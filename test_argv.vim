vim9script

const args = argv()
echomsg 'argv length: ' .. len(args)
for i in range(len(args))
  echomsg 'args[' .. i .. '] = ' .. args[i]
endfor

var input_file = len(args) >= 1 ? args[0] : 'autoload/vim9parser.vim'
var output_file = len(args) >= 2 ? args[1] : 'js/vim9parser.js'

echomsg 'input_file: ' .. input_file
echomsg 'output_file: ' .. output_file

qa!
