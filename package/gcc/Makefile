
NAME=gcc
VERSION=7.5.0
SOURCE_FILE=$(NAME)-$(VERSION).tar.xz
URL=https://ftp.gnu.org/gnu/$(NAME)/$(NAME)-$(VERSION)/$(SOURCE_FILE)

PACKAGE_SOURCE_DIR=$(BUILD_SOURCE_DIR)/$(NAME)-$(VERSION)
PACKAGE_BUILD_DIR_COMMON=$(BUILD_DIR)/$(NAME)-$(VERSION)

CONFIGURE_ARGS= \
	--prefix=$(OUTPUT_PREFIX) \
	--target=$(TARGET) \
	$(if $(HOST),--host=$(HOST)) \
	--disable-__cxa_atexit \
	--disable-multilib \
	--disable-libgomp \
	--disable-libquadmath \
	--disable-libatomic \
	--disable-libssp \
	--disable-libsanitizer \
	--disable-libmudflap \
	--disable-sjlj-exceptions \
	--enable-version-specific-runtime-libs \
	--enable-fully-dynamic-string \
	--enable-gnu-unique-object \
	--enable-linker-build-id \
	--enable-c99 \
	--enable-clocale=gnu \
	--enable-long-long \
	--with-gnu-ld \
	--with-gnu-as \
	--with-libiconv \
	--with-system-zlib \
	$(TARGET_GCC_FLAGS)

LIBS_CFLAGS := -I$(HOST_OUTPUT_PREFIX)/include
LIBS_CXXFLAGS := $(LIBS_CFLAGS)
LIBS_LDFLAGS := -L$(HOST_OUTPUT_PREFIX)/lib

ifneq ($(ARCH),x86)
CONFIGURE_ARGS += --disable-decimal-float
endif

ifeq ($(strip $(LIBC_DEBUG)),y)
GCC_DEBUG_CFLAGS:=-g3 -ggdb3 -gdwarf-4
endif

PACKAGE_BUILD_DIR=$(PACKAGE_BUILD_DIR_COMMON)-$(STAGE)

ifneq ($(LIBC),none)
STAGE_MK=$(STAGE)
else
STAGE_MK=$(STAGE)-none
endif

include $(STAGE_MK).mk


all: install
	true

download:
	[ -f $(DLDIR)/$(SOURCE_FILE) ] || wget -O $(DLDIR)/$(SOURCE_FILE) $(URL) || (rm -f $(DLDIR)/$(SOURCE_FILE) && false)

extract: download
	[ -f $(PACKAGE_SOURCE_DIR)/.extracted ] || ( \
		mkdir -p $(PACKAGE_SOURCE_DIR); \
		tar -Jxf $(DLDIR)/$(SOURCE_FILE) -C $(BUILD_SOURCE_DIR) && \
		for f in $$(ls ./patches/*.patch ./patches/*.diff); do patch -d $(PACKAGE_SOURCE_DIR) -p1 < $$f; done; \
		touch $(PACKAGE_SOURCE_DIR)/.extracted \
	)

ifeq ($(BUILD_TYPE),toolchain)
configure: extract
	[ -f $(PACKAGE_BUILD_DIR)/.configured ] || ( \
		mkdir -p $(PACKAGE_BUILD_DIR); \
		cd $(PACKAGE_BUILD_DIR); \
		CFLAGS="$(HOST_CFLAGS) $(LIBS_CFLAGS)" \
		CXXFLAGS="$(HOST_CXXFLAGS) $(LIBS_CXXFLAGS)" \
		LDFLAGS="$(HOST_LDFLAGS) $(LIBS_LDFLAGS)" \
			$(PACKAGE_SOURCE_DIR)/configure $(CONFIGURE_ARGS) && \
		touch $(PACKAGE_BUILD_DIR)/.configured \
	)
else
configure: extract
	[ -f $(PACKAGE_BUILD_DIR)/.configured ] || ( \
		mkdir -p $(PACKAGE_BUILD_DIR); \
		cd $(PACKAGE_BUILD_DIR); \
		enable_gnu_indirect_function=yes \
		default_gnu_indirect_function=yes \
		CFLAGS="$(HOST_CFLAGS) $(LIBS_CFLAGS)" \
		CXXFLAGS="$(HOST_CXXFLAGS) $(LIBS_CXXFLAGS)" \
		LDFLAGS="$(HOST_LDFLAGS) $(LIBS_LDFLAGS)" \
		CFLAGS_FOR_TARGET="$(TARGET_CFLAGS) $(LIBS_CFLAGS) $(GCC_DEBUG_CFLAGS)" \
		CXXFLAGS_FOR_TARGET="$(TARGET_CXXFLAGS) $(LIBS_CXXFLAGS) $(GCC_DEBUG_CFLAGS)" \
		LDFLAGS_FOR_TARGET="$(TARGET_LDFLAGS) $(LIBS_LDFLAGS)" \
		CC_FOR_TARGET="$(TOOLCHAIN_PREFIX)gcc" \
		CXX_FOR_TARGET="$(TOOLCHAIN_PREFIX)g++" \
		AR_FOR_TARGET="$(TOOLCHAIN_PREFIX)ar" \
		AS_FOR_TARGET="$(TOOLCHAIN_PREFIX)as" \
		LD_FOR_TARGET="$(TOOLCHAIN_PREFIX)ld"  \
		RANLIB_FOR_TARGET="$(TOOLCHAIN_PREFIX)ranlib" \
			$(PACKAGE_SOURCE_DIR)/configure $(CONFIGURE_ARGS) && \
		touch $(PACKAGE_BUILD_DIR)/.configured \
	)
endif

build: configure
	[ -f $(PACKAGE_BUILD_DIR)/.built ] || ( \
		$(MAKE) -C $(PACKAGE_BUILD_DIR) && \
		touch $(PACKAGE_BUILD_DIR)/.built \
	)

install: build
	[ -f $(PACKAGE_BUILD_DIR)/.installed ] || ( \
		$(MAKE) -C $(PACKAGE_BUILD_DIR) install && \
		([ -d $(OUTPUT_PREFIX)/lib/gcc/$(TARGET)/lib ] && cp -a $(OUTPUT_PREFIX)/lib/gcc/$(TARGET)/lib64/* $(OUTPUT_PREFIX)/lib/gcc/$(TARGET)/$(VERSION)/ || true ) && \
		([ -d $(OUTPUT_PREFIX)/lib/gcc/$(TARGET)/lib64 ] && cp -a $(OUTPUT_PREFIX)/lib/gcc/$(TARGET)/lib64/* $(OUTPUT_PREFIX)/lib/gcc/$(TARGET)/$(VERSION)/ || true ) && \
		touch $(PACKAGE_BUILD_DIR)/.installed \
	)

force-install: build
	$(MAKE) -C $(PACKAGE_BUILD_DIR) install

