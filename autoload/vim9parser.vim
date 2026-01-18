vim9script

# Vim9 Script Parser
#
# License: This file is placed in the public domain.

def import(): dict<any>
  return {
    StringReader: StringReader,
    Vim9Tokenizer: Vim9Tokenizer,
    Vim9Parser: Vim9Parser,
    Compiler: Compiler,
  }
enddef

# Token type constants
const TOKEN_EOF = 0
const TOKEN_EOL = 1
const TOKEN_SPACE = 2
const TOKEN_NUMBER = 3
const TOKEN_STRING = 4
const TOKEN_IDENTIFIER = 5
const TOKEN_KEYWORD = 6
const TOKEN_COLON = 7
const TOKEN_COMMA = 8
const TOKEN_SEMICOLON = 9
const TOKEN_POPEN = 10
const TOKEN_PCLOSE = 11
const TOKEN_SQOPEN = 12
const TOKEN_SQCLOSE = 13
const TOKEN_COPEN = 14
const TOKEN_CCLOSE = 15
const TOKEN_DOT = 16
const TOKEN_ARROW = 17
const TOKEN_PLUS = 18
const TOKEN_MINUS = 19
const TOKEN_STAR = 20
const TOKEN_SLASH = 21
const TOKEN_PERCENT = 22
const TOKEN_EQ = 23
const TOKEN_EQEQ = 24
const TOKEN_NEQ = 25
const TOKEN_LT = 26
const TOKEN_LTEQ = 27
const TOKEN_GT = 28
const TOKEN_GTEQ = 29
const TOKEN_AND = 30
const TOKEN_OR = 31
const TOKEN_NOT = 32
const TOKEN_QUESTION = 33
const TOKEN_AMPERSAND = 34
const TOKEN_DOTDOTDOT = 35
const TOKEN_AT = 36
const TOKEN_SHARP = 37

# Vim9 keywords
const KEYWORDS = [
  'def', 'enddef', 'class', 'endclass', 'var', 'const', 'final',
  'static', 'private', 'protected', 'public', 'extends', 'implements',
  'enum', 'endenum', 'import', 'export', 'if', 'else', 'elseif', 'endif',
  'for', 'endfor', 'while', 'endwhile', 'try', 'catch', 'finally', 'endtry',
  'return', 'throw', 'break', 'continue', 'true', 'false', 'null', 'any',
]

# Node type constants
const NODE_TOPLEVEL = 1
const NODE_COMMENT = 2
const NODE_EXCMD = 3
const NODE_FUNCTION = 4
const NODE_ENDFUNCTION = 5
const NODE_DELFUNCTION = 6
const NODE_RETURN = 7
const NODE_EXCALL = 8
const NODE_LET = 9
const NODE_UNLET = 10
const NODE_LOCKVAR = 11
const NODE_UNLOCKVAR = 12
const NODE_IF = 13
const NODE_ELSEIF = 14
const NODE_ELSE = 15
const NODE_ENDIF = 16
const NODE_WHILE = 17
const NODE_ENDWHILE = 18
const NODE_FOR = 19
const NODE_ENDFOR = 20
const NODE_CONTINUE = 21
const NODE_BREAK = 22
const NODE_TRY = 23
const NODE_CATCH = 24
const NODE_FINALLY = 25
const NODE_ENDTRY = 26
const NODE_THROW = 27
const NODE_ECHO = 28
const NODE_ECHON = 29
const NODE_ECHOHL = 30
const NODE_ECHOMSG = 31
const NODE_ECHOERR = 32
const NODE_EXECUTE = 33
const NODE_TERNARY = 34
const NODE_OR = 35
const NODE_AND = 36
const NODE_EQUAL = 37
const NODE_NEQUAL = 40
const NODE_GREATER = 43
const NODE_GEQUAL = 46
const NODE_SMALLER = 49
const NODE_SEQUAL = 52

# Vim9 specific node types
const NODE_VAR = 201
const NODE_CONST = 202
const NODE_DEF = 203
const NODE_ENDDEF = 204
const NODE_CLASS = 205
const NODE_ENDCLASS = 206
const NODE_EXTENDS = 207
const NODE_IMPLEMENTS = 208
const NODE_IMPORT = 209
const NODE_EXPORT = 210
const NODE_ENUM = 211
const NODE_ENDENUM = 212
const NODE_TYPE = 213

