lua << EOF
-- Set the mapleader
vim.g.mapleader = ","

-- Open new splits on the right/below
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Display tabs and trailing spaces
vim.opt.list = true
vim.opt.listchars = { tab = "▷⋅", trail = "⋅", nbsp = "⋅" }

-- Wrap lines
vim.opt.wrap = true

-- Default indent settings
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

-- Set the width of \t to 4. It's still a TAB, but displayed as wide as 4
-- chars.
vim.opt.tabstop = 4

-- In insert mode, hitting TAB will insert N spaces instead.
vim.opt.expandtab = true

-- NEOVIM_PLUGINS_PATH should be set to a dir containing plugins
vim.opt.packpath =
    vim.opt.packpath ~= ""
    and vim.env.NEOVIM_PLUGINS_PATH
    or vim.env.NEOVIM_PLUGINS_PATH .. "," .. vim.opt.packpath

-- git = ignore = false: make sure nvim-tree shows gitignored files
require'nvim-tree'.setup({ git = { ignore = false }})



-- Toggle filetree on ,o
vim.api.nvim_set_keymap('n', '<Leader>o', ':NvimTreeToggle<CR>', { noremap = true })

-- Toggle Buffers on ,b
vim.api.nvim_set_keymap('n', '<Leader>b', ':Buffers<CR>', { noremap = true })

-- search

-- Stop highlighting search on C-/
vim.api.nvim_set_keymap('n', '<C-_>', ':noh<CR>', { noremap = true })

-- Case insensitive search with ,/
vim.api.nvim_set_keymap('n', '<Leader>/', '/\\c', { noremap = true })

-- Navigation across windows

-- Simplify navigator across windows; C-{hjkl} moves to other window
for _,key in pairs{ 'H', 'J', 'K', 'L' } do
    vim.api.nvim_set_keymap('n', '<C-'..key..'>', '<C-W><C-'..key..'>', { noremap = true })
end

-- Same, in insert mode (uses C-O which runs a command and then re-enters
-- insert mode)
for _,key in pairs{ 'H', 'J', 'K', 'L' } do
    vim.api.nvim_set_keymap('i', '<C-'..key..'>', '<C-O><C-W><C-'..key..'>', { noremap = true })
end

-- Misc

-- Open file picker (FZF) on ,f
vim.api.nvim_set_keymap('n', '<Leader>f', ':FZF<CR>', { noremap = true })

-- Wrap selected lines with Q
vim.api.nvim_set_keymap('n', 'Q', 'gq', { noremap = true })

-- Yank til end of line (consistent with C and D)
vim.api.nvim_set_keymap('n', 'Y', 'y$', { noremap = true })

-- Select the whole file with <C-G>
vim.api.nvim_set_keymap('n', '<C-G>', 'ggVG<CR>', { noremap = true })

-- TERMINAL

-- Open a terminal in the current window
vim.api.nvim_set_keymap('n', '<Leader>t', ':terminal<CR>', { noremap = true })

-- Exit terminal through Ctrl+hjkl
for _,key in pairs{ 'H', 'J', 'K', 'L' } do
    vim.api.nvim_set_keymap('t', '<C-'..key..'>', '<C-\\><C-N><C-W><C-'..key..'>', { noremap = true })
end

-- Exit terminal with <C-\>
vim.api.nvim_set_keymap('t', '<C-\\>', '<C-\\><C-N>', { noremap = true })



-- Make sure :terminal loads bash profile
vim.opt.shell = "bash -l"
EOF

" Some things that Lua doesn't support (yet)

" Show line numbers
set number
" ... except in terminal
autocmd TermOpen * setlocal nonumber norelativenumber

" Remove trailing whitespaces
nnoremap <Leader>w :call TrimWhitespace()<CR>
fun! TrimWhitespace()
    " by saving/restoring the view we make sure the cursor doesn't appear to
    " have moved
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun

""""""""""""
" TERMINAL "
""""""""""""

" Close the terminal buffer if the terminal exits with 0
autocmd TermClose * if !v:event.status | exe 'bdelete! '..expand('<abuf>') | endif
