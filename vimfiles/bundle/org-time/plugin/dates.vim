" =============================================================================
" Filename: time/dates.vim
" Author: andrewppar
" License: None
" Last Change: 2019-05-21 
" ============================================================================= 

" -- Manage Dates --{{{
let g:days=["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

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
  return g:days[(l:daysum + l:jan_first) % 7]
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
    let l:time=strftime("%H:%M")
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

function! GetDateFromOrgDate(org_date)
  let l:clean_string = substitute(a:org_date, '^\s*\(.\{-}\)\s*$', '\1', '') 
  return strpart(l:clean_string,1,10)
endfunction

function! GetTimeFromOrgDate(org_date)
  let l:clean_string = substitute(a:org_date, '^\s*\(.\{-}\)\s*$', '\1', '') 
  return strpart(l:clean_string,16,5)
endfunction


" --}}}
" -- Manage Todos -- {{{ 
let g:todo_keylist=["TODO ", "IN PROGRESS ", "DONE "]
let g:last_todo_idx=len(g:todo_keylist) - 1

function! CycleTodoKeys ()
  "@NOTE This function assumes that CurrenLineTodoLineWithKeys will either 
  "return 0, 1, or a string keyword from g:todo_keylist 
  "@todo Bro you should really be programmin a little more robustly. 
  "@return This function will return 1 or 0 depending on whether it
  "was on a star line. If it was, it will insert the next todo key in 
  "the cycle and return 1. Otherwise it will do nothing and return 0. 
  let l:possibly_outline_depth_or_todo_key=CurrenLineTodoLineWithKeys(g:todo_keylist) 
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

function! CurrenLineTodoLineWithKeys(keywords)
  "@return the todo keyword if there is one 
  "otherwise it returns 1 if the line is an outline line
  "otherwise it returns 0.
  let l:line=getline('.')
  return TodoLineWithKeys(l:line, a:keywords)
endfunction

function! TodoLineWithKeys(line, keywords)
  let l:outline_depth=OutlineItemDepth(a:line)
  if l:outline_depth 
    let l:line_init=strpart(a:line,(l:outline_depth + 1))
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

function! GetTodoDictionary()
  "This function looks at the current file 
  "@todo expand to look at a group of files
  "and generates a dictionary of all the non-finished todo items 
  "along with their associated dates. 
  let l:todo_dictionary = {}
  let l:last_line_number=line('$') 
  let l:current_line_number=0
  let l:last_todo=g:todo_keylist[-1]
  while l:current_line_number <= l:last_line_number
    let l:current_line=getline(l:current_line_number)
    let l:current_todo=TodoLineWithKeys(l:current_line, g:todo_keylist)
    "echom "LINE" 
    "echom l:current_line
    "echom "CURRENT TODO" 
    "echom l:current_todo
    if index(g:todo_keylist, l:current_todo) >= 0 && l:current_todo !=# l:last_todo 
      "echom "FOUND USEFUL LINE"
      let l:next_line=getline(l:current_line_number + 1)
      "echom "NEXT LINE" 
      "echom l:next_line
      let l:org_date=OrgDateLineP(l:next_line)
      "echom "DATE?"
      "echom l:org_date
      let l:todo_item=TodoLineTodoItem(l:current_line)
      if l:org_date > 0 
        let l:todo_dictionary[l:todo_item]=l:next_line 
      else 
        let l:todo_dictionary[l:todo_item]="" 
      endif
    endif
    let l:current_line_number=l:current_line_number + 1
  endwhile 
  return l:todo_dictionary
endfunction

function! TodoLineTodoItem(line) 
  let l:depth=OutlineItemDepth(a:line)
  if l:depth>0
    return strpart(a:line,l:depth)
  else
    return ""
  endif 
endfunction

function! OrgDateLineP(line)
  if matchstr(a:line, '\v\<\d\d\d\d-\d\d-\d\d \S\S\S \d\d:\d\d\>') !=? ""
    return 1
  endif
  if matchstr(a:line, '\v\<\d\d\d\d-\d\d-\d\d \S\S\S \d\d:\d\d\ \+\d*\S>') !=? ""
    return 1
  endif
  return 0 
endfunction 

function! FinishedLineWithCloseTime()
  "@return 1, if the current line is the last line in g:todo_keylist. 
  "if there is a closed:... line underneath that gets deleted. 
  "@return 0, otherwise. 
  let l:line_num=line('.')
  let l:line=getline(l:line_num)
  let finish_line=CurrenLineTodoLineWithKeys([g:todo_keylist[-1]])
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
  execute ":normal! o" . l:stars 
  return 1
endfunction
"  }}}
" -- Org Agenda --- {{{

let g:agenda_vertial_p=1

function! OrgAgenda() 
  "@todo fix *agenda* to be easily mode recognizable 
  let l:todo_items=GetTodoDictionary()
  let l:timeless_todos=[]
  let l:timed_todos={} 
  for todo_item in keys(l:todo_items)
    let l:todo_time=l:todo_items[l:todo_item]
    if l:todo_time ==? ""
      let l:timeless_todos=add(l:timeless_todos,l:todo_item)
    else
      let l:timed_todos[l:todo_item]=l:todo_time
    endif 
  endfor
  if g:agenda_vertial_p
    execute ":vsp *agenda*"
  else
    execute ":sp *agenda*"
  endif 
  setlocal modifiable
  setlocal buftype=nofile
  set ft=org 
  execute ":normal! iOrg Agenda"
  execute ":normal! o------------------------------------------------"
  call PrintTimelessTodoItems(l:timeless_todos)
  execute ":normal! o"
  let l:current_month_name=strftime("%b")
  execute ":normal! o" . l:current_month_name
  let l:current_month=strftime("%m")
  let l:current_day=strftime("%d")
  let l:current_year=strftime("%Y")
  let l:weekday_dict=CurrentWeekDayDictionary(l:current_day, l:current_month, l:current_year)
  for day in g:days
    "if day matches todo then print todo
    "Do something special for today, i.e. expand it and add now
    let l:current_date=l:weekday_dict[l:day]
    execute "normal! o" . l:day . " " . l:current_date . "  ----------------------------------------"
    call PrintOrgTodoItemsForDay(l:timed_todos, l:current_date, l:current_month, l:current_year)
  endfor 
  setlocal nomodifiable
endfunction

function! PrintTodoItem(item, time)
  execute "normal! o status: " . a:time . "...... " . a:item 
endfunction

function! PrintTimelessTodoItems(items)
  for item in a:items
    call PrintTodoItem(l:item, "     ")
  endfor 
endfunction 

function! PrintOrgTodoItemsForDay(todo_dictionary, day, month, year)
  for todo_item in keys(a:todo_dictionary) 
    let l:timestamp=a:todo_dictionary[l:todo_item]
    let l:scheduled_date=GetDateFromOrgDate(l:timestamp)
    if a:year . "-" . a:month . "-" . TwoDigitNumberString(a:day) ==# l:scheduled_date 
      let l:scheduled_time=GetTimeFromOrgDate(l:timestamp) 
      call PrintTodoItem(l:todo_item, l:scheduled_time) 
    endif  
  endfor
endfunction

function! TwoDigitNumberString(number_string)
  if a:number_string < 10 && a:number_string > -10
    return "0" . a:number_string
  else 
    return a:number_string
  endif
endfunction 

let g:month_length_dictionary={'01':31, '02':28, '03':31, '04':30, '05':31, '06':30, '07': 31, '08':31, '09':30, '10':31, '11':30, '12':31}

function! CurrentWeekDayDictionary(current_day, current_month, current_year)
  let l:weekday=GetDayFromYearMonthDay(a:current_year, a:current_month, a:current_day)
  let l:weekdays={}
  let l:current_weekday_count=index(g:days,l:weekday) 
  let l:day_count=l:current_weekday_count 
  let l:month_length=g:month_length_dictionary[a:current_month]
  while l:day_count >= 0
    let l:potential_loop_day=a:current_day - (l:current_weekday_count - l:day_count)
    if l:potential_loop_day < 1 
      let l:loop_day=g:month_length_dictionary[(a:current_month -1)] - (abs(l:potential_loop_day) + 1)
    else
      let l:loop_day=l:potential_loop_day 
    endif 
    let l:loop_weekday=g:days[l:day_count]
    let l:weekdays[l:loop_weekday]=l:loop_day
    let l:day_count-= 1
  endwhile
  let l:day_count=l:current_weekday_count+1
  while l:day_count <= 6
    let l:potential_loop_day=a:current_day + (l:day_count - l:current_weekday_count)
    if l:potential_loop_day > l:month_length 
      let l:loop_day=l:potential_loop_day - l:month_length
    else 
      let l:loop_day=l:potential_loop_day
    endif 
    let l:loop_weekday=g:days[l:day_count]
    let l:weekdays[l:loop_weekday]=l:loop_day
    let l:day_count+= 1
  endwhile 
  return l:weekdays
endfunction





"  }}}
