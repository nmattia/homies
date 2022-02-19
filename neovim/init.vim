let mapleader=","

" Open new splits on the right
set splitright
set splitbelow

" NEOVIM_PLUGINS_PATH should be set to a dir containing plugins
set packpath+=$NEOVIM_PLUGINS_PATH

" git = ignore = false: make sure nvim-tree shows gitignored files
lua require'nvim-tree'.setup({git = { ignore = false }})

" Toggle filetree on ,o
nnoremap <Leader>o :NvimTreeToggle<CR>

" don't wrap lines
set nowrap

" Simplify navigation across windows
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Same, in insert mode (uses C-O which runs a command and then re-enters
" insert mode)
inoremap <C-J> <C-O><C-W><C-J>
inoremap <C-K> <C-O><C-W><C-K>
inoremap <C-L> <C-O><C-W><C-L>
inoremap <C-H> <C-O><C-W><C-H>

" Save buffer on ,w
nnoremap <Leader>w :write<CR>

" TERMINAL

" Create a new pane and open terminal on ,t
" nnoremap <Leader>t <C-W><C-V><C-W><C-L>:terminal<CR>
nnoremap <Leader>t :new<CR>:terminal<CR>
nnoremap <Leader>T :vnew<CR>:terminal<CR>

" Open new terminals in insert mode
autocmd TermOpen * startinsert

" Exit terminal through Ctrl+hjkl
tnoremap <C-H> <C-\><C-N><C-W><C-H>
tnoremap <C-J> <C-\><C-N><C-W><C-J>
tnoremap <C-K> <C-\><C-N><C-W><C-K>
tnoremap <C-L> <C-\><C-N><C-W><C-L>

" Make sure :terminal loads bash profile
set shell=bash\ -l
