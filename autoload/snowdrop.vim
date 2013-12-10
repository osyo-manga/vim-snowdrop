scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let g:snowdrop#open_cmd = get(g:, "snowdrop#open_cmd", "edit")

let g:snowdrop#libclang_path = get(g:, "snowdrop#libclang_path", "")

let g:snowdrop#include_paths = get(g:, "snowdrop#include_paths", {})

let g:snowdrop#command_options = get(g:, "snowdrop#command_options", {})

let s:command_options = {
\	"cpp" : "-std=c++1y",
\}

function! s:command_option(filetype)
	return get(extend(s:command_options, get(g:, "snowdrop#command_options", {})), a:filetype, "")
endfunction


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



function! snowdrop#get_libclang_version()
	return libcall("libclang.dll", "clang_getNullCursor", "")
" 	return snowdrop#python#get_libclang_version()
endfunction



function! snowdrop#get_current_include_paths()
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


function! snowdrop#current_command_opt(...)
	let option = get(a:, 1, "")
	return snowdrop#to_include_opt(snowdrop#get_current_include_paths()) . " " . s:command_option(&filetype) . " " . option
endfunction


function! snowdrop#echoerr(str)
	echohl ErrorMsg
	echo "snowdrop.vim : "a:str
	echohl NONE
endfunction


function! snowdrop#load(libclang_path)
	if !has("python")
		call snowdrop#echoerr("Requires +python.")
		return
	endif
	if !empty(a:libclang_path) && !isdirectory(a:libclang_path)
		call snowdrop#echoerr("Not found dir : " . a:libclang_path)
		return
	endif

	call snowdrop#python#load(a:libclang_path)
endfunction


function! snowdrop#libclang_file()
	return snowdrop#python#get_library_file()
endfunction



function! snowdrop#source_from_bufnr(bufnr)
	return [
\		join(getbufline(a:bufnr, 1, "$"), "\n"),
\		s:dummy_filename(getbufvar(a:bufnr, "&filetype", ""))
\	]
endfunction


function! snowdrop#source_from_file(file)
	return [
\		join(readfile(a:file), "\n"),
\		substitute(fnamemodify(a:file, ":p"), '\\', '/', 'g'),
\	]
endfunction


function! snowdrop#source(expr)
	let expr = bufnr(a:expr)
	return type(expr) == type(0) ? snowdrop#source_from_bufnr(expr)
\		 : type(expr) == type("") && filereadable(expr) ? snowdrop#source_from_file(expr)
\		 : []
endfunction
 

function! snowdrop#current_includes(...)
	let option = snowdrop#current_command_opt() . " " . get(a:, 1, "")
	return snowdrop#includes(snowdrop#source("%"), option)
endfunction


function! snowdrop#includes(source, ...)
	if empty(a:source)
		return
	endif
	let option = get(a:, 1, "")
	return snowdrop#python#includes(a:source[0], a:source[1], option)
endfunction


function! snowdrop#definition(source, line, col, ...)
	if empty(a:source)
		return
	endif
	let option = get(a:, 1, "")
	return snowdrop#python#definition(a:source[0], a:source[1], option, a:line, a:col)
endfunction


function! snowdrop#definition_in_cursor(...)
	let option = snowdrop#current_command_opt() . " " . get(a:, 1, "")
	let [line, col, dummy] = getpos(".")[1:]
	let [filename, line, col] = snowdrop#definition(snowdrop#source("%"), line, col, option)
	if filename == s:dummy_filename(&filetype)
		return [empty(bufname("%")) ? bufnr("%") : bufname("%"), line, col]
	else
		return [filename, line, col]
	endif
endfunction


let g:snowdrop#goto_definition_open_cmd = get(g:, "snowdrop#goto_definition_open_cmd", "edit")

function! snowdrop#goto_definition_in_cursor(...)
	let option = get(a:, 1, "")
	let open_cmd = get(a:, 2, g:snowdrop#goto_definition_open_cmd)
	let [filename, line, col] = snowdrop#definition_in_cursor(option)
	if empty(filename)
		echo "Not found '" . expand("<cword>") . "'."
		return
	endif
	if type(filename) == type("") && filereadable(filename)
		execut open_cmd filename
	endif
	call setpos(".", [0, line, col, 0])
endfunction


function! snowdrop#print_status(source, line, col, ...)
	if empty(a:source)
		return
	endif
	let option = get(a:, 1, "")
return snowdrop#python#print_status(a:source[0], a:source[1], option, a:line, a:col)
endfunction


function! snowdrop#print_staus_in_cursor(...)
	let option = snowdrop#current_command_opt() . " " . get(a:, 1, "")
	let [line, col, dummy] = getpos(".")[1:]
	call snowdrop#print_status(snowdrop#source("%"), line, col, option)
endfunction



call snowdrop#load(g:snowdrop#libclang_path)


let &cpo = s:save_cpo
unlet s:save_cpo
