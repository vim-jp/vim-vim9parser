vim9script

import './autoload/vim9parser.vim' as v9p
import './autoload/vim9parser/jsc.vim' as jsc

var log_lines: list<string> = []

def Log(msg: string)
  log_lines->add(msg)
  writefile(log_lines, 'update_js_debug.log')
enddef

try
  Log('Starting...')
  
  # Read file
  var lines = readfile('autoload/vim9parser.vim')
  Log('Read ' .. len(lines) .. ' lines')
  
  # Create reader
  Log('Creating StringReader...')
  var reader = v9p.StringReader.new(lines)
  Log('StringReader created')
  
  # Create parser
  Log('Creating parser...')
  var p = v9p.Vim9Parser.new()
  Log('Parser created')
  
  # Parse
  Log('Starting parse at ' .. strftime('%H:%M:%S'))
  var ast = p.Parse(reader)
  Log('Parse complete at ' .. strftime('%H:%M:%S'))
  
  # Compile
  Log('Creating compiler...')
  var compiler = jsc.JSCompiler.new()
  Log('Compiler created')
  
  Log('Starting compilation at ' .. strftime('%H:%M:%S'))
  var js_lines = compiler.Compile(ast)
  Log('Compilation complete at ' .. strftime('%H:%M:%S'))
  Log('Generated ' .. len(js_lines) .. ' lines of JavaScript')
  
catch
  Log('ERROR: ' .. v:exception)
  Log('Throwpoint: ' .. v:throwpoint)
endtry

quit!
