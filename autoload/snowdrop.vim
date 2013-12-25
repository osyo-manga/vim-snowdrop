scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! snowdrop#echoerr(str)
	echohl ErrorMsg
	echo "snowdrop.vim : " . a:str
	echohl NONE
	return -1
endfunction


let g:snowdrop#libclang_path = get(g:, "snowdrop#libclang_path", "")

let s:is_windows = has('win16') || has('win32') || has('win64') || has('win95')
let s:is_mac = has('mac') || has('macunix') || has('gui_macvim')

let g:snowdrop#libclang_file = get(g:, "snowdrop#libclang_file", "")

function! snowdrop#get_libclang_filename()
	if empty(g:snowdrop#libclang_file)
		let file = s:is_mac     ? "libclang.dylib"
\				 : s:is_windows ? "libclang.dll"
\				 : "libclang.so"
	else
		let file = g:snowdrop#libclang_file
	endif
	if empty(g:snowdrop#libclang_path)
		return file
	endif
	return g:snowdrop#libclang_path . "/" . file
endfunction


function! snowdrop#get_libclang_version(...)
	let libclang = get(a:, 1, snowdrop#get_libclang_filename())
	if empty(executable(libclang))
		return snowdrop#echoerr("Not found libclang file : " . libclang)
	endif
	if s:is_windows
		let libclang = matchstr(libclang, '.*\ze\.dll$')
	endif
	return libcall(libclang, "clang_getClangVersion", "")
endfunction



let g:snowdrop#include_paths = get(g:, "snowdrop#include_paths", {})


function! snowdrop#current_include_paths()
	let filetype = &filetype
	let paths = get(g:snowdrop#include_paths, filetype, [])
	return filter(split(&path, ',') + paths, 'isdirectory(v:val) && v:val !~ ''\./''')
endfunction


function! snowdrop#to_include_opt(paths)
	let include_opt = join(filter(a:paths, 'v:val !=# "."'), ' -I')
	if empty(include_opt)
		return ""
	endif
	return "-I" . include_opt
endfunction



let g:snowdrop#command_options = get(g:, "snowdrop#command_options", {})

let s:command_options = {
\	"cpp" : "-std=c++1y",
\}

function! s:command_option(filetype)
	return get(extend(s:command_options, get(g:, "snowdrop#command_options", {})), a:filetype, "")
endfunction


function! snowdrop#current_command_opt(...)
	let option = get(a:, 1, "")
	return snowdrop#to_include_opt(snowdrop#current_include_paths()) . " " . s:command_option(&filetype) . " " . option
endfunction



function! snowdrop#includes(context)
	return snowdrop#libclang#includes(
\		a:context.source,
\		a:context.filename,
\		get(a:context, "option")
\	)
endfunction


function! snowdrop#current_includes(...)
	return snowdrop#includes(extend(snowdrop#context#current(), get(a:, 1, {})))
endfunction


function! snowdrop#definition(context)
	return snowdrop#libclang#definition(
\		a:context.source,
\		a:context.filename,
\		get(a:context, "option"),
\		a:context.line,
\		a:context.col,
\	)
endfunction


function! snowdrop#definition_in_cursor(...)
	return snowdrop#definition(snowdrop#context#cursor(get(a:, 1, {})))
endfunction


function! snowdrop#goto_definition_in_cursor(...)
	let open_cmd = get(a:, 1, g:snowdrop#goto_definition_open_cmd)
	let context = get(a:, 2, {})
	let [filename, line, col] = snowdrop#definition_in_cursor(context)
	if empty(filename)
		echo "Not found '" . expand("<cword>") . "'."
		return
	endif
	if type(filename) == type("") && filereadable(filename)
		execut open_cmd filename
	endif
	call setpos(".", [0, line, col, 0])
endfunction


function! snowdrop#print_status(context)
	return snowdrop#libclang#print_status(
\		a:context.source,
\		a:context.filename,
\		get(a:context, "option"),
\		a:context.line,
\		a:context.col,
\	)
endfunction


function! snowdrop#print_staus_in_cursor(...)
	call snowdrop#print_status(snowdrop#context#cursor(get(a:, 1, {})))
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
