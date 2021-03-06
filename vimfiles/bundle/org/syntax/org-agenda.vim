if exists("b:current_syntax")
  finish 
endif

syntax match dayLine "-*"
highlight link dayLine Boolean

syntax match day "\w\w\w \d\+"
highlight link day Label
"Times
syntax match agendaTime "\d\d:\d\d"
highlight link agendaTime Constant

syntax match todoLine ".*TODO.*" nextgroup=todoTime skipwhite
syntax match todoTime "\v\d\d:\d\d" contained containedin=todoLine
syntax match todoItem "\v\.*  TODO" contained containedin=todoLine
syntax keyword orgTodo  TODO contained containedin=todoItem
syntax match todoStatus "status:"  contained containedin=todoLine
syntax match todoStatus "unset :"  contained containedin=todoLine
syntax match todoStatus "future:"  contained containedin=todoLine 
syntax match todoStatus "late  :"  contained containedin=todoLine

highlight link todoTime Conditional
highlight link orgTodo Keyword
highlight link todoStatus Float
highlight link todoItem Text
highlight link todoLine Text

syntax match inprogressLine ".*IN PROGRESS.*" nextgroup=inprogressTime skipwhite
syntax match inprogressTime "\v\d\d:\d\d" contained containedin=inprogressLine
syntax match inprogressItem "\v\.*  IN PROGRESS" contained containedin=inprogressLine
syntax match orginprogress  "IN PROGRESS" contained containedin=inprogressItem
syntax match inprogressStatus "status:"  contained containedin=inprogressLine
syntax match inprogressStatus "unset :"  contained containedin=inprogressLine
syntax match inprogressStatus "future :"  contained containedin=inprogressLine
syntax match inprogressStatus "late  :"  contained containedin=inprogressLine 
highlight link inprogressTime Define
highlight link orginprogress Function
highlight link inprogressItem Text
highlight link inprogressStatus Float
highlight link inprogressLine Text

syntax match statusItem "status:" 
syntax match statusItem "unset :"
syntax match statusItem "future:"
syntax match statusItem "late  :"
highlight link statusItem Float

syntax match hline "\v^\=+$"
highlight link hline Function

let b:current_syntax="org-agenda"
