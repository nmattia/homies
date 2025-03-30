local api = vim.api

local function read_file(filename)
    local f = assert(io.open(filename, "rb"))
    local content = f:read("*all")
    f:close()
    return content
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
        on_exit = function(job_id, exit_code)


            -- Avoid "Process exited with ..."
            -- (buffer is still valid iff it wasn't somehow deleted already)
            if api.nvim_buf_is_valid(new_buf_nr) then
                api.nvim_buf_delete(new_buf_nr, {})
            end

            if(exit_code ~= 0) then
                -- most likely ^C
                return
            end

            local content = read_file(stdout_filename)
            local filename, lineno = rg_filename_and_lineno(content)

            -- open file at line
            vim.cmd('e '..'+'..lineno..' '..filename)

            -- center
            vim.api.nvim_feedkeys("zz", "n", false)

            os.remove(stdout_filename)
        end

    })
    vim.cmd'startinsert'
end


return { rg = rg }
