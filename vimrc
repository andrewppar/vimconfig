" Fold vim files so you can read them ---{{{
set foldenable
set foldcolumn=3
augroup filetype_vim 
  autocmd!
  autocmd FileType vim setlocal foldmethod=marker
augroup end
"}}} 
" Turn on plugins --- {{{
filetype plugin indent on
filetype plugin on
execute pathogen#infect()
syntax on 
filetype plugin indent on
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
set statusline=%.20F\ %y%h%m%r\ %=%{v:register}\ Lines:\ %L\ %#Question#%{strftime('%a\ %b\ %e\ %I:%M')}
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
onoremap jk <Esc>
cnoremap jk <C-c><Esc>
nnoremap <leader>s :call SaveMakingDirs()<cr>
nnoremap <leader>o <C-w><C-w>
nnoremap <leader>1 <C-w>T
nnoremap <C-d> :sh<CR> 
nnoremap [ %
vnoremap [ %
nnoremap gg=G :call Reindent()<cr> 

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
    :write
  else 
    let l:command="mkdir -p " . l:path
    execute "! " . l:command 
    :write
  endif 
endfunction

" try to get an emacs-like find-file command
nnoremap <leader>f :tabedit 

"Edit .vimrc while in another file. 
nnoremap <C-c>e    :tabedit ~/.vimrc<cr>
nnoremap <leader>e :source ~/.vimrc<cr>
"}}}
" Org Mode --- {{{
augroup filetype_org
  autocmd! 

  autocmd BufEnter *.org set nospell
  autocmd FileType org nnoremap <leader>t :call CycleTodoKeys()<CR> 
  autocmd FileType org inoremap ,,d <C-o>:call OutlineNewline()<CR>
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
"compile Lisp file 
function! CompileLisp ()
  execute "! clisp " . " " . '%'
endfunction
augroup filetype_lisp 
  autocmd!
  autocmd FileType lisp nnoremap <leader>b :w<CR>:call CompileLisp()<CR>
  autocmd FileType lisp nnoremap - o(write-line "")<esc>o
  autocmd FileType lisp nnoremap <leader>c I;<esc>
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
" }}}
"}}}
" --  Scratch --- {{{
function! SourceCurrentBuffer ()
  let l:file=expand('%F')
  execute ":source " . l:file
endfunction
"  --- }}}
