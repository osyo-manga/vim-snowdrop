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
		call snowdrop#echoerr("Not found libclang file : " . libclang)
		return snowdrop#echoerr("Please set 'g:snowdrop#libclang_path'")
	endif
	if s:is_windows
		let libclang = matchstr(libclang, '.*\ze\.dll$')
	endif
	return libcall(libclang, "clang_getClangVersion", "")
endfunction


function! snowdrop#check()
	try
		call snowdrop#check#all()
	catch
	endtry
endfunction


let g:snowdrop#include_paths   = get(g:, "snowdrop#include_paths", {})
let g:snowdrop#command_options = get(g:, "snowdrop#command_options", {})


function! snowdrop#current_command_option()
	return snowdrop#command_option#bufnr(bufnr("%"))
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


function! snowdrop#context(context)
	return snowdrop#libclang#context(
\		a:context.source,
\		a:context.filename,
\		get(a:context, "option"),
\		a:context.line,
\		a:context.col,
\	)
endfunction


function! snowdrop#context_in_cursor(...)
	return snowdrop#context(snowdrop#context#cursor(get(a:, 1, {})))
endfunction


function! snowdrop#definition(context)
	let definition = snowdrop#context(a:context).definition
	if empty(definition)
		return ["", 0, 0]
	endif
	let location = definition.location
	return [location.file, location.line, location.column]
" 	return snowdrop#libclang#definition(
" \		a:context.source,
" \		a:context.filename,
" \		get(a:context, "option"),
" \		a:context.line,
" \		a:context.col,
" \	)
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


function! snowdrop#typeof(context)
	let result = snowdrop#context(a:context)
	if empty(result)
		return {}
	endif
	if result.kind ==# "MEMBER_REF_EXPR" && result.definition.type.kind ==# "FUNCTIONPROTO"
		return result.definition.type
	else
		return result.type
	endif

" 	if result.kind ==# "MEMBER_REF_EXPR" && result.definition.type.kind ==# "FUNCTIONPROTO"
" 		return result.definition.result_type
" 	elseif result.type.kind == "FUNCTIONPROTO"
" 		return result.result_type
" 	else
" 		return result.type
" 	endif
endfunction


function! snowdrop#typeof_in_cursor(...)
	return snowdrop#typeof(snowdrop#context#cursor(get(a:, 1, {})))
endfunction


function! snowdrop#code_complete(context)
	return snowdrop#libclang#code_complete(
\		a:context.source,
\		a:context.filename,
\		get(a:context, "option"),
\		a:context.line,
\		a:context.col,
\	)
endfunction


function! snowdrop#code_complete_in_cursor(...)
	let context = snowdrop#context#cursor(get(a:, 1, {}))
	let context.col += 1
	return snowdrop#code_complete(context)
endfunction


function! snowdrop#code_complete_near_cursor(...)
	return snowdrop#code_complete(snowdrop#context#code_complete(get(a:, 1, {})))
endfunction


function! snowdrop#print_type(type)
	if a:type.spelling ==# a:type.canonical_spelling
		return printf("type : %s", a:type.spelling)
	endif
	return printf("type      : %s\n", a:type.spelling)
\		.  printf("canonical : %s", a:type.canonical_spelling)
endfunction


function! snowdrop#ballonexpr_typeof()
	let type = snowdrop#typeof(snowdrop#context#buffer(v:beval_bufnr, {
\		"line" : v:beval_lnum,
\		"col"  : v:beval_col,
\	}))
	return snowdrop#print_type(type)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
