-- First, make sure the Lua modules can be "require"d
package.path = package.path .. ";" .. vim.env.NEOVIM_LUA_PATH

-- Initialize functional lua
require'fun'()

-- Set the mapleader (space)
-- note: we remap space to ensure there's no existing mapping: https://stackoverflow.com/a/446293
vim.keymap.set('n', ' ', '<Nop>', { silent = true, remap = false })
vim.g.mapleader = ' '

local opts = {

    -- Open new splits on the right/below
    "splitright",
    "splitbelow",

    -- Display tabs and trailing spaces
    list = true,
    listchars = { tab = "▷⋅", trail = "⋅", nbsp = "⋅" },

    -- Wrap lines
    wrap = true,

    -- Default indent settings
    shiftwidth = 4,
    softtabstop = 4,

    -- Set the width of \t to 4. It's still a TAB, but displayed as wide as 4
    -- chars.
    tabstop = 4,

    -- In insert mode, hitting TAB will insert N spaces instead.
    expandtab = true,

    -- NEOVIM_PLUGINS_PATH should be set to a dir containing plugins
    packpath = vim.opt.packpath + { vim.env.NEOVIM_PLUGINS_PATH },

    -- Large scrollback in terminal (default: 10_000)
    scrollback = 100000,

    -- Enables 24-bit RGB color
    termguicolors = true,
}

-- This reads all the "opts" and sets the corresponding vim opt. This takes
-- advantage of the fact that Lua treats { "foo" } as an associative array with
-- { 1 = "foo" }, thus, if a key is a "number", then we set the opt to "true".
for opt_key in pairs(opts) do
    if(type(opt_key) == "number") then
        vim.opt[opts[opt_key]] = true
    elseif (type(opt_key) == "string") then
        vim.opt[opt_key] = opts[opt_key]
    end
end

-- Show line numbers
vim.opt.number = true
-- ... except in terminal
vim.api.nvim_create_autocmd('TermOpen', {
    callback = function ()
        vim.wo.number = false
        vim.wo.relativenumber = false
    end
})

-- git = ignore = false: make sure nvim-tree shows gitignored files
require'nvim-tree'.setup({ git = { ignore = false }})

-- Toggle filetree on ,o
vim.keymap.set('n', '<Leader>o', vim.cmd.NvimTreeToggle, { noremap = true })

-- Remove trailing whitespaces
vim.api.nvim_command([[
fun! TrimWhitespace()
    " by saving/restoring the view we make sure the cursor doesn't appear to
    " have moved
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun
]])
vim.keymap.set('n', '<Leader>w', vim.fn.TrimWhitespace, { noremap = true })

-- search

-- Stop highlighting search on C-/
vim.keymap.set('n', '<C-/>', vim.cmd.noh, { noremap = true })

-- Case insensitive search with ,/
vim.keymap.set('n', '<Leader>/', '/\\c', { noremap = true })

-- E[x]it with ,x
vim.keymap.set('n', '<Leader>x', vim.cmd.x, { noremap = true })

-- [d]elete buffer with ,d
-- note: this uses 'bufdelete' which ensures that nvim-tree doesn't end up as fullscreen
-- when it's the last buffer
vim.keymap.set('n', '<Leader>d', require'bufdelete'.bufdelete, { noremap = true })

-- Navigation across windows

-- Simplify navigator across windows; C-{hjkl} moves to other window
for _,key in pairs{ 'H', 'J', 'K', 'L' } do
    vim.keymap.set('n', '<C-'..key..'>', '<C-W><C-'..key..'>', { noremap = true })
end

-- Same, in insert mode (uses C-O which runs a command and then re-enters
-- insert mode)
for _,key in pairs{ 'H', 'J', 'K', 'L' } do
    vim.keymap.set('i', '<C-'..key..'>', '<C-O><C-W><C-'..key..'>', { noremap = true })
end

-- FZF + ripgrep on ,fr

local fzf = require'fzf'
vim.keymap.set('n', '<Leader>fr', fzf.rg, { noremap = true })

-- Misc

-- Wrap selected lines with Q
vim.keymap.set('n', 'Q', 'gq', { noremap = true })

-- Yank til end of line (consistent with C and D)
vim.keymap.set('n', 'Y', 'y$', { noremap = true })

-- Select the whole file with <C-G>
vim.keymap.set('n', '<C-G>', 'ggVG<CR>', { noremap = true })

-- Start a git command with ,g
vim.keymap.set('n', '<Leader>g', ':G ', { noremap = true })

-- [r]efresh buffers
vim.keymap.set('n', '<Leader>r', ':checktime<CR> ', { noremap = true })

-- In Visual, sort with <C-S>
vim.keymap.set('v', '<C-S>', ':sort<CR>', { noremap = true })

-- Create a scratch buffer with leader + s
vim.keymap.set('n', '<Leader>s', function()
  vim.cmd('enew')  -- empty unnamed buffer
  vim.bo.buftype = 'nofile'
  vim.bo.bufhidden = 'hide'
  vim.bo.swapfile = false
  vim.bo.filetype = 'markdown'
end, { noremap = true, desc = "New scratch buffer" })

-- TERMINAL

-- Open a terminal in the current window
vim.keymap.set('n', '<Leader>t', vim.cmd.terminal, { noremap = true })

-- Exit terminal through Ctrl+hjkl
for _,key in pairs{ 'H', 'J', 'K', 'L' } do
    vim.keymap.set('t', '<C-'..key..'>', '<C-\\><C-N><C-W><C-'..key..'>', { noremap = true })
end

-- Close the terminal buffer if the terminal exits with 0
vim.api.nvim_create_autocmd('TermClose', {
    command = "if !v:event.status | exe 'bdelete! '..expand('<abuf>') | endif"
})

-- Multi-cursor edit (enabled only in normal mode to avoid clash with
-- <C-S> in visual mode)
local mc = require("multicursor-nvim")
mc.setup()
-- Add a cursor and jump to the next word under cursor.
vim.keymap.set({'n'}, '<C-N>', function() mc.addCursor("*") end)
-- Skip word under cursor
vim.keymap.set({'n'}, '<C-S>', function() mc.skipCursor("*") end)

-- Clear all cursors
vim.keymap.set({'n', 'v'}, '<C-\\>', function()
    if mc.hasCursors() then
        mc.clearCursors()
    end
end)

-- Set up bufferline: https://github.com/akinsho/bufferline.nvim?tab=readme-ov-file#usage
require("bufferline").setup{}

-- switch to previous/next buffer (and enter submode for quick repeat with h/l)
vim.api.nvim_command([[
call submode#enter_with('switchbuf', 'n', '', '<Leader>h', ':bprevious<CR>')
call submode#enter_with('switchbuf', 'n', '', '<Leader>l', ':bnext<CR>')
call submode#leave_with('switchbuf', 'n', '', '<Esc>')
call submode#map('switchbuf', 'n', '', 'h', ':bprevious<CR>')
call submode#map('switchbuf', 'n', '', 'l', ':bnext<CR>')
]])

-- Make vim sees the leaving key when exiting a submode (similar to
-- e.g. opt+key when emulating Esc)
vim.g.submode_keep_leaving_key = true
