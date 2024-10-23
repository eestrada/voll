" Vim syntax file
" Language: VOLL
" Maintainer: Ethan Estrada
" Latest Revision: 22 October 2024

if exists('b:current_syntax')
  finish
endif

syntax match vollStartBlank /\v^[ \t]*/ nextgroup=vollComment,vollIdentifier
syntax keyword vollTodo contained TODO FIXME XXX NOTE
syntax match vollComment "\v#.*$" contained contains=vollTodo

syntax match vollIdentifier "\v[a-zA-Z][a-zA-Z0-9_.]*" contained nextgroup=vollPreAssignmentBlank
syntax match vollPreAssignmentBlank "\v[ \t]*" contained nextgroup=vollAssignment
syntax match vollAssignment "\v\=" contained skipwhite nextgroup=vollJsonFloat,vollJsonNumber,vollJsonBoolean,vollJsonNull,vollJsonString

" Add proper highlight for JSON style literals

" XXX: Types with `Json` in the name are parsed like JSON to visually indicate what is JSON compatible and what is not.

" TODO: support more floating point formats that are JSON compatible
syntax match vollJsonFloat "\v-?\d+\.\d+[ \t]*$" contained
syntax match vollJsonNumber "\v-?\d+[ \t]*$" contained
syntax keyword vollJsonBoolean contained true false
syntax keyword vollJsonNull contained null

" FIXME: JSON strings do not properly support all JSON escapes yet.
syntax region vollJsonString start=/\v"/ skip=/\v\\./ end=/\v"[ \t]*$/ oneline contained

hi def link vollStartBlank         Ignore
hi def link vollPreAssignmentBlank Ignore
hi def link vollTodo               Todo
hi def link vollComment            Comment
hi def link vollIdentifier         Identifier
hi def link vollAssignment         Operator
hi def link vollJsonFloat          Float
hi def link vollJsonNumber         Number
hi def link vollJsonBoolean        Boolean
hi def link vollJsonNull           Constant
hi def link vollJsonString         String

let b:current_syntax = 'voll'
