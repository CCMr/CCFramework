//
//  UITabBar+Additional.m
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

#import "UITabBar+Additional.h"

@implementation UITabBar (Additional)

/**
 *  @author CC, 16-07-30
 *
 *  @brief 显示小红点
 *
 *  @param index 选项卡
 */
- (void)showBadgePointOnItemIndex:(NSInteger)index
{
    //移除之前的小红点
    [self removeBadgePointOnItemIndex:index];

    //新建小红点
    UIView *badgeView = [UIView new];
    badgeView.tag = 888 + index;
    badgeView.layer.cornerRadius = 5.0;		 //圆形
    badgeView.backgroundColor = [UIColor redColor]; //颜色：红色
    CGRect tabFrame = self.frame;

    //确定小红点的位置
    CGFloat percentX = (index + 0.55) / self.items.count;
    CGFloat x = ceilf(percentX * tabFrame.size.width);
    CGFloat y = ceilf(0.1 * tabFrame.size.height);
    badgeView.frame = CGRectMake(x, y, 10.0, 10.0); //圆形大小为10
    badgeView.clipsToBounds = YES;
    [self addSubview:badgeView];
}

/**
 *  @author CC, 16-07-30
 *
 *  @brief 隐藏小红点
 *
 *  @param index 选项卡
 */
- (void)hideBadgePointOnItemIndex:(NSInteger)index
{
    [self removeBadgePointOnItemIndex:index];
}

/**
 *  @author CC, 16-07-30
 *
 *  @brief 移除小红点
 *
 *  @param index 选项卡
 */
- (void)removeBadgePointOnItemIndex:(NSInteger)index
{
    for (UIView *subView in self.subviews) {
        if (subView.tag == 888+index) {
            [subView removeFromSuperview];
        }
    }
}

@end
