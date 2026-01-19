# Comment Handling Issue - Analysis & Test Cases

## Problem Statement

The JavaScript generation (`make`) fails because the parser encounters `#` tokens when parsing inline comments within code. The tokenizer treats `#` as `TOKEN_SHARP` when it should skip the rest of the line.

## Root Cause

**The issue is NOT in StringReader or Vim9 for loops** (as initially suspected).

The real problem occurs when the tokenizer encounters a comment character `#` in the middle of parsing an expression or statement.

### Example from vim9parser.vim line 161:

```vim
var lines: list<string> = lines->map((_, l) => substitute(l, '^[ \t]*$', '', ''))
```

When parsing this line with the next line being a comment:
```vim
    # Only peek within current line, don't cross line boundaries
```

The parser tries to continue parsing the expression but encounters the `#` character, which the tokenizer returns as `TOKEN_SHARP`.

## Current Behavior

```
ERROR: Syntax error at line 161, col 13: Unexpected token in expression: "#" (type 37)
```

The parser's `ParsePrimary()` method doesn't handle `TOKEN_SHARP`, causing an exception.

## Solutions Attempted

1. **Filter comments in StringReader.new()** - FAILED
   - Vim9 for loops seemed to cause hangs with complex logic
   - Actually worked fine; problem was elsewhere

2. **Skip comments in Get() tokenizer method** - FAILED
   - Tried both recursive and loop-based approaches
   - Infinite loops or timeouts occurred

3. **Pre-filter in jscompiler.vim** - FAILED
   - Vim9 for/filter/lambda expressions appeared problematic
   - Actually worked in isolation; problem was with vim9parser.vim itself

4. **Pre-filter in jscompile.sh script** - FAILED
   - Script execution also timed out

## Viable Solution Approach

The proper fix requires one of:

### Option A: Handle TOKEN_SHARP in ParsePrimary()
In ParsePrimary(), when encountering TOKEN_SHARP:
1. Skip to end of current line
2. Call Get() again to get the next real token
3. Continue parsing

Challenge: Requires careful state management in the tokenizer

### Option B: Make Get() skip comments automatically
Modify Get() to loop internally until a non-comment token is found.

Challenge: Must avoid infinite loops and handle edge cases (EOF, EOL)

### Option C: Pre-tokenize and filter
Process the entire input to extract comment positions before tokenizing.

Challenge: Requires coordination between tokenizer and parser

## Test Cases Created

See `test/` directory:

- `test_comment_handling.vim` - Basic comment parsing
- `test_stringreader_filtering.vim` - StringReader filtering
- `test_vim9_filtering_issue.vim` - Vim9 script patterns
- `test_comment_hang_detection.vim` - Size-based hang detection
- `test_full_file_hang.vim` - Full file StringReader test
- `test_parse_full_file.vim` - **REPRODUCTION CASE**

## Key Finding

The Vim9 language constructs (for loops, filter(), map()) are NOT the problem.
The issue is purely in how the tokenizer handles comment characters encountered
during expression parsing.

## Recommendation

Focus on Option A: Making TOKEN_SHARP handling in the parser robust by:
1. Detecting TOKEN_SHARP in ParsePrimary()
2. Safely skipping to next line and getting next token
3. Testing with all comment patterns in the test suite
