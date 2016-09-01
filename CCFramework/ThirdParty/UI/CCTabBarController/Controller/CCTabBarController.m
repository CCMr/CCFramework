//
//  CCTabBarController.m
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

#import "CCTabBarController.h"
#import "CCTabBar.h"
#import "CCTabBarItem.h"

@interface CCTabBarController () <CCTabBarDelegate>

@property(nonatomic, strong) CCTabBar *lcTabBar;

@end

@implementation CCTabBarController

#pragma mark -

- (UIColor *)itemTitleColor
{
    if (!_itemTitleColor)
        _itemTitleColor = [UIColor lightGrayColor];
    return _itemTitleColor;
}

- (UIColor *)selectedItemTitleColor
{
    if (!_selectedItemTitleColor)
        _selectedItemTitleColor = [UIColor blueColor];
    return _selectedItemTitleColor;
}

- (UIFont *)itemTitleFont
{
    if (!_itemTitleFont)
        _itemTitleFont = [UIFont systemFontOfSize:10.0f];
    return _itemTitleFont;
}

- (UIFont *)badgeTitleFont
{
    if (!_badgeTitleFont)
        _badgeTitleFont = [UIFont systemFontOfSize:13.0f];
    return _badgeTitleFont;
}

#pragma mark -

- (void)loadView
{
    [super loadView];
    self.itemImageRatio = 0.70f;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tabBar addSubview:({
        CCTabBar *tabBar = [[CCTabBar alloc] init];
        tabBar.frame     = self.tabBar.bounds;
        tabBar.delegate  = self;

        self.lcTabBar = tabBar;
    })];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self removeOriginControls];
}

- (void)removeOriginControls
{
    [self.tabBar.subviews enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIControl class]])
            [obj removeFromSuperview];
    }];
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    self.lcTabBar.badgeTitleFont = self.badgeTitleFont;
    self.lcTabBar.itemTitleFont = self.itemTitleFont;
    self.lcTabBar.itemImageRatio = self.itemImageRatio;
    self.lcTabBar.itemTitleColor = self.itemTitleColor;
    self.lcTabBar.selectedItemTitleColor = self.selectedItemTitleColor;

    self.lcTabBar.tabBarItemCount = viewControllers.count;

    [viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

        UIViewController *VC = (UIViewController *)obj;

        UIImage *selectedImage = VC.tabBarItem.selectedImage;
        VC.tabBarItem.selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

        [self addChildViewController:VC];

        [self.lcTabBar addTabBarItem:VC.tabBarItem];
    }];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [super setSelectedIndex:selectedIndex];

    self.lcTabBar.selectedItem.selected = NO;
    self.lcTabBar.selectedItem = self.lcTabBar.tabBarItems[selectedIndex];
    self.lcTabBar.selectedItem.selected = YES;
}

#pragma mark - XXTabBarDelegate Method

- (void)tabBar:(CCTabBar *)tabBarView didSelectedItemFrom:(NSInteger)from to:(NSInteger)to
{
    self.selectedIndex = to;
}

@end
