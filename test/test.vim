" Test for vim9parser
set nocompatible

let s:base = fnamemodify(resolve(expand('<sfile>')), ':h:h')
execute 'set runtimepath=' . s:base . ',' . &runtimepath

" Test: Parse simple vim9script
function! Test_parse_simple_var() abort
  let p = vim9parser#import()
  let reader = p.StringReader.new(['var x = 1'])
  let parser = p.Vim9Parser.new()
  let ast = parser.parse(reader)
  
  echo 'Test: Parse simple var'
  echo ast
  assert_equal(1, ast.type)  " NODE_TOPLEVEL
  assert_equal(1, len(ast.body))
endfunction

" Test: Parse function definition
function! Test_parse_def() abort
  let p = vim9parser#import()
  let lines = [
    \ 'def Add(x: number, y: number): number',
    \ '  return x + y',
    \ 'enddef',
    \ ]
  let reader = p.StringReader.new(lines)
  let parser = p.Vim9Parser.new()
  let ast = parser.parse(reader)
  
  echo 'Test: Parse def'
  echo ast
  assert_equal(1, ast.type)  " NODE_TOPLEVEL
  assert_equal(1, len(ast.body))
endfunction

call Test_parse_simple_var()
call Test_parse_def()

echo 'All tests passed!'
