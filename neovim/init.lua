-- First, make sure the Lua modules can be "require"d
package.path = package.path .. ";" .. vim.env.NEOVIM_LUA_PATH .. "/?.lua"

-- Set the mapleader
vim.g.mapleader = ","

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
    packpath =
        vim.opt.packpath ~= ""
        and vim.env.NEOVIM_PLUGINS_PATH
        or vim.env.NEOVIM_PLUGINS_PATH .. "," .. vim.opt.packpath,

    -- Make sure :terminal loads bash profile
    shell = "bash -l",
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
vim.keymap.set('n', '<Leader>o', ':NvimTreeToggle<CR>', { noremap = true })

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
vim.keymap.set('n', '<Leader>w', ':call TrimWhitespace()<CR>', { noremap = true })

-- search

-- Stop highlighting search on C-/
vim.keymap.set('n', '<C-/>', ':noh<CR>', { noremap = true })

-- Case insensitive search with ,/
vim.keymap.set('n', '<Leader>/', '/\\c', { noremap = true })

-- E[x]it with ,x
vim.keymap.set('n', '<Leader>x', ':x<CR>', { noremap = true })

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
vim.keymap.set('n', '<Leader>ft', fzf.terms, { noremap = true })

-- Misc

-- Wrap selected lines with Q
vim.keymap.set('n', 'Q', 'gq', { noremap = true })

-- Yank til end of line (consistent with C and D)
vim.keymap.set('n', 'Y', 'y$', { noremap = true })

-- Select the whole file with <C-G>
vim.keymap.set('n', '<C-G>', 'ggVG<CR>', { noremap = true })

-- Start a git command with ,g
vim.keymap.set('n', '<Leader>g', ':G ', { noremap = true })

-- In Visual, sort with <C-S>
vim.keymap.set('v', '<C-S>', ':sort<CR>', { noremap = true })

-- TERMINAL

-- Open a terminal in the current window
vim.keymap.set('n', '<Leader>t', ':terminal<CR>', { noremap = true })

-- Exit terminal through Ctrl+hjkl
for _,key in pairs{ 'H', 'J', 'K', 'L' } do
    vim.keymap.set('t', '<C-'..key..'>', '<C-\\><C-N><C-W><C-'..key..'>', { noremap = true })
end

-- Close the terminal buffer if the terminal exits with 0
vim.api.nvim_create_autocmd('TermClose', {
    command = "if !v:event.status | exe 'bdelete! '..expand('<abuf>') | endif"
})

-- Go to terminal on <C-Space>
local termopylae = require'termopylae'
vim.keymap.set('n', '<C-Space>', termopylae.enter_term, { noremap = true })

-- Exit terminal and go back to previous window with <C-Space>
vim.keymap.set('t', '<C-Space>', termopylae.leave_term, { noremap = true })
-- Simply exit terminal with <C-\>
vim.keymap.set('t', '<C-\\>', '<C-\\><C-N>', { noremap = true })
-- In general, go to normal mode with <C-\> (in addition to the default <C-[>)
vim.keymap.set('i', '<C-\\>', '<Esc>', { noremap = true })
-- Map it for normal mode as well, because of muscle memory. Otherwise vim expects other keys.
vim.keymap.set('n', '<C-\\>', '<Esc>', { noremap = true })
