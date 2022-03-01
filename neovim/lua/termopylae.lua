local ret = {}

-- Move cursor to the first visible terminal found
local enter_term = function()

    -- Map windows to buffers
    local wins = vim.api.nvim_list_wins()
    local win_to_buf = {}

    for k in pairs(wins) do
        local win_nr = wins[k]
        local buf_nr = vim.api.nvim_win_get_buf(win_nr)

        win_to_buf[win_nr] = buf_nr
    end

    -- Iterate over the windows and, if the buffer is a terminal,
    -- move cursor to window.
    for win_nr in pairs(win_to_buf) do
        local buf_nr = win_to_buf[win_nr]
        local buf_name = vim.api.nvim_buf_get_name(buf_nr)
        if(string.find(buf_name, "term://")) then

            -- Before we move to the new window, we record the current window
            -- so that we can come back to it
            ret.previous_win_nr = vim.api.nvim_get_current_win()

            vim.api.nvim_set_current_win(win_nr)
            vim.cmd('startinsert')
            return
        end
    end
end

-- If a previous window is recorded, go back to it
local leave_term = function()
    if(ret.previous_win_nr) then
        vim.api.nvim_set_current_win(ret.previous_win_nr)
        ret.previous_win_nr = nil
    end
end

ret['enter_term'] = enter_term
ret['leave_term'] = leave_term

return ret
