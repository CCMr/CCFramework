//
//  BaseAppDelegate.m
//  CC
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
#import "UIColor+BUIColor.h"
#import <objc/runtime.h>

static char OperationKey;

@implementation BaseAppDelegate

/**
 *  @author C C, 2015-05-30 17:05:31
 *
 *  @brief  程序启动事件
 *
 *  @param application   <#application description#>
 *  @param launchOptions <#launchOptions description#>
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //全局crash捕获
    InstallUncaughtExceptionHandler();

    [self uploadCrashLog];

    _BarTintColor = [UIColor colorFromHexCode:@"3b3f4d"];
    [self NavigationBarColor];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    //添加模糊效果
    //    [CCSecurityStrategy addBlurEffect];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];// 设置app图标消息计数为0
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //移除模糊效果
    //    [CCSecurityStrategy removeBlurEffect];

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
 *
 *  @since <#1.0#>
 */
- (void)initguidePages: (NSArray *)imageStrAry
  EnterBackgroundImage: (NSString *)backgroundImage
             EnterSzie: (CGSize)size
{
    BOOL canShow = [SmoothViewController canShowNewFeature];
    if (canShow) {
        SmoothViewController *viewController = [[SmoothViewController alloc] initWithCoverImageNames:imageStrAry];
        viewController.enterBackgroundImage = backgroundImage;
        viewController.enterSzie = size;
        [viewController didSelectedEnter:^(id request) {
            [self startViewController];
        }];
        self.window.rootViewController = viewController;
    }else{
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
- (void) startViewController
{

}

/**
 *  @author C C, 15-08-18
 *
 *  @brief  修改导航栏颜色
 *
 *  @since <#1.0#>
 */
- (void)NavigationBarColor
{
    if (CURRENT_SYS_VERSION >= 7.0) {
        [[UINavigationBar appearance] setBarTintColor:_BarTintColor];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    } else {
        [[UINavigationBar appearance] setTintColor:_BarTintColor];
    }


    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor whiteColor], NSForegroundColorAttributeName, [UIFont boldSystemFontOfSize:17], NSFontAttributeName, nil]];
}

/**
 *  @author C C, 2015-07-30
 *
 *  @brief  动画消失启动页
 *
 *  @since 1.0
 */
- (void)AnimationStartPage
{
    if ([SmoothViewController canShowNewFeature]) {
        UIView *splashScreen = self.window.rootViewController.view;
        [UIView animateWithDuration:2.5 animations:^{
            splashScreen.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.0);
            splashScreen.alpha = 0.0;
        } completion:^(BOOL finished) {
            [splashScreen removeFromSuperview];
        }];
    }else{
        UIImageView *splashScreen = [[UIImageView alloc] initWithFrame:self.window.bounds];
        splashScreen.image = [UIImage imageNamed:@"Default-568h"];
        splashScreen.backgroundColor = [UIColor redColor];
        [self.window addSubview:splashScreen];

        [UIView animateWithDuration:2.5 animations:^{
            splashScreen.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.0);
            splashScreen.alpha = 0.0;
        } completion:^(BOOL finished) {
            [splashScreen removeFromSuperview];
        }];
    }
}

/**
 *  @author C C, 2015-07-30
 *
 *  @brief  上传奔溃日志
 *
 *  @since 1.0
 */
- (void)uploadCrashLog{
    //    BOOL isCrash = [CCUserDefaultsCrash sharedlnstance].isCrash;
    //    if (isCrash) {// 调用接口反馈错误日志
    //        [CCUserDefaultsCrash sharedlnstance].isCrash = !isCrash;
    //
    //        NSMutableDictionary *dic = [CCUserDefaultsCrash sharedlnstance].crashDic;
    //        for (NSDate *date in dic.allKeys) {
    //            NSMutableDictionary *sendDic = [NSMutableDictionary dictionary];
    //            [sendDic setObject:date forKey:@"ErrDate"];
    //            [sendDic setObject:[dic objectForKey:date] forKey:@"ErrMsg"];
    //            [sendDic setObject:[CCUserDefaultsUserinfo sharedlnstance].userName forKey:@"ErrName"];
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
- (void)repeatExecutionWithafterDelay: (NSTimeInterval)delay ExecutionFunction: (void (^)())function
{
    NSMutableDictionary *opreations = (NSMutableDictionary *)objc_getAssociatedObject(self, &OperationKey);
    if(!opreations){
        opreations = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &OperationKey, opreations, OBJC_ASSOCIATION_RETAIN);
        [opreations setObject:function forKey:@"RepeatExecutionWithafterDelay"];
        [opreations setObject:@(delay) forKey:@"delay"];
    }
    
    void(^block)() = [opreations objectForKey:@"RepeatExecutionWithafterDelay"];
    int delays = [[opreations objectForKey:@"delay"] intValue];

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(repeatExecutionWithafterDelay:ExecutionFunction:) object:nil];
    block();
    [self performSelector:@selector(repeatExecutionWithafterDelay:ExecutionFunction:) withObject:[NSArray arrayWithObjects:@(delays),function, nil] afterDelay:delays];
}

