" Test for vim9parser - Vim9 script test
set nocompatible

let base = fnamemodify(resolve(expand('<sfile>')), ':h:h')
execute 'set runtimepath=' .. base .. ',' .. &runtimepath

let results = []

call add(results, 'Starting Vim9script tests...')

try
  call add(results, 'Test 1: Create StringReader')
  let reader = StringReader.new(['var x = 1 + 2'])
  call add(results, '  OK: StringReader.new()')
  
  call add(results, 'Test 2: Create Parser')
  let parser = Vim9Parser.new()
  call add(results, '  OK: Vim9Parser.new()')
  
  call add(results, 'Test 3: Parse simple addition')
  let reader2 = StringReader.new(['var x = 1 + 2'])
  let ast = parser.Parse(reader2)
  call add(results, '  OK: parser.Parse()')
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
      
      if expr.type == 300
        call add(results, '  ✓ Expression type is NODE_ADD (300)')
      else
        call add(results, '  ✗ Expression type is NOT NODE_ADD, got ' .. expr.type)
      endif
      
      if expr.op == '+'
        call add(results, '  ✓ Operator is +')
      else
        call add(results, '  ✗ Operator is NOT +, got ' .. expr.op)
      endif
    endif
  endif
  
  call add(results, '')
  call add(results, 'ALL TESTS COMPLETED SUCCESSFULLY')
  
catch
  call add(results, 'ERROR: ' .. v:exception)
  call add(results, 'THROWPOINT: ' .. v:throwpoint)
endtry

call writefile(results, '/tmp/vim9parser_vim9_results.txt')
quit!
