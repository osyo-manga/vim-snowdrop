require "ffi"
require "ffi/clang"
require "json"


module FFI
	module Clang
		module Lib
			attach_function :get_clang_version, :clang_getClangVersion, [], :string

			attach_function :get_location, :clang_getLocation,
				[:CXTranslationUnit, :CXFile, :uint, :uint], CXSourceLocation.by_value

			attach_function :get_cursor, :clang_getCursor,
				[:CXTranslationUnit, CXSourceLocation.by_value], CXCursor.by_value

			attach_function :get_cursor_definition, :clang_getCursorDefinition,
				[CXCursor.by_value], CXCursor.by_value

			attach_function :get_canonical_type, :clang_getCanonicalType,
				[CXType.by_value], CXType.by_value
		end
	end
end



module Snowdrop
	include FFI::Clang

	INDEX = Index.new
	def INDEX.args_pointer_from(command_line_args)
		args_pointer = FFI::MemoryPointer.new(:pointer)
	
		strings = command_line_args.map do |arg|
			FFI::MemoryPointer.from_string(arg.to_s)
		end
	
		args_pointer.put_array_of_pointer(0, strings) unless strings.empty?
		args_pointer
	end

	def self.get_clang_version
		return FFI::Clang::Lib::get_clang_version()
	end


	def self.get_location(tu, file, line, column)
		return Lib.get_location(tu, Lib.get_file(tu, file), line, column)
	end
	
	def self.cursor_from_location(tu, location)
		return Cursor.new(Lib.get_cursor(tu, location))
	end
	
	def get_cursor_definition(cursor)
		return Cursor.new(Lib.get_cursor_definition(cursor.cursor))
	end

	def self.get_cursor(tu, file, line, column)
		return cursor_from_location(tu, get_location(tu, file, line, column))
	end
	
	def self.get_cursor_definition(cursor)
		return Cursor.new(Lib.get_cursor_definition(cursor.cursor))
	end
