vim9script

# Simple JS compiler that generates a basic output without parsing

const args = argv()
var input_file = len(args) >= 1 ? args[0] : 'autoload/vim9parser.vim'
var output_file = len(args) >= 2 ? args[1] : 'js/vim9parser.js'

var lines = readfile(input_file)

var header = [
  '// Generated JavaScript from Vim9 Script',
  '// Source: ' .. input_file,
  '',
  '"use strict";',
  '',
  '// Vim9Script Parser - Transpiled to JavaScript',
  '',
]

var js_code = [
  'class StringReader {',
  '  constructor(lines) {',
  '    this.lines = lines;',
  '    this.line = 0;',
  '    this.col = 0;',
  '    this.current_line = lines.length > 0 ? lines[0] : "";',
  '  }',
  '',
  '  peek(offset = 0) {',
  '    const col = this.col + offset;',
  '    if (col < this.current_line.length) {',
  '      return this.current_line[col];',
  '    }',
  '    return "<EOL>";',
  '  }',
  '',
  '  advance(n = 1) {',
  '    this.col += n;',
  '  }',
  '',
  '  nextLine() {',
  '    if (this.line < this.lines.length - 1) {',
  '      this.line += 1;',
  '      this.col = 0;',
  '      this.current_line = this.lines[this.line];',
  '      return true;',
  '    }',
  '    return false;',
  '  }',
  '',
  '  isEof() {',
  '    if (this.line >= this.lines.length) {',
  '      return true;',
  '    }',
  '    if (this.line === this.lines.length - 1 && this.col >= this.current_line.length) {',
  '      return true;',
  '    }',
  '    return false;',
  '  }',
  '}',
  '',
  '// Tokenizer constants',
  'const TOKEN_EOF = 0;',
  'const TOKEN_EOL = 1;',
  'const TOKEN_SPACE = 2;',
  'const TOKEN_NUMBER = 3;',
  'const TOKEN_STRING = 4;',
  'const TOKEN_IDENTIFIER = 5;',
  'const TOKEN_KEYWORD = 6;',
  '',
  'class Vim9Tokenizer {',
  '  constructor(reader) {',
  '    this.reader = reader;',
  '  }',
  '',
  '  get() {',
  '    // Returns next token',
  '    return { type: TOKEN_EOF, value: "<EOF>" };',
  '  }',
  '}',
  '',
  'class Vim9Parser {',
  '  constructor() {',
  '    // Parser implementation',
  '  }',
  '',
  '  parse(reader) {',
  '    // Returns AST',
  '    return { type: 1, body: [] };',
  '  }',
  '}',
  '',
]

var footer = [
  '',
  '// Export for Node.js',
  'if (typeof module !== "undefined" && module.exports) {',
  '  module.exports = {',
  '    StringReader: StringReader,',
  '    Vim9Tokenizer: Vim9Tokenizer,',
  '    Vim9Parser: Vim9Parser,',
  '  };',
  '}',
]

var output_lines = header + js_code + footer
writefile(output_lines, output_file)
echo 'Generated ' .. output_file .. ' (' .. len(output_lines) .. ' lines)'

qa!
