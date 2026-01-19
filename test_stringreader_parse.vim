vim9script

import './autoload/vim9parser.vim' as v9p

var code = [
  'export class StringReader',
  '   var lines: list<string>',
  '   var line: number = 0',
  '   var col: number = 0',
  '   var current_line: string = \'\'',
  '   ',
  '   def new(lines: list<string>)',
  '     this.lines = lines',
  '   enddef',
  'endclass',
]

var reader = v9p.StringReader.new(code)
var p = v9p.Vim9Parser.new()

try
  var ast = p.Parse(reader)
  writefile(['Parse successful!'], 'test_stringreader_parse.log')
catch
  var lines = [
    'Parse error: ' .. v:exception,
  ]
  writefile(lines, 'test_stringreader_parse.log')
endtry

quit!