#
# 	def self.get_canonical_type(type)
# 		return Type.new(Lib.get_canonical_type(type))
# 	end

	def self.get_canonical_type(cursor)
		return Type.new(Lib.get_canonical_type(Lib.get_cursor_type cursor.cursor))
	end

	def self.location_context(location)
		if location.file
			return {
				:file => location.file,
				:line => location.line,
				:column => location.column
			}
		end
		return {}
	end

	def self.type_context(type, cursor)
		return {
			:spelling => type.spelling,
			:canonical_type => get_canonical_type(cursor).spelling,
			:kind => TYPE_KIND_TABLE[type.kind] || "",
		}
	end

	def self.cursor_context(cursor)
		if cursor
			return {
				:location => location_context(cursor.location),
				:displayname => cursor.display_name,
				:spelling => cursor.spelling,
				:type => type_context(cursor.type, cursor),
				:result_type => type_context(cursor.result_type, cursor),
				:kind => CURSOR_KIND_TABLE[cursor.kind] || "",
			}
		end
	end

	def self.context(source, filename, options, line, col)
		file = UnsavedFile.new(filename, source)
		tu = Snowdrop::INDEX.parse_translation_unit(filename, "-std=c++1y", [file])
		cursor = get_cursor(tu, filename, line, col)
		context = cursor_context(cursor)
		context["definition"] = cursor_context(get_cursor_definition(cursor))
		return context
	end

	TYPE_KIND_TABLE = {
		  0 => :INVALID,
		  1 => :UNEXPOSED,
		  2 => :VOID,
		  3 => :BOOL,
		  4 => :CHAR_U,
		  5 => :UCHAR,
		  6 => :CHAR16,
		  7 => :CHAR32,
		  8 => :USHORT,
		  9 => :UINT,
		 10 => :ULONG,
		 11 => :ULONGLONG,
		 12 => :UINT128,
		 13 => :CHAR_S,
		 14 => :SCHAR,
		 15 => :WCHAR,
		 16 => :SHORT,
		 17 => :INT,
		 18 => :LONG,
		 19 => :LONGLONG,
		 20 => :INT128,
		 21 => :FLOAT,
		 22 => :DOUBLE,
		 23 => :LONGDOUBLE,
		 24 => :NULLPTR,
		 25 => :OVERLOAD,
		 26 => :DEPENDENT,
		 27 => :OBJCID,
		 28 => :OBJCCLASS,
		 29 => :OBJCSEL,
		100 => :COMPLEX,
		101 => :POINTER,
		102 => :BLOCKPOINTER,
		103 => :LVALUEREFERENCE,
		104 => :RVALUEREFERENCE,
		105 => :RECORD,
		106 => :ENUM,
		107 => :TYPEDEF,
		108 => :OBJCINTERFACE,
		109 => :OBJCOBJECTPOINTER,
		110 => :FUNCTIONNOPROTO,
		111 => :FUNCTIONPROTO,
		112 => :CONSTANTARRAY,
		113 => :VECTOR,
	}

	CURSOR_KIND_TABLE = {
		  1 => :UNEXPOSED_DECL,
		  2 => :STRUCT_DECL,
		  3 => :UNION_DECL,
		  4 => :CLASS_DECL,
		  5 => :ENUM_DECL,
		  6 => :FIELD_DECL,
		  7 => :ENUM_CONSTANT_DECL,
		  8 => :FUNCTION_DECL,
		  9 => :VAR_DECL,
		 10 => :PARM_DECL,
		 11 => :OBJC_INTERFACE_DECL,
		 12 => :OBJC_CATEGORY_DECL,
		 13 => :OBJC_PROTOCOL_DECL,
		 14 => :OBJC_PROPERTY_DECL,
		 15 => :OBJC_IVAR_DECL,
		 16 => :OBJC_INSTANCE_METHOD_DECL,
		 17 => :OBJC_CLASS_METHOD_DECL,
		 18 => :OBJC_IMPLEMENTATION_DECL,
		 19 => :OBJC_CATEGORY_IMPL_DECL,
		 20 => :TYPEDEF_DECL,
		 21 => :CXX_METHOD,
		 22 => :NAMESPACE,
		 23 => :LINKAGE_SPEC,
		 24 => :CONSTRUCTOR,
		 25 => :DESTRUCTOR,
		 26 => :CONVERSION_FUNCTION,
		 27 => :TEMPLATE_TYPE_PARAMETER,
		 28 => :TEMPLATE_NON_TYPE_PARAMETER,
		 29 => :TEMPLATE_TEMPLATE_PARAMETER,
		 30 => :FUNCTION_TEMPLATE,
		 31 => :CLASS_TEMPLATE,
		 32 => :CLASS_TEMPLATE_PARTIAL_SPECIALIZATION,
		 33 => :NAMESPACE_ALIAS,
		 34 => :USING_DIRECTIVE,
		 35 => :USING_DECLARATION,
		 36 => :TYPE_ALIAS_DECL,
		 37 => :OBJC_SYNTHESIZE_DECL,
		 38 => :OBJC_DYNAMIC_DECL,
		 39 => :CXX_ACCESS_SPEC_DECL,
		 40 => :OBJC_SUPER_CLASS_REF,
		 41 => :OBJC_PROTOCOL_REF,
		 42 => :OBJC_CLASS_REF,
		 43 => :TYPE_REF,
		 44 => :CXX_BASE_SPECIFIER,
		 45 => :TEMPLATE_REF,
		 46 => :NAMESPACE_REF,
		 47 => :MEMBER_REF,
		 48 => :LABEL_REF,
		 49 => :OVERLOADED_DECL_REF,
		 70 => :INVALID_FILE,
		 71 => :NO_DECL_FOUND,
		 72 => :NOT_IMPLEMENTED,
		 73 => :INVALID_CODE,
		100 => :UNEXPOSED_EXPR,
		101 => :DECL_REF_EXPR,
		102 => :MEMBER_REF_EXPR,
		103 => :CALL_EXPR,
		104 => :OBJC_MESSAGE_EXPR,
		105 => :BLOCK_EXPR,
		106 => :INTEGER_LITERAL,
		107 => :FLOATING_LITERAL,
		108 => :IMAGINARY_LITERAL,
		109 => :STRING_LITERAL,
		110 => :CHARACTER_LITERAL,
		111 => :PAREN_EXPR,
		112 => :UNARY_OPERATOR,
		113 => :ARRAY_SUBSCRIPT_EXPR,
		114 => :BINARY_OPERATOR,
		115 => :COMPOUND_ASSIGNMENT_OPERATOR,
		116 => :CONDITIONAL_OPERATOR,
		117 => :CSTYLE_CAST_EXPR,
		118 => :COMPOUND_LITERAL_EXPR,
		119 => :INIT_LIST_EXPR,
		120 => :ADDR_LABEL_EXPR,
		121 => :StmtExpr,
		122 => :GENERIC_SELECTION_EXPR,
		123 => :GNU_NULL_EXPR,
		124 => :CXX_STATIC_CAST_EXPR,
		125 => :CXX_DYNAMIC_CAST_EXPR,
		126 => :CXX_REINTERPRET_CAST_EXPR,
		127 => :CXX_CONST_CAST_EXPR,
		128 => :CXX_FUNCTIONAL_CAST_EXPR,
		129 => :CXX_TYPEID_EXPR,
		130 => :CXX_BOOL_LITERAL_EXPR,
		131 => :CXX_NULL_PTR_LITERAL_EXPR,
		132 => :CXX_THIS_EXPR,
		133 => :CXX_THROW_EXPR,
		134 => :CXX_NEW_EXPR,
		135 => :CXX_DELETE_EXPR,
		136 => :CXX_UNARY_EXPR,
		137 => :OBJC_STRING_LITERAL,
		138 => :OBJC_ENCODE_EXPR,
		139 => :OBJC_SELECTOR_EXPR,
		140 => :OBJC_PROTOCOL_EXPR,
		141 => :OBJC_BRIDGE_CAST_EXPR,
		142 => :PACK_EXPANSION_EXPR,
		143 => :SIZE_OF_PACK_EXPR,
		200 => :UNEXPOSED_STMT,
		201 => :LABEL_STMT,
		202 => :COMPOUND_STMT,
		203 => :CASE_STMT,
		204 => :DEFAULT_STMT,
		205 => :IF_STMT,
		206 => :SWITCH_STMT,
		207 => :WHILE_STMT,
		208 => :DO_STMT,
		209 => :FOR_STMT,
		210 => :GOTO_STMT,
		211 => :INDIRECT_GOTO_STMT,
		212 => :CONTINUE_STMT,
		213 => :BREAK_STMT,
		214 => :RETURN_STMT,
		215 => :ASM_STMT,
		216 => :OBJC_AT_TRY_STMT,
		217 => :OBJC_AT_CATCH_STMT,
		218 => :OBJC_AT_FINALLY_STMT,
		219 => :OBJC_AT_THROW_STMT,
		220 => :OBJC_AT_SYNCHRONIZED_STMT,
		221 => :OBJC_AUTORELEASE_POOL_STMT,
		222 => :OBJC_FOR_COLLECTION_STMT,
		223 => :CXX_CATCH_STMT,
		224 => :CXX_TRY_STMT,
		225 => :CXX_FOR_RANGE_STMT,
		226 => :SEH_TRY_STMT,
		227 => :SEH_EXCEPT_STMT,
		228 => :SEH_FINALLY_STMT,
		230 => :NULL_STMT,
		231 => :DECL_STMT,
		300 => :TRANSLATION_UNIT,
		400 => :UNEXPOSED_ATTR,
		401 => :IB_ACTION_ATTR,
		402 => :IB_OUTLET_ATTR,
		403 => :IB_OUTLET_COLLECTION_ATTR,
		404 => :CXX_FINAL_ATTR,
		405 => :CXX_OVERRIDE_ATTR,
		406 => :ANNOTATE_ATTR,
		407 => :ASM_LABEL_ATTR,
		500 => :PREPROCESSING_DIRECTIVE,
		501 => :MACRO_DEFINITION,
		502 => :MACRO_INSTANTIATION,
		503 => :INCLUSION_DIRECTIVE,
	}
end


# class Snowdrop
# 	def test
# 		puts "test"
# 	end
# end

