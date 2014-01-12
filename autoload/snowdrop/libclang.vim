scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:libclang_binding = "python"

let g:snowdrop#libclang#libclang_binding = get(g:, "snowdrop#libclang#libclang_binding", "python")

let g:snowdrop#libclang#use_libclang_bindings = get(g:, "snowdrop#libclang#use_libclang_bindings", {})


function! s:get_binding(name)
	return get(g:snowdrop#libclang#use_libclang_bindings, a:name, g:snowdrop#libclang#libclang_binding)
endfunction

function! s:binding_call(name, ...)
	return call("snowdrop#libclang#" . s:get_binding(a:name) . "#" . a:name, a:000)
endfunction


function! snowdrop#libclang#load(...)
	let libclang = get(a:, 1, snowdrop#get_libclang_filename())
	if executable(libclang) != 1
		return snowdrop#echoerr("Not found libclang : " . libclang)
	endif
endfunction

call snowdrop#libclang#load(snowdrop#get_libclang_filename())


function! snowdrop#libclang#get_library_file()
	return s:binding_call("get_library_file")
endfunction


function! snowdrop#libclang#get_clang_version()
	return s:binding_call("get_clang_version")
endfunction


function! snowdrop#libclang#includes(source, filename, option)
	return s:binding_call("includes", a:source, a:filename, a:option)
endfunction


function! snowdrop#libclang#definition(source, filename, option, line, col)
	return s:binding_call("definition", a:source, a:filename, a:option, a:line, a:col)
endfunction


function! snowdrop#libclang#print_status(source, filename, option, line, col)
	return s:binding_call("print_status", a:source, a:filename, a:option, a:line, a:col)
endfunction

function! snowdrop#libclang#context(source, filename, option, line, col)
	return s:binding_call("context", a:source, a:filename, a:option, a:line, a:col)
endfunction

function! snowdrop#libclang#code_complete(source, filename, option, line, col)
	return s:binding_call("code_complete", a:source, a:filename, a:option, a:line, a:col)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
