
CONFIGURE_ARGS += \
	--enable-lto \
	--enable-plugins \
	--enable-largefile \
	--enable-shared \
	--enable-static \
	--enable-nls \
	--enable-libstdcxx-debug \
	--enable-libstdcxx-time=yes \
	--enable-languages=c,c++,lto \
	--with-sysroot=$(SYSROOT_PREFIX) \
	--with-native-system-header-dir=/include

ifeq ($(LIBC),newlib)
CONFIGURE_ARGS += \
	--with-newlib \
	--disable-thread \
	--disable-tls
else
CONFIGURE_ARGS += \
	--enable-threads=posix \
	--enable-tls
endif

