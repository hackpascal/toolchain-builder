
CONFIGURE_ARGS += \
	--disable-lto \
	--disable-largefile \
	--disable-shared \
	--enable-languages=c \
	--disable-nls \
	--disable-bootstrap \
	--with-newlib

ifneq ($(LIBC_HEADERS),)
CONFIGURE_ARGS += \
	--enable-threads \
	--enable-tls \
	--with-build-sysroot=$(BUILD_SYSROOT) \
	--with-native-system-header-dir=/include
else
CONFIGURE_ARGS += \
	--disable-threads \
	--disable-tls \
	--without-headers
endif

