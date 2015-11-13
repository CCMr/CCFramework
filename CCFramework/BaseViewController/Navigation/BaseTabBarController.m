//
//  BaseTabBarController.m
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

#import "BaseTabBarController.h"
#import "Config.h"

@interface BaseTabBarController () <UITabBarControllerDelegate>
@end

@implementation BaseTabBarController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    //    [self HideTabBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/**
 *  @author CC, 15-09-09
 *
 *  @brief  隐藏底部按钮
 *
 *  @since 1.0
 */
- (void)HideTabBar
{
    for (UIView *v in self.view.subviews) {
        if ([v isKindOfClass:[UITabBar class]]) {
            v.frame = CGRectMake(v.frame.origin.x, winsize.height, v.frame.size.width, v.frame.size.height);
        } else {
            v.frame = CGRectMake(v.frame.origin.x, v.frame.origin.y, v.frame.size.width, winsize.height);
        }
    }
}

#pragma mark - 转屏

- (BOOL)shouldAutorotate
{
    return [[self.viewControllers objectAtIndex:self.selectedIndex] shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [[self.viewControllers objectAtIndex:self.selectedIndex] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [[self.viewControllers objectAtIndex:self.selectedIndex] preferredInterfaceOrientationForPresentation];
}

@end
