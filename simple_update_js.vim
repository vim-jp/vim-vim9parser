vim9script

import './autoload/vim9parser.vim' as v9p
import './autoload/vim9parser/jsc.vim' as jsc

var output: list<string> = ['Starting update_js...']

try
  output->add('Importing modules...')
  output->add('Reading vim9parser.vim...')
  var lines = readfile('autoload/vim9parser.vim')
  output->add('Read ' .. len(lines) .. ' lines')
  
  output->add('Creating StringReader...')
  var reader = v9p.StringReader.new(lines)
  output->add('Creating Vim9Parser...')
  var p = v9p.Vim9Parser.new()
  
  output->add('Parsing...')
  var ast = p.Parse(reader)
  output->add('Parse successful')
  
  output->add('Creating JSCompiler...')
  var compiler = jsc.JSCompiler.new()
  output->add('Compiling to JavaScript...')
  var js_lines = compiler.Compile(ast)
  output->add('Compilation successful: ' .. len(js_lines) .. ' lines')
  
  # Add headers and footers
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
  
  var final = header + js_lines + footer
  writefile(final, 'js/vim9parser.js')
  output->add('Written to js/vim9parser.js: ' .. len(final) .. ' total lines')
  
catch
  output->add('ERROR: ' .. v:exception)
  output->add('Throwpoint: ' .. v:throwpoint)
endtry

writefile(output, 'simple_update_js.log')
quit!
