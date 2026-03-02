build:
	@swift package archive --allow-network-connections docker --disable-sandbox
#	@swift package --disable-sandbox --allow-network-connections docker archive --container-cli container

.PHONY: build
