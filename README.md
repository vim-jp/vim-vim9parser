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
- Lambda expressions: `(x) => x * 2`
- Ternary operator: `condition ? true_val : false_val`
- Bitwise operators: `<<`, `>>`, `&`, `|`, `^`

## Supported Features

### Declarations
- `var` - variable declarations with optional type annotations
- `const` - constant declarations
- `def` / `enddef` - function definitions with parameter and return types
- `class` / `endclass` - class definitions

### Control Flow
- `if` / `elseif` / `else` / `endif`
- `while` / `endwhile`
- `for` / `endfor`
- `try` / `catch` / `finally` / `endtry`
- `return`

### Expressions
- Arithmetic operators: `+`, `-`, `*`, `/`, `%`
- Compound assignment operators: `+=`, `-=`, `*=`, `/=`, `%=`
- Comparison operators: `==`, `!=`, `<`, `>`, `<=`, `>=`
- Logical operators: `&&`, `||`, `!`
- Bitwise operators: `&`, `|`, `^`, `<<`, `>>`
- Ternary operator: `condition ? true_expr : false_expr`
- Member access: `obj.field`
- Array/Dict subscript: `arr[index]`, `dict[key]`
- Function call: `func(arg1, arg2)`
- Lambda expressions: `(x, y) => x + y`
- String interpolation: `$"Hello, {name}!"`
- List comprehensions: `[for i in range(10): i * i]`, `[for i in list if i > 5: i]`
- Destructuring assignment: `var [a, b] = [1, 2]`, `var {x, y} = dict`

### Literals
- Numbers: `42`, `3.14`
- Strings: `"hello"`, `'world'`
- Booleans: `true`, `false`
- Null: `null`
- Lists: `[1, 2, 3]`
- Dictionaries: `{key: value}`

### Module System
- `import` statements
- `export` declarations

## Recently Implemented Features

### Recently Added (Latest)
- **Compound Assignment Operators**: `+=`, `-=`, `*=`, `/=`, `%=` are now fully supported
- **String Interpolation**: `$"Hello, {name}!"` syntax is now parsed (preserves interpolation expressions)
- **Error Recovery**: Parser now tracks errors without throwing immediately, allowing for multiple error reporting
- **Destructuring Assignment**: Both list `var [a, b] = [1, 2]` and dict `var {x, y} = dict` patterns
- **List Comprehensions**: `[for i in range(10): i * i]` and with filters `[for i in list if i > 5: i]`

## Known Limitations and TODO

### Unsupported Syntax

#### Line Continuation
```vim
var long_expr = 1 +
  2 +     # May not parse correctly across lines
  3
```
Explicit line continuation with `\` or proper handling of operator-based continuation is not fully implemented.

#### Type Aliases
```vim
type MyList = list<string>  # Not supported
```

#### Interfaces
```vim
interface Drawable  # Not supported
  def Draw(): void
endinterface
```

#### Enum (Partial Support)
```vim
enum Color  # Token recognized but full semantics not implemented
  RED
  GREEN
  BLUE
endenum
```

#### Decorators/Annotations
```vim
@cached  # Not supported
def MyFunc(): void
enddef
```

### Semantic Features (Not Implemented)

- **Type Checking**: Type annotations are parsed but not validated
- **Scope Resolution**: Variable scoping is not tracked
- **Symbol Table**: No tracking of defined functions/variables/classes
- **Undefined Reference Detection**: References to undefined symbols are not flagged

### Error Handling Limitations

- **Limited Error Messages**: Errors may not always indicate what was expected
- **No Warnings**: No detection of unused variables, unreachable code, etc.

### Future Enhancements

1. **High Priority**
   - Better line continuation handling
   - Extended test coverage

2. **Medium Priority**
   - Dict comprehensions: `{for k in list: k: value}`
   - Full enum support with proper semantics
   - Type aliases: `type MyList = list<string>`

3. **Low Priority**
   - Type checking system
   - Interface support
   - Language Server Protocol (LSP) integration
   - Code formatter based on AST
   - Scope resolution and symbol tracking

## Contributing

Contributions are welcome! Please feel free to submit pull requests for:
- Bug fixes
- New feature implementations
- Test cases
- Documentation improvements

## Relation to vim-vimlparser

This parser is designed to be used alongside vim-vimlparser. It handles vim9script syntax while vim-vimlparser handles legacy VimL.

For projects supporting both, consider using a dispatcher that checks the script header and selects the appropriate parser.
