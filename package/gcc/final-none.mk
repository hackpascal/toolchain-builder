
CONFIGURE_ARGS += \
	--disable-libgomp \
	--disable-libquadmath \
	--disable-libatomic \
	--disable-libssp \
	--disable-libsanitizer \
	--disable-libstdc++-v3 \
	--disable-tls \
	--enable-lto \
	--enable-plugins \
	--enable-largefile \
	--disable-threads \
	--disable-shared \
	--enable-static \
	--enable-languages=c,c++,lto \
	--with-newlib \
	--with-build-sysroot=$(OUTPUT_PREFIX)/$(TARGET) \
	--with-native-system-header-dir=/include

