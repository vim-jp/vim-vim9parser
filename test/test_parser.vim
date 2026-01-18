vim9script

# Test for vim9parser parser (tokenizer -> AST)
set nocompatible

var base = fnamemodify(resolve(expand('<sfile>')), ':h:h')
execute 'set runtimepath=' .. base .. ',' .. &runtimepath

# Test: Parse var declaration
def Test_parse_var(): void
  var p = vim9parser#import()
  var lines = ['var x: number = 1']
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  assert_equal(1, ast.type)  # NODE_TOPLEVEL
  assert_equal(1, len(ast.body))
  
  var var_node = ast.body[0]
  assert_equal(p.NODE_VAR, var_node.type)
  assert_equal('x', var_node.name)
  assert_equal('number', var_node.rtype)
  
  echomsg 'Test_parse_var: PASS'
enddef

# Test: Parse def function
def Test_parse_def(): void
  var p = vim9parser#import()
  var lines = [
    'def Add(x: number, y: number): number',
    '  return x + y',
    'enddef',
  ]
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  assert_equal(1, ast.type)  # NODE_TOPLEVEL
  assert_equal(1, len(ast.body))
  
  var def_node = ast.body[0]
  assert_equal(p.NODE_DEF, def_node.type)
  assert_equal('Add', def_node.name)
  assert_equal('number', def_node.rtype)
  assert_equal(2, len(def_node.params))
  
  var param1 = def_node.params[0]
  assert_equal('x', param1.name)
  assert_equal('number', param1.type)
  
  var param2 = def_node.params[1]
  assert_equal('y', param2.name)
  assert_equal('number', param2.type)
  
  echomsg 'Test_parse_def: PASS'
enddef

# Test: Parse const declaration
def Test_parse_const(): void
  var p = vim9parser#import()
  var lines = ['const PI: number = 3.14']
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  assert_equal(1, ast.type)  # NODE_TOPLEVEL
  assert_equal(1, len(ast.body))
  
  var const_node = ast.body[0]
  assert_equal(p.NODE_CONST, const_node.type)
  assert_equal('PI', const_node.name)
  assert_equal('number', const_node.rtype)
  
  echomsg 'Test_parse_const: PASS'
enddef

# Test: Parse class definition
def Test_parse_class(): void
  var p = vim9parser#import()
  var lines = [
    'class MyClass',
    '  var x: number',
    'endclass',
  ]
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  assert_equal(1, ast.type)  # NODE_TOPLEVEL
  assert_equal(1, len(ast.body))
  
  var class_node = ast.body[0]
  assert_equal(p.NODE_CLASS, class_node.type)
  assert_equal('MyClass', class_node.name)
  
  echomsg 'Test_parse_class: PASS'
enddef

# Test: Parse import statement
def Test_parse_import(): void
  var p = vim9parser#import()
  var lines = ['import autoload "mymodule.vim" as m']
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  assert_equal(1, ast.type)  # NODE_TOPLEVEL
  assert_equal(1, len(ast.body))
  
  var import_node = ast.body[0]
  assert_equal(p.NODE_IMPORT, import_node.type)
  assert_equal('mymodule.vim', import_node.line)
  assert_equal('m', import_node.name)
  
  echomsg 'Test_parse_import: PASS'
enddef

# Test: Parse export def
def Test_parse_export(): void
  var p = vim9parser#import()
  var lines = [
    'export def GetValue(): number',
    '  return 42',
    'enddef',
  ]
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  assert_equal(1, ast.type)  # NODE_TOPLEVEL
  assert_equal(1, len(ast.body))
  
  var export_node = ast.body[0]
  assert_equal(p.NODE_EXPORT, export_node.type)
  assert_equal(1, len(export_node.body))
  
  var def_node = export_node.body[0]
  assert_equal(p.NODE_DEF, def_node.type)
  assert_equal('GetValue', def_node.name)
  
  echomsg 'Test_parse_export: PASS'
enddef

# Test: Parse vim9script declaration
def Test_parse_vim9script(): void
  var p = vim9parser#import()
  var lines = [
    'vim9script',
    'var x = 1',
  ]
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  assert_equal(1, ast.type)  # NODE_TOPLEVEL
  assert_equal(1, len(ast.body))  # Only var, vim9script is skipped
  
  echomsg 'Test_parse_vim9script: PASS'
enddef

# Run tests
try
  Test_parse_var()
  Test_parse_def()
  Test_parse_const()
  Test_parse_class()
  Test_parse_import()
  Test_parse_export()
  Test_parse_vim9script()
  echomsg 'All parser tests passed!'
  sleep 100m
catch
  echoerr 'Test failed: ' .. v:exception
  sleep 100m
finally
  quit!
endtry
