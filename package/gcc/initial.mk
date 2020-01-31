
CONFIGURE_ARGS += \
	--disable-lto \
	--disable-largefile \
	--disable-nls \
	--disable-shared \
	--disable-bootstrap \
	--disable-libgomp \
	--disable-libquadmath \
	--disable-libatomic \
	--disable-libssp \
	--disable-libsanitizer \
	--enable-languages=c \
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

