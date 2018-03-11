let mapleader=","
set encoding=utf-8

""Use Vim settings, rather then Vi settings (much better!).
"This must be first, because it changes other options as a side effect.
set nocompatible

"allow backspacing over everything in insert mode
set backspace=indent,eol,start

"store lots of :cmdline history
set history=1000

set showcmd     "show incomplete cmds down the bottom
set showmode    "show current mode down the bottom

set number      "show line numbers

"display tabs and trailing spaces
set list
set listchars=tab:▷⋅,trail:⋅,nbsp:⋅

set hlsearch    "hilight searches by default

set wrap        "wrap lines
set linebreak   "wrap lines at convenient points

if v:version >= 703
    "undo settings
    set undodir=~/.vim/undofiles
    set undofile

    set colorcolumn=+1 "mark the ideal max text width
endif

"default indent settings
set shiftwidth=4
set softtabstop=4
set tabstop=4       " The width of a TAB is set to 4.
                    " Still it is a \t. It is just that
                    " Vim will interpret it to be having
                    " a width of 4.
set expandtab
set autoindent

"folding settings
set foldmethod=indent   "fold based on indent
set foldnestmax=3       "deepest fold is 3 levels
set nofoldenable        "dont fold by default

set wildmode=longest,list,full
set wildignore=*.o,*.obj,*~ "stuff to ignore when tab completing
set wildignore+=*\\tmp\\*,*.swp,*.swo,*.zip,.git,.cabal-sandbox
set wildmenu                "enable ctrl-n and ctrl-p to scroll thru matches
set completeopt+=longest

set formatoptions-=o "dont continue comments when pushing o/O

"vertical/horizontal scroll off settings
set scrolloff=3
set sidescrolloff=7
set sidescroll=1

"load ftplugins and indent files
filetype plugin on
filetype indent on

"turn on syntax highlighting
syntax on

"some stuff to get the mouse going in term
set mouse=a

""tell the term has 256 colors
set t_Co=256

"hide buffers when not displayed
set hidden

"statusline setup
set statusline =%#identifier#
set statusline+=[%t]    "tail of the filename
set statusline+=%*

"display a warning if fileformat isnt unix
set statusline+=%#warningmsg#
set statusline+=%{&ff!='unix'?'['.&ff.']':''}
set statusline+=%*

"display a warning if file encoding isnt utf-8
set statusline+=%#warningmsg#
set statusline+=%{(&fenc!='utf-8'&&&fenc!='')?'['.&fenc.']':''}
set statusline+=%*

set statusline+=%h      "help file flag
set statusline+=%y      "filetype

"read only flag
set statusline+=%#identifier#
set statusline+=%r
set statusline+=%*

"modified flag
set statusline+=%#identifier#
set statusline+=%m
set statusline+=%*

"display a warning if &et is wrong, or we have mixed-indenting
set statusline+=%#error#
set statusline+=%{StatuslineTabWarning()}
set statusline+=%*

set statusline+=%{StatuslineTrailingSpaceWarning()}

set statusline+=%{StatuslineLongLineWarning()}

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

"display a warning if &paste is set
set statusline+=%#error#
set statusline+=%{&paste?'[paste]':''}
set statusline+=%*

set statusline+=%=      "left/right separator
set statusline+=%{StatuslineCurrentHighlight()}\ \ "current highlight
set statusline+=%c,     "cursor column
set statusline+=%l/%L   "cursor line/total lines
set statusline+=\ %P    "percent through file

"recalculate the trailing whitespace warning when idle, and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_trailing_space_warning

"return '[\s]' if trailing white space is detected
"return '' otherwise
function! StatuslineTrailingSpaceWarning()
    if !exists("b:statusline_trailing_space_warning")

        if !&modifiable
            let b:statusline_trailing_space_warning = ''
            return b:statusline_trailing_space_warning
        endif

        if search('\s\+$', 'nw') != 0
            let b:statusline_trailing_space_warning = '[\s]'
        else
            let b:statusline_trailing_space_warning = ''
        endif
    endif
    return b:statusline_trailing_space_warning
endfunction


"return the syntax highlight group under the cursor ''
function! StatuslineCurrentHighlight()
    let name = synIDattr(synID(line('.'),col('.'),1),'name')
    if name == ''
        return ''
    else
        return '[' . name . ']'
    endif
endfunction

"recalculate the tab warning flag when idle and after writing
autocmd cursorhold,bufwritepost * unlet! b:statusline_tab_warning

