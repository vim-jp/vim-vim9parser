vim9script

import './autoload/vim9parser.vim' as v9p

var output: list<string> = ['Testing complex parse...']

try
  output->add('Reading test_very_simple.vim...')
  var lines = readfile('test_very_simple.vim')
  output->add('File has ' .. len(lines) .. ' lines')
  
  output->add('Creating StringReader...')
  var reader = v9p.StringReader.new(lines)
  output->add('Creating Vim9Parser...')
  var p = v9p.Vim9Parser.new()
  
  output->add('Starting parse...')
  var ast = p.Parse(reader)
  output->add('Parse successful!')
  output->add('AST body items: ' .. len(ast.body))
catch
  output->add('Parse error: ' .. v:exception)
endtry

writefile(output, 'test_parse_complex.log')
quit!
