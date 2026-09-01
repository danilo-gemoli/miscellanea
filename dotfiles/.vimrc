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

" Escape quickly from insert mode
inoremap <C-j> <ESC>

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
set smartindent
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
set infercase
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
" set omnifunc=ft-c-omni

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

" Workaround for base16 themes found here: https://github.com/chriskempson/base16-vim?tab=readme-ov-file
let base16colorspace=256
set termguicolors

" let g:codedark_conservative=1
let g:codedark_modern=1
" let g:codedark_italics=1
let g:codedark_transparent=1
colorscheme codedark

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
" Auto-Pairs
" When inside a pair, jump off and keep typing without exting insert mode
let g:AutoPairsShortcutJump = '<C-L>'

" NERDTree
noremap <silent> <Leader>nx :NERDTreeToggle<CR>
"" Reveal the current file on the editor
noremap <silent> <Leader>nf :NERDTreeFind<CR>
"" Open NERDTree on vim startup
" autocmd VimEnter *  NERDTree
let g:NERDTreeShowHidden=1

" fzf vim plugin
let g:fzf_layout = { 'window': 'enew' }
let g:fzf_preview_window = ['down', 'ctrl-/']
noremap <silent> <Leader>sf :FZF -e<CR>
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
function! s:setupKernelDevEnv()
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

function s:kernelActionMenu(descriptions, actions)
    let l:k_descriptions = ['Kernel: Dev Env']
    let l:k_actions = [':call s:setupKernelDevEnv()']
    call extend(a:descriptions, k_descriptions)
    call extend(a:actions, k_actions)
endfunction

""""""""""
" Golang "
""""""""""
function! s:setupGolangDevEnv()
    if expand("%:e") !~ 'go\|mod\|work'
        throw "Golang development env needs a go|gomod|gowork buffer to load properly"
    endif
    """"""""""
    " vim-go "
    """"""""""
    " Disable vim-go LSP integration
    let g:go_gopls_enabled = 0
    let g:go_def_mode = 'none'
    let g:go_info_mode = 'none'

    " Disable completion 
    let g:go_code_completion_enabled = 0

    " Disable diagnostics/signs if using LSP
    let g:go_diagnostics_enabled = 0
    let g:go_metalinter_enabled = []

    let g:go_fmt_autosave = 0
    let g:go_imports_autosave = 0
    let g:go_guru_enabled = 0
    let g:go_doc_keywordprg_enabled = 0

    " Debugger
    let g:go_debug_windows = {
        \ 'vars':  'leftabove 30vnew',
        \ 'out':   'botright 5new',
        \ }
    " let g:go_debug_log_output = 'debugger,rpc'
    let g:go_debug_log_output = ''
    let g:go_debug_preserve_layout = 1

    packadd vim-go

    " Debugger

    " vim-go plugin loads properly only when a go filetype is detected.
    " Since we are doing lazy loading here, we have to simulate that
    " behavior as well.
    doautocmd FileType go

    augroup go_lsp_omnifunc
        autocmd!
        autocmd FileType go setlocal omnifunc=LspOmniFunc
    augroup END

    """"""""""""""""
    " yegappan/lsp "
    """"""""""""""""
    packadd lsp

    call LspAddServer([{
        \ 'name': 'gopls',
        \ 'filetype': ['go', 'gomod', 'gowork'],
        \ 'path': 'gopls',
        \ 'args': ['-rpc.trace', '-logfile=/tmp/gopls.log', 'serve'],
        \ 'syncInit': v:true,
        \ 'workspaceConfig': {
        \   'gopls': {
        \      'usePlaceholders': v:true,
        \   },
        \ },
        \ }])

    call LspOptionsSet({
        \ 'autoComplete': v:true,
        \ 'showDiagInPopup': v:true,
        \ 'showDiagOnStatusLine': v:true,
        \ 'showInlayHints': v:true,
        \ 'autoHighlightDiags': v:true,
        \ 'completionMatcher': 'fuzzy',
        \ 'usePopupInCodeAction': v:true,
        \ 'useBufferCompletion': v:true,
        \ 'outlineOnRight': v:true,
        \ 'outlineWinSize': 60,
        \ 'snippetSupport': v:true,
        \ 'completionTextEdit': v:false,
        \ 'vsnipSupport': v:true,
        \ 'ultisnipsSupport': v:false,
        \ })

    inoremap <C-space> <C-\><C-o>:call lsp#completion#LspComplete(v:true)<cr>

    augroup go_lsp_format
        autocmd!
        autocmd BufWritePre *.go if &modifiable && exists(':LspFormat') | LspFormat | endif
    augroup END

    augroup LspHighlight
        autocmd!
        autocmd User LspAttached call s:go_lsp_highlight_setup()
    augroup END
    set updatetime=700

    noremap <F12> :LspGotoDefinition<CR>
    noremap <S-F11> :GoDebugStepOut<CR>
endfunction

function! s:go_lsp_highlight_setup() abort
    autocmd CursorHold <buffer> silent! LspHighlight
    autocmd CursorMoved <buffer> silent! LspHighlightClear
endfunction

function s:golangActionMenu(descriptions, actions)
    let l:go_descriptions = [
                \ 'Go: Dev Env',
                \ 'Go: Run Test',
                \ 'Go: Debug Test',
                \ 'Go: Debug Stop',
                \ 'Go: Remove Debug Signs',
                \ 'Go: Lsp Diag Buffer',
                \ 'Go: Lsp GoTo Definition',
                \ 'Go: Lsp GoTo Implementation',
                \ 'Go: Lsp Symbol Search',
                \ 'Go: Lsp Show References',
                \ 'Go: Lsp Rename',
                \ 'Go: Lsp Outline',
                \ 'Go: Lsp Code Action',
    \ ]
    let l:go_actions = [
                \ ':call s:setupGolangDevEnv()',
                \ ':GoTestFunc',
                \ ':GoDebugTest',
                \ ':GoDebugStop',
                \ ':sign unplace * group=vim-go-debug',
                \ ':LspDiagShow',
                \ ':LspGotoDefinition',
                \ ':LspGotoImpl',
                \ ':LspSymbolSearch',
                \ ':LspShowReferences',
                \ ':LspRename',
                \ ':LspOutline toggle',
                \ ':LspCodeAction',
    \ ]
    call extend(a:descriptions, go_descriptions)
    call extend(a:actions, go_actions)
endfunction

"""""""""""""""
" Action Menu "
"""""""""""""""
function s:actionMenuSink(lines, actions)
    if len(a:lines) < 2
        return
    endif

    let l:index = str2nr(a:lines[1])
    let l:action = a:actions[l:index]
    execute l:action
    call histadd(":", trim(l:action, ":"))
endfunction

function! g:ActionMenu()
    let l:descriptions = []
    let l:actions = []
    call s:golangActionMenu(l:descriptions, l:actions)
    call s:kernelActionMenu(l:descriptions, l:actions)

    if len(descriptions) != len(actions)
        throw "Actions and descriptions length are not matching"
    endif

    let spec = { 'sink*': { lines -> s:actionMenuSink(lines, actions) },
                \ 'source': descriptions,
                \ 'tmux': '',
                \ 'options': [
                \   '--tmux=40%',
                \   '--exact',
                \   '--no-sort',
                \   '--tac',
                \   '--cycle',
                \   '--accept-nth={n}',
                \   '--print-query',
                \   '--header', 'Perform an action',
                \   '--prompt', 'Action> '
                \ ],
                \ 'placeholder': '{1}'
                \ }
    call fzf#run(spec)
endfunction

command! ActionMenu call ActionMenu()
noremap <Leader>M :ActionMenu<CR>
