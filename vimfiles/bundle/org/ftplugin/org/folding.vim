" setlocal foldmethod=indent
setlocal foldmethod=expr
setlocal foldexpr=OrgFold(v:lnum)

function! OrgFold(linum) 
  "@todo don't just ignore closed, ignore timestamps, i.e. make them what
  "their parents is
  "@todo have a better fold for same depth, maybe don't...
  let l:line=getline(a:linum)
  let l:prev_line=(getline(a:linum - 1))
  let l:prev_depth=OutlineItemDepth(l:prev_line)
  let l:depth=OutlineItemDepth(l:line)
  if l:line =~? '\v^\s*$'
    return '='
  endif 
  if l:line =~? '\v\s*CLOSED:'
    return '='
  endif 
  if l:line =~? '\v\s*DEADLINE:'
    return '='
  endif 
  if l:line =~? '\v\s*\<\d\d\d\d-\d\d-\d\d \w\w\w \d\d:\d\d\>'
    return l:prev_depth
  endif
  if l:line =~? '\v\<\d\d\d\d-\d\d-\d\d \w\w\w \d\d:\d\d\ \+\d*\S\>'
    return l:prev_depth 
  endif
  if l:depth != 0
    if l:depth ==? l:prev_depth
      return '>' . l:depth . '<' . l:depth
    elseif l:prev_depth < l:depth
      return  '>' . l:depth
    else
      return  '>' . l:depth 
    endif
  else 
    return '='
  endif
endfunction 
