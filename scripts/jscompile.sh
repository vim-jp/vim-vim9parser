#!/bin/bash
cd "$(dirname "$0")/.."

# Just call vim directly - jscompiler.vim will handle errors gracefully
vim -u NONE -i NONE -E -N -R -X --cmd 'set rtp+=.' -S jscompiler.vim -- "$@"
