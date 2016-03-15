//
//  CCProperty.h
//  CCFramework
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

#ifndef CCProperty_h
#define CCProperty_h
#import <UIKit/UIDevice.h>

#define Bundle                              [NSBundle mainBundle]

/** 资源文件 */
#define cc_Resource(bundleName,Extaension)  [NSBundle bundleWithURL:[Bundle URLForResource:bundleName withExtension:Extaension]]

/** 资源图片 */
#define CCResourceImage(name)               (cc_Resource(@"CCFramework",@"bundle") ? [UIImage imageWithContentsOfFile:[[cc_Resource(@"CCFramework",@"bundle") resourcePath] stringByAppendingPathComponent:name]] : nil)

/** 版本号 */
#define VersonNumber                        [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey]

/** 应用名称 */
#define AppName                             [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey]

/** 设备编号 */
#define deviceUID                           [[[UIDevice currentDevice] identifierForVendor] UUIDString]

/** 设备类型 */
#define deviceType                          [[UIDevice currentDevice] model];
#define iOS7Later                           (CURRENT_SYS_VERSION >= 7.0f)
#define iOS8Later                           (CURRENT_SYS_VERSION >= 8.0f)
#define iOS9Later                           (CURRENT_SYS_VERSION >= 9.0f)

/** 设备版本号 */
#define CURRENT_SYS_VERSION                 [[[UIDevice currentDevice] systemVersion] floatValue]

/** 获取缓存 */
#define userDefaults                        [NSUserDefaults standardUserDefaults]

/** 应用委托 */
#define ApplicationDelegate                 [[UIApplication sharedApplication] delegate]
#define SharedApplication                   [UIApplication sharedApplication]
#define StatusBarHeight                     [UIApplication sharedApplication].statusBarFrame.size.height

/** 设置网络活动指示灯 */
#define ShowNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define HideNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO
#define NetworkActivityIndicatorVisible(x)  [UIApplication sharedApplication].networkActivityIndicatorVisible = x

/** 导航栏 */
#define SelfNavBar                          self.navigationController.navigationBar
#define SelfNavBarHeight                    self.navigationController.navigationBar.bounds.size.height
#define SelfDefaultToolbarHeight            self.navigationController.navigationBar.frame.size.height

/** 底部导航 */
#define SelfTabBar                          self.tabBarController.tabBar
#define SelfTabBarHeight                    self.tabBarController.tabBar.bounds.size.height

/** 主屏幕 */
#define MainScreen                          [UIScreen mainScreen]

/** 屏幕高宽 */
#define ScreenRect                          [[UIScreen mainScreen] bounds]

/** 屏幕大小 */
#define winsize                             [[UIScreen mainScreen] bounds].size

#pragma mark-
#pragma mark :. 常用

#define cc_NilOrNull(__ref) (((__ref) == nil) || ([(__ref) isEqual:[NSNull null]]))

#define cc_Font(__fontSize) [UIFont systemFontOfSize:__fontSize]
#define cc_BFont(__fontSize) [UIFont boldSystemFontOfSize:__fontSize]

/** 设置颜色RGB */
#define cc_ColorRGB(r, g, b)                [UIColor colorWithRed:(r) / 255.f green:(g) / 255.f blue:(b) / 255.f alpha:1.f]
#define cc_ColorRGBA(r, g, b, a)            [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a]

/** RGB颜色转换（16进制->10进制）*/
#define cc_ColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
                green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
                 blue:((float)(rgbValue & 0xFF)) / 255.0\
                alpha:1.0]

/** 字符串判断 */
#define cc_SafeString(str)                   (str == nil ? @"" : str)//判断字符串
#define cc_ServiceString(str)                ([str isKindOfClass:[NSNull class]] ? @"" : str)

/** 字符串拼接 */
#define cc_Format(__format, ...)             [NSString stringWithFormat:__format, ##__VA_ARGS__]
#define cc_FormatObj(__obj)                  [NSString stringWithFormat:@"%@", __obj]
#define cc_FormatInteger(__integer)          [NSString stringWithFormat:@"%zi", __integer]
#define cc_FormatFloat(__float)              [NSString stringWithFormat:@"%lf", __float]
#define cc_Predicate(__format, ...)          [NSPredicate predicateWithFormat:__format, ##__VA_ARGS__]

/** 图片调整 */
#define cc_Stretch_Image(image, edgeInsets) \
(CURRENT_SYS_VERSION < 6.0 ? [image stretchableImageWithLeftCapWidth:edgeInsets.left topCapHeight:edgeInsets.top] :\
                             [image resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch])


