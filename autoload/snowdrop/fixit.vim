scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! s:region_search_pattern(first, last, pattern)
	if a:first == a:last
		return printf('\%%%dl\%%%dc', a:first[0], a:first[1])
	elseif a:first[0] == a:last[0]
		return printf('\%%%dl\%%>%dc%s\%%<%dc', a:first[0], a:first[1]-1, a:pattern, a:last[1]+1)
	elseif a:last[0] - a:first[0] == 1
		return  printf('\%%%dl%s\%%>%dc', a:first[0], a:pattern, a:first[1]-1)
\		. "\\|" . printf('\%%%dl%s\%%<%dc', a:last[0], a:pattern, a:last[1]+1)
	else
		return  printf('\%%%dl%s\%%>%dc', a:first[0], a:pattern, a:first[1]-1)
\		. "\\|" . printf('\%%>%dl%s\%%<%dl', a:first[0], a:pattern, a:last[0])
\		. "\\|" . printf('\%%%dl%s\%%<%dc', a:last[0], a:pattern, a:last[1]+1)
	endif
endfunction


function! s:replace_current(start, end, value)
	let pattern = s:region_search_pattern(a:start, a:end, '.*')
	execute printf("%%s/%s/%s/g", pattern, a:value)
endfunction


function! snowdrop#fixit#from_fixit(fixit)
	let start = a:fixit.range.start
	let end   = a:fixit.range.end
	if snowdrop#context#is_dummy_file(start.file)
		let bufnr = snowdrop#context#bufnr(start.file)
	else
		let bufnr = bufnr(start.file)
	endif
	if bufnr == bufnr("%")
		call s:replace_current([start.line, start.column], [end.line, end.column], a:fixit.value)
	endif
endfunction


function! snowdrop#fixit#from_diagnostic(diag)
	return map(reverse(a:diag.fixits), "snowdrop#fixit#from_fixit(v:val)")
endfunction


function! snowdrop#fixit#from_diagnostics(diagnostics)
	return map(reverse(a:diagnostics), "snowdrop#fixit#from_diagnostic(v:val)")
endfunction


function! snowdrop#fixit#current(...)
	let context = extend({ "line" : 0, "col" : 0 }, get(a:, 1, {}))
	return snowdrop#fixit#from_diagnostics(snowdrop#diagnostics(snowdrop#context#current(context)))
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
