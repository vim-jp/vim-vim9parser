vim9script

" Redirect output to file
set redir=/tmp/vim_test_output.txt

try
  echomsg 'Starting test...'
  
  # Try to import
  import '/home/mattn/.vim/plugged/vim-vim9parser/autoload/vim9parser.vim' as parser
  echomsg 'Import successful'
  
  # Try to create StringReader
  var reader = parser.StringReader.new(['var x = 1 + 2'])
  echomsg 'StringReader created'
  
  # Try to create Parser
  var p = parser.Vim9Parser.new()
  echomsg 'Parser created'
  
  # Try to parse
  var ast = p.Parse(reader)
  echomsg 'Parse successful'
  echomsg 'AST body length: ' .. len(ast.body)
  
  if len(ast.body) > 0
    echomsg 'Test PASSED'
  else
    echomsg 'Test FAILED: Empty AST'
  endif
  
catch
  echomsg 'ERROR: ' .. v:exception
  echomsg 'THROWPOINT: ' .. v:throwpoint
endtry

set redir&
quit!
