# -*- coding: utf-8 -*
import sys
import os
import vim
from pprint import pprint

sys.path.insert(0, os.path.dirname(__file__))

import snowdrop.clang.cindex

sys.path.remove(os.path.dirname(__file__))

from snowdrop.clang.cindex import Index
from snowdrop.clang.cindex import Config
from snowdrop.clang.cindex import Cursor
from snowdrop.clang.cindex import SourceLocation
from snowdrop.clang.cindex import TranslationUnit
from snowdrop.clang.cindex import functionList
from snowdrop.clang.cindex import _CXString
from snowdrop.clang.cindex import CursorKind
from snowdrop.clang.cindex import CodeCompletionResults
from snowdrop.clang.cindex import Type


functionList.append(
  ("clang_getClangVersion",
   [],
   _CXString,
   _CXString.from_result
   ),
)


functionList.append(
  ("clang_getTypeSpelling",
   [Type],
   _CXString,
   _CXString.from_result),
)


# functionList.append(
#   ("clang_codeCompleteGetContainerUSR",
#    [CodeCompletionResults],
#    _CXString,
#    _CXString.from_result),
# )
#
#
# functionList.append(
#   ("clang_codeCompleteGetContexts",
#    [CodeCompletionResults],
#    clang.cindex.c_ulonglong),
# )
#
#
# functionList.append(
#   ("clang_codeCompleteGetContainerKind",
#    [CodeCompletionResults, clang.cindex.c_void_p],
#    CursorKind)
# )


if not Config.loaded:
	Config.set_compatibility_check(False)


def set_library_path(path):
	global index
	if path != "":
		Config.loaded = False
		Config.set_compatibility_check(False)
		Config.set_library_path(path)
	index = Index.create()


def get_library_file():
	conf = Config()
	return conf.get_filename()


def get_clang_version():
	conf = Config()
	return conf.lib.clang_getClangVersion()


EditingTranslationUnitOptions = (
	  TranslationUnit.PARSE_INCOMPLETE
# 	| TranslationUnit.PARSE_PRECOMPILED_PREAMBLE
	| TranslationUnit.PARSE_DETAILED_PROCESSING_RECORD
	| TranslationUnit.PARSE_CACHE_COMPLETION_RESULTS
# 	| TranslationUnit.PARSE_SKIP_FUNCTION_BODIES
# 	| TranslationUnit.PARSE_INCLUDE_BRIEF_COMMENTS_IN_CODE_COMPLETION
)

# EditingTranslationUnitOptions = (
# 	  TranslationUnit.PARSE_INCOMPLETE
# 	| TranslationUnit.PARSE_PRECOMPILED_PREAMBLE
# 	| TranslationUnit.PARSE_CACHE_COMPLETION_RESULTS
# 	| TranslationUnit.PARSE_INCLUDE_BRIEF_COMMENTS_IN_CODE_COMPLETION
# )


def parse(source, options, name):
	global index
	global EditingTranslationUnitOptions
# 	return index.parse(name, args = options, unsaved_files = [ (name, source) ])
	return index.parse(name, args = options, unsaved_files = [ (name, source) ], options=EditingTranslationUnitOptions)


def includes(source, options, name):
	tu = parse(source, options, name)
	result = []
	for include in tu.get_includes():
		result.append(include.source.name)
		result.append(include.include.name)
	return list(set(result))


def definition(source, filename, options, line, col):
	tu = parse(source, options, filename)
	location = tu.get_location(filename, (line, col))
	cursor = Cursor.from_location(tu, location)
	defs = [cursor.get_definition(), cursor.referenced]
	for d in defs:
		if d is not None and location != d.location:
			location = d.location
			return [location.file.name, location.line, location.column]
	return ["", 0, 0]


def type_spelling(type):
	return clang.cindex.conf.lib.clang_getTypeSpelling(type)


def type_context(type):
	return {
		"spelling" : type_spelling(type),
		"canonical_spelling" : type_spelling(type.get_canonical()),
		"kind" : type.kind.name
	}


