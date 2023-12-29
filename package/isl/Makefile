
NAME=isl
VERSION=0.26
SOURCE_FILE=$(NAME)-$(VERSION).tar.xz
URL=https://libisl.sourceforge.io/$(SOURCE_FILE)

PACKAGE_SOURCE_DIR=$(SOURCEDIR)/$(NAME)-$(VERSION)
PACKAGE_BUILD_DIR=$(HOST_BUILD_DIR)/$(NAME)-$(VERSION)

CONFIGURE_ARGS= \
	--prefix=$(HOST_OUTPUT_PREFIX) \
	$(if $(HOST),--host=$(HOST)) \
	--disable-shared \
	--enable-static \
	--with-gmp-prefix=$(HOST_OUTPUT_PREFIX)

all: install
	true

download:
	[ -f $(DLDIR)/$(SOURCE_FILE) ] || wget -O $(DLDIR)/$(SOURCE_FILE) $(URL) || (rm -f $(DLDIR)/$(SOURCE_FILE) && false)

extract: download
	[ -f $(PACKAGE_SOURCE_DIR)/.extracted ] || ( \
		mkdir -p $(PACKAGE_SOURCE_DIR); \
		tar -xf $(DLDIR)/$(SOURCE_FILE) -C $(SOURCEDIR) && \
		for f in $$(ls ./patches/*.patch ./patches/*.diff); do patch -d $(PACKAGE_SOURCE_DIR) -p1 < $$f; done; \
		touch $(PACKAGE_SOURCE_DIR)/.extracted \
	)

configure: extract
	[ -f $(PACKAGE_BUILD_DIR)/.configured ] || ( \
		mkdir -p $(PACKAGE_BUILD_DIR); \
		cd $(PACKAGE_BUILD_DIR); \
		ln -sf $(PACKAGE_SOURCE_DIR); \
		CFLAGS="$(HOST_CFLAGS)" \
		LDFLAGS="$(HOST_LDFLAGS)" \
			$(PACKAGE_SOURCE_DIR:$(SOURCEDIR)/%=%)/configure $(CONFIGURE_ARGS) && \
		touch $(PACKAGE_BUILD_DIR)/.configured \
	)

build: configure
	[ -f $(PACKAGE_BUILD_DIR)/.built ] || ( \
		$(MAKE) -C $(PACKAGE_BUILD_DIR) && \
		touch $(PACKAGE_BUILD_DIR)/.built \
	)

install: build
	[ -f $(PACKAGE_BUILD_DIR)/.installed ] || ( \
		$(MAKE) -C $(PACKAGE_BUILD_DIR) install && \
		touch $(PACKAGE_BUILD_DIR)/.installed \
	)

force-install: build
	$(MAKE) -C $(PACKAGE_BUILD_DIR) install

