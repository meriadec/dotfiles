COLORS_PREVIEW_IMAGE=colors.png

all: colors install

install:
	@./scripts/install.sh

colors:
	@./scripts/build-colors.sh

watch-colors:
	@./scripts/watch-colors.sh
