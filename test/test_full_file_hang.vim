vim9script

# Test with full vim9parser.vim file to reproduce the hang

var output: list<string> = []
output->add('Testing with full file...')

try
  output->add('Loading vim9parser.vim...')
  var all_lines = readfile('autoload/vim9parser.vim')
  output->add('Read ' .. len(all_lines) .. ' lines')
  
  output->add('Creating StringReader...')
  import '../autoload/vim9parser.vim' as v9p
  var reader = v9p.StringReader.new(all_lines)
  output->add('StringReader created with ' .. len(reader.lines) .. ' lines')
  
  output->add('Success!')
  
catch
  output->add('ERROR: ' .. v:exception)
  output->add('Throwpoint: ' .. v:throwpoint)
endtry

writefile(output, 'test_full_file_output.txt')

qa!
