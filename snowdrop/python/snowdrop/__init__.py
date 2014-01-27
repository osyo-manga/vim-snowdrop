# -*- coding: utf-8 -*
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))

import snowdrop.libclang

sys.path.remove(os.path.dirname(__file__))


def set_library_path(path):
	libclang.set_library_path(path)

def get_library_file():
	return libclang.get_library_file()


def get_clang_version():
	return libclang.get_clang_version()


def includes(source, options, name):
	return libclang.includes(source, options, name)


def definition(source, filename, options, line, col):
	return libclang.definition(source, filename, options, line, col)


def context(source, filename, options, line, col):
	return libclang.context(source, filename, options, line, col)


def code_complete(source, filename, options, line, col):
	return libclang.code_complete(source, filename, options, line, col)


def diagnostics(source, options, filename):
	return libclang.diagnostics(source, options, filename)


__all__ = ['clang.cindex']



