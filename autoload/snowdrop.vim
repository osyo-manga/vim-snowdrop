scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let g:snowdrop#libclang_path = get(g:, "snowdrop#libclang_path", "")

let g:snowdrop#include_paths = get(g:, "snowdrop#include_paths", {})


function! snowdrop#get_current_include_paths()
	let filetype = &filetype
	let paths = get(g:snowdrop#include_paths, filetype, [])
	return filter(split(&path, ',') + paths, 'isdirectory(v:val) && v:val !~ ''\./''')
endfunction


function! snowdrop#to_include_opt(paths)
	let include_opt = join(filter(a:paths, 'v:val !=# "."'), ' -I')
	if empty(include_opt)
		return ""
	endif
	return "-I" . include_opt
endfunction


function! snowdrop#current_command_opt(...)
	let option = get(a:, 1, "")
	return snowdrop#to_include_opt(snowdrop#get_current_include_paths()) . " " . option
endfunction


function! snowdrop#echoerr(str)
	echohl ErrorMsg
	echo "snowdrop.vim : "a:str
	echohl NONE
endfunction


function! snowdrop#load(libclang_path)
	if !has("python")
		call snowdrop#echoerr("Requires +python.")
		return
	endif
	if !empty(a:libclang_path) && !isdirectory(a:libclang_path)
		call snowdrop#echoerr("Not found dir : " . a:libclang_path)
		return
	endif

	call snowdrop#python#load(a:libclang_path)

	if !executable(snowdrop#libclang_file())
		call snowdrop#echoerr("Not found libclang : " . snowdrop#python#get_library_file())
		return
	endif
endfunction


function! snowdrop#libclang_file()
	return snowdrop#python#get_library_file()
endfunction

function! snowdrop#includes_from_bufnr(bufnr, option)
	let option = a:option
	return snowdrop#python#includes(join(getbufline(a:bufnr, 1, "$"), "\n"), option)
endfunction


function! snowdrop#current_includes(...)
	let option = snowdrop#current_command_opt() . " " . get(a:, 1, "")
	return snowdrop#includes_from_bufnr("%", option)
endfunction


function! snowdrop#get_libclang_version()
	return snowdrop#python#get_libclang_version()
endfunction


call snowdrop#load(g:snowdrop#libclang_path)





let &cpo = s:save_cpo
unlet s:save_cpo
