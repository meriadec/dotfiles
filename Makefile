.PHONY: install test

install:
	@./install

test:
	@python3 -m unittest discover -s tests -v
