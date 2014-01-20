scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


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


function! snowdrop#ftplugin#command(filetype)
	command! -buffer -bar SnowdropEchoIncludes
\		echo join(sort(snowdrop#current_includes()), "\n")

	command! -buffer -bar SnowdropErrorCheck
\		call setqflist(snowdrop#diagnostics#to_qflist(snowdrop#current_diagnostics())) | cwindow

	command! -buffer -bar SnowdropGotoDefinition
\		call snowdrop#goto_definition_in_cursor()

	command! -buffer -bar SnowdropEchoTypeof
\		echo snowdrop#print_type(snowdrop#typeof_in_cursor())

	command! -buffer -bar SnowdropEchoResultTypeof
\		echo snowdrop#print_type(s:get_definition())

	return "
\		delcommand SnowdropEchoIncludes
\|		delcommand SnowdropErrorCheck
\|		delcommand SnowdropGotoDefinition
\|		delcommand SnowdropEchoTypeof
\|		delcommand SnowdropEchoResultTypeof
\	"
endfunction


function! snowdrop#ftplugin#mapping(filetype)
	nnoremap <buffer><silent> <Plug>(snowdrop-goto-definition)
\		:<C-u>SnowdropGotoDefinition<CR>

	return "nunmap <buffer> <Plug>(snowdrop-goto-definition)"
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
