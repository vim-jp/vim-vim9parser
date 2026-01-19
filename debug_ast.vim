vim9script

import './autoload/vim9parser.vim' as v9p

var lines = readfile('test_very_simple.vim')
var reader = v9p.StringReader.new(lines)
var p = v9p.Vim9Parser.new()
var ast = p.Parse(reader)

def PrintNode(node: dict<any>, indent: number = 0)
  var ind = repeat('  ', indent)
  if type(node) == v:t_dict
    for key in sort(keys(node))
      var val = node[key]
      if key == 'body'
        echo ind .. key .. ': [... ' .. len(val) .. ' items ...]'
      elseif type(val) == v:t_dict
        echo ind .. key .. ': {'
        PrintNode(val, indent + 1)
        echo ind .. '}'
      elseif type(val) == v:t_list
        echo ind .. key .. ': [' .. len(val) .. ' items]'
      else
        echo ind .. key .. ': ' .. string(val)
      endif
    endfor
  endif
enddef

echo 'AST Structure:'
echo 'Root node: type=' .. ast.type
echo 'Body items: ' .. len(ast.body)
for i in range(len(ast.body))
  echo ''
  echo 'Body[' .. i .. ']:'
  PrintNode(ast.body[i], 1)
endfor

quit!
