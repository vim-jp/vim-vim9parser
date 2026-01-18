.PHONY: test
test:
	vim -u NONE -N -S test/test.vim -c qa!

.PHONY: clean
clean:
	rm -rf htmlcov .coverage
