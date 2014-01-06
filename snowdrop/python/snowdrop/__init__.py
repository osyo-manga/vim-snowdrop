# -*- coding: utf-8 -*
import sys
import os
from pprint import pprint

sys.path.insert(0, os.path.dirname(__file__))

import snowdrop.clang.cindex

sys.path.remove(os.path.dirname(__file__))

from snowdrop.clang.cindex import Index
from snowdrop.clang.cindex import Config
from snowdrop.clang.cindex import Cursor
from snowdrop.clang.cindex import SourceLocation
from snowdrop.clang.cindex import functionList
from snowdrop.clang.cindex import _CXString
from snowdrop.clang.cindex import Type
from snowdorp.clang.cindex import TranslationUnit


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

Config.set_compatibility_check(False)


def set_library_path(path):
	global index
	if path != "":
		Config.loaded = False
		Config.set_library_path(path)
		index = Index.create()

def get_library_file():
	conf = Config()
	return conf.get_filename()


def get_clang_version():
	conf = Config()
	return conf.lib.clang_getClangVersion()


index = Index.create()

EditingTranslationUnitOptions = (
	  TranslationUnit.PARSE_PRECOMPILED_PREAMBLE
	| TranslationUnit.PARSE_CACHE_COMPLETION_RESULTS
	| TranslationUnit.PARSE_INCLUDE_BRIEF_COMMENTS_IN_CODE_COMPLETION
)


def parse(source, options, name):
	global index
	global EditingTranslationUnitOptions
	return index.parse(name, args = options, unsaved_files = [ (name, source) ], options=EditingTranslationUnitOptions)


def includes(source, options, name):
	tree = parse(source, options, name)
	return list(set(map((lambda x: x.source.name), tree.get_includes())))


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


def print_type_status(type, status = "type"):
	print "---- %s ----" % status
	print "spelling : %s" % type_spelling(type)
	print "kind : %s" % type.kind.spelling
	print "get_canonical : %s" % type_spelling(type.get_canonical())


def print_cursor_status(cursor, status = "cursor"):
	if cursor:
		print "---- %s ----" % status
		print "location : %s" % cursor.location
		print "displayname : %s" % cursor.displayname
		print "spelling : %s" % cursor.spelling
		print "kind : %s" % cursor.kind.name
# 		print "extent : %s" % cursor.extent
		print_type_status(cursor.type)
		print_type_status(cursor.result_type, "result_type")
		if cursor.kind.is_declaration():
			print_type_status(cursor.underlying_typedef_type, "underlying_typedef_type")
		print " "


def print_status(source, filename, options, line, col):
	tu = parse(source, options, filename)
	location = tu.get_location(filename, (line, col))
	cursor = Cursor.from_location(tu, location)
	print_cursor_status(cursor)
	print_cursor_status(cursor.get_definition(), "cursor definition")


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


def cursor_context(cursor):
	if cursor:
		result = {
			"displayname" : cursor.displayname,
			"kind" : cursor.kind.name,
			"location" : location_context(cursor.location),
			"type" : type_context(cursor.type),
			"result_type" : type_context(cursor.result_type),
# 			"arguments_type" : cursor_arguments_type_context(cursor),
			"extent" : extent_context(cursor.extent),
# 			"definition" : cursor_context(cursor.get_definition()),
		}

		return result
	return {}


def context(source, filename, options, line, col):
	tu = parse(source, options, filename)
	location = tu.get_location(filename, (line, col))
	cursor = Cursor.from_location(tu, location)
	result = cursor_context(cursor)
	result["definition"] = cursor_context(cursor.get_definition())
	result["semantic_parent"] = cursor_context(cursor.semantic_parent)
# 	result["lexical_parent"] = cursor_context(cursor.lexical_parent)
	result["referenced"] = cursor_context(cursor.referenced)
	return result



__all__ = ['clang.cindex']

