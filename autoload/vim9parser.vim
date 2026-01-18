vim9script

# Vim9 Script Parser
#
# License: This file is placed in the public domain.

# Token type constants (exported for testing)
export const TOKEN_EOF = 0
export const TOKEN_EOL = 1
export const TOKEN_SPACE = 2
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
const TOKEN_PIPE = 38
const TOKEN_CARET = 39
const TOKEN_LSHIFT = 40
const TOKEN_RSHIFT = 41

# Vim9 keywords
const KEYWORDS = [
  'def', 'enddef', 'class', 'endclass', 'var', 'const', 'final',
  'static', 'private', 'protected', 'public', 'extends', 'implements',
  'enum', 'endenum', 'import', 'export', 'if', 'else', 'elseif', 'endif',
  'for', 'endfor', 'while', 'endwhile', 'in', 'try', 'catch', 'finally', 'endtry', 'as',
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

# Expression node types
const NODE_ADD = 300
const NODE_SUBTRACT = 301
const NODE_MULTIPLY = 302
const NODE_DIVIDE = 303
const NODE_MODULO = 304
const NODE_NUMBER = 305
const NODE_STRING = 306
const NODE_IDENTIFIER = 307
const NODE_TRUE = 308
const NODE_FALSE = 309
const NODE_NULL = 310
const NODE_LIST = 311
const NODE_DICT = 312
const NODE_CALL = 313
const NODE_DOT = 314
const NODE_SUBSCRIPT = 315
const NODE_NOT = 316
const NODE_LAMBDA = 317
const NODE_BIT_OR = 318
const NODE_BIT_XOR = 319
const NODE_BIT_AND = 320
const NODE_LSHIFT = 321
const NODE_RSHIFT = 322

# StringReader class
export class StringReader
  var lines: list<string>
  var line: number = 0
  var col: number = 0
  var current_line: string = ''
  
  def new(lines: list<string>)
    this.lines = lines
    this.line = 0
    this.col = 0
    if len(lines) > 0
      this.current_line = lines[0]
    endif
    enddef
  
  def Peek(offset: number = 0): string
    var col = this.col + offset
    
    # Only peek within current line, don't cross line boundaries
    if col < len(this.current_line)
      return this.current_line[col : col]
    endif
    
    # At or past end of current line
    return '<EOL>'
  enddef
  
  def Peekn(n: number): string
    var end = this.col + n
    if end <= len(this.current_line)
      return this.current_line[this.col : end - 1]
    endif
    return this.current_line[this.col : ]
  enddef
  
  def Advance(n: number = 1): void
    this.col += n
  enddef
  
  def NextLine(): bool
    if this.line < len(this.lines) - 1
      this.line += 1
      this.col = 0
      this.current_line = this.lines[this.line]
      return true
    endif
    return false
  enddef
  
  def IsEof(): bool
    if this.line >= len(this.lines)
      return true
    endif
    if this.line == len(this.lines) - 1 && this.col >= len(this.current_line)
      return true
    endif
    return false
  enddef
  
  def Getpos(): dict<any>
    return {
      line: this.line,
      col: this.col,
    }
  enddef
  
  def LoadLine(): void
    if this.line < len(this.lines)
      this.current_line = this.lines[this.line]
    endif
  enddef
  
  def SetPos(line: number, col: number): void
    this.line = line
    this.col = col
    this.LoadLine()
  enddef
  
  def SkipWhitespace(): void
    var iterations = 0
    var max_iterations = 10000
    
    while !this.IsEof() && iterations < max_iterations
      var c = this.Peek()
      if c =~ '[ \t]'
        this.Advance()
      elseif this.col >= len(this.current_line)
        # Skip to next line
        if this.NextLine()
          # Continue to skip whitespace on next line
          continue
        else
          break
        endif
      else
        break
      endif
      iterations += 1
    endwhile
  enddef
endclass

export class Vim9Tokenizer
  var reader: StringReader
  var current_token: dict<any> = {}
  
  def new(reader: StringReader)
    this.reader = reader
    enddef
  
  def Token(type: number, value: string, line: number, col: number): dict<any>
    return {
      type: type,
      value: value,
      line: line,
      col: col,
    }
  enddef
  
  def Peek(): dict<any>
    var saved_line = this.reader.line
    var saved_col = this.reader.col
    var saved_current = this.reader.current_line
    
    var tok = this.Get()
    
    this.reader.line = saved_line
    this.reader.col = saved_col
    this.reader.current_line = saved_current
    
    return tok
  enddef
  
  def Get(): dict<any>
    # Skip to next line if at end of current line
    while this.reader.col >= len(this.reader.current_line) && this.reader.NextLine()
      # Continue to next line
    endwhile
    
    this.reader.SkipWhitespace()
    
    if this.reader.IsEof()
      return this.Token(TOKEN_EOF, '<EOF>', this.reader.line, this.reader.col)
    endif
    
    var line = this.reader.line
    var col = this.reader.col
    var c = this.reader.Peek()
    
    # Numbers
    if c =~ '[0-9]'
      return this.ReadNumber()
    endif
    
    # Strings
    if c == '"'
      return this.ReadString('"')
    endif
    
    if c == "'"
      return this.ReadString("'")
    endif
    
    # Identifiers and keywords
    if c =~ '[A-Za-z_]'
      return this.ReadIdentifier()
    endif
    
    # Multi-character operators
    var cc = this.reader.Peekn(2)
    if cc == '=>'
      this.reader.Advance(2)
      return this.Token(TOKEN_ARROW, '=>', line, col)
    elseif cc == '=='
      this.reader.Advance(2)
      return this.Token(TOKEN_EQEQ, '==', line, col)
    elseif cc == '!='
      this.reader.Advance(2)
      return this.Token(TOKEN_NEQ, '!=', line, col)
    elseif cc == '<='
      this.reader.Advance(2)
      return this.Token(TOKEN_LTEQ, '<=', line, col)
    elseif cc == '>='
      this.reader.Advance(2)
      return this.Token(TOKEN_GTEQ, '>=', line, col)
    elseif cc == '<<'
      this.reader.Advance(2)
      return this.Token(TOKEN_LSHIFT, '<<', line, col)
    elseif cc == '>>'
      this.reader.Advance(2)
      return this.Token(TOKEN_RSHIFT, '>>', line, col)
    elseif cc == '&&'
      this.reader.Advance(2)
      return this.Token(TOKEN_AND, '&&', line, col)
    elseif cc == '||'
      this.reader.Advance(2)
      return this.Token(TOKEN_OR, '||', line, col)
    elseif cc == '..'
      this.reader.Advance(2)
      if this.reader.Peek() == '.'
        this.reader.Advance(1)
        return this.Token(TOKEN_DOTDOTDOT, '...', line, col)
      endif
      return this.Token(TOKEN_DOT, '..', line, col)
    endif
    
    # Single-character tokens
    this.reader.Advance(1)
    if c == ':'
      return this.Token(TOKEN_COLON, ':', line, col)
    elseif c == ','
      return this.Token(TOKEN_COMMA, ',', line, col)
    elseif c == ';'
      return this.Token(TOKEN_SEMICOLON, ';', line, col)
    elseif c == '('
      return this.Token(TOKEN_POPEN, '(', line, col)
    elseif c == ')'
      return this.Token(TOKEN_PCLOSE, ')', line, col)
    elseif c == '['
      return this.Token(TOKEN_SQOPEN, '[', line, col)
    elseif c == ']'
      return this.Token(TOKEN_SQCLOSE, ']', line, col)
    elseif c == '{'
      return this.Token(TOKEN_COPEN, '{', line, col)
    elseif c == '}'
      return this.Token(TOKEN_CCLOSE, '}', line, col)
    elseif c == '.'
      return this.Token(TOKEN_DOT, '.', line, col)
    elseif c == '+'
      return this.Token(TOKEN_PLUS, '+', line, col)
    elseif c == '-'
      return this.Token(TOKEN_MINUS, '-', line, col)
    elseif c == '*'
      return this.Token(TOKEN_STAR, '*', line, col)
    elseif c == '/'
      return this.Token(TOKEN_SLASH, '/', line, col)
    elseif c == '%'
      return this.Token(TOKEN_PERCENT, '%', line, col)
    elseif c == '='
      return this.Token(TOKEN_EQ, '=', line, col)
    elseif c == '<'
      return this.Token(TOKEN_LT, '<', line, col)
    elseif c == '>'
      return this.Token(TOKEN_GT, '>', line, col)
    elseif c == '!'
      return this.Token(TOKEN_NOT, '!', line, col)
    elseif c == '?'
      return this.Token(TOKEN_QUESTION, '?', line, col)
    elseif c == '&'
      return this.Token(TOKEN_AMPERSAND, '&', line, col)
    elseif c == '|'
      return this.Token(TOKEN_PIPE, '|', line, col)
    elseif c == '^'
      return this.Token(TOKEN_CARET, '^', line, col)
    elseif c == '@'
      return this.Token(TOKEN_AT, '@', line, col)
    elseif c == '#'
      return this.Token(TOKEN_SHARP, '#', line, col)
    endif
    
    # Unknown character
    return this.Token(TOKEN_IDENTIFIER, c, line, col)
  enddef
  
  def ReadNumber(): dict<any>
    var line = this.reader.line
    var col = this.reader.col
    var value = ''
    
    # Read digits
    while !this.reader.IsEof() && this.reader.col < len(this.reader.current_line) && this.reader.Peek() =~ '[0-9]'
      value ..= this.reader.Peek()
      this.reader.Advance(1)
    endwhile
    
    # Read decimal part
    if this.reader.col < len(this.reader.current_line) && this.reader.Peek() == '.' && this.reader.Peekn(2)[1 : 1] =~ '[0-9]'
      value ..= '.'
      this.reader.Advance(1)
      while !this.reader.IsEof() && this.reader.col < len(this.reader.current_line) && this.reader.Peek() =~ '[0-9]'
        value ..= this.reader.Peek()
        this.reader.Advance(1)
      endwhile
    endif
    
    return this.Token(TOKEN_NUMBER, value, line, col)
  enddef
  
  def ReadString(quote: string): dict<any>
    var line = this.reader.line
    var col = this.reader.col
    var value = ''
    
    this.reader.Advance(1)  # Skip opening quote
    
    while !this.reader.IsEof()
      var c = this.reader.Peek()
      if c == quote
        this.reader.Advance(1)
        break
      elseif c == '\'
        value ..= c
        this.reader.Advance(1)
        if !this.reader.IsEof()
          value ..= this.reader.Peek()
          this.reader.Advance(1)
        endif
      else
        value ..= c
        this.reader.Advance(1)
      endif
    endwhile
    
    return this.Token(TOKEN_STRING, value, line, col)
  enddef
  
  def ReadIdentifier(): dict<any>
    var line = this.reader.line
    var col = this.reader.col
    var value = ''
    
    while !this.reader.IsEof() && this.reader.col < len(this.reader.current_line) && this.reader.Peek() =~ '[A-Za-z0-9_]'
      value ..= this.reader.Peek()
      this.reader.Advance(1)
    endwhile
    
    # Check if it's a keyword
    var token_type = TOKEN_IDENTIFIER
    if index(KEYWORDS, value) >= 0
      token_type = TOKEN_KEYWORD
    endif
    
    return this.Token(token_type, value, line, col)
  enddef
endclass

# Node structure - dict based factory function to avoid Vim9script class limitations
export def NewNode(type: number): dict<any>
  return {
    type: type,
    body: [],
    line: '',
    pos: 0,
    len: -1,
    name: '',
    params: [],
    rtype: '',
    value: null,
    left: null,
    right: null,
    op: '',
  }
enddef

# Operator precedence table (higher number = higher precedence)
const OPERATOR_PRECEDENCE = {
  '||': 1,
  '&&': 2,
  '==': 3, '!=': 3, '<': 3, '>': 3, '<=': 3, '>=': 3,
  '+': 4, '-': 4,
  '*': 5, '/': 5, '%': 5,
  '!': 6,  # unary
}

# Vim9Parser class
export class Vim9Parser
  var reader: StringReader
  var tokenizer: Vim9Tokenizer
  var current_token: dict<any> = {}
  var next_token: dict<any> = {}
  
  def new()
    enddef
  
  def Parse(reader: StringReader): dict<any>
    this.reader = reader
    this.tokenizer = Vim9Tokenizer.new(reader)
    this.Advance()  # Load first token
    this.Advance()  # Load second token
    
    var toplevel = NewNode(NODE_TOPLEVEL)
    
    while this.current_token.type != TOKEN_EOF
      if this.current_token.type == TOKEN_KEYWORD && this.current_token.value == 'vim9script'
        this.Advance()
        continue
      endif
      
      # Parse top-level statements
      var stmt = this.ParseTopLevelStatement()
      if len(stmt) > 0  # Check if dict is not empty
        toplevel.body->add(stmt)
      endif
    endwhile
    
    return toplevel
  enddef
  
  def ParseTopLevelStatement(): dict<any>
    # Only certain keywords are allowed at top level
    if this.current_token.type != TOKEN_KEYWORD
      # Skip non-keyword tokens
      this.Advance()
      return {}
    endif
    
    if this.current_token.value == 'var'
      return this.ParseVar()
    elseif this.current_token.value == 'const'
      return this.ParseConst()
    elseif this.current_token.value == 'def'
      return this.ParseDef()
    elseif this.current_token.value == 'class'
      return this.ParseClass()
    elseif this.current_token.value == 'import'
      return this.ParseImport()
    elseif this.current_token.value == 'export'
      return this.ParseExport()
    elseif this.current_token.value == 'if'
      return this.ParseIf()
    elseif this.current_token.value == 'while'
      return this.ParseWhile()
    elseif this.current_token.value == 'for'
      return this.ParseFor()
    elseif this.current_token.value == 'return'
      return this.ParseReturn()
    elseif this.current_token.value == 'try'
      return this.ParseTry()
    else
      # Skip unknown keywords at top level
      this.Advance()
      return {}
    endif
  enddef
  
  def Advance(): void
    this.current_token = this.next_token
    this.next_token = this.tokenizer.Get()
  enddef
  
  def Expect(type: number): dict<any>
    if this.current_token.type != type
      var type_names = {
        0: 'EOF',
        1: 'EOL',
        5: 'IDENTIFIER',
        6: 'KEYWORD',
        7: 'COLON',
        10: 'POPEN',
        11: 'PCLOSE',
        23: 'EQ',
        24: 'EQEQ',
      }
      var expected_name = get(type_names, type, string(type))
      var got_name = get(type_names, this.current_token.type, string(this.current_token.type))
      throw $'Syntax error at line {this.reader.line + 1}, col {this.reader.col + 1}: Expected {expected_name}, got {got_name} ({this.current_token.value})'
    endif
    var tok = this.current_token
    this.Advance()
    return tok
  enddef
  
  def ParseVar(): dict<any>
    var node = NewNode(NODE_VAR)
    var start_pos = this.current_token
    
    this.Expect(TOKEN_KEYWORD)  # var
    
    var name_tok = this.Expect(TOKEN_IDENTIFIER)
    node.name = name_tok.value
    
    # Optional type annotation
    if this.current_token.type == TOKEN_COLON
      this.Advance()
      node.rtype = this.ParseType()
    endif
    
    # Optional initialization
    if this.current_token.type == TOKEN_EQ
      this.Advance()
      node.body->add(this.ParseExpression())
    endif
    
    return node
  enddef
  
  def ParseConst(): dict<any>
    var node = NewNode(NODE_CONST)
    
    this.Expect(TOKEN_KEYWORD)  # const
    
    var name_tok = this.Expect(TOKEN_IDENTIFIER)
    node.name = name_tok.value
    
    # Optional type annotation
    if this.current_token.type == TOKEN_COLON
      this.Advance()
      node.rtype = this.ParseType()
    endif
    
    # Initialization (required for const)
    if this.current_token.type == TOKEN_EQ
      this.Advance()
      node.body->add(this.ParseExpression())
    endif
    
    return node
  enddef
  
  def ParseDef(): dict<any>
    var node = NewNode(NODE_DEF)
    
    this.Expect(TOKEN_KEYWORD)  # def
    
    var name_tok = this.Expect(TOKEN_IDENTIFIER)
    node.name = name_tok.value
    
    # Parse parameters
    this.Expect(TOKEN_POPEN)
    node.params = this.ParseParameterList()
    this.Expect(TOKEN_PCLOSE)
    
    # Parse return type
    if this.current_token.type == TOKEN_COLON
      this.Advance()
      node.rtype = this.ParseType()
    endif
    
    # Parse body
    while !(this.current_token.type == TOKEN_KEYWORD && this.current_token.value == 'enddef')
      if this.current_token.type == TOKEN_EOF
        throw $'Syntax error at line {this.reader.line + 1}: Unexpected EOF in def body'
      endif
      node.body->add(this.ParseStatement())
    endwhile
    
    this.Expect(TOKEN_KEYWORD)  # enddef
    
    return node
  enddef
  
  def ParseClass(): dict<any>
    var node = NewNode(NODE_CLASS)
    
    this.Expect(TOKEN_KEYWORD)  # class
    
    var name_tok = this.Expect(TOKEN_IDENTIFIER)
    node.name = name_tok.value
    
    # Parse body (members and methods)
    while !(this.current_token.type == TOKEN_KEYWORD && this.current_token.value == 'endclass')
      if this.current_token.type == TOKEN_EOF
        throw $'Syntax error at line {this.reader.line + 1}: Unexpected EOF in class body'
      endif
      
      if this.current_token.value == 'var' || this.current_token.value == 'const'
        node.body->add(this.ParseVar())
      elseif this.current_token.value == 'def'
        node.body->add(this.ParseDef())
      else
        this.Advance()
      endif
    endwhile
    
    this.Expect(TOKEN_KEYWORD)  # endclass
    
    return node
  enddef
  
  def ParseImport(): dict<any>
    var node = NewNode(NODE_IMPORT)
    
    this.Expect(TOKEN_KEYWORD)  # import
    
    # import autoload "module.vim" as m
    if this.current_token.value == 'autoload'
      this.Advance()
    endif
    
    var path_tok = this.Expect(TOKEN_STRING)
    node.line = path_tok.value
    
    if this.current_token.value == 'as'
      this.Advance()
      var alias_tok = this.Expect(TOKEN_IDENTIFIER)
      node.name = alias_tok.value
    endif
    
    return node
  enddef
  
  def ParseExport(): dict<any>
    var node = NewNode(NODE_EXPORT)
    
    this.Expect(TOKEN_KEYWORD)  # export
    
    if this.current_token.value == 'def'
      node.body->add(this.ParseDef())
    elseif this.current_token.value == 'const'
      node.body->add(this.ParseConst())
    elseif this.current_token.value == 'var'
      node.body->add(this.ParseVar())
    elseif this.current_token.value == 'class'
      node.body->add(this.ParseClass())
    endif
    
    return node
  enddef
  
  def ParseStatement(): dict<any>
    # Check for control statements and declarations
    if this.current_token.type == TOKEN_KEYWORD
      if this.current_token.value == 'var'
        return this.ParseVar()
      elseif this.current_token.value == 'const'
        return this.ParseConst()
      elseif this.current_token.value == 'if'
        return this.ParseIf()
      elseif this.current_token.value == 'while'
        return this.ParseWhile()
      elseif this.current_token.value == 'for'
        return this.ParseFor()
      elseif this.current_token.value == 'return'
        return this.ParseReturn()
      elseif this.current_token.value == 'break'
        this.Advance()
        return NewNode(NODE_BREAK)
      elseif this.current_token.value == 'continue'
        this.Advance()
        return NewNode(NODE_CONTINUE)
      elseif this.current_token.value == 'echo'
        var echo_node = NewNode(NODE_ECHO)
        this.Advance()
        # Parse echo arguments
        while this.current_token.type != TOKEN_KEYWORD && this.current_token.type != TOKEN_EOF
          echo_node.body->add(this.ParseExpression())
          if this.current_token.type == TOKEN_COMMA
            this.Advance()
          else
            break
          endif
        endwhile
        return echo_node
      elseif this.current_token.value == 'try'
        return this.ParseTry()
      elseif this.current_token.value == 'throw'
        var throw_node = NewNode(NODE_THROW)
        this.Advance()
        throw_node.body->add(this.ParseExpression())
        return throw_node
      endif
    endif
    
    # Parse expression statement (may include assignment)
    var expr = this.ParseExpression()
    
    # Check for assignment
    if this.current_token.type == TOKEN_EQ
      this.Advance()
      var value = this.ParseExpression()
      var assign_node = NewNode(NODE_LET)
      assign_node.left = expr
      assign_node.right = value
      return assign_node
    endif
    
    return expr
  enddef
  
  def ParseIf(): dict<any>
    var node = NewNode(NODE_IF)
    this.Expect(TOKEN_KEYWORD)  # 'if'
    
    # Parse condition
    var condition = this.ParseExpression()
    node.body = [condition]
    
    # Parse if body
    var if_body: list<dict<any>> = []
    while this.current_token.type != TOKEN_KEYWORD || 
          (this.current_token.value != 'else' && 
           this.current_token.value != 'elseif' && 
           this.current_token.value != 'endif')
      if this.current_token.type == TOKEN_EOF
        throw $'Syntax error at line {this.reader.line + 1}: Unexpected EOF in if statement (expected endif)'
      endif
      if_body->add(this.ParseStatement())
    endwhile
    node.body->add(if_body)
    
    # Parse else/elseif/endif
    while this.current_token.type == TOKEN_KEYWORD && 
          (this.current_token.value == 'elseif' || this.current_token.value == 'else')
      if this.current_token.value == 'elseif'
        this.Advance()
        var elseif_cond = this.ParseExpression()
        var elseif_node = NewNode(NODE_ELSEIF)
        elseif_node.body = [elseif_cond]
        
        var elseif_body: list<dict<any>> = []
        while this.current_token.type != TOKEN_KEYWORD || 
              (this.current_token.value != 'else' && 
               this.current_token.value != 'elseif' && 
               this.current_token.value != 'endif')
          elseif_body->add(this.ParseStatement())
        endwhile
        elseif_node.body->add(elseif_body)
        node.body->add(elseif_node)
      elseif this.current_token.value == 'else'
        this.Advance()
        var else_node = NewNode(NODE_ELSE)
        var else_body: list<dict<any>> = []
        while !(this.current_token.type == TOKEN_KEYWORD && this.current_token.value == 'endif')
          if this.current_token.type == TOKEN_EOF
            throw $'Syntax error at line {this.reader.line + 1}: Unexpected EOF in else statement'
          endif
          else_body->add(this.ParseStatement())
        endwhile
        else_node.body = else_body
        node.body->add(else_node)
        break
      endif
    endwhile
    
    this.Expect(TOKEN_KEYWORD)  # 'endif'
    return node
  enddef
  
  def ParseWhile(): dict<any>
    var node = NewNode(NODE_WHILE)
    this.Expect(TOKEN_KEYWORD)  # 'while'
    
    # Parse condition
    var condition = this.ParseExpression()
    node.body = [condition]
    
    # Parse body
    var body: list<dict<any>> = []
    while !(this.current_token.type == TOKEN_KEYWORD && this.current_token.value == 'endwhile')
      if this.current_token.type == TOKEN_EOF
        throw $'Syntax error at line {this.reader.line + 1}: Unexpected EOF in while statement'
      endif
      body->add(this.ParseStatement())
    endwhile
    node.body->add(body)
    
    this.Expect(TOKEN_KEYWORD)  # 'endwhile'
    return node
  enddef
  
  def ParseFor(): dict<any>
    var node = NewNode(NODE_FOR)
    this.Expect(TOKEN_KEYWORD)  # 'for'
    
    # Parse variable
    var var_name = this.Expect(TOKEN_IDENTIFIER).value
    node.name = var_name
    
    # Expect 'in'
    if this.current_token.type != TOKEN_KEYWORD || this.current_token.value != 'in'
      throw $'Syntax error at line {this.reader.line + 1}, col {this.reader.col + 1}: Expected "in" keyword in for loop, got "{this.current_token.value}"'
    endif
    this.Advance()
    
    # Parse iterable expression
    var iterable = this.ParseExpression()
    node.body = [iterable]
    
    # Parse body
    var body: list<dict<any>> = []
    while !(this.current_token.type == TOKEN_KEYWORD && this.current_token.value == 'endfor')
      if this.current_token.type == TOKEN_EOF
        throw $'Syntax error at line {this.reader.line + 1}: Unexpected EOF in for statement'
      endif
      body->add(this.ParseStatement())
    endwhile
    node.body->add(body)
    
    this.Expect(TOKEN_KEYWORD)  # 'endfor'
    return node
  enddef
  
  def ParseReturn(): dict<any>
    var node = NewNode(NODE_RETURN)
    this.Expect(TOKEN_KEYWORD)  # 'return'
    
    # Return value is optional
    if this.current_token.type != TOKEN_KEYWORD
      var return_val = this.ParseExpression()
      node.body = [return_val]
    endif
    
    return node
  enddef
  
  def ParseTry(): dict<any>
    var node = NewNode(NODE_TRY)
    this.Expect(TOKEN_KEYWORD)  # 'try'
    
    # Parse try body
    var try_body: list<dict<any>> = []
    while !(this.current_token.type == TOKEN_KEYWORD && 
            (this.current_token.value == 'catch' || this.current_token.value == 'finally' || this.current_token.value == 'endtry'))
      if this.current_token.type == TOKEN_EOF
        throw $'Syntax error at line {this.reader.line + 1}: Unexpected EOF in try statement'
      endif
      try_body->add(this.ParseStatement())
    endwhile
    node.body = [try_body]
    
    # Parse catch blocks
    while this.current_token.type == TOKEN_KEYWORD && this.current_token.value == 'catch'
      this.Advance()
      var catch_node = NewNode(NODE_CATCH)
      
      # Parse exception variable (optional)
      if this.current_token.type == TOKEN_KEYWORD && this.current_token.value == 'as'
        this.Advance()
        var exc_var = this.Expect(TOKEN_IDENTIFIER)
        catch_node.name = exc_var.value
      endif
      
      # Parse catch body
      var catch_body: list<dict<any>> = []
      while !(this.current_token.type == TOKEN_KEYWORD && 
              (this.current_token.value == 'catch' || this.current_token.value == 'finally' || this.current_token.value == 'endtry'))
        if this.current_token.type == TOKEN_EOF
          throw $'Syntax error at line {this.reader.line + 1}: Unexpected EOF in catch block'
        endif
        catch_body->add(this.ParseStatement())
      endwhile
      catch_node.body = catch_body
      node.body->add(catch_node)
    endwhile
    
    # Parse finally block (optional)
    if this.current_token.type == TOKEN_KEYWORD && this.current_token.value == 'finally'
      this.Advance()
      var finally_node = NewNode(NODE_FINALLY)
      
      var finally_body: list<dict<any>> = []
      while !(this.current_token.type == TOKEN_KEYWORD && this.current_token.value == 'endtry')
        if this.current_token.type == TOKEN_EOF
          throw $'Syntax error at line {this.reader.line + 1}: Unexpected EOF in finally block'
        endif
        finally_body->add(this.ParseStatement())
      endwhile
      finally_node.body = finally_body
      node.body->add(finally_node)
    endif
    
    this.Expect(TOKEN_KEYWORD)  # 'endtry'
    return node
  enddef
  
  def ParseParameterList(): list<any>
    var params: list<any> = []
    
    while this.current_token.type == TOKEN_IDENTIFIER
      var param: dict<any> = {}
      
      param.name = this.Expect(TOKEN_IDENTIFIER).value
      
      if this.current_token.type == TOKEN_COLON
        this.Advance()
        param.type = this.ParseType()
      endif
      
      params->add(param)
      
      if this.current_token.type == TOKEN_COMMA
        this.Advance()
      else
        break
      endif
    endwhile
    
    return params
  enddef
  
  def ParseType(): string
    var type_str = ''
    
    if this.current_token.type != TOKEN_IDENTIFIER && this.current_token.type != TOKEN_KEYWORD
      throw $'Expected type, got {this.current_token.value}'
    endif
    
    type_str = this.current_token.value
    this.Advance()
    
    # Handle generic types: list<string>, dict<number>, etc.
    if this.current_token.type == TOKEN_LT
      this.Advance()
      type_str ..= '<'
      type_str ..= this.ParseType()
      if this.current_token.type == TOKEN_GT
        this.Advance()
        type_str ..= '>'
      endif
    endif
    
    return type_str
  enddef
  
  def ParseExpression(): dict<any>
    return this.ParseTernary()
  enddef
  
  def ParseTernary(): dict<any>
    var condition = this.ParseLogicalOr()
    
    if this.current_token.type == TOKEN_QUESTION
      this.Advance()
      var true_expr = this.ParseExpression()
      this.Expect(TOKEN_COLON)
      var false_expr = this.ParseExpression()
      var node = NewNode(NODE_TERNARY)
      node.body = [condition, true_expr, false_expr]
      return node
    endif
    
    return condition
  enddef
  
  def ParseLogicalOr(): dict<any>
    var left = this.ParseLogicalAnd()
    
    while this.current_token.type == TOKEN_OR
      var op = this.current_token.value
      this.Advance()
      var right = this.ParseLogicalAnd()
      var node = NewNode(NODE_OR)
      node.op = op
      node.left = left
      node.right = right
      left = node
    endwhile
    
    return left
  enddef
  
  def ParseLogicalAnd(): dict<any>
    var left = this.ParseBitwiseOr()
    
    while this.current_token.type == TOKEN_AND
      var op = this.current_token.value
      this.Advance()
      var right = this.ParseBitwiseOr()
      var node = NewNode(NODE_AND)
      node.op = op
      node.left = left
      node.right = right
      left = node
    endwhile
    
    return left
  enddef
  
  def ParseBitwiseOr(): dict<any>
    var left = this.ParseBitwiseXor()
    
    while this.current_token.type == TOKEN_PIPE
      this.Advance()
      var right = this.ParseBitwiseXor()
      var node = NewNode(NODE_BIT_OR)
      node.left = left
      node.right = right
      left = node
    endwhile
    
    return left
  enddef
  
  def ParseBitwiseXor(): dict<any>
    var left = this.ParseBitwiseAnd()
    
    while this.current_token.type == TOKEN_CARET
      this.Advance()
      var right = this.ParseBitwiseAnd()
      var node = NewNode(NODE_BIT_XOR)
      node.left = left
      node.right = right
      left = node
    endwhile
    
    return left
  enddef
  
  def ParseBitwiseAnd(): dict<any>
    var left = this.ParseComparison()
    
    while this.current_token.type == TOKEN_AMPERSAND
      this.Advance()
      var right = this.ParseComparison()
      var node = NewNode(NODE_BIT_AND)
      node.left = left
      node.right = right
      left = node
    endwhile
    
    return left
  enddef
  
  def ParseComparison(): dict<any>
    var left = this.ParseShift()
    
    while this.current_token.type == TOKEN_EQEQ ||
          this.current_token.type == TOKEN_NEQ ||
          this.current_token.type == TOKEN_LT ||
          this.current_token.type == TOKEN_GT ||
          this.current_token.type == TOKEN_LTEQ ||
          this.current_token.type == TOKEN_GTEQ
      var op = this.current_token.value
      var tok_type = this.current_token.type
      this.Advance()
      var right = this.ParseShift()
      var node = NewNode(NODE_EQUAL)
      if tok_type == TOKEN_NEQ
        node.type = NODE_NEQUAL
      elseif tok_type == TOKEN_LT
        node.type = NODE_SMALLER
      elseif tok_type == TOKEN_GT
        node.type = NODE_GREATER
      elseif tok_type == TOKEN_LTEQ
        node.type = NODE_SEQUAL
      elseif tok_type == TOKEN_GTEQ
        node.type = NODE_GEQUAL
      endif
      node.op = op
      node.left = left
      node.right = right
      left = node
    endwhile
    
    return left
  enddef
  
  def ParseShift(): dict<any>
    var left = this.ParseAdditive()
    
    while this.current_token.type == TOKEN_LSHIFT ||
          this.current_token.type == TOKEN_RSHIFT
      var tok_type = this.current_token.type
      this.Advance()
      var right = this.ParseAdditive()
      var node = NewNode(tok_type == TOKEN_LSHIFT ? NODE_LSHIFT : NODE_RSHIFT)
      node.left = left
      node.right = right
      left = node
    endwhile
    
    return left
  enddef
  
  def ParseAdditive(): dict<any>
    var left = this.ParseMultiplicative()
    
    while this.current_token.type == TOKEN_PLUS ||
          this.current_token.type == TOKEN_MINUS
      var op = this.current_token.value
      var tok_type = this.current_token.type
      this.Advance()
      var right = this.ParseMultiplicative()
      var node = NewNode(tok_type == TOKEN_PLUS ? NODE_ADD : NODE_SUBTRACT)
      node.op = op
      node.left = left
      node.right = right
      left = node
    endwhile
    
    return left
  enddef
  
  def ParseMultiplicative(): dict<any>
    var left = this.ParseUnary()
    
    while this.current_token.type == TOKEN_STAR ||
          this.current_token.type == TOKEN_SLASH ||
          this.current_token.type == TOKEN_PERCENT
      var op = this.current_token.value
      var tok_type = this.current_token.type
      this.Advance()
      var right = this.ParseUnary()
      var node_type = NODE_MULTIPLY
      if tok_type == TOKEN_SLASH
        node_type = NODE_DIVIDE
      elseif tok_type == TOKEN_PERCENT
        node_type = NODE_MODULO
      endif
      var node = NewNode(node_type)
      node.op = op
      node.left = left
      node.right = right
      left = node
    endwhile
    
    return left
  enddef
  
  def ParseUnary(): dict<any>
    if this.current_token.type == TOKEN_NOT
      this.Advance()
      var operand = this.ParseUnary()
      var node = NewNode(NODE_NOT)
      node.left = operand
      return node
    elseif this.current_token.type == TOKEN_MINUS
      this.Advance()
      var operand = this.ParseUnary()
      var node = NewNode(NODE_SUBTRACT)
      node.left = operand
      return node
    endif
    
    return this.ParsePostfix()
  enddef
  
  def ParsePostfix(): dict<any>
    var left = this.ParsePrimary()
    
    while true
      if this.current_token.type == TOKEN_DOT
        # Member access: obj.field
        this.Advance()
        if this.current_token.type != TOKEN_IDENTIFIER
          throw $'Expected identifier after ., got {this.current_token.value}'
        endif
        var field = this.current_token.value
        this.Advance()
        var node = NewNode(NODE_DOT)
        node.left = left
        node.name = field
        left = node
      elseif this.current_token.type == TOKEN_SQOPEN
        # Array access: arr[index]
        this.Advance()
        var index = this.ParseExpression()
        this.Expect(TOKEN_SQCLOSE)
        var node = NewNode(NODE_SUBSCRIPT)
        node.left = left
        node.right = index
        left = node
      elseif this.current_token.type == TOKEN_POPEN
        # Function call: func(args)
        this.Advance()
        var args: list<dict<any>> = []
        
        while this.current_token.type != TOKEN_PCLOSE && this.current_token.type != TOKEN_EOF
          args->add(this.ParseExpression())
          if this.current_token.type == TOKEN_COMMA
            this.Advance()
          else
            break
          endif
        endwhile
        
        this.Expect(TOKEN_PCLOSE)
        var node = NewNode(NODE_CALL)
        node.left = left
        node.body = args
        left = node
      else
        break
      endif
    endwhile
    
    return left
  enddef
  
  def ParsePrimary(): dict<any>
    if this.current_token.type == TOKEN_NUMBER
      var node = NewNode(NODE_NUMBER)
      node.value = this.current_token.value
      this.Advance()
      return node
    elseif this.current_token.type == TOKEN_STRING
      var node = NewNode(NODE_STRING)
      node.value = this.current_token.value
      this.Advance()
      return node
    elseif this.current_token.type == TOKEN_IDENTIFIER
      var node = NewNode(NODE_IDENTIFIER)
      node.name = this.current_token.value
      this.Advance()
      return node
    elseif this.current_token.value == 'true'
      var node = NewNode(NODE_TRUE)
      this.Advance()
      return node
    elseif this.current_token.value == 'false'
      var node = NewNode(NODE_FALSE)
      this.Advance()
      return node
    elseif this.current_token.value == 'null'
      var node = NewNode(NODE_NULL)
      this.Advance()
      return node
    elseif this.current_token.type == TOKEN_POPEN
      # Parenthesized expression or lambda: (x) or (x) => x + 1
      var saved_line = this.reader.line
      var saved_col = this.reader.col
      
      this.Advance()
      
      # Try to parse as lambda
      var is_lambda = false
      var params: list<string> = []
      
      # Check for lambda parameters
      if this.current_token.type == TOKEN_PCLOSE
        # Empty parameter list: () => ...
        is_lambda = true
        this.Advance()
      elseif this.current_token.type == TOKEN_IDENTIFIER
        # Could be (x) => or (expr)
        var first_id = this.current_token.value
        this.Advance()
        
        if this.current_token.type == TOKEN_COMMA || this.current_token.type == TOKEN_PCLOSE
          # Lambda parameter list
          is_lambda = true
          params->add(first_id)
          
          while this.current_token.type == TOKEN_COMMA
            this.Advance()
            if this.current_token.type == TOKEN_IDENTIFIER
              params->add(this.current_token.value)
              this.Advance()
            endif
          endwhile
          
          this.Expect(TOKEN_PCLOSE)
        else
          # Not a lambda, restore and parse as expression
          is_lambda = false
        endif
      endif
      
      if is_lambda && this.current_token.type == TOKEN_ARROW
        # Lambda expression: (x, y) => x + y
        this.Advance()
        var body_expr = this.ParseExpression()
        var node = NewNode(NODE_LAMBDA)
        node.params = params
        node.body = [body_expr]
        return node
      else
        # Regular parenthesized expression - need to reparse
        this.reader.SetPos(saved_line, saved_col)
        this.Advance()  # Skip (
        this.Advance()  # Reload token
        var expr = this.ParseExpression()
        this.Expect(TOKEN_PCLOSE)
        return expr
      endif
    elseif this.current_token.type == TOKEN_SQOPEN
      # Array literal: [1, 2, 3]
      this.Advance()
      var elements: list<dict<any>> = []
      
      while this.current_token.type != TOKEN_SQCLOSE && this.current_token.type != TOKEN_EOF
        elements->add(this.ParseExpression())
        if this.current_token.type == TOKEN_COMMA
          this.Advance()
        else
          break
        endif
      endwhile
      
      this.Expect(TOKEN_SQCLOSE)
      var node = NewNode(NODE_LIST)
      node.body = elements
      return node
    elseif this.current_token.type == TOKEN_COPEN
      # Dict literal: {key: value}
      this.Advance()
      var pairs: list<any> = []
      
      while this.current_token.type != TOKEN_CCLOSE && this.current_token.type != TOKEN_EOF
        var key = this.current_token.value
        this.Advance()
        this.Expect(TOKEN_COLON)
        var value = this.ParseExpression()
        pairs->add({key: key, value: value})
        
        if this.current_token.type == TOKEN_COMMA
          this.Advance()
        else
          break
        endif
      endwhile
      
      this.Expect(TOKEN_CCLOSE)
      var node = NewNode(NODE_DICT)
      node.body = pairs
      return node
    else
      throw $'Syntax error at line {this.reader.line + 1}, col {this.reader.col + 1}: Unexpected token in expression: "{this.current_token.value}" (type {this.current_token.type})'
    endif
  enddef
endclass

# Compiler class
export class Compiler
  def new()
    enddef
  
  def Compile(node: dict<any>): list<string>
    var result: list<string> = []
    this.CompileNode(node, 0, result)
    return result
  enddef
  
  def CompileNode(node: dict<any>, depth: number, result: list<string>): void
    var indent = repeat('  ', depth)
    var type_names = {
      1: 'TOPLEVEL',
      13: 'IF',
      17: 'WHILE',
      19: 'FOR',
      23: 'TRY',
      24: 'CATCH',
      25: 'FINALLY',
      27: 'THROW',
      28: 'ECHO',
      201: 'VAR',
      202: 'CONST',
      203: 'DEF',
      205: 'CLASS',
      209: 'IMPORT',
      210: 'EXPORT',
      300: 'ADD',
      305: 'NUMBER',
      306: 'STRING',
      307: 'IDENTIFIER',
      313: 'CALL',
    }
    var type_name = get(type_names, node.type, string(node.type))
    
    if node.type == NODE_TOPLEVEL
      for child in node.body
        this.CompileNode(child, depth, result)
      endfor
    elseif node.type == NODE_VAR
      var type_str = empty(node.rtype) ? '' : $' : {node.rtype}'
      result->add($'{indent}(var {node.name}{type_str})')
      for expr in node.body
        this.CompileNode(expr, depth + 1, result)
      endfor
    elseif node.type == NODE_CONST
      var type_str = empty(node.rtype) ? '' : $' : {node.rtype}'
      result->add($'{indent}(const {node.name}{type_str})')
      for expr in node.body
        this.CompileNode(expr, depth + 1, result)
      endfor
    elseif node.type == NODE_DEF
      var params_str = ''
      for p in node.params
        params_str ..= $'{p.name}: {get(p, "type", "any")} '
      endfor
      params_str = trim(params_str)
      var ret_str = empty(node.rtype) ? '' : $': {node.rtype}'
      result->add($'{indent}(def {node.name}({params_str}){ret_str})')
      for stmt in node.body
        this.CompileNode(stmt, depth + 1, result)
      endfor
      result->add($'{indent}(enddef)')
    elseif node.type == NODE_CLASS
      result->add($'{indent}(class {node.name})')
      for stmt in node.body
        this.CompileNode(stmt, depth + 1, result)
      endfor
      result->add($'{indent}(endclass)')
    elseif node.type == NODE_IF
      result->add($'{indent}(if)')
      for stmt in node.body
        if type(stmt) == v:t_dict && !empty(stmt)
          this.CompileNode(stmt, depth + 1, result)
        endif
      endfor
      result->add($'{indent}(endif)')
    elseif node.type == NODE_WHILE
      result->add($'{indent}(while)')
      for stmt in node.body
        if type(stmt) == v:t_dict && !empty(stmt)
          this.CompileNode(stmt, depth + 1, result)
        endif
      endfor
      result->add($'{indent}(endwhile)')
    elseif node.type == NODE_FOR
      result->add($'{indent}(for {node.name})')
      for stmt in node.body
        if type(stmt) == v:t_dict && !empty(stmt)
          this.CompileNode(stmt, depth + 1, result)
        endif
      endfor
      result->add($'{indent}(endfor)')
    elseif node.type == NODE_TRY
      result->add($'{indent}(try)')
      for stmt in node.body
        if type(stmt) == v:t_dict && !empty(stmt)
          this.CompileNode(stmt, depth + 1, result)
        endif
      endfor
      result->add($'{indent}(endtry)')
    elseif node.type == NODE_TERNARY
      result->add($'{indent}(TERNARY)')
      for expr in node.body
        this.CompileNode(expr, depth + 1, result)
      endfor
    elseif node.type >= 300
      # Expression nodes
      if node.type == NODE_LAMBDA
        var params_str = join(node.params, ', ')
        result->add($'{indent}(LAMBDA ({params_str}))')
        for expr in node.body
          this.CompileNode(expr, depth + 1, result)
        endfor
      elseif node.type == NODE_ADD || node.type == NODE_SUBTRACT || node.type == NODE_MULTIPLY || node.type == NODE_DIVIDE || 
            node.type == NODE_MODULO || node.type == NODE_OR || node.type == NODE_AND ||
            node.type == NODE_EQUAL || node.type == NODE_NEQUAL || node.type == NODE_GREATER || node.type == NODE_GEQUAL ||
            node.type == NODE_SMALLER || node.type == NODE_SEQUAL ||
            node.type == NODE_BIT_OR || node.type == NODE_BIT_XOR || node.type == NODE_BIT_AND ||
            node.type == NODE_LSHIFT || node.type == NODE_RSHIFT
        var op_names = {
          300: 'ADD', 301: 'SUBTRACT', 302: 'MULTIPLY', 303: 'DIVIDE', 304: 'MODULO',
          35: 'OR', 36: 'AND', 37: 'EQUAL', 40: 'NEQUAL', 43: 'GREATER', 46: 'GEQUAL',
          49: 'SMALLER', 52: 'SEQUAL',
          318: 'BIT_OR', 319: 'BIT_XOR', 320: 'BIT_AND', 321: 'LSHIFT', 322: 'RSHIFT'
        }
        var op_name = get(op_names, node.type, string(node.type))
        result->add($'{indent}({op_name})')
        if node.left != null
          this.CompileNode(node.left, depth + 1, result)
        endif
        if node.right != null
          this.CompileNode(node.right, depth + 1, result)
        endif
      elseif node.type == NODE_NOT
        result->add($'{indent}(NOT)')
        if node.left != null
          this.CompileNode(node.left, depth + 1, result)
        endif
      elseif node.type == NODE_DOT
        result->add($'{indent}(DOT)')
        if node.left != null
          this.CompileNode(node.left, depth + 1, result)
        endif
        result->add($'{indent}  (FIELD {node.name})')
      elseif node.type == NODE_SUBSCRIPT
        result->add($'{indent}(SUBSCRIPT)')
        if node.left != null
          this.CompileNode(node.left, depth + 1, result)
        endif
        if node.right != null
          this.CompileNode(node.right, depth + 1, result)
        endif
      elseif node.type == NODE_CALL
        result->add($'{indent}(CALL)')
        if node.left != null
          this.CompileNode(node.left, depth + 1, result)
        endif
        for arg in node.body
          this.CompileNode(arg, depth + 1, result)
        endfor
      elseif node.type == NODE_LIST
        result->add($'{indent}(LIST)')
        for elem in node.body
          this.CompileNode(elem, depth + 1, result)
        endfor
      elseif node.type == NODE_DICT
        result->add($'{indent}(DICT)')
        for pair in node.body
          result->add($'{indent}  (PAIR)')
          result->add($'{indent}    (KEY {pair.key})')
          this.CompileNode(pair.value, depth + 2, result)
        endfor
      elseif node.type == NODE_NUMBER
        result->add($'{indent}(NUMBER {node.value})')
      elseif node.type == NODE_STRING
        result->add($'{indent}(STRING "{node.value}")')
      elseif node.type == NODE_IDENTIFIER
        result->add($'{indent}(IDENTIFIER {node.name})')
      elseif node.type == NODE_TRUE
        result->add($'{indent}(TRUE)')
      elseif node.type == NODE_FALSE
        result->add($'{indent}(FALSE)')
      elseif node.type == NODE_NULL
        result->add($'{indent}(NULL)')
      else
        result->add($'{indent}({type_name})')
      endif
    elseif node.type == NODE_IMPORT
      result->add($'{indent}(import {node.name})')
    elseif node.type == NODE_EXPORT
      result->add($'{indent}(export)')
      for child in node.body
        if type(child) == v:t_dict && !empty(child)
          this.CompileNode(child, depth + 1, result)
        endif
      endfor
    else
      result->add($'{indent}({type_name})')
    endif
  enddef
endclass

# Public interface - Return global scope
export def Import(): dict<any>
  # In Vim9script, we can't return class references directly
  # Instead, return a dict with function references
  return {}
enddef

export def Test(input: any): void
  var lines: list<any>
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
  var ast = parser.Parse(reader)
  
  for line in compiler.Compile(ast)
    echo line
  endfor
enddef
