//
//  Conflg.h
//  Conflg
//
// Copyright (c) 2015 CC ( http://www.ccskill.com )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#ifndef CCFramework__Config_h
#define CCFramework__Config_h

#import <CCFramework/EnumConfig.h>
#import <CCFramework/ResourcesPhotos.h>
#import <CCFramework/CCProperty.h>
#import <CCFramework/CCExtScope.h>
#import <CCFramework/CCMetamacros.h>
#import <CCFramework/CCBlockTrace.h>


#pragma mark - 定义全局回调函数
typedef void (^Completion)(id request);

/**
 *  @author CC, 15-08-20
 *
 *  @brief  检测网络状态回调
 *
 *  @param netConnetState 网络是否可用
 *
 *  @since 1.0
 */
typedef void (^NetWorkBlock)(BOOL netConnetState);


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//输出日志处理
#ifdef DEBUG
#define NSLog(...) NSLog(__VA_ARGS__)
#define debugMethod() NSLog(@"%s", __func__)
#else
#define NSLog(...)
#define debugMethod()
#endif

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - 全局变量与方法
/**
 *  @author CC, 2015-08-13
 *
 *  @brief  弱引用对象
 *
 *  @param self 当前页面对象
 *
 *  @return 弱引用定义
 *
 *  @since 1.0
 */
#define WEAKSELF typeof(self) __weak weakSelf = self

/**
 *  @author CC, 2015-08-13
 *
 *  @brief  强类型弱引用
 *
 *  @param weakSelf 弱引用对象
 *
 *  @return 强类型引用定义
 *
 *  @since 1.0
 */
#define STRONGSELF __strong __typeof(weakSelf) strongSelf = weakSelf

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Redefine
//子线程
#define ChildThread(block) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
//主线程
#define MainThread(block) dispatch_async(dispatch_get_main_queue(), block)


#endif