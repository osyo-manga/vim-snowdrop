scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let s:plugin_root = substitute(expand("<sfile>:p:h:h:h"), '\\', '/', 'g')
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


function! snowdrop#python#load(libclang_path)
	py import vim

	call s:import(s:python_module_path, "snowdrop")

" 	if !get(s:, "is_loaded", 0)
	py snowdrop.set_library_path( vim.eval("a:libclang_path") )
" 	endif

	let s:is_loaded = 1
endfunction


function! snowdrop#python#get_library_file()
	return pyeval('snowdrop.get_library_file()')
endfunction


function! snowdrop#python#includes(source, option)
	let dummy_filename = "INPUT.cpp"
	let result = pyeval('snowdrop.includes( vim.eval("a:source"), vim.eval("split(a:option, '' '')") )')
	call remove(result, index(result, dummy_filename))
	return result
endfunction


function! snowdrop#python#get_libclang_version()
	return pyeval('snowdrop.get_clang_version()')
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
