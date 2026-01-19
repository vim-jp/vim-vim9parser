vim9script

# Test StringReader filtering logic in isolation

import '../autoload/vim9parser.vim' as v9p

var test_cases = [
  {
    name: 'empty lines',
    input: ['', 'var x = 1', ''],
    expected_count: 3,  # StringReader keeps all lines as-is
  },
  {
    name: 'comment only',
    input: ['# comment'],
    expected_count: 1,
  },
  {
    name: 'mixed',
    input: ['# comment', 'var x = 1', '  # indented', 'var y = 2'],
    expected_count: 4,
  },
]

var passed = 0
var failed = 0

for test in test_cases
  try
    var reader = v9p.StringReader.new(test.input)
    var actual_count = len(reader.lines)
    
    if actual_count == test.expected_count
      echomsg '✓ PASS: ' .. test.name .. ' (lines: ' .. actual_count .. ')'
      passed += 1
    else
      echomsg '✗ FAIL: ' .. test.name
      echomsg '  Expected: ' .. test.expected_count .. ' lines'
      echomsg '  Got: ' .. actual_count .. ' lines'
      failed += 1
    endif
  catch
    echomsg '✗ ERROR: ' .. test.name
    echomsg '  Exception: ' .. v:exception
    failed += 1
  endtry
endfor

echomsg ''
echomsg 'Results: ' .. passed .. ' passed, ' .. failed .. ' failed'

qa!
