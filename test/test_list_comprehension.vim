vim9script

# Test for list comprehensions
set nocompatible

var base = fnamemodify(resolve(expand('<sfile>')), ':h:h')
execute 'set runtimepath=' .. base .. ',' .. &runtimepath

# Test: Parse simple list comprehension
def Test_simple_list_comprehension(): void
  var p = vim9parser#Import()
  var lines = ['var squares = [for i in range(10): i * i]']
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  var var_node = ast.body[0]
  var expr = var_node.body[0]
  
  # Should be a LIST node with comprehension info
  assert_equal(p.NODE_LIST, expr.type)
  assert_true(has_key(expr, 'is_comprehension'))
  assert_true(expr.is_comprehension)
  assert_equal('i', expr.loop_var)
  
  echomsg 'Test_simple_list_comprehension: PASS'
enddef

# Test: Parse list comprehension with filter
def Test_list_comprehension_with_filter(): void
  var p = vim9parser#Import()
  var lines = ['var evens = [for i in range(10) if i % 2 == 0: i]']
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  var var_node = ast.body[0]
  var expr = var_node.body[0]
  
  # Should be a LIST node with comprehension and filter
  assert_equal(p.NODE_LIST, expr.type)
  assert_true(expr.is_comprehension)
  assert_equal('i', expr.loop_var)
  assert_true(expr.filter != null)
  
  echomsg 'Test_list_comprehension_with_filter: PASS'
enddef

# Test: Regular list still works
def Test_regular_list(): void
  var p = vim9parser#Import()
  var lines = ['var nums = [1, 2, 3]']
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  var var_node = ast.body[0]
  var expr = var_node.body[0]
  
  assert_equal(p.NODE_LIST, expr.type)
  assert_equal(3, len(expr.body))
  
  echomsg 'Test_regular_list: PASS'
enddef

# Run tests
try
  Test_simple_list_comprehension()
  Test_list_comprehension_with_filter()
  Test_regular_list()
  echomsg 'All list comprehension tests passed!'
  sleep 100m
catch
  echoerr 'Test failed: ' .. v:exception
  sleep 100m
finally
  quit!
endtry
