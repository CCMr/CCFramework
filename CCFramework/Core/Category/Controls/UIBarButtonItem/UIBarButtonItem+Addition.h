//
//  UIBarButtonItem+Addition.h
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

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Addition)

/**
 *  @author CC, 2016-12-30
 *  
 *  @brief  设置背景图片
 *
 *  @param backgroundImage 图片路径
 */
- (void)setItemImage:(NSString *)backgroundImage;

/**
 *  @author CC, 16-02-02
 *  
 *  @brief 图片按钮
 *
 *  @param iconName 图标
 *  @param target   当前页面
 *  @param action   页面回调函数
 *
 *  @return 返回当前对象
 */
+ (UIBarButtonItem *)imageWithAction:(NSString *)iconName
                              Target:(id)target
                              Action:(SEL)action;

/**
 *  @author CC, 15-09-28
 *
 *  @brief  图片按钮
 *
 *  @param backgroundImage 背景图片
 *  @param target          当前页面
 *  @param action          页面回调函数
 *
 *  @return 返回当前对象
 */
+ (UIBarButtonItem *)filletWithAction:(NSString *)backgroundImage
                     placeholderImage:(NSString *)placeholder
                               Target:(id)target
                               Action:(SEL)action;

/**
 *  @author CC, 2016-01-04
 *  
 *  @brief  图片文
 *
 *  @param title                 标题
 *  @param backgroundImage       背景图片
 *  @param onButtonTouchUpInside 回调函数
 *
 *  @return 返回当前对象
 */
+ (UIBarButtonItem *)buttonItemWithTitle:(NSString *)title
                         BackgroundImage:(NSString *)backgroundImage
                didOnButtonTouchUpInside:(void (^)(UIButton *sender))onButtonTouchUpInside;

/**
 *  @author C C, 2015-09-28
 *
 *  @brief  左图右文
 *
 *  @param backgroundImage 左图
 *  @param title           文字
 *  @param target          当前页面
 *  @param action          页面回调函数
 *
 *  @return 返回当前对象
 */
+ (UIBarButtonItem *)buttonItemWithImageTitle:(NSString *)backgroundImage
                                         Tile:(NSString *)title
                                       Target:(id)target
                                       Action:(SEL)action;

/**
 *  @author CC, 2016-01-04
 *  
 *  @brief  左图右文
 *
 *  @param backgroundImage       左图
 *  @param title                 标题
 *  @param onButtonTouchUpInside 回调函数
 *
 *  @return 返回当前对象
 */
+ (UIBarButtonItem *)buttonItemWithImageTitle:(NSString *)backgroundImage
                                         Tile:(NSString *)title
                     didOnButtonTouchUpInside:(void (^)(UIButton *sender))onButtonTouchUpInside;

@end
