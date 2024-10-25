" Vim syntax file
" Language:        VOLL
" Original Author: Ethan Estrada
" Latest Change:   24 October 2024

if exists('b:current_syntax')
  finish
endif

syn match vollLineStart /\v^[ \t]*/ nextgroup=vollComment,vollIdentifier
syn keyword vollTodo contained TODO FIXME XXX NOTE
syn match vollComment "\v\#" contained nextgroup=vollShebangComment,vollNormalComment
syn match vollNormalComment "\v[^!].*$" contained contains=vollTodo
syn match vollShebangComment "\v\!.+$" contained

syn match vollIdentifier "\v[a-zA-Z][a-zA-Z0-9_.]*" contained skipwhite nextgroup=vollAssignment,vollAssignmentError,vollIdentifierError
syn match vollIdentifierError "\v[^a-zA-Z0-9_.= \t]+" contained nextgroup=vollAssignment,vollAssignmentError,vollIdentifier
syn match vollAssignment "\v\=" contained skipwhite nextgroup=vollJsonNumber,vollJsonBoolean,vollJsonNull,vollJsonString
syn match vollAssignmentError "\v[^=]+$" contained

" Add proper highlighting for JSON literals.

" XXX: Types with `Json` in the name are parsed like JSON to visually indicate what is JSON compatible and what is not.

" NOTE: Pulled the Number regex from the JSON syntax definition.
syn match vollJsonNumber "-\=\<\%(0\|[1-9]\d*\)\%(\.\d\+\)\=\%([eE][-+]\=\d\+\)\=\>" contained skipwhite nextgroup=vollJsonWarning
syn keyword vollJsonBoolean contained true false skipwhite nextgroup=vollJsonWarning
syn keyword vollJsonNull contained null skipwhite nextgroup=vollJsonWarning

" NOTE: Pulled the string and escape sequence regex from the JSON syntax definition.
syn region vollJsonString start=/\v"/ skip=/\\\\\|\\"/ end=/\v"/ oneline contained skipwhite contains=vollJsonEscape nextgroup=vollJsonWarning

" Syntax: Escape sequences
syn match vollJsonEscape "\\["\\/bfnrt]" contained
syn match vollJsonEscape "\\u\x\{4}" contained

" Only shown if extra text trails a JSON literal.
syn match vollJsonWarning "\v[^ \t].*$" contained

hi def link vollComment            Comment
hi def link vollNormalComment      Comment
hi def link vollShebangComment     SpecialComment

hi def link vollTodo               Todo
hi def link vollIdentifier         Identifier
hi def link vollAssignment         Operator
hi def link vollJsonNumber         Number
hi def link vollJsonBoolean        Boolean
hi def link vollJsonNull           Constant
hi def link vollJsonString         String
hi def link vollJsonEscape         Special
hi def link vollJsonWarning        Todo
hi def link vollIdentifierError    Error
hi def link vollAssignmentError    Error

let b:current_syntax = 'voll'
