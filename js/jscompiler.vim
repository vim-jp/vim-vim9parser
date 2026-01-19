vim9script

# JavaScript Compiler for Vim9 Parser
# This script converts vim9parser AST to JavaScript

def ConvertToJS(input_file: string, output_file: string): void
  var base = fnamemodify(resolve(expand('<sfile>')), ':h:h')
  execute 'set runtimepath=' .. base .. ',' .. &runtimepath
  
  try
    # Import the parser and compiler
    var parser = vim9parser#Import()
    
    # Read the vim9 script file
    var lines = readfile(input_file)
    
    # Parse it
    var reader = parser.StringReader.new(lines)
    var p = parser.Vim9Parser.new()
    var ast = p.Parse(reader)
    
    # Compile to JavaScript
    var compiler = parser.JSCompiler.new()
    var js_lines = compiler.Compile(ast)
    
    # Prepare header and footer
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
    
    # Write the output file
    writefile(header + js_lines + footer, output_file)
  catch
    throw 'Error compiling to JavaScript: ' .. v:exception
  endtry
enddef

def ParseArgs(): list<string>
  var v = [
    fnamemodify(expand('<sfile>'), ':h:h') .. '/autoload/vim9parser.vim',
    fnamemodify(expand('<sfile>'), ':h') .. '/vim9parser.js'
  ]
  var args = argv()[1:]
  if len(args) != 0
    if len(args) != 2
      throw 'invalid argument: ' .. string(args)
    endif
    v = args
  endif
  return v
enddef

def Main(): void
  try
    var args = ParseArgs()
    ConvertToJS(args[0], args[1])
  catch
    echoerr v:exception
    cquit!
  endtry
enddef

Main()
