//
//  BaseAppDelegate.h
//
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

#import <UIKit/UIKit.h>
#import "CCDropzone.h"
#import "CCSideMenu.h"

@interface BaseAppDelegate : UIResponder <UIApplicationDelegate>

@property(strong, nonatomic) UIWindow *window;

/**
 *  @author C C, 15-08-18
 *
 *  @brief  修改导航栏颜色
 */
- (void)NavigationBarColor:(UIColor *)color;

/**
 *  @author CC, 2015-07-30
 *
 *  @brief  动画消失启动页
 */
- (void)AnimationStartPage;

/**
 *  @author CC, 15-08-21
 *
 *  @brief  引导页
 */
- (void)initguidePages:(NSArray *)imageStrAry
  EnterBackgroundImage:(NSString *)backgroundImage
             EnterSzie:(CGSize)size;

/**
 *  @author CC, 2015-11-13
 *  
 *  @brief  引导页
 *
 *  @param imageStrAry     引导页图片集合
 *  @param backgroundImage 完成万纽背景图片
 *  @param size            图片大小
 *  @param endBack         回调事件
 */
- (void)initguidePages:(NSArray *)imageStrAry
  EnterBackgroundImage:(NSString *)backgroundImage
             EnterSzie:(CGSize)size
               EndBack:(void (^)())endBack;

/**
 *  @author CC, 15-08-21
 *
 *  @brief  启动进入主窗口
 */
- (void)startViewController;

/**
 *  @author C C, 2015-07-30
 *
 *  @brief  上传奔溃日志
 */
- (void)uploadCrashLog;

/**
 *  @author CC, 15-09-22
 *
 *  @brief  重复执行函数
 *
 *  @param delay    相隔多少秒
 *  @param function 执行函数
 */
- (void)repeatExecutionWithafterDelay:(NSTimeInterval)delay
                    ExecutionFunction:(void (^)())function;

/**
 *  @author C C, 2015-07-30
 *
 *  @brief  初始化极光推送(初始化程序使用)
 *
 *  @param launchOptions 完成启动使用选项
 *
 *  @since 1.0
 */
- (void)initAPService:(NSDictionary *)launchOptions;

@end
