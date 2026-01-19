vim9script

var input_file = 'autoload/vim9parser.vim'
var output_file = 'autoload/vim9parser_nocomments.vim'

var lines = readfile(input_file)
var filtered = []

for line in lines
  var trimmed = substitute(line, '^\s*#.*$', '', '')
  if trimmed !~ '^\s*$'
    filtered->add(trimmed)
  elseif line =~ '^\s*#'
    # Skip pure comment lines
    continue
  else
    # Keep empty lines
    filtered->add(line)
  endif
endfor

writefile(filtered, output_file)
echo 'Removed comments: ' .. input_file .. ' -> ' .. output_file .. ' (' .. len(filtered) .. ' lines)'

quit!
