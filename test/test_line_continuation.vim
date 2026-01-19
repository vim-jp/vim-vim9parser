vim9script

# Test for line continuation
set nocompatible

var base = fnamemodify(resolve(expand('<sfile>')), ':h:h')
execute 'set runtimepath=' .. base .. ',' .. &runtimepath

# Test: Parse expression with operator-based continuation
def Test_operator_continuation(): void
  var p = vim9parser#Import()
  var lines = [
    'var result = 1 +',
    '  2 +',
    '  3'
  ]
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  var var_node = ast.body[0]
  var expr = var_node.body[0]
  
  # Should be an ADD node representing the full expression
  assert_equal(p.NODE_ADD, expr.type)
  
  echomsg 'Test_operator_continuation: PASS'
enddef

# Test: Parse expression with explicit backslash continuation
def Test_explicit_continuation(): void
  var p = vim9parser#Import()
  var lines = [
    'var result = 1 + \',
    '  2 + \',
    '  3'
  ]
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  var var_node = ast.body[0]
  var expr = var_node.body[0]
  
  # Should be an ADD node representing the full expression
  assert_equal(p.NODE_ADD, expr.type)
  
  echomsg 'Test_explicit_continuation: PASS'
enddef

# Test: Parse function call across lines
def Test_function_call_continuation(): void
  var p = vim9parser#Import()
  var lines = [
    'var result = func(',
    '  1,',
    '  2',
    ')'
  ]
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  var var_node = ast.body[0]
  var expr = var_node.body[0]
  
  # Should be a CALL node
  assert_equal(p.NODE_CALL, expr.type)
  
  echomsg 'Test_function_call_continuation: PASS'
enddef

# Run tests
try
  Test_operator_continuation()
  Test_explicit_continuation()
  Test_function_call_continuation()
  echomsg 'All line continuation tests passed!'
  sleep 100m
catch
  echoerr 'Test failed: ' .. v:exception
  sleep 100m
finally
  quit!
endtry
