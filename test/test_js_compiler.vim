vim9script

# Test for JavaScript compiler
set nocompatible

var base = fnamemodify(resolve(expand('<sfile>')), ':h:h')
execute 'set runtimepath=' .. base .. ',' .. &runtimepath

# Test: Compile simple variable declaration
def Test_js_var_declaration(): void
  var p = vim9parser#Import()
  var lines = ['var x = 42']
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  var compiler = p.JSCompiler.new()
  var js_lines = compiler.Compile(ast)
  
  assert_true(len(js_lines) > 0)
  var js_code = join(js_lines, '\n')
  assert_match('let x', js_code)
  assert_match('42', js_code)
  
  echomsg 'Test_js_var_declaration: PASS'
enddef

# Test: Compile expression
def Test_js_expression(): void
  var p = vim9parser#Import()
  var lines = ['var result = 1 + 2']
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  var compiler = p.JSCompiler.new()
  var js_lines = compiler.Compile(ast)
  
  var js_code = join(js_lines, '\n')
  assert_match('let result', js_code)
  assert_match('+', js_code)
  
  echomsg 'Test_js_expression: PASS'
enddef

# Test: Compile function definition
def Test_js_function(): void
  var p = vim9parser#Import()
  var lines = [
    'def Add(a, b)',
    '  return a + b',
    'enddef'
  ]
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  var compiler = p.JSCompiler.new()
  var js_lines = compiler.Compile(ast)
  
  var js_code = join(js_lines, '\n')
  assert_match('function Add', js_code)
  assert_match('a, b', js_code)
  assert_match('return', js_code)
  
  echomsg 'Test_js_function: PASS'
enddef

# Test: Compile list literal
def Test_js_list(): void
  var p = vim9parser#Import()
  var lines = ['var items = [1, 2, 3]']
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  var compiler = p.JSCompiler.new()
  var js_lines = compiler.Compile(ast)
  
  var js_code = join(js_lines, '\n')
  assert_match('let items', js_code)
  assert_match('\[', js_code)
  
  echomsg 'Test_js_list: PASS'
enddef

# Test: Compile list comprehension
def Test_js_list_comprehension(): void
  var p = vim9parser#Import()
  var lines = ['var squares = [for i in range(5): i * i]']
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  var compiler = p.JSCompiler.new()
  var js_lines = compiler.Compile(ast)
  
  var js_code = join(js_lines, '\n')
  assert_match('let squares', js_code)
  assert_match('map', js_code)
  
  echomsg 'Test_js_list_comprehension: PASS'
enddef

# Run tests
try
  Test_js_var_declaration()
  Test_js_expression()
  Test_js_function()
  Test_js_list()
  Test_js_list_comprehension()
  echomsg 'All JavaScript compiler tests passed!'
  sleep 100m
catch
  echoerr 'Test failed: ' .. v:exception
  sleep 100m
finally
  quit!
endtry
