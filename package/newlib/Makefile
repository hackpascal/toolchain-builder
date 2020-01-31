
NAME=newlib
VERSION=3.3.0
SOURCE_FILE=$(NAME)-$(VERSION).tar.gz
URL=http://www.sourceware.org/pub/$(NAME)/$(NAME)-$(VERSION).tar.gz

PACKAGE_SOURCE_DIR=$(BUILD_SOURCE_DIR)/$(NAME)-$(VERSION)
PACKAGE_BUILD_DIR=$(BUILD_DIR)/$(NAME)-$(VERSION)

CONFIGURE_ARGS= \
	--prefix=/ \
	--enable-static \
	--enable-shared \
	--target=$(TARGET)

ifeq ($(strip $(LIBC_DEBUG)),y)
NEWLIB_DEBUG_CFLAGS:=-g3 -ggdb3 -gdwarf-4
endif

all: install
	true

download:
	[ -f $(DLDIR)/$(SOURCE_FILE) ] || wget -O $(DLDIR)/$(SOURCE_FILE) $(URL) || (rm -f $(DLDIR)/$(SOURCE_FILE) && false)

extract: download
	[ -f $(PACKAGE_SOURCE_DIR)/.extracted ] || ( \
		mkdir -p $(PACKAGE_SOURCE_DIR); \
		tar -zxf $(DLDIR)/$(SOURCE_FILE) -C $(BUILD_SOURCE_DIR) && \
		for f in $$(ls ./patches/*.patch ./patches/*.diff); do patch -d $(PACKAGE_SOURCE_DIR) -p1 < $$f; done; \
		touch $(PACKAGE_SOURCE_DIR)/.extracted \
	)

configure: extract
	[ -f $(PACKAGE_BUILD_DIR)/.configured ] || ( \
		mkdir -p $(PACKAGE_BUILD_DIR); \
		cd $(PACKAGE_BUILD_DIR); \
		acnewlib_cv_type_long_double=yes \
		newlib_cv_ldbl_eq_dbl=yes \
		CFLAGS="$(HOST_CFLAGS)" \
		CFLAGS_FOR_TARGET="$(TARGET_CFLAGS) $(NEWLIB_DEBUG_CFLAGS)" \
		CC_FOR_TARGET="$(TOOLCHAIN_PREFIX)gcc" \
		CXX_FOR_TARGET="$(TOOLCHAIN_PREFIX)g++" \
		AR_FOR_TARGET="$(TOOLCHAIN_PREFIX)ar" \
		AS_FOR_TARGET="$(TOOLCHAIN_PREFIX)as" \
		LD_FOR_TARGET="$(TOOLCHAIN_PREFIX)ld" \
		RANLIB_FOR_TARGET="$(TOOLCHAIN_PREFIX)ranlib" \
			$(PACKAGE_SOURCE_DIR)/configure $(CONFIGURE_ARGS) && \
		touch $(PACKAGE_BUILD_DIR)/.configured \
	)

build: configure
	[ -f $(PACKAGE_BUILD_DIR)/.built ] || ( \
		$(MAKE) -C $(PACKAGE_BUILD_DIR) && \
		touch $(PACKAGE_BUILD_DIR)/.built \
	)

install: build
	[ -f $(PACKAGE_BUILD_DIR)/.installed ] || ( \
		($(MAKE) -C $(PACKAGE_BUILD_DIR) install DESTDIR=$(BUILD_DIR)/newlib-libs || \
		 $(MAKE) -C $(PACKAGE_BUILD_DIR) install DESTDIR=$(BUILD_DIR)/newlib-libs) && \
		cp -a $(BUILD_DIR)/newlib-libs/$(TARGET)/* $(SYSROOT_PREFIX)/ && \
		touch $(PACKAGE_BUILD_DIR)/.installed \
	)

force-install: build
	$(MAKE) -C $(PACKAGE_BUILD_DIR) install

