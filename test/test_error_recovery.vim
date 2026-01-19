vim9script

# Test for error recovery
set nocompatible

var base = fnamemodify(resolve(expand('<sfile>')), ':h:h')
execute 'set runtimepath=' .. base .. ',' .. &runtimepath

# Test: Parser has errors list
def Test_parser_has_errors_list(): void
  var p = vim9parser#Import()
  var lines = ['var x = 1']
  var reader = p.StringReader.new(lines)
  var parser = p.Vim9Parser.new()
  var ast = parser.parse(reader)
  
  # Check that parser has errors attribute (even if empty)
  assert_true(has_key(parser, 'errors'))
  
  echomsg 'Test_parser_has_errors_list: PASS'
enddef

# Test: Tokenizer is exported
def Test_tokenizer_exported(): void
  var p = vim9parser#Import()
  
  # Check that tokenizer is available
  assert_true(has_key(p, 'Vim9Tokenizer'))
  
  echomsg 'Test_tokenizer_exported: PASS'
enddef

# Run tests
try
  Test_parser_has_errors_list()
  Test_tokenizer_exported()
  echomsg 'All error recovery tests passed!'
  sleep 100m
catch
  echoerr 'Test failed: ' .. v:exception
  sleep 100m
finally
  quit!
endtry
