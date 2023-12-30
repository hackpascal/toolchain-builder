
export STAGE:=$(strip $(STAGE))

export TARGET_BUILD_DIR:=$(BUILDDIR)/$(TARGET)/$(VARIANT)
export TARGET_OUTPUT_DIR:=$(OUTPUTDIR)/$(TARGET)/$(VARIANT)

export STAGE_BUILD_DIR:=$(TARGET_BUILD_DIR)/$(STAGE)
export BUILD_SYSROOT:=$(STAGE_BUILD_DIR)/$(SYSROOT_NAME)

export LINUX_HEADER_DIR:=$(TARGET_BUILD_DIR)/linux-headers
export LIBC_PRE_HEADER_DIR:=$(STAGE_BUILD_DIR)/libc-dev

ifeq ($(STAGE),toolchain)
export HOST_BUILD_DIR:=$(BUILDDIR)/$(BUILD)
export HOST:=
export BUILD_PREFIX:=$(TARGET_OUTPUT_DIR)/$(STAGE)/usr
export INSTALL_DIR:=/
export FINAL_OUTPUT_DIR:=$(BUILD_PREFIX)
else
ifeq ($(STAGE),target)
export HOST_BUILD_DIR:=$(BUILDDIR)/$(HOST)
ifneq ($(TARGET_PREFIX),)
export BUILD_PREFIX:=$(TARGET_PREFIX)
else
export BUILD_PREFIX:=/opt/toolchain/$(TARGET)
endif # $(TARGET_PREFIX)
export INSTALL_DIR:=$(TARGET_OUTPUT_DIR)/$(STAGE)
export FINAL_OUTPUT_DIR:=$(INSTALL_DIR)$(BUILD_PREFIX)
else
$(error Invalid STAGE)
endif
endif

export SYSROOT_PREFIX:=$(BUILD_PREFIX)/$(TARGET)/$(SYSROOT_NAME)
export FINAL_SYSROOT_DIR:=$(FINAL_OUTPUT_DIR)/$(TARGET)/$(SYSROOT_NAME)

ifneq ($(filter-out aarch64 aarch64_eb x86_64 mips64 mips64el,$(TARGET)),)
export TARGET_LIB_DIR:=/lib64
else
export TARGET_LIB_DIR:=/lib
endif

export HOST_OUTPUT_PREFIX:=$(HOST_BUILD_DIR)/install

export TOOLCHAIN_BIN_DIR:=$(TARGET_OUTPUT_DIR)/toolchain/usr/bin

ifeq ($(NATIVE_BUILD),)
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

ifneq ($(LIBC),newlib)
LINUX_HEADERS_DEP := linux-headers
DIR_PREP_DEP :=
else
LINUX_HEADERS_DEP :=
DIR_PREP_DEP := dir-prep
endif

all: gcc-final gdb
ifneq ($(TARGET),$(PROGRAM_PREFIX))
	-find $(FINAL_OUTPUT_DIR)/bin/ -name '$(TARGET)-*' -printf '%P\n' | while read f; do ln -sf "$$f" "$(FINAL_OUTPUT_DIR)/bin/$(PROGRAM_PREFIX)$${f#*$(TARGET)}"; done
endif
ifeq ($(STAGE),target)
ifneq ($(WIN_HOST),)
	-find $(FINAL_OUTPUT_DIR)/ -name '*.exe' -o -name '*.dll' | xargs $(HOST)-strip
