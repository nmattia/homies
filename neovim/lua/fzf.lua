local api = vim.api

local function read_file(filename)
    local f = assert(io.open(filename, "rb"))
    local content = f:read("*all")
    f:close()
    return content
end

-- write the lines in table 'content' to 'filename
local function append_file(filename, content)
    local f = assert(io.open(filename, "a"))
    iter(content):each(function(line) f:write(line, "\n") end)
    f:close()
end

local function execute_stdout(command)
    local out = os.tmpname()
    os.execute(command.. " >"..out)
    local stdout = read_file(out)
    os.remove(out)
    return stdout
end

local function tmpdir()
    local filename = execute_stdout("mktemp -d")
    return string.gsub(filename, '\n$', '')
end

-- Function that removes repeated empty strings
local function remove_repeated_blanks(values)
    local filtered = {}
    local empty_previous = true

    iter(values):each(function(v)
        local empty = v == ""
        if (empty) then
            if (not empty_previous) then
                table.insert(filtered, v)
            end
        else
            table.insert(filtered, v)
        end
        empty_previous = empty
    end)

    return filtered
end

-- split the string on newline chars
local string_lines = function(text)
    local lines = {}
    for s in text:gmatch("[^\n]+") do
        table.insert(lines,s)
    end
    return lines
end

local get_buf_by_name = function(name)
    return iter(api.nvim_list_bufs()):filter(function(buf_nr)
        return api.nvim_buf_get_name(buf_nr) == name
    end):nth(1)
end

local log_buf_name = "log://custom-fzf"

local create_log_buf = function()
    local log_buf = api.nvim_create_buf(true, true)
    api.nvim_buf_set_name(log_buf, log_buf_name)
    return log_buf
end

local get_log_buf = function()
    return get_buf_by_name(log_buf_name) or create_log_buf()
end

local log = function(text)
    local success = pcall(function()
        local log_buf = get_log_buf()
        local lines = { os.date() }
        iter(string_lines(vim.inspect(text))):each(function(v)
            table.insert(lines,v)
        end)
        api.nvim_buf_set_lines(log_buf, -1, -1, false, lines)
    end)
    if(not success) then
        api.nvim_buf_set_lines(get_log_buf(), -1, -1, false, {"warning: log() failed"})
    end
end

local rg_filename_and_lineno = function(line)
    local idx = string.find(line, ":")
    local filename = string.sub(line, 1, idx-1)
    line = string.sub(line, idx+1, -1)

    idx = string.find(line, ":")
    local lineno = string.sub(line, 1, idx-1)

    return filename, tonumber(lineno)
end

local mk_fzf_bindings = function(bindings)
    local kvs = iter(bindings):map(function(k,v) return k..":"..v end):totable()
    return table.concat(kvs, ",")
end

