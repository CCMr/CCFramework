//
//  CCExpandHeader.m
//  CCFramework
//
// Copyright (c) 2016 CC ( http://www.ccskill.com )
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

#import "CCExpandHeader.h"

#define CExpandContentOffset @"contentOffset"

@interface CCExpandHeader () <UIScrollViewDelegate>

@property(nonatomic, strong) UIScrollView *scrollView;

@property(nonatomic, strong) UIView *expandView;

@property(nonatomic, assign) CGFloat expandHeight;

@end

@implementation CCExpandHeader

/**
 *  @author CC, 2016-01-11
 *  
 *  @brief 生成一个CCExpandHeader实例
 *
 *  @param scrollView 滑动控件
 *  @param expandView 伸展的背景View
 */
+ (id)expandWithScrollView:(UIScrollView *)scrollView
                expandView:(UIView *)expandView
{
    CCExpandHeader *expandHeader = [CCExpandHeader new];
    [expandHeader expandWithScrollView:scrollView expandView:expandView];
    return expandHeader;
}

/**
 *  @author CC, 2016-01-11
 *  
 *  @brief 扩展滑动事件
 *
 *  @param scrollView 滑动控件
 *  @param expandView 伸展的背景View  
 */
- (void)expandWithScrollView:(UIScrollView *)scrollView
                  expandView:(UIView *)expandView
{
    expandView.tag = 999;
    _expandHeight = CGRectGetHeight(expandView.frame);
    
    _scrollView = scrollView;
    [[_scrollView viewWithTag:999] removeFromSuperview];
    _scrollView.contentInset = UIEdgeInsetsMake(_expandHeight, 0, 0, 0);
    [_scrollView insertSubview:expandView atIndex:0];
    [_scrollView addObserver:self forKeyPath:CExpandContentOffset options:NSKeyValueObservingOptionNew context:nil];
    [_scrollView setContentOffset:CGPointMake(0, -_expandHeight)];
    
    _expandView = expandView;
    //使View可以伸展效果  重要属性
    _expandView.contentMode = UIViewContentModeScaleAspectFill;
    _expandView.clipsToBounds = YES;
    
    [self reSizeView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (![keyPath isEqualToString:CExpandContentOffset]) {
        return;
    }
    [self scrollViewDidScroll:_scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY < _expandHeight * -1) {
        CGRect currentFrame = _expandView.frame;
        CGFloat y = currentFrame.origin.y - offsetY;
        
        currentFrame.origin.y = offsetY;
        currentFrame.size.height = -1 * offsetY;
        _expandView.frame = currentFrame;
        
        for (UIView *childeView in _expandView.subviews) {
            currentFrame = childeView.frame;
            currentFrame.origin.y += y;
            childeView.frame = currentFrame;
        }
    }
}

- (void)reSizeView
{
    //重置_expandView位置
    [_expandView setFrame:CGRectMake(0, -1 * _expandHeight, CGRectGetWidth(_expandView.frame), _expandHeight)];
}

- (void)dealloc
{
    if (_scrollView) {
        [_scrollView removeObserver:self forKeyPath:CExpandContentOffset];
        _scrollView = nil;
    }
    _expandView = nil;
}

@end
