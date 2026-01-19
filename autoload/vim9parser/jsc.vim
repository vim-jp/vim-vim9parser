vim9script

# JavaScript Compiler for Vim9 Parser
# Compiles AST to JavaScript code

const NODE_TOPLEVEL = 1
const NODE_TYPE = 213
const NODE_VAR = 201
const NODE_CONST = 202
const NODE_DEF = 203
const NODE_CLASS = 205
const NODE_IF = 13
const NODE_WHILE = 17
const NODE_FOR = 19
const NODE_TRY = 23
const NODE_THROW = 27
const NODE_RETURN = 7
const NODE_ECHO = 28
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
const NODE_EQUAL = 37
const NODE_NEQUAL = 40
const NODE_GREATER = 43
const NODE_GEQUAL = 46
const NODE_SMALLER = 49
const NODE_SEQUAL = 52
const NODE_AND = 36
const NODE_OR = 35
const NODE_TERNARY = 34
const NODE_LET = 9

export class JSCompiler
  var indent: number = 0
  var lines: list<string> = []
  
  def new()
  enddef
  
  def Compile(node: dict<any>): list<string>
    this.lines = []
    this.indent = 0
    this.CompileNode(node)
    return this.lines
  enddef
  
  def Out(text: string): void
    this.lines->add(repeat('  ', this.indent) .. text)
  enddef
  
  def IncIndent(): void
    this.indent += 1
  enddef
  
  def DecIndent(): void
    if this.indent > 0
      this.indent -= 1
    endif
  enddef
  
  def CompileNode(node: dict<any>): string
    if node.type == NODE_TOPLEVEL
      return this.CompileToplevel(node)
    elseif node.type == NODE_TYPE
      return this.CompileType(node)
    elseif node.type == NODE_VAR
      return this.CompileVar(node)
    elseif node.type == NODE_CONST
      return this.CompileConst(node)
    elseif node.type == NODE_DEF
      return this.CompileDef(node)
    elseif node.type == NODE_CLASS
      return this.CompileClass(node)
    elseif node.type == NODE_IF
      return this.CompileIf(node)
    elseif node.type == NODE_WHILE
      return this.CompileWhile(node)
    elseif node.type == NODE_FOR
      return this.CompileFor(node)
    elseif node.type == NODE_TRY
      return this.CompileTry(node)
    elseif node.type == NODE_THROW
      return this.CompileThrow(node)
    elseif node.type == NODE_RETURN
      return this.CompileReturn(node)
    elseif node.type == NODE_ECHO
      return this.CompileEcho(node)
    elseif node.type == NODE_LET
      return this.CompileLet(node)
    elseif node.type >= 300
      # Expression nodes
      return this.CompileExpr(node)
    else
      return ''
    endif
  enddef
  
  def CompileType(node: dict<any>): string
    # JavaScript doesn't have type aliases, so we skip them
    this.Out($'// type alias: {node.name}')
    return ''
  enddef
  
  def CompileToplevel(node: dict<any>): string
    for stmt in node.body
      if type(stmt) == v:t_dict && !empty(stmt)
        this.CompileNode(stmt)
      endif
    endfor
    return ''
  enddef
  
  def CompileVar(node: dict<any>): string
    var type_str = empty(node.rtype) ? '' : $': {node.rtype}'
    var init = ''
    if len(node.body) > 0
      var expr_result = this.CompileExpr(node.body[0])
      if !empty(expr_result)
        init = $' = {expr_result}'
      endif
    endif
    this.Out($'let {node.name}{type_str}{init};')
    return ''
  enddef
  
  def CompileConst(node: dict<any>): string
    var type_str = empty(node.rtype) ? '' : $': {node.rtype}'
    var init = ''
    if len(node.body) > 0
      var expr_result = this.CompileExpr(node.body[0])
      if !empty(expr_result)
        init = $' = {expr_result}'
      endif
    endif
    this.Out($'const {node.name}{type_str}{init};')
    return ''
  enddef
  
  def CompileDef(node: dict<any>): string
    var params_list: list<string> = []
    for p in node.params
      params_list->add(p.name)
    endfor
    var params_str = join(params_list, ', ')
    
    this.Out($'function {node.name}({params_str}) {{')
    this.IncIndent()
    
    for stmt in node.body
      if type(stmt) == v:t_dict && !empty(stmt)
        this.CompileNode(stmt)
      endif
    endfor
    
    this.DecIndent()
    this.Out('}')
    return ''
  enddef
  
  def CompileClass(node: dict<any>): string
    this.Out($'class {node.name} {{')
    this.IncIndent()
    
    for stmt in node.body
      if type(stmt) == v:t_dict && !empty(stmt)
        this.CompileNode(stmt)
      endif
    endfor
    
    this.DecIndent()
    this.Out('}')
    return ''
  enddef
  
  def CompileIf(node: dict<any>): string
    if len(node.body) > 0
      var cond = this.CompileExpr(node.body[0])
      this.Out($'if ({cond}) {{')
      this.IncIndent()
      
      if len(node.body) > 1
        for stmt in node.body[1]
          if type(stmt) == v:t_dict && !empty(stmt)
            this.CompileNode(stmt)
          endif
        endfor
      endif
      
      this.DecIndent()
      this.Out('}')
    endif
    return ''
  enddef
  
  def CompileWhile(node: dict<any>): string
    if len(node.body) > 0
      var cond = this.CompileExpr(node.body[0])
      this.Out($'while ({cond}) {{')
      this.IncIndent()
      
      if len(node.body) > 1
        for stmt in node.body[1]
          if type(stmt) == v:t_dict && !empty(stmt)
            this.CompileNode(stmt)
          endif
        endfor
      endif
      
      this.DecIndent()
      this.Out('}')
    endif
    return ''
  enddef
  
  def CompileFor(node: dict<any>): string
    if len(node.body) > 0
      var iterable = this.CompileExpr(node.body[0])
      this.Out($'for (let {node.name} of {iterable}) {{')
      this.IncIndent()
      
      if len(node.body) > 1
        for stmt in node.body[1]
          if type(stmt) == v:t_dict && !empty(stmt)
            this.CompileNode(stmt)
          endif
        endfor
      endif
      
      this.DecIndent()
      this.Out('}')
    endif
    return ''
  enddef
  
  def CompileTry(node: dict<any>): string
    this.Out('try {')
    this.IncIndent()
    
    for stmt in node.body
      if type(stmt) == v:t_dict && !empty(stmt)
        this.CompileNode(stmt)
      endif
    endfor
    
    this.DecIndent()
    this.Out('}')
    return ''
  enddef
  
  def CompileThrow(node: dict<any>): string
    if len(node.body) > 0
      var expr = this.CompileExpr(node.body[0])
      this.Out($'throw {expr};')
    endif
    return ''
  enddef
  
  def CompileReturn(node: dict<any>): string
    if len(node.body) > 0
      var expr = this.CompileExpr(node.body[0])
      this.Out($'return {expr};')
    else
      this.Out('return;')
    endif
    return ''
  enddef
  
  def CompileEcho(node: dict<any>): string
    var args: list<string> = []
    for arg in node.body
      if type(arg) == v:t_dict && !empty(arg)
        args->add(this.CompileExpr(arg))
      endif
    endfor
    this.Out($'console.log({join(args, ", ")});')
    return ''
  enddef
  
  def CompileLet(node: dict<any>): string
    if node.left != null && node.right != null
      var left = this.CompileExpr(node.left)
      var right = this.CompileExpr(node.right)
      this.Out($'{left} = {right};')
    endif
    return ''
  enddef
  
  def CompileExpr(node: dict<any>): string
    if node.type == NODE_NUMBER
      return node.value
    elseif node.type == NODE_STRING
      return $'"{node.value}"'
    elseif node.type == NODE_IDENTIFIER
      return node.name
    elseif node.type == NODE_TRUE
      return 'true'
    elseif node.type == NODE_FALSE
      return 'false'
    elseif node.type == NODE_NULL
      return 'null'
    elseif node.type == NODE_LIST
      if has_key(node, 'is_comprehension') && node.is_comprehension
        # List comprehension: [for i in iterable: expr]
        var iterable = this.CompileExpr(node.iterable)
        var expr = this.CompileExpr(node.expr)
        if node.filter != null
          var filter = this.CompileExpr(node.filter)
          return $'[..{iterable}].filter(({node.loop_var}) => {filter}).map(({node.loop_var}) => {expr})'
        else
          return $'[..{iterable}].map(({node.loop_var}) => {expr})'
        endif
      else
        # Regular list literal
        var elements: list<string> = []
        for elem in node.body
          elements->add(this.CompileExpr(elem))
        endfor
        return $'[{join(elements, ", ")}]'
      endif
    elseif node.type == NODE_DICT
      var pairs: list<string> = []
      for pair in node.body
        pairs->add($'{pair.key}: {this.CompileExpr(pair.value)}')
      endfor
      return $'{{ {join(pairs, ", ")} }}'
    elseif node.type == NODE_ADD
      return $'({this.CompileExpr(node.left)} + {this.CompileExpr(node.right)})'
    elseif node.type == NODE_SUBTRACT
      return $'({this.CompileExpr(node.left)} - {this.CompileExpr(node.right)})'
    elseif node.type == NODE_MULTIPLY
      return $'({this.CompileExpr(node.left)} * {this.CompileExpr(node.right)})'
    elseif node.type == NODE_DIVIDE
      return $'({this.CompileExpr(node.left)} / {this.CompileExpr(node.right)})'
    elseif node.type == NODE_MODULO
      return $'({this.CompileExpr(node.left)} % {this.CompileExpr(node.right)})'
    elseif node.type == NODE_EQUAL
      return $'({this.CompileExpr(node.left)} === {this.CompileExpr(node.right)})'
    elseif node.type == NODE_NEQUAL
      return $'({this.CompileExpr(node.left)} !== {this.CompileExpr(node.right)})'
    elseif node.type == NODE_GREATER
      return $'({this.CompileExpr(node.left)} > {this.CompileExpr(node.right)})'
    elseif node.type == NODE_GEQUAL
      return $'({this.CompileExpr(node.left)} >= {this.CompileExpr(node.right)})'
    elseif node.type == NODE_SMALLER
      return $'({this.CompileExpr(node.left)} < {this.CompileExpr(node.right)})'
    elseif node.type == NODE_SEQUAL
      return $'({this.CompileExpr(node.left)} <= {this.CompileExpr(node.right)})'
    elseif node.type == NODE_AND
      return $'({this.CompileExpr(node.left)} && {this.CompileExpr(node.right)})'
    elseif node.type == NODE_OR
      return $'({this.CompileExpr(node.left)} || {this.CompileExpr(node.right)})'
    elseif node.type == NODE_NOT
      return $'(!{this.CompileExpr(node.left)})'
    elseif node.type == NODE_BIT_OR
      return $'({this.CompileExpr(node.left)} | {this.CompileExpr(node.right)})'
    elseif node.type == NODE_BIT_XOR
      return $'({this.CompileExpr(node.left)} ^ {this.CompileExpr(node.right)})'
    elseif node.type == NODE_BIT_AND
      return $'({this.CompileExpr(node.left)} & {this.CompileExpr(node.right)})'
    elseif node.type == NODE_LSHIFT
      return $'({this.CompileExpr(node.left)} << {this.CompileExpr(node.right)})'
    elseif node.type == NODE_RSHIFT
      return $'({this.CompileExpr(node.left)} >> {this.CompileExpr(node.right)})'
    elseif node.type == NODE_DOT
      return $'{this.CompileExpr(node.left)}.{node.name}'
    elseif node.type == NODE_SUBSCRIPT
      return $'{this.CompileExpr(node.left)}[{this.CompileExpr(node.right)}]'
    elseif node.type == NODE_CALL
      var args: list<string> = []
      for arg in node.body
        args->add(this.CompileExpr(arg))
      endfor
      return $'{this.CompileExpr(node.left)}({join(args, ", ")})'
    elseif node.type == NODE_LAMBDA
      var params_str = join(node.params, ', ')
      var body = this.CompileExpr(node.body[0])
      return $'(({params_str}) => {body})'
    elseif node.type == NODE_TERNARY
      if len(node.body) >= 3
        var cond = this.CompileExpr(node.body[0])
        var true_expr = this.CompileExpr(node.body[1])
        var false_expr = this.CompileExpr(node.body[2])
        return $'({cond} ? {true_expr} : {false_expr})'
      endif
    endif
    return ''
  enddef
endclass
