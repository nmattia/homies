local api = vim.api
local pp = vim.pretty_print
local cmd = vim.cmd

function read_file(file)
    local f = assert(io.open(file, "rb"))
    local content = f:read("*all")
    f:close()
    return content
end

local get_buf_by_name = function(name)
    for k,v in pairs(api.nvim_list_bufs()) do
        if(api.nvim_buf_get_name(v) == name) then
            return v
        end
    end
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
    local log_buf = get_log_buf()
    api.nvim_buf_set_lines(log_buf, -1, -1, false, {os.date()})
    api.nvim_buf_set_lines(log_buf, -1, -1, false, {vim.inspect(text)})
end

local rg_filename_and_lineno = function(line)
    local idx = string.find(line, ":")
    local filename = string.sub(line, 1, idx-1)
    line = string.sub(line, idx+1, -1)

    idx = string.find(line, ":")
    local lineno = string.sub(line, 1, idx-1)

    return filename, tonumber(lineno)
end

local rg = function()

    vim.cmd("new")
    local new_buf_nr = api.nvim_get_current_buf()
    local stdout_filename = os.tmpname()

    local nl = [[nl -b a -n ln | sed "s/^42\(.*\)/`tput bold`>>> 42\1`tput sgr0`/"]]

    local rg_opts = '--line-number --no-heading --smart-case --color=always'
    local rg = 'rg '..rg_opts..' .'

    local preview_cmd = [[cat {1} | nl -b a -n ln | sed "s/^"{2}" \(.*\)""/"{2}" "`tput bold`"\1"`tput sgr0`"/"]]
    local bindings = 'ctrl-p:toggle-preview,ctrl-c:cancel,ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down'
    local fzf_opts = [[--ansi --delimiter=':' --preview ']]..preview_cmd..[[' --preview-window=hidden --bind ']]..bindings..[[']]
    local fzf = [[fzf ]]..fzf_opts..[[ >]]..stdout_filename

    -- --color=always + --ansi = colors
    -- TODO: document the hell out of this
    vim.fn.termopen(rg..' | '..fzf, {
        on_exit = function()

            -- Avoid "Process exited with ..."
            -- (buffer is still valid iff it wasn't somehow deleted already)
            if api.nvim_buf_is_valid(new_buf_nr) then
                api.nvim_buf_delete(new_buf_nr, {})
            end

            local content = read_file(stdout_filename)
            local filename, lineno = rg_filename_and_lineno(content)

            -- open file at line
            vim.cmd("e ".."+"..lineno.." "..filename)

            -- center
            vim.cmd'zz'

            os.remove(stdout_filename)
        end

    })
    vim.cmd("startinsert")
end


local rg_opts = {
    -- show filename on each line, instead of grouping lines by filename
    "--no-heading",

    -- default to case insensivity, unless the pattern is mixed-case
    "--smart-case",
}

-- local fzf_bind = {
--     'ctrl-d' = "preview-half-page-down",
--     'ctrl-u' = "preview-half-page-up",
--
--     -- clear query string if not empty, abort fzf otherwise
--     'ctrl-c' = "cancel",
-- }

return { rg = rg }