def test(input: any): void
  try
    var lines: list<string>
    if type(input) == v:t_string
      if filereadable(input)
        lines = readfile(input)
      else
        lines = split(input, "\n")
      endif
    else
      lines = input
    endif
    
    var reader = StringReader.new(lines)
    var parser = Vim9Parser.new()
    var compiler = Compiler.new()
    var ast = parser.parse(reader)
    
    for line in compiler.compile(ast)
      echo line
    endfor
  catch
    echohl Error
    echomsg 'vim9parser error: ' .. v:exception
    echohl None
  endtry
enddef

# StringReader class
class StringReader
  var lines: list<string>
  var line: number = 0
  var col: number = 0
  var current_line: string = ''
  
  def new(lines: list<string>): StringReader
    this.lines = lines
    this.line = 0
    this.col = 0
    if len(lines) > 0
      this.current_line = lines[0]
    endif
    return this
  enddef
  
  def peek(offset: number = 0): string
    var col = this.col + offset
    if col < len(this.current_line)
      return this.current_line[col : col]
    endif
    return '<EOL>'
  enddef
  
  def peekn(n: number): string
    var end = this.col + n
    if end <= len(this.current_line)
      return this.current_line[this.col : end - 1]
    endif
    return this.current_line[this.col : ]
  enddef
  
  def advance(n: number = 1): void
    this.col += n
  enddef
  
  def next_line(): bool
    if this.line < len(this.lines) - 1
      this.line += 1
      this.col = 0
      this.current_line = this.lines[this.line]
      return true
    endif
    return false
  enddef
  
  def iseof(): bool
    return this.line >= len(this.lines)
  enddef
  
  def getpos(): dict<any>
    return {
      line: this.line,
      col: this.col,
    }
  enddef
  
  def skip_whitespace(): void
    while !this.iseof() && this.peek() =~ '[ \t]'
      this.advance()
    endwhile
  enddef
endclass

