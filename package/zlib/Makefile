
NAME=zlib
VERSION=1.2.11
SOURCE_FILE=$(NAME)-$(VERSION).tar.gz
URL=https://zlib.net/$(SOURCE_FILE)

PACKAGE_BUILD_DIR=$(BUILD_DIR)/$(NAME)-$(VERSION)

ifneq ($(filter-out none,$(LIBC)),)
all: install
	true
else
all:
	true
endif

download:
	[ -f $(DLDIR)/$(SOURCE_FILE) ] || wget -O $(DLDIR)/$(SOURCE_FILE) $(URL) || (rm -f $(DLDIR)/$(SOURCE_FILE) && false)

extract: download
	[ -f $(PACKAGE_BUILD_DIR)/.extracted ] || ( \
		mkdir -p $(PACKAGE_BUILD_DIR); \
		tar -zxf $(DLDIR)/$(SOURCE_FILE) -C $(BUILD_DIR) && \
		for f in $$(ls ./patches/*.patch ./patches/*.diff); do patch -d $(PACKAGE_BUILD_DIR) -p1 < $$f; done; \
		touch $(PACKAGE_BUILD_DIR)/.extracted \
	)

configure: extract
	[ -f $(PACKAGE_BUILD_DIR)/.configured ] || ( \
		cd $(PACKAGE_BUILD_DIR); \
		CC='$(TOOLCHAIN_PREFIX)gcc' CFLAGS="$(TARGET_CFLAGS)" ./configure && \
		touch $(PACKAGE_BUILD_DIR)/.configured \
	)

build: configure
	[ -f $(PACKAGE_BUILD_DIR)/.built ] || ( \
		$(MAKE) -C $(PACKAGE_BUILD_DIR) && \
		touch $(PACKAGE_BUILD_DIR)/.built \
	)

install: build
	cp $(PACKAGE_BUILD_DIR)/libz.a $(SYSROOT_PREFIX)/lib
	cp $(PACKAGE_BUILD_DIR)/libz.so $(SYSROOT_PREFIX)/lib
	cp $(PACKAGE_BUILD_DIR)/libz.so.1 $(SYSROOT_PREFIX)/lib
	cp $(PACKAGE_BUILD_DIR)/libz.so.$(VERSION) $(SYSROOT_PREFIX)/lib
	cp $(PACKAGE_BUILD_DIR)/zconf.h $(SYSROOT_PREFIX)/include
	cp $(PACKAGE_BUILD_DIR)/zlib.h $(SYSROOT_PREFIX)/include

