scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim



let s:extensions = {
\	"c"   : "c",
\	"cpp" : "cpp",
\}

function! s:extension(filetype)
	return get(extend(s:extensions, get(g:, "snowdrop#extension", {})), a:filetype, a:filetype)
endfunction


function! s:dummy_filename(filetype)
	return "snowdrop_dummy_filename." . s:extension(a:filetype)
endfunction


function! snowdrop#context#file(file, ...)
	let base = get(a:, 1, {})
	return extend(base, {
\		"filename" : a:file,
\		"source" : join(readfile(a:file), "\n"),
\	}, "keep")
endfunction


function! snowdrop#context#buffer(bufnr, ...)
	let base = get(a:, 1, {})
	return extend(base, {
\		"filename" : s:dummy_filename(getbufvar(a:bufnr, "&filetype", "")),
\		"source" : join(getbufline(a:bufnr, 1, "$"), "\n"),
\	}, "keep")
endfunction


function! snowdrop#context#current(...)
	let base = get(a:, 1, {})
	let filename = substitute(fnamemodify(bufname("%"), ":p"), '\\', '/', 'g')
	if filereadable(filename)
		let base = snowdrop#context#file(filename, base)
	else
		let base = snowdrop#context#buffer("%", base)
	endif
	return extend(base, {
\		"option" : snowdrop#current_command_opt()
\	}, "keep")
endfunction


function! snowdrop#context#cursor(...)
	let base = get(a:, 1, {})
	return extend({
\		"line" : line("."),
\		"col"  : col("."),
\	}, snowdrop#context#current(base))
endfunction


function! snowdrop#context#cpp_source(source, ...)
	let base = get(a:, 1, {})
	return extend({
\		"filename" : s:dummy_filename("cpp"),
\		"source" : a:source,
\	}, base)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
