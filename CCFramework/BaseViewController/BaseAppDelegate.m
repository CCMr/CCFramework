//
//  BaseAppDelegate.m
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

#import "BaseAppDelegate.h"
#import "CCUncaughtExceptionHandler.h"
#import "CCSecurityStrategy.h"
#import "SmoothViewController.h"
#import "CCUserDefaultsCrash.h"
#import "NSObject+Additions.h"
#import <objc/runtime.h>
#import "CCLaunchAnimation.h"
#import "CCDebugTool.h"

#import <notify.h>
#define NotificationLock CFSTR("com.apple.springboard.lockcomplete")
#define NotificationChange CFSTR("com.apple.springboard.lockstate")
#define NotificationPwdUI CFSTR("com.apple.springboard.hasBlankedScreen")

static char OperationKey;

@interface BaseAppDelegate ()

/**
 *  @author C C, 2015-12-06
 *  
 *  @brief  是否启动极光推送
 */
@property(nonatomic, assign) BOOL isJPush;

@end

@implementation BaseAppDelegate

/**
 *  @author C C, 2015-05-30
 *
 *  @brief  程序启动事件
 *
 *  @param application   应用
 *  @param launchOptions 完成启动使用选项
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //全局crash捕获
    InstallUncaughtExceptionHandler();
   
    [self uploadCrashLog];
    
    float sysVersion = [[UIDevice currentDevice] systemVersion].floatValue;
    if (sysVersion >= 8.0) {
        UIUserNotificationType type = UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound;
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:type categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    //添加模糊效果
    //    [CCSecurityStrategy addBlurEffect];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    application.applicationIconBadgeNumber = 0;
    cc_NoticePost(kCCLockScreen, @"Lock screen");
    //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0]; // 设置app图标消息计数为0
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [application setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //移除模糊效果
    //    [CCSecurityStrategy removeBlurEffect];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application
  supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskAll;
}

//首先在 application:didFinishLaunchingWithOptions: 中设置 minimun background fetch interval 类型为 UIApplicationBackgroundFetchIntervalMinimum（默认为 UIApplicationBackgroundFetchIntervalNever），然后实现代理方法 application:performFetchWithCompletionHandler: 中实现数据请求。
//[application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
}

/**
 *  @author CC, 15-08-21
 *
 *  @brief  引导页
 */
- (void)initGuidePages:(NSArray *)imageStrAry
  EnterBackgroundImage:(NSString *)backgroundImage
             EnterSzie:(CGSize)size
{
    [self initGuidePages:imageStrAry
    EnterBackgroundImage:backgroundImage
               EnterSzie:size
              FirstStart:nil];
}

/**
 *  @author CC, 16-1-4
 *
 *  @brief  引导页
 */
- (void)initGuidePages:(NSArray *)imageStrAry
  EnterBackgroundImage:(NSString *)backgroundImage
             EnterSzie:(CGSize)size
            FirstStart:(void (^)())firstStartBlock
{
    [self initGuidePages:imageStrAry
    EnterBackgroundImage:backgroundImage
               EnterSzie:size
              FirstStart:nil
                 EndBack:nil];
}

/**
 *  @author CC, 2015-11-13
 *  
 *  @brief  引导页
 *
 *  @param imageStrAry     引导页图片集合
 *  @param backgroundImage 完成万纽背景图片
 *  @param size            图片大小
 *  @param firstStartBlock 第一次启动调用
 *  @param endBack         回调事件
 */
- (void)initGuidePages:(NSArray *)imageStrAry
  EnterBackgroundImage:(NSString *)backgroundImage
             EnterSzie:(CGSize)size
            FirstStart:(void (^)())firstStartBlock
               EndBack:(void (^)())endBack
{
    BOOL canShow = [SmoothViewController canShowNewFeature];
    if (canShow) {
        SmoothViewController *viewController = [[SmoothViewController alloc] initWithCoverImageNames:imageStrAry];
        viewController.enterBackgroundImage = backgroundImage;
        viewController.enterSzie = size;
        [viewController didSelectedEnter:^(id request) {
            
            if (endBack)
                endBack();
            
            [self startViewController];
        }];
        self.window.rootViewController = viewController;
        
        if (firstStartBlock)
            firstStartBlock();
    } else {
        [self startViewController];
    }
}

/**
 *  @author CC, 15-08-21
 *
 *  @brief  启动进入主窗口
 *
 *  @since 1.0
 */
- (void)startViewController
{
}

/**
 *  @author C C, 15-08-18
 *
 *  @brief  修改导航栏颜色
 */
- (void)NavigationBarColor:(UIColor *)color
{
    if (CURRENT_SYS_VERSION >= 7.0) {
        [[UINavigationBar appearance] setBarTintColor:color];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setBackIndicatorImage:CCResourceImage(@"returns")];
        [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:CCResourceImage(@"returns")];
        [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-3, 0) forBarMetrics:UIBarMetricsDefault];
    } else {
        [[UINavigationBar appearance] setTintColor:color];
    }
    
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor whiteColor], NSForegroundColorAttributeName, [UIFont boldSystemFontOfSize:19], NSFontAttributeName, nil]];
}

