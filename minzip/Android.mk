LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
	Hash.c \
	SysUtil.c \
	DirUtil.c \
	Inlines.c \
	Zip.c

LOCAL_C_INCLUDES := \
	external/zlib \
	external/safe-iop/include

LOCAL_MODULE := libminzip

LOCAL_SHARED_LIBRARIES := libselinux libz

LOCAL_CLANG := true

LOCAL_CFLAGS += -Werror -Wall

include $(BUILD_SHARED_LIBRARY)


include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
	Hash.c \
	SysUtil.c \
	DirUtil.c \
	Inlines.c \
	Zip.c

LOCAL_C_INCLUDES += \
	external/zlib \
	external/safe-iop/include

LOCAL_MODULE := libminzip

LOCAL_STATIC_LIBRARIES := libselinux libz

LOCAL_CLANG := true

LOCAL_CFLAGS += -Werror -Wall

include $(BUILD_STATIC_LIBRARY)
