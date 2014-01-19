scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! s:diag_to_qf(diag)
	let result = {
\		"type"     : a:diag.severity == 3 ? "E"
\				   : a:diag.severity == 2 ? "W"
\				   : "",
\		"text"     : a:diag.spelling,
\	}
	if empty(a:diag.location)
		return result
	endif
	let result.bufnr = snowdrop#context#bufnr(a:diag.location.file)
	let result.lnum     = a:diag.location.line
	let result.col      = a:diag.location.column
	return result
endfunction


function! snowdrop#diagnostics#to_qflist(diagnostics)
	return map(a:diagnostics, "s:diag_to_qf(v:val)")
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
