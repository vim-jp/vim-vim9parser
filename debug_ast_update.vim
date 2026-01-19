vim9script

import './autoload/vim9parser.vim' as v9p

var output: list<string> = ['Debugging AST...']

try
  var lines = readfile('test_very_simple.vim')
  output->add('Read ' .. len(lines) .. ' lines')
  
  var reader = v9p.StringReader.new(lines)
  var p = v9p.Vim9Parser.new()
  var ast = p.Parse(reader)
  
  output->add('Parse successful!')
  output->add('Body items: ' .. len(ast.body))
  
  for i in range(len(ast.body))
    var stmt = ast.body[i]
    output->add('Stmt ' .. i .. ': type=' .. stmt.type .. ' name=' .. stmt.name .. ' value=' .. get(stmt, 'value', ''))
  endfor
catch
  output->add('ERROR: ' .. v:exception)
endtry

writefile(output, 'debug_ast_update.log')
quit!
