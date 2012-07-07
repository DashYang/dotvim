" Author:   Liang Feng <liang.feng98 AT gmail DOT com>
" Brief:    This vimrc supports Mac, Linux and Windows(both GUI & console version).
"           While it is well commented, just in case some commands confuse you,
"           please RTFM by ':help WORD' or ':helpgrep WORD'.
" HomePage: https://github.com/liangfeng/vimrc
" Comments: has('mac') means Mac version only.
"           has('unix') means Mac or Linux version.
"           has('win32') means Windows 32 verion only.
"           has('win64') means Windows 64 verion only.
"           has('gui_win32') means Windows 32 bit GUI version.
"           has('gui_win64') means Windows 64 bit GUI version.
"           has('gui_running') means in GUI mode.

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Init {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if v:version < 700
    echoerr 'This _vimrc requires Vim 7 or later.'
    quit
endif

" Use Vim settings, rather then Vi settings.
" This option must be first, because it changes other options.
set nocompatible

let g:maplocalleader = ","
let g:mapleader = ","

" If vim starts without opening file(s),
" change working directory to $VIM (Windows) or $HOME(Mac, Linux).
if expand('%') == ''
    if has('unix')
        cd $HOME
    elseif has('win32') || has('win64')
        cd $VIM
    endif
endif

" Setup vundle plugin.
" Must be called before filetype on.
if has('unix')
    set runtimepath=$VIMRUNTIME,$HOME/.vim/bundle/vundle
    call vundle#rc()
else
    set runtimepath=$VIMRUNTIME,$VIM/bundle/vundle
    call vundle#rc('$VIM/bundle')
endif

" Do not load system menu, before ':syntax on' and ':filetype on'.
if has('gui_running')
    set guioptions+=M
endif

" Patch to hide DOS prompt window, when call vim function system().
" See Wu Yongwei's site for detail
" http://wyw.dcweb.cn/
if has('win32') || has('win64')
    let $VIM_SYSTEM_HIDECONSOLE = 1
endif

filetype plugin indent on

" End of Init }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Startup/Exit {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set shortmess+=I

if has('gui_win32') || has('gui_win64')
    command! Res simalt ~r
    command! Max simalt ~x
    " Run gvim with max mode by default.
    au GUIEnter * Max

    function! s:ToogleWindowSize()
        if exists('g:does_windows_need_max')
            let g:does_windows_need_max = !g:does_windows_need_max
        else
            " Need to restore window, since gvim run into max mode by default.
            let g:does_windows_need_max = 0
        endif
        if g:does_windows_need_max == 1
            Max
        else
            Res
        endif
    endfunction

    nnoremap <silent> <Leader>W :call <SID>ToogleWindowSize()<CR>
endif

" XXX: Change it. It's just for my environment.
language messages zh_CN.utf-8

" Locate the cursor at the last edited location when open a file
au BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exec "normal! g`\"" |
    \ endif

if has('unix')
    " XXX: Change it. It's just for my environment.
    set viminfo+=n$HOME/tmp/.viminfo
endif

" End of Startup }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Encoding {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:legacy_encoding = &encoding
let &termencoding = &encoding

set encoding=utf-8
set ambiwidth=double
scriptencoding utf-8
set fileencodings=ucs-bom,utf-8,default,gb18030,big5,latin1
if g:legacy_encoding != 'latin1'
    let &fileencodings=substitute(
                \&fileencodings, '\<default\>', g:legacy_encoding, '')
else
    let &fileencodings=substitute(
                \&fileencodings, ',default,', ',', '')
endif

" This function is revised from Wu yongwei's _vimrc.
" Function to display the current character code in its 'file encoding'
function! s:EchoCharCode()
    let _char_enc = matchstr(getline('.'), '.', col('.') - 1)
    let _char_fenc = iconv(_char_enc, &encoding, &fileencoding)
    let i = 0
    let _len = len(_char_fenc)
    let _hex_code = ''
    while i < _len
        let _hex_code .= printf('%.2x',char2nr(_char_fenc[i]))
        let i += 1
    endwhile
    echo '<' . _char_enc . '> Hex ' . _hex_code . ' (' .
          \(&fileencoding != '' ? &fileencoding : &encoding) . ')'
endfunction

" Key mapping to display the current character in its 'file encoding'
nnoremap <silent> gn :call <SID>EchoCharCode()<CR>

" End of Encoding }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" UI {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has('gui_running')
    if has('mac')
        set guifont=Monaco:h14
    elseif has('win32') || has('win64')
        set guifont=Consolas:h14:cANSI
        set guifontwide=YaHei\ Consolas\ Hybrid:h14
    else
        set guifont=Monospace:h14
    endif
endif

" Activate 256 colors independently of terminal, except Mac console mode
if !(has('mac') && !has('gui_running'))
    set t_Co=256
endif

if has('mac') && has('gui_running')
    set fuoptions+=maxhorz
    nnoremap <silent> <D-f> :set invfullscreen<CR>
    inoremap <silent> <D-f> <C-o>:set invfullscreen<CR>
endif

" Switch on syntax highlighting.
" Delete colors_name for _vimrc re-sourcing.
if exists("g:colors_name")
    unlet g:colors_name
endif

syntax on

" End of UI }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Editting {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has('unix')
    if isdirectory("$HOME/tmp")
        set directory=$HOME/tmp
    else
        set directory=/tmp
    endif
elseif has('win32') || has('win64')
    set directory=$TMP
endif

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set autochdir

set nobackup

" keep 400 lines of command line history
set history=400

set completeopt-=preview

" Disable middlemouse paste
noremap <silent> <MiddleMouse> <LeftMouse>
noremap <silent> <2-MiddleMouse> <Nop>
inoremap <silent> <2-MiddleMouse> <Nop>
map <silent> <3-MiddleMouse> <Nop>
inoremap <silent> <3-MiddleMouse> <Nop>
noremap <silent> <4-MiddleMouse> <Nop>
inoremap <silent> <4-MiddleMouse> <Nop>

" Disable bell on errors
set noerrorbells
set novisualbell
au VimEnter * set vb t_vb=

" remap Y to work properly
nnoremap <silent> Y y$

" Key mapping for confirmed exiting
nnoremap <silent> ZZ :confirm qa<CR>

" Create a new tabpage
nnoremap <silent> <Leader><Tab> :tabnew<CR>

" Quote shell if it contains space and is not quoted
if &shell =~? '^[^"].* .*[^"]'
    let &shell = '"' . &shell . '"'
endif

" Clear up xquote
set shellxquote=

" Redirect command output to standard output and temp file
if has('unix')
    set shellpipe=2>&1\|\ tee
endif

if has('filterpipe')
    set noshelltemp
endif

if has('win32') || has('win64')
    set shellslash
endif

" Execute command without disturbing registers and cursor postion.
function! s:Preserve(command)
    " Preparation: save last search, and cursor position.
    let _s=@/
    let _l = line(".")
    let _c = col(".")
    " Do the business.
    execute a:command
    " Clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(_l, _c)
endfunction

function! s:RemoveTrailingSpaces()
    call s:Preserve('%s/\s\+$//e')
endfunction

" Remove trailing spaces for all files
au BufWritePre * call s:RemoveTrailingSpaces()

" End of Editting }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Searching/Matching {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" incremental searching
set incsearch

" highlight the last used search pattern.
set hlsearch

" Use external grep command for performance
" On Windows, install 'grep' from:
" http://gnuwin32.sourceforge.net/packages/grep.htm
set grepprg=grep\ -Hn

set gdefault

" Find buffer more friendly
set switchbuf=usetab

" :help CTRL-W_gf
" :help CTRL-W_gF
nnoremap <silent> gf <C-w>gf
nnoremap <silent> gF <C-w>gF

" Quick moving between tabs
nnoremap <silent> <C-Tab> gt

" Quick moving between windows
nnoremap <silent> <Leader>w <C-w>w

" To make remapping Esc work porperly in console mode by disabling esckeys.
if !has('gui_running')
    set noesckeys
endif
" remap <Esc> to stop searching highlight
nnoremap <silent> <Esc> :nohls<CR><Esc>
imap <silent> <Esc> <C-o><Esc>

nnoremap <silent> <Up> <Nop>
nnoremap <silent> <Down> <Nop>
nnoremap <silent> <Left> <Nop>
nnoremap <silent> <Right> <Nop>
inoremap <silent> <Up> <Nop>
inoremap <silent> <Down> <Nop>
inoremap <silent> <Left> <Nop>
inoremap <silent> <Right> <Nop>

" move around the visual lines
nnoremap <silent> j gj
nnoremap <silent> k gk

" Make cursor move smooth
set whichwrap+=<,>,h,l

set ignorecase
set smartcase

set wildmenu

set wildignore+=*.o
set wildignore+=*.obj
set wildignore+=*.bak
set wildignore+=*.exe
set wildignore+=*.swp
set wildignore+=*.pyc

nmap <silent> <Tab> %

nnoremap / /\v
vnoremap / /\v

" Support */# in visual mode
function! s:VSetSearch()
    let temp = @@
    normal! gvy
    let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
    let @@ = temp
endfunction

vnoremap <silent> * :<C-u>call <SID>VSetSearch()<CR>//<CR>
vnoremap <silent> # :<C-u>call <SID>VSetSearch()<CR>??<CR>

" End of Searching/Matching }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Formats/Style {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set tabstop=4
set shiftwidth=4
set expandtab
set smarttab
set autoindent
set smartindent
set display=lastline
set clipboard=unnamed

vnoremap <silent> <Tab> >gv
vnoremap <silent> <S-Tab> <gv

set scrolloff=7

if has('gui_running')
    set guioptions-=m
    set guioptions-=T
    set guioptions+=c
endif
set titlelen=0

" Make vim CJK-friendly
set formatoptions+=mM

" Show line number
set number

set cursorline

set laststatus=2

set fileformats=unix,dos

" Function to insert the current date
function! s:InsertCurrentDate()
    let _curr_date = strftime('%Y-%m-%d', localtime())
    silent! exec 'normal! gi' .  _curr_date . "\<Esc>a"
endfunction

" Key mapping to insert the current date
inoremap <silent> <C-d><C-d> <C-o>:call <SID>InsertCurrentDate()<CR>

" Eliminate comment leader when joining comment lines
function! s:JoinWithLeader(count, leaderText)
    let l:linecount = a:count
    " default number of lines to join is 2
    if l:linecount < 2
        let l:linecount = 2
    endif
    echo l:linecount . " lines joined"
    " clear errmsg so we can determine if the search fails
    let v:errmsg = ''

    " save off the search register to restore it later because we will clobber
    " it with a substitute command
    let l:savsearch = @/

    while l:linecount > 1
        " do a J for each line (no mappings)
        normal! J
        " remove the comment leader from the current cursor position
        silent! execute 'substitute/\%#\s*\%('.a:leaderText.'\)\s*/ /'
        " check v:errmsg for status of the substitute command
        if v:errmsg=~'E486'
            " just means the line wasn't a comment - do nothing
        elseif v:errmsg!=''
            echo "Problem with leader pattern for s:JoinWithLeader()!"
        else
            " a successful substitute will move the cursor to line beginning,
            " so move it back
            normal! ``
        endif
        let l:linecount = l:linecount - 1
    endwhile
    " restore the @/ register
    let @/ = l:savsearch
endfunction

function! s:MapJoinWithLeaders(leaderText)
    let l:leaderText = escape(a:leaderText, '/')
    " visual mode is easy - just remove comment leaders from beginning of lines
    " before using J normally
    exec "vnoremap <silent> <buffer> J :<C-u>let savsearch=@/<Bar>'<+1,'>".
                \'s/^\s*\%('.
                \l:leaderText.
                \'\)\s*/<Space>/e<Bar>'.
                \'let @/=savsearch<Bar>unlet savsearch<CR>'.
                \'gvJ'
    " normal mode is harder because of the optional count - must use a function
    exec "nnoremap <silent> <buffer> J :<C-u>call <SID>JoinWithLeader(v:count, '".l:leaderText."')<CR>"
endfunction

" End of Formats/Style }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tab/Buffer {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has('gui_running')
    " Only show short name in gui tab
    set guitablabel=%N\ %t%m%r
endif

" End of Tab/Buffer }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Bash {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" :help ft-bash-syntax
let g:is_bash = 1

" End of Bash }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" C/C++ {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:GNUIndent()
    setlocal cinoptions=>4,n-2,{2,^-2,:2,=2,g0,h2,p5,t0,+2,(0,u0,w1,m1
    setlocal shiftwidth=2
    setlocal tabstop=8
endfunction

function! s:SetSysTags()
    " include system tags, :help ft-c-omni
    if has('unix')
        set tags+=$HOME/.vim/systags
    elseif has('win32') || has('win64')
        set tags+=$TMP/systags
    endif
endfunction

function! s:HighlightSpaceErrors()
    " Highlight space errors in C/C++ source files.
    " :help ft-c-syntax
    let g:c_space_errors = 1
endfunction

function! s:TuneCHighlight()
    " Tune for C highlighting
    " :help ft-c-syntax
    let g:c_gnu = 1
    " XXX: It's maybe a performance penalty.
    let g:c_curly_error = 1
endfunction

" Setup my favorite C/C++ indent
function! s:SetCPPIndent()
    setlocal cinoptions=(0,t0,w1 shiftwidth=4 tabstop=4
endfunction

" Setup basic C/C++ development envionment
function! s:SetupCppEnv()
    call s:SetSysTags()
    call s:HighlightSpaceErrors()
    call s:TuneCHighlight()
    call s:SetCPPIndent()
endfunction

" Setting for files following the GNU coding standard
if has('unix')
    au BufEnter /usr/include/* call s:GNUIndent()
elseif has('win32') || has('win64')
    " XXX: change it. It's just for my environment.
    au BufEnter e:/project/g++/* call s:GNUIndent()
    set makeprg=nmake
endif

au FileType c,cpp setlocal commentstring=\ //%s
au FileType c,cpp call s:SetupCppEnv()
au FileType c,cpp call s:MapJoinWithLeaders('//\\|\\')

" End of C/C++ }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Help {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
au FileType help nnoremap <buffer> <silent> q :q<CR>
au FileType help setlocal number


" End of help }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" HTML {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Let TOhtml output <PRE> and style sheet
let g:html_use_css = 1
let g:use_xhtml = 1
au FileType html,xhtml setlocal indentexpr=

" End of HTML }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Lua {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Run the current buffer as lua code
function! s:RunAsLuaCode(s, e)
    pclose!
    silent exec a:s . ',' . a:e . 'y a'
    belowright new
    silent put a
    silent %!lua -
    setlocal previewwindow
    setlocal noswapfile buftype=nofile bufhidden=wipe
    setlocal nobuflisted nowrap cursorline nonumber fdc=0
    setlocal ro nomodifiable
    wincmd p
endfunction

function! s:SetupAutoCmdForRunAsLuaCode()
    nnoremap <buffer> <silent> <Leader>e :call <SID>RunAsLuaCode('1', '$')<CR>
    command! -range Eval :call s:RunAsLuaCode(<line1>, <line2>)
    vnoremap <buffer> <silent> <Leader>e :Eval<CR>
endfunction

au FileType lua call s:SetupAutoCmdForRunAsLuaCode()
au FileType lua call s:MapJoinWithLeaders('--\\|\\')

" End of Lua }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Make {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
au FileType make setlocal noexpandtab
au FileType make call s:MapJoinWithLeaders('#\\|\\')

" End of make }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Python {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:python_highlight_all = 1

" Run the current buffer as python code
function! s:RunAsPythonCode(s, e)
    pclose!
    silent exec a:s . ',' . a:e . 'y a'
    belowright new
    silent put a
    silent %!python -
    setlocal previewwindow
    setlocal noswapfile buftype=nofile bufhidden=wipe
    setlocal nobuflisted nowrap cursorline nonumber fdc=0
    setlocal ro nomodifiable
    wincmd p
endfunction

function! s:SetupAutoCmdForRunAsPythonCode()
    nnoremap <buffer> <silent> <Leader>e :call <SID>RunAsPythonCode('1', '$')<CR>
    command! -range Eval :call s:RunAsPythonCode(<line1>, <line2>)
    vnoremap <buffer> <silent> <Leader>e :Eval<CR>
endfunction

au FileType python setlocal commentstring=\ #%s
au FileType python call s:SetupAutoCmdForRunAsPythonCode()
au FileType python call s:MapJoinWithLeaders('#\\|\\')

" End of Python }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  VimL {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Run the current buffer as VimL
function! s:RunAsVimL(s, e)
    pclose!
    let _lines = getline(a:s, a:e)
    let _file = tempname()
    call writefile(_lines, _file)
    redir @e
    silent exec ':source ' . _file
    call delete(_file)
    redraw
    redir END

    if strlen(getreg('e')) > 0
        belowright new
        redraw
        setlocal previewwindow
        setlocal noswapfile buftype=nofile bufhidden=wipe
        setlocal nobuflisted nowrap cursorline nonumber fdc=0
        syn match ErrorLine +^E\d\+:.*$+
        hi link ErrorLine Error
        silent put e
        setlocal ro nomodifiable
        wincmd p
    endif
endfunction

function! s:SetupAutoCmdForRunAsVimL()
    nnoremap <buffer> <silent> <Leader>e :call <SID>RunAsVimL('1', '$')<CR>
    command! -range Eval :call s:RunAsVimL(<line1>, <line2>)
    vnoremap <buffer> <silent> <Leader>e :Eval<CR>
endfunction

au FileType vim setlocal commentstring=\ \"%s
au FileType vim call s:SetupAutoCmdForRunAsVimL()
au FileType vim call s:MapJoinWithLeaders('"\\|\\')

let g:vimsyn_noerror = 1

" End of VimL }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  vimrc {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" If current buffer is noname and empty, use current buffer.
" Otherwise use new tab
function! s:OpenFileWithProperBuffer(file)
    if bufname('%') == '' && &modified == 0 && &modifiable == 1
        exec 'edit ' . a:file
    else
        exec 'tabedit' . a:file
    endif
endfunction

" Fast editing of vimrc
function! s:OpenVimrc()
    if has('unix')
        call s:OpenFileWithProperBuffer('$HOME/.vimrc')
    elseif has('win32') || has('win64')
        call s:OpenFileWithProperBuffer('$VIM/_vimrc')
    endif
endfunction

nnoremap <silent> <Leader>v :call <SID>OpenVimrc()<CR>

" End of vimrc }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - c-syntax {{{
" https://github.com/liangfeng/c-syntax
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'liangfeng/c-syntax'

" End of c-syntax }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - ctrlp.vim {{{
" https://github.com/kien/ctrlp.vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'kien/ctrlp.vim'

nnoremap <silent> <Leader>f :CtrlP<CR>
nnoremap <silent> <Leader>b :CtrlPBuffer<CR>
nnoremap <silent> <Leader>m :CtrlPMRU<CR>
nnoremap <silent> <Leader>a :CtrlP<CR>

let g:ctrlp_custom_ignore = {
            \ 'dir':  '\.git$\|\.hg$\|\.svn$',
            \ 'file': '\.exe$\|\.so$\|\.dll$\|\.o$\|\.obj$',
            \ }

" Do not delete the cache files upon exiting vim.
let g:ctrlp_clear_cache_on_exit = 0

" Set the max files
let g:ctrlp_max_files = 10000

" Optimize file searching
" TODO: 1. Need support ctrlp_max_files on Windows.
if has('unix')
    let ctrlp_find_cmd_ = 'find %s -type f | head -' . g:ctrlp_max_files
elseif has('win32') || has('win64')
    let ctrlp_find_cmd_ = 'dir %s /-n /b /s /a-d'
endif

let g:ctrlp_user_command = {
            \ 'types': {
            \ 1: ['.git/', 'cd %s && git ls-files'],
            \ 2: ['.hg', 'hg --cwd %s locate -I .'],
            \ },
            \ 'fallback': ctrlp_find_cmd_
            \ }

let g:ctrlp_open_new_file = 't'

" End of ctrlp.vim }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - delimitMate {{{
" https://github.com/Raimondi/delimitMate
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'Raimondi/delimitMate'

au FileType vim,html let b:delimitMate_matchpairs = "(:),[:],{:},<:>"
au FileType html let b:delimitMate_quotes = "\" '"
au FileType python let b:delimitMate_nesting_quotes = ['"']
let g:delimitMate_expand_cr = 1
let g:delimitMate_balance_matchpairs = 1
let delimitMate_excluded_ft = "mail,txt"

" End of delimitMate }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - DoxygenToolkit.vim {{{
" https://github.com/vim-scripts/DoxygenToolkit.vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'DoxygenToolkit.vim'

" Load doxygen syntax file for c/cpp/idl files
let g:load_doxygen_syntax = 1
let g:DoxygenToolkit_commentType = "C++"
let g:DoxygenToolkit_dateTag = ""
let g:DoxygenToolkit_authorName = "liangfeng"
let g:DoxygenToolkit_versionString = ""
let g:DoxygenToolkit_versionTag = ""
let g:DoxygenToolkit_briefTag_pre = "@brief:  "
let g:DoxygenToolkit_fileTag = "@file:   "
let g:DoxygenToolkit_authorTag = "@author: "
let g:DoxygenToolkit_blockTag = "@name: "
let g:DoxygenToolkit_paramTag_pre = "@param:  "
let g:DoxygenToolkit_returnTag = "@return:  "
let g:DoxygenToolkit_classTag = "@class: "

" End of DoxygenToolkit.vim }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - eclim {{{
" https://github.com/ervandew/eclim
" http://eclim.org/
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:EclimDisabled = 1
let g:EclimTaglistEnabled = 0
if has('mac')
    let g:EclimHome = '/Applications/eclipse/plugins/org.eclim_1.6.0'
    let g:EclimEclipseHome = '/Applications/eclipse'
elseif has('win32') || has('win64')
    let g:EclimHome = 'D:/eclipse/plugins/org.eclim_1.6.0'
    let g:EclimEclipseHome = 'D:/eclipse'
endif

" End of eclim }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - FencView.vim {{{
" https://github.com/vim-scripts/FencView.vim
" https://github.com/liangfeng/FencView.vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'liangfeng/FencView.vim'

" End of FencView.vim }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - filetype-completion.vim {{{
" https://github.com/c9s/filetype-completion.vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'c9s/filetype-completion.vim'

" End of filetype-completion.vim }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - FSwitch {{{
" https://github.com/vim-scripts/FSwitch
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: Need refining
Bundle 'FSwitch'

command! FA :FSSplitAbove

let g:fsnonewfiles = 1

" End of FSwitch }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - LargeFile {{{
" https://github.com/vim-scripts/LargeFile
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'LargeFile'

" End of LargeFile }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - matchit {{{
" https://github.com/vim-scripts/matchit.zip
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Since 'matchit' script is included in standard distribution,
" only need to 'source' it.
:source $VIMRUNTIME/macros/matchit.vim

" End of matchit }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - neocomplcache {{{
" https://github.com/Shougo/neocomplcache
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'Shougo/neocomplcache'

set showfulltag
let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_enable_ignore_case = 0
let g:neocomplcache_enable_underbar_completion = 1
let g:neocomplcache_auto_completion_start_length = 2
let g:neocomplcache_manual_completion_start_length = 2
let g:neocomplcache_enable_camel_case_completion = 1
let g:neocomplcache_enable_underbar_completion = 1

if !exists('g:neocomplcache_omni_patterns')
    let g:neocomplcache_omni_patterns = {}
endif
let g:neocomplcache_omni_patterns.c = '\%(\.\|->\)\h\w*'
let g:neocomplcache_omni_patterns.cpp = '\h\w*\%(\.\|->\)\h\w*\|\h\w*::'


if !exists('g:neocomplcache_context_filetype_lists')
    let g:neocomplcache_context_filetype_lists = {}
endif
let g:neocomplcache_context_filetype_lists.vim =
            \ [{'filetype' : 'python', 'start' : '^\s*python <<\s*\(\h\w*\)', 'end' : '^\1'}]

" <CR>: close popup and save indent.
inoremap <silent> <expr> <CR> neocomplcache#close_popup() . '<C-r>=delimitMate#ExpandReturn()<CR>'

" Set up proper mappings for  <BS> or <C-x>.
inoremap <silent> <expr> <BS> pumvisible() ? '<BS><C-x>' : '<BS>'
inoremap <silent> <expr> <C-h> pumvisible() ? '<C-h><C-x>' : '<C-h>'

" Do NOT popup when enter <C-y> and <C-e>
inoremap <silent> <expr> <C-y> neocomplcache#close_popup() . '<C-y>'
inoremap <silent> <expr> <C-e> neocomplcache#close_popup() . '<C-e>'

" <Tab>: completion.
inoremap <silent> <expr> <Tab> pumvisible() ? '<C-n>' : '<Tab>'
inoremap <silent> <expr> <S-Tab> pumvisible() ? '<C-p>' : '<Tab>'

" End of neocomplcache }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - nerdcommenter {{{
" https://github.com/scrooloose/nerdcommenter
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'scrooloose/nerdcommenter'

let g:NERDCreateDefaultMappings = 0
let g:NERDMenuMode = 0
let g:NERDSpaceDelims = 1
nmap <silent> <Leader>cc <plug>NERDCommenterAlignLeft
vmap <silent> <Leader>cc <plug>NERDCommenterAlignLeft
nmap <silent> <Leader>cu <plug>NERDCommenterUncomment
vmap <silent> <Leader>cu <plug>NERDCommenterUncomment

let g:NERDCustomDelimiters = {
            \ 'vim': { 'left': '"' }
            \ }

" End of nerdcommenter }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - nerdtree {{{
" https://github.com/scrooloose/nerdtree
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'scrooloose/nerdtree'

" Set the window position
let g:NERDTreeWinPos = "right"
let g:NERDTreeQuitOnOpen = 1
let g:NERDTreeWinSize = 50
let g:NERDTreeDirArrows = 1
let g:NERDTreeMinimalUI = 1
let g:NERDTreeIgnore=['^\.git', '^\.hg', '^\.svn', '\~$']

nnoremap <silent> <Leader>n :NERDTreeToggle<CR>
" command 'NERDTree' will refresh current directory.
nnoremap <silent> <Leader>N :NERDTree<CR>

" End of nerdtree }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - python.vim--Vasiliev {{{
" https://github.com/vim-scripts/python.vim--Vasiliev
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'python.vim--Vasiliev'

" End of python.vim--Vasiliev }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - python_match.vim {{{
" https://github.com/vim-scripts/python_match.vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'python_match.vim'

" End of python_match.vim }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - SimpylFold for python {{{
" https://github.com/tmhedberg/SimpylFold
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle "tmhedberg/SimpylFold"

" End of SimpylFold for python }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - supertab {{{
" https://github.com/ervandew/supertab
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: add function param complete by TAB (like Vim script #1764)
Bundle 'ervandew/supertab'

" Since use tags, disable included header files searching to improve
" performance.
set complete-=i
" Only scan current buffer
set complete=.

let g:SuperTabDefaultCompletionType = 'context'
let g:SuperTabCrMapping = 0

" End of supertab }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - SyntaxAttr.vim {{{
" https://github.com/vim-scripts/SyntaxAttr.vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'SyntaxAttr.vim'

nnoremap <silent> <Leader>S :call SyntaxAttr()<CR>

" End of SyntaxAttr.vim }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - tagbar {{{
" https://github.com/majutsushi/tagbar
" http://ctags.sourceforge.net/
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'majutsushi/tagbar'

nnoremap <silent> <Leader>t :TagbarToggle<CR>
let g:tagbar_left = 1
let g:tagbar_width = 30
let g:tagbar_compact = 1

" End of tagbar }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - TagHighlight {{{
" https://github.com/vim-scripts/TagHighlight
" http://ctags.sourceforge.net/
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Doesn't work now, disable it.
" TODO: Need troubleshooting.
" Bundle 'TagHighlight'

" End of TagHighlight }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - TaskList.vim {{{
" https://github.com/vim-scripts/TaskList.vim
" http://juan.axisym3.net/vim-plugins/
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'TaskList.vim'

nmap <silent> <Leader>T <Plug>TaskList

" End of TaskList.vim }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-colors-solarized {{{
" https://github.com/altercation/vim-colors-solarized
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'altercation/vim-colors-solarized'

if !has('gui_running')
    let g:solarized_termcolors=256
endif
let g:solarized_italic = 0
let g:solarized_hitrail = 1
set background=dark
colorscheme solarized

" End of vim-colors-solarized }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-powerline {{{
" https://github.com/Lokaltog/vim-powerline
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'Lokaltog/vim-powerline'

" End of vim-powerline }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-repeat {{{
" https://github.com/tpope/vim-repeat
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'tpope/vim-repeat'

" End of vim-repeat }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-surround {{{
" https://github.com/tpope/vim-surround
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'tpope/vim-surround'

" End of vim-surround }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vimcdoc {{{
" https://github.com/vim-scripts/vimcdoc
" http://vimcdoc.sourceforge.net/
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'liangfeng/vimcdoc'

" End of vimcdoc }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vimprj (my plugin) {{{
" https://github.com/liangfeng/vimprj
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: add workspace support for projectmgr plugin. Such as, lookupfile plugin support multiple ftags.
Bundle 'liangfeng/vimprj'

" Since this plugin use python script to do some text precessing jobs,
" add python script path into 'PYTHONPATH' environment variable.
if has('unix')
    let $PYTHONPATH .= $HOME . '/.vim/bundle/vimprj/ftplugin/vimprj/:'
elseif has('win32') || has('win64')
    let $PYTHONPATH .= $VIM . '/bundle/vimprj/ftplugin/vimprj/;'
endif

" XXX: Change it. It's just for my environment.
if has('win32') || has('win64')
    let g:cscope_sort_path = 'd:/cscope'
endif

" Fast editing of my plugin
if has('unix')
    nnoremap <silent> <Leader>p :call <SID>OpenFileWithProperBuffer('$HOME/.vim/bundle/vimprj/ftplugin/vimprj/projectmgr.vim')<CR>
elseif has('win32') || has('win64')
    nnoremap <silent> <Leader>p :call <SID>OpenFileWithProperBuffer('$VIM/bundle/vimprj/ftplugin/vimprj/projectmgr.vim')<CR>
endif

" End of vimprj }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vimproc {{{
" https://github.com/Shougo/vimproc
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'Shougo/vimproc'

" End of vimproc }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vimshell {{{
" https://github.com/Shougo/vimshell
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'Shougo/vimshell'

" End of vimshell }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vundle {{{
" https://github.com/gmarik/vundle
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'gmarik/vundle'

let g:vundle_default_git_proto = 'http'
au FileType vundle setlocal noshellslash

" End of vundle }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - xml.vim {{{
" https://github.com/othree/xml.vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" XXX: Since the original repo dos not suit vundle, use vim-scripts instead.
" TODO: Should check whether vundle support post-install hook. If support, use
"       original repo, create html.vim as symbol link to xml.vim.
Bundle 'xml.vim'

autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" End of xml.vim }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - xptemplate {{{
" https://github.com/drmingdrmer/xptemplate
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'drmingdrmer/xptemplate'

au BufRead,BufNewFile *.xpt.vim set filetype=xpt.vim

" trigger key
let g:xptemplate_key = '<C-l>'
" navigate key
let g:xptemplate_nav_next = '<C-j>'
let g:xptemplate_nav_prev = '<C-k>'
let g:xptemplate_fallback = ''
let g:xptemplate_strict = 1
let g:xptemplate_minimal_prefix = 1

let g:xptemplate_pum_tab_nav = 1
let g:xptemplate_move_even_with_pum = 1
" since use delimitMate Plugin, disable it in xptemplate
let g:xptemplate_brace_complete = 0

" snippet settting
" Do not add space between brace
let g:xptemplate_vars = 'SPop=&SParg='

" End of xptemplate }}}

" vim: set et sw=4 ts=4 fdm=marker ff=unix:
