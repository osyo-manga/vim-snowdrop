scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim



function! snowdrop#context#is_dummy_file(filename)
	let filename = fnamemodify(a:filename, ":t")
	return filename =~ '^snowdrop_dummy_filename_bufnr\d\+\.\S\+$'
endfunction


function! snowdrop#context#bufnr(filename)
	if !snowdrop#context#is_dummy_file(a:filename)
		return bufnr(a:filename)
	endif
	let filename = fnamemodify(a:filename, ":t")
	return str2nr(matchstr(filename, '^snowdrop_dummy_filename_bufnr\zs\d\+\ze\.\S\+$'))
endfunction

" function! snowdrop#context#dummy_file_to_bufnr(filename)
" 	if !snowdrop#context#is_dummy_file(a:filename)
" 		return -1
" 	endif
" 	let filename = fnamemodify(a:filename, ":t")
" 	return char2nr(matchstr(filename, '^snowdrop_dummy_filename_bufnr\(\d\+\)\.\S\+$'))
" endfunction


let s:extensions = {
\	"c"   : "c",
\	"cpp" : "cpp",
\}

function! s:extension(filetype)
	return get(extend(s:extensions, get(g:, "snowdrop#extension", {})), a:filetype, a:filetype)
endfunction


function! s:dummy_filename(bufnr)
	let filetype = getbufvar(a:bufnr, "&filetype", "")
	return printf("snowdrop_dummy_filename_bufnr%d.%s", a:bufnr, s:extension(filetype))
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
\		"filename" : s:dummy_filename(bufnr(a:bufnr)),
\		"source" : join(getbufline(a:bufnr, 1, "$"), "\n"),
\		"option" : snowdrop#command_option#bufnr(a:bufnr)
\	}, "keep")
endfunction


function! snowdrop#context#current(...)
	let base = get(a:, 1, {})
	let base = extend(base, {
\		"option" : snowdrop#current_command_option()
\	}, "keep")
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
	return base
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


function! snowdrop#context#comment_out_include_preprocessor(context)
	let is_include = '^\s*#\s*include'
	let a:context.source = join(map(split(a:context.source, "\n"), "v:val =~ is_include ? '// ' . v:val : v:val"), "\n")
	return a:context
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
