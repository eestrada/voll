" Vim filetype plugin
" Language:         VOLL
" Original Author:  Ethan Estrada

if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

" Set comment (formatting) related options.
setlocal commentstring=#\ %s
setlocal comments=:#
setlocal formatoptions-=t
setlocal formatoptions+=cro/q

compiler voll_sh

" Let Vim know how to disable the plug-in.
let b:undo_ftplugin = 'setlocal commentstring< comments< formatoptions< makeprg< errorformat<'
