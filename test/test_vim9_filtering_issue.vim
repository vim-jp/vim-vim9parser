vim9script

# Test to identify why Vim9script filtering hangs

var output: list<string> = []
output->add('Testing Vim9script filtering patterns...')

try
  # Pattern 1: Simple for loop with condition
  output->add('Test 1: Simple for loop')
  var lines = ['# comment', 'code', '  # indented comment']
  var filtered = []
  
  for line in lines
    if line != '# comment'
      filtered->add(line)
    endif
  endfor
  
  output->add('  For loop result: ' .. len(filtered) .. ' items')
catch
  output->add('  ERROR: ' .. v:exception)
endtry

try
  # Pattern 2: For loop with string match
  output->add('Test 2: For loop with match')
  var lines2 = ['# comment', 'code', '  # indented comment']
  var filtered2 = []
  
  for line in lines2
    var trimmed = substitute(line, '^[ \t]*', '', '')
    if trimmed != '# comment'
      filtered2->add(line)
    endif
  endfor
  
  output->add('  For loop with match result: ' .. len(filtered2) .. ' items')
catch
  output->add('  ERROR: ' .. v:exception)
endtry

try
  # Pattern 3: For loop with regex check
  output->add('Test 3: For loop with regex')
  var lines3 = ['# comment', 'code', '  # indented comment']
  var filtered3 = []
  
  for line in lines3
    var trimmed = substitute(line, '^[ \t]*', '', '')
    if trimmed !~ '^#'
      filtered3->add(line)
    endif
  endfor
  
  output->add('  For loop with regex result: ' .. len(filtered3) .. ' items')
catch
  output->add('  ERROR: ' .. v:exception)
endtry

try
  # Pattern 4: Using map() - POTENTIALLY PROBLEMATIC
  output->add('Test 4: Using map()')
  var lines4 = ['# comment', 'code']
  var mapped = lines4->map((i, l) => l)
  output->add('  Map result: ' .. len(mapped) .. ' items')
catch
  output->add('  ERROR in map: ' .. v:exception)
endtry

try
  # Pattern 5: Using filter() with simple check - POTENTIALLY PROBLEMATIC
  output->add('Test 5: Using filter()')
  var lines5 = ['# comment', 'code']
  var filtered4 = lines5->filter((_, l) => l != '# comment')
  output->add('  Filter result: ' .. len(filtered4) .. ' items')
catch
  output->add('  ERROR in filter: ' .. v:exception)
endtry

try
  # Pattern 6: Using filter() with regex - POTENTIALLY PROBLEMATIC
  output->add('Test 6: Using filter() with regex')
  var lines6 = ['# comment', 'code']
  var filtered5 = lines6->filter((_, l) => l !~ '^[ \t]*#')
  output->add('  Filter with regex result: ' .. len(filtered5) .. ' items')
catch
  output->add('  ERROR in filter with regex: ' .. v:exception)
endtry

output->add('All tests completed')

writefile(output, 'test_vim9_filter_output.txt')

qa!
