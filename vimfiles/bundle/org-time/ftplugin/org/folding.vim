" setlocal foldmethod=indent
setlocal foldmethod=expr
setlocal foldexpr=OrgFold(v:lnum)

function! OrgFold(linum) 
  "@todo don't just ignore closed, ignore timestamps, i.e. make them what
  "their parents is
  "@todo have a better fold for same depth, maybe don't...
  let l:line=getline(a:linum)
  if l:line =~? '\v^\s*$'
    return '-1'
  endif
  let l:prev_line=(getline(a:linum - 1))
  let l:prev_depth=OutlineItemDepth(l:prev_line)
  let l:depth=OutlineItemDepth(l:line)
  if l:line =~? '\v\s*CLOSED:'
    return l:prev_depth
  endif 
  if l:line =~? '\v\s*\<\d\d\d\d-\d\d-\d\d \w\w\w \d\d:\d\d\>'
    return l:prev_depth
  endif
  if l:depth == l:prev_depth
    return l:depth
  endif 
  if l:prev_depth < l:depth
    return  '>' . l:depth
  else
    return l:depth 
  endfunction 
