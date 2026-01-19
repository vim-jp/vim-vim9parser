vim9script

try
  import './autoload/vim9parser.vim' as v9p
  
  var lines = readfile('autoload/vim9parser.vim')
  var reader = v9p.StringReader.new(lines)
  var p = v9p.Vim9Parser.new()
  
  # Parse the first few statements manually
  p.current_token = p.tokenizer.Get()
  p.next_token = p.tokenizer.Get()
  
  var stmt_count = 0
  while p.current_token.type != v9p.TOKEN_EOF && stmt_count < 5
    writefile(['Parsing statement ' .. stmt_count .. ': line ' .. p.reader.line .. ', token=' .. p.current_token.value], 'debug_parser.txt', 'a')
    stmt_count += 1
  endwhile
  
catch
  writefile(['Error: ' .. v:exception, 'Throwpoint: ' .. v:throwpoint], 'debug_parser.txt', 'a')
endtry

qa!
