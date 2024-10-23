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
syntax match vollAssignment "\v\=" contained skipwhite nextgroup=vollJsonString,vollValue

" Add proper highlight for JSON style literals

" XXX: Types with `Json` in the name are parsed like JSON to visually indicate what is JSON compatible and what is not.

" TODO: support more floating point formats that are JSON compatible
syntax match vollJsonFloat "\v-?\d+\.\d+" contained
syntax match vollJsonNumber "\v-?\d+" contained
syntax keyword vollJsonBoolean contained true false
syntax keyword vollJsonNull contained null

" FIXME: JSON strings embedded in a vollValue are highlighted when they should not be.
" FIXME: JSON strings do not properly support all JSON escapes yet.
syntax region vollJsonString start=/\v"/ skip=/\v\\./ end=/\v"/ oneline contained

" Anything that isn't JSON compatible is lumped into a single, all
" encompassing value type.
syntax match vollValue "\v.*$" contained contains=vollJsonFloat,vollJsonNumber,vollJsonBoolean,vollJsonNull,vollJsonString

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
hi def link vollValue              Special

let b:current_syntax = 'voll'
