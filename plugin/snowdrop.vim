scriptencoding utf-8
if exists('g:loaded_snowdrop')
  finish
endif
let g:loaded_snowdrop = 1

let s:save_cpo = &cpo
set cpo&vim


command! -bar SnowdropGotoDefinition
\	call snowdrop#goto_definition_in_cursor()

nnoremap <silent> <Plug>(snowdrop-goto-definition) :<C-u>SnowdropGotoDefinition<CR>


function! s:print_type(type)
	if a:type.spelling ==# a:type.canonical_spelling
		return printf("type : %s", a:type.spelling)
	endif
	return printf("type      : %s\n", a:type.spelling)
\		.  printf("canonical : %s", a:type.canonical_spelling)
endfunction

command! -bar SnowdropEchoTypeof
\	echo s:print_type(snowdrop#typeof_in_cursor())


command! -bar SnowdropEchoResultTypeof
\	echo s:print_type(get(get(snowdrop#context_in_cursor(), "definition", {}), "result_type"))


command! -bar SnowdropEchoIncludes
\	echo join(sort(snowdrop#current_includes()), "\n")


command! -bar SnowdropEchoClangVersion
\	echo snowdrop#get_libclang_version()


let &cpo = s:save_cpo
unlet s:save_cpo
