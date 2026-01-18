.PHONY: test
test: test-tokenizer test-parser test-expr test-ast

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

.PHONY: clean
clean:
	rm -rf htmlcov .coverage
