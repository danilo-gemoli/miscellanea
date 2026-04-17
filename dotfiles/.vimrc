" References:
" https://www.freecodecamp.org/news/vimrc-configuration-guide-customize-your-vim-editor/
" https://www.shortcutfoo.com/blog/top-50-vim-configuration-options/

""""""""
" Misc "
""""""""
let mapleader = "-"

" Disable vi compatibility.
set nocompatible

" Enable file type detection.
filetype on
filetype plugin on
filetype indent on

syntax on

" Set command history up to n (default to 20)
set history=1000

set nobackup
set noswapfile

nnoremap <silent> <Leader>o o<Esc>k
nnoremap <silent> <Leader>O O<Esc>j

" Apply the macro from the q register to the selected lines.
vnoremap <S-q> :normal! @q<CR>

"""""""""""
" Editing "
"""""""""""
" Surrond the highlighted text with a pair of something
vnoremap " <Esc>`>a"<Esc>`<i"<Esc>
vnoremap ' <Esc>`>a"<Esc>`<i'<Esc>
vnoremap ( <Esc>`>a)<Esc>`<i(<Esc>
vnoremap [ <Esc>`>a]<Esc>`<i[<Esc>
vnoremap { <Esc>`>a}<Esc>`<i{<Esc>

""""""""""
" Cursor "
""""""""""
" The following make sure the cursor stays always in the middle
" of the screen
nnoremap <C-U> 11kzz
nnoremap <C-D> 11jzz
nnoremap j jzz
nnoremap k kzz
nnoremap G Gzz
nnoremap # #zz
nnoremap * *zz
nnoremap n nzz
nnoremap N Nzz

"""""""""""""""
" Indentation "
"""""""""""""""
set autoindent
set shiftround
set shiftwidth=4
set tabstop=4
set expandtab
set smarttab
" Do not wrap long lines.
set nowrap
" Show the mode you are on the last line.
set showmode

"""""""""""""
" Searching "
"""""""""""""
" Use highlighting when doing search.
set hlsearch
set ignorecase
set incsearch
set smartcase
noremap <Leader>H :noh<CR>

""""""""
" Text "
""""""""
set encoding=utf-8

""""""""""""""""""
" User Interface "
""""""""""""""""""
set title
set laststatus=2
set ruler
set cursorline
set number
"set cursorcolumn
set wildmenu

"""""""""""""
" Clipboard "
"""""""""""""
set clipboard^=unnamed,unnamedplus

"""""""""""
" Buffers "
""""""""""
set hidden
noremap <C-k> :bn<CR>
noremap <C-j> :bp<CR>

"""""""""""""""""""
" Omni completion "
"""""""""""""""""""
"" Close preview when selection done
autocmd CompleteDone * pclose
set completeopt=menu,preview,popup,fuzzy,noinsert,noselect
set omnifunc=ft-c-omni

""""""""
" Tags "
""""""""
nnoremap <leader>wt :execute "Tags " . expand('<cword>')<CR>

"""""""""""
" Windows "
"""""""""""
noremap <C-S-Right> <C-w>3>
noremap <C-S-Left> <C-w>3<
noremap <C-S-Down> <C-w>3+
noremap <C-S-Up> <C-w>3-

"""""""""
" Theme "
"""""""""
" Download theme at https://github.com/NLKNguyen/papercolor-theme
set background=dark
colorscheme PaperColor
" let g:solarized_termcolors=256
" colorscheme solarized
"colorscheme desert

"""""""""""""
" Scripting "
"""""""""""""
" Buffers
function! CloseBuffersButCurrent(force)
    let l:all_buf_info = getbufinfo({'buflisted': 1, 'bufloaded': 1})
    let l:curbuf = bufnr('%')
    for buf_info in all_buf_info
        if buf_info.bufnr == curbuf
            continue
        endif

        if buf_info.changed == 1
            if a:force == 1
                exec 'bd! ' . buf_info.bufnr
            endif
        else
            exec 'bd ' . buf_info.bufnr
        endif
    endfor
endfunction

nnoremap <silent> <Leader>bd :call CloseBuffersButCurrent(0)<CR>
nnoremap <silent> <Leader>bD :call CloseBuffersButCurrent(1)<CR>

" Custom clipboard
function! WriteToFileClipboard()
    let l:data = getreg('"', 1, 1)
    let l:result = writefile(l:data, "/tmp/clipboard", "bs")
    if l:result == 1
        throw "fail to sync clipboard"
    endif
endfunction

function! ReadFromFileClipboard()
    let l:cp = "/tmp/clipboard"
    if filereadable(l:cp)
        let l:data = readfile(l:cp, "b")
        if setreg('"', l:data, "l") != 0
            throw 'Failed to sync register "'
        endif
    else
        throw l:cp . " is not readable"
    endif
endfunction

nnoremap <silent> <Leader>cs :call WriteToFileClipboard()<CR>
nnoremap <silent> <Leader>cS :call ReadFromFileClipboard()<CR>

"""""""""""
" Plugins "
"""""""""""
" Bufferlist

" NERDTree
noremap <silent> <Leader>nx :NERDTreeToggle<CR>
"" Reveal the current file on the editor
noremap <silent> <Leader>nf :NERDTreeFind<CR>
"" Open NERDTree on vim startup
" autocmd VimEnter *  NERDTree
" let g:NERDTreeShowHidden=1

" fzf vim plugin
let g:fzf_layout = { 'window': 'enew' }
let g:fzf_preview_window = ['down', 'ctrl-/']
noremap <silent> <Leader>sf :FZF<CR>
"" Buffer Search
noremap <silent> <Leader>bs :CustomFzfBuffers<CR>
"" Reveal Files
noremap <silent> <Leader>rf :call g:FZF_list_files_dirs()<CR>
noremap <silent> <Leader>bl :BLines<CR>

" any-fold
" https://github.com/pseewald/vim-anyfold

"" activate for all filetypes
autocmd Filetype * AnyFoldActivate 
"" open all folds
set foldlevel=99

" tagbar
" https://github.com/preservim/tagbar
noremap <Leader>tt :TagbarToggle()<CR>

" vim-gitgutter
" https://github.com/airblade/vim-gitgutter
helptags $HOME/.vim/pack/vendor/start/vim-gitgutter/doc

" gutentags
" https://github.com/ludovicchabant/vim-gutentag
helptags $HOME/.vim/pack/vendor/start/vim-gutentags/doc
let g:gutentags_define_advanced_commands = 1 
"" Enable it manually only when needed
let g:gutentags_enabled = 0
"" Enable cscope too
let g:gutentags_modules = ['ctags', 'cscope']
"" Consider as a project whatever dir contains a .gutentags-root file
let g:gutentags_project_root = ['.gutentags-root']

""""""""""
" Kernel "
""""""""""
function! LoadKernelEnvironment()
    let ktags = "/home/dgemoli/dev/src/git.kernel.org/linux-stable/tags"
    let current_tags = execute("set tags?")
    if stridx(current_tags, ktags) == -1
        execute "set tags+=".ktags
    endif

    let kcscope_out = "/home/dgemoli/dev/src/git.kernel.org/linux-stable/cscope.out"
    let cs_connections = execute(":cscope show")
    if stridx(cs_connections, kcscope_out) == -1
        execute "cscope add ".kcscope_out
    endif
endfunction

command! LoadKernelEnv call LoadKernelEnvironment()

