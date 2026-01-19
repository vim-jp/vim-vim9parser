vim9script

var logfile = 'compile_debug.log'
var log_lines = []

def Log(msg: string)
  log_lines->add(msg)
enddef

try
  Log('Starting compile...')
  
  import './autoload/vim9parser.vim' as v9p
  Log('Imported parser')
  
  var lines = ['var x = 42']
  Log('Created test lines')
  
  var reader = v9p.StringReader.new(lines)
  Log('Created reader')
  
  var p = v9p.Vim9Parser.new()
  Log('Created parser')
  
  var ast = p.Parse(reader)
  Log('Parsed AST')
  
  import './autoload/vim9parser/jsc.vim' as jsc
  Log('Imported JSCompiler')
  
  var compiler = jsc.JSCompiler.new()
  Log('Created compiler')
  
  var js_lines = compiler.Compile(ast)
  Log('Compiled to JS: ' .. len(js_lines) .. ' lines')
  
  Log('--- JavaScript Output ---')
  for line in js_lines
    Log(line)
  endfor
  
catch
  Log('ERROR: ' .. v:exception)
  Log('THROWPOINT: ' .. v:throwpoint)
endtry

writefile(log_lines, logfile)
echo 'Log written to ' .. logfile

quit!
