
NAME=linux
VERSION=4.14.3
SOURCE_FILE=$(NAME)-$(VERSION).tar.xz
URL=https://cdn.kernel.org/pub/linux/kernel/v4.x/$(SOURCE_FILE)

PACKAGE_SOURCE_DIR=$(BUILD_SOURCE_DIR)/$(NAME)-$(VERSION)

download:
	[ -f $(DLDIR)/$(SOURCE_FILE) ] || wget -O $@ $(URL)

extract: download
	[ -f $(PACKAGE_SOURCE_DIR)/.extracted ] || ( \
		mkdir -p $(PACKAGE_SOURCE_DIR); \
		tar -Jxf $(DLDIR)/$(SOURCE_FILE) -C $(BUILD_SOURCE_DIR) && \
		for f in $$(ls ./patches/*.patch ./patches/*.diff); do patch -d $(PACKAGE_SOURCE_DIR) -p1 < $$f; done; \
		touch $(PACKAGE_SOURCE_DIR)/.extracted \
	)

headers: extract
	mkdir -p $(LINUX_HEADER_DIR)
	$(MAKE) -C $(PACKAGE_SOURCE_DIR) ARCH=$(ARCH) INSTALL_HDR_PATH=$(LINUX_HEADER_DIR) headers_install
	cp -a $(LINUX_HEADER_DIR)/include/* $(BUILD_SYSROOT)/include/
	cp -a $(LINUX_HEADER_DIR)/include/* $(SYSROOT_PREFIX)/include/