"return '[&et]' if &et is set wrong
"return '[mixed-indenting]' if spaces and tabs are used to indent
"return an empty string if everything is fine
function! StatuslineTabWarning()
    if !exists("b:statusline_tab_warning")
        let b:statusline_tab_warning = ''

        if !&modifiable
            return b:statusline_tab_warning
        endif

        let tabs = search('^\t', 'nw') != 0

        "find spaces that arent used as alignment in the first indent column
        let spaces = search('^ \{' . &ts . ',}[^\t]', 'nw') != 0

        if tabs && spaces
            let b:statusline_tab_warning =  '[mixed-indenting]'
        elseif (spaces && !&et) || (tabs && &et)
            let b:statusline_tab_warning = '[&et]'
        endif
    endif
    return b:statusline_tab_warning
endfunction

"recalculate the long line warning when idle and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_long_line_warning

"return a warning for "long lines" where "long" is either &textwidth or 80 (if
"no &textwidth is set)
"
"return '' if no long lines
"return '[#x,my,$z] if long lines are found, were x is the number of long
"lines, y is the median length of the long lines and z is the length of the
"longest line
function! StatuslineLongLineWarning()
    if !exists("b:statusline_long_line_warning")

        if !&modifiable
            let b:statusline_long_line_warning = ''
            return b:statusline_long_line_warning
        endif

        let long_line_lens = s:LongLines()

        if len(long_line_lens) > 0
            let b:statusline_long_line_warning = "[" .
                        \ '#' . len(long_line_lens) . "," .
                        \ 'm' . s:Median(long_line_lens) . "," .
                        \ '$' . max(long_line_lens) . "]"
        else
            let b:statusline_long_line_warning = ""
        endif
    endif
    return b:statusline_long_line_warning
endfunction

"return a list containing the lengths of the long lines in this buffer
function! s:LongLines()
    let threshold = (&tw ? &tw : 80)
    let spaces = repeat(" ", &ts)
    let line_lens = map(getline(1,'$'), 'len(substitute(v:val, "\\t", spaces, "g"))')
    return filter(line_lens, 'v:val > threshold')
endfunction

"find the median of the given array of numbers
function! s:Median(nums)
    let nums = sort(a:nums)
    let l = len(nums)

    if l % 2 == 1
        let i = (l-1) / 2
        return nums[i]
    else
        return (nums[l/2] + nums[(l/2)-1]) / 2
    endif
endfunction

"nerdtree settings
let g:NERDTreeMouseMode = 2
let g:NERDTreeWinSize = 40
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']

" NERD comments
let g:NERDCustomDelimiters = { 'haskell': { 'left': '-- ','right': '' } }

"explorer mappings
nnoremap <f1> :BufExplorer<cr>
nnoremap <f3> :TagbarToggle<cr>
nnoremap <Leader>o :NERDTreeToggle<CR>
nnoremap <Leader>/ /\c

"make <c-l> clear the highlight as well as redraw
nnoremap <C-L> :nohls<CR><C-L>
inoremap <C-L> <C-O>:nohls<CR>
inoremap <C-e> <C-o>$

"map Q to line wrapping
noremap Q gq

"make Y consistent with C and D
nnoremap Y y$

"make '=' reindent the whole file
nnoremap = ggVG=<C-o><C-o><CR>

"make '=' reindent the whole file
nnoremap <C-g> ggVG<CR>

"make 'X' delete the buffer
nnoremap X :bdelete<CR>

"visual search mappings
function! s:VSetSearch()
    let temp = @@
    norm! gvy
    let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
    let @@ = temp
endfunction
vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR>


"jump to last cursor position when opening a file
"dont do it when writing a commit log entry
autocmd BufReadPost * call SetCursorPosition()
function! SetCursorPosition()
    if &filetype !~ 'svn\|commit\c'
        if line("'\"") > 0 && line("'\"") <= line("$")
            exe "normal! g`\""
            normal! zz
        endif
    end
endfunction

" Open GHCi in a new pane
function! RunGhci(type)
    call VimuxRunCommand(" stack ghci && exit")
    if a:type
        call VimuxSendText(":l " . bufname("%"))
        call VimuxSendKeys("Enter")
    endif
endfunction

"spell check when writing commit logs
autocmd filetype svn,*commit* setlocal spell
autocmd filetype go set tabstop=4
autocmd filetype make set tabstop=4

set guioptions-=m "remove menu
set guioptions-=T "remove toolbar
set guioptions-=r "remove scroll bar right
set guioptions-=L "remove scroll bar left
let g:yankring_history_dir = "~/.vim"