def location_context(location):
	if location.file:
		return {
			"file" : location.file.name,
			"line" : location.line,
			"column" : location.column,
		}
	return {}


def extent_context(extent):
	return {
		"start" : location_context(extent.start),
		"end"   : location_context(extent.end),
	}


def cursor_arguments_type_context(cursor):
	return ([cursor_context(x)["type"] for x in cursor.get_arguments()])


def cursor_children(cursor, filename):
	if filename == "":
		return []
	children = [cursor_context(x, filename) for x in cursor.get_children()]
# 	for _ in cursor.get_children():
# 		children.append(cursor_context(_, filename))
# 	return []
	return [x for x in children if (x.get("location", {}).get("file", "") == filename)]
# 	return children


def cursor_context(cursor, filename = ""):
	if filename != "" and cursor.location.file and (cursor.location.file.name != filename):
		return {}
	result = {}
	if cursor:
		result = {
			"displayname" : cursor.displayname,
			"spelling" : cursor.spelling  or "None",
			"kind" : cursor.kind.name,
			"location" : location_context(cursor.location),
			"type" : type_context(cursor.type),
			"result_type" : type_context(cursor.result_type),
			"arguments_type" : cursor_arguments_type_context(cursor),
			"filename" : filename,
# 			"extent" : extent_context(cursor.extent),
# 			"definition" : cursor_context(cursor.get_definition()),
		}
		if filename:
			result["children"] = cursor_children(cursor, filename)
	return result


def context(source, filename, options, line, col):
	tu = parse(source, options, filename)
	if line == 0 and col == 0:
		cursor = tu.cursor
	else:
		location = tu.get_location(filename, (line, col))
		cursor = Cursor.from_location(tu, location)

	result = cursor_context(cursor, filename)
	result["definition"] = cursor_context(cursor.get_definition())
	result["referenced"] = cursor_context(cursor.referenced)
# 	result["semantic_parent"] = cursor_context(cursor.semantic_parent)
# 	result["lexical_parent"] = cursor_context(cursor.lexical_parent)
	return result


def completion_string_to_dict(string):
	info = ""
	complete_word = ""
	result_type = ""
	for chunk in string:
		if chunk.isKindTypedText():
			complete_word = chunk.spelling
		if chunk.isKindResultType():
			result_type = chunk.spelling
		else:
			info += chunk.spelling
	return {
		"info" : info,
		"complete_word" : complete_word,
		"result_type" : result_type,
		"availability" : str(string.availability),
		"is_available" : str(string.availability) == "Available",
		"priority" : str(string.priority),
	}


def completion_result_to_dict(result):
	dict = completion_string_to_dict(result.string)
	dict["kind"] = result.kind.name
	return dict


def code_complete(source, filename, options, line, col):
	tu = parse(source, options, filename)
	completion = tu.codeComplete(filename, line, col, unsaved_files = [ (filename, source) ])
	
# 	print clang.cindex.conf.lib.clang_codeCompleteGetContainerKind(completion, None)
	return [completion_result_to_dict(x) for x in completion.results]


def fixit_to_dict(fixit):
	return {
		"value" : fixit.value,
		"range" : {
			"start" : location_context(fixit.range.start),
			"end"   : location_context(fixit.range.end),
		}
	}


def diagnostic_to_dict(diag):
	severity  = ['Ignored', 'Note', 'Warning', 'Error', 'Fatal']
	return {
			"spelling" : diag.spelling,
			"location" : location_context(diag.location),
			"severity" : diag.severity,
			"severity_string" : severity[diag.severity],
			"category_number" : diag.category_number,
			"category_name" : diag.category_name,
			"fixits" : map(fixit_to_dict, diag.fixits)
	}

def diagnostics(source, options, filename):
	tu = parse(source, options, filename)
	return map(diagnostic_to_dict, tu.diagnostics)
# 	for diag in tu.diagnostics:
#
# 	print diag.spelling
# 	print diag.location
# 	print diag.severity
# # 	print diag.option
# 	print diag.category_number
# 	print diag.category_name
# 	for fix in diag.fixits:
# 		print fix


__all__ = ['clang.cindex']

