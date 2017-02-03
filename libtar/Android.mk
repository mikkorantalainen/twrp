LOCAL_PATH := $(call my-dir)

common_src_files := \
    android_utils.c \
    append.c \
    basename.c \
    block.c \
    decode.c \
    dirname.c \
    encode.c \
    extract.c \
    handle.c \
    libtar_hash.c \
    libtar_list.c \
    output.c \
    strmode.c \
    util.c \
    wrapper.c

# Build shared library
include $(CLEAR_VARS)

LOCAL_MODULE := libtar_twrp
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := $(common_src_files)
LOCAL_C_INCLUDES += $(LOCAL_PATH) \
                    external/libselinux/include \
                    external/zlib
LOCAL_SHARED_LIBRARIES += libc libselinux libz
ifeq ($(TW_INCLUDE_CRYPTO_FBE), true)
    LOCAL_SHARED_LIBRARIES += libe4crypt
    LOCAL_CFLAGS += -DHAVE_EXT4_CRYPT
    LOCAL_C_INCLUDES += $(LOCAL_PATH)/../crypto/ext4crypt
endif
include $(BUILD_SHARED_LIBRARY)

common_src_files :=
