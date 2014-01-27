scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:plugin_root = substitute(expand("<sfile>:p:h:h:h:h"), '\\', '/', 'g')
let s:python_module_path = s:plugin_root . "/snowdrop/python"


function! s:import(path, module)
	if get(s:, "is_loaded", 0)
		execute printf("py reload(%s)", a:module)
	endif
	let cwd = getcwd()
	execute "lcd" fnameescape(a:path)
	lcd
	try
		execute "py import" a:module
	finally
		execute "lcd" fnameescape(cwd)
	endtry
endfunction


function! s:import(path, module)
	py import sys
	execute printf('python sys.path.insert(0, "%s")', a:path)
	if get(s:, "is_loaded", 0)
		execute printf("py reload(%s)", a:module)
	endif
	try
		execute "py import" a:module
	finally
		execute printf('python sys.path.remove("%s")', a:path)
	endtry
endfunction


function! snowdrop#libclang#python#load(libclang)
 	if !has("python")
		return snowdrop#echoerr("Requires +python.")
	endif

	py import vim

	call s:import(s:python_module_path, "snowdrop")
	call s:import(s:python_module_path, "snowdrop.libclang")

	let path = fnamemodify(a:libclang, ":h")
	let file = fnamemodify(a:libclang, ":t")
	py snowdrop.set_library_path( vim.eval("path") )

	let s:is_loaded = 1
endfunction


function! snowdrop#libclang#python#get_library_file()
	return pyeval('snowdrop.get_library_file()')
endfunction


function! snowdrop#libclang#python#get_clang_version()
	return pyeval('snowdrop.get_clang_version()')
endfunction


function! snowdrop#libclang#python#includes(source, filename, option)
	let option = snowdrop#command_option#split(a:option)
	let result = pyeval('snowdrop.includes(
\		vim.eval("a:source"),
\		vim.eval("option"),
\		vim.eval("a:filename")
\	)')
	if empty(result)
		return []
	endif
	call remove(result, index(result, a:filename))
	return result
endfunction


function! snowdrop#libclang#python#diagnostics(source, filename, option)
	let option = snowdrop#command_option#split(a:option)
	return pyeval('snowdrop.diagnostics(
\		vim.eval("a:source"),
\		vim.eval("option"),
\		vim.eval("a:filename")
\	)')
endfunction


function! snowdrop#libclang#python#context(source, filename, option, line, col)
	let option = snowdrop#command_option#split(a:option)
	return pyeval('snowdrop.context(
\		vim.eval("a:source"),
\		vim.eval("a:filename"),
\		vim.eval("option"),
\		int(vim.eval("a:line")),
\		int(vim.eval("a:col")) )
\	')
endfunction


function! snowdrop#libclang#python#code_complete(source, filename, option, line, col)
	let option = snowdrop#command_option#split(a:option)
	return pyeval('snowdrop.code_complete(
\		vim.eval("a:source"),
\		vim.eval("a:filename"),
\		vim.eval("option"),
\		int(vim.eval("a:line")),
\		int(vim.eval("a:col")) )
\	')
endfunction


function! snowdrop#libclang#python#definition(source, filename, option, line, col)
	let option = snowdrop#command_option#split(a:option)
	return pyeval('snowdrop.definition(
\		vim.eval("a:source"),
\		vim.eval("a:filename"),
\		vim.eval("option"),
\		int(vim.eval("a:line")),
\		int(vim.eval("a:col")) )
\	')
endfunction


call snowdrop#libclang#python#load(snowdrop#get_libclang_filename())



let &cpo = s:save_cpo
unlet s:save_cpo
