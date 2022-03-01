-- Move cursor to the first visible terminal found
local get_term = function()


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
            vim.api.nvim_set_current_win(win_nr)
            vim.cmd('startinsert')
            return
        end
    end
end

return { get_term = get_term }
