scriptencoding utf-8
if exists('g:loaded_snowdrop')
  finish
endif
let g:loaded_snowdrop = 1

let s:save_cpo = &cpo
set cpo&vim


command! -bar -bang
\	SnowdropVerify
\	call snowdrop#verify(<bang>0)


command! -bar SnowdropEchoClangVersion
\	echo snowdrop#get_libclang_version()

command! -bar SnowdropLogs
\	echo snowdrop#debug#logs()

command! -bar SnowdropClearLogs
\	call snowdrop#debug#clear()


let &cpo = s:save_cpo
unlet s:save_cpo
