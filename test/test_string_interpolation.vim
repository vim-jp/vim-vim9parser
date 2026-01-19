vim9script

# Test for string interpolation
set nocompatible

var base = fnamemodify(resolve(expand('<sfile>')), ':h:h')
execute 'set runtimepath=' .. base .. ',' .. &runtimepath

# Test: Parse simple string interpolation
def Test_string_interpolation_simple(): void
  var p = vim9parser#Import()
  var lines = ['var msg = $"Hello, {name}!"']
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  var var_node = ast.body[0]
  var expr = var_node.body[0]
  
  # Should be a STRING node with interpolation marker
  assert_equal(p.NODE_STRING, expr.type)
  assert_match('{name}', expr.value)
  
  echomsg 'Test_string_interpolation_simple: PASS'
enddef

# Test: Parse string interpolation with multiple expressions
def Test_string_interpolation_multiple(): void
  var p = vim9parser#Import()
  var lines = ['var result = $"x={x}, y={y}"']
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  var var_node = ast.body[0]
  var expr = var_node.body[0]
  
  # Should be a STRING node
  assert_equal(p.NODE_STRING, expr.type)
  assert_match('{x}', expr.value)
  assert_match('{y}', expr.value)
  
  echomsg 'Test_string_interpolation_multiple: PASS'
enddef

# Test: Regular string still works
def Test_regular_string(): void
  var p = vim9parser#Import()
  var lines = ['var msg = "Hello, world!"']
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  var var_node = ast.body[0]
  var expr = var_node.body[0]
  
  assert_equal(p.NODE_STRING, expr.type)
  assert_equal('Hello, world!', expr.value)
  
  echomsg 'Test_regular_string: PASS'
enddef

# Run tests
try
  Test_string_interpolation_simple()
  Test_string_interpolation_multiple()
  Test_regular_string()
  echomsg 'All string interpolation tests passed!'
  sleep 100m
catch
  echoerr 'Test failed: ' .. v:exception
  sleep 100m
finally
  quit!
endtry
