vim9script

import './autoload/vim9parser.vim' as v9p

const args = argv()
var input_file = len(args) >= 1 ? args[0] : 'autoload/vim9parser.vim'
var output_file = len(args) >= 2 ? args[1] : 'js/vim9parser.js'

try
  var lines = readfile(input_file)
  
  var reader = v9p.StringReader.new(lines)
  var p = v9p.Vim9Parser.new()
  var ast = p.Parse(reader)
  
  import './autoload/vim9parser/jsc.vim' as jsc
  var compiler = jsc.JSCompiler.new()
  var js_lines = compiler.Compile(ast)
  
  var header = [
    '// Generated JavaScript from Vim9 Script',
    '// Source: ' .. input_file,
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
  
  writefile(header + js_lines + footer, output_file)
  echo 'Success! Output written to ' .. output_file
catch
  echoerr 'Error: ' .. v:exception
  echoerr 'Throwpoint: ' .. v:throwpoint
endtry
