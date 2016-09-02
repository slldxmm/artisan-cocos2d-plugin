/*
 * Copyright (C) 2016 TestBird  - All Rights Reserved
 * You may use, distribute and modify this code under
 * the terms of the mit license.
 */

#ifndef __LUA_EXCEPTION_HANDLER_H__
#define __LUA_EXCEPTION_HANDLER_H__

#include "cocos2d.h"
#include "TestBird/CrashReporter/CrashReporter.h"

TB_NS_START
class  LuaExceptionHandler
{
public:
    static void registerLuaExceptionHandler();
    static int reportCaughtException(lua_State* ls);
    static int onLuaException(lua_State* ls);
    static int setUserId(lua_State* ls);
    static int addCustomLog(lua_State* ls);
    static int setCustomKey(lua_State* ls);
    static int removeCustomKey(lua_State* ls);
    static int clearCustomKeys(lua_State* ls);
};
TB_NS_END

#endif  // __LUA_EXCEPTION_HANDLER_H__

