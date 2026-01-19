vim9script

import './autoload/vim9parser.vim' as v9p

var output: list<string> = ['Testing full parser.vim...']

try
  output->add('Reading autoload/vim9parser.vim...')
  var lines = readfile('autoload/vim9parser.vim')
  output->add('File has ' .. len(lines) .. ' lines')
  
  output->add('Creating StringReader...')
  var reader = v9p.StringReader.new(lines)
  output->add('Creating Vim9Parser...')
  var p = v9p.Vim9Parser.new()
  
  output->add('Starting parse at line 1...')
  var ast = p.Parse(reader)
  output->add('Parse successful!')
  output->add('AST body items: ' .. len(ast.body))
catch
  output->add('Parse error: ' .. v:exception)
  output->add('Throwpoint: ' .. v:throwpoint)
endtry

writefile(output, 'test_parse_full.log')
quit!
