scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:root = substitute(expand("<sfile>:p:h"), '\\', '/', "g")
let s:test_dir  = s:root . "/verify_files"

function! s:test_file(...)
	let base = get(a:, 1, {})
	return snowdrop#context#file(s:test_dir . "/test.cpp", base, { "option" : "-I" . s:test_dir } )
endfunction


function! s:verify(verifyer, output)
	try
		let result = snowdrop#verify#{ a:verifyer }()
	catch
		let result = 0
		call snowdrop#debug#print(a:verifyer, v:throwpoint . " " . v:exception)
		if a:output
			echo v:throwpoint . " " . v:exception
		endif
	endtry
	if result
		return printf("[Success] %s", a:verifyer)
	else
		return printf("[Failure] %s", a:verifyer)
	endif
endfunction


function! snowdrop#verify#load()
	let v  = snowdrop#get_libclang_version()
	let v2 = snowdrop#libclang#get_clang_version()
	return v != "" && v2 != "" && v == v2
endfunction


function! snowdrop#verify#includes()
	let result = sort(snowdrop#includes(s:test_file()))
	return len(result) == 2
\		&& fnamemodify(result[0], ":t") ==# "test.h"
\		&& fnamemodify(result[1], ":t") ==# "test2.h"
endfunction


function! snowdrop#verify#diagnostics()
	let result = snowdrop#diagnostics(s:test_file())
	return sort(map(result, "v:val.location.line")) == [6, 8]
endfunction


function! snowdrop#verify#typeof()
	let result = snowdrop#typeof(s:test_file({ "line" : 6, "col" : 2 }))
	return result.spelling is# "X"
endfunction


function! snowdrop#verify#code_complete()
	let result = snowdrop#code_complete_in_cursor(s:test_file({"line" : 7, "col" : 3 }))
	return sort(map(result, "v:val.complete_word")) == ['X', 'func', 'operator=', 'value', '~X']
endfunction


function! snowdrop#verify#all(output)
	echo snowdrop#get_libclang_version()
	let result = join([
\		s:verify("load", a:output),
\		s:verify("includes", a:output),
\		s:verify("diagnostics", a:output),
\		s:verify("typeof", a:output),
\		s:verify("code_complete", a:output),
\	], "\n")
	echo result
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
