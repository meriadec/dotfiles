install:
	@./scripts/install.sh

test:
	@python3 -m unittest discover -s tests -v
