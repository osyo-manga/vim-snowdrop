scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let s:plugin_root = substitute(expand("<sfile>:p:h:h:h:h"), '\\', '/', 'g')
let s:ruby_module_path = s:plugin_root . "/snowdrop/ffi_clang/snowdrop.rb"


function! s:import(file)
	execute "rubyfile" a:file
endfunction


function! snowdrop#libclang#ffi_clang#load(libclang)
	if !has("ruby")
		return snowdrop#echoerr("Requires +ruby.")
	endif
	call s:import(s:ruby_module_path)
endfunction


function! snowdrop#libclang#ffi_clang#get_clang_version()
	ruby VIM::command("let result ='" + Snowdrop.get_clang_version() + "'")
	return result
endfunction


function! snowdrop#libclang#ffi_clang#context(source, filename, option, line, col)
	let option = snowdrop#command_option#split(a:option)
	ruby VIM::command("let result =" + JSON.generate(Snowdrop.context(
\		VIM::evaluate("a:source"),
\		VIM::evaluate("a:filename"),
\		VIM::evaluate("option"),
\		VIM::evaluate("a:line"),
\		VIM::evaluate("a:col")
\	)))
	return result
endfunction


call snowdrop#libclang#ffi_clang#load(snowdrop#get_libclang_filename())


let &cpo = s:save_cpo
unlet s:save_cpo
