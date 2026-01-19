vim9script

# Test parsing the full vim9parser.vim file

var output: list<string> = []
output->add('Testing parsing of full vim9parser.vim...')

try
  output->add('Loading file...')
  var all_lines = readfile('autoload/vim9parser.vim')
  output->add('Read ' .. len(all_lines) .. ' lines')
  
  output->add('Importing parser...')
  import '../autoload/vim9parser.vim' as v9p
  
  output->add('Creating StringReader...')
  var reader = v9p.StringReader.new(all_lines)
  output->add('StringReader created')
  
  output->add('Creating Vim9Parser...')
  var p = v9p.Vim9Parser.new()
  output->add('Vim9Parser created')
  
  output->add('Starting parse...')
  var ast = p.Parse(reader)
  output->add('Parse completed!')
  
  output->add('AST node count: ' .. len(ast.body))
  
  output->add('Success!')
  
catch
  output->add('ERROR: ' .. v:exception)
  output->add('Throwpoint: ' .. v:throwpoint)
endtry

writefile(output, 'test_parse_full_file_output.txt')

qa!
