scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:root = expand("<sfile>:p:h")
let s:test_file = s:root . "/check_files/test.cpp"
" echo s:test_source


function! s:message(result, check)
	if a:result
		return printf("[Success] %s", a:check)
	else
		return printf("[Failure] %s", a:check)
	endif
endfunction


function! snowdrop#check#version()
	return snowdrop#get_libclang_version() == snowdrop#libclang#get_clang_version()
endfunction


function! snowdrop#check#includes()
	let result = snowdrop#includes(snowdrop#context#file(s:test_file))
	return len(result) == 2
\		&& fnamemodify(result[0], ":t") ==# "test2.h"
\		&& fnamemodify(result[1], ":t") ==# "test.h"
endfunction


function! snowdrop#check#typeof()
	let result = snowdrop#typeof(snowdrop#context#file(s:test_file, { "line" : 6, "col" : 2 }))
	return result.spelling is# "X"
endfunction


function! snowdrop#check#all()
	let result = join([
\		s:message(snowdrop#check#version(), "version"),
\		s:message(snowdrop#check#includes(), "includes"),
\		s:message(snowdrop#check#typeof(), "typeof"),
\	], "\n")
	echo result
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
