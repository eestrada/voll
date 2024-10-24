" Vim plugin
" Original Author: Ethan Estrada
" Last Change:     23 October 2024

if has('win32')
  let s:path_sep = ';'
else
  let s:path_sep = ':'
endif

" Folder in which script resides: (not safe for symlinks)
let s:path = simplify(expand('<sfile>:p:h') . '/../../bin')

" prepend script bin path
let $PATH = s:path . s:path_sep . $PATH