/**
 *  @author CC, 16-02-29
 *  
 *  @brief 设置返回按钮图片
 *
 *  @param backImage 返回图片
 */
- (void)setNavigationBarBackImage:(UIImage *)backImage
{
    if (backImage) {
        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[backImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backImage.size.width, 0, 0)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, 0) forBarMetrics:UIBarMetricsDefault];
    }
}

/**
 *  @author C C, 2015-07-30
 *
 *  @brief  动画消失启动页
 */
- (void)AnimationStartPage
{
    [CCLaunchAnimation animationWithWindow:self.window];
}

/**
 *  @author CC, 16-06-07
 *  
 *  @brief  初始化调试模式
 */
- (void)initEnableDebugMode
{
#if DEBUG
    [[CCDebugTool manager] enableDebugMode];
#endif
}

/**
 *  @author C C, 2015-07-30
 *
 *  @brief  上传奔溃日志
 *
 *  @since 1.0
 */
- (void)uploadCrashLog
{
    //    BOOL isCrash = [CCUserDefaultsCrash sharedlnstance].isCrash;
    //    if (isCrash) {// 调用接口反馈错误日志
    //        [CCUserDefaultsCrash sharedlnstance].isCrash = !isCrash;
    //
    //        NSMutableDictionary *dic = [CCUserDefaultsCrash sharedlnstance].crashDic;
    //        for (NSDate *date in dic.allKeys) {
    //            NSMutableDictionary *sendDic = [NSMutableDictionary dictionary];
    //            [sendDic setObject:date forKey:@"ErrDate"];
    //            [sendDic setObject:[dic objectForKey:date] forKey:@"ErrMsg"];
    //            [sendDic setObject:[CCUserDefaultsUserinfo manager].userName forKey:@"ErrName"];
    //            [sendDic setObject:@"4" forKey:@"ErrType"];
    //            [[CCHTTPRequest sharedlnstance] sendError:sendDic responseBlock:^(id responseData, BOOL isError) {
    //                if (!isError) {
    //                    NSLog(@"%@",responseData);
    //                }
    //            }];
    //        }
    //
    //        [dic removeAllObjects];
    //        [CCUserDefaultsCrash sharedlnstance].crashDic = dic;
    //
    //    }
}

/**
 *  @author CC, 15-09-22
 *
 *  @brief  重复执行函数
 *
 *  @param delay    相隔多少秒
 *  @param function 执行函数
 */
- (void)repeatExecutionWithafterDelay:(NSTimeInterval)delay
                    ExecutionFunction:(void (^)())function
{
    NSMutableDictionary *opreations = (NSMutableDictionary *)objc_getAssociatedObject(self, &OperationKey);
    if (!opreations) {
        opreations = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &OperationKey, opreations, OBJC_ASSOCIATION_RETAIN);
        [opreations setObject:function forKey:@"RepeatExecutionWithafterDelay"];
        [opreations setObject:@(delay) forKey:@"delay"];
    }
    
    void (^block)() = [opreations objectForKey:@"RepeatExecutionWithafterDelay"];
    int delays = [[opreations objectForKey:@"delay"] intValue];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(repeatExecutionWithafterDelay:ExecutionFunction:) object:nil];
    block();
    [self performSelector:@selector(repeatExecutionWithafterDelay:ExecutionFunction:) withObject:[NSArray arrayWithObjects:@(delays), function, nil] afterDelay:delays];
}

/**
 使用系统自带推送
 
 @param application 
 */
- (void)initOwnService:(UIApplication *)application
{
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) { //IOS8
        //创建UIUserNotificationSettings，并设置消息的显示类类型
        UIUserNotificationSettings *notSettings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound)categories:nil];
        [application registerUserNotificationSettings:notSettings];
    } else { //IOS7
        [application registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound)];
    }
}

// 设备是否锁屏
static void screenLockStateChanged(CFNotificationCenterRef center,void* observer,CFStringRef name,const void* object,CFDictionaryRef userInfo){
    NSString* lockstate = (__bridge NSString*)name;
    if ([lockstate isEqualToString:(__bridge  NSString*)NotificationLock]) {
        cc_NoticePost(kCCLockScreen, @"Lock screen");
    }else if ([lockstate isEqualToString:(__bridge  NSString*)NotificationChange]){
        cc_NoticePost(kCCLockScreen, @"State change");
    }
}


/**
 监听锁屏
 */
-(void)monitorLockScreen
{
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, screenLockStateChanged, NotificationLock, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, screenLockStateChanged, NotificationChange, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}

#pragma mark - 推送
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{

}

/**
 *  @author C C, 2015-07-30
 *
 *  @brief  通知错误日志
 *
 *  @param application 应用
 *  @param error       错误日志
 *
 *  @since 1.0
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

// Called when your app has been activated by the user selecting an action from
// a local notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
}

// Called when your app has been activated by the user selecting an action from
// a remote notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler
{
}
#endif

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{

}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{

}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{

}
@end
