vim9script

# Test for destructuring assignment
set nocompatible

var base = fnamemodify(resolve(expand('<sfile>')), ':h:h')
execute 'set runtimepath=' .. base .. ',' .. &runtimepath

# Test: Parse list destructuring
def Test_list_destructuring(): void
  var p = vim9parser#Import()
  var lines = ['var [a, b, c] = [1, 2, 3]']
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  var var_node = ast.body[0]
  
  # Should be a VAR node with destructuring info
  assert_equal(p.NODE_VAR, var_node.type)
  assert_true(has_key(var_node, 'is_destructure'))
  assert_true(var_node.is_destructure)
  assert_true(var_node.is_list_destructure)
  assert_equal(['a', 'b', 'c'], var_node.names)
  
  echomsg 'Test_list_destructuring: PASS'
enddef

# Test: Parse dict destructuring
def Test_dict_destructuring(): void
  var p = vim9parser#Import()
  var lines = ['var {x, y} = {x: 1, y: 2}']
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  var var_node = ast.body[0]
  
  # Should be a VAR node with destructuring info
  assert_equal(p.NODE_VAR, var_node.type)
  assert_true(has_key(var_node, 'is_destructure'))
  assert_true(var_node.is_destructure)
  assert_equal(0, var_node.is_list_destructure)
  assert_equal(['x', 'y'], var_node.names)
  
  echomsg 'Test_dict_destructuring: PASS'
enddef

# Test: Regular variable still works
def Test_regular_var(): void
  var p = vim9parser#Import()
  var lines = ['var x = 42']
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  var var_node = ast.body[0]
  
  assert_equal(p.NODE_VAR, var_node.type)
  assert_equal('x', var_node.name)
  
  echomsg 'Test_regular_var: PASS'
enddef

# Run tests
try
  Test_list_destructuring()
  Test_dict_destructuring()
  Test_regular_var()
  echomsg 'All destructuring tests passed!'
  sleep 100m
catch
  echoerr 'Test failed: ' .. v:exception
  sleep 100m
finally
  quit!
endtry
