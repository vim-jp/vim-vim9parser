vim9script

# Test runner for vim9parser
import '/home/mattn/.vim/plugged/vim-vim9parser/autoload/vim9parser.vim' as parser

var results: list<string> = []

results->add('=== Vim9Parser Test Suite ===')
results->add('')

try
  results->add('Test 1: Create StringReader')
  var reader = parser.StringReader.new(['var x = 1 + 2'])
  results->add('  ✓ StringReader created')
  
  results->add('Test 2: Create Parser')
  var p = parser.Vim9Parser.new()
  results->add('  ✓ Parser created')
  
  results->add('Test 3: Parse simple addition')
  var reader2 = parser.StringReader.new(['var x = 1 + 2'])
  var ast = p.Parse(reader2)
  results->add('  ✓ Parsed successfully')
  results->add('  AST body length: ' .. len(ast.body))
  
  if len(ast.body) > 0
    var var_node = ast.body[0]
    results->add('  Var node type: ' .. var_node.type)
    results->add('  Var node name: ' .. var_node.name)
    
    if len(var_node.body) > 0
      var expr = var_node.body[0]
      results->add('  Expression type: ' .. expr.type)
      results->add('  Expression op: ' .. expr.op)
      
      if expr.type == 300 && expr.op == '+'
        results->add('  ✓ PASS: Addition expression parsed correctly')
      else
        results->add('  ✗ FAIL: Expected NODE_ADD (300) with +, got ' .. expr.type .. ' / ' .. expr.op)
      endif
      
      if expr.left.type == 305 && expr.left.value == '1'
        results->add('  ✓ PASS: Left operand correct')
      else
        results->add('  ✗ FAIL: Left operand incorrect')
      endif
      
      if expr.right.type == 305 && expr.right.value == '2'
        results->add('  ✓ PASS: Right operand correct')
      else
        results->add('  ✗ FAIL: Right operand incorrect')
      endif
    endif
  endif
  
  results->add('')
  results->add('Test 4: Parse with operator precedence (1 + 2 * 3)')
  var reader3 = parser.StringReader.new(['var y = 1 + 2 * 3'])
  var ast3 = p.Parse(reader3)
  
  if len(ast3.body) > 0
    var var_node3 = ast3.body[0]
    if len(var_node3.body) > 0
      var expr3 = var_node3.body[0]
      
      # Should be (1 + (2 * 3))
      if expr3.type == 300  # NODE_ADD
        results->add('  ✓ Root is addition')
        
        if expr3.right.type == 302  # NODE_MULTIPLY
          results->add('  ✓ PASS: Correct precedence (right side is multiplication)')
        else
          results->add('  ✗ FAIL: Wrong precedence, right side is ' .. expr3.right.type)
        endif
      else
        results->add('  ✗ FAIL: Root is not addition, got ' .. expr3.type)
      endif
    endif
  endif
  
  results->add('')
  results->add('Test 5: Parse function call')
  var reader4 = parser.StringReader.new(['var z = Add(1, 2)'])
  var ast4 = p.Parse(reader4)
  
  if len(ast4.body) > 0
    var var_node4 = ast4.body[0]
    if len(var_node4.body) > 0
      var expr4 = var_node4.body[0]
      
      if expr4.type == 313  # NODE_CALL
        results->add('  ✓ Expression is function call')
        
        if expr4.left.type == 307 && expr4.left.name == 'Add'
          results->add('  ✓ PASS: Function name is Add')
        endif
        
        if len(expr4.body) == 2
          results->add('  ✓ PASS: Has 2 arguments')
        else
          results->add('  ✗ FAIL: Expected 2 args, got ' .. len(expr4.body))
        endif
      else
        results->add('  ✗ FAIL: Expected NODE_CALL (313), got ' .. expr4.type)
      endif
    endif
  endif
  
  results->add('')
  results->add('=== ALL TESTS COMPLETED ===')
  
catch
  results->add('ERROR: ' .. v:exception)
  results->add('THROWPOINT: ' .. v:throwpoint)
endtry

for line in results
  echomsg line
endfor

writefile(results, '/tmp/vim9parser_test_results.txt')
quit!
