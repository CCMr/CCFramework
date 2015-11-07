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
#define UIColorFromRGB(rgbValue)            [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0] // rgb颜色转换（16进制->10进制）
#define CCSafeString(str)                   (str == nil ? @"" : str)																			   //判断字符串
#define CCServiceString(str)                ([str isKindOfClass:[NSNull class]] ? @"" : str)
#define CC_STRETCH_IMAGE(image, edgeInsets) (CURRENT_SYS_VERSION < 6.0 ? [image stretchableImageWithLeftCapWidth:edgeInsets.left topCapHeight:edgeInsets.top] : [image resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch])


//设备判断
#define kIsiPad                             (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define kIs_iPhone                          (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kIs_iPhone_6                        (kIs_iPhone && winsize.height == 667.0)
#define kIs_iPhone_6P                       (kIs_iPhone && winsize.height == 736.0)


#endif /* CCProperty_h */
