vim9script

# Test for vim9parser tokenizer
set nocompatible

var base = fnamemodify(resolve(expand('<sfile>')), ':h:h')
execute 'set runtimepath=' .. base .. ',' .. &runtimepath

# Test: Tokenize simple var declaration
def Test_tokenize_var_declaration(): void
  var p = vim9parser#import()
  var lines = ['var x: number = 1']
  var reader = p.StringReader.new(lines)
  var tokenizer = p.Vim9Tokenizer.new(reader)
  
  var tok1 = tokenizer.get()
  assert_equal(p.TOKEN_KEYWORD, tok1.type)
  assert_equal('var', tok1.value)
  
  var tok2 = tokenizer.get()
  assert_equal(p.TOKEN_IDENTIFIER, tok2.type)
  assert_equal('x', tok2.value)
  
  var tok3 = tokenizer.get()
  assert_equal(p.TOKEN_COLON, tok3.type)
  assert_equal(':', tok3.value)
  
  var tok4 = tokenizer.get()
  assert_equal(p.TOKEN_KEYWORD, tok4.type)
  assert_equal('number', tok4.value)
  
  var tok5 = tokenizer.get()
  assert_equal(p.TOKEN_EQ, tok5.type)
  assert_equal('=', tok5.value)
  
  var tok6 = tokenizer.get()
  assert_equal(p.TOKEN_NUMBER, tok6.type)
  assert_equal('1', tok6.value)
  
  var tok7 = tokenizer.get()
  assert_equal(p.TOKEN_EOF, tok7.type)
  
  echomsg 'Test_tokenize_var_declaration: PASS'
enddef

# Test: Tokenize def function
def Test_tokenize_def(): void
  var p = vim9parser#import()
  var lines = ['def Add(x: number, y: number): number']
  var reader = p.StringReader.new(lines)
  var tokenizer = p.Vim9Tokenizer.new(reader)
  
  var tokens: list<dict<any>> = []
  while true
    var tok = tokenizer.get()
    tokens->add(tok)
    if tok.type == p.TOKEN_EOF
      break
    endif
  endwhile
  
  assert_equal('def', tokens[0].value)
  assert_equal('Add', tokens[1].value)
  assert_equal('(', tokens[2].value)
  assert_equal('x', tokens[3].value)
  assert_equal(':', tokens[4].value)
  
  echomsg 'Test_tokenize_def: PASS'
enddef

# Test: Tokenize operators
def Test_tokenize_operators(): void
  var p = vim9parser#import()
  var lines = ['x + y == 1 && z >= 2']
  var reader = p.StringReader.new(lines)
  var tokenizer = p.Vim9Tokenizer.new(reader)
  
  var tokens: list<dict<any>> = []
  while true
    var tok = tokenizer.get()
    tokens->add(tok)
    if tok.type == p.TOKEN_EOF
      break
    endif
  endwhile
  
  assert_equal(p.TOKEN_IDENTIFIER, tokens[0].type)
  assert_equal(p.TOKEN_PLUS, tokens[1].type)
  assert_equal(p.TOKEN_IDENTIFIER, tokens[2].type)
  assert_equal(p.TOKEN_EQEQ, tokens[3].type)
  assert_equal(p.TOKEN_NUMBER, tokens[4].type)
  assert_equal(p.TOKEN_AND, tokens[5].type)
  assert_equal(p.TOKEN_IDENTIFIER, tokens[6].type)
  assert_equal(p.TOKEN_GTEQ, tokens[7].type)
  assert_equal(p.TOKEN_NUMBER, tokens[8].type)
  
  echomsg 'Test_tokenize_operators: PASS'
enddef

# Test: Tokenize string
def Test_tokenize_string(): void
  var p = vim9parser#import()
  var lines = ['var s = "hello world"']
  var reader = p.StringReader.new(lines)
  var tokenizer = p.Vim9Tokenizer.new(reader)
  
  var tokens: list<dict<any>> = []
  while true
    var tok = tokenizer.get()
    tokens->add(tok)
    if tok.type == p.TOKEN_EOF
      break
    endif
  endwhile
  
  assert_equal(p.TOKEN_KEYWORD, tokens[0].type)  # var
  assert_equal(p.TOKEN_IDENTIFIER, tokens[1].type)  # s
  assert_equal(p.TOKEN_EQ, tokens[2].type)  # =
  assert_equal(p.TOKEN_STRING, tokens[3].type)  # "hello world"
  assert_equal('hello world', tokens[3].value)
  
  echomsg 'Test_tokenize_string: PASS'
enddef

# Run tests
try
  Test_tokenize_var_declaration()
  Test_tokenize_def()
  Test_tokenize_operators()
  Test_tokenize_string()
  echomsg 'All tokenizer tests passed!'
  sleep 100m
catch
  echoerr 'Test failed: ' .. v:exception
  sleep 100m
finally
  quit!
endtry
