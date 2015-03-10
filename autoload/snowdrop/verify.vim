scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:root = substitute(expand("<sfile>:p:h"), '\\', '/', "g")
let s:test_dir  = s:root . "/verify_files"

let s:List = snowdrop#vital().import("Data.List")


function! s:test_file(...)
	let base = get(a:, 1, {})
	return snowdrop#context#file(s:test_dir . "/test.cpp", base, { "option" : "-std=c++03 -I" . s:test_dir } )
endfunction


function! s:print(success, output)
	if a:success
		return printf("[Success] %s", a:output)
	else
		return printf("[Failure] %s", a:output)
	endif
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
	return s:print(result, a:verifyer)
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
	return sort(map(result, "v:val.location.line")) == [17, 19]
endfunction


function! snowdrop#verify#typeof()
	let result = snowdrop#typeof(s:test_file({ "line" : 17, "col" : 2 }))
	return result.spelling is# "X"
endfunction


function! snowdrop#verify#code_complete()
	let result = snowdrop#code_complete_in_cursor(s:test_file({"line" : 18, "col" : 3 }))
	return s:List.uniq(sort(map(result, "v:val.complete_word"))) == ['X', 'func', 'operator=', 'value', '~X']
endfunction


function! snowdrop#verify#all(output)
	echo snowdrop#get_libclang_version()
	echo s:print(has("python"), "+python")
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