local rg = function()

    vim.cmd("new")
    local new_buf_nr = api.nvim_get_current_buf()
    local stdout_filename = os.tmpname()

    -- --line-number: show line numbers, useful when picking exact line
    -- --no-heading: don't cluster by file name (file name is printed alone above matches)
    -- '\S': print all lines that contain at least one non-space character
    -- --hidden --glob '!.git': show hidden files like `.github/` but ignore `.git/`
    local rg_opts = '--line-number --no-heading --color=always --hidden --glob "!.git"'
    local rg = 'rg '..rg_opts..' -- "\\S"'

    -- num[b]er all lines, and format is [l]eft justified
    local add_linenos = 'nl -b all -n ln'

    -- Match on 'start of line' + line number of selected line
    -- Capture rest of line in \1
    -- Replace everything with "line number" + <start highlight> + \1 + <stop highlight>
    local highlight_line = [[sed "s/^"{2}" \(.*\)""/"{2}" "`tput bold`"\1"`tput sgr0`"/"]]

    -- fzf's preview command, that shows the file (with the selected line highlighted)
    local preview_cmd = 'cat {1} | '..add_linenos..' | '..highlight_line

    local fzf_bindings = mk_fzf_bindings{
        ['ctrl-p'] = 'toggle-preview',
        ['ctrl-c'] = 'cancel',
        ['ctrl-u'] = 'preview-half-page-up',
        ['ctrl-d'] = 'preview-half-page-down',
    }

    local fzf_opts = {
        "--ansi", -- works with --color=always in rg to show colors properly
        "--delimiter=':'", -- used by fzf to split "FIELD INDEX EXPRESSIONS" (':' is the default rg delimited)
        [[--preview ']]..preview_cmd..[[']], -- specify how the currently selected file should be previewed
        "--preview-window=hidden", -- don't open preview unless asked to
        [[--bind ']]..fzf_bindings..[[']],
    }

    -- Make the actual command
    local fzf = 'fzf '..table.concat(fzf_opts, ' ')..' >'..stdout_filename
    local term_cmd = rg..' | '..fzf

    vim.fn.termopen(term_cmd, {
        on_exit = function()

            -- Avoid "Process exited with ..."
            -- (buffer is still valid iff it wasn't somehow deleted already)
            if api.nvim_buf_is_valid(new_buf_nr) then
                api.nvim_buf_delete(new_buf_nr, {})
            end

            local content = read_file(stdout_filename)
            local filename, lineno = rg_filename_and_lineno(content)

            -- open file at line
            vim.cmd('e '..'+'..lineno..' '..filename)

            -- center
            vim.cmd'zz'

            os.remove(stdout_filename)
        end

    })
    vim.cmd'startinsert'
end

local function term_get_pid(buf_nr)
    local term_name = vim.api.nvim_buf_get_name(buf_nr)
    local pid = string.match(term_name, "%d+") -- check for nil
    return tonumber(pid) -- this doesn't error out; worst case it returns nil
end

-- pid is a number
local function get_proc_child(pid)
    local ok, data = pcall(function() return vim.api.nvim_get_proc_children(pid) end)
    if(not ok) then
        return nil
    end

    local children = data
    if(children == nil) then
        log("Unexpected nil children")
        return nil
    end
    if(#children == 0) then return nil end

    return children[1]
end

local function get_proc_command(pid)
    local full = execute_stdout("ps -o command -p "..tostring(pid))
    full = string_lines(full)
    if (#full < 2)  then return nil end
    return full[2]
end

local function term_get_running_command(buf_nr)
    local pid = term_get_pid(buf_nr)
    if (pid == nil) then return nil end

    range(10):each(function()
        pid = get_proc_child(pid)
        if (pid == nil) then return nil end

        local command = get_proc_command(pid)
        if(command == nil) then return nil end

        if(not (string.match(command, "/bin/bash")))then
            return command
        end
    end)

    return nil
end

local function lines_infer_last_command(lines)
    for i=1, #lines do
       local line = lines[#lines + 1 - i]
       local idx = string.find(line, "%$")
       if(idx ~= nil) then
           local rest = string.sub(line, idx + 2)
           if(string.match(rest, "%w")) then
               return rest
           end
       end
    end

    return nil
end

local terms = function()
    local previous_win_nr = vim.api.nvim_get_current_win()

    vim.cmd'new' -- create a new window where fzf will be shown

    local new_buf_nr = api.nvim_get_current_buf()

    -- A temporary directory within which each filename
    -- is a buffer number, and each file contains a preview
    -- of the buffer.
    local terms_dir = tmpdir()

    local terms = iter(vim.api.nvim_list_bufs()):filter(function(buf_nr)
        local buf_name = vim.api.nvim_buf_get_name(buf_nr)
        return string.find(buf_name, "term://")
    end)

    -- file used to tell fzf about candidates
    local stdin_filename = os.tmpname()

    -- for each term, create the preview file, and add the term
    -- to the list of candidates
    terms:each(function(buf_nr)
        local filename = terms_dir..'/'..tostring(buf_nr)
        local content = api.nvim_buf_get_lines(buf_nr,0, -1, false)
        content = remove_repeated_blanks(content)
        append_file(filename, content)
        local last_command =
            term_get_running_command(buf_nr) or
            lines_infer_last_command(content) or
            " ? "
        append_file(stdin_filename, { tostring(buf_nr).." "..last_command })
    end)

    -- file used to retrieve fzf's selection
    local stdout_filename = os.tmpname()

    local fzf_bindings = mk_fzf_bindings{
        ['ctrl-c'] = 'cancel',
        ['ctrl-u'] = 'preview-half-page-up',
        ['ctrl-d'] = 'preview-half-page-down',
    }

    -- the preview command where {1} represents the first "field index expression"
    -- (i.e. "42" in "42 <some command>")
    local preview_cmd = 'cat '..terms_dir..'/{1}'

    local fzf_opts = {
        "--preview-window follow", -- basically 'tail -f', used to show the bottom of the file
        [[--preview ']]..preview_cmd..[[']], -- specify how the currently selected file should be previewed
        [[--bind ']]..fzf_bindings..[[']],
    }

    -- Make the actual command
    local term_cmd = 'fzf <'..stdin_filename..' '..table.concat(fzf_opts, " ")..' >'..stdout_filename

    vim.fn.termopen(term_cmd, {
        on_exit = function()
            local status, err = pcall(function ()
                -- Avoid "Process exited with ..."
                -- (buffer is still valid iff it wasn't somehow deleted already)
                if api.nvim_buf_is_valid(new_buf_nr) then
                    api.nvim_buf_delete(new_buf_nr, {})
                end

                -- Read buffer number out
                local buf_entry = read_file(stdout_filename)
                local buf_nr = string.match(buf_entry, "^%d+")
                buf_nr = tonumber(buf_nr)

                -- Go back to previous window and open buffer
                vim.api.nvim_set_current_win(previous_win_nr)
                vim.api.nvim_set_current_buf(buf_nr)
                vim.api.nvim_input("i") -- note: for some reason startinsert doesn't work here
            end)

            terms:each(function(buf_nr)
                os.remove(terms_dir..'/'..buf_nr)
            end)

            os.remove(terms_dir)
            os.remove(stdin_filename)
            os.remove(stdout_filename)

            if(not status) then
                log("Error caught when opening term")
                log(err)
            end
        end

    })
    vim.cmd("startinsert")
end

return { rg = rg, terms = terms }
