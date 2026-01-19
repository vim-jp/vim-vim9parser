// Generated JavaScript from Vim9 Script
// Source: autoload/vim9parser.vim

"use strict";

// Token type constants
const TOKEN_EOF = 0;
const TOKEN_EOL = 1;
const TOKEN_SPACE = 2;
const TOKEN_NUMBER = 3;
const TOKEN_STRING = 4;
const TOKEN_IDENTIFIER = 5;
const TOKEN_KEYWORD = 6;
const TOKEN_COLON = 7;
const TOKEN_COMMA = 8;
const TOKEN_SEMICOLON = 9;
const TOKEN_POPEN = 10;
const TOKEN_PCLOSE = 11;
const TOKEN_SQOPEN = 12;
const TOKEN_SQCLOSE = 13;
const TOKEN_COPEN = 14;
const TOKEN_CCLOSE = 15;
const TOKEN_DOT = 16;
const TOKEN_ARROW = 17;
const TOKEN_PLUS = 18;
const TOKEN_MINUS = 19;
const TOKEN_STAR = 20;
const TOKEN_SLASH = 21;
const TOKEN_PERCENT = 22;
const TOKEN_EQ = 23;
const TOKEN_EQEQ = 24;
const TOKEN_NEQ = 25;
const TOKEN_LT = 26;
const TOKEN_LTEQ = 27;
const TOKEN_GT = 28;
const TOKEN_GTEQ = 29;
const TOKEN_AND = 30;
const TOKEN_OR = 31;
const TOKEN_NOT = 32;
const TOKEN_QUESTION = 33;
const TOKEN_AMPERSAND = 34;
const TOKEN_DOTDOTDOT = 35;
const TOKEN_AT = 36;
const TOKEN_SHARP = 37;
const TOKEN_PIPE = 38;
const TOKEN_CARET = 39;
const TOKEN_LSHIFT = 40;
const TOKEN_RSHIFT = 41;
const TOKEN_PLUSEQ = 42;
const TOKEN_MINUSEQ = 43;
const TOKEN_STAREQ = 44;
const TOKEN_SLASHEQ = 45;
const TOKEN_PERCENTEQ = 46;

