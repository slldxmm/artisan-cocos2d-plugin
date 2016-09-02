/*
 * Copyright (C) 2016 TestBird  - All Rights Reserved
 * You may use, distribute and modify this code under
 * the terms of the mit license.
 */

#include <string.h>
#include "LuaExceptionHandler.h"
#include "Testbird/CrashReporter/CrashReporter.h"
#include "scripting/lua-bindings/manual/CCLuaEngine.h"

TB_NS_START
void LuaExceptionHandler::registerLuaExceptionHandler() {
#if COCOS2D_VERSION >= 0x00030000
    lua_State* ls = cocos2d::LuaEngine::getInstance()->getLuaStack()->getLuaState();
#else
    lua_State* ls = cocos2d::CCLuaEngine::defaultEngine()->getLuaStack()->getLuaState();
#endif
    lua_register(ls, "TestBirdReportCaughtException", reportCaughtException);
    lua_register(ls, "TestBirdOnLuaException", onLuaException);
    lua_register(ls, "TestBirdSetUserId", setUserId);
    lua_register(ls, "TestBirdAddCustomLog", addCustomLog);
    lua_register(ls, "TestBirdSetCustomKey", setCustomKey);
    lua_register(ls, "TestBirdRemoveCustomKey", removeCustomKey);
    lua_register(ls, "TestBirdClearCustomKeys", clearCustomKeys);
}

int LuaExceptionHandler::reportCaughtException(lua_State* ls) {
    const char* message = lua_tostring(ls, 1);
    const char* traceback = lua_tostring(ls, 2);

    if (message != nullptr && traceback != nullptr) {
        CrashReporter::reportException(EXCEPTION_TYPE_CAUGHT_LUA, "LuaException", message, traceback);
    }
    return 0;
}

int LuaExceptionHandler::onLuaException(lua_State* ls) {
    const char* message = lua_tostring(ls, 1);
    const char* traceback = lua_tostring(ls, 2);

    if (message != nullptr && traceback != nullptr) {
        CrashReporter::reportException(EXCEPTION_TYPE_LUA, "LuaException", message, traceback);
    }
    return 0;
}

int LuaExceptionHandler::setUserId(lua_State* ls) {
    const char* userId = lua_tostring(ls, 1);
    if (userId != nullptr) {
        CrashReporter::setUserId(userId);
    }
    return 0;
}


int LuaExceptionHandler::addCustomLog(lua_State* ls) {
    const char *log = lua_tostring(ls, 1);
    if (log != nullptr) {
        CrashReporter::addCustomLog(log);
    }
    return 0;
}
int LuaExceptionHandler::setCustomKey(lua_State* ls) {
    const char *key = lua_tostring(ls, 1);
    const char *value = lua_tostring(ls, 2);
    if (key != nullptr && value != nullptr) {
        CrashReporter::setCustomKey(key, value);
    }
    return 0;
}

int LuaExceptionHandler::removeCustomKey(lua_State* ls) {
    const char *key = lua_tostring(ls, 1);
    if (key != nullptr) {
        CrashReporter::removeCustomKey(key);
    }
    return 0;
}

int LuaExceptionHandler::clearCustomKeys(lua_State* ls) {
    CrashReporter::clearCustomKeys();
    return 0;
}

TB_NS_END


