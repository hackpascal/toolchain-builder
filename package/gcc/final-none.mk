
CONFIGURE_ARGS += \
	--enable-lto \
	--enable-plugins \
	--enable-largefile \
	--disable-threads \
	--disable-shared \
	--enable-static \
	--enable-languages=c,c++ \
	--disable-tls \
	--disable-libstdc++-v3 \
	--with-newlib \
	--with-build-sysroot=$(OUTPUT_PREFIX)/$(TARGET) \
	--with-native-system-header-dir=/include

