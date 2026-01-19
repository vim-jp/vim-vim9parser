vim9script

# Test comment handling in various contexts

import '../autoload/vim9parser.vim' as v9p

var tests = [
  # Test 1: Simple comment line
  {
    name: 'simple comment line',
    code: [
      '# This is a comment',
      'var x = 1',
    ],
    should_parse: true,
  },
  
  # Test 2: Multiple comment lines
  {
    name: 'multiple comment lines',
    code: [
      '# Comment 1',
      '# Comment 2',
      'var x = 1',
    ],
    should_parse: true,
  },
  
  # Test 3: Comment with leading spaces
  {
    name: 'comment with leading spaces',
    code: [
      '  # Indented comment',
      'var x = 1',
    ],
    should_parse: true,
  },
  
  # Test 4: Mixed comments and code
  {
    name: 'mixed comments and code',
    code: [
      '# Start',
      'var x = 1',
      '# Middle',
      'var y = 2',
      '# End',
    ],
    should_parse: true,
  },
  
  # Test 5: Comment in function
  {
    name: 'comment in function',
    code: [
      'def Foo()',
      '  # Function comment',
      '  var x = 1',
      'enddef',
    ],
    should_parse: true,
  },
  
  # Test 6: Comment in class
  {
    name: 'comment in class',
    code: [
      'class MyClass',
      '  # Class comment',
      '  var x = 1',
      'endclass',
    ],
    should_parse: true,
  },
]

var passed = 0
var failed = 0

for test in tests
  try
    var reader = v9p.StringReader.new(test.code)
    var p = v9p.Vim9Parser.new()
    var ast = p.Parse(reader)
    
    if test.should_parse
      echomsg '✓ PASS: ' .. test.name
      passed += 1
    else
      echomsg '✗ FAIL: ' .. test.name .. ' (expected parse error but succeeded)'
      failed += 1
    endif
  catch
    if !test.should_parse
      echomsg '✓ PASS: ' .. test.name .. ' (correctly failed)'
      passed += 1
    else
      echomsg '✗ FAIL: ' .. test.name
      echomsg '  Error: ' .. v:exception
      failed += 1
    endif
  endtry
endfor

echomsg ''
echomsg 'Results: ' .. passed .. ' passed, ' .. failed .. ' failed'

if failed > 0
  cquit 1
endif

qa!
