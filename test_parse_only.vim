vim9script

try
  import './autoload/vim9parser.vim' as v9p
  
  var lines = readfile('autoload/vim9parser.vim')
  var reader = v9p.StringReader.new(lines)
  var p = v9p.Vim9Parser.new()
  
  var ast = p.Parse(reader)
  
  writefile(['Parse successful!', 'AST created with ' .. len(ast.body) .. ' top-level statements'], 'parse_result.txt')
  
catch
  writefile(['Parse failed:', 'Error: ' .. v:exception, 'Throwpoint: ' .. v:throwpoint], 'parse_result.txt')
endtry

qa!
