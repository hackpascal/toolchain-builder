
NAME=glibc
VERSION=2.26
SOURCE_FILE=$(NAME)-$(VERSION).tar.xz
URL=https://ftp.gnu.org/gnu/$(NAME)/$(SOURCE_FILE)

PACKAGE_SOURCE_DIR=$(BUILD_SOURCE_DIR)/$(NAME)-$(VERSION)
PACKAGE_BUILD_DIR=$(BUILD_DIR)/$(NAME)-$(VERSION)

CONFIGURE_ARGS= \
	--prefix=/ \
	--host=$(TARGET) \
	--disable-profile \
	--disable-werror \
	--without-gd \
	--without-cvs \
	--enable-add-ons \
	--with-headers=$(BUILD_SYSROOT)/include

ifeq ($(strip $(LIBC_USE_SOFT_FLOAT)),y)
CONFIGURE_ARGS += --without-fp
endif

ifeq ($(strip $(LIBC_DEBUG)),y)
GLIBC_DEBUG_CFLAGS:=-g3 -ggdb3 -gdwarf-4
endif


all: install
	true

download:
	[ -f $(DLDIR)/$(SOURCE_FILE) ] || wget -O $(DLDIR)/$(SOURCE_FILE) $(URL) || (rm -f $(DLDIR)/$(SOURCE_FILE) && false)

extract: download
	[ -f $(PACKAGE_SOURCE_DIR)/.extracted ] || ( \
		mkdir -p $(PACKAGE_SOURCE_DIR); \
		tar -Jxf $(DLDIR)/$(SOURCE_FILE) -C $(BUILD_SOURCE_DIR) && \
		cp $(PACKAGE_SOURCE_DIR)/sysdeps/unix/sysv/linux/aarch64/pt-vfork.c $(PACKAGE_SOURCE_DIR)/sysdeps/unix/sysv/linux/arm/pt-vfork.c && \
		for f in $$(ls ./patches/*.patch ./patches/*.diff); do patch -d $(PACKAGE_SOURCE_DIR) -p1 < $$f; done; \
		touch $(PACKAGE_SOURCE_DIR)/.extracted \
	)

configure: extract
	[ -f $(PACKAGE_BUILD_DIR)/.configured ] || ( \
		mkdir -p $(PACKAGE_BUILD_DIR); \
		cd $(PACKAGE_BUILD_DIR); \
		libc_cv_slibdir="/$(TARGET_LIB_DIR)" \
		use_ldconfig=no \
		libc_cv_ssp=no \
		libc_cv_ssp_strong=no \
		ac_cv_header_cpuid_h=yes \
		libc_cv_ld_gnu_indirect_function=yes \
		CC="$(TOOLCHAIN_PREFIX)gcc" \
		CXX="$(TOOLCHAIN_PREFIX)g++" \
		CFLAGS="$(TARGET_CFLAGS) $(GLIBC_DEBUG_CFLAGS)" \
		CXXFLAGS="$(TARGET_CFLAGS) $(GLIBC_DEBUG_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
			$(PACKAGE_SOURCE_DIR)/configure $(CONFIGURE_ARGS) && \
		touch $(PACKAGE_BUILD_DIR)/.configured \
	)

build: configure
	[ -f $(PACKAGE_BUILD_DIR)/.built ] || ( \
		$(MAKE) -C $(PACKAGE_BUILD_DIR) && \
		touch $(PACKAGE_BUILD_DIR)/.built \
	)

headers: configure
	$(MAKE) -C $(PACKAGE_BUILD_DIR) \
		install_root="$(LIBC_PRE_HEADER_DIR)" \
		install-bootstrap-headers=yes \
		install-headers
	touch $(LIBC_PRE_HEADER_DIR)/include/gnu/stubs.h
	cp -a $(LIBC_PRE_HEADER_DIR)/include/* $(BUILD_SYSROOT)/include/
	cp -a $(LIBC_PRE_HEADER_DIR)/include/* $(SYSROOT_PREFIX)/include/

install: build
	[ -f $(PACKAGE_BUILD_DIR)/.installed ] || ( \
		$(MAKE) -C $(PACKAGE_BUILD_DIR) install DESTDIR=$(SYSROOT_PREFIX) && \
		touch $(PACKAGE_BUILD_DIR)/.installed \
	)

force-install: build
	$(MAKE) -C $(PACKAGE_BUILD_DIR) install