// Node type constants
const NODE_TOPLEVEL = 1;
const NODE_COMMENT = 2;
const NODE_EXCMD = 3;
const NODE_FUNCTION = 4;
const NODE_ENDFUNCTION = 5;
const NODE_DELFUNCTION = 6;
const NODE_RETURN = 7;
const NODE_EXCALL = 8;
const NODE_LET = 9;
const NODE_UNLET = 10;
const NODE_LOCKVAR = 11;
const NODE_UNLOCKVAR = 12;
const NODE_IF = 13;
const NODE_ELSEIF = 14;
const NODE_ELSE = 15;
const NODE_ENDIF = 16;
const NODE_WHILE = 17;
const NODE_ENDWHILE = 18;
const NODE_FOR = 19;
const NODE_ENDFOR = 20;
const NODE_CONTINUE = 21;
const NODE_BREAK = 22;
const NODE_TRY = 23;
const NODE_CATCH = 24;
const NODE_FINALLY = 25;
const NODE_ENDTRY = 26;
const NODE_THROW = 27;
const NODE_ECHO = 28;
const NODE_ECHON = 29;
const NODE_ECHOHL = 30;
const NODE_ECHOMSG = 31;
const NODE_ECHOERR = 32;
const NODE_EXECUTE = 33;
const NODE_TERNARY = 34;
const NODE_OR = 35;
const NODE_AND = 36;
const NODE_EQUAL = 37;
const NODE_NEQ = 38;
const NODE_GREATER = 39;
const NODE_GEQUAL = 40;
const NODE_SMALLER = 41;
const NODE_SEQUAL = 42;
const NODE_MATCH = 43;
const NODE_NOMATCH = 44;
const NODE_IS = 45;
const NODE_ISNOT = 46;
const NODE_PLUS = 47;
const NODE_MINUS = 48;
const NODE_DOT = 49;
const NODE_CONCAT = 50;
const NODE_STAR = 51;
const NODE_DIVIDE = 52;
const NODE_PERCENT = 53;
const NODE_NOT = 54;
const NODE_MINUS_UNARY = 55;
const NODE_PLUS_UNARY = 56;
const NODE_SUBSCRIPT = 57;
const NODE_SLICE = 58;
const NODE_GETATTR = 59;
const NODE_GETITEM = 60;
const NODE_LIST = 61;
const NODE_DICT = 62;
const NODE_STRING = 63;
const NODE_NUMBER = 64;
const NODE_FLOAT = 65;
const NODE_OPTION = 66;
const NODE_ENV = 67;
const NODE_REG = 68;
const NODE_CALL = 69;
const NODE_METHOD = 70;
const NODE_INDEX = 71;
const NODE_SLICE2 = 72;
const NODE_MEMBER = 73;
const NODE_COND = 74;
const NODE_COND_AND = 75;
const NODE_COND_OR = 76;
const NODE_NAME = 77;
const NODE_DLIST = 78;
const NODE_OP = 79;
const NODE_CMP = 80;
const NODE_UNKNOWN = 81;
const NODE_NESTED_FUNC = 82;
const NODE_YIELD = 83;
const NODE_GETINDEX = 84;
const NODE_CLASS = 205;
const NODE_OBJECT = 206;
const NODE_CLASSDEF = 207;
const NODE_IMPLEMENTS = 208;
const NODE_IMPORT = 209;
const NODE_EXPORT = 210;
const NODE_ENUM = 211;
const NODE_ENDENUM = 212;
const NODE_TYPE = 213;
const NODE_ADD = 300;
const NODE_SUBTRACT = 301;
const NODE_MULTIPLY = 302;
const NODE_DIVIDE = 303;
const NODE_MODULO = 304;
const NODE_NUMBER_LIT = 305;
const NODE_STRING_LIT = 306;
const NODE_IDENTIFIER = 307;
const NODE_TRUE = 308;
const NODE_FALSE = 309;
const NODE_NULL = 310;
const NODE_LIST_LIT = 311;
const NODE_DICT_LIT = 312;
const NODE_CALL_EXPR = 313;
const NODE_DOT_EXPR = 314;
const NODE_SUBSCRIPT_EXPR = 315;
const NODE_NOT_EXPR = 316;
const NODE_LAMBDA = 317;
const NODE_BIT_OR = 318;
const NODE_BIT_XOR = 319;
const NODE_BIT_AND = 320;
const NODE_LSHIFT = 321;
const NODE_RSHIFT = 322;
const NODE_EOF = 323;

// StringReader class
class StringReader {
  constructor(lines) {
    this.lines = lines.map(l => l.replace(/^\s*$/, ''));
    this.line = 0;
    this.col = 0;
    this.current_line = this.lines.length > 0 ? this.lines[0] : '';
  }

  peek(offset = 0) {
    const col = this.col + offset;
    if (col < this.current_line.length) {
      return this.current_line[col];
    }
    return '<EOL>';
  }

  peekn(n) {
    const end = this.col + n;
    if (end <= this.current_line.length) {
      return this.current_line.substring(this.col, end);
    }
    return this.current_line.substring(this.col);
  }

  advance(n = 1) {
    this.col += n;
  }

  nextLine() {
    if (this.line < this.lines.length - 1) {
      this.line += 1;
      this.col = 0;
      this.current_line = this.lines[this.line];
      return true;
    }
    return false;
  }

  isEof() {
    if (this.line >= this.lines.length) return true;
    if (this.line === this.lines.length - 1 && this.col >= this.current_line.length) {
      return true;
    }
    return false;
  }

  getPos() {
    return { line: this.line, col: this.col };
  }

  setPos(line, col) {
    this.line = line;
    this.col = col;
    this.loadLine();
  }

  loadLine() {
    if (this.line < this.lines.length) {
      this.current_line = this.lines[this.line];
    }
  }

  skipWhitespace() {
    const max_iterations = 10000;
    let iterations = 0;

    while (!this.isEof() && iterations < max_iterations) {
      if (this.col === 0 && this.current_line[0] === '#') {
        if (!this.nextLine()) {
          break;
        }
        continue;
      }

      const c = this.peek();
      if (c === ' ' || c === '\t') {
        this.advance();
      } else if (this.col >= this.current_line.length) {
        if (this.col === this.current_line.length && this.current_line !== '') {
          if (this.current_line[this.current_line.length - 1] === '\\') {
            if (this.nextLine()) {
              continue;
            } else {
              break;
            }
          } else {
            if (this.nextLine()) {
              continue;
            } else {
              break;
            }
          }
        } else {
          if (this.nextLine()) {
            continue;
          } else {
            break;
          }
        }
      } else {
        break;
      }
      iterations += 1;
    }
  }

