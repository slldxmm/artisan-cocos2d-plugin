LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := testbird_artisan_cocos_js

LOCAL_MODULE_FILENAME := libartisancocosjs

LOCAL_CPP_EXTENSION := .mm .cpp .cc
LOCAL_CFLAGS += -x c++

LOCAL_SRC_FILES := JSExceptionHandler.cpp
LOCAL_STATIC_LIBRARIES := cocos2d_js_static

LOCAL_STATIC_LIBRARIES ＋= testbird_artisan_cocos

include $(BUILD_STATIC_LIBRARY)
