/*
 * Copyright (C) 2016 TestBird  - All Rights Reserved
 * You may use, distribute and modify this code under
 * the terms of the mit license.
 */

#include "CrashReporter.h"

#include <string.h>

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    #import <Foundation/Foundation.h>
    #import <TestBirdAgent/TestBirdAgent.h>
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    #include <jni.h>
    #include <android/log.h>
    #define COCOS_ACTIVITY_CLASS "org/cocos2dx/lib/Cocos2dxActivity"
    #define COCOS_ACTIVITY_METHOD_CONTEXT "getContext"
    #define COCOS_ACTIVITY_METHOD_CONTEXT_PARAMETER "()Landroid/content/Context;"
    #define ARTISAN_CRASHMANAGER_CLASS "com/testbird/artisan/TestBirdAgent/CrashManager"
    #define ARTISAN_SET_DEBUG "setDebug"
    #define ARTISAN_SET_DEBUG_SIG "(Z)V"
    #define ARTISAN_PLUGIN_CLASS "com/testbird/artisan/TestBirdAgent/ArtisanPlugin"
    #define ARTISAN_SET_CONTEXT "setContext"
    #define ARTISAN_SET_CONTEXT_SIG "(Landroid/content/Context;)V"
    #define ARTISAN_ADD_CUSTOM_LOG "addCustomLog"
    #define ARTISAN_ADD_CUSTOM_LOG_SIG "(Ljava/lang/String;I)V"
    #define ARTISAN_REGISTER_SDK "registerSdk"
    #define ARTISAN_REGISTER_SDK_SIG "(Ljava/lang/String;Ljava/lang/String;)V"
    #define ARTISAN_SUBMIT_CRASH "submitCrash"
    #define ARTISAN_SUBMIT_CRASH_SIG "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
    #define ARTISAN_ADD_CUSTOM_KEY "addCustomKey"
    #define ARTISAN_ADD_CUSTOM_KEY_SIG "(Ljava/lang/String;Ljava/lang/String;)V"
    #define ARTISAN_SET_USER_ID "setUserId"
    #define ARTISAN_SET_USER_ID_SIG "(Ljava/lang/String;)V"
    #define ARTISAN_DELETE_CUSTOM_KEY "deleteCustomKey"
    #define ARTISAN_DELETE_CUSTOM_KEY_SIG "(Ljava/lang/String;)V"
    #define ARTISAN_CLEAR_CUSTOM_KEY "clearCustomKeys"
    #define ARTISAN_CLEAR_CUSTOM_KEY_SIG "()V"

    #define LOG_TAG "artisan_agent"
    #define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
    #define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)
    #define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)
#endif

USING_NS_CC;

TB_NS_START

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
static JNIEnv *getEnv() {
    JavaVM *jvm = cocos2d::JniHelper::getJavaVM();
    JNIEnv *env = NULL;
    int status = jvm->GetEnv((void **)&env, JNI_VERSION_1_4);
    if (NULL == jvm || NULL == env) {
        LOGE("Could not complete opertion because JavaVM or JNIEnv is null!");
        return NULL;
    }
    if (status < 0) {
        jvm->AttachCurrentThread(&env, 0);
    }
    return env;
}

static bool android_checkJniException(JNIEnv *env) {
    if (env->ExceptionCheck()) {
        env->ExceptionDescribe();
        env->ExceptionClear();
        return true;
    } else {
        return false;
    }
}

static jclass android_findClass(JNIEnv *env, const char *name) {
    jclass cls = env->FindClass(name);
    if (android_checkJniException(env)) {
        LOGE("Find class %s error.", name);
        return NULL;
    }
    return cls;
}

static jmethodID android_getStaticMethod(JNIEnv *env, jclass cls,
                                         const char *name,
                                         const char *sig) {
    jmethodID method = env->GetStaticMethodID(cls, name, sig);
    if (android_checkJniException(env)) {
        LOGE("Get static method name:%s sig:%s error.", name, sig);
        return NULL;
    }
    return method;
}

