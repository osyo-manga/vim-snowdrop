scriptencoding utf-8
if exists('g:loaded_snowdrop')
  finish
endif
let g:loaded_snowdrop = 1

let s:save_cpo = &cpo
set cpo&vim


command! -bar SnowdropGotoDefinition
\	call snowdrop#goto_definition_in_cursor()

nnoremap <Plug>(snowdrop-goto-definition) :<C-u>SnowdropGotoDefinition<CR>


function! s:typeof()
	let type = snowdrop#typeof_in_cursor()
	if type.spelling ==# type.canonical_spelling
		return printf("type : %s", type.spelling)
	endif
	return printf("type      : %s\ncanonical : %s", type.spelling, type.canonical_spelling)
endfunction
command! -bar SnowdropEchoTypeof
\	echo s:typeof()


let &cpo = s:save_cpo
unlet s:save_cpo
