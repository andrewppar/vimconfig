if exists("b:current_syntax")
  finish
endif

"Org todo Keywords
syntax match orgComment "\v#.*$" 
highlight link orgComment Comment

syntax match orgOperator "\v\*" nextgroup=orgKeyword skipwhite
syntax keyword orgKeyword TODO DONE contained 
syntax match   orgKeyword "IN PROGRESS" contained
highlight link orgOperator Operator
highlight link orgKeyword Statement

syntax match orgTimeStamp "\v\<\d\d\d\d-\d\d-\d\d \w\w\w \d\d:\d\d\>"
syntax keyword orgTimeStamp CLOSED SCHEDULED
highlight link orgTimeStamp Tag



let b:current_syntax = "potion"
