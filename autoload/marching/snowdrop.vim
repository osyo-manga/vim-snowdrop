scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! marching#snowdrop#complete(context)
	echo "marching completion start"
	let completion = snowdrop#code_complete_in_cursor({
\		"line" : a:context.pos[0],
\		"col"  : a:context.pos[1] - 1,
\	})
	call filter(completion, "v:val.is_available")
	return map(completion, '{
\		"word" : v:val.complete_word,
\		"abbr" : v:val.info . " -> " . v:val.result_type,
\		"dup"  : g:marching_enable_dup
\	}')
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
