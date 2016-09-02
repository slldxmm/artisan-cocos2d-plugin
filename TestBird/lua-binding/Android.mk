LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := testbird_artisan_cocos_lua

LOCAL_MODULE_FILENAME := libartisancocoslua

LOCAL_CPP_EXTENSION := .mm .cpp .cc
LOCAL_CFLAGS += -x c++

LOCAL_SRC_FILES := LuaExceptionHandler.cpp

LOCAL_STATIC_LIBRARIES := cocos2d_lua_static testbird_artisan_cocos

include $(BUILD_STATIC_LIBRARY)
