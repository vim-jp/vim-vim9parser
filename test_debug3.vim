vim9script

var debug_file = 'debug_output.txt'
var debug_log = []

try
  debug_log->add('Starting jscompiler debug')
  
  import './autoload/vim9parser.vim' as v9p
  debug_log->add('vim9parser import successful')
  
  const args = argv()
  debug_log->add('argv length: ' .. len(args))
  var input_file = len(args) >= 1 ? args[0] : 'autoload/vim9parser.vim'
  var output_file = len(args) >= 2 ? args[1] : 'js/vim9parser.js'
  debug_log->add('input_file: ' .. input_file)
  debug_log->add('output_file: ' .. output_file)
  
  var lines = readfile(input_file)
  debug_log->add('file read: ' .. len(lines) .. ' lines')
  
  var reader = v9p.StringReader.new(lines)
  debug_log->add('StringReader created')
  
  var p = v9p.Vim9Parser.new()
  debug_log->add('Vim9Parser created')
  
  var ast = p.Parse(reader)
  debug_log->add('Parse completed')
  
  import './autoload/vim9parser/jsc.vim' as jsc
  debug_log->add('jsc import successful')
  
  var compiler = jsc.JSCompiler.new()
  debug_log->add('JSCompiler created')
  
  var js_lines = compiler.Compile(ast)
  debug_log->add('Compile completed: ' .. len(js_lines) .. ' lines')
  
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
  debug_log->add('Success! Output written to ' .. output_file)
  
catch
  debug_log->add('Error: ' .. v:exception)
  debug_log->add('Throwpoint: ' .. v:throwpoint)
endtry

writefile(debug_log, debug_file)
qa!
