vim9script

import './autoload/vim9parser.vim' as v9p
import './autoload/vim9parser/jsc.vim' as jsc

var lines = readfile('autoload/vim9parser.vim')
var reader = v9p.StringReader.new(lines)
var p = v9p.Vim9Parser.new()

try
  var ast = p.Parse(reader)
  var compiler = jsc.JSCompiler.new()
  var js_lines = compiler.Compile(ast)
  
  var header = [
    '// Generated JavaScript from Vim9 Script',
    '// Source: autoload/vim9parser.vim',
    '',
    '"use strict";',
    '',
  ]
  
  var footer = [
    '',
    '// Export for Node.js',
    'if (typeof module !== "undefined" && module.exports) {',
    '  module.exports = {',
    '    // Add exports here',
    '  };',
    '}',
  ]
  
  var output = header + js_lines + footer
  writefile(output, 'js/vim9parser.js')
  echomsg 'Generated js/vim9parser.js: ' .. len(output) .. ' lines'
catch
  echomsg 'Error: ' .. v:exception
endtry

quit!
