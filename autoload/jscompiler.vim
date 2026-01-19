vim9script

# JavaScript Compiler for Vim9 Parser autoload module
import autoload 'vim9parser.vim'
import './vim9parser/jsc.vim'

export def ConvertToJS(input_file: string, output_file: string): void
  writefile(['DEBUG: Starting ConvertToJS'], '/tmp/jscompiler_debug.log')
  try
    writefile(['DEBUG: Reading file'], '/tmp/jscompiler_debug.log', 'a')
    var lines = readfile(input_file)
    
    writefile(['DEBUG: Creating reader'], '/tmp/jscompiler_debug.log', 'a')
    var reader = StringReader.new(lines)
    
    writefile(['DEBUG: Creating parser'], '/tmp/jscompiler_debug.log', 'a')
    var p = Vim9Parser.new()
    
    writefile(['DEBUG: Parsing...'], '/tmp/jscompiler_debug.log', 'a')
    var ast = p.Parse(reader)
    
    writefile(['DEBUG: Creating compiler'], '/tmp/jscompiler_debug.log', 'a')
    var compiler = jsc.JSCompiler.new()
    
    writefile(['DEBUG: Compiling...'], '/tmp/jscompiler_debug.log', 'a')
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
    writefile(['DEBUG: Success'], '/tmp/jscompiler_debug.log', 'a')
  catch
    writefile(['DEBUG: Error: ' .. v:exception], '/tmp/jscompiler_debug.log', 'a')
    throw 'Error compiling to JavaScript: ' .. v:exception
  endtry
enddef