#define CCAssert(condition, format, ...) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wformat-extra-args\"") \
if ((condition) == NO) \
NSLog(format, ##__VA_ARGS__); \
_Pragma("clang diagnostic pop") \
} while (0);


#define cc_MainQueue(__stuff) \
if ([NSThread isMainThread]) { \
__stuff \
} else { \
dispatch_async(dispatch_get_main_queue(), ^{ \
__stuff \
}); \
}


#pragma mark-
#pragma mark :. 注册事件
/*************************  注册事件  *************************/
/** 注册通知 */
#define cc_NoticeObserver(TARGET,SELECTOR,NAME,OBJECT)  [[NSNotificationCenter defaultCenter] addObserver:TARGET selector:SELECTOR name:NAME object:OBJECT];
#define cc_NoticeremoveObserver(TARGET,NAME,OBJECT)     [[NSNotificationCenter defaultCenter] removeObserver:TARGET name:NAME object:OBJECT];
/** 发送通知 */
#define cc_NoticePost(NAME,OBJECT)                      [[NSNotificationCenter defaultCenter] postNotificationName:NAME object:OBJECT];
#define cc_NoticePostInfo(NAME,OBJECT,USERINFO)         [[NSNotificationCenter defaultCenter] postNotificationName:NAME object:OBJECT userInfo:USERINFO];

#pragma mark-
#pragma mark :. 设备
/*************************  设备  *************************/
/** 判断是否为iPhone */
#define isiPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

/** 判断是否是iPad */
#define isiPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

/** 判断是否为iPod */
#define isiPod ([[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"])

/** 判断是否 Retina屏 */
#define isRetina ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0f))

/** 设备是否为iPhone 4/4S 分辨率320x480，像素640x960，@2x */
#define iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

/** 设备是否为iPhone 5C/5/5S 分辨率320x568，像素640x1136，@2x */
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

/** 设备是否为iPhone 6 分辨率375x667，像素750x1334，@2x */
#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)

/** 设备是否为iPhone 6 Plus 分辨率414x736，像素1242x2208，@3x */
#define iPhone6P ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

#pragma mark-
#pragma mark :. 本地文档相关
/*************************  本地文档相关  *************************/

/** 定义UIImage对象 */
#define cc_ImageNamed(_pointer)                 ([UIImage imageNamed:[UIUtil imageName:_pointer]])

/** 定义UIImage对象并从本地文件读取加载图片 */
#define cc_Image(name)                          ([UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:nil]])

/** 读取本地图片 */
#define cc_LoadImage(file,ext)                  ([UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:file ofType:ext]])

/** 获取Documents目录 */
#define cc_DocumentsPath                        ([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject])

/** 获得Documents下指定文件名的文件路径 */
#define cc_FilePath(filename)                   ([[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:filename];)

/** 获取Library目录 */
#define cc_LibraryPath                          ([NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject])

/** 获取Caches目录 */
#define cc_CachesPath                           ([NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject])

/** 获取Tmp目录 */
#define cc_TmpPath                              NSTemporaryDirectory()

/** NSFileManager 实例化 */
#define cc_FileManager                          [NSFileManager defaultManager]

/** NSRunLoop 实例化 */
#define cc_MainRunLoop                          [NSRunLoop mainRunLoop]

#pragma mark -
#pragma mark :. View
/*************************  View  *************************/
/** view 圆角 */
#define cc_View_Radius(view, radius) \
[view.layer setCornerRadius:(radius)]; \
[view.layer setMasksToBounds:YES]

/** view 单个圆角 
 angle某个圆角
 * UIRectCornerTopLeft
 * UIRectCornerTopRight
 * UIRectCornerBottomLeft
 * UIRectCornerBottomRight
 * UIRectCornerAllCorners
 
 radius圆角度
 */
#define cc_View_SingleFillet(view,angle,radius)\
UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds \
                                               byRoundingCorners:angle \
                                                     cornerRadii:CGSizeMake(radius, radius)]; \
CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init]; \
maskLayer.frame = view.bounds; \
maskLayer.path = maskPath.CGPath; \
view.layer.mask = maskLayer;

/** view 圆角 边框 */
#define cc_View_Border_Radius(view, radius, width, color) \
cc_View_Radius(view, radius); \
cc_view_Border(view, width, color);

/** view 边框 */
#define cc_view_Border(view, width, color)\
[view.layer setBorderWidth:(width)]; \
[view.layer setBorderColor:[color CGColor]];

#endif /* CCProperty_h */
