# 1 - Create needed folders
# 2 - Install zsh-syntax-highlighting
# 3 - Create or update all symlinks
install: build
	@./scripts/install.sh

# Parse the theme.sh variables and replace them in *.template files
build: colors compile

compile:
	@./scripts/compile.sh

# Rebuild on every scripts/compile.sh change
watch-compile:
	@./scripts/watch-compile.sh

# Create color pallet preview in colors.png
colors:
	@./scripts/build-colors.sh

# Open color pallet preview, hot reload it on every change
watch-colors:
	@./scripts/watch-colors.sh
