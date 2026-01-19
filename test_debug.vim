vim9script

try
  import './autoload/vim9parser.vim' as v9p
  echomsg 'vim9parser import successful'
  
  import './autoload/vim9parser/jsc.vim' as jsc
  echomsg 'jsc import successful'
catch
  echomsg 'Error: ' .. v:exception
  echomsg 'Throwpoint: ' .. v:throwpoint
endtry

qa!
