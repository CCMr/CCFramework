//
//  CCGraffitiBoardView.m
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

#import "CCGraffitiBoardView.h"
#import "UIButton+BUIButton.h"
#import "UIControl+BUIControl.h"
#import "config.h"
#import "CCPaintingView.h"
#import "CCBaseBrush.h"


#define BottomNavigationBarHeigth 50

@interface CCGraffitiBoardView ()

/**
 *  @author CC, 2015-12-16
 *  
 *  @brief  底部菜单导航
 */
@property(nonatomic, weak) UIScrollView *bottomNavigationBarScrollView;

/** 涂鸦板. */
@property(nonatomic, strong) IBOutlet CCPaintingView *paintingView;

@end

@implementation CCGraffitiBoardView

- (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}

- (void)InitControl
{
   
}
#pragma mark :. 属性
/**
 *  @author CC, 2015-12-16
 *  
 *  @brief  底部菜单导航
 */
- (UIScrollView *)bottomNavigationBarScrollView
{
    if (!_bottomNavigationBarScrollView) {
        UIScrollView *bottomNavigationBarScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - BottomNavigationBarHeigth, CGRectGetWidth(self.bounds), BottomNavigationBarHeigth)];
        bottomNavigationBarScrollView.showsHorizontalScrollIndicator = NO;
        bottomNavigationBarScrollView.showsVerticalScrollIndicator = NO;
        _bottomNavigationBarScrollView = bottomNavigationBarScrollView;
    }
    return _bottomNavigationBarScrollView;
}


@end
