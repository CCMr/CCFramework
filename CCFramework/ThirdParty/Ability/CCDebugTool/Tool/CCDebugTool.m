//
//  CCDebugTool.m
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

#import "CCDebugTool.h"
#import "CCTabBarController.h"
#import "CCDebugCrashViewController.h"
#import "CCDebugHttpViewController.h"
#import "CCDebugLogViewController.h"
#import "CCDebugMemoryHelper.h"
#import "CCDebugHttpProtocol.h"
#import "CCDebugCrashHelper.h"
#import "Config.h"

@interface CCDebugWindow : UIWindow

@end

@implementation CCDebugWindow

- (void)becomeKeyWindow
{
    //uisheetview
    [[[UIApplication sharedApplication].delegate window] makeKeyWindow];
}

@end


@interface CCDebugTool ()

@property(nonatomic, weak) CCTabBarController *debugTabBar;
@property(nonatomic, strong) CCDebugWindow *debugWindow;

@property(nonatomic, strong) UIButton *debugButton;
@property(nonatomic, strong) NSTimer *debugTimer;

@end

@implementation CCDebugTool

+ (instancetype)manager
{
    static CCDebugTool *tool;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        tool = [[CCDebugTool alloc] init];
    });
    return tool;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.mainColor = cc_ColorRGB(245, 116, 91);
        self.maxCrashCount = 20;
        self.maxLogsCount = 50;
        self.debugWindow = [[CCDebugWindow alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
    }
    return self;
}

/**
 *  @author CC, 16-03-05
 *
 *  @brief 状态栏显示Debug按钮
 */
- (void)showOnStatusBar
{
    self.debugWindow.windowLevel = UIWindowLevelStatusBar + 1;
    self.debugWindow.hidden = NO;

    self.debugButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 2, 91, 18)];
    self.debugButton.backgroundColor = self.mainColor;
    self.debugButton.layer.cornerRadius = 3;
    self.debugButton.titleLabel.font = [UIFont systemFontOfSize:10];
    [self.debugButton setTitle:@"Debug Starting" forState:UIControlStateNormal];
    [self.debugButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.debugButton addTarget:self action:@selector(showDebug) forControlEvents:UIControlEventTouchUpInside];
    [self.debugWindow addSubview:self.debugButton];

    self.debugTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerMonitor) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.debugTimer forMode:NSDefaultRunLoopMode];
}


/**
 *  @author CC, 16-03-05
 *
 *  @brief 启动Debug检测
 */
- (void)enableDebugMode
{
    [NSURLProtocol registerClass:[CCDebugHttpProtocol class]];
    __weak typeof(self) wSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [wSelf showOnStatusBar];
    });
}

- (void)showDebug
{
    if (!self.debugTabBar) {
        UITabBarController *debugTabBar = [[UITabBarController alloc] init];

        UINavigationController *debugHTTPNav = [[UINavigationController alloc] initWithRootViewController:[CCDebugHttpViewController new]];
        debugHTTPNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"HTTP" image:[[UIImage imageNamed:@""] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@""] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [debugHTTPNav.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor],NSFontAttributeName:[UIFont systemFontOfSize:30]} forState:UIControlStateNormal];
        [debugHTTPNav.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:self.mainColor,NSFontAttributeName:[UIFont systemFontOfSize:30]} forState:UIControlStateSelected];

        
        UINavigationController *debugCrashNav =  [[UINavigationController alloc] initWithRootViewController: [CCDebugCrashViewController new]]; 
        debugCrashNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Crash" image:[[UIImage imageNamed:@""] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@""] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [debugCrashNav.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor],NSFontAttributeName:[UIFont systemFontOfSize:30]} forState:UIControlStateNormal];
        [debugCrashNav.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:self.mainColor,NSFontAttributeName:[UIFont systemFontOfSize:30]} forState:UIControlStateSelected];

        UINavigationController *debugLOGNav = [[UINavigationController alloc] initWithRootViewController:[CCDebugLogViewController new]];
        debugLOGNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"LOG" image:[[UIImage imageNamed:@""] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@""] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [debugLOGNav.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor],NSFontAttributeName:[UIFont systemFontOfSize:30]} forState:UIControlStateNormal];
        [debugLOGNav.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:self.mainColor,NSFontAttributeName:[UIFont systemFontOfSize:30]} forState:UIControlStateSelected];

        debugTabBar.viewControllers = [NSArray arrayWithObjects:debugHTTPNav, debugCrashNav, debugLOGNav, nil];
        self.debugTabBar = debugTabBar;

        UIViewController *rootViewController = [[[UIApplication sharedApplication].delegate window] rootViewController];
        UIViewController *presentedViewController = rootViewController.presentedViewController;
        [presentedViewController ?: rootViewController presentViewController:self.debugTabBar animated:YES completion:nil];
    } else {
        [self.debugTabBar dismissViewControllerAnimated:YES completion:nil];
        self.debugTabBar = nil;
    }
}

/**
 *  @author CC, 16-03-05
 *
 *  @brief 时时刷新当前使用情况
 */
- (void)timerMonitor
{
    [self.debugButton setTitle:[NSString stringWithFormat:@"Debug（%@）", [CCDebugMemoryHelper bytesOfUsedMemory]] forState:UIControlStateNormal];
}

@end
