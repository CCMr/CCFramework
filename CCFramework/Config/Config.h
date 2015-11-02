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

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  网络请求完成
 *
 *  @param request <#request description#>
 *
 *  @since 1.0
 */
typedef void (^RequestComplete)(id responseData);

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  错误代码块
 *
 *  @param errorCodeBlock <#errorCodeBlock description#>
 *
 *  @since 1.0
 */
typedef void (^ErrorCodeBlock)(id errorCode);

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  超时或者请求失败
 *
 *  @param failureBlock <#failureBlock description#>
 *
 *  @since 1.0
 */
typedef void (^FailureBlock)(id failure);

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  请求回调相应
 *
 *  @param responseData 相应数据
 *  @param isError      是否有错误
 *
 *  @since 1.0
 */
typedef void (^RequestBlock)(id responseData, BOOL isError);

/**
 *  @author CC, 15-08-19
 *
 *  @brief  上传下载进度回调
 *
 *  @param bytesRead                读取的字节
 *  @param totalBytesRead           总字节数学
 *  @param totalBytesExpectedToRead 读取字节数
 *
 *  @since <#1.0#>
 */
typedef void (^ProgressBlock)(NSUInteger bytesRead, long long totalBytesRead,
                              long long totalBytesExpectedToRead);

/**
 *  @author CC, 2015-10-22
 *
 *  @brief  请求完成处理回调函数
 *
 *  @param responseData 请求返回数据
 *  @param userInfo     字典接收
 */
typedef void (^CompletionCallback)(id responseData, id userInfo);

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

#define Bundle [NSBundle mainBundle]
#define VersonNumber [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey] //版本号
#define AppName [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey]	 //应用名称
#define deviceUID [[[UIDevice currentDevice] identifierForVendor] UUIDString]				   //设备编号
#define deviceType [[UIDevice currentDevice] model];							   //设备类型
#define IsiOS7Later !(CURRENT_SYS_VERSION < 7.0)
#define CURRENT_SYS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue] //设备版本号
#define userDefaults [NSUserDefaults standardUserDefaults]			  //获取缓存
#define ApplicationDelegate [[UIApplication sharedApplication] delegate]
#define SharedApplication [UIApplication sharedApplication]
#define StatusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define ShowNetworkActivityIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define HideNetworkActivityIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = NO
#define NetworkActivityIndicatorVisible(x) [UIApplication sharedApplication].networkActivityIndicatorVisible = x
#define SelfNavBar self.navigationController.navigationBar
#define SelfTabBar self.tabBarController.tabBar
#define SelfNavBarHeight self.navigationController.navigationBar.bounds.size.height
#define SelfTabBarHeight self.tabBarController.tabBar.bounds.size.height
#define SelfDefaultToolbarHeight self.navigationController.navigationBar.frame.size.height
#define MainScreen [UIScreen mainScreen]
#define ScreenRect [[UIScreen mainScreen] bounds]
#define winsize [[UIScreen mainScreen] bounds].size //获取屏幕
#define winsizeWidth [[UIScreen mainScreen] bounds].size.width
#define winsizeHeight [[UIScreen mainScreen] bounds].size.height
//设置颜色RGB
#define RGB(r, g, b) [UIColor colorWithRed:(r) / 255.f green:(g) / 255.f blue:(b) / 255.f alpha:1.f]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0] // rgb颜色转换（16进制->10进制）
#define CCSafeString(str) (str == nil ? @"" : str)																			   //判断字符串
#define CCServiceString(str) ([str isKindOfClass:[NSNull class]] ? @"" : str)
#define CC_STRETCH_IMAGE(image, edgeInsets) (CURRENT_SYS_VERSION < 6.0 ? [image stretchableImageWithLeftCapWidth:edgeInsets.left topCapHeight:edgeInsets.top] : [image resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch])
//设备判断
#define kIsiPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define kIs_iPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kIs_iPhone_6 (kIs_iPhone && winsize.height == 667.0)
#define kIs_iPhone_6P                                                          (kIs_iPhone && winsize.height == 736.0)

#define kVoiceRecorderTotalTime 60.0

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#endif