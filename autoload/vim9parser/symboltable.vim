vim9script

# Symbol Table for Vim9 Parser
# Tracks functions, variables, classes, and imports for LSP support

export type IFunction = dict<any>
export type IIdentifier = dict<any>
export type IClass = dict<any>
export type IImport = dict<any>

export class Vim9SymbolTable
  var globalFunctions: dict<list<IFunction>> = {}
  var scriptFunctions: dict<list<IFunction>> = {}
  var globalIdentifiers: dict<list<IIdentifier>> = {}
  var localIdentifiers: dict<list<IIdentifier>> = {}
  var classes: dict<list<IClass>> = {}
  var imports: dict<list<IImport>> = {}
  
  def new()
  enddef
  
  # Extract symbols from AST
  def ExtractSymbols(ast: dict<any>): void
    if empty(ast)
      return
    endif
    
    # Process top-level statements
    if has_key(ast, 'body') && type(ast.body) == v:t_list
      for stmt in ast.body
        if type(stmt) == v:t_dict && !empty(stmt)
          this.ProcessStatement(stmt, 0)
        endif
      endfor
    endif
  enddef
  
  def ProcessStatement(stmt: dict<any>, depth: number): void
    if !has_key(stmt, 'type')
      return
    endif
    
    var node_type = stmt.type
    
    # NODE_VAR = 201
    if node_type == 201
      this.ProcessVar(stmt, depth)
    # NODE_CONST = 202
    elseif node_type == 202
      this.ProcessConst(stmt, depth)
    # NODE_DEF = 203
    elseif node_type == 203
      this.ProcessDef(stmt, depth)
    # NODE_CLASS = 205
    elseif node_type == 205
      this.ProcessClass(stmt, depth)
    # NODE_IMPORT = 209
    elseif node_type == 209
      this.ProcessImport(stmt, depth)
    # NODE_EXPORT = 210
    elseif node_type == 210
      this.ProcessExport(stmt, depth)
    endif
  enddef
  
  def ProcessVar(stmt: dict<any>, depth: number): void
    if !has_key(stmt, 'name') || empty(stmt.name)
      return
    endif
    
    var identifier: IIdentifier = {
      name: stmt.name,
      startLine: get(stmt, 'line', 0) + 1,
      startCol: get(stmt, 'col', 0) + 1,
      type: 'var',
      rtype: get(stmt, 'rtype', ''),
    }
    
    var key = stmt.name
    
    # Determine scope
    if depth == 0
      # Script-level variable
      if !has_key(this.globalIdentifiers, key)
        this.globalIdentifiers[key] = []
      endif
      this.globalIdentifiers[key]->add(identifier)
    else
      # Local variable in function/class
      if !has_key(this.localIdentifiers, key)
        this.localIdentifiers[key] = []
      endif
      this.localIdentifiers[key]->add(identifier)
    endif
  enddef
  
  def ProcessConst(stmt: dict<any>, depth: number): void
    if !has_key(stmt, 'name') || empty(stmt.name)
      return
    endif
    
    var identifier: IIdentifier = {
      name: stmt.name,
      startLine: get(stmt, 'line', 0) + 1,
      startCol: get(stmt, 'col', 0) + 1,
      type: 'const',
      rtype: get(stmt, 'rtype', ''),
    }
    
    var key = stmt.name
    
    if depth == 0
      if !has_key(this.globalIdentifiers, key)
        this.globalIdentifiers[key] = []
      endif
      this.globalIdentifiers[key]->add(identifier)
    else
      if !has_key(this.localIdentifiers, key)
        this.localIdentifiers[key] = []
      endif
      this.localIdentifiers[key]->add(identifier)
    endif
  enddef
  
  def ProcessDef(stmt: dict<any>, depth: number): void
    if !has_key(stmt, 'name') || empty(stmt.name)
      return
    endif
    
    var func: IFunction = {
      name: stmt.name,
      args: get(stmt, 'params', []),
      startLine: get(stmt, 'line', 0) + 1,
      startCol: get(stmt, 'col', 0) + 1,
      endLine: get(stmt, 'line', 0) + 1,  # TODO: Calculate proper end line
      endCol: get(stmt, 'col', 0) + 1,
      range: {
        startLine: get(stmt, 'line', 0) + 1,
        startCol: get(stmt, 'col', 0) + 1,
        endLine: get(stmt, 'line', 0) + 1,
        endCol: get(stmt, 'col', 0) + 1,
      },
      rtype: get(stmt, 'rtype', ''),
    }
    
    var key = stmt.name
    
    if depth == 0
      # Script-level function
      if !has_key(this.scriptFunctions, key)
        this.scriptFunctions[key] = []
      endif
      this.scriptFunctions[key]->add(func)
    else
      # Nested function (not typical in vim9script)
      if !has_key(this.globalFunctions, key)
        this.globalFunctions[key] = []
      endif
      this.globalFunctions[key]->add(func)
    endif
    
    # Process function body
    if has_key(stmt, 'body') && type(stmt.body) == v:t_list
      for body_stmt in stmt.body
        if type(body_stmt) == v:t_dict && !empty(body_stmt)
          this.ProcessStatement(body_stmt, depth + 1)
        endif
      endfor
    endif
  enddef
  
  def ProcessClass(stmt: dict<any>, depth: number): void
    if !has_key(stmt, 'name') || empty(stmt.name)
      return
    endif
    
    var cls: IClass = {
      name: stmt.name,
      startLine: get(stmt, 'line', 0) + 1,
      startCol: get(stmt, 'col', 0) + 1,
      endLine: get(stmt, 'line', 0) + 1,
      endCol: get(stmt, 'col', 0) + 1,
    }
    
    var key = stmt.name
    
    if !has_key(this.classes, key)
      this.classes[key] = []
    endif
    this.classes[key]->add(cls)
    
    # Process class members and methods
    if has_key(stmt, 'body') && type(stmt.body) == v:t_list
      for body_stmt in stmt.body
        if type(body_stmt) == v:t_dict && !empty(body_stmt)
          this.ProcessStatement(body_stmt, depth + 1)
        endif
      endfor
    endif
  enddef
  
  def ProcessImport(stmt: dict<any>, depth: number): void
    if !has_key(stmt, 'name') || empty(stmt.name)
      return
    endif
    
    var imp: IImport = {
      path: stmt.name,
      alias: get(stmt, 'alias', ''),
      startLine: get(stmt, 'line', 0) + 1,
      startCol: get(stmt, 'col', 0) + 1,
    }
    
    var key = get(stmt, 'alias', stmt.name)
    
    if !has_key(this.imports, key)
      this.imports[key] = []
    endif
    this.imports[key]->add(imp)
  enddef
  
  def ProcessExport(stmt: dict<any>, depth: number): void
    if !has_key(stmt, 'export') || !stmt.export
      return
    endif
    
    # Mark the statement as exported, then process it
    var wrapped = deepcopy(stmt)
    wrapped.export = true
    this.ProcessStatement(wrapped, depth)
  enddef
  
  # LSP-compatible interface methods
  
  def GetGlobalFunctions(): dict<list<IFunction>>
    return this.globalFunctions
  enddef
  
  def GetScriptFunctions(): dict<list<IFunction>>
    return this.scriptFunctions
  enddef
  
  def GetGlobalIdentifiers(): dict<list<IIdentifier>>
    return this.globalIdentifiers
  enddef
  
  def GetLocalIdentifiers(): dict<list<IIdentifier>>
    return this.localIdentifiers
  enddef
  
  def GetClasses(): dict<list<IClass>>
    return this.classes
  enddef
  
  def GetImports(): dict<list<IImport>>
    return this.imports
  enddef
  
  # Get completion candidates for a given line
  def GetFunctionLocalIdentifierItems(line: number): list<dict<any>>
    var items: list<dict<any>> = []
    
    # Collect all local identifiers accessible at this line
    for [key, identifiers] in items(this.localIdentifiers)
      for ident in identifiers
        if ident.startLine <= line
          items->add({
            label: key,
            kind: 'Variable',
            detail: get(ident, 'type', 'var'),
          })
        endif
      endfor
    endfor
    
    # Also include function parameters (would need context)
    return items
  enddef
  
  # Find symbol at position
  def FindSymbolAtPosition(line: number, col: number): dict<any>
    var result: dict<any> = {}
    
    # Search in local identifiers
    for [key, identifiers] in items(this.localIdentifiers)
      for ident in identifiers
        if ident.startLine == line && ident.startCol <= col && col < ident.startCol + len(key)
          return {
            type: 'identifier',
            name: key,
            info: ident,
          }
        endif
      endfor
    endfor
    
    # Search in global identifiers
    for [key, identifiers] in items(this.globalIdentifiers)
      for ident in identifiers
        if ident.startLine == line && ident.startCol <= col && col < ident.startCol + len(key)
          return {
            type: 'identifier',
            name: key,
            info: ident,
          }
        endif
      endfor
    endfor
    
    # Search in functions
    for [key, functions] in items(this.scriptFunctions)
      for func in functions
        if func.startLine == line && func.startCol <= col && col < func.startCol + len(key)
          return {
            type: 'function',
            name: key,
            info: func,
          }
        endif
      endfor
    endfor
    
    return result
  enddef
endclass
