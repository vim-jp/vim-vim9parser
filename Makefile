.PHONY: test
test: test-tokenizer test-parser

.PHONY: test-tokenizer
test-tokenizer:
	vim -u NONE -N -S test/test_tokenizer.vim -c qa!

.PHONY: test-parser
test-parser:
	vim -u NONE -N -S test/test.vim -c qa!

.PHONY: clean
clean:
	rm -rf htmlcov .coverage
