
export BUILD_TYPE:=$(strip $(BUILD_TYPE))

export TARGET_BUILD_DIR:=$(BUILDDIR)/$(TARGET)
export TARGET_OUTPUT_DIR:=$(OUTPUTDIR)/$(TARGET)

export OUTPUT_PREFIX:=$(TARGET_OUTPUT_DIR)/$(VARIANT)/$(BUILD_TYPE)/usr
export OUTPUT_TARGET_PREFIX:=$(OUTPUT_PREFIX)/$(TARGET)
export SYSROOT_PREFIX:=$(OUTPUT_TARGET_PREFIX)/$(SYSROOT_NAME)

export BUILD_SOURCE_DIR:=$(BUILDDIR)/sources
export ARCH_SOURCE_DIR:=$(BUILD_SOURCE_DIR)/$(ARCH)

export BUILD_DIR:=$(TARGET_BUILD_DIR)/$(VARIANT)/$(BUILD_TYPE)
export BUILD_SYSROOT:=$(BUILD_DIR)/$(SYSROOT_NAME)

export LINUX_HEADER_DIR:=$(TARGET_BUILD_DIR)/linux
export LIBC_PRE_HEADER_DIR:=$(BUILD_DIR)/libc-dev

ifeq ($(BUILD_TYPE),toolchain)
export HOST_BUILD_DIR:=$(BUILDDIR)/$(BUILD)
export HOST:=
else
ifeq ($(BUILD_TYPE),target)
export HOST_BUILD_DIR:=$(BUILDDIR)/$(HOST)
else
$(error Invalid BUILD_TYPE)
endif
endif

ifneq ($(filter-out aarch64 aarch64_eb x86_64 mips64 mips64el,$(TARGET)),)
export TARGET_LIB_DIR:=/lib64
else
export TARGET_LIB_DIR:=/lib
endif

export HOST_SOURCE_DIR:=$(BUILD_SOURCE_DIR)
export HOST_OUTPUT_PREFIX:=$(HOST_BUILD_DIR)/install

ifeq ($(NATIVE_BUILD),)
export TOOLCHAIN_BIN_DIR:=$(TARGET_OUTPUT_DIR)/$(VARIANT)/toolchain/usr/bin
export TOOLCHAIN_PREFIX:=$(TOOLCHAIN_BIN_DIR)/$(TARGET)-
else
ifeq ($(PREFIX_USE_GCC_ARCH),y)
export TOOLCHAIN_PREFIX:=$(GCC_ARCH)-
else
export TOOLCHAIN_PREFIX:=$(TARGET)-
endif
endif


ifneq ($(filter uclibc-ng glibc,$(LIBC)),)
export LIBC_HEADERS:=$(LIBC)-headers
endif


all: gcc-final gdb
ifneq ($(TARGET),$(PROGRAM_PREFIX))
	-find $(OUTPUT_PREFIX)/bin/ -name '$(TARGET)-*' -printf '%P\n' | while read f; do ln -sf "$$f" "$(OUTPUT_PREFIX)/bin/$(PROGRAM_PREFIX)$${f#*$(TARGET)}"; done
endif
ifeq ($(BUILD_TYPE),target)
ifneq ($(WIN_HOST),)
	-find $(OUTPUT_PREFIX)/ -name '*.exe' -o -name '*.dll' | xargs $(HOST)-strip
	$(TOPDIR)/symlinkconv.sh "$(OUTPUT_PREFIX)"
endif
endif

gmp:
	$(MAKE) -C $(PACKAGEDIR)/gmp

mpfr: gmp
	$(MAKE) -C $(PACKAGEDIR)/mpfr

mpc: gmp mpfr
	$(MAKE) -C $(PACKAGEDIR)/mpc

isl: gmp
	$(MAKE) -C $(PACKAGEDIR)/isl

binutils: gmp mpfr mpc isl
	$(MAKE) -C $(PACKAGEDIR)/binutils

dir-prep:
	mkdir -p $(SYSROOT_PREFIX)/lib
	mkdir -p $(SYSROOT_PREFIX)/include
	ln -sf $(SYSROOT_NAME)/include $(OUTPUT_TARGET_PREFIX)/include
	mkdir -p $(BUILD_SYSROOT)/lib
	mkdir -p $(BUILD_SYSROOT)/include

ifneq ($(LIBC),none)
linux-headers: dir-prep
	$(MAKE) -C $(PACKAGEDIR)/linux-kernel headers

ifeq ($(BUILD_TYPE),toolchain)
$(LIBC): linux-headers gcc-initial
	$(MAKE) -C $(PACKAGEDIR)/$(LIBC)

ifneq ($(LIBC_HEADERS),)
gcc-minimum: gmp mpfr mpc isl binutils
	$(MAKE) -C $(PACKAGEDIR)/gcc STAGE=minimum

$(LIBC_HEADERS): gcc-minimum dir-prep
	$(MAKE) -C $(PACKAGEDIR)/$(LIBC) headers
endif

gcc-initial: gmp mpfr mpc isl binutils $(LIBC_HEADERS)
	$(MAKE) -C $(PACKAGEDIR)/gcc STAGE=initial
else
$(LIBC): linux-headers
	$(MAKE) -C $(PACKAGEDIR)/$(LIBC)
endif

gcc-final: binutils $(LIBC)
	$(MAKE) -C $(PACKAGEDIR)/gcc STAGE=final

else
gcc-final: gmp mpfr mpc isl binutils dir-prep
	$(MAKE) -C $(PACKAGEDIR)/gcc STAGE=final
endif

gdb: mpfr
	$(MAKE) -C $(PACKAGEDIR)/gdb


# Additional libraries

libiconv: gcc-final
	$(MAKE) -C $(PACKAGEDIR)/libiconv

zlib: gcc-final
	$(MAKE) -C $(PACKAGEDIR)/zlib

