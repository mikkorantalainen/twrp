#
# Copyright (C) 2014 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Hierarchy:
# 1) toybox (if TW_USE_TOYBOX)
# 2) busybox (if !TW_USE_TOYBOX)
# 3) toolbox (always included; provides start, stop, restart for services)

#####################
##      toybox     ##
#####################

ifeq ($(TW_USE_TOYBOX), true)

LOCAL_PATH := external/toybox

include $(CLEAR_VARS)

LOCAL_MODULE := toybox_recovery
LOCAL_MODULE_STEM := toybox
LOCAL_MODULE_PATH := $(TARGET_RECOVERY_ROOT_OUT)/sbin
LOCAL_MODULE_TAGS := optional

LOCAL_WHOLE_STATIC_LIBRARIES := libtoybox
LOCAL_SHARED_LIBRARIES := libc libcutils libselinux libcrypto liblog libselinux

LOCAL_CFLAGS := \
    -std=c99 \
    -Os \
    -Wno-char-subscripts \
    -Wno-sign-compare \
    -Wno-string-plus-int \
    -Wno-uninitialized \
    -Wno-unused-parameter \
    -funsigned-char \
    -ffunction-sections \
    -fdata-sections \
    -fno-asynchronous-unwind-tables

toybox_upstream_version := $(shell grep -o 'TOYBOX_VERSION.*\".*\"' $(LOCAL_PATH)/main.c | cut -d'"' -f2)
toybox_sha := $(shell git -C $(LOCAL_PATH) rev-parse --short=12 HEAD 2>/dev/null)

toybox_version := $(toybox_upstream_version)-$(toybox_sha)-android
LOCAL_CFLAGS += -DTOYBOX_VERSION='"$(toybox_version)"'

LOCAL_CXX_STL := none
LOCAL_CLANG := true
LOCAL_PACK_MODULE_RELOCATIONS := false

TOYBOX_INSTLIST := $(HOST_OUT_EXECUTABLES)/toybox-instlist

include $(BUILD_EXECUTABLE)

endif

#####################
##     busybox     ##
#####################

ifneq ($(TW_USE_TOYBOX), true)

LOCAL_PATH := $(call my-dir)

BUSYBOX_LINKS := $(shell cat $(LOCAL_PATH)/../busybox/busybox-full.links)

# Exclusions:
#  fstools provides tune2fs and mke2fs
#  pigz provides gzip gunzip
#  dosfstools provides equivalents of mkdosfs mkfs.vfat
#  sh isn't working well in android 7.1, so relink mksh instead
BUSYBOX_EXCLUDE := tune2fs mke2fs mkdosfs mkfs.vfat gzip gunzip sh

# Having /sbin/modprobe present on 32 bit devices with can cause a massive
# performance problem if the kernel has CONFIG_MODULES=y
ifeq ($(filter arm64 x86_64, $(TARGET_ARCH)),)
    BUSYBOX_EXCLUDE += modprobe
endif

BUSYBOX_TOOLS := $(filter-out $(BUSYBOX_EXCLUDE), $(notdir $(BUSYBOX_LINKS)))

endif

#####################
##     toolbox     ##
#####################

BSD_TOOLS := \
    dd

TOOLBOX_TOOLS := \
    getevent \
    iftop \
    ioctl \
    log \
    nandread \
    newfs_msdos \
    prlimit \
    ps \
    restart \
    sendevent \
    start \
    stop \
    top

###########################
##     micro.toolbox     ##
###########################

# Provides getprop, setprop when toybox is not available
# These tools originated in toolbox, but were removed when toybox took responsibility

ifneq ($(TW_USE_TOYBOX), true)

LOCAL_PATH := $(call my-dir)

MTOOLBOX_LINKS := $(shell cat $(LOCAL_PATH)/mt/micro.toolbox-links)

endif

##############################
##     utility symlinks     ##
##############################

include $(CLEAR_VARS)

ifeq ($(TW_USE_TOYBOX), true)

utility_symlinks: $(TOYBOX_INSTLIST)
utility_symlinks: TOOLBOX_TOOLS_INSTALLED=$(BSD_TOOLS) $(TOOLBOX_TOOLS)
utility_symlinks:
	@mkdir -p $(TARGET_RECOVERY_ROOT_OUT)/sbin
	@echo -e ${CL_CYN}"Generate toolbox links:"${CL_RST} $(TOOLBOX_TOOLS_INSTALLED)
	$(hide) $(foreach t,$(TOOLBOX_TOOLS_INSTALLED),ln -sf toolbox $(TARGET_RECOVERY_ROOT_OUT)/sbin/$(t);)
	@echo -e ${CL_CYN}"Generate toybox links:"${CL_RST} $(TOYBOX_TOOLS)
	$(hide) $(TOYBOX_INSTLIST) | xargs -I'{}' ln -sf toybox '$(TARGET_RECOVERY_ROOT_OUT)/sbin/{}'

else

utility_symlinks: TOOLBOX_TOOLS_INSTALLED=$(filter-out $(BUSYBOX_TOOLS), $(BSD_TOOLS) $(TOOLBOX_TOOLS))
utility_symlinks: MTOOLBOX_TOOLS_INSTALLED=$(filter-out $(BUSYBOX_TOOLS) $(TOOLBOX_TOOLS_INSTALLED), $(MTOOLBOX_LINKS))
utility_symlinks:
	@mkdir -p $(TARGET_RECOVERY_ROOT_OUT)/sbin
	@echo -e ${CL_CYN}"Generate busybox links:"${CL_RST} $(BUSYBOX_TOOLS)
	$(hide) $(foreach t,$(BUSYBOX_TOOLS),ln -sf busybox $(TARGET_RECOVERY_ROOT_OUT)/sbin/$(t);)
	@echo -e ${CL_CYN}"Generate toolbox links:"${CL_RST} $(TOOLBOX_TOOLS_INSTALLED)
	$(hide) $(foreach t,$(TOOLBOX_TOOLS_INSTALLED),ln -sf toolbox $(TARGET_RECOVERY_ROOT_OUT)/sbin/$(t);)
	@echo -e ${CL_CYN}"Generate micro.toolbox links:"${CL_RST} $(MTOOLBOX_TOOLS_INSTALLED)
	$(hide) $(foreach t,$(MTOOLBOX_TOOLS_INSTALLED),ln -sf micro.toolbox $(TARGET_RECOVERY_ROOT_OUT)/sbin/$(t);)

endif
