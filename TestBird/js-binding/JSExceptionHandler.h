/*
 * Copyright (C) 2016 TestBird  - All Rights Reserved
 * You may use, distribute and modify this code under
 * the terms of the mit license.
 */

#ifndef __JS_EXCEPTION_HANDLER_H__
#define __JS_EXCEPTION_HANDLER_H__

#include "cocos2d.h"
#include "scripting/js-bindings/manual/js_module_register.h"
#include "Testbird/CrashReporter/CrashReporter.h"

#if COCOS2D_VERSION >= 0x00030500
#define TBJSObject JS::HandleObject
#else
#define TBJSObject JSObject*
#endif

TB_NS_START
class  JSExceptionHandler
{
public:
    static void registerJSExceptionHandler(JSContext *cx, TBJSObject object);

private:
    static bool reportCaughtException(JSContext *cx, unsigned argc, JS::Value *vp);
    static void reportError(JSContext *cx, const char *message, JSErrorReport *report);
    static void registerFunctions(JSContext *cx, TBJSObject obj);
    static bool setUserId(JSContext *cx, unsigned argc, JS::Value *vp);
    static bool addCustomLog(JSContext *cx, unsigned argc, JS::Value *vp);
    static bool setCustomKey(JSContext *cx, unsigned argc, JS::Value *vp);
    static bool removeCustomKey(JSContext *cx, unsigned argc, JS::Value *vp);
    static bool clearCustomKeys(JSContext *cx, unsigned argc, JS::Value *vp);
};
TB_NS_END

#endif  // __JS_EXCEPTION_HANDLER_H__

