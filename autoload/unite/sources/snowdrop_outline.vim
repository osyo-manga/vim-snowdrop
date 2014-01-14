scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let s:cursor_kind_string_table = {
\	"STRUCT_DECL" : "struct",
\	"CLASS_DECL" : "class",
\	"CLASS_TEMPLATE" : "template class",
\	"NAMESPACE" : "namespace",
\	"CXX_METHOD" : "",
\	"FUNCTION_DECL" : "",
\	"FUNCTION_TEMPLATE" : "template",
\	"MACRO_DEFINITION" : "#define",
\	"INCLUSION_DIRECTIVE" : "#include",
\}

function! s:cursor_kind_string_table.TYPEDEF_DECL(cursor)
	if len(a:cursor.children) == 0
		return printf("typedef %s %s", a:cursor.type.canonical_spelling, a:cursor.displayname)
	else
		return printf("typedef %s %s", a:cursor.children[0].displayname, a:cursor.displayname)
	endif
endfunction


function! s:cursor_kind_string_table.FIELD_DECL(cursor)
	return printf("%s %s", a:cursor.type.spelling, a:cursor.displayname)
endfunction


function! s:cursor_string(cursor)
	if !has_key(s:cursor_kind_string_table, a:cursor.kind)
		return ""
	endif
	if type(s:cursor_kind_string_table[a:cursor.kind]) == type("")
		let kind = s:cursor_kind_string_table[a:cursor.kind]
		return kind . (kind == "" ? "" : " ") . a:cursor.displayname
	elseif type(s:cursor_kind_string_table[a:cursor.kind]) == type(function("tr"))
		return s:cursor_kind_string_table[a:cursor.kind](a:cursor)
	endif
	return ""
endfunction


function! s:cursor_to_candidate(cursor, indent)
	if empty(a:cursor.location)
		return {}
	endif
	let abbr = s:cursor_string(a:cursor)
	if abbr == ""
		return {}
	endif
	return {
\		"word" : a:cursor.displayname,
\		"abbr" : a:indent . s:cursor_string(a:cursor),
\		"kind" : "jump_list",
\		"action__path" : a:cursor.location.file,
\		"action__line" : a:cursor.location.line,
\		"action__col" : a:cursor.location.column,
\	}
endfunction

function! s:empty_candidate()
	return {
\		"word" : "",
\	}
endfunction


function! s:outline(cursor, indent, result)
	let is_added = 0
	let check = len(a:result)
	for cursor in a:cursor.children
		let candidate = s:cursor_to_candidate(cursor, a:indent)
		if !empty(candidate)
			call add(a:result, candidate)
			let is_added = 1
		endif
		call s:outline(cursor, a:indent . "  ", a:result)
	endfor
	if a:cursor.kind ==# "STRUCT_DECL"
\	|| a:cursor.kind ==# "CLASS_DECL"
\	|| a:cursor.kind ==# "CLASS_TEMPLATE"
\	|| a:cursor.kind ==# "NAMESPACE"
		call insert(a:result, s:empty_candidate(), check - 1)
	endif
	if is_added
" 		call add(a:result, s:empty_candidate())
	endif
endfunction



let s:source = {
\	"name" : "snowdrop/outline",
\	"syntax" : "uniteSource__SnowdropOutline",
\	"hooks" : {},
\}

function! s:source.hooks.on_syntax(args, context)
	syntax keyword uniteSource__SnowdropOutlineStructure class typename template namespace typedef struct contained containedin=uniteSource__SnowdropOutline
	highlight default link uniteSource__SnowdropOutlineStructure Structure

	syntax match uniteSource__SnowdropOutlineDefine '#\(include\|define\)' contained containedin=uniteSource__SnowdropOutline
	highlight default link uniteSource__SnowdropOutlineDefine Macro
endfunction


function! s:source.gather_candidates(args, context)
	let context = snowdrop#context_in_cursor({ "line" : 0, "col" : 0 })
	let result = []
	call s:outline(context, "", result)
	return result
endfunction

function! unite#sources#snowdrop_outline#define()
	return s:source
endfunction


if expand("%:p") == expand("<sfile>:p")
	call unite#define_source(s:source)
endif


let &cpo = s:save_cpo
unlet s:save_cpo
