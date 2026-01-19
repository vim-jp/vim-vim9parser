vim9script

import './autoload/vim9parser.vim' as v9p

var output: list<string> = ['Testing parse...']

try
  output->add('Creating StringReader...')
  var lines = ['var x = 1']
  var reader = v9p.StringReader.new(lines)
  output->add('Creating Vim9Parser...')
  var p = v9p.Vim9Parser.new()
  
  output->add('Parsing: var x = 1')
  var ast = p.Parse(reader)
  output->add('Parse successful!')
  output->add('AST body items: ' .. len(ast.body))
catch
  output->add('Parse error: ' .. v:exception)
  output->add('Throwpoint: ' .. v:throwpoint)
endtry

writefile(output, 'test_parse_simple.log')
quit!
