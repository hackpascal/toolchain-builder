
NAME=zlib
VERSION=1.2.11
SOURCE_FILE=$(NAME)-$(VERSION).tar.gz
URL=https://zlib.net/$(SOURCE_FILE)

PACKAGE_SOURCE_DIR=$(HOST_SOURCE_DIR)/$(NAME)-$(VERSION)
PACKAGE_BUILD_DIR=$(HOST_BUILD_DIR)/$(NAME)-$(VERSION)

CONFIGURE_ARGS = \
	--static

all: install
	true

download:
	[ -f $(DLDIR)/$(SOURCE_FILE) ] || wget -O $(DLDIR)/$(SOURCE_FILE) $(URL) || (rm -f $(DLDIR)/$(SOURCE_FILE) && false)

extract: download
	[ -f $(PACKAGE_SOURCE_DIR)/.extracted ] || ( \
		mkdir -p $(PACKAGE_SOURCE_DIR); \
		tar -xf $(DLDIR)/$(SOURCE_FILE) -C $(HOST_SOURCE_DIR) && \
		for f in $$(ls ./patches/*.patch ./patches/*.diff); do patch -d $(PACKAGE_SOURCE_DIR) -p1 < $$f; done && \
		touch $(PACKAGE_SOURCE_DIR)/.extracted \
	)

ifeq ($(BUILD_TYPE),target)
configure: extract
	[ -f $(PACKAGE_BUILD_DIR)/.configured ] || ( \
		mkdir -p $(PACKAGE_BUILD_DIR) && \
		cp -a $(PACKAGE_SOURCE_DIR)/* $(PACKAGE_BUILD_DIR)/ && \
		touch $(PACKAGE_BUILD_DIR)/.configured \
	)

build: configure
	[ -f $(PACKAGE_BUILD_DIR)/.built ] || ( \
		$(CONFIGURE_ENVS) \
			$(MAKE) PREFIX=$(HOST)- LOC="$(TARGET_CFLAGS) $(TARGET_LDFLAGS)" \
				-C $(PACKAGE_BUILD_DIR) -f win32/Makefile.gcc libz.a && \
		touch $(PACKAGE_BUILD_DIR)/.built \
	)
else
configure: extract
	[ -f $(PACKAGE_BUILD_DIR)/.configured ] || ( \
		mkdir -p $(PACKAGE_BUILD_DIR); \
		cd $(PACKAGE_BUILD_DIR); \
		ln -sf $(PACKAGE_SOURCE_DIR); \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		$(CONFIGURE_ENVS) \
			$(PACKAGE_SOURCE_DIR:$(BUILD_SOURCE_DIR)/%=%)/configure $(CONFIGURE_ARGS) && \
		touch $(PACKAGE_BUILD_DIR)/.configured \
	)

build: configure
	[ -f $(PACKAGE_BUILD_DIR)/.built ] || ( \
		$(MAKE) -C $(PACKAGE_BUILD_DIR) && \
		touch $(PACKAGE_BUILD_DIR)/.built \
	)
endif

install: build
	[ -f $(PACKAGE_BUILD_DIR)/.installed ] || ( \
		mkdir -p $(HOST_OUTPUT_PREFIX)/lib $(HOST_OUTPUT_PREFIX)/include && \
		cp $(PACKAGE_BUILD_DIR)/libz.a $(HOST_OUTPUT_PREFIX)/lib && \
		cp $(PACKAGE_BUILD_DIR)/zconf.h $(HOST_OUTPUT_PREFIX)/include && \
		cp $(PACKAGE_SOURCE_DIR)/zlib.h $(HOST_OUTPUT_PREFIX)/include && \
		touch $(PACKAGE_BUILD_DIR)/.installed \
	)

