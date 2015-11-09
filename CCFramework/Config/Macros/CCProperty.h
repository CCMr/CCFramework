//
//  CCProperty.h
//  CCFramework
//
//  Created by CC on 15/11/7.
//  Copyright © 2015年 CC. All rights reserved.
//

#ifndef CCProperty_h
#define CCProperty_h

#define Bundle                              [NSBundle mainBundle]
#define VersonNumber                        [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey] //版本号
#define AppName                             [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey]	 //应用名称
#define deviceUID                           [[[UIDevice currentDevice] identifierForVendor] UUIDString]				   //设备编号
#define deviceType                          [[UIDevice currentDevice] model];							   //设备类型
#define IsiOS7Later                         !(CURRENT_SYS_VERSION < 7.0)
#define CURRENT_SYS_VERSION                 [[[UIDevice currentDevice] systemVersion] floatValue] //设备版本号
#define userDefaults                        [NSUserDefaults standardUserDefaults]			  //获取缓存
#define ApplicationDelegate                 [[UIApplication sharedApplication] delegate]
#define SharedApplication                   [UIApplication sharedApplication]
#define StatusBarHeight                     [UIApplication sharedApplication].statusBarFrame.size.height
#define ShowNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define HideNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO
#define NetworkActivityIndicatorVisible(x)  [UIApplication sharedApplication].networkActivityIndicatorVisible = x
#define SelfNavBar                          self.navigationController.navigationBar
#define SelfTabBar                          self.tabBarController.tabBar
#define SelfNavBarHeight                    self.navigationController.navigationBar.bounds.size.height
#define SelfTabBarHeight                    self.tabBarController.tabBar.bounds.size.height
#define SelfDefaultToolbarHeight            self.navigationController.navigationBar.frame.size.height
#define MainScreen                          [UIScreen mainScreen]
#define ScreenRect                          [[UIScreen mainScreen] bounds]
#define winsize                             [[UIScreen mainScreen] bounds].size //获取屏幕
#define winsizeWidth                        [[UIScreen mainScreen] bounds].size.width
#define winsizeHeight                       [[UIScreen mainScreen] bounds].size.height


//设置颜色RGB
#define RGB(r, g, b)                        [UIColor colorWithRed:(r) / 255.f green:(g) / 255.f blue:(b) / 255.f alpha:1.f]
#define RGBA(r, g, b, a)                    [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a]
// rgb颜色转换（16进制->10进制）
#define UIColorFromRGB(rgbValue)            [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0] 
#define CCSafeString(str)                   (str == nil ? @"" : str)//判断字符串
#define CCServiceString(str)                ([str isKindOfClass:[NSNull class]] ? @"" : str)
#define CC_STRETCH_IMAGE(image, edgeInsets) (CURRENT_SYS_VERSION < 6.0 ? [image stretchableImageWithLeftCapWidth:edgeInsets.left topCapHeight:edgeInsets.top] : [image resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch])


//设备判断
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

/*************************  本地文档相关  *************************/

/** 定义UIImage对象 */
#define kImageNamed(_pointer) ([UIImage imageNamed:[UIUtil imageName:_pointer]])

/** 定义UIImage对象并从本地文件读取加载图片 */
#define kImage(name) ([UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:nil]])

/** 读取本地图片 */
#define kLoadImage(file,ext) ([UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:file ofType:ext]])

/** 获取Documents目录 */
#define kDocumentsPath ([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject])

/** 获得Documents下指定文件名的文件路径 */
#define kFilePath(filename) ([[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:filename];)

/** 获取Library目录 */
#define kLibraryPath ([NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject])

/** 获取Caches目录 */
#define kCachesPath ([NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject])

/** 获取Tmp目录 */
#define kTmpPath NSTemporaryDirectory()

#endif /* CCProperty_h */
