scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let s:source = {
\	"name" : "snowdrop/includes",
\	"description" : "included header files",
\}

function! s:source.gather_candidates(args, context)
	let bufnr = unite#get_current_unite().prev_bufnr
	return map(snowdrop#includes(snowdrop#context#buffer(bufnr)), '{
\		"word" : v:val,
\		"kind" : "file",
\		"action__path" : v:val,
\	}')
endfunction


function! unite#sources#snowdrop_includes#define()
	return s:source
endfunction


if expand("%:p") == expand("<sfile>:p")
	call unite#define_source(s:source)
endif


let &cpo = s:save_cpo
unlet s:save_cpo
