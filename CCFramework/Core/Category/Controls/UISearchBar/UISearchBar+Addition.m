//
//  UISearchBar+Addition.m
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

#import "UISearchBar+Addition.h"
#import "Config.h"

@implementation UISearchBar (Addition)

/**
 *  @author CC, 2015-11-06
 *  
 *  @brief  设置取消按钮标题
 *
 *  @param title 标题
 */
- (void)setCancelTitle:(NSString *)title
{
    [self setCancelTitleWithColor:title
                            Color:nil];
}

/**
 *  @author CC, 2015-11-06
 *  
 *  @brief  设置取消按钮文字与颜色
 *
 *  @param title 标题
 *  @param color 颜色
 */
- (void)setCancelTitleWithColor:(NSString *)title
                          Color:(UIColor *)color
{
    for (UIView *v in [self.subviews lastObject].subviews) {
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton *cancelBtn = (UIButton *)v;
            cancelBtn.enabled = YES;
            [cancelBtn setTitle:title forState:UIControlStateNormal];
            if (color)
                [cancelBtn setTintColor:color];
        }
    }
}

/**
 *  @author CC, 16-02-18
 *  
 *  @brief 设置输入框背景颜色
 *
 *  @param backgroundColor 颜色
 */
- (void)setSearchTextFieldBackgroundColor:(UIColor *)backgroundColor
{
    UIView *searchTextField = nil;
    if (iOS7Later) {
        searchTextField = [[[self.subviews firstObject] subviews] lastObject];
    } else {
        for (UIView *subView in self.subviews) {
            if ([subView isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
                searchTextField = subView;
            }
        }
    }
    
    searchTextField.backgroundColor = backgroundColor;
}

@end
