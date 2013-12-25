scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:libclang_binding = "python"

function! s:binding_call(name, ...)
	return call("snowdrop#libclang#" . s:libclang_binding . "#" . a:name, a:000)
endfunction


function! snowdrop#libclang#load(...)
	let libclang = get(a:, 1, snowdrop#get_libclang_filename())
	if !has("python")
		call snowdrop#echoerr("Requires +python.")
		return
	endif
	if executable(libclang) != 1
		call snowdrop#echoerr("Not found libclang : " . libclang)
		return
	endif

	call s:binding_call("load", libclang)
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


let &cpo = s:save_cpo
unlet s:save_cpo