static bool android_init() {
    static bool _inited = false;
    if (_inited) {
        return false;
    }
    _inited = true;

    JNIEnv *env = getEnv();
    jclass clz = android_findClass(env, COCOS_ACTIVITY_CLASS);
    if (clz != NULL) {
        jmethodID method = android_getStaticMethod(env, clz, COCOS_ACTIVITY_METHOD_CONTEXT,
                                                   COCOS_ACTIVITY_METHOD_CONTEXT_PARAMETER);
        if (method == NULL) {
            return false;
        }
        jobject objCtx = (jobject)env->CallStaticObjectMethod(clz, method);
        if (android_checkJniException(env)) {
            LOGE("Exception in call static method getContext");
            return false;
        }
        if (NULL == objCtx) {
            LOGD("Could not find Cocos2dxActivity object!");
            return false;
        } else {
            LOGD("find class %s.", ARTISAN_PLUGIN_CLASS);
            jclass cls =android_findClass(env, ARTISAN_PLUGIN_CLASS);
            if (cls == NULL) {
                return false;
            }
            method = android_getStaticMethod(env, cls, ARTISAN_SET_CONTEXT, ARTISAN_SET_CONTEXT_SIG);
            if (method == NULL) {
                return false;
            }
            env->CallStaticVoidMethod(cls, method, objCtx);
            if (android_checkJniException(env)) {
                LOGE("Error in call method %s.", ARTISAN_SET_CONTEXT);
                return false;
            }
            LOGD("set context complete.");
            return true;
        }
    }
    return false;
}

static void android_callArtisanSdkMethod(const char *name, const char *sig, ...) {
    JNIEnv *env = getEnv();
    jclass cls = android_findClass(env, ARTISAN_PLUGIN_CLASS);
    if (cls != NULL) {
        jmethodID method = android_getStaticMethod(env, cls, name, sig);
        if (method != NULL) {
            va_list arg_ptr;
            va_start(arg_ptr, sig);
            char *param;
            int arg_cnt = 0;
            jstring params[6] = {NULL};
            while ((param = va_arg(arg_ptr, char *)) != NULL) {
                params[arg_cnt] =  env->NewStringUTF(param);
                arg_cnt ++;
            }

            va_end(arg_ptr);

            switch (arg_cnt) {
                case 0:
                    env->CallStaticVoidMethod(cls, method);
                    break;
                case 1:
                    env->CallStaticVoidMethod(cls, method, params[0]);
                    break;
                case 2:
                    env->CallStaticVoidMethod(cls, method, params[0], params[1]);
                    break;
                case 3:
                    env->CallStaticVoidMethod(cls, method, params[0], params[1], params[2]);
                    break;
                case 4:
                    env->CallStaticVoidMethod(cls, method, params[0], params[1], params[2], params[3]);
                    break;
                case 5:
                    env->CallStaticVoidMethod(cls, method, params[0], params[1], params[2], params[3], params[4]);
                    break;
                case 6:
                    env->CallStaticVoidMethod(cls, method, params[0], params[1], params[2], params[3], params[4], params[5]);
                    break;
            }

            while (arg_cnt > 0) {
                env->DeleteLocalRef(params[--arg_cnt]);
            }
            if (android_checkJniException(env)) {
                LOGE("Error in method %s.", name);
            }
        }
    }
}

#endif

void CrashReporter::enableDebug(bool enable) {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    [TestBirdAgent setDebug:enable];
#else
    JNIEnv *env = getEnv();
    jclass cls = android_findClass(env, ARTISAN_CRASHMANAGER_CLASS);
    jmethodID method = android_getStaticMethod(env, cls, ARTISAN_SET_DEBUG, ARTISAN_SET_DEBUG_SIG);
    env->CallStaticVoidMethod(cls, method, enable);
#endif
}

void CrashReporter::initWithAppKey(const char *appKey, const char *channel) {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    NSString *appKeyString = [NSString stringWithCString:appKey encoding:NSUTF8StringEncoding];
    [TestBirdAgent enableWithAppKey:appKeyString];
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    android_init();
    android_callArtisanSdkMethod(ARTISAN_REGISTER_SDK, ARTISAN_REGISTER_SDK_SIG, appKey, channel, NULL);
#endif
}

