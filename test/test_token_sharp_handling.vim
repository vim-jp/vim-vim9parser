vim9script

# Test to demonstrate the TOKEN_SHARP issue and validate the fix

var test_cases = [
  {
    name: 'Simple var with inline comment',
    code: [
      'var x = 1  # comment',
    ],
    should_parse: false,  # Currently fails with TOKEN_SHARP error
  },
  {
    name: 'Function with inline comment',
    code: [
      'def Foo()  # Function comment',
      'enddef',
    ],
    should_parse: false,  # Currently fails
  },
  {
    name: 'Expression with comment on next line',
    code: [
      'var x = 1 +',
      '  # Add comment',
      '  2',
    ],
    should_parse: false,  # Currently fails
  },
  {
    name: 'Map with inline comment after lambda',
    code: [
      'var result = lines->map((_, l) => l)  # comment',
    ],
    should_parse: false,  # Currently fails - this is the actual issue
  },
]

var output: list<string> = []
output->add('Testing TOKEN_SHARP handling...')
output->add('')

var passed = 0
var failed = 0
var expected_fails = 0

import '../autoload/vim9parser.vim' as v9p

for test in test_cases
  output->add('Test: ' .. test.name)
  
  try
    var reader = v9p.StringReader.new(test.code)
    var p = v9p.Vim9Parser.new()
    var ast = p.Parse(reader)
    
    if test.should_parse
      output->add('  ✓ PASS: Parsed successfully')
      passed += 1
    else
      output->add('  ✗ FAIL: Should have failed but succeeded')
      failed += 1
    endif
  catch /Unexpected token in expression: "#"/
    if !test.should_parse
      output->add('  ⚠ EXPECTED: TOKEN_SHARP error (known issue)')
      expected_fails += 1
    else
      output->add('  ✗ FAIL: Unexpected TOKEN_SHARP error')
      output->add('    Error: ' .. v:exception)
      failed += 1
    endif
  catch
    output->add('  ✗ ERROR: ' .. v:exception)
    failed += 1
  endtry
  
  output->add('')
endfor

output->add('Summary:')
output->add('  Passed: ' .. passed)
output->add('  Failed: ' .. failed)
output->add('  Expected failures (TOKEN_SHARP): ' .. expected_fails)
output->add('')
output->add('Note: Tests marked as "EXPECTED" show the TOKEN_SHARP issue.')
output->add('This is the issue that needs to be fixed in ParsePrimary().')

writefile(output, 'test_token_sharp_output.txt')

qa!
