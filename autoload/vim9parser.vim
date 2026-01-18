" vim:set ts=8 sts=2 sw=2 tw=0 et:
"
" Vim9 Script Parser
"
" License: This file is placed in the public domain.

function! vim9parser#import() abort
  return s:
endfunction

" @brief Read input as Vim9Script and return stringified AST.
" @param input Input filename or string of Vim9Script.
" @return Stringified AST.
function! vim9parser#test(input) abort
  try
    let lines = type(a:input) ==# 1 && filereadable(a:input) ? readfile(a:input) : split(a:input, "\n")
    let r = s:StringReader.new(lines)
    let p = s:Vim9Parser.new()
    let c = s:Compiler.new()
    echo join(c.compile(p.parse(r)), "\n")
  catch
    echoerr v:exception
  endtry
endfunction

" Node types - compatible with vimlparser
let s:NODE_TOPLEVEL = 1
let s:NODE_COMMENT = 2
let s:NODE_EXCMD = 3
let s:NODE_FUNCTION = 4
let s:NODE_ENDFUNCTION = 5
let s:NODE_DELFUNCTION = 6
let s:NODE_RETURN = 7
let s:NODE_EXCALL = 8
let s:NODE_LET = 9
let s:NODE_UNLET = 10
let s:NODE_LOCKVAR = 11
let s:NODE_UNLOCKVAR = 12
let s:NODE_IF = 13
let s:NODE_ELSEIF = 14
let s:NODE_ELSE = 15
let s:NODE_ENDIF = 16
let s:NODE_WHILE = 17
let s:NODE_ENDWHILE = 18
let s:NODE_FOR = 19
let s:NODE_ENDFOR = 20
let s:NODE_CONTINUE = 21
let s:NODE_BREAK = 22
let s:NODE_TRY = 23
let s:NODE_CATCH = 24
let s:NODE_FINALLY = 25
let s:NODE_ENDTRY = 26
let s:NODE_THROW = 27
let s:NODE_ECHO = 28
let s:NODE_ECHON = 29
let s:NODE_ECHOHL = 30
let s:NODE_ECHOMSG = 31
let s:NODE_ECHOERR = 32
let s:NODE_EXECUTE = 33
let s:NODE_TERNARY = 34
let s:NODE_OR = 35
let s:NODE_AND = 36
let s:NODE_EQUAL = 37
let s:NODE_NEQUAL = 40
let s:NODE_GREATER = 43
let s:NODE_GEQUAL = 46
let s:NODE_SMALLER = 49
let s:NODE_SEQUAL = 52

" Vim9 specific node types
let s:NODE_VAR = 201          " var declaration
let s:NODE_CONST = 202        " const declaration
let s:NODE_DEF = 203          " def function
let s:NODE_ENDDEF = 204       " enddef
let s:NODE_CLASS = 205        " class definition
let s:NODE_ENDCLASS = 206     " endclass
let s:NODE_EXTENDS = 207      " extends keyword
let s:NODE_IMPLEMENTS = 208   " implements keyword
let s:NODE_IMPORT = 209       " import statement
let s:NODE_EXPORT = 210       " export statement
let s:NODE_ENUM = 211         " enum definition
let s:NODE_ENDENUM = 212      " endenum
let s:NODE_TYPE = 213         " type annotation

" StringReader - reads lines
let s:StringReader = {}

function! s:StringReader.new(lines) abort
  let obj = {
    \ 'lines': a:lines,
    \ 'pos': 0,
    \ 'lnum': 1,
    \ 'col': 0,
    \ }
  return obj
endfunction

function! s:StringReader.peek(...) abort dict
  let offset = a:0 > 0 ? a:1 : 0
  let pos = self.pos + offset
  if pos < len(self.lines)
    return self.lines[pos]
  endif
  return ''
endfunction

function! s:StringReader.read() abort dict
  if self.pos < len(self.lines)
    let line = self.lines[self.pos]
    self.pos += 1
    self.lnum += 1
    return line
  endif
  return ''
endfunction

function! s:StringReader.iseof() abort dict
  return self.pos >= len(self.lines)
endfunction

" Vim9Parser - parses vim9script
let s:Vim9Parser = {}

function! s:Vim9Parser.new() abort
  return {
    \ 'reader': {},
    \ }
endfunction

