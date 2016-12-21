//
//  CCHierarchySearcher.m
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

@import UIKit;
#import "CCSideMenu.h"
#import "CCDrawerController.h"
#import "CCHierarchySearcher.h"

@implementation CCHierarchySearcher

- (UIViewController *)topmostViewController
{
    return [self topmostViewControllerFrom:[[self baseWindow] rootViewController]
                              includeModal:YES];
}

- (UIViewController *)topmostNonModalViewController
{
    return [self topmostViewControllerFrom:[[self baseWindow] rootViewController]
                              includeModal:NO];
}

- (UINavigationController *)topmostNavigationController
{
    return [self topmostNavigationControllerFrom:[self topmostViewController]];
}

- (UINavigationController *)topmostNavigationControllerFrom:(UIViewController *)vc
{
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabbar = (UITabBarController *)vc;
        return (UINavigationController *)[tabbar.viewControllers objectAtIndex:tabbar.selectedIndex];
    }
    
    if ([vc isKindOfClass:[UINavigationController class]])
        return (UINavigationController *)vc;
    if ([vc navigationController])
        return [vc navigationController];
    
    if ([vc isKindOfClass:[CCSideMenu class]]) {
        UITabBarController *tabbar = (UITabBarController *)((CCSideMenu *)vc).contentViewController;
        return [self topmostNavigationControllerFrom:tabbar.selectedViewController];
    }
    
    if ([vc isKindOfClass:[CCDrawerController class]]) {
        UITabBarController *tabbar = (UITabBarController *)((CCDrawerController *)vc).centerViewController;
        return [self topmostNavigationControllerFrom:tabbar.selectedViewController];
    }
    
    
    if (vc.presentingViewController)
        return [self topmostNavigationControllerFrom:vc.presentingViewController];
    else
        return nil;
}

- (UIViewController *)topmostViewControllerFrom:(UIViewController *)viewController
                                   includeModal:(BOOL)includeModal
{
    
    if ([viewController isKindOfClass:[CCDrawerController class]]){
        UITabBarController *tabbar = (UITabBarController *)((CCDrawerController *)viewController).centerViewController; 
        return [tabbar.selectedViewController topViewController];
    }
    
    if (includeModal && viewController.presentedViewController)
        return [self topmostViewControllerFrom:viewController.presentedViewController
                                  includeModal:includeModal];
    
    if ([viewController respondsToSelector:@selector(topViewController)])
        return [self topmostViewControllerFrom:[(id)viewController topViewController]
                                  includeModal:includeModal];
    
    return viewController;
}

- (UIWindow *)baseWindow
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    if (!window)
        window = [[UIApplication sharedApplication] keyWindow];
    
    NSAssert(window != nil, @"No window to calculate hierarchy from");
    return window;
}

@end