ifeq ($(STRIP_ALL),y)
	-find $(FINAL_OUTPUT_DIR)/lib/gcc/$(TARGET) -name '*.so*' -o -name '*.a' -o -name '*.o' | xargs $(TOOLCHAIN_BIN_DIR)/$(TARGET)-strip
	-find $(FINAL_OUTPUT_DIR)/libexec/gcc/$(TARGET) -name '*.so*' -o -name '*.a' | xargs $(TOOLCHAIN_BIN_DIR)/$(TARGET)-strip
	-find $(FINAL_OUTPUT_DIR)/$(TARGET)/$(SYSROOT_NAME)/lib -name '*.so*' -o -name '*.a' -o -name '*.o' | xargs $(TOOLCHAIN_BIN_DIR)/$(TARGET)-strip
	-find $(FINAL_OUTPUT_DIR)/$(TARGET)/$(SYSROOT_NAME)/lib64 -name '*.so*' -o -name '*.a' -o -name '*.o' | xargs $(TOOLCHAIN_BIN_DIR)/$(TARGET)-strip
	-find $(FINAL_OUTPUT_DIR)/$(TARGET)/$(SYSROOT_NAME)/bin | xargs $(TOOLCHAIN_BIN_DIR)/$(TARGET)-strip
	-find $(FINAL_OUTPUT_DIR)/$(TARGET)/$(SYSROOT_NAME)/sbin | xargs $(TOOLCHAIN_BIN_DIR)/$(TARGET)-strip
	-find $(FINAL_OUTPUT_DIR)/$(TARGET)/$(SYSROOT_NAME)/libexec | xargs $(TOOLCHAIN_BIN_DIR)/$(TARGET)-strip
endif
	$(TOPDIR)/symlinkconv.sh "$(FINAL_OUTPUT_DIR)"
endif
	find $(FINAL_OUTPUT_DIR) -name '*.la' | xargs sed -i -e 's/-L$(subst /,\/,$(HOST_OUTPUT_PREFIX))\/lib//g' -e 's/$(subst /,\/,$(INSTALL_DIR))//g'
endif

gmp:
	$(MAKE) -C $(PACKAGEDIR)/gmp

mpfr: gmp
	$(MAKE) -C $(PACKAGEDIR)/mpfr

mpc: gmp mpfr
	$(MAKE) -C $(PACKAGEDIR)/mpc

isl: gmp
	$(MAKE) -C $(PACKAGEDIR)/isl

libiconv:
	$(MAKE) -C $(PACKAGEDIR)/libiconv

zlib:
	$(MAKE) -C $(PACKAGEDIR)/zlib

expat:
	$(MAKE) -C $(PACKAGEDIR)/expat

xz:
	$(MAKE) -C $(PACKAGEDIR)/xz

binutils: gmp mpfr mpc isl zlib libiconv
	$(MAKE) -C $(PACKAGEDIR)/binutils

dir-prep:
	mkdir -p $(FINAL_SYSROOT_DIR)/lib
	ln -sf lib $(FINAL_SYSROOT_DIR)/lib64
	mkdir -p $(FINAL_SYSROOT_DIR)/include
	ln -sf $(SYSROOT_NAME)/include $(FINAL_OUTPUT_DIR)/$(TARGET)/include
	mkdir -p $(BUILD_SYSROOT)/lib
	ln -sf lib $(BUILD_SYSROOT)/lib64
	mkdir -p $(BUILD_SYSROOT)/include

ifneq ($(LIBC),none)
linux-headers: dir-prep
	$(MAKE) -C $(PACKAGEDIR)/linux-kernel headers

ifeq ($(STAGE),toolchain)
$(LIBC): $(LINUX_HEADERS_DEP) $(DIR_PREP_DEP) gcc-initial
	$(MAKE) -C $(PACKAGEDIR)/$(LIBC)

ifneq ($(LIBC_HEADERS),)
gcc-minimum: gmp mpfr mpc isl zlib libiconv binutils
	$(MAKE) -C $(PACKAGEDIR)/gcc GCC_STAGE=minimum

$(LIBC_HEADERS): gcc-minimum dir-prep
	$(MAKE) -C $(PACKAGEDIR)/$(LIBC) headers
endif

gcc-initial: gmp mpfr mpc isl zlib libiconv binutils $(LIBC_HEADERS)
	$(MAKE) -C $(PACKAGEDIR)/gcc GCC_STAGE=initial
else
$(LIBC): $(LINUX_HEADERS_DEP) $(DIR_PREP_DEP)
	$(MAKE) -C $(PACKAGEDIR)/$(LIBC)
endif

gcc-final: binutils $(LIBC)
	$(MAKE) -C $(PACKAGEDIR)/gcc GCC_STAGE=final

else
gcc-final: gmp mpfr mpc isl zlib libiconv binutils dir-prep
	$(MAKE) -C $(PACKAGEDIR)/gcc GCC_STAGE=final
endif

gdb: mpfr expat xz zlib libiconv
	$(MAKE) -C $(PACKAGEDIR)/gdb

