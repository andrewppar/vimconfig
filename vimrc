" Fold vim files so you can read them ---{{{
set foldenable
set foldcolumn=3
augroup filetype_vim 
  autocmd!
  autocmd FileType vim setlocal foldmethod=marker
augroup end
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
set statusline=%.30F\ %y%h%m%r\ %=%{v:register}\ Lines:\ %L\ %#Question#%{strftime('%a\ %b\ %e\ %H:%M')}
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
nnoremap <leader>s :call SaveMakingDirs()<cr>
nnoremap <leader>o <C-w><C-w>
nnoremap <leader>1 <C-w>T
nnoremap <C-d> :sh<CR> 
nnoremap [ %
vnoremap [ %
nnoremap <leader>q :call Reindent()<cr>

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
nnoremap <leader>sv :source ~/.vimrc<cr>
"}}}
" Make the Cursor change with different modes --- {{{
let &t_SI = "\e[6 q" 
let &t_EI = "\e[2 q" 
" }}}
" Org Mode --- {{{
augroup filetype_org
  autocmd! 

  autocmd BufEnter *.org set nospell
  autocmd FileType org nnoremap <leader>t :call ToggleLines()<CR> 
  autocmd FileType org inoremap ,d <C-o>:call OutlineNewline()<CR>
  "@todo unify this ^ with CycleTodoKeys
  " autocmd FileType org nnoremap <C-M> :call OutlineNewline()<CR>
  autocmd BufRead,BufNewFile *.org set filetype=org
augroup END

" }}} 
"UndoTree --- {{{
"@todo think of something useful here. 
"
"}}} 
" Langauges --- {{{
" COQ -- {{{
augroup filetype_coq 
  autocmd!
  autocmd BufRead,BufNewFile *.v set filetype=coq
  autocmd FileType coq :CoqIDESetMap
  autocmd FileType coq inoremap <C-j> <esc>:CoqIDENext<CR>
  autocmd FileType coq nnoremap <C-j> :CoqIDENext<CR>
  autocmd FileType coq inoremap <C-k> <esc>:CoqIDEUndo<CR>
  autocmd FileType coq nnoremap <C-k> :CoqIDEUndo<CR>
  autocmd FileType coq inoremap <C-l> <esc>:CoqIDEToEOF<CR>
  autocmd FileType coq nnoremap <C-l> :CoqIDEToEOF<CR>
  autocmd FileType coq set nospell
augroup END
"}}} 
" LaTeX -- {{{
augroup filetype_tex 
  autocmd!
  "Compile LaTeX Files
  autocmd FileType tex set spell 
  autocmd FileType tex nnoremap <leader>b :w<CR>:call CompileTeX()<CR> 
  "This doesn't do anything now ^
  "I also don't like the idea of 
  "linking my bash scripts to my 
  "vim scripts like this.  

  autocmd FileType tex nnoremap <leader>c I%<esc>  
  " There's gotta be a better way to do this ^

  "Check LaTeX word count
  nnoremap <leader>w :w !detex \| wc -w<CR>
  autocmd FileType tex nnoremap <leader>t :LatexTOC<CR>

  "Wrap environment
  autocmd FileType tex inoremap <C-L><C-E> <esc>vbxi\begin{<esc>pa}<CR><CR>\end{<esc>pa}<esc>ki
augroup END

function! CompileTeX()
  execute "! compileLaTeX" . " " . '%' 
endfunction 
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
"  --- }}}
