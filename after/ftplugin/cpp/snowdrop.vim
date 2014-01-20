scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

if exists('b:ftplugin_cpp_snowdrop')
  finish
endif
let b:ftplugin_cpp_snowdrop = 1


if exists('b:undo_ftplugin')
	let b:undo_ftplugin .= ' | '
else
	let b:undo_ftplugin = ''
endif


let b:undo_ftplugin .= join([
\	"unlet! b:ftplugin_cpp_snowdrop",
\	snowdrop#ftplugin#command("cpp"),
\	snowdrop#ftplugin#mapping("cpp"),
\], " | ")


let &cpo = s:save_cpo
unlet s:save_cpo