void CrashReporter::reportException(EXCEPTION_TYPE type, const char *name, const char *reason, const char *traceback)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    CocosScriptExceptionType exceptionType;
    switch (type) {
        case EXCEPTION_TYPE_JS:
            exceptionType = JSException;
            break;
        case EXCEPTION_TYPE_LUA:
            exceptionType = LuaException;
            break;
        case EXCEPTION_TYPE_GAUGHT_JS:
            exceptionType = JSCaughtException;
            break;
        case EXCEPTION_TYPE_CAUGHT_LUA:
            exceptionType = LuaCaughtException;
            break;
        default:
            break;
    }

    [[TestBirdAgent sharedInstance]reportCocosScriptException:exceptionType
                                                         name:@(name)
                                                       reason:@(reason)
                                                    traceback:@(traceback)];
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    const char* event_type;
    switch (type) {
        case EXCEPTION_TYPE_JS:
            event_type = "cocos_js_exception";
            break;
        case EXCEPTION_TYPE_LUA:
            event_type = "cocos_lua_exception";
            break;
        case EXCEPTION_TYPE_GAUGHT_JS:
            event_type = "cocos_js_caught_exception";
            break;
        case EXCEPTION_TYPE_CAUGHT_LUA:
            event_type = "cocos_lua_caught_exception";
            break;
        default:
            break;
    }
    android_callArtisanSdkMethod(ARTISAN_SUBMIT_CRASH,
                                 ARTISAN_SUBMIT_CRASH_SIG,
                                 name, reason, traceback, event_type, NULL);
#endif
}

void CrashReporter::setUserId(const char *userId) {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    [[TestBirdAgent sharedInstance] setUserId:@(userId)];
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    android_callArtisanSdkMethod(ARTISAN_SET_USER_ID,
                                 ARTISAN_SET_USER_ID_SIG, userId, NULL);
#endif
}

void CrashReporter::addCustomLog(const char *log) {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    [[TestBirdAgent sharedInstance] addCustomLog:@(log)];
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    JNIEnv *env = getEnv();
    jclass cls = android_findClass(env, ARTISAN_PLUGIN_CLASS);
    if (cls != NULL) {
        jmethodID method = android_getStaticMethod(
            env, cls, ARTISAN_ADD_CUSTOM_LOG, ARTISAN_ADD_CUSTOM_LOG_SIG);
        if (method != NULL) {
        jstring jline = env->NewStringUTF(log);
        env->CallStaticObjectMethod(cls, method, jline, 4, NULL);
        if (android_checkJniException(env)) {
            LOGE("Exception in call static method %s.", ARTISAN_ADD_CUSTOM_LOG);
            return;
        }
        env->DeleteLocalRef(jline);
        }
    }
#endif
}
void CrashReporter::setCustomKey(const char *key, const char *value) {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    [[TestBirdAgent sharedInstance] setCustomValue:@(value) forKey:@(key)];
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    android_callArtisanSdkMethod(ARTISAN_ADD_CUSTOM_KEY,
                                 ARTISAN_ADD_CUSTOM_KEY_SIG, key, value, NULL);
#endif
}
void CrashReporter::removeCustomKey(const char *key) {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    [[TestBirdAgent sharedInstance] removeCustomKey:@(key)];
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    android_callArtisanSdkMethod(ARTISAN_DELETE_CUSTOM_KEY,
                                 ARTISAN_DELETE_CUSTOM_KEY_SIG, key, NULL);
#endif
}
void CrashReporter::clearCustomKeys() {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    [[TestBirdAgent sharedInstance] clearCustomKeys];
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    android_callArtisanSdkMethod(ARTISAN_CLEAR_CUSTOM_KEY,
                                 ARTISAN_CLEAR_CUSTOM_KEY_SIG, NULL);
#endif
}
TB_NS_END
