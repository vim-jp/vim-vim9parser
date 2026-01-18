vim9script

# Test for vim9parser expression parser
set nocompatible

var base = fnamemodify(resolve(expand('<sfile>')), ':h:h')
execute 'set runtimepath=' .. base .. ',' .. &runtimepath

# Test: Parse simple addition
def Test_expr_addition(): void
  var p = vim9parser#Import()
  var lines = ['var x = 1 + 2']
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  var var_node = ast.body[0]
  var expr = var_node.body[0]
  
  assert_equal(p.NODE_ADD, expr.type)
  assert_equal('+', expr.op)
  assert_equal(p.NODE_NUMBER, expr.left.type)
  assert_equal('1', expr.left.value)
  assert_equal(p.NODE_NUMBER, expr.right.type)
  assert_equal('2', expr.right.value)
  
  echomsg 'Test_expr_addition: PASS'
enddef

# Test: Parse comparison
def Test_expr_comparison(): void
  var p = vim9parser#Import()
  var lines = ['var x = 1 == 2']
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  var var_node = ast.body[0]
  var expr = var_node.body[0]
  
  assert_equal(p.NODE_EQUAL, expr.type)
  assert_equal('==', expr.op)
  
  echomsg 'Test_expr_comparison: PASS'
enddef

# Test: Parse multiplication with higher precedence
def Test_expr_precedence(): void
  var p = vim9parser#Import()
  var lines = ['var x = 1 + 2 * 3']
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  var var_node = ast.body[0]
  var expr = var_node.body[0]
  
  # Should be (1 + (2 * 3))
  assert_equal(p.NODE_ADD, expr.type)
  assert_equal(p.NODE_NUMBER, expr.left.type)
  assert_equal('1', expr.left.value)
  assert_equal(p.NODE_MULTIPLY, expr.right.type)
  assert_equal('2', expr.right.left.value)
  assert_equal('3', expr.right.right.value)
  
  echomsg 'Test_expr_precedence: PASS'
enddef

# Test: Parse function call
def Test_expr_function_call(): void
  var p = vim9parser#Import()
  var lines = ['var x = Add(1, 2)']
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  var var_node = ast.body[0]
  var expr = var_node.body[0]
  
  assert_equal(p.NODE_CALL, expr.type)
  assert_equal(p.NODE_IDENTIFIER, expr.left.type)
  assert_equal('Add', expr.left.name)
  assert_equal(2, len(expr.body))
  
  echomsg 'Test_expr_function_call: PASS'
enddef

# Test: Parse array literal
def Test_expr_array(): void
  var p = vim9parser#Import()
  var lines = ['var x = [1, 2, 3]']
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  var var_node = ast.body[0]
  var expr = var_node.body[0]
  
  assert_equal(p.NODE_LIST, expr.type)
  assert_equal(3, len(expr.body))
  assert_equal(p.NODE_NUMBER, expr.body[0].type)
  assert_equal('1', expr.body[0].value)
  
  echomsg 'Test_expr_array: PASS'
enddef

# Test: Parse member access
def Test_expr_member_access(): void
  var p = vim9parser#Import()
  var lines = ['var x = obj.field']
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  var var_node = ast.body[0]
  var expr = var_node.body[0]
  
  assert_equal(p.NODE_DOT, expr.type)
  assert_equal('field', expr.name)
  assert_equal(p.NODE_IDENTIFIER, expr.left.type)
  assert_equal('obj', expr.left.name)
  
  echomsg 'Test_expr_member_access: PASS'
enddef

# Test: Parse logical AND
def Test_expr_logical_and(): void
  var p = vim9parser#Import()
  var lines = ['var x = a && b || c']
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  var var_node = ast.body[0]
  var expr = var_node.body[0]
  
  # Should be ((a && b) || c)
  assert_equal(p.NODE_OR, expr.type)
  assert_equal(p.NODE_AND, expr.left.type)
  
  echomsg 'Test_expr_logical_and: PASS'
enddef

# Test: Parse parenthesized expression
def Test_expr_parenthesis(): void
  var p = vim9parser#Import()
  var lines = ['var x = (1 + 2) * 3']
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  var var_node = ast.body[0]
  var expr = var_node.body[0]
  
  # Should be ((1 + 2) * 3)
  assert_equal(p.NODE_MULTIPLY, expr.type)
  assert_equal(p.NODE_ADD, expr.left.type)
  
  echomsg 'Test_expr_parenthesis: PASS'
enddef

# Run tests
try
  Test_expr_addition()
  Test_expr_comparison()
  Test_expr_precedence()
  Test_expr_function_call()
  Test_expr_array()
  Test_expr_member_access()
  Test_expr_logical_and()
  Test_expr_parenthesis()
  echomsg 'All expression parser tests passed!'
  sleep 100m
catch
  echoerr 'Test failed: ' .. v:exception
  sleep 100m
finally
  quit!
endtry
