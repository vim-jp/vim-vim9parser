vim9script

try
  import './autoload/vim9parser.vim' as v9p
  echomsg 'vim9parser import successful'
  
  var lines = readfile('autoload/vim9parser.vim')
  echomsg 'file read: ' .. len(lines) .. ' lines'
  
  var reader = v9p.StringReader.new(lines)
  echomsg 'StringReader created'
  
  var p = v9p.Vim9Parser.new()
  echomsg 'Vim9Parser created'
  
  var ast = p.Parse(reader)
  echomsg 'Parse completed'
  
  import './autoload/vim9parser/jsc.vim' as jsc
  echomsg 'jsc import successful'
  
  var compiler = jsc.JSCompiler.new()
  echomsg 'JSCompiler created'
  
  var js_lines = compiler.Compile(ast)
  echomsg 'Compile completed: ' .. len(js_lines) .. ' lines'
  
catch
  echomsg 'Error: ' .. v:exception
  echomsg 'Throwpoint: ' .. v:throwpoint
endtry

qa!
