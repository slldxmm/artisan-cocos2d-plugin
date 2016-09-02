LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := artisan_native
LOCAL_SRC_FILES := $(LOCAL_PATH)/lib/$(TARGET_ARCH_ABI)/libartisan.so
include $(PREBUILT_SHARED_LIBRARY)