class Vim9Tokenizer
  var reader: StringReader
  var current_token: dict<any> = {}
  
  def new(reader: StringReader): Vim9Tokenizer
    this.reader = reader
    return this
  enddef
  
  def token(type: number, value: string, line: number, col: number): dict<any>
    return {
      type: type,
      value: value,
      line: line,
      col: col,
    }
  enddef
  
  def peek(): dict<any>
    var saved_line = this.reader.line
    var saved_col = this.reader.col
    var saved_current = this.reader.current_line
    
    var tok = this.get()
    
    this.reader.line = saved_line
    this.reader.col = saved_col
    this.reader.current_line = saved_current
    
    return tok
  enddef
  
  def get(): dict<any>
    this.reader.skip_whitespace()
    
    if this.reader.iseof()
      return this.token(TOKEN_EOF, '<EOF>', this.reader.line, this.reader.col)
    endif
    
    var line = this.reader.line
    var col = this.reader.col
    var c = this.reader.peek()
    
    # Numbers
    if c =~ '[0-9]'
      return this.read_number()
    endif
    
    # Strings
    if c == '"'
      return this.read_string('"')
    endif
    
    if c == "'"
      return this.read_string("'")
    endif
    
    # Identifiers and keywords
    if c =~ '[A-Za-z_]'
      return this.read_identifier()
    endif
    
    # Multi-character operators
    var cc = this.reader.peekn(2)
    if cc == '=>'
      this.reader.advance(2)
      return this.token(TOKEN_ARROW, '=>', line, col)
    elseif cc == '=='
      this.reader.advance(2)
      return this.token(TOKEN_EQEQ, '==', line, col)
    elseif cc == '!='
      this.reader.advance(2)
      return this.token(TOKEN_NEQ, '!=', line, col)
    elseif cc == '<='
      this.reader.advance(2)
      return this.token(TOKEN_LTEQ, '<=', line, col)
    elseif cc == '>='
      this.reader.advance(2)
      return this.token(TOKEN_GTEQ, '>=', line, col)
    elseif cc == '&&'
      this.reader.advance(2)
      return this.token(TOKEN_AND, '&&', line, col)
    elseif cc == '||'
      this.reader.advance(2)
      return this.token(TOKEN_OR, '||', line, col)
    elseif cc == '..'
      this.reader.advance(2)
      if this.reader.peek() == '.'
        this.reader.advance(1)
        return this.token(TOKEN_DOTDOTDOT, '...', line, col)
      endif
      return this.token(TOKEN_DOT, '..', line, col)
    endif
    
    # Single-character tokens
    this.reader.advance(1)
    if c == ':'
      return this.token(TOKEN_COLON, ':', line, col)
    elseif c == ','
      return this.token(TOKEN_COMMA, ',', line, col)
    elseif c == ';'
      return this.token(TOKEN_SEMICOLON, ';', line, col)
    elseif c == '('
      return this.token(TOKEN_POPEN, '(', line, col)
    elseif c == ')'
      return this.token(TOKEN_PCLOSE, ')', line, col)
    elseif c == '['
      return this.token(TOKEN_SQOPEN, '[', line, col)
    elseif c == ']'
      return this.token(TOKEN_SQCLOSE, ']', line, col)
    elseif c == '{'
      return this.token(TOKEN_COPEN, '{', line, col)
    elseif c == '}'
      return this.token(TOKEN_CCLOSE, '}', line, col)
    elseif c == '.'
      return this.token(TOKEN_DOT, '.', line, col)
    elseif c == '+'
      return this.token(TOKEN_PLUS, '+', line, col)
    elseif c == '-'
      return this.token(TOKEN_MINUS, '-', line, col)
    elseif c == '*'
      return this.token(TOKEN_STAR, '*', line, col)
    elseif c == '/'
      return this.token(TOKEN_SLASH, '/', line, col)
    elseif c == '%'
      return this.token(TOKEN_PERCENT, '%', line, col)
    elseif c == '='
      return this.token(TOKEN_EQ, '=', line, col)
    elseif c == '<'
      return this.token(TOKEN_LT, '<', line, col)
    elseif c == '>'
      return this.token(TOKEN_GT, '>', line, col)
    elseif c == '!'
      return this.token(TOKEN_NOT, '!', line, col)
    elseif c == '?'
      return this.token(TOKEN_QUESTION, '?', line, col)
    elseif c == '&'
      return this.token(TOKEN_AMPERSAND, '&', line, col)
    elseif c == '@'
      return this.token(TOKEN_AT, '@', line, col)
    elseif c == '#'
      return this.token(TOKEN_SHARP, '#', line, col)
    endif
    
    # Unknown character
    return this.token(TOKEN_IDENTIFIER, c, line, col)
  enddef
  
  def read_number(): dict<any>
    var line = this.reader.line
    var col = this.reader.col
    var value = ''
    
    # Read digits
    while !this.reader.iseof() && this.reader.peek() =~ '[0-9]'
      value ..= this.reader.peek()
      this.reader.advance(1)
    endwhile
    
    # Read decimal part
    if this.reader.peek() == '.' && this.reader.peekn(2)[1 : 1] =~ '[0-9]'
      value ..= '.'
      this.reader.advance(1)
      while !this.reader.iseof() && this.reader.peek() =~ '[0-9]'
        value ..= this.reader.peek()
        this.reader.advance(1)
      endwhile
    endif
    
    return this.token(TOKEN_NUMBER, value, line, col)
  enddef
  
  def read_string(quote: string): dict<any>
    var line = this.reader.line
    var col = this.reader.col
    var value = ''
    
    this.reader.advance(1)  # Skip opening quote
    
    while !this.reader.iseof()
      var c = this.reader.peek()
      if c == quote
        this.reader.advance(1)
        break
      elseif c == '\'
        value ..= c
        this.reader.advance(1)
        if !this.reader.iseof()
          value ..= this.reader.peek()
          this.reader.advance(1)
        endif
      else
        value ..= c
        this.reader.advance(1)
      endif
    endwhile
    
    return this.token(TOKEN_STRING, value, line, col)
  enddef
  
  def read_identifier(): dict<any>
    var line = this.reader.line
    var col = this.reader.col
    var value = ''
    
    while !this.reader.iseof() && this.reader.peek() =~ '[A-Za-z0-9_]'
      value ..= this.reader.peek()
      this.reader.advance(1)
    endwhile
    
    # Check if it's a keyword
    var token_type = TOKEN_IDENTIFIER
    if index(KEYWORDS, value) >= 0
      token_type = TOKEN_KEYWORD
    endif
    
    return this.token(token_type, value, line, col)
  enddef
endclass

# Node structure
class Node
  var type: number
  var body: list<any> = []
  var line: string = ''
  var pos: number = 0
  var len: number = -1
  var name: string = ''
  var params: list<dict<string, any>> = []
  var rtype: string = ''
  
  def new(type: number): Node
    this.type = type
    return this
  enddef
endclass

