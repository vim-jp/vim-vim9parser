" Test for vim9parser expression parser - writes results to file
set nocompatible

let base = fnamemodify(resolve(expand('<sfile>')), ':h:h')
execute 'set runtimepath=' .. base .. ',' .. &runtimepath

let results = []

call add(results, 'Starting tests...')

try
  call add(results, 'Test 1: Import')
  let p = vim9parser#Import()
  call add(results, '  OK: vim9parser#Import()')
  
  call add(results, 'Test 2: Create StringReader')
  let reader = p.StringReader.new(['var x = 1 + 2'])
  call add(results, '  OK: StringReader.new()')
  
  call add(results, 'Test 3: Create Parser')
  let parser = p.Vim9Parser.new()
  call add(results, '  OK: Vim9Parser.new()')
  
  call add(results, 'Test 4: Parse simple addition')
  let reader2 = p.StringReader.new(['var x = 1 + 2'])
  let ast = parser.parse(reader2)
  call add(results, '  OK: parser.parse()')
  call add(results, '  AST body length: ' .. len(ast.body))
  
  if len(ast.body) > 0
    let var_node = ast.body[0]
    call add(results, '  Var node type: ' .. var_node.type)
    call add(results, '  Var node name: ' .. var_node.name)
    call add(results, '  Var node body length: ' .. len(var_node.body))
    
    if len(var_node.body) > 0
      let expr = var_node.body[0]
      call add(results, '  Expression type: ' .. expr.type)
      call add(results, '  Expression op: ' .. expr.op)
      call add(results, '  Expected NODE_ADD = 300, got: ' .. expr.type)
      
      if expr.type == 300
        call add(results, '  ✓ Expression type is NODE_ADD')
      else
        call add(results, '  ✗ Expression type is NOT NODE_ADD')
      endif
      
      if expr.op == '+'
        call add(results, '  ✓ Operator is +')
      else
        call add(results, '  ✗ Operator is not +')
      endif
      
      call add(results, '  Left type: ' .. expr.left.type)
      call add(results, '  Left value: ' .. expr.left.value)
      call add(results, '  Right type: ' .. expr.right.type)
      call add(results, '  Right value: ' .. expr.right.value)
    endif
  endif
  
  call add(results, 'Test 5: Parse precedence (1 + 2 * 3)')
  let reader3 = p.StringReader.new(['var x = 1 + 2 * 3'])
  let ast3 = parser.parse(reader3)
  
  if len(ast3.body) > 0
    let var_node3 = ast3.body[0]
    if len(var_node3.body) > 0
      let expr3 = var_node3.body[0]
      call add(results, '  Root op: ' .. expr3.op)
      call add(results, '  Left is NUMBER: ' .. expr3.left.value)
      call add(results, '  Right type (should be MULTIPLY=302): ' .. expr3.right.type)
      
      if expr3.right.type == 302
        call add(results, '  ✓ Right side is multiplication')
      else
        call add(results, '  ✗ Right side is NOT multiplication')
      endif
    endif
  endif
  
  call add(results, '')
  call add(results, 'ALL TESTS COMPLETED SUCCESSFULLY')
  
catch
  call add(results, 'ERROR: ' .. v:exception)
  call add(results, 'THROWPOINT: ' .. v:throwpoint)
endtry

call writefile(results, '/tmp/vim9parser_test_results.txt')
quit!
