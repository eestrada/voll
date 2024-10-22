" Vim syntax file
" Language: VOLL
" Maintainer: Ethan Estrada
" Latest Revision: 21 October 2024

if exists('b:current_syntax')
  finish
endif
let b:current_syntax = 'voll'

syntax keyword vollTodo contained TODO FIXME XXX NOTE
syntax match vollComment "#.*$" contains=vollTodo

syntax match vollIdentifier "[a-zA-Z][a-zA-Z0-9_.]*" nextgroup=vollAssignment
syntax match vollAssignment "=" contained nextgroup=vollValue

" Add proper highlight for JSON style literals
syntax match vollNumber "\d\+" contained
" syntax match vollFloat ".*" contained
syntax keyword vollBoolean contained true false
syntax keyword vollNull contained null
syntax match vollString "\"[^\"]*\"" contained
syntax match vollValue ".*$" contained contains=vollNumber,vollFloat,vollBoolean,vollNull,vollString

hi def link vollTodo       Todo
hi def link vollComment    Comment
hi def link vollIdentifier Identifier
hi def link vollAssignment Operator
hi def link vollNumber     Number
" hi def link vollFloat      Float
hi def link vollBoolean    Boolean
hi def link vollNull       Constant
hi def link vollString     String
hi def link vollValue      Constant
