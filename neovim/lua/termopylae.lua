local M = {}

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

    -- Before we move to the new window, we record the current window so that
    -- we can come back to it
    M.previous_win_nr = vim.api.nvim_get_current_win()
    -- ... and the previous buffer (used if the window isn't valid anymore)
    M.previous_buf_nr = vim.api.nvim_get_current_buf()

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

    -- If no open window contains a terminal, create a new window
    vim.cmd('vnew')

    -- If a buffer already contains a terminal, load that buffer
    local bufs = vim.api.nvim_list_bufs()
    for k in pairs(bufs) do
        local buf_nr = bufs[k]
        local buf_name = vim.api.nvim_buf_get_name(buf_nr)
        if(string.find(buf_name, "term://")) then
            vim.api.nvim_set_current_buf(buf_nr)
            vim.cmd('startinsert')
            return
        end
    end

    -- Otherwise create a new terminal
    vim.cmd('terminal')
    vim.cmd('startinsert')
end

-- If a previous window is recorded, go back to it
local leave_term = function()
    if(M.previous_win_nr and vim.api.nvim_win_is_valid(M.previous_win_nr)) then
        vim.api.nvim_set_current_win(M.previous_win_nr)
        M.previous_win_nr = nil
        M.previous_buf_nr = nil
    elseif (M.previous_buf_nr and vim.api.nvim_buf_is_valid(M.previous_buf_nr)) then
        vim.api.nvim_set_current_buf(M.previous_buf_nr)
        M.previous_win_nr = nil
        M.previous_buf_nr = nil
    end
end

M['enter_term'] = enter_term
M['leave_term'] = leave_term

return M
