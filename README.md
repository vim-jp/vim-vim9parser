# Vim9 Script Parser

Vim9script language parser that generates AST (Abstract Syntax Tree).

Compatible with vim-vimlparser for unified interface.

## Features

- Parse vim9script syntax including type annotations, classes, etc.
- Generate AST compatible with vim-vimlparser
- Support for vim9script specific features

## Supported Languages

- Vim9script (VimL with `:vim9script` declaration)

## Usage

```vim
let p = vim9parser#new()
let r = p.parse(stringreader)
let c = vim9parser#Compiler.new()
echo join(c.compile(r), "\n")
```

## Vim9Script Extensions

Compared to legacy VimL, vim9script adds:

- Type annotations for variables and functions
- Classes and objects
- New syntax: `var`, `const`, `def`, `class`
- No more `:` prefix for options access
- `import` and `export` statements

## Relation to vim-vimlparser

This parser is designed to be used alongside vim-vimlparser. It handles vim9script syntax while vim-vimlparser handles legacy VimL.

For projects supporting both, consider using a dispatcher that checks the script header and selects the appropriate parser.
