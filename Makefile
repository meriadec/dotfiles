COLORS_PREVIEW_IMAGE=colors.png

install:
	@./scripts/install

colors:
	@./scripts/build-colors

watch-colors:
	@./scripts/watch-colors

preview-colors: colors
	@killall feh 2>/dev/null && echo "> Reloaded preview" || echo "> Launching preview"
	@feh $(COLORS_PREVIEW_IMAGE) &

.PHONY: colors
