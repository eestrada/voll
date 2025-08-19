" Vim compiler file
" Compiler:        voll.sh
" Original Author: Ethan Estrada

if exists('current_compiler')
  finish
endif
let current_compiler = 'voll_sh'

let s:cpo_save = &cpo
set cpo&vim

CompilerSet makeprg=voll.sh\ -l\ %:S
CompilerSet errorformat=%f:%l:%m,
                       \%-G%.%#

let &cpo = s:cpo_save
unlet s:cpo_save