  skipLineContinuation() {
    this.advance(1);
    if (this.nextLine()) {
      this.skipWhitespace();
    }
  }

  hasLineContinuation() {
    if (this.current_line.length > 0 && this.current_line[this.current_line.length - 1] === '\\') {
      return true;
    }
    return false;
  }
}

// Vim9Tokenizer class
class Vim9Tokenizer {
  constructor(reader) {
    this.reader = reader;
  }

  token(type, value, line, col) {
    return { type, value, line, col };
  }

  skipComments() {
    if (this.reader.col < this.reader.current_line.length && this.reader.peek() === '#') {
      while (this.reader.col < this.reader.current_line.length) {
        this.reader.advance();
      }
    }
  }

  get() {
    while (this.reader.col >= this.reader.current_line.length && this.reader.nextLine()) {
      if (this.reader.hasLineContinuation()) {
        this.reader.skipLineContinuation();
      }
    }

    this.reader.skipWhitespace();
    this.skipComments();

    if (this.reader.isEof()) {
      return this.token(TOKEN_EOF, '<EOF>', this.reader.line, this.reader.col);
    }

    const line = this.reader.line;
    const col = this.reader.col;
    const c = this.reader.peek();

    // Numbers
    if (/[0-9]/.test(c)) {
      return this.readNumber();
    }

    // Strings
    if (c === '"') {
      return this.readString('"');
    }
    if (c === "'") {
      return this.readString("'");
    }

    // Identifiers and keywords
    if (/[A-Za-z_]/.test(c)) {
      return this.readIdentifier();
    }

    // Multi-character operators
    const cc = this.reader.peekn(2);
    const keywords = ['->'];
    if (cc === '->') {
      this.reader.advance(2);
      return this.token(TOKEN_ARROW, '->', line, col);
    }

    // Single-character tokens
    this.reader.advance(1);
    const tokenMap = {
      ':': TOKEN_COLON,
      ',': TOKEN_COMMA,
      ';': TOKEN_SEMICOLON,
      '(': TOKEN_POPEN,
      ')': TOKEN_PCLOSE,
      '[': TOKEN_SQOPEN,
      ']': TOKEN_SQCLOSE,
      '{': TOKEN_COPEN,
      '}': TOKEN_CCLOSE,
      '.': TOKEN_DOT,
      '+': TOKEN_PLUS,
      '-': TOKEN_MINUS,
      '*': TOKEN_STAR,
      '/': TOKEN_SLASH,
      '%': TOKEN_PERCENT,
      '=': TOKEN_EQ,
      '<': TOKEN_LT,
      '>': TOKEN_GT,
      '!': TOKEN_NOT,
      '?': TOKEN_QUESTION,
      '&': TOKEN_AMPERSAND,
      '|': TOKEN_PIPE,
      '^': TOKEN_CARET,
      '@': TOKEN_AT,
      '#': TOKEN_SHARP,
    };

    if (tokenMap[c] !== undefined) {
      return this.token(tokenMap[c], c, line, col);
    }

    return this.token(TOKEN_IDENTIFIER, c, line, col);
  }

  readNumber() {
    const line = this.reader.line;
    const col = this.reader.col;
    let value = '';

    while (!this.reader.isEof() && this.reader.col < this.reader.current_line.length && /[0-9.]/.test(this.reader.peek())) {
      value += this.reader.peek();
      this.reader.advance(1);
    }

    return this.token(TOKEN_NUMBER, value, line, col);
  }

  readString(quote) {
    const line = this.reader.line;
    const col = this.reader.col;
    this.reader.advance(1);
    let value = '';

    while (!this.reader.isEof() && this.reader.col < this.reader.current_line.length) {
      const c = this.reader.peek();
      if (c === quote) {
        this.reader.advance(1);
        break;
      }
      if (c === '\\') {
        this.reader.advance(1);
        if (this.reader.col < this.reader.current_line.length) {
          value += this.reader.peek();
          this.reader.advance(1);
        }
      } else {
        value += c;
        this.reader.advance(1);
      }
    }

    return this.token(TOKEN_STRING, value, line, col);
  }

