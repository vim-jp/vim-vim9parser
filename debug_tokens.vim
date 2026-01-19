vim9script

import './autoload/vim9parser.vim' as v9p

var lines = readfile('test_no_comments.vim')
var reader = v9p.StringReader.new(lines)
var tokenizer = v9p.Vim9Tokenizer.new(reader)

echo 'First 20 tokens:'
for i in range(20)
  var tok = tokenizer.Get()
  if tok.type == 0
    echo 'EOF'
    break
  endif
  echo i .. ': type=' .. tok.type .. ' value="' .. tok.value .. '" (line ' .. tok.line .. ', col ' .. tok.col .. ')'
endfor

quit!
