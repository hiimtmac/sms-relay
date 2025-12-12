build:
	@swift package archive --allow-network-connections docker --disable-sandbox

.PHONY: build