# Vim9Parser class
class Vim9Parser
  var reader: StringReader
  var tokenizer: Vim9Tokenizer
  var current_token: dict<any> = {}
  var next_token: dict<any> = {}
  
  def new(): Vim9Parser
    return this
  enddef
  
  def parse(reader: StringReader): Node
    this.reader = reader
    this.tokenizer = Vim9Tokenizer.new(reader)
    this.advance()  # Load first token
    this.advance()  # Load second token
    
    var toplevel = Node.new(NODE_TOPLEVEL)
    
    while this.current_token.type != TOKEN_EOF
      if this.current_token.type == TOKEN_KEYWORD
        if this.current_token.value == 'vim9script'
          this.advance()
          continue
        elseif this.current_token.value == 'var'
          toplevel.body->add(this.parseVar())
        elseif this.current_token.value == 'const'
          toplevel.body->add(this.parseConst())
        elseif this.current_token.value == 'def'
          toplevel.body->add(this.parseDef())
        elseif this.current_token.value == 'class'
          toplevel.body->add(this.parseClass())
        elseif this.current_token.value == 'import'
          toplevel.body->add(this.parseImport())
        elseif this.current_token.value == 'export'
          toplevel.body->add(this.parseExport())
        else
          this.advance()
        endif
      else
        this.advance()
      endif
    endwhile
    
    return toplevel
  enddef
  
  def advance(): void
    this.current_token = this.next_token
    this.next_token = this.tokenizer.get()
  enddef
  
  def expect(type: number): dict<any>
    if this.current_token.type != type
      throw $'Expected token type {type}, got {this.current_token.type}'
    endif
    var tok = this.current_token
    this.advance()
    return tok
  enddef
  
  def parseVar(): Node
    var node = Node.new(NODE_VAR)
    var start_pos = this.current_token
    
    this.expect(TOKEN_KEYWORD)  # var
    
    var name_tok = this.expect(TOKEN_IDENTIFIER)
    node.name = name_tok.value
    
    # Optional type annotation
    if this.current_token.type == TOKEN_COLON
      this.advance()
      node.rtype = this.parseType()
    endif
    
    # Optional initialization
    if this.current_token.type == TOKEN_EQ
      this.advance()
      node.body->add(this.parseExpression())
    endif
    
    return node
  enddef
  
  def parseConst(): Node
    var node = Node.new(NODE_CONST)
    
    this.expect(TOKEN_KEYWORD)  # const
    
    var name_tok = this.expect(TOKEN_IDENTIFIER)
    node.name = name_tok.value
    
    # Optional type annotation
    if this.current_token.type == TOKEN_COLON
      this.advance()
      node.rtype = this.parseType()
    endif
    
    # Initialization (required for const)
    if this.current_token.type == TOKEN_EQ
      this.advance()
      node.body->add(this.parseExpression())
    endif
    
    return node
  enddef
  
  def parseDef(): Node
    var node = Node.new(NODE_DEF)
    
    this.expect(TOKEN_KEYWORD)  # def
    
    var name_tok = this.expect(TOKEN_IDENTIFIER)
    node.name = name_tok.value
    
    # Parse parameters
    this.expect(TOKEN_POPEN)
    node.params = this.parseParameterList()
    this.expect(TOKEN_PCLOSE)
    
    # Parse return type
    if this.current_token.type == TOKEN_COLON
      this.advance()
      node.rtype = this.parseType()
    endif
    
    # Parse body
    while this.current_token.type != TOKEN_KEYWORD || this.current_token.value != 'enddef'
      if this.current_token.type == TOKEN_EOF
        throw 'Unexpected EOF in def body'
      endif
      node.body->add(this.parseStatement())
    endwhile
    
    this.expect(TOKEN_KEYWORD)  # enddef
    
    return node
  enddef
  
  def parseClass(): Node
    var node = Node.new(NODE_CLASS)
    
    this.expect(TOKEN_KEYWORD)  # class
    
    var name_tok = this.expect(TOKEN_IDENTIFIER)
    node.name = name_tok.value
    
    # Parse body (members and methods)
    while this.current_token.type != TOKEN_KEYWORD || this.current_token.value != 'endclass'
      if this.current_token.type == TOKEN_EOF
        throw 'Unexpected EOF in class body'
      endif
      
      if this.current_token.value == 'var' || this.current_token.value == 'const'
        node.body->add(this.parseVar())
      elseif this.current_token.value == 'def'
        node.body->add(this.parseDef())
      else
        this.advance()
      endif
    endwhile
    
    this.expect(TOKEN_KEYWORD)  # endclass
    
    return node
  enddef
  
  def parseImport(): Node
    var node = Node.new(NODE_IMPORT)
    
    this.expect(TOKEN_KEYWORD)  # import
    
    # import autoload "module.vim" as m
    if this.current_token.value == 'autoload'
      this.advance()
    endif
    
    var path_tok = this.expect(TOKEN_STRING)
    node.line = path_tok.value
    
    if this.current_token.value == 'as'
      this.advance()
      var alias_tok = this.expect(TOKEN_IDENTIFIER)
      node.name = alias_tok.value
    endif
    
    return node
  enddef
  
  def parseExport(): Node
    var node = Node.new(NODE_EXPORT)
    
    this.expect(TOKEN_KEYWORD)  # export
    
    if this.current_token.value == 'def'
      node.body->add(this.parseDef())
    elseif this.current_token.value == 'const'
      node.body->add(this.parseConst())
    elseif this.current_token.value == 'var'
      node.body->add(this.parseVar())
    elseif this.current_token.value == 'class'
      node.body->add(this.parseClass())
    endif
    
    return node
  enddef
  
  def parseStatement(): Node
    var node = Node.new(NODE_EXCMD)
    
    # Skip to next meaningful token
    if this.current_token.type != TOKEN_EOF
      this.advance()
    endif
    
    return node
  enddef
  
  def parseParameterList(): list<dict<string, any>>
    var params: list<dict<string, any>> = []
    
    while this.current_token.type == TOKEN_IDENTIFIER
      var param: dict<string, any> = {}
      
      param.name = this.expect(TOKEN_IDENTIFIER).value
      
      if this.current_token.type == TOKEN_COLON
        this.advance()
        param.type = this.parseType()
      endif
      
      params->add(param)
      
      if this.current_token.type == TOKEN_COMMA
        this.advance()
      else
        break
      endif
    endwhile
    
    return params
  enddef
  
  def parseType(): string
    var type_str = ''
    
    if this.current_token.type != TOKEN_IDENTIFIER && this.current_token.type != TOKEN_KEYWORD
      throw $'Expected type, got {this.current_token.value}'
    endif
    
    type_str = this.current_token.value
    this.advance()
    
    # Handle generic types: list<string>, dict<number>, etc.
    if this.current_token.type == TOKEN_LT
      this.advance()
      type_str ..= '<'
      type_str ..= this.parseType()
      if this.current_token.type == TOKEN_GT
        this.advance()
        type_str ..= '>'
      endif
    endif
    
    return type_str
  enddef
  
  def parseExpression(): Node
    # Simple expression parsing - just consume tokens until we hit a keyword or EOL
    var expr_node = Node.new(NODE_EXCMD)
    
    while this.current_token.type != TOKEN_EOF &&
          this.current_token.type != TOKEN_KEYWORD &&
          this.current_token.type != TOKEN_SEMICOLON
      expr_node.line ..= this.current_token.value .. ' '
      this.advance()
    endwhile
    
    return expr_node
  enddef
