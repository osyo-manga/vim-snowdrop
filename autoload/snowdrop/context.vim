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
\		"option" : snowdrop#command_option#file(a:file)
\	}, "keep")
endfunction


function! snowdrop#context#buffer(bufnr, ...)
	let base = get(a:, 1, {})
	return extend(base, {
\		"filename" : s:dummy_filename(getbufvar(a:bufnr, "&filetype", "")),
\		"source" : join(getbufline(a:bufnr, 1, "$"), "\n"),
\		"option" : snowdrop#command_option#bufnr(a:bufnr)
\	}, "keep")
endfunction


function! snowdrop#context#current(...)
	let base = get(a:, 1, {})
	let filename = substitute(fnamemodify(bufname("%"), ":p"), '\\', '/', 'g')
	if filereadable(filename)
		if &modified
			let base = snowdrop#context#buffer("%", base)
			let base.filename = filename
		else
			let base = snowdrop#context#file(filename, base)
		endif
	else
		let base = snowdrop#context#buffer("%", base)
	endif
	return extend(base, {
\		"option" : snowdrop#current_command_option()
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


function! snowdrop#context#code_complete(...)
	let base = get(a:, 1, {})
	let pos = searchpos('\(->\)\|\.\|\(::\)\|;\|^', 'cbWen')
	return extend({
\		"line" : pos[0],
\		"col"  : pos[1] + 1,
\	}, snowdrop#context#current(base))
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
