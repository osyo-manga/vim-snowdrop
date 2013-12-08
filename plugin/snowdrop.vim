scriptencoding utf-8
if exists('g:loaded_snowdrop')
  finish
endif
let g:loaded_snowdrop = 1

let s:save_cpo = &cpo
set cpo&vim


command! -bar SnowdropGotoDefinitionInCursor
\	call snowdrop#goto_definition_in_cursor()


let &cpo = s:save_cpo
unlet s:save_cpo
