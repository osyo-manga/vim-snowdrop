scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let g:neocomplete#sources#snowdrop#enable = get(g:, "neocomplete#sources#snowdrop#enable", 0)


let s:source = {
\	"name" : "snowdrop",
\	"filetypes" : { "cpp" : 1 },
\	"kind" : "manual",
\	"disabled" : 1,
\}


function! s:source.get_complete_position(context)
	if g:neocomplete#sources#snowdrop#enable == 0
		return -1
	endif
	let pattern = '[^.[:digit:] *\t]\%(\.\|->\)\zs\w*\|::\zs\w*'
	if a:context.input !~ pattern
		return -1
	endif
	return getpos(".")[2] - len(matchstr(a:context.input, pattern)) - 1
endfunction


let s:cache = {}
function! s:complete(line, col)
	let pos = a:line . "_" . a:col
	if has_key(s:cache, pos)
		return s:cache[pos]
	endif

	let completion = snowdrop#code_complete_in_cursor({
\		"line" : a:line,
\		"col"  : a:col,
\	})
	call filter(completion, "v:val.is_available")

	let s:cache[pos] = map(completion, '{
\		"word" : v:val.complete_word,
\		"abbr" : v:val.info . " -> " . v:val.result_type,
\		"dup"  : 1,
\	}')
	return s:cache[pos]
endfunction


function! s:source.gather_candidates(context)
	let completion = s:complete(line("."), a:context.complete_pos)
	return completion
endfunction


augroup snowdrop-neocomplete
	autocmd!
	autocmd InsertLeave * let s:cache = {}
augroup END



function! neocomplete#sources#snowdrop#define()
	return s:source
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
