vim9script
import './autoload/vim9parser.vim' as v9p
import './autoload/vim9parser/jsc.vim' as jsc

echo "v9p type: " .. typename(v9p)
echo "StringReader type: " .. typename(v9p.StringReader)
