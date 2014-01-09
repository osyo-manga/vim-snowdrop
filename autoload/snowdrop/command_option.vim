scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:command_options = {
\	"cpp" : "-std=c++1y",
\}


function! s:command_option(filetype)
	return get(extend(s:command_options, get(g:, "snowdrop#command_options", {})), a:filetype, "")
endfunction



function! snowdrop#command_option#include_paths_from_filetype(filetype)
	let paths = get(g:snowdrop#include_paths, a:filetype, [])
	return filter(paths, 'isdirectory(v:val) && v:val !~ ''\./''')
endfunction


function! snowdrop#command_option#include_paths_from_bufnr(bufnr)
	let filetype = getbufvar(a:bufnr, "&filetype")
	let paths = snowdrop#command_option#include_paths_from_filetype(filetype)
	return filter(split(getbufvar(a:bufnr, "&path"), '\\\@<![, ]') + paths, 'isdirectory(v:val) && v:val !~ ''\./''')
endfunction


function! snowdrop#command_option#to_include_option(paths)
	let include_opt = join(filter(a:paths, 'v:val !=# "."'), ' -I')
	if empty(include_opt)
		return ""
	endif
	return "-I" . include_opt
endfunction


function! snowdrop#command_option#file(file)
	" unimplemented
	return ""
endfunction


function! snowdrop#command_option#filetype(filetype)
	return s:command_option(a:filetype) . " " . snowdrop#command_option#to_include_option(snowdrop#command_option#include_paths_from_filetype(a:filetype))
endfunction


function! snowdrop#command_option#bufnr(bufnr)
	let filetype = getbufvar(a:bufnr, "&filetype")
	let local = get(b:, "snowdrop_command_option", "")
	return snowdrop#command_option#filetype(filetype) . " ". snowdrop#command_option#to_include_option(snowdrop#command_option#include_paths_from_bufnr(a:bufnr)) . " " . local
endfunction


function! snowdrop#command_option#split(option)
	return map(filter(split(a:option, '\(\s\|^\)-'), 'v:val !~ ''^\s\+$'''), '"-" . v:val')
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
