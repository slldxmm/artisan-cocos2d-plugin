LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := testbird_artisan_cocos

LOCAL_MODULE_FILENAME := libartisancocos

LOCAL_CPP_EXTENSION := .mm .cpp .cc
LOCAL_CFLAGS += -x c++
LOCAL_STATIC_LIBRARIES := cocos2dx_static

LOCAL_SHARED_LIBRARIES := artisan_native

LOCAL_SRC_FILES := CrashReporter.mm

include $(BUILD_STATIC_LIBRARY)

$(call import-module,external/TestBird/prebuilt)
