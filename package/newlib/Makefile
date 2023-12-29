
NAME=newlib
VERSION=3.3.0
SOURCE_FILE=$(NAME)-$(VERSION).tar.gz
URL=http://www.sourceware.org/pub/$(NAME)/$(NAME)-$(VERSION).tar.gz

PACKAGE_SOURCE_DIR=$(SOURCEDIR)/$(NAME)-$(VERSION)
PACKAGE_BUILD_DIR=$(STAGE_BUILD_DIR)/$(NAME)-$(VERSION)

CONFIGURE_ARGS= \
	--prefix=/ \
	--enable-static \
	--enable-shared \
	--target=$(TARGET)

ifeq ($(strip $(LIBC_DEBUG)),y)
NEWLIB_DEBUG_CFLAGS:=-g3 -ggdb3 -gdwarf-4
endif

ifeq ($(strip $(LIBC_NANO)),y)
CONFIGURE_ARGS += \
	--enable-newlib-reent-small \
	--enable-newlib-retargetable-locking \
	--disable-newlib-fvwrite-in-streamio \
	--disable-newlib-fseek-optimization \
	--disable-newlib-wide-orient \
	--disable-newlib-unbuf-stream-opt \
	--disable-nls \
	--enable-newlib-nano-malloc \
	--enable-lite-exit \
	--enable-newlib-global-atexit
#	--disable-newlib-supplied-syscalls

LIBC_NANO_RENAME := \
	cp -f $(STAGE_BUILD_DIR)/newlib-libs/$(TARGET)/lib/libc.a $(STAGE_BUILD_DIR)/newlib-libs/$(TARGET)/lib/libc_nano.a && \
	cp -f $(STAGE_BUILD_DIR)/newlib-libs/$(TARGET)/lib/libg.a $(STAGE_BUILD_DIR)/newlib-libs/$(TARGET)/lib/libg_nano.a && \
	cp -f $(STAGE_BUILD_DIR)/newlib-libs/$(TARGET)/lib/librdimon.a $(STAGE_BUILD_DIR)/newlib-libs/$(TARGET)/lib/librdimon_nano.a &&

else
CONFIGURE_ARGS += \
	--disable-newlib-supplied-syscalls \
	--disable-nls \
	--enable-newlib-io-long-long \
	--enable-newlib-io-c99-formats \
	--enable-newlib-register-fini \
	--enable-newlib-retargetable-locking
endif

ifneq ($(LIBC_USE_SOFT_FLOAT),y)
CONFIGURE_ARGS += \
	--enable-newlib-io-long-double

ifeq ($(strip $(LIBC_NANO)),y)
CONFIGURE_ARGS += \
	--enable-newlib-nano-formatted-io
endif
endif

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
		READELF_FOR_TARGET="$(TOOLCHAIN_PREFIX)readelf" \
			$(PACKAGE_SOURCE_DIR:$(SOURCEDIR)/%=%)/configure $(CONFIGURE_ARGS) && \
		touch $(PACKAGE_BUILD_DIR)/.configured \
	)

build: configure
	[ -f $(PACKAGE_BUILD_DIR)/.built ] || ( \
		$(MAKE) -C $(PACKAGE_BUILD_DIR) && \
		touch $(PACKAGE_BUILD_DIR)/.built \
	)

ifeq ($(strip $(LIBC_NANO)),y)
install: build
	[ -f $(PACKAGE_BUILD_DIR)/.installed ] || ( \
		$(MAKE) -j1 -C $(PACKAGE_BUILD_DIR) install DESTDIR=$(STAGE_BUILD_DIR)/newlib-libs && \
		$(LIBC_NANO_RENAME) \
		cp -a $(STAGE_BUILD_DIR)/newlib-libs/$(TARGET)/* $(FINAL_SYSROOT_DIR)/ && \
		touch $(PACKAGE_BUILD_DIR)/.installed \
	)
else
install: build
	[ -f $(PACKAGE_BUILD_DIR)/.installed ] || ( \
		$(MAKE) -j1 -C $(PACKAGE_BUILD_DIR) install DESTDIR=$(STAGE_BUILD_DIR)/newlib-libs && \
		cp -a $(STAGE_BUILD_DIR)/newlib-libs/$(TARGET)/* $(FINAL_SYSROOT_DIR)/ && \
		touch $(PACKAGE_BUILD_DIR)/.installed \
	)
endif

force-install: build
	$(MAKE) -C $(PACKAGE_BUILD_DIR) install

