vim9script

try
  import './autoload/vim9parser.vim' as v9p
  
  var lines = readfile('/tmp/test_vim9.vim')
  var reader = v9p.StringReader.new(lines)
  var p = v9p.Vim9Parser.new()
  
  var ast = p.Parse(reader)
  
  writefile(['Parse successful!'], 'parse_minimal.txt')
  
catch
  writefile(['Parse failed:', 'Error: ' .. v:exception, 'Throwpoint: ' .. v:throwpoint], 'parse_minimal.txt')
endtry

qa!
