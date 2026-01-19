vim9script

import 'autoload/vim9parser.vim' as v9p
import 'autoload/vim9parser/jsc.vim' as jsc

var lines = readfile('autoload/vim9parser.vim')

var reader = v9p.StringReader.new(lines)
var p = v9p.Vim9Parser.new()
var ast = p.parse(reader)

var compiler = jsc.JSCompiler.new()
var js_lines = compiler.Compile(ast)

writefile(js_lines, 'js/vim9parser.js')
echo 'Compiled ' .. len(js_lines) .. ' lines to js/vim9parser.js'
quit!