  readIdentifier() {
    const line = this.reader.line;
    const col = this.reader.col;
    let value = '';

    while (!this.reader.isEof() && this.reader.col < this.reader.current_line.length && /[A-Za-z0-9_]/.test(this.reader.peek())) {
      value += this.reader.peek();
      this.reader.advance(1);
    }

    const keywords = ['def', 'enddef', 'class', 'endclass', 'var', 'const', 'final',
                      'static', 'private', 'protected', 'public', 'extends', 'implements',
                      'enum', 'endenum', 'import', 'export', 'if', 'else', 'elseif', 'endif',
                      'for', 'endfor', 'while', 'endwhile', 'in', 'try', 'catch', 'finally', 'endtry', 'as',
                      'return', 'throw', 'break', 'continue', 'true', 'false', 'null', 'any', 'type'];

    const type = keywords.includes(value) ? TOKEN_KEYWORD : TOKEN_IDENTIFIER;
    return this.token(type, value, line, col);
  }
}

// Vim9Parser class - simplified version
class Vim9Parser {
  constructor() {
    this.reader = null;
    this.tokenizer = null;
    this.current_token = null;
    this.next_token = null;
    this.errors = [];
  }

  parse(reader) {
    this.reader = reader;
    this.tokenizer = new Vim9Tokenizer(reader);
    this.current_token = this.tokenizer.get();
    this.next_token = this.tokenizer.get();

    const toplevel = {
      type: NODE_TOPLEVEL,
      body: [],
      line: 0,
      col: 0,
      name: '',
      rtype: '',
    };

    while (this.current_token.type !== TOKEN_EOF) {
      if (this.current_token.type === TOKEN_KEYWORD && this.current_token.value === 'vim9script') {
        this.advance();
        continue;
      }

      const stmt = this.parseTopLevelStatement();
      if (Object.keys(stmt).length > 0) {
        toplevel.body.push(stmt);
      }
    }

    return toplevel;
  }

  parseTopLevelStatement() {
    if (this.current_token.type !== TOKEN_KEYWORD) {
      this.advance();
      return {};
    }

    if (this.current_token.value === 'var') {
      return this.parseVar();
    } else if (this.current_token.value === 'const') {
      return this.parseConst();
    } else if (this.current_token.value === 'def') {
      return this.parseDef();
    } else if (this.current_token.value === 'class') {
      return this.parseClass();
    } else if (this.current_token.value === 'import') {
      return this.parseImport();
    } else if (this.current_token.value === 'export') {
      return this.parseExport();
    } else {
      this.advance();
      return {};
    }
  }

  parseVar() {
    const node = {
      type: 201, // NODE_VAR
      name: '',
      rtype: '',
      body: [],
      line: this.current_token.line,
      col: this.current_token.col,
    };

    this.expect(TOKEN_KEYWORD); // var

    const nameTok = this.expect(TOKEN_IDENTIFIER);
    node.name = nameTok.value;

    if (this.current_token.type === TOKEN_COLON) {
      this.advance();
      node.rtype = this.parseTypeString();
    }

    if (this.current_token.type === TOKEN_EQ) {
      this.advance();
      node.body.push(this.parseExpression());
    }

    return node;
  }

  parseConst() {
    const node = {
      type: 202, // NODE_CONST
      name: '',
      rtype: '',
      body: [],
      line: this.current_token.line,
      col: this.current_token.col,
    };

    this.expect(TOKEN_KEYWORD); // const

    const nameTok = this.expect(TOKEN_IDENTIFIER);
    node.name = nameTok.value;

    if (this.current_token.type === TOKEN_COLON) {
      this.advance();
      node.rtype = this.parseTypeString();
    }

    if (this.current_token.type === TOKEN_EQ) {
      this.advance();
      node.body.push(this.parseExpression());
    }

    return node;
  }

