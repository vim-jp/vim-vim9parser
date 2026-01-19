vim9script

import './autoload/vim9parser.vim' as v9p

var test_code = [
  '# Comment at start',
  'var x = 42',
  '# Another comment',
  'const y = 10',
]

var reader = v9p.StringReader.new(test_code)
var tokenizer = v9p.Vim9Tokenizer.new(reader)

# Get first token
var tok = tokenizer.Get()
echo 'Token 1: ' .. tok.value .. ' (type ' .. tok.type .. ')'

# Get second token
tok = tokenizer.Get()
echo 'Token 2: ' .. tok.value .. ' (type ' .. tok.type .. ')'

quit!
