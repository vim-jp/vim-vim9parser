#!/bin/sh
cd "$(dirname "$0")/.."
vim -u NONE -i NONE -E -N -R -X --cmd 'set rtp+=.' -S jscompiler.vim -- "$@"