  parseDef() {
    const node = {
      type: 203, // NODE_DEF
      name: '',
      params: [],
      rtype: '',
      body: [],
      line: this.current_token.line,
      col: this.current_token.col,
    };

    this.expect(TOKEN_KEYWORD); // def

    const nameTok = this.expect(TOKEN_IDENTIFIER);
    node.name = nameTok.value;

    this.expect(TOKEN_POPEN);
    node.params = this.parseParameterList();
    this.expect(TOKEN_PCLOSE);

    if (this.current_token.type === TOKEN_COLON) {
      this.advance();
      node.rtype = this.parseTypeString();
    }

    while (!(this.current_token.type === TOKEN_KEYWORD && this.current_token.value === 'enddef')) {
      if (this.current_token.type === TOKEN_EOF) {
        throw new Error(`Syntax error: Unexpected EOF in def body`);
      }
      node.body.push(this.parseStatement());
    }

    this.expect(TOKEN_KEYWORD); // enddef

    return node;
  }

  parseClass() {
    const node = {
      type: 205, // NODE_CLASS
      name: '',
      body: [],
      line: this.current_token.line,
      col: this.current_token.col,
    };

    this.expect(TOKEN_KEYWORD); // class

    const nameTok = this.expect(TOKEN_IDENTIFIER);
    node.name = nameTok.value;

    while (!(this.current_token.type === TOKEN_KEYWORD && this.current_token.value === 'endclass')) {
      if (this.current_token.type === TOKEN_EOF) {
        throw new Error(`Syntax error: Unexpected EOF in class body`);
      }

      if (this.current_token.value === 'var' || this.current_token.value === 'const') {
        node.body.push(this.parseVar());
      } else if (this.current_token.value === 'def') {
        node.body.push(this.parseDef());
      } else {
        this.advance();
      }
    }

    this.expect(TOKEN_KEYWORD); // endclass

    return node;
  }

  parseImport() {
    const node = {
      type: 209, // NODE_IMPORT
      name: '',
      body: [],
      line: this.current_token.line,
      col: this.current_token.col,
    };

    this.expect(TOKEN_KEYWORD); // import
    const pathTok = this.expect(TOKEN_STRING);
    node.name = pathTok.value;

    if (this.current_token.type === TOKEN_KEYWORD && this.current_token.value === 'as') {
      this.advance();
      const aliasTok = this.expect(TOKEN_IDENTIFIER);
      node.alias = aliasTok.value;
    }

    return node;
  }

  parseExport() {
    this.expect(TOKEN_KEYWORD); // export

    if (this.current_token.value === 'var') {
      const node = this.parseVar();
      node.export = true;
      return node;
    } else if (this.current_token.value === 'const') {
      const node = this.parseConst();
      node.export = true;
      return node;
    } else if (this.current_token.value === 'def') {
      const node = this.parseDef();
      node.export = true;
      return node;
    } else if (this.current_token.value === 'class') {
      const node = this.parseClass();
      node.export = true;
      return node;
    } else {
      return {};
    }
  }

  parseStatement() {
    return { type: 0, body: [] };
  }

  parseExpression() {
    return { type: 0, value: '' };
  }

  parseTypeString() {
    return 'any';
  }

  parseParameterList() {
    const params = [];
    while (this.current_token.type !== TOKEN_PCLOSE && this.current_token.type !== TOKEN_EOF) {
      if (this.current_token.type === TOKEN_IDENTIFIER) {
        params.push({ name: this.current_token.value });
        this.advance();
      }
      if (this.current_token.type === TOKEN_COMMA) {
        this.advance();
      } else if (this.current_token.type !== TOKEN_PCLOSE) {
        break;
      }
    }
    return params;
  }

  advance() {
    this.current_token = this.next_token;
    this.next_token = this.tokenizer.get();
  }

  expect(tokenType) {
    if (this.current_token.type !== tokenType) {
      throw new Error(`Expected token type ${tokenType}, got ${this.current_token.type} (${this.current_token.value})`);
    }
    const tok = this.current_token;
    this.advance();
    return tok;
  }
}

// Export for Node.js
if (typeof module !== "undefined" && module.exports) {
  module.exports = {
    StringReader,
    Vim9Tokenizer,
    Vim9Parser,
    TOKEN_EOF,
    TOKEN_NUMBER,
    TOKEN_STRING,
    TOKEN_IDENTIFIER,
    TOKEN_KEYWORD,
    NODE_TOPLEVEL,
    NODE_VAR,
    NODE_CONST,
    NODE_DEF,
    NODE_CLASS,
    NODE_IMPORT,
    NODE_EXPORT,
  };
}
