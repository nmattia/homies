let mapleader=","
echo $NEOVIM_PLUGINS_PATH
set packpath+=$NEOVIM_PLUGINS_PATH

" git = ignore = false: make sure nvim-tree shows gitignored files
lua require'nvim-tree'.setup({git = { ignore = false }})
nnoremap <Leader>o :NvimTreeToggle<CR>

" don't wrap lines
set nowrap

" Simplify navigation across windows
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" TERMINAL

" Exit terminal through Ctrl+hjkl
:tnoremap <C-H> <C-\><C-N><C-W><C-H>
:tnoremap <C-J> <C-\><C-N><C-W><C-J>
:tnoremap <C-K> <C-\><C-N><C-W><C-K>
:tnoremap <C-L> <C-\><C-N><C-W><C-L>

" Make sure :terminal loads bash profile
set shell=bash\ -l
