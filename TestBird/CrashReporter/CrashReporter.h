/*
 * Copyright (C) 2016 TestBird  - All Rights Reserved
 * You may use, distribute and modify this code under
 * the terms of the mit license.
 */

#ifndef CrashReporter_h
#define CrashReporter_h

#define TB_NS_START namespace TestBird {
#define TB_NS_END   }
#define USING_TB_NS using namespace TestBird
#define TB_NS_PREFIX TestBird::

#include "cocos2d.h"

TB_NS_START
typedef enum {
    EXCEPTION_TYPE_LUA,
    EXCEPTION_TYPE_JS,
    EXCEPTION_TYPE_CAUGHT_LUA,
    EXCEPTION_TYPE_GAUGHT_JS
}EXCEPTION_TYPE;

class CrashReporter {
public:
    static void enableDebug(bool enable);
    static void initWithAppKey(const char *appKey, const char *channel);
    static void setUserId(const char *userId);
    static void addCustomLog(const char *log);
    static void setCustomKey(const char *key, const char *value);
    static void removeCustomKey(const char *key);
    static void clearCustomKeys();
    static void reportException(EXCEPTION_TYPE type, const char *name, const char *reason, const char *traceback);
};
TB_NS_END


#endif /* CrashReporter_h */
