/*
 * Copyright (C) 2016 TestBird  - All Rights Reserved
 * You may use, distribute and modify this code under
 * the terms of the mit license.
 */

#include <string.h>
#include "JSExceptionHandler.h"

#define NUMBER_STRING_LENGTH 32

TB_NS_START
void JSExceptionHandler::registerJSExceptionHandler(JSContext *cx, TBJSObject object) {
    JS_SetErrorReporter(cx, reportError);
    JS_DefineFunction(cx, object, "TestBirdReportCaughtException", reportCaughtException, 3, 0);
    JS_DefineFunction(cx, object, "TestBirdSetUserId", setUserId, 1, 0);
    JS_DefineFunction(cx, object, "TestBirdAddCustomLog", addCustomLog, 1, 0);
    JS_DefineFunction(cx, object, "TestBirdSetCustomKey", setCustomKey, 2, 0);
    JS_DefineFunction(cx, object, "TestBirdRemoveCustomKey", removeCustomKey, 1, 0);
    JS_DefineFunction(cx, object, "TestBirdClearCustomKeys", clearCustomKeys, 1, 0);
}

bool JSExceptionHandler::reportCaughtException(JSContext *cx, unsigned argc, JS::Value *vp) {
    if (argc > 0) {
        const char* name, *reason = "", *traceback = "";
#if COCOS2D_VERSION >= 0x00030500
        JS::CallArgs args = JS::CallArgsFromVp(argc, vp);
        jsval_to_charptr(cx, args.get(0), &name);
        if (argc > 1) {
            jsval_to_charptr(cx, args.get(1), &reason);
        }
        if (argc > 2) {
            jsval_to_charptr(cx, args.get(2), &traceback);
        }
        args.rval().setUndefined();
#else
        jsval *argvp = JS_ARGV(cx, vp);
        jsval_to_charptr(cx, *argvp++, &name);
        if (argc > 1) {
        jsval_to_charptr(cx, *argvp++, &reason);
        }
        if (argc > 2) {
            jsval_to_charptr(cx, *argvp++, &traceback);
        }
#endif
        CrashReporter::reportException(EXCEPTION_TYPE_GAUGHT_JS, name, reason, traceback);
    }
    return true;
}

void JSExceptionHandler::reportError(JSContext *cx, const char *message, JSErrorReport *report)
{
    const char* format = "%s:%u\n";
    const char* fileName = report != nullptr && report->filename ? report->filename : "No filename";

    size_t bufLen = strlen(format) + strlen(fileName) + NUMBER_STRING_LENGTH;
    char* traceback = (char*)malloc(bufLen);
    memset(traceback, 0, bufLen);
    sprintf(traceback, format, fileName, (unsigned int) report->lineno);

    const char *reason = strstr(message, ":");
    const char *name = message;

    if (reason == nullptr) {
        reason = message;
    } else {
        size_t len = strlen(message) - strlen(reason);
        if (len > 0) {
            name = strndup(message, len);
            reason ++;
        }
    }

    CrashReporter::reportException(EXCEPTION_TYPE_JS, name, reason, traceback);
    free(traceback);

    if (name != message) {
        free((void*)name);
    }
};

bool JSExceptionHandler::setUserId(JSContext *cx, unsigned argc, JS::Value *vp) {
    if (argc > 0) {
#if COCOS2D_VERSION >= 0x00030500
        JS::CallArgs args = JS::CallArgsFromVp(argc, vp);
        const char* arg0;
        jsval_to_charptr(cx, args.get(0), &arg0);
        CrashReporter::setUserId(arg0);
        args.rval().setUndefined();
#else
        jsval *argvp = JS_ARGV(cx, vp);
        const char* arg0;
        jsval_to_charptr(cx, *argvp++, &arg0);
        CrashReporter::setUserId(arg0);
#endif
    }

    return true;
}

bool JSExceptionHandler::addCustomLog(JSContext *cx, unsigned argc, JS::Value *vp) {
    if (argc > 0) {
#if COCOS2D_VERSION >= 0x00030500
        JS::CallArgs args = JS::CallArgsFromVp(argc, vp);
        const char* arg0;
        jsval_to_charptr(cx, args.get(0), &arg0);
        CrashReporter::addCustomLog(arg0);
        args.rval().setUndefined();
#else
        jsval *argvp = JS_ARGV(cx, vp);
        const char* arg0;
        jsval_to_charptr(cx, *argvp++, &arg0);
        CrashReporter::addCustomLog(arg0);
#endif
    }
    return true;
}
bool JSExceptionHandler::setCustomKey(JSContext *cx, unsigned argc, JS::Value *vp) {
    if (argc > 1) {
#if COCOS2D_VERSION >= 0x00030500
        JS::CallArgs args = JS::CallArgsFromVp(argc, vp);
        const char* key, *value;
        jsval_to_charptr(cx, args.get(0), &key);
        jsval_to_charptr(cx, args.get(1), &value);
        CrashReporter::setCustomKey(key, value);
        args.rval().setUndefined();
#else
        jsval *argvp = JS_ARGV(cx, vp);
        const char* key, *value;
        jsval_to_charptr(cx, *argvp++, &key);
        jsval_to_charptr(cx, *argvp++, &value);
        CrashReporter::setCustomKey(key, value);
#endif
    }
    return true;
}
bool JSExceptionHandler::removeCustomKey(JSContext *cx, unsigned argc, JS::Value *vp) {
    if (argc > 0) {
#if COCOS2D_VERSION >= 0x00030500
        JS::CallArgs args = JS::CallArgsFromVp(argc, vp);
        const char* key;
        jsval_to_charptr(cx, args.get(0), &key);
        CrashReporter::removeCustomKey(key);
        args.rval().setUndefined();
#else
        jsval *argvp = JS_ARGV(cx, vp);
        const char* key;
        jsval_to_charptr(cx, *argvp++, &key);
        CrashReporter::removeCustomKey(key);
#endif
    }
    return true;
}
bool JSExceptionHandler::clearCustomKeys(JSContext *cx, unsigned argc, JS::Value *vp) {
    CrashReporter::clearCustomKeys();
    return true;
}
TB_NS_END

