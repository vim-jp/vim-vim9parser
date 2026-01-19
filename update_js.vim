vim9script

import './autoload/vim9parser.vim' as v9p
import './autoload/vim9parser/jsc.vim' as jsc

var log_lines: list<string> = []
var js_lines: list<string> = []

try
  # Read and parse test_very_simple.vim
  var lines = readfile('test_very_simple.vim')
  log_lines->add('Read ' .. len(lines) .. ' lines')
  
  var reader = v9p.StringReader.new(lines)
  var p = v9p.Vim9Parser.new()
  log_lines->add('Starting parse...')
  
  var ast = p.Parse(reader)
  log_lines->add('Parse complete, compiling to JavaScript...')
  
  # Compile to JavaScript
  var compiler = jsc.JSCompiler.new()
  js_lines = compiler.Compile(ast)
  log_lines->add('Compiled to JavaScript: ' .. len(js_lines) .. ' lines')
catch
  log_lines->add('ERROR: ' .. v:exception)
  log_lines->add('Throwpoint: ' .. v:throwpoint)
  
  # Write log and quit
  writefile(log_lines, 'update_js.log')
  quit!
endtry

# Create output with header and footer
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
echo 'vim9parser.js updated: ' .. len(output) .. ' lines'

quit!