/**
 *  @author C C, 2015-07-30
 *
 *  @brief  初始化极光推送
 *
 *  @param launchOptions <#launchOptions description#>
 *
 *  @since 1.0
 */
- (void)initAPService:(NSDictionary *)launchOptions
{
    //极光通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setTagsAlias:) name:@"setTagsAlias" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetTags) name:@"resetTags" object:nil];
    //    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert) categories:nil];
    //    [APService setupWithOption:launchOptions];
}

/**
 *  @author CC, 15-08-31
 *
 *  @brief  使用系统自带推送
 *
 *  @param application <#application description#>
 *
 *  @since <#1.0#>
 */
-(void)initOwnService: (UIApplication *)application
{
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    { //IOS8
        //创建UIUserNotificationSettings，并设置消息的显示类类型
        UIUserNotificationSettings *notSettings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound) categories:nil];
        [application registerUserNotificationSettings:notSettings];
    }
    else
    {//IOS7
        [application registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound)];
    }
}

#pragma mark - 推送
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //注册deviceToken
    //    [APService registerDeviceToken:deviceToken];

}

/**
 *  @author C C, 2015-07-30
 *
 *  @brief  通知错误日志
 *
 *  @param application <#application description#>
 *  @param error       <#error description#>
 *
 *  @since 1.0
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
}

// Called when your app has been activated by the user selecting an action from
// a local notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification  completionHandler:(void (^)())completionHandler {
}

// Called when your app has been activated by the user selecting an action from
// a remote notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
}
#endif

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //    [APService handleRemoteNotification:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PushNotifications" object:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    //    [APService handleRemoteNotification:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PushNotifications" object:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    //    [APService showLocalNotificationAtFront:notification identifierKey:nil];
}

/**
 *  @author C C, 2015-07-30
 *
 *  @brief  设置极光别名与标签
 *
 *  @param puthDic <#puthDic description#>
 *
 *  @since 1.0
 */
-(void)setTagsAlias:(NSNotification *)puthDic{
    //    NSDictionary *dic = (NSDictionary *)puthDic.object;
    __autoreleasing NSMutableSet *tags = [NSMutableSet set];
    //    [tags addObject:[NSString stringWithFormat:@"%@%@",KTSafeString(tipflag),[deviceUID stringByReplacingOccurrencesOfString:@"-" withString:@""]]];
    __autoreleasing NSString *alias = @"1";
    [self analyseInput:&alias tags:&tags];
    //    NSString *_alias = [NSString stringWithFormat:@"%@%@",KTSafeString(tipflag),[dic objectForKey:@"tag1"]];
    //[APService setAlias:_alias callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:self];
    //[APService setTags:tags callbackSelector:nil object:nil];

    //    [APService setTags:tags alias:_alias callbackSelector:@selector(tagsAliasCallback:tags:alias:) target:self];

}

/**
 *  @author C C, 2015-07-30
 *
 *  @brief  注销极光的别名与标签
 *
 *  @since 1.0
 */
-(void)resetTags{
    //    [APService setTags:[NSSet set] callbackSelector:nil object:nil];
    //    [APService setAlias:@"" callbackSelector:nil object:nil];
}

- (void)analyseInput:(NSString **)alias tags:(NSSet **)tags {
    // alias analyse
    if (![*alias length]) {
        // ignore alias
        *alias = nil;
    }
    // tags analyse
    if (![*tags count]) {
        *tags = nil;
    } else {
        __block int emptyStringCount = 0;
        [*tags enumerateObjectsUsingBlock:^(NSString *tag, BOOL *stop) {
            if ([tag isEqualToString:@""]) {
                emptyStringCount++;
            } else {
                emptyStringCount = 0;
                *stop = YES;
            }
        }];
        if (emptyStringCount == [*tags count]) {
            *tags = nil;
        }
    }
}

@end
