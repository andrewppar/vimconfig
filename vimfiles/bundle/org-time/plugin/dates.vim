" =============================================================================
" Filename: time/dates.vim
" Author: andrewppar
" License: None
" Last Change: 2019-05-21 
" ============================================================================= 

" -- Manage Dates --{{{

function! GetDayFromBuffer () 
  let l:line=getline('.')
  let l:possibly_split_lines=split(l:line, '<')
  if len(l:possibly_split_lines) >= 2 
    let l:potential_date=split(l:possibly_split_lines[-1], ' ')[0]
    let l:date_fields=split(potential_date, '-')
    let l:year=date_fields[0]
    let l:month=date_fields[1]
    let l:day=date_fields[2]
    let l:result=GetDayFromYearMonthDay(l:year, l:month, l:day)
    execute ':normal! a ' . l:result . '>'
  else 
    echom "Couldn't Find Date"
  endif 
endfunction 

function! GetDayFromYearMonthDay (year, month, day)
  let l:days=["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
  let l:months=[31,28,31,30,31,30,31,31,30,31,30,31]
  "@todo there is a probably a more elegant algorithm, but this seems pretty 
  " performant so whatevs. Fix it if you want bro. 
  let l:year_but_one=a:year - 1
  let l:big_year=6*(l:year_but_one % 400) 
  let l:middle_year=4*(l:year_but_one % 100)
  let l:small_year=5*(l:year_but_one % 4)
  let l:total=1+l:small_year+l:middle_year+l:big_year 
  let l:jan_first=l:total % 7
  let l:leap_year_p=a:year % 4 ==? 0
  let l:month_range=range(a:month - 1)
  let l:daysum=0
  for month_idx in l:month_range
    let l:daysum += l:months[month_idx] 
    if l:leap_year_p && (month_idx ==? 1)
      let l:daysum += 1
    endif 
  endfor
  let l:daysum += (a:day - 1)
  return l:days[(l:daysum + l:jan_first) % 7]
endfunction

function! InsertTimeStamp ()
  call GenerateTimeStampInternal(1,0) 
endfunction

function! GetTimeToInsert ()
  call GenerateTimeStampInternal(0,0)
endfunction

function! InsertCurrentDateInformation()
  call GenerateTimeStampInternal(1,1)
endfunction

function! GenerateTimeStampInternal(use_today_p, use_now_p)
  if a:use_today_p 
    let l:year=strftime("%Y")
    let l:month=strftime("%m")
    let l:day=strftime("%d") 
  else
    let l:month=input("Month: ")
    let l:day=input("Day: ")
    let l:year=input("Year: ") 
  endif
  if a:use_now_p
    let l:time=strftime("%I:%M")
  else
    let l:time=input("Time: ")
  endif
  let l:timestamp=GenerateTimeStamp(l:day, l:month, l:year, l:time)
  execute ':normal! i' . l:timestamp 
endfunction

function! GenerateTimeStamp(day, month, year, time) 
  let l:weekday=GetDayFromYearMonthDay(a:year, a:month, a:day)
  return  "<" . a:year . "-" . a:month . "-" . a:day . " " . l:weekday . " " . a:time .">"
endfunction 

" --}}}
" -- Manage Todos -- {{{ 
let g:todo_keylist=["TODO ", "IN PROGRESS ", "DONE "]
let g:last_todo_idx=len(g:todo_keylist) - 1

function! CycleTodoKeys ()
  "@NOTE This function assumes that TodoLineWithKeys will either 
  "return 0, 1, or a string keyword from g:todo_keylist 
  "@todo Bro you should really be programmin a little more robustly. 
  "@return This function will return 1 or 0 depending on whether it
  "was on a star line. If it was, it will insert the next todo key in 
  "the cycle and return 1. Otherwise it will do nothing and return 0. 
  let l:possibly_outline_depth_or_todo_key=TodoLineWithKeys(g:todo_keylist) 
  if index(g:todo_keylist, l:possibly_outline_depth_or_todo_key) >= 0 
    " Get the next todo keyword
    let l:next_key=NextTodoKey(l:possibly_outline_depth_or_todo_key)
    let l:chars_to_delete=len(l:possibly_outline_depth_or_todo_key) 
    " Delete the last keyword
    execute ':normal! 0f ' . l:chars_to_delete . "xa" . l:next_key 
    " If the new keyword is the last one, close the item.
    "@todo make 'CLOSED" be indented the right amount
    if l:next_key ==# g:todo_keylist[-1]
      execute ':normal! o CLOSED: '
      call InsertCurrentDateInformation()
      execute ':normal! k'
      "If the old keyword was the last remove any 
      "old CLOSEDs
    elseif l:possibly_outline_depth_or_todo_key ==# g:todo_keylist[-1]
      let l:next_line=getline(line('.')+1)
      if l:next_line =~# '^\s*CLOSED:'
        execute 'normal! jddk'
      endif 
    endif
    return 1 
  elseif l:possibly_outline_depth_or_todo_key ==? 1 
    execute ':normal! 0f a' . g:todo_keylist[0]
    return 1
  else
    return 0
  endif
endfunction

function! NextTodoKey(key) 
  "@NOTE This assumes that key is a valid element of g:todo_keylist
  "  echom a:key
  let l:last_todo_key=g:todo_keylist[-1]
  if a:key ==# l:last_todo_key
    return ""
  else 
    let l:current_key_idx=index(g:todo_keylist, a:key)
    return g:todo_keylist[l:current_key_idx + 1]
  endif
endfunction 

function! LineOutlineItemDepth ()
  let l:line=getline('.')
  return OutlineItemDepth(l:line)
endfunction

function! OutlineItemDepth (line)
  "This errors if the string can't be split
  let l:split_line=split(a:line, ' ')
  if empty(l:split_line)
    return 0
  else 

    let l:possibly_stars=l:split_line[0]
    if !empty(matchstr(l:possibly_stars, '\**'))
      return strlen(l:possibly_stars)
    else 
      return 0
    endif
  endif
endfunction

function! InitialStringMatch(longstring, substring) 
  let l:index=0 
  let l:max=strlen(a:substring)
  if l:max > strlen(a:longstring)
    return 0
  else
    let l:match=1 
    while l:index < l:max && l:match
      if a:longstring[l:index] !=# a:substring[l:index]
        let l:match=0 
      endif 
      let l:index=l:index + 1
    endwhile 
    return l:match 
  endif
endfunction

function! TodoLineWithKeys(keywords)
  "@return the todo keyword if there is one 
  "otherwise it returns 1 if the line is an outline line
  "otherwise it returns 0.
  let l:line=getline('.')
  let l:outline_depth=OutlineItemDepth(l:line)
  if l:outline_depth 
    let l:line_init=strpart(l:line,(l:outline_depth + 1))
    let l:key=""
    let l:index=0
    let l:max=len(a:keywords) 
    while l:key ==? "" && l:index < l:max
      let l:current_key=a:keywords[l:index]
      if InitialStringMatch(l:line_init, l:current_key)
        let l:key=l:current_key
      endif
      let l:index += 1
    endwhile
    if l:key ==? "" 
      return 1
    else
      return l:key 
    endif
  else 
    return 0
  endif 
endfunction 

function! FinishedLineWithCloseTime()
  "@return 1, if the current line is the last line in g:todo_keylist. 
  "if there is a closed:... line underneath that gets deleted. 
  "@return 0, otherwise. 
  let l:line_num=line('.')
  let l:line=getline(l:line_num)
  let finish_line=TodoLineWithKeys([g:todo_keylist[-1]])
  if finish_line ==# g:todo_keylist[-1]
    return 1
  else 
    return 0 
  endif
endfunction
" -- }}}
" -- Outline Items --- {{{ 

function! OutlineNewline ()
  "Enters a newline with the same outline
  "depth as the current line. If the current
  "line is not an outline line then it just enters a line. 
  let l:outline_depth=LineOutlineItemDepth()
  let l:star_count=0
  let l:stars=""
  while l:star_count < outline_depth
    let l:stars=l:stars . "*"
    let l:star_count=l:star_count + 1
  endwhile
  execute ":normal! o" . l:stars . " " 
  return 1
endfunction




"  }}}