autocmd Filetype html setlocal ts=2 sts=2 sw=2
autocmd Filetype ruby setlocal ts=2 sts=2 sw=2
autocmd Filetype haskell setlocal ts=2 sts=2 sw=2
autocmd Filetype javascript setlocal ts=4 sts=4 sw=4

autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1
autocmd FileType ruby,eruby let g:rubycomplete_rails = 1


autocmd FileType go set nolist

"for codex
set tags=tags;/,codex.tags;/
noremap T :Tab/


" change buffers
noremap <S-j> :bn<CR>
noremap <S-k> :bp<CR>

" move around panes with h,j,k,l
nnoremap <C-k> :wincmd k <CR>
nnoremap <C-l> :wincmd l <CR>
nnoremap <C-h> :wincmd h <CR>
nnoremap <C-j> :wincmd j <CR>

map <Bslash> <Leader><Leader>
map <Leader>t :GhcModType<CR>
map <Leader>i :GhcModInfo<CR>
map <Leader>C :GhcModCheck!<CR>

" *G*enerate function body
map <Leader>g :GhcModSigCodegen<CR>

" *L*ist constructors
map <Leader>l :GhcModSplitFunCase<CR>


au FileType haskell nmap <silent><buffer> <leader>gg :call RunGhci(1)<CR>
au FileType haskell nmap <silent><buffer> <leader>gs :call RunGhci(0)<CR>

map <Leader>f :CtrlP<CR>
map <Leader>p :CtrlPTag<CR>

" Open *h*istory
map <Leader>O :GundoToggle<CR>

let g:ctrlp_working_path_mode = 'ra'


" make YCM compatible with UltiSnips (using supertab)
let g:ycm_key_list_select_completion = ['<C-j>']
let g:ycm_key_list_previous_completion = ['<C-k>']

" set python2 interpreter path
let g:ycm_server_python_interpreter = '/usr/bin/python'

"" better key bindings for UltiSnipsExpandTrigger
let g:UltiSnipsExpandTrigger = "<C-l>"
let g:UltiSnipsJumpForwardTrigger = "<C-l>"
let g:UltiSnipsJumpBackwardTrigger = "<C-h>"
let g:UltiSnipsSnippetDirectories=["ultisnips"]
let g:UltiSnipsSnippetsDir = "~/.vim/ultisnips"

let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1



" Set browser for haddock
let g:haddock_browser = "xdg-open"
let g:haddock_browser_callformat = "%s %s"


let g:indent_guides_guide_size=1

" Set 80th column marker
set cc=80

" Binding for removing trailing whitespaces
map <Leader>w :FixWhitespace<CR>

" Reload all buffers from disk content
map <Leader>e :bufdo e!<CR>

" Run GhcModCheck when writing a buffer
"autocmd BufWritePost *.hs GhcModCheck

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

nnoremap <silent> <Leader>= :exe "resize " . (winheight(0) * 3/2)<CR>
nnoremap <silent> <Leader>- :exe "resize " . (winheight(0) * 2/3)<CR>

autocmd Filetype haskell setlocal omnifunc=necoghc#omnifunc
autocmd Filetype haskell setlocal cscopeprg=hscope

" Modify function arguments
autocmd FileType haskell
    \ onoremap <silent> ia
    \ :<c-u>silent execute "normal! ?->\r:nohlsearch\rwvf-ge"<CR>
autocmd FileType haskell
    \ onoremap <silent> aa
    \ :<c-u>silent execute "normal! ?->\r:nohlsearch\rhvEf-ge"<CR>

" Run hasktags on buffer write
:autocmd BufWritePost *.hs
    \ silent!
    \ !(hasktags --ignore-close-implementation --ctags .; sort tags)
    \ &> /dev/null

" Jump between haskell functions
function! JumpHaskellFunction(reverse)
    call search('\C[[:alnum:]]*\s*::', a:reverse ? 'bW' : 'W')
endfunction
au FileType haskell nnoremap
    \   <buffer><silent> ]] :call JumpHaskellFunction(0)<CR>
au FileType haskell nnoremap
    \   <buffer><silent> [[ :call JumpHaskellFunction(1)<CR>


" Jump to *I*mports and *C*abal file
au FileType haskell nnoremap <buffer> gI gg /\cimport<CR><ESC>:noh<CR>
au FileType haskell nnoremap <buffer> gC :e *.cabal<CR>

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0

vnoremap <C-s> :sort<CR>
" setlocal spell spelllang=en_us TODO: this confuses code and comments
