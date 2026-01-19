vim9script

# Detect where the hang occurs with real data

var output: list<string> = []
output->add('Testing comment handling with increasing data sizes...')

try
  output->add('Test 1: Reading vim9parser.vim file')
  var all_lines = readfile('autoload/vim9parser.vim')
  output->add('  Read ' .. len(all_lines) .. ' lines')
  
  # Test: Extract first 10 lines
  output->add('Test 2: First 10 lines')
  var small_subset = all_lines[0 : 9]
  output->add('  Subset size: ' .. len(small_subset))
  
  # Test: Filter small subset
  output->add('Test 3: Filter small subset')
  var filtered_small = []
  for line in small_subset
    var trimmed = substitute(line, '^[ \t]*', '', '')
    if trimmed != '' && match(trimmed, '^#') != 0
      filtered_small->add(line)
    endif
  endfor
  output->add('  Filtered to ' .. len(filtered_small) .. ' lines')
  
  # Test: Filter 100 lines
  output->add('Test 4: Filter 100 lines')
  var medium_subset = all_lines[0 : 99]
  var filtered_medium = []
  for line in medium_subset
    var trimmed = substitute(line, '^[ \t]*', '', '')
    if trimmed != '' && match(trimmed, '^#') != 0
      filtered_medium->add(line)
    endif
  endfor
  output->add('  Filtered to ' .. len(filtered_medium) .. ' lines')
  
  # Test: StringReader with small subset
  output->add('Test 5: StringReader with 10 lines')
  import '../autoload/vim9parser.vim' as v9p
  var reader1 = v9p.StringReader.new(small_subset)
  output->add('  Reader created with ' .. len(reader1.lines) .. ' lines')
  
  # Test: StringReader with 100 lines
  output->add('Test 6: StringReader with 100 lines')
  var reader2 = v9p.StringReader.new(medium_subset)
  output->add('  Reader created with ' .. len(reader2.lines) .. ' lines')
  
  output->add('Success! All tests completed')
  
catch
  output->add('ERROR: ' .. v:exception)
  output->add('Throwpoint: ' .. v:throwpoint)
endtry

writefile(output, 'test_comment_hang_output.txt')

qa!
