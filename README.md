# Vim9 Script Parser

A high-performance parser for Vim9script that generates Abstract Syntax Trees (AST).

## Project Goal

Enable **Vim9script support in [vim-language-server](https://github.com/iamcco/vim-language-server)** by providing:

1. **Accurate Vim9 syntax parsing** - Complete AST generation for all vim9script constructs
2. **Language Server integration** - Symbol tables and completion support for LSP clients
3. **Cooperative parsing** - Work alongside [vim-vimlparser](https://github.com/vim-jp/vim-vimlparser) in a dispatcher pattern for hybrid VimL/Vim9 files

### Vision: LSP Completion Flow

```
vim-language-server
    ↓
Detect language (vim9script vs legacy VimL)
    ↓
┌─────────────────────┬──────────────────────┐
├─ Legacy VimL ──────→ vim-vimlparser       │
└─ Vim9script ───────→ vim-vim9parser       │
                      (this project)         │
                      ↓                      │
                      AST generation        │
                      ↓                      │
                      Symbol Table          │
                      ↓                      │
                      Completion candidates │
└─────────────────────┴──────────────────────┘
```

## Supported Languages

- **Vim9script** - Modern Vim scripting language (with `:vim9script` declaration)

## Usage

### Parse Vim9 Script

```vim
let p = vim9parser#Import()
let lines = ['var x = 1 + 2']
let reader = p.StringReader.new(lines)
let parser = p.Vim9Parser.new()
let ast = parser.Parse(reader)
```

### Compile to AST Representation

```vim
let compiler = p.Compiler.new()
echo join(compiler.Compile(ast), "\n")
```

### Compile to JavaScript

```vim
let js_compiler = p.JSCompiler.new()
let js_lines = js_compiler.Compile(ast)
echo join(js_lines, "\n")
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
- **JavaScript Compiler**: Generate JavaScript code from Vim9 AST
  - `JSCompiler` class for transpiling to JavaScript
  - Support for variables, functions, classes, control flow
  - List comprehensions compile to JavaScript `.map()` and `.filter()`
  - Lambda expressions compile to arrow functions
- **Line Continuation**: Both explicit `\` continuation and operator-based continuation across lines
  - `var x = 1 +\` (explicit backslash)
  - `var x = 1 +` (operator-based, continues to next line)
  - Function calls and subscripts continue naturally across lines
- **Compound Assignment Operators**: `+=`, `-=`, `*=`, `/=`, `%=` are now fully supported
- **String Interpolation**: `$"Hello, {name}!"` syntax is now parsed (preserves interpolation expressions)
- **Error Recovery**: Parser now tracks errors without throwing immediately, allowing for multiple error reporting
- **Destructuring Assignment**: Both list `var [a, b] = [1, 2]` and dict `var {x, y} = dict` patterns
- **List Comprehensions**: `[for i in range(10): i * i]` and with filters `[for i in list if i > 5: i]`

## Known Limitations and TODO

### Unsupported Syntax

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

### Semantic Features (Critical for LSP)

- **Symbol Table**: ⚠️ **MISSING** - No tracking of defined functions/variables/classes (REQUIRED FOR COMPLETION)
- **Scope Resolution**: Not tracked - Variable/function scoping is not analyzed
- **Type Checking**: Type annotations are parsed but not validated
- **Undefined Reference Detection**: References to undefined symbols are not flagged

### Parsing Limitations

- **Incremental Parsing**: Not supported - full file re-parse on every change
- **Hybrid Files**: Limited support for files that mix legacy VimL and vim9script
- **Error Handling**: Limited error messages; parser stops at first syntax error

### Future Work (Prioritized for LSP Goal)

#### Phase 1: LSP Foundation (CRITICAL)
1. **Symbol Table Implementation** ⚠️ **HIGHEST PRIORITY**
   - **REQUIREMENT**: Must be compatible with vim-vimlparser Buffer interface
   - Implement `Vim9Buffer` class with same methods as vim-vimlparser's `Buffer`:
     - `getGlobalFunctions(): Record<string, IFunction[]>`
     - `getScriptFunctions(): Record<string, IFunction[]>`
     - `getGlobalIdentifiers(): Record<string, IIdentifier[]>`
     - `getLocalIdentifiers(): Record<string, IIdentifier[]>`
     - `getFunctionLocalIdentifierItems(line): CompletionItem[]`
   - Extract function definitions (name, args, startLine, startCol, endLine, endCol, range)
   - Extract variable declarations with scope (g:, s:, l:, a:, b:)
   - Track class/import definitions for vim9script
   - **Why**: vim-language-server expects this exact interface; without it, dispatcher pattern fails
   - **See**: [ANALYSIS.md](ANALYSIS.md) for detailed interface specification

2. **Scope Analysis**
   - Function-local scope vs script-level scope
   - Parameter binding in function context
   - Closure support for nested functions
   - **Why**: Avoid suggesting symbols from wrong scope

3. **Public LSP Interface**
   - Standardized API for vim-language-server integration
   - Return format compatible with LSP (SymbolInformation, CompletionItem)
   - Position-to-symbol lookup capability
   - **Why**: LSP clients need consistent interface

4. **Test Coverage for LSP Scenarios**
   - Completion in function bodies
   - Completion with imported symbols
   - Hover information for variables/functions
   - Go-to-definition support
   - **Why**: Verify LSP integration works end-to-end

#### Phase 2: Advanced Features
- Incremental parsing support for large files
- Hybrid file support (VimL + Vim9 in same file)
- Dict comprehensions: `{for k in list: k: value}`
- Full enum support with proper semantics
- Type aliases: `type MyList = list<string>`

#### Phase 3: Quality & Performance
- Extended test coverage
- Performance optimization for large files
- Better error messages and error recovery
- Code formatter based on AST

#### Phase 4: Optional Enhancements
- Type checking system
- Interface support
- Language Server Protocol reference implementation
- JavaScript compilation to production-grade code

## Contributing

Contributions are welcome! Please feel free to submit pull requests for:
- Bug fixes
- New feature implementations
- Test cases
- Documentation improvements

## Architecture & Integration

### Cooperative Parsing with vim-vimlparser

This parser is designed to work **alongside** vim-vimlparser in a dispatcher pattern:

```
┌─────────────────────────────────────┐
│  vim-language-server (dispatcher)   │
└────────────┬────────────────────────┘
             │
             ├─ Detect file type
             │
    ┌────────┴───────┐
    │                │
    v                v
vim9script      Legacy VimL
    │                │
    v                v
vim-vim9parser  vim-vimlparser
    │                │
    v                v
vim9 AST       VimL AST
    │                │
    └────────┬───────┘
             v
    Language Service Features
    (Completion, Hover, Go-to-def, etc.)
```

### Implementation Strategy

1. **Detection**: Check for `:vim9script` at file start or in first few lines
2. **Delegation**: Route to appropriate parser
3. **Symbol Integration**: Merge symbol tables from both parsers
4. **Unified LSP**: Return consistent LSP responses regardless of source language

### Current Status by Component

| Component | Status | Notes |
|-----------|--------|-------|
| Vim9 Parsing | ✅ Complete | All major syntax supported |
| vim9 AST | ✅ Complete | Node types defined |
| Symbol Table | ❌ **MISSING** | CRITICAL for LSP |
| Scope Analysis | ❌ **MISSING** | CRITICAL for Completion |
| LSP Interface | ❌ **MISSING** | Needs standardization |
| vim-vimlparser integration | 🚀 Pending | Requires dispatcher in vim-language-server |

## Testing

The parser includes comprehensive test coverage:

- **Syntax parsing tests** - All major vim9script constructs
- **Expression tests** - Operators, precedence, types
- **Feature tests** - Line continuation, comprehensions, destructuring, etc.
- **Compiler tests** - JavaScript code generation

Run all tests: `make test`
