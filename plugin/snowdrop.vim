scriptencoding utf-8
if exists('g:loaded_snowdrop')
  finish
endif
let g:loaded_snowdrop = 1

let s:save_cpo = &cpo
set cpo&vim


command! -bar -bang
\	SnowdropVerify
\	call snowdrop#verify(<bang>0)


command! -bar SnowdropGotoDefinition
\	call snowdrop#goto_definition_in_cursor()

nnoremap <silent> <Plug>(snowdrop-goto-definition) :<C-u>SnowdropGotoDefinition<CR>


command! -bar SnowdropEchoTypeof
\	echo snowdrop#print_type(snowdrop#typeof_in_cursor())


function! s:get_definition()
	let context = snowdrop#context_in_cursor()
	if !empty(context.definition)
		return context.definition.result_type
	elseif !empty(context.referenced)
		return context.referenced.result_type
	else
		return {}
	endif
endfunction

command! -bar SnowdropEchoResultTypeof
\	echo snowdrop#print_type(s:get_definition())
"

command! -bar SnowdropEchoIncludes
\	echo join(sort(snowdrop#current_includes()), "\n")


command! -bar SnowdropEchoClangVersion
\	echo snowdrop#get_libclang_version()


let &cpo = s:save_cpo
unlet s:save_cpo
