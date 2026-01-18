vim9script

# Test for vim9parser
set nocompatible

var base = fnamemodify(resolve(expand('<sfile>')), ':h:h')
execute 'set runtimepath=' .. base .. ',' .. &runtimepath

# Test: Parse simple vim9script with var declaration
def Test_parse_simple_var(): void
  var p = vim9parser#import()
  var reader = p.StringReader.new(['var x = 1'])
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  echomsg 'Test: Parse simple var'
  assert_equal(1, ast.type)  # NODE_TOPLEVEL
  assert_equal(1, len(ast.body))
  echomsg 'PASS'
enddef

# Test: Parse function definition with def
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
  
  echomsg 'Test: Parse def'
  assert_equal(1, ast.type)  # NODE_TOPLEVEL
  assert_equal(1, len(ast.body))
  echomsg 'PASS'
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
  
  echomsg 'Test: Parse class'
  assert_equal(1, ast.type)  # NODE_TOPLEVEL
  assert_equal(1, len(ast.body))
  echomsg 'PASS'
enddef

# Test: Parse import statement
def Test_parse_import(): void
  var p = vim9parser#import()
  var reader = p.StringReader.new(['import autoload "mymodule.vim" as m'])
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  echomsg 'Test: Parse import'
  assert_equal(1, ast.type)  # NODE_TOPLEVEL
  assert_equal(1, len(ast.body))
  echomsg 'PASS'
enddef

# Run tests
try
  Test_parse_simple_var()
  Test_parse_def()
  Test_parse_class()
  Test_parse_import()
  echomsg 'All tests passed!'
catch
  echoerr v:exception
finally
  quit!
endtry
