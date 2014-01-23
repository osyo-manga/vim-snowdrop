scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let g:snowdrop#debug#enable = get(g:, "snowdrop#debug#enable", 0)

if !exists("s:log_data")
	let s:log_data = ""
endif


function! snowdrop#debug#clear()
	let s:log_data = ""
endfunction


function! snowdrop#debug#logs()
	return s:log_data
endfunction


function! snowdrop#debug#print(point, ...)
	if !g:snowdrop#debug#enable
		return
	endif
	let s:log_data .= "---- " . strftime("%c", localtime()) . ' ---- | ' . a:point . "\n"
	if a:0
		let s:log_data .= (type(a:1) == type("") ? a:1 : string(a:1)) . "\n"
	endif
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
