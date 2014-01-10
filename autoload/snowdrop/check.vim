scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:root = expand("<sfile>:p:h")
let s:test_file = s:root . "/check_files/test.cpp"


function! s:message(result, check)
	if a:result
		return printf("[Success] %s", a:check)
	else
		return printf("[Failure] %s", a:check)
	endif
endfunction


function! snowdrop#check#load()
	return snowdrop#get_libclang_version() == snowdrop#libclang#get_clang_version()
endfunction


function! snowdrop#check#includes()
	let result = sort(snowdrop#includes(snowdrop#context#file(s:test_file)))
	return len(result) == 2
\		&& fnamemodify(result[0], ":t") ==# "test.h"
\		&& fnamemodify(result[1], ":t") ==# "test2.h"
endfunction


function! snowdrop#check#typeof()
	let result = snowdrop#typeof(snowdrop#context#file(s:test_file, { "line" : 6, "col" : 2 }))
	return result.spelling is# "X"
endfunction


function! snowdrop#check#code_complete()
	let result = snowdrop#code_complete_in_cursor(snowdrop#context#file(s:test_file, { "line" : 7, "col" : 3 }))
	return sort(map(result, "v:val.complete_word")) == ['X', 'func', 'operator=', 'value', '~X']
endfunction


function! snowdrop#check#all()
	echo snowdrop#get_libclang_version()
	let result = join([
\		s:message(snowdrop#check#load(), "load"),
\		s:message(snowdrop#check#includes(), "includes"),
\		s:message(snowdrop#check#typeof(), "typeof"),
\		s:message(snowdrop#check#code_complete(), "code_complete"),
\	], "\n")
	echo result
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
