import clang.cindex
from clang.cindex import Index
from clang.cindex import Config
from clang.cindex import Cursor
from clang.cindex import SourceLocation

clang.cindex.functionList.append(
  ("clang_getClangVersion",
   [],
   clang.cindex._CXString,
   clang.cindex._CXString.from_result
   ),
)


clang.cindex.functionList.append(
  ("clang_getTypeSpelling",
   [clang.cindex.Type],
   clang.cindex._CXString,
   clang.cindex._CXString.from_result),
)



def set_library_path(path):
	if path != "":
		Config.loaded = False
		Config.set_library_path(path)

def get_library_file():
	conf = Config()
	return conf.get_filename()


def get_clang_version():
	conf = Config()
	return conf.lib.clang_getClangVersion()


def includes(source, options, name):
	index = Index.create()
	tree = index.parse(name, args = options, unsaved_files = [ (name, source) ])
	return list(set(map((lambda x: x.source.name), tree.get_includes())))


def definition(source, filename, options, line, col):
	index = Index.create()
	tu = index.parse(filename, args = options, unsaved_files = [ (filename, source) ])
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
	index = Index.create()
	tu = index.parse(filename, args = options, unsaved_files = [ (filename, source) ])
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
			"file" : "",
			"line" : location.line,
			"column" : location.column,
		}
	return {}

def cursor_context(cursor):
	result = {
		"displayname" : cursor.displayname,
		"kind" : cursor.kind.name,
		"location" : location_context(cursor.location),
		"type" : type_context(cursor.type),
		"result_type" : type_context(cursor.result_type),
	}
	return result



def context(source, filename, options, line, col):
	index = Index.create()
	tu = index.parse(filename, args = options, unsaved_files = [ (filename, source) ])
	location = tu.get_location(filename, (line, col))
	cursor = Cursor.from_location(tu, location)
	result = cursor_context(cursor)
	return result



