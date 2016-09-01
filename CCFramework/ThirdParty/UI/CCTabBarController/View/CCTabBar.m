//
//  CCTabBar.m
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

#import "CCTabBar.h"
#import "CCTabBarItem.h"

@interface CCTabBar ()

@end

@implementation CCTabBar

- (NSMutableArray *)tabBarItems
{
    if (_tabBarItems == nil)
        _tabBarItems = [[NSMutableArray alloc] init];
    return _tabBarItems;
}

- (void)addTabBarItem:(UITabBarItem *)item
{
    CCTabBarItem *tabBarItem = [[CCTabBarItem alloc] initWithItemImageRatio:self.itemImageRatio];

    tabBarItem.badgeTitleFont = self.badgeTitleFont;
    tabBarItem.itemTitleFont = self.itemTitleFont;
    tabBarItem.itemTitleColor = self.itemTitleColor;
    tabBarItem.selectedItemTitleColor = self.selectedItemTitleColor;

    tabBarItem.tabBarItemCount = self.tabBarItemCount;

    tabBarItem.tabBarItem = item;

    [tabBarItem addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];

    [self addSubview:tabBarItem];

    [self.tabBarItems addObject:tabBarItem];

    if (self.tabBarItems.count == 1)
        [self buttonClick:tabBarItem];
}

- (void)buttonClick:(CCTabBarItem *)tabBarItem
{
    if ([self.delegate respondsToSelector:@selector(tabBar:didSelectedItemFrom:to:)])
        [self.delegate tabBar:self didSelectedItemFrom:self.selectedItem.tabBarItem.tag to:tabBarItem.tag];

    self.selectedItem.selected = NO;
    self.selectedItem = tabBarItem;
    self.selectedItem.selected = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;

    int count = (int)self.tabBarItems.count;
    CGFloat itemY = 0;
    CGFloat itemW = w / self.subviews.count;
    CGFloat itemH = h;

    for (int index = 0; index < count; index++) {
        CCTabBarItem *tabBarItem = self.tabBarItems[index];
        tabBarItem.tag = index;
        CGFloat itemX = index * itemW;
        tabBarItem.frame = CGRectMake(itemX, itemY, itemW, itemH);
    }
}

@end
