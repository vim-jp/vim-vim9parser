vim9script

# Vim9 Script Parser
#
# License: This file is placed in the public domain.

def import(): dict<any>
  return {
    StringReader: StringReader,
    Vim9Parser: Vim9Parser,
    Compiler: Compiler,
  }
enddef

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
  var pos: number = 0
  var lnum: number = 1
  var col: number = 0
  
  def new(lines: list<string>): StringReader
    this.lines = lines
    return this
  enddef
  
  def peek(offset: number = 0): string
    var pos = this.pos + offset
    if pos < len(this.lines)
      return this.lines[pos]
    endif
    return ''
  enddef
  
  def read(): string
    if this.pos < len(this.lines)
      var line = this.lines[this.pos]
      this.pos += 1
      this.lnum += 1
      return line
    endif
    return ''
  enddef
  
  def iseof(): bool
    return this.pos >= len(this.lines)
  enddef
  
  def getpos(): dict<number>
    return {
      pos: this.pos,
      lnum: this.lnum,
      col: this.col,
    }
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
  var current_line: string = ''
  var indent_level: number = 0
  
  def new(): Vim9Parser
    return this
  enddef
  
  def parse(reader: StringReader): Node
    this.reader = reader
    var toplevel = Node.new(NODE_TOPLEVEL)
    
    while !this.reader.iseof()
      var line = this.reader.peek()
      var trimmed = line->trim()
      
      # Skip empty lines and comments
      if empty(trimmed) || trimmed[0] == '#'
        this.reader.read()
        continue
      endif
      
      # Parse vim9script specific statements
      if trimmed =~ '^vim9script'
        this.reader.read()
        continue
      elseif trimmed =~ '^var\s'
        toplevel.body->add(this.parseVar())
      elseif trimmed =~ '^const\s'
        toplevel.body->add(this.parseConst())
      elseif trimmed =~ '^def\s'
        toplevel.body->add(this.parseDef())
      elseif trimmed =~ '^class\s'
        toplevel.body->add(this.parseClass())
      elseif trimmed =~ '^import\s'
        toplevel.body->add(this.parseImport())
      elseif trimmed =~ '^export\s'
        toplevel.body->add(this.parseExport())
      else
        toplevel.body->add(this.parseExcmd())
      endif
    endwhile
    
    return toplevel
  enddef
  
  def parseVar(): Node
    var node = Node.new(NODE_VAR)
    node.line = this.reader.read()
    # TODO: Parse variable name, type annotation, initial value
    return node
  enddef
  
  def parseConst(): Node
    var node = Node.new(NODE_CONST)
    node.line = this.reader.read()
    # TODO: Parse const name, type annotation, initial value
    return node
  enddef
  
  def parseDef(): Node
    var node = Node.new(NODE_DEF)
    var startline = this.reader.read()
    node.line = startline
    
    # TODO: Parse function signature (name, params with types, return type)
    
    while !this.reader.iseof()
      var line = this.reader.peek()
      if line =~ '^\s*enddef\s*$'
        this.reader.read()
        break
      endif
      node.body->add(this.reader.read())
    endwhile
    
    return node
  enddef
  
  def parseClass(): Node
    var node = Node.new(NODE_CLASS)
    var startline = this.reader.read()
    node.line = startline
    
    # TODO: Parse class name, extends, implements, members, methods
    
    while !this.reader.iseof()
      var line = this.reader.peek()
      if line =~ '^\s*endclass\s*$'
        this.reader.read()
        break
      endif
      node.body->add(this.reader.read())
    endwhile
    
    return node
  enddef
  
  def parseImport(): Node
    var node = Node.new(NODE_IMPORT)
    node.line = this.reader.read()
    # TODO: Parse import path and item names
    return node
  enddef
  
  def parseExport(): Node
    var node = Node.new(NODE_EXPORT)
    node.line = this.reader.read()
    # TODO: Parse export target (def, class, const, var)
    return node
  enddef
  
  def parseExcmd(): Node
    var node = Node.new(NODE_EXCMD)
    node.line = this.reader.read()
    return node
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