endclass

# Compiler class
class Compiler
  def new(): Compiler
    return this
  enddef
  
  def compile(node: Node): list<string>
    var result: list<string> = []
    this.compileNode(node, 0, result)
    return result
  enddef
  
  def compileNode(node: Node, depth: number, result: list<string>): void
    var indent = repeat('  ', depth)
    
    if node.type == NODE_TOPLEVEL
      for child in node.body
        this.compileNode(child, depth, result)
      endfor
    elseif node.type == NODE_VAR
      result->add($'{indent}(var {node.line})')
    elseif node.type == NODE_CONST
      result->add($'{indent}(const {node.line})')
    elseif node.type == NODE_DEF
      result->add($'{indent}(def {node.line})')
      for line in node.body
        result->add($'{indent}  {line}')
      endfor
      result->add($'{indent}(enddef)')
    elseif node.type == NODE_CLASS
      result->add($'{indent}(class {node.line})')
      for line in node.body
        result->add($'{indent}  {line}')
      endfor
      result->add($'{indent}(endclass)')
    elseif node.type == NODE_IMPORT
      result->add($'{indent}(import {node.line})')
    elseif node.type == NODE_EXPORT
      result->add($'{indent}(export {node.line})')
    else
      result->add($'{indent}({node.line})')
    endif
  enddef
endclass

# Public interface
export def vim9parser#import(): dict<any>
  return import()
enddef

export def vim9parser#test(input: any): void
  test(input)
enddef
