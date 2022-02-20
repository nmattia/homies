let mapleader=","

" Open new splits on the right
set splitright
set splitbelow

" Show line numbers
set number
" ... except in terminal
autocmd TermOpen * setlocal nonumber norelativenumber

" Display tabs and trailing spaces
set list
set listchars=tab:▷⋅,trail:⋅,nbsp:⋅

" Wrap lines
set wrap

" Default indent settings
set shiftwidth=4
set softtabstop=4

" Set the width of \t to 4. It's still a TAB, but displayed as wide as 4
" chars.
set tabstop=4

" In insert mode, hitting TAB will insert N spaces instead.
set expandtab

" NEOVIM_PLUGINS_PATH should be set to a dir containing plugins
set packpath+=$NEOVIM_PLUGINS_PATH

" git = ignore = false: make sure nvim-tree shows gitignored files
lua require'nvim-tree'.setup({git = { ignore = false }})

" Toggle filetree on ,o
nnoremap <Leader>o :NvimTreeToggle<CR>

" Toggle Buffers on ,b
nnoremap <Leader>b :Buffers<CR>

" Remove trailing whitespaces
nnoremap <Leader>w :call TrimWhitespace()<CR>
fun! TrimWhitespace()
    " by saving/restoring the view we make sure the cursor doesn't appear to
    " have moved
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun


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

" Open file picker (FZF) on ,f
nnoremap <Leader>f :FZF<CR>

""""""""""""
" TERMINAL "
""""""""""""

" Create a new pane and open terminal
nnoremap <C-W>ws :new<CR>:terminal<CR>

" Open a terminal in the current window
nnoremap <Leader>t :terminal<CR>

" or this? nnoremap <C-W>ws :new<CR>:terminal<CR>
nnoremap <C-W>wv :vnew<CR>:terminal<CR>

" Open new terminals in insert mode
autocmd TermOpen * startinsert

" Exit terminal through Ctrl+hjkl
tnoremap <C-H> <C-\><C-N><C-W><C-H>
tnoremap <C-J> <C-\><C-N><C-W><C-J>
tnoremap <C-K> <C-\><C-N><C-W><C-K>
tnoremap <C-L> <C-\><C-N><C-W><C-L>

" Exit terminal with <C-\>
tnoremap <C-\> <C-\><C-N>

" Close the terminal buffer if the terminal exits with 0
autocmd TermClose * if !v:event.status | exe 'bdelete! '..expand('<abuf>') | endif

" Make sure :terminal loads bash profile
set shell=bash\ -l
