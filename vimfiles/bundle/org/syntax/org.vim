if exists("b:current_syntax")
  finish
endif

"bold, italic, underline
syntax region orgBold start=/\v\*/ skip=/\v\\./ end=/\v\*/ keepend oneline
hi def orgBold term=bold cterm=bold gui=bold 

syntax region orgItalic start=/\v\// skip=/\v\\./ end=/\v\// keepend oneline
hi def orgItalic term=italic cterm=italic gui=italic

syntax region orgUnderline start=/\v\\_/ skip=/\v\\./ end=/\v\\_/ keepend oneline
hi def orgUnderline term=underline cterm=underline gui=underline

"Org todo Keywords
syntax match orgOperator "\v^\**" nextgroup=orgKeyword skipwhite
syntax keyword orgKeyword TODO DONE contained 
syntax match   orgKeyword "IN PROGRESS" contained
highlight link orgOperator Operator
highlight link orgKeyword Statement 

"Time Stamp
syntax match orgTimeStamp "\v\<\d\d\d\d-\d\d-\d\d \w\w\w \d\d:\d\d\>"
syntax match orgTimeStamp "\v\<\d\d\d\d-\d\d-\d\d \w\w\w \d\d:\d\d\ \+\d*\S\>"
syntax keyword orgTimeStamp CLOSED SCHEDULED
highlight link orgTimeStamp Tag

"Comment
syntax match orgComment "\v#.*$" 
highlight link orgComment Comment

"CheckBoxes  "@todo question: What do we do with checkboxes embedded in
"outlines as headers, e.g. ** [ ] ITEM
syntax match orgUncheckedCheckLine "^\(\s\|\**\)\s*\[ \]" nextgroup=uncheckedBox
syntax match uncheckedBox "\[ \]" contained containedin=orgUncheckedCheckLine 
highlight link orgUncheckedCheckLine Macro
highlight link uncheckedBox Constant

syntax match orgCheckedCheckLine "^\(\s\|\**\)\s*\[X\]" nextgroup=checkedBox 
syntax match checkedBox "\[X\]" contained containedin=orgCheckedCheckLine
highlight link orgCheckedCheckLine Text
highlight link checkedBox Label

"Priorities
syntax match orgHighPriority "\v\[#A\]"
highlight link orgHighPriority Constant
 
syntax match orgMedPriority "\v\[#B\]"
highlight link orgMedPriority Float

syntax match orgLowPriority "\v\[#C\]" 
highlight link orgLowPriority Keyword

let b:current_syntax = "org"
