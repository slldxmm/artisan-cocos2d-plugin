# TestBird 崩溃分析(Artisan) Cocos Plugin 使用指南

TestBird崩溃分析，[SDK全面开源](https://github.com/TheTestBird)，**请放心使用！**

TestBird Cocos Plugin 为Cocos 提供访问TestBird 崩溃分析SDK 的一系列接口，
并提供Lua/Javascript 的异常捕捉上报功能。

**要使用Cocos Plugin 需要集成TestBird 崩溃分析SDK。**[SDK及Plugin下载](http://docs.testbird.com/guide/crashanalysis/sdk-download/)

## 一、添加Cocos Plugin

### 1.1 将TestBird 目录拷贝到external 目录下
Cocos 项目引用Cocos 的模式一般有两种，external 的位置有所不同：

* *源码模式*：external 目录位于工程目录下的 frameworks/cocos2d-x
* *静态库模式*：external 目录位于cocos 源码目录下

### 1.2 为Android 项目添加Cocos Plugin
用文本编辑器打开以下文件：

	frameworks/runtime-src/proj.android/jni/Android.mk

在文件中添加引用Cocos Plugin

* 在`include $(BUILD_SHARED_LIBRARY)`之前添加：

		LOCAL_STATIC_LIBRARIES += testbird_artisan_cocos
		# 根据项目的语言（lua/javascript）选择以下两行之一
		LOCAL_STATIC_LIBRARIES += testbird_artisan_cocos_lua
		LOCAL_STATIC_LIBRARIES += testbird_artisan_cocos_js

* 在`include $(BUILD_SHARED_LIBRARY)`之后添加：

		$(call import-module,external/TestBird/CrashReporter)
		# 根据项目的语言（lua/javascript）选择以下两行之一
		$(call import-module,external/TestBird/lua-binding)
		$(call import-module,external/TestBird/js-binding)

如下图：

![](images/edit-mk.png)

### 1.3 为iOS 项目添加Cocos Plugin
*  用Xcode 打开iOS 工程 `frameworks/runtime-src/proj.ios_mac/YouAppName.xcodeproj`
*  将CrashReport 添加到iOS 工程，如下图：

    ![](images/add-crashreporter.png)

*  添加lua-binding 或者 js-binding 到iOS 工程

    根据引用Cocos 的不同模式，需要不同的添加方法：

    -   源码模式，将lua-binding 或者 js-binding 添加到cocos2d_lua_bindings 或者cocos2d_js_bindings 子工程

        ![](images/add-lua-binding.png)

    -   静态库模式，将lua-binding 或者 js-binding 直接添加到iOS工程

        ![](images/add-lua-binding2.png)

## 二、启用TestBird Cocos Plugin
启动Cocos Plugin需要在`AppDelegate.cpp`中添加以下内容：

*  首先在 `frameworks/runtime-src/Classes/AppDelegate.cpp` 添加头文件引用：
		
		#include "TestBird/CrashReporter/CrashReporter.h"
    	// Lua 工程还需要添加:
        #include "TestBird/lua-binding/LuaExceptionHandler.h"    
    	// Javascript 工程还需要添加:    
    	#include "TestBird/js-binding/JSExceptionHandler.h"
    
*  在 `bool AppDelegate::applicationDidFinishLaunching()` 函数中初始化Cocos Plugin
    
    	TestBird::CrashReporter::enableDebug(true);
    	#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    	TestBird::CrashReporter::initWithAppKey("YourAppKey", NULL);
    	#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    	TestBird::CrashReporter::initWithAppKey("YourAppKey", "Channel");
    	#endif
    
*  在初始化Cocos Plugin 之后注册 Lua/Javascript 函数

    	// Lua：
    	TestBird::LuaExceptionHandler::registerLuaExceptionHandler();
    	// Javascript:
    	sc->addRegisterCallback(TestBird::JSExceptionHandler::registerJSExceptionHandler);

*  在Lua脚本中定义异常处理函数(Javascript 工程可略过)

    在`src/main.lua` 文件中添加如下代码：

    **需要在 xpcall 之前添加**
    
    	__G__TRACKBACK__ = function(msg)
        	TestBirdOnLuaException(tostring(msg), debug.traceback())
        	return msg
    	end
    	
## 三、API说明

### 3.1 上报被捕获的异常    

    // Javascript:
    function TestBirdReportCaughtException(name, reason, stack)
    
    // Lua:
    function TestBirdReportCaughtException(message, stack)

Javascript示例：

    try {
        // some error here
    } catch (err) {
        TestBirdReportCaughtException(err.name, err.message, err.stack)
    }
    
Lua示例：
    
    TestBirdReportCaughtException("custom exception", "")

### 3.2 设置用户标识
  
    function TestBirdSetUserId(userid)

### 3.3 添加一条自定义log

    function TestBirdAddCustomLog(log)

### 3.4 自定义键值对参数
#### 添加一条自定义键值对纪录

    function TestBirdSetCustomKey(key, value)

#### 移除一条自定义键值对纪录   

    function TestBirdRemoveCustomKey(key)

#### 清除所有自定义键值对纪录

    function TestBirdRemoveCustomKey()
