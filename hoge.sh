#!/bin/sh
cd /home/mattn/.vim/plugged/vim-vim9parser && rm debug_output.txt 2>/dev/null; vim -u NONE -i NONE -E -N -R -X --cmd 'set rtp+=.' -S test_debug3.vim -- autoload/vim9parser.vim js/vim9parser.js 2>&1; cat debug_output.txt
