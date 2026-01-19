#!/bin/bash
cd "$(dirname "$0")/.."

# Simply call vim with original arguments - fast enough
vim -u NONE -i NONE -E -N -R -X --cmd 'set rtp+=.' -S jscompiler_nodebug.vim -- "$@"
