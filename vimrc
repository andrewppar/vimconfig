" Fold vim files so you can read them ---{{{
set foldenable
set foldcolumn=3
augroup filetype_vim 
  autocmd!
  autocmd FileType vim setlocal foldmethod=marker
augroup end
"}}} 
" Set split below --- {{{
set splitbelow
"}}}
" Set the path to do recursive search ---{{{
set path+=** 
"}}}
" Turn on plugins --- {{{
filetype plugin indent on
filetype plugin on
execute pathogen#infect()
syntax on 
filetype plugin indent on
"Turn on ctags
set tags=tags
"}}}
"Set up line numbering --- {{{
set relativenumber
set number 
"}}}
" Ignore case when searching --- {{{
set ignorecase
"}}}
" Highlight matching words while searching--- {{{ 
set hlsearch incsearch 
set backspace=indent,eol,start
"}}}
" Set up colorscheme--- {{{
colorscheme kalisi
set background=dark
set laststatus=2
"}}}
"Status Line --- {{{
set statusline=%.30F\ %y%h%m%r\ %=%{v:register}\ %l:%c\ %#Question#%{strftime('%a\ %b\ %e\ %H:%M')}
""set statusline=%t[%{strlen(&fenc)?&fenc:'none'},%{&ff}]%h%m%r\ %=%{v:register}\ %l/%L\ %P\ %#Question#%{strftime('%a\ %b\ %e\ %I:%M')}
set wrap linebreak nolist
set tabstop=4 shiftwidth=2 expandtab
"}}}
" Spelling @todo Do we always want this on? --- {{{
hi clear SpellBad 
hi SpellBad cterm=underline
"}}}
" Custom general key mappings --- {{{
let mapleader = ","
inoremap jk <Esc>`^
nnoremap <leader>o <C-w><C-w>
nnoremap <leader>1 <C-w>T
nnoremap <C-d> :sh<CR> 
nnoremap [ %
vnoremap [ %
nnoremap <leader>q :call Reindent()<cr>
nnoremap <leader>ev :tabedit ~/.vimrc<cr>
nnoremap <leader>sv :source ~/.vimrc<cr>

"Copy and paste to clipboard
vnoremap <leader>y :w !pbcopy<CR>
nnoremap <leader>p :r !pbpaste<CR>

function! Reindent () 
  "A reindent that doesn't take you away from the current line. 
  let l:linenumber=line('.')
  execute 'normal! gg=G'
  execute 'normal! ' . l:linenumber . 'G'
endfunction

function! SaveMakingDirs ()
  " Have Vim make dirs that don't exist.
  let l:path=expand('%:p:h')
  if isdirectory(l:path)
    execute "w <cr>"
    let file=expand('%:p') . "bk"
    execute "write " . l:file . "<cr>"
  else 
    let l:command="mkdir -p " . l:path
    execute "! " . l:command 
    execute ":w <cr>"
  endif 
endfunction

" try to get an emacs-like find-file command
nnoremap <leader>f :tabedit 

"Edit .vimrc while in another file. 
nnoremap <C-c>e    :tabedit ~/.vimrc<cr>
nnoremap <leader>e :call SourceCurrentBuffer()<cr>
"}}}
" Make the Cursor change with different modes --- {{{
let &t_SI = "\e[6 q" 
let &t_EI = "\e[2 q" 
" }}}
" Useful Functions --- {{{ 

function! RemoveMatchingPair ()
  let position=getpos('.')
  execute ':norm %x'
  call cursor(l:position[1], l:position[2])
  execute ':norm x'
endfunction

"}}} 
" Org Mode --- {{{
augroup filetype_org
  autocmd!  
  autocmd BufEnter *.org set nospell
  "@todo make these changes local 
  autocmd FileType org nnoremap <leader>t :call ToggleLines()<CR> 
  autocmd FileType org nnoremap <C-N> :call OrgLineIncreaseTimeStamp()<CR>
  autocmd FileType org nnoremap <C-P> :call OrgLineDecreaseTimeStamp()<CR>
  autocmd FileType org inoremap <C-J> <esc>`^:call OutlineNewline()<CR>A 
  autocmd FileType org nnoremap <leader>s :normal o    <CR>:call InsertCurrentDateInformation()<CR>
  autocmd FileType org nnoremap <leader>a :call OrgAgenda()<CR>
  autocmd FileType org nnoremap <leader>d :call OrgArchiveTodos()<CR>
  autocmd FileType org nnoremap <C-c><C-c> :call ExecuteBashInContext()<CR>
  autocmd FileType org nnoremap <C-L> :call OutlineIndent()<CR>
  autocmd FileType org nnoremap <C-H> :call OutlineUnindent()<CR>
  autocmd BufRead,BufNewFile *.org set filetype=org
augroup END

augroup filetype_org_agenda
  autocmd! 
  autocmd BufEnter \*agenda\* set nospell
  autocmd FileType org-agenda nnoremap q :q<CR>
augroup END

