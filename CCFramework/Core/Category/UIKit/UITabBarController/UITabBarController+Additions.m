//
//  UITabBarController+Additions.m
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

#import "UITabBarController+Additions.h"

@implementation UITabBarController (Additions)

/**
 *  @author CC, 2015-10-09
 *
 *  @brief  设置切换选项卡并跳转页面
 *
 *  @param selectedIndex  选项卡下标
 *  @param viewController 跳转的页面
 *  @param animated       是否动画效果
 */
- (void)setSelectedIndex:(NSUInteger)selectedIndex
      PushViewController:(UIViewController *)viewController
                animated:(BOOL)animated
{
    [self setSelectedIndex:selectedIndex
        PushViewController:viewController
                 backTitle:nil
                  animated:animated];
}

/**
 设置切换选项卡并跳转页面与返回标题
 
 @param selectedIndex 选项卡下标
 @param viewController 跳转页面
 @param title 返回按钮标题
 @param animated 是否显示动画效果
 */
- (void)setSelectedIndex:(NSUInteger)selectedIndex
      PushViewController:(UIViewController *)viewController
               backTitle:(NSString *)title
                animated:(BOOL)animated
{
    [self setSelectedIndex:selectedIndex];
    UINavigationController *selectedNavigationController = [self.viewControllers objectAtIndex:selectedIndex];
    [selectedNavigationController popToRootViewControllerAnimated:NO];
    if (selectedNavigationController) {
        if (title)
            selectedNavigationController.topViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:nil];
        
        [selectedNavigationController pushViewController:viewController animated:animated];
    }
}

/**
 *  @author CC, 2016-01-25
 *  
 *  @brief 返回当前根目录跳转页面
 *
 *  @param viewController 跳转页面
 *  @param animated       动画效果
 */
- (void)popToRootWithPushViewConroller:(UIViewController *)viewController
                              animated:(BOOL)animated
{
    UINavigationController *selectedNavigationController = [self.viewControllers objectAtIndex:self.selectedIndex];
    [selectedNavigationController popToRootViewControllerAnimated:NO];
    if (selectedNavigationController) {
        [selectedNavigationController pushViewController:viewController
                                                animated:animated];
    }
}

@end
