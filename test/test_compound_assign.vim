vim9script

# Test for compound assignment operators
set nocompatible

var base = fnamemodify(resolve(expand('<sfile>')), ':h:h')
execute 'set runtimepath=' .. base .. ',' .. &runtimepath

# Test: Parse += operator
def Test_compound_plus_eq(): void
  var p = vim9parser#Import()
  var lines = ['x += 5']
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  var stmt = ast.body[0]
  
  # Should be a LET node with ADD operation
  assert_equal(p.NODE_LET, stmt.type)
  assert_equal(p.NODE_ADD, stmt.right.type)
  assert_equal(p.NODE_NUMBER, stmt.right.right.type)
  assert_equal('5', stmt.right.right.value)
  
  echomsg 'Test_compound_plus_eq: PASS'
enddef

# Test: Parse -= operator
def Test_compound_minus_eq(): void
  var p = vim9parser#Import()
  var lines = ['x -= 2']
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  var stmt = ast.body[0]
  
  # Should be a LET node with SUBTRACT operation
  assert_equal(p.NODE_LET, stmt.type)
  assert_equal(p.NODE_SUBTRACT, stmt.right.type)
  
  echomsg 'Test_compound_minus_eq: PASS'
enddef

# Test: Parse *= operator
def Test_compound_star_eq(): void
  var p = vim9parser#Import()
  var lines = ['x *= 3']
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  var stmt = ast.body[0]
  
  # Should be a LET node with MULTIPLY operation
  assert_equal(p.NODE_LET, stmt.type)
  assert_equal(p.NODE_MULTIPLY, stmt.right.type)
  
  echomsg 'Test_compound_star_eq: PASS'
enddef

# Test: Parse /= operator
def Test_compound_slash_eq(): void
  var p = vim9parser#Import()
  var lines = ['x /= 2']
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  var stmt = ast.body[0]
  
  # Should be a LET node with DIVIDE operation
  assert_equal(p.NODE_LET, stmt.type)
  assert_equal(p.NODE_DIVIDE, stmt.right.type)
  
  echomsg 'Test_compound_slash_eq: PASS'
enddef

# Test: Parse %= operator
def Test_compound_percent_eq(): void
  var p = vim9parser#Import()
  var lines = ['x %= 2']
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  var stmt = ast.body[0]
  
  # Should be a LET node with MODULO operation
  assert_equal(p.NODE_LET, stmt.type)
  assert_equal(p.NODE_MODULO, stmt.right.type)
  
  echomsg 'Test_compound_percent_eq: PASS'
enddef

# Run tests
try
  Test_compound_plus_eq()
  Test_compound_minus_eq()
  Test_compound_star_eq()
  Test_compound_slash_eq()
  Test_compound_percent_eq()
  echomsg 'All compound assignment tests passed!'
  sleep 100m
catch
  echoerr 'Test failed: ' .. v:exception
  sleep 100m
finally
  quit!
endtry
