
export TOPDIR:=$(CURDIR)
export DLDIR:=$(TOPDIR)/dl
export OUTPUTDIR:=$(TOPDIR)/output
export BUILDDIR:=$(TOPDIR)/build
export PACKAGEDIR:=$(TOPDIR)/package

export HOST_CFLAGS:=-ffunction-sections -fdata-sections
export HOST_LDFLAGS:=-Wl,--gc-sections

export TARGET_CFLAGS:=$(HOST_CFLAGS)
export TARGET_LDFLAGS:=$(HOST_LDFLAGS)

export HOSTCC ?= gcc

export SYSROOT_NAME:=sysroot

ifneq ($(wildcard $(TOPDIR)/.config),)

include $(TOPDIR)/.config

export GCC_ARCH:=$(strip $(shell $(HOSTCC) --print-multiarch 2>/dev/null))

ifeq ($(BUILD),)
# you can copy config.guess to TOPDIR manually
export BUILD:=$(strip $(shell $(TOPDIR)/config.guess 2>/dev/null))
ifeq ($(BUILD),)
export BUILD:=$(GCC_ARCH)
endif
endif

ifeq ($(BUILD),$(TARGET))
NATIVE_BUILD:=y
ifneq ($(GCC_ARCH),$(TARGET))
PREFIX_USE_GCC_ARCH:=y
endif
else
ifeq ($(GCC_ARCH),$(TARGET))
NATIVE_BUILD:=y
endif
endif

export NATIVE_BUILD PREFIX_USE_GCC_ARCH

WIN_HOST:=$(findstring mingw,$(HOST))
WIN_HOST:=$(WIN_HOST)$(findstring cygwin,$(HOST))
WIN_HOST:=$(WIN_HOST)$(findstring msys,$(HOST))
WIN_HOST:=$(strip $(WIN_HOST))

export WIN_HOST


all: dirs target
	true

dirs:
	mkdir -p $(DLDIR)

target: toolchain
ifeq ($(strip $(NO_TARGET)),)
	$(MAKE) -f build.mk BUILD_TYPE=target
else
	true
endif

toolchain:
ifeq ($(NATIVE_BUILD),)
	$(MAKE) -f build.mk BUILD_TYPE=toolchain
else
	true
endif

target_%:
ifeq ($(strip $(NO_TARGET)),)
	$(MAKE) -f build.mk BUILD_TYPE=target $(@:target_%=%)
endif

toolchain_%:
ifeq ($(NATIVE_BUILD),)
	$(MAKE) -f build.mk BUILD_TYPE=toolchain $(@:toolchain_%=%)
endif

else
all:
	echo "Missing configure file!"
	false

endif

clean:
	-rm -rf $(BUILDDIR)

dirclean: clean
	-rm -rf $(OUTPUTDIR)

distclean: dirclean
	-rm -rf $(DLDIR)

.PHONY: clean dirclean distclean


