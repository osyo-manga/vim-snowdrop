scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:P = vital#of('snowdrop').import('ProcessManager')


let g:snowdrop#libclang#python_interpreter#command = get(g:, "snowdrop#libclang#python_interpreter#command", "python")


let s:plugin_root = substitute(expand("<sfile>:p:h:h:h:h"), '\\', '/', 'g')
let s:python_module_path = s:plugin_root . "/snowdrop/python"


function! s:escape_backslash(str)
	return substitute(substitute(a:str, '\\', '\\\\', "g"), "\n", '\\n', "g")
endfunction


function! snowdrop#libclang#python_interpreter#load(libclang)
 	if !executable(g:snowdrop#libclang#python_interpreter#command)
		return snowdrop#echoerr(printf("Requires %s.", g:snowdrop#libclang#python_interpreter#command))
	endif

	if !exists("s:_python")
		call s:python().post("import sys")
		call s:python().post(printf('sys.path.append("%s")', s:python_module_path))
		call s:python().post("import snowdrop")
	else
		call s:python().post("reload(snowdrop)")
	endif

	let path = fnamemodify(a:libclang, ":h")
	let file = fnamemodify(a:libclang, ":t")
	call s:python().post("snowdrop.set_library_path(" . string(path) . ")")
endfunction


function! snowdrop#libclang#python_interpreter#get_library_file()
	return eval(s:python().get("snowdrop.get_library_file()"))
endfunction


function! snowdrop#libclang#python_interpreter#get_clang_version()
	return eval(s:python().get("snowdrop.get_clang_version()"))
endfunction


function! snowdrop#libclang#python_interpreter#includes(source, filename, option)
	let option = snowdrop#command_option#split(a:option)
	let source =  s:escape_backslash(a:source)
	let result = s:pyfunc("snowdrop.includes", [
\		source,
\		option,
\		a:filename,
\	])

	if empty(result)
		return []
	endif
	call remove(result, index(result, a:filename))
	return result
endfunction


function! snowdrop#libclang#python_interpreter#diagnostics(source, filename, option)
	let option = snowdrop#command_option#split(a:option)
	let source = s:escape_backslash(a:source)
	return s:pyfunc("snowdrop.diagnostics", [
\		source,
\		option,
\		a:filename,
\	])
endfunction


function! snowdrop#libclang#python_interpreter#context(source, filename, option, line, col)
	let option = snowdrop#command_option#split(a:option)
	let source = s:escape_backslash(a:source)
	return s:pyfunc("snowdrop.context", [
\		source,
\		a:filename,
\		option,
\		a:line,
\		a:col,
\	])
endfunction


function! snowdrop#libclang#python_interpreter#code_complete(source, filename, option, line, col)
	let option = snowdrop#command_option#split(a:option)
	let source = s:escape_backslash(a:source)
	return s:pyfunc("snowdrop.code_complete", [
\		source,
\		a:filename,
\		option,
\		a:line,
\		a:col,
\	])
endfunction





function! s:pyfunc(func, args)
	call snowdrop#debug#print("python_interpreter " . "s:pyfunc " . a:func, a:args)

	let tempfile = tr(tempname(), '\', '/')
	let func = a:func . "(" . join(map(a:args, "string(v:val)"), ",") . ")"
	call s:python().get(printf('f = open("%s", "w"); f.write(str(%s)); f.close();', tempfile, func))
	return eval(readfile(tempfile)[0])
" 	return s:python().get(a:func . "(" . join(map(a:args, "string(v:val)"), ",") . ")")
endfunction


function! s:process(label, command)
	let self = {
\		"label" :  a:label,
\		"is_got" : 0,
\		"command" : a:command,
\		"endpattern" : '>>>'
\	}

	function! self.start()
		call s:P.touch(self.label, self.command . " -i")
	endfunction

	function! self.status()
		return s:P.status(self.label)
	endfunction

	function! self.kill()
		return s:P.kill(self.label)
	endfunction

	function! self.post(expr, ...)
		let wait = get(a:, 1, 30)
		if !self.is_got
" 			call self.debug(s:P.read_wait_end(self.label, [self.endpattern]))
			call self.debug(s:P.read_wait(self.label, wait, [self.endpattern]))
		endif
		let self.is_got = 0
		call s:P.writeln(self.label, a:expr)
	endfunction

	function! self.get(...)
		let expr = get(a:, 1, "")
		let wait = get(a:, 2, 30)
		if expr != ""
			call self.post(expr)
		endif
" 		let result = self.debug(s:P.read_wait_end(self.label, [self.endpattern]))
		let result = self.debug(s:P.read_wait(self.label, wait, [self.endpattern]))
		if result[2] ==# "matched"
			let self.is_got = 1
		endif
		return self.filter(result[0])
	endfunction

	function! self.filter(data)
		return a:data
	endfunction

	function! self.debug(data)
		return a:data
	endfunction

	call self.start()

	return self
endfunction


function! s:python()
	if exists("s:_python")
		return s:_python
	endif

	let self = s:process("snowdrop", g:snowdrop#libclang#python_interpreter#command)

	function! self.debug(data)
		call snowdrop#debug#print("snowdrop python_interpreter", a:data)
" 		echo iconv(a:data[1], "sjis", &enc)
		return a:data
	endfunction

	function! self.filter(data)
		return substitute(a:data, "[\r\n\\|\n]", "", "g")
	endfunction

	let s:_python = self
	return s:_python
endfunction


function! snowdrop#libclang#python_interpreter#kill()
	if exists("s:_python")
		call s:python().kill()
		unlet s:_python
	endif
endfunction


augroup snowdrop-python-interpreter
	autocmd!
	autocmd VimLeave * call snowdrop#libclang#python_interpreter#kill()
augroup END



if expand("%:p") == expand("<sfile>:p")
	call snowdrop#libclang#python_interpreter#kill()
endif


call snowdrop#libclang#python_interpreter#load(snowdrop#get_libclang_filename())


let &cpo = s:save_cpo
unlet s:save_cpo