function! s:Vim9Parser.parse(reader) abort dict
  let self.reader = a:reader
  let toplevel = {
    \ 'type': s:NODE_TOPLEVEL,
    \ 'body': [],
    \ 'pos': 0,
    \ 'len': -1,
    \ }
  
  while !self.reader.iseof()
    let line = self.reader.peek()
    let line_trimmed = substitute(line, '^\s*', '', '')
    
    " Skip empty lines and comments
    if empty(line_trimmed) || line_trimmed[0] ==# '"'
      call self.reader.read()
      continue
    endif
    
    " Parse vim9script specific statements
    if line_trimmed =~# '^vim9script'
      call self.reader.read()
      continue
    elseif line_trimmed =~# '^var\s'
      call add(toplevel.body, self.parseVar())
    elseif line_trimmed =~# '^const\s'
      call add(toplevel.body, self.parseConst())
    elseif line_trimmed =~# '^def\s'
      call add(toplevel.body, self.parseDef())
    elseif line_trimmed =~# '^class\s'
      call add(toplevel.body, self.parseClass())
    elseif line_trimmed =~# '^import\s'
      call add(toplevel.body, self.parseImport())
    elseif line_trimmed =~# '^export\s'
      call add(toplevel.body, self.parseExport())
    else
      " Fallback: treat as excmd
      call add(toplevel.body, self.parseExcmd())
    endif
  endwhile
  
  return toplevel
endfunction

function! s:Vim9Parser.parseVar() abort dict
  let node = {
    \ 'type': s:NODE_VAR,
    \ 'line': self.reader.read(),
    \ }
  return node
endfunction

function! s:Vim9Parser.parseConst() abort dict
  let node = {
    \ 'type': s:NODE_CONST,
    \ 'line': self.reader.read(),
    \ }
  return node
endfunction

function! s:Vim9Parser.parseDef() abort dict
  let body = []
  let startline = self.reader.read()
  
  while !self.reader.iseof()
    let line = self.reader.peek()
    if line =~# '^\s*enddef\s*$'
      call self.reader.read()
      break
    endif
    call add(body, self.reader.read())
  endwhile
  
  let node = {
    \ 'type': s:NODE_DEF,
    \ 'line': startline,
    \ 'body': body,
    \ }
  return node
endfunction

function! s:Vim9Parser.parseClass() abort dict
  let body = []
  let startline = self.reader.read()
  
  while !self.reader.iseof()
    let line = self.reader.peek()
    if line =~# '^\s*endclass\s*$'
      call self.reader.read()
      break
    endif
    call add(body, self.reader.read())
  endwhile
  
  let node = {
    \ 'type': s:NODE_CLASS,
    \ 'line': startline,
    \ 'body': body,
    \ }
  return node
endfunction

function! s:Vim9Parser.parseImport() abort dict
  let node = {
    \ 'type': s:NODE_IMPORT,
    \ 'line': self.reader.read(),
    \ }
  return node
endfunction

function! s:Vim9Parser.parseExport() abort dict
  let node = {
    \ 'type': s:NODE_EXPORT,
    \ 'line': self.reader.read(),
    \ }
  return node
endfunction

function! s:Vim9Parser.parseExcmd() abort dict
  let node = {
    \ 'type': s:NODE_EXCMD,
    \ 'line': self.reader.read(),
    \ }
  return node
endfunction

" Compiler - converts AST to string representation
let s:Compiler = {}

function! s:Compiler.new() abort
  return {}
endfunction

function! s:Compiler.compile(node) abort dict
  return self.compileNode(a:node, 0)
endfunction

function! s:Compiler.compileNode(node, depth) abort dict
  let lines = []
  
  if a:node.type ==# s:NODE_TOPLEVEL
    for child in a:node.body
      call extend(lines, self.compileNode(child, a:depth))
    endfor
  elseif a:node.type ==# s:NODE_VAR
    call add(lines, printf('%s(var %s)', repeat('  ', a:depth), a:node.line))
  elseif a:node.type ==# s:NODE_CONST
    call add(lines, printf('%s(const %s)', repeat('  ', a:depth), a:node.line))
  elseif a:node.type ==# s:NODE_DEF
    call add(lines, printf('%s(def %s)', repeat('  ', a:depth), a:node.line))
    for line in a:node.body
      call add(lines, printf('%s  %s', repeat('  ', a:depth), line))
    endfor
    call add(lines, printf('%s(enddef)', repeat('  ', a:depth)))
  elseif a:node.type ==# s:NODE_CLASS
    call add(lines, printf('%s(class %s)', repeat('  ', a:depth), a:node.line))
    for line in a:node.body
      call add(lines, printf('%s  %s', repeat('  ', a:depth), line))
    endfor
    call add(lines, printf('%s(endclass)', repeat('  ', a:depth)))
  elseif a:node.type ==# s:NODE_IMPORT
    call add(lines, printf('%s(import %s)', repeat('  ', a:depth), a:node.line))
  elseif a:node.type ==# s:NODE_EXPORT
    call add(lines, printf('%s(export %s)', repeat('  ', a:depth), a:node.line))
  else
    call add(lines, printf('%s(%s)', repeat('  ', a:depth), a:node.line))
  endif
  
  return lines
endfunction
