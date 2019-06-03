if exists("b:current_syntax")
  finish
endif

"Org todo Keywords
syntax region orgBold start=/\v\*/ skip=/\v\\./ end=/\v\*/
hi def orgBold term=bold cterm=bold gui=bold 

"syntax region orgItalic start=/\v\// skip=/\v\\./ end=/\v\//
"hi def orgItalic term=italic cterm=italic gui=italic

syntax region orgUnderline start=/\v\\_/ skip=/\v\\./ end=/\v\\_/
hi def orgUnderline term=underline cterm=underline gui=underline

syntax match orgOperator "\v^\**" nextgroup=orgKeyword skipwhite
syntax keyword orgKeyword TODO DONE contained 
syntax match   orgKeyword "IN PROGRESS" contained
highlight link orgOperator Operator
highlight link orgKeyword Statement 

syntax match orgTimeStamp "\v\<\d\d\d\d-\d\d-\d\d \w\w\w \d\d:\d\d\>"
syntax keyword orgTimeStamp CLOSED SCHEDULED
highlight link orgTimeStamp Tag

syntax match orgComment "\v#.*$" 
highlight link orgComment Comment

let b:current_syntax = "org"
