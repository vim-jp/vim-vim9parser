vim9script

import "./autoload/vim9parser.vim" as p
var lines = ['var x = 1 + 2']
var reader = p.StringReader.new(lines)
var parser = p.Vim9Parser.new()
var ast = parser.Parse(reader)
echo ast
