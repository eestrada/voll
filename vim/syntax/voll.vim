" Vim syntax file
" Language:         VOLL
" Original Author:  Ethan Estrada
" Latest Change:    23 October 2024

if exists('b:current_syntax')
  finish
endif

syn include @Json syntax/json.vim

syn match vollLineStart /\v^[ \t]*/ nextgroup=vollComment,vollIdentifier
syn keyword vollTodo contained TODO FIXME XXX NOTE
syn match vollComment "\v#.*$" contained contains=vollTodo,@Spell

syn match vollIdentifier "\v[a-zA-Z][a-zA-Z0-9_.]*" contained skipwhite nextgroup=vollAssignment,vollAssignmentError,vollIdentifierError
syn match vollIdentifierError "\v[^a-zA-Z0-9_.= \t]+" contained nextgroup=vollAssignment,vollAssignmentError,vollIdentifier
syn match vollAssignment "\v\=" contained skipwhite nextgroup=jsonNull,jsonBoolean,jsonNumber,jsonString
syn match vollAssignmentError "\v[^=]+$" contained

" FIXME: Since including JSON syntax directly, this is unused.
" Only shown if extra text trails a JSON literal.
syn match vollJsonError "\v[^ \t].*$" contained

hi def link vollTodo               Todo
hi def link vollComment            Comment
hi def link vollIdentifier         Identifier
hi def link vollAssignment         Operator
hi def link jsonNumber             Number
hi def link jsonBoolean            Boolean
hi def link jsonNull               Constant
hi def link jsonString             String
hi def link vollJsonError          Error
hi def link vollIdentifierError    Error
hi def link vollAssignmentError    Error

let b:current_syntax = 'voll'
