
NAME=uClibc-ng
VERSION=1.0.45
SOURCE_FILE=$(NAME)-$(VERSION).tar.xz
URL=https://downloads.uclibc-ng.org/releases/$(VERSION)/$(SOURCE_FILE)

PACKAGE_BUILD_DIR=$(STAGE_BUILD_DIR)/$(NAME)-$(VERSION)

ifeq ($(strip $(LIBC_DEBUG)),y)
UCLIBC_DEBUG_CFLAGS:=-g3 -ggdb3 -gdwarf-4
endif

all: install
	true

download:
	[ -f $(DLDIR)/$(SOURCE_FILE) ] || wget -O $(DLDIR)/$(SOURCE_FILE) $(URL) || (rm -f $(DLDIR)/$(SOURCE_FILE) && false)

extract: download
	[ -f $(PACKAGE_BUILD_DIR)/.extracted ] || ( \
		mkdir -p $(PACKAGE_BUILD_DIR); \
		tar -xf $(DLDIR)/$(SOURCE_FILE) -C $(STAGE_BUILD_DIR) && \
		for f in $$(ls ./patches/*.patch ./patches/*.diff); do patch -d $(PACKAGE_BUILD_DIR) -p1 < $$f; done; \
		touch $(PACKAGE_BUILD_DIR)/.extracted \
	)

configure: extract
	cp ./configs/$(TARGET)$(if $(strip $(UCLIBC_VARIANT)),.$(strip $(UCLIBC_VARIANT))).config $(PACKAGE_BUILD_DIR)/tmp.config
	sed -i 's/KERNEL_HEADERS=""/KERNEL_HEADERS="$(subst /,\/,$(LINUX_HEADER_DIR)/include)"/g' $(PACKAGE_BUILD_DIR)/tmp.config
	sed -i 's/CROSS_COMPILER_PREFIX=""/CROSS_COMPILER_PREFIX="$(subst /,\/,$(TOOLCHAIN_PREFIX))"/g' $(PACKAGE_BUILD_DIR)/tmp.config
	sed -i 's/UCLIBC_EXTRA_CFLAGS=""/UCLIBC_EXTRA_CFLAGS="$(TARGET_CFLAGS) $(UCLIBC_DEBUG_CFLAGS)"/g' $(PACKAGE_BUILD_DIR)/tmp.config
	if [ "$(LIBC_USE_SOFT_FLOAT)" = "y" ]; then \
		sed -i 's/UCLIBC_HAS_FPU=y/# UCLIBC_HAS_FPU is not set/g' $(PACKAGE_BUILD_DIR)/tmp.config; \
		sed -i 's/# UCLIBC_HAS_SOFT_FLOAT is not set/UCLIBC_HAS_SOFT_FLOAT=y/g' $(PACKAGE_BUILD_DIR)/tmp.config; \
	else \
		sed -i 's/# UCLIBC_HAS_FPU is not set/UCLIBC_HAS_FPU=y/g' $(PACKAGE_BUILD_DIR)/tmp.config; \
		sed -i 's/UCLIBC_HAS_SOFT_FLOAT=y/# UCLIBC_HAS_SOFT_FLOAT is not set/g' $(PACKAGE_BUILD_DIR)/tmp.config; \
	fi
	if [ -f $(PACKAGE_BUILD_DIR)/.config ]; then \
		cmp $(PACKAGE_BUILD_DIR)/.config $(PACKAGE_BUILD_DIR)/tmp.config || \
			cp $(PACKAGE_BUILD_DIR)/tmp.config $(PACKAGE_BUILD_DIR)/.config; \
		rm $(PACKAGE_BUILD_DIR)/tmp.config; \
	else \
		mv $(PACKAGE_BUILD_DIR)/tmp.config $(PACKAGE_BUILD_DIR)/.config; \
	fi
	make -C $(PACKAGE_BUILD_DIR) oldconfig

headers: configure
	$(MAKE) -C $(PACKAGE_BUILD_DIR) PREFIX=$(LIBC_PRE_HEADER_DIR) install_headers
	cp -a $(LIBC_PRE_HEADER_DIR)/include/* $(BUILD_SYSROOT)/include/
	cp -a $(LIBC_PRE_HEADER_DIR)/include/* $(FINAL_SYSROOT_DIR)/include/

build: configure
	[ -f $(PACKAGE_BUILD_DIR)/.built ] || ( \
		$(MAKE) -C $(PACKAGE_BUILD_DIR) all hostutils && \
		touch $(PACKAGE_BUILD_DIR)/.built \
	)

install: build
	[ -f $(PACKAGE_BUILD_DIR)/.installed ] || ( \
		$(MAKE) -C $(PACKAGE_BUILD_DIR) PREFIX=$(FINAL_SYSROOT_DIR) install_runtime install_dev; \
		if [ x"$(STAGE)" = xtoolchain ]; then \
			mkdir -p $(FINAL_OUTPUT_DIR)/bin; \
			cp $(PACKAGE_BUILD_DIR)/utils/getconf.host $(FINAL_OUTPUT_DIR)/bin/$(TARGET)-getconf; \
			cp $(PACKAGE_BUILD_DIR)/utils/ldconfig.host $(FINAL_OUTPUT_DIR)/bin/$(TARGET)-ldconfig; \
			cp $(PACKAGE_BUILD_DIR)/utils/ldd.host $(FINAL_OUTPUT_DIR)/bin/$(TARGET)-ldd; \
		fi; \
		touch $(PACKAGE_BUILD_DIR)/.installed \
	)