" }}} 
"UndoTree --- {{{
"@todo think of something useful here. 
"
"}}} 
" Langauges --- {{{
" COQ -- {{{
"augroup filetype_coq 
"  autocmd!
"  autocmd BufRead,BufNewFile *.v set filetype=coq
"  autocmd FileType coq :CoqIDESetMap
"  autocmd FileType coq inoremap <C-j> <esc>:CoqIDENext<CR>
"  autocmd FileType coq nnoremap <C-j> :CoqIDENext<CR>
"  autocmd FileType coq inoremap <C-k> <esc>:CoqIDEUndo<CR>
"  autocmd FileType coq nnoremap <C-k> :CoqIDEUndo<CR>
"  autocmd FileType coq inoremap <C-l> <esc>:CoqIDEToEOF<CR>
"  autocmd FileType coq nnoremap <C-l> :CoqIDEToEOF<CR>
"  autocmd FileType coq set nospell
"augroup END
"}}} 
" Lisp -- {{{
"Compile and Run Lisp file 
function! CompileAndRunLisp ()
  execute "! clisp -x \"(load \\\"" .'%' . "\\\")\" -repl" 
endfunction
augroup filetype_lisp 
  autocmd!
  autocmd FileType lisp nnoremap <leader>c :w<CR>:call CompileAndRunLisp()<CR>
  autocmd FileType lisp nnoremap - o(write-line "")<esc>o
  autocmd FileType lisp nnoremap <leader>; I;<esc>
augroup END
"}}}
" Haskell -- {{{
"
let g:haskell_enable_quantification = 1   " to enable highlighting of `forall`
let g:haskell_enable_recursivedo = 1      " to enable highlighting of `mdo` and `rec`
let g:haskell_enable_arrowsyntax = 1      " to enable highlighting of `proc`
let g:haskell_enable_pattern_synonyms = 1 " to enable highlighting of `pattern`
let g:haskell_enable_typeroles = 1        " to enable highlighting of type roles
let g:haskell_enable_static_pointers = 1  " to enable highlighting of `static`
let g:haskell_backpack = 1                " to enable highlighting of backpack keywords

let g:haskell_indent_if = 3
let g:haskell_indent_case = 2
let g:haskell_indent_let = 4
let g:haskell_indent_do = 3
let g:haskell_indent_in = 1
let g:haskell_indent_guard = 2
let g:haskell_indent_case_alternative = 1

function! CompileHaskell ()
  execute "! runhaskell" . " " . '%'
endfunction

augroup filetype_haskell
  autocmd!
  autocmd FileType haskell nnoremap <leader>c :w<CR>:call CompileHaskell()<CR>
  autocmd FileType haskell nnoremap <leader>; I--<esc>  
augroup END
"}}}
" Python -- {{{
function! CompilePython ()
  execute "! python" . " " . '%'
endfunction
augroup filetype_python 
  autocmd!
  autocmd FileType python nnoremap <leader>c :w<CR>:call CompilePython()<CR>
  autocmd FileType python vnoremap <leader>; :call CommentRegion("#")<cr>
augroup END
"}}} 
" Java -- {{{
augroup filetype_java 
  autocmd!
  autocmd FileType java :iabbrev <buffer> print System.out.println(
" }}}
" SPARQL -- {{{
augroup filetype_sparql
  autocmd!  
  autocmd BufRead,BufNewFile *.rq set filetype=sparql 
  autocmd FileType sparql nnoremap <leader>c :w<CR>:call RunSPARQLQuery()<CR>
augroup END

let g:anzo_dataset="http://cambridgesemantics.com/Graphmart/584241c448724ef6a0a49bdcfee79501"
let g:anzo_ds="http://cambridgesemantics.com/GqeDatasource/guid_b7dae89e5c754628fda6e6654ddd4d79"

function! RunSPARQLQuery() 
  echom "! anzo query -u sysadmin -w 123 -ds " . g:anzo_ds . " -dataset " . g:anzo_dataset . " -f " . '%' . " -y" 
  execute "! anzo query -u sysadmin -w 123 -ds " . g:anzo_ds . " -dataset " . g:anzo_dataset . " -f " . '%' . " -y" 
endfunction 
"}}}
" JSON -- {{{ 
augroup filetype_json
  autocmd! 
  autocmd BufRead,BufNewFile *.json set filetype=json
  autocmd FileType json nnoremap gg=G :%!python -m json.tool<cr>
augroup END
" }}}
" Mail -- {{{
augroup filetype_mail
  autocmd!
  autocmd FileType mail set spell
  autocmd FileType mail setlocal fo+=aw

augroup END
" }}}
"}}}
" --  Scratch --- {{{
function! SourceCurrentBuffer ()
  let l:file=expand('%F')
  execute ":source " . l:file
endfunction

function! CommentRegion (comment_string)
  "@todo find a way of defining a string on a language basis. We can probably
  "handle this with a G variable
  let l:start=line("'<")
  let l:end=line("'>")
  execute l:start . "," . l:end . "norm I". a:comment_string
endfunction

function! SurroundRegion (character)

endfunction


"  --- }}} 
