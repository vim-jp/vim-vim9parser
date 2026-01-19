vim9script

var logfile = 'compile_full.log'
var log_lines = []

def Log(msg: string)
  log_lines->add(msg)
enddef

try
  Log('Starting full compilation of vim9parser.vim...')
  
  import './autoload/vim9parser.vim' as v9p
  Log('Imported parser')
  
  var lines = readfile('autoload/vim9parser.vim')
  Log('Read ' .. len(lines) .. ' lines from autoload/vim9parser.vim')
  
  var reader = v9p.StringReader.new(lines)
  Log('Created reader')
  
  var p = v9p.Vim9Parser.new()
  Log('Created parser')
  
  var ast = p.Parse(reader)
  Log('Parsed AST successfully')
  
  import './autoload/vim9parser/jsc.vim' as jsc
  Log('Imported JSCompiler')
  
  var compiler = jsc.JSCompiler.new()
  Log('Created compiler')
  
  var js_lines = compiler.Compile(ast)
  Log('Compiled to JavaScript: ' .. len(js_lines) .. ' lines')
  
  # Add header
  var header = [
    '// Generated JavaScript from Vim9 Script',
    '// Source: autoload/vim9parser.vim',
    '',
    '"use strict";',
    '',
  ]
  
  # Add footer
  var footer = [
    '',
    '// Export for Node.js',
    'if (typeof module !== "undefined" && module.exports) {',
    '  module.exports = {',
    '    // Add exports here',
    '  };',
    '}',
  ]
  
  var output_lines = header + js_lines + footer
  writefile(output_lines, 'js/vim9parser.js')
  Log('Written to js/vim9parser.js: ' .. len(output_lines) .. ' total lines')
  
  Log('First 10 lines of output:')
  for i in range(0, min([9, len(js_lines) - 1]))
    Log('  ' .. js_lines[i])
  endfor
  
catch
  Log('ERROR: ' .. v:exception)
  Log('THROWPOINT: ' .. v:throwpoint)
endtry

writefile(log_lines, logfile)
echo 'Log written to ' .. logfile

quit!
