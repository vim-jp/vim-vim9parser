# vim-language-server Symbol Table Analysis

## vim-language-server が期待するシンボルテーブル形式

### IFunction インターフェース
```typescript
export interface IFunction {
  name: string;                    // 関数名
  args: INode[];                   // 引数の AST ノード配列
  startLine: number;               // 関数開始行番号（1-indexed）
  startCol: number;                // 関数開始カラム（1-indexed）
  endLine: number;                 // 関数終了行番号（1-indexed）
  endCol: number;                  // 関数終了カラム（1-indexed）
  range: {                          // 関数の完全な範囲
    startLine: number;
    startCol: number;
    endLine: number;
    endCol: number;
  }
}
```

### IIdentifier インターフェース
```typescript
export interface IIdentifier {
  name: string;                    // 変数名
  startLine: number;               // 定義行番号（1-indexed）
  startCol: number;                // 定義カラム（1-indexed）
}
```

### Buffer クラスの構造
```typescript
export class Buffer {
  // グローバル関数 (例: g:FuncName, FuncName, module#func)
  private globalFunctions: Record<string, IFunction[]>;
  
  // スクリプトローカル関数 (例: s:func_name)
  private scriptFunctions: Record<string, IFunction[]>;
  
  // グローバル変数 (例: g:var, b:var, var_name)
  private globalVariables: Record<string, IIdentifier[]>;
  
  // スクリプトローカル変数 (例: s:var, l:var, a:var)
  private localVariables: Record<string, IIdentifier[]>;
  
  // 環境変数 (例: $HOME)
  private envs: Record<string, IIdentifier[]>;
  
  // 関数参照 (例: let func = function('FuncName'))
  private globalFunctionRefs: Record<string, IFunRef[]>;
  private scriptFunctionRefs: Record<string, IFunRef[]>;
  
  // 変数参照（使用箇所の追跡）
  private globalVariableRefs: Record<string, IIdentifier[]>;
  private localVariableRefs: Record<string, IIdentifier[]>;
}
```

## 変数スコープの分類

| スコープ記号 | 説明 | 例 |
|------------|------|-----|
| `g:` | グローバル変数 | `g:global_var` |
| `s:` | スクリプトローカル変数 | `s:local_var` |
| `l:` | 関数ローカル変数 | `l:func_local` |
| `a:` | 関数の引数 | `a:param` |
| `b:` | バッファローカル変数 | `b:bufvar` |
| (none) | デフォルト（グローバル扱い）| `plain_var` |
| `$` | 環境変数 | `$HOME` |

## 関数スコープの分類

| パターン | スコープ | 例 |
|---------|--------|-----|
| `g:FuncName` または `FuncName` | グローバル | `g:MyFunc`, `MyFunc` |
| `s:func_name` | スクリプトローカル | `s:my_func` |
| `ModuleName#FuncName` | 自動ロード関数 | `module#func` |

## 補完フロー

### 1. Symbol Resolution
```
cursor position (line, col)
    ↓
Buffer.getFunctionLocalIdentifierItems(line)
    ↓
関数范囲内の行？
    ├─ YES: 関数の引数 + ローカル変数
    └─ NO: グローバル変数/関数
```

### 2. Completion Items 生成
```
IFunction/IIdentifier
    ↓
CompletionItem {
  label: string;              // 表示名
  kind: CompletionItemKind;   // Function or Variable
  sortText: string;           // ソート優先度
  insertText: string;         // 挿入テキスト
  insertTextFormat?: number;
}
```

## vim-vim9parser で実装が必要な形式

### 要件 1: INode の互換性
vim-vimlparser の INode 構造と互換性のある AST が必要

```typescript
export interface INode {
  type: number;
  pos: IPos;
  body: INode[];
  // ... その他のプロパティ
}

export interface IPos {
  lnum: number;   // 1-indexed line number
  col: number;    // 1-indexed column number
  offset: number; // offset from start
}
```

### 要件 2: Symbol Extraction インターフェース
```typescript
export class Vim9Buffer {
  // vim-vimlparser の Buffer と同じメソッドシグネチャ
  
  // 関数取得
  getGlobalFunctions(): Record<string, IFunction[]>;
  getScriptFunctions(): Record<string, IFunction[]>;
  
  // 変数取得
  getGlobalIdentifiers(): Record<string, IIdentifier[]>;
  getLocalIdentifiers(): Record<string, IIdentifier[]>;
  
  // 補完アイテム生成
  getGlobalFunctionItems(): CompletionItem[];
  getScriptFunctionItems(): CompletionItem[];
  getGlobalIdentifierItems(): CompletionItem[];
  getLocalIdentifierItems(): CompletionItem[];
  getFunctionLocalIdentifierItems(line: number): CompletionItem[];
}
```

### 要件 3: vim9script の拡張
vim9script 固有の構文に対応する必要がある：

| Vim9 構文 | vim9Buffer の処理 |
|----------|------------------|
| `var name: type = value` | グローバル/ローカル変数として抽出 |
| `const name: type = value` | グローバル/ローカル変数として抽出 |
| `def FuncName(param: type): type` | 関数定義として抽出、型情報を保持 |
| `class ClassName` | クラス定義として抽出（新規） |
| `import Script as alias` | インポート追跡（新規） |
| `export def/var` | エクスポート定義追跡（新規） |

## 実装ロードマップ

### Phase 1: Symbol Table 基盤
1. **IFunction/IIdentifier の実装**
   - vim9parser の AST から抽出可能な形式に統一
   - Line/col は 1-indexed を使用

2. **Symbol Extraction Engine**
   - ParseStatement で関数/変数定義を検出
   - スコープ情報を付加（s:, l:, a:, g: プレフィックス）
   - 変数参照も追跡

3. **Scope Analysis**
   - 関数スコープの検出
   - ローカル変数の スコープ分析
   - 引数バインディング

### Phase 2: Vim9Buffer クラス
vim-vimlparser の Buffer と同じインターフェースを持つ Vim9Buffer を実装

```vim
export class Vim9Buffer
  def getGlobalFunctions(): dict<list<dict>>
  def getScriptFunctions(): dict<list<dict>>
  def getGlobalIdentifiers(): dict<list<dict>>
  def getLocalIdentifiers(): dict<list<dict>>
  # ... その他メソッド
endclass
```

### Phase 3: vim-language-server 統合
vim-language-server が両方の Buffer クラスを同じ方法で扱えるようにする

```typescript
// dispatcher で言語判定
if (isVim9Script) {
  buffer = new Vim9Buffer(ast);
} else {
  buffer = new Buffer(ast);
}

// 同じインターフェースで処理
const functions = buffer.getGlobalFunctions();
const completions = buffer.getGlobalFunctionItems();
```

## vim-vimlparser との互換性

vim-vimlparser のコードパターンで参考になるもの：

1. **IPos の定義**（vim-vim9parser の StringReader のポジション記録）
2. **Pattern matching**（グローバル/スクリプト/引数の判定ロジック）
3. **Buffer の structuring**（変数/関数を name でグループ化）

## 次のステップ

1. ✅ vim-language-server の要求形式を理解
2. 🚀 IFunction/IIdentifier を vim9parser に対応させる
3. 🚀 Symbol Extraction Engine を実装
4. 🚀 Vim9Buffer クラスを実装
5. 🚀 vim-language-server でのテスト統合
