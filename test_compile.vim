vim9script

var base = fnamemodify(resolve(expand('<sfile>')), ':h')
execute 'set runtimepath=' .. base .. ',' .. &runtimepath

var parser = vim9parser#Import()

var lines = readfile('autoload/vim9parser.vim')
var reader = parser.StringReader.new(lines)
var p = parser.Vim9Parser.new()
var ast = p.Parse(reader)

var compiler = parser.JSCompiler.new()
var js_lines = compiler.Compile(ast)

call writefile(js_lines, 'js/vim9parser.js')
echomsg 'JavaScript generated!'
quit!
