vim9script

import './autoload/vim9parser.vim' as v9p

var code = [
  'class Foo',
  '  def new()',
  '  enddef',
  'endclass',
]

var reader = v9p.StringReader.new(code)
var p = v9p.Vim9Parser.new()

try
  var ast = p.Parse(reader)
  writefile(['Parse successful!'], 'test_def_new.log')
catch
  var lines = [
    'Parse error: ' .. v:exception,
    'Throwpoint: ' .. v:throwpoint,
  ]
  writefile(lines, 'test_def_new.log')
endtry

quit!
