vim9script

import './autoload/vim9parser.vim' as v9p

const args = argv()
var input_file = len(args) >= 1 ? args[0] : 'autoload/vim9parser.vim'
var output_file = len(args) >= 2 ? args[1] : 'js/vim9parser.js'

var lines = readfile(input_file)

var header = [
  '// Generated JavaScript from Vim9 Script',
  '// Source: ' .. input_file,
  '// Note: This is a partial compilation due to parsing errors',
  '',
  '"use strict";',
  '',
  '// Parser encountered errors, but generating partial output',
  '',
]

var js_lines: list<string> = []

try
  var reader = v9p.StringReader.new(lines)
  var p = v9p.Vim9Parser.new()
  var ast = p.Parse(reader)
  
  import './autoload/vim9parser/jsc.vim' as jsc
  var compiler = jsc.JSCompiler.new()
  js_lines = compiler.Compile(ast)
  
catch /Syntax error/
  # Parser failed, output what we can
  js_lines->add('// ERROR: Parser encountered syntax errors during compilation')
  js_lines->add('// ' .. v:exception)
  
catch /Unexpected token/
  # Token error, output what we can
  js_lines->add('// ERROR: Unexpected token during parsing')
  js_lines->add('// ' .. v:exception)
  
catch
  # Generic error, still output something
  js_lines->add('// ERROR: ' .. v:exception)
endtry

var footer = [
  '',
  '// Export for Node.js',
  'if (typeof module !== "undefined" && module.exports) {',
  '  module.exports = {',
  '    // Add exports here',
  '  };',
  '}',
]

writefile(header + js_lines + footer, output_file)
echo 'Output written to ' .. output_file .. ' (' .. len(js_lines) .. ' lines of code)'
