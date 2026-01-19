.PHONY: all
all: js/vim9parser.js

.PHONY: js
js: js/vim9parser.js

js/vim9parser.js: autoload/vim9parser.vim js/jscompiler.vim
	scripts/jscompile.sh $< $@

.PHONY: test
test: test-tokenizer test-parser test-expr test-ast test-line-continuation test-compound test-string-interp test-error-recovery test-destructuring test-list-comp test-js

.PHONY: test-tokenizer
test-tokenizer:
	vim -u NONE -N -S test/test_tokenizer.vim -c qa!

.PHONY: test-parser
test-parser:
	vim -u NONE -N -S test/test_parser.vim -c qa!

.PHONY: test-expr
test-expr:
	vim -u NONE -N -S test/test_expr.vim -c qa!

.PHONY: test-ast
test-ast:
	vim -u NONE -N -S test/test.vim -c qa!

.PHONY: test-line-continuation
test-line-continuation:
	vim -u NONE -N -S test/test_line_continuation.vim -c qa!

.PHONY: test-compound
test-compound:
	vim -u NONE -N -S test/test_compound_assign.vim -c qa!

.PHONY: test-string-interp
test-string-interp:
	vim -u NONE -N -S test/test_string_interpolation.vim -c qa!

.PHONY: test-error-recovery
test-error-recovery:
	vim -u NONE -N -S test/test_error_recovery.vim -c qa!

.PHONY: test-destructuring
test-destructuring:
	vim -u NONE -N -S test/test_destructuring.vim -c qa!

.PHONY: test-list-comp
test-list-comp:
	vim -u NONE -N -S test/test_list_comprehension.vim -c qa!

.PHONY: test-js
test-js:
	vim -u NONE -N -S test/test_js_compiler.vim -c qa!

.PHONY: clean
clean:
	rm -rf htmlcov .coverage js/vim9parser.js
