" Vim syntax file
" Language: VOLL
" Maintainer: Ethan Estrada
" Latest Revision: 22 October 2024

if exists('b:current_syntax')
  finish
endif

syn match vollLineStart /\v^[ \t]*/ nextgroup=vollComment,vollIdentifier
syn keyword vollTodo contained TODO FIXME XXX NOTE
syn match vollComment "\v#.*$" contained contains=vollTodo

syn match vollIdentifier "\v[a-zA-Z][a-zA-Z0-9_.]*" contained skipwhite nextgroup=vollAssignment
syn match vollAssignment "\v\=" contained skipwhite nextgroup=vollJsonFloat,vollJsonNumber,vollJsonBoolean,vollJsonNull,vollJsonString

" Add proper highlighting for JSON literals.

" XXX: Types with `Json` in the name are parsed like JSON to visually indicate what is JSON compatible and what is not.

" TODO: support more floating point formats that are JSON compatible
syn match vollJsonFloat "\v-?\d+\.\d+" contained skipwhite nextgroup=vollJsonError

" FIXME: Number regex is taking precedence over float regex (i.e. floats aren't parsing correctly).
syn match vollJsonNumber "\v-?\d+" contained skipwhite nextgroup=vollJsonError
syn keyword vollJsonBoolean contained true false skipwhite nextgroup=vollJsonError
syn keyword vollJsonNull contained null skipwhite nextgroup=vollJsonError

" FIXME: JSON strings do not properly support all JSON escapes yet.
syn region vollJsonString start=/\v"/ skip=/\v\\./ end=/\v"/ oneline contained skipwhite nextgroup=vollJsonError

" Only shown if extra text trails a JSON literal.
syn match vollJsonError "\v[^ \t].*$" contained

hi def link vollTodo               Todo
hi def link vollComment            Comment
hi def link vollIdentifier         Identifier
hi def link vollAssignment         Operator
hi def link vollJsonFloat          Float
hi def link vollJsonNumber         Number
hi def link vollJsonBoolean        Boolean
hi def link vollJsonNull           Constant
hi def link vollJsonString         String
hi def link vollJsonError          Error

let b:current_syntax = 'voll'
