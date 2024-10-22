" Vim syntax file
" Language: VOLL
" Maintainer: Ethan Estrada
" Latest Revision: 22 October 2024

if exists('b:current_syntax')
  finish
endif

syntax match vollStartLine /\v^/ nextgroup=vollComment,vollIdentifier
syntax match vollStartBlank /\v^[ \t]*/ nextgroup=vollComment,vollIdentifier
syntax keyword vollTodo contained TODO FIXME XXX NOTE
syntax match vollComment "\v#.*$" contained contains=vollTodo

syntax match vollIdentifier "\v[a-zA-Z][a-zA-Z0-9_.]*" contained nextgroup=vollPreAssignmentBlank
syntax match vollPreAssignmentBlank "\v[ \t]*" contained nextgroup=vollAssignment
syntax match vollAssignment "\v\=" contained nextgroup=vollValue

" Add proper highlight for JSON style literals

" TODO: support more floating point formats that are JSON compatible
syntax match vollFloat "\v\d+\.\d+" contained
syntax match vollNumber "\v\d+" contained
syntax keyword vollBoolean contained true false
syntax keyword vollNull contained null
syntax region vollString start=/\v"/ skip=/\v\\./ end=/\v"/ contained
syntax match vollValue "\v.*$" contained contains=vollFloat,vollNumber,vollBoolean,vollNull,vollString

" hi def link vollStartLine          Ignore
hi def link vollStartBlank         Ignore
hi def link vollPreAssignmentBlank Ignore
hi def link vollTodo               Todo
hi def link vollComment            Comment
hi def link vollIdentifier         Identifier
hi def link vollAssignment         Operator
hi def link vollFloat              Float
hi def link vollNumber             Number
hi def link vollBoolean            Boolean
hi def link vollNull               Constant
hi def link vollString             String
hi def link vollValue              Ignore

let b:current_syntax = 'voll'
