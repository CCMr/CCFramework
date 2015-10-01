//
//  UIButton+BUIButton.h
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

@interface UIButton (BUIButton)

/**
 *  @author C C, 2015-10-01
 *
 *  @brief  设置标题普通与高亮
 *
 *  @param title 标题
 */
- (void)setTitle:(NSString *)title;

/**
 *  @author C C, 2015-10-01
 *
 *  @brief  设置标题文字颜色普通与高亮
 *
 *  @param color 标题颜色
 */
- (void)setTitleColor:(UIColor *)color;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  扩展属性
 *
 *  @since 1.0
 */
@property (nonatomic, retain) NSObject *carryObjects;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  创建按钮
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
+(id)buttonWith;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  标题
 *
 *  @param title 标题
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
+(id)buttonWithTitle:(NSString *)title;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  点击不会改变
 *
 *  @param title 标题
 *  @param image 背景图片
 *  @param color 字体颜色
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
+(id)buttonClickDoesNotChange:(NSString *)title BackgroundImage:(NSString *)image TitleColor:(UIColor *)color;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  设置标题与背景
 *
 *  @param title 标题
 *  @param image 背景图片
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
+(id)buttonWithTitleBackgroundImage:(NSString *)title BackgroundImage:(NSString *)image;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  设置背景图与长按背景图片
 *
 *  @param sImage 背景图片
 *  @param image 长按背景图片
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
+(id)buttonWithFinishedSelectedImage:(NSString *)FinishedSelectedImage withFinishedUnselectedImage:(NSString *)FinishedUnselectedImage;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  设置标题与背景
 *
 *  @param title 标题
 *  @param sImage 背景图片
 *  @param image 长按背景图片
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
+(id)buttonWithImage:(NSString *)title FinishedSelectedImage:(NSString *)FinishedSelectedImage WithFinishedUnselectedImage:(NSString *)FinishedUnselectedImage;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  设置背景图片
 *
 *  @param image 背景图片
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
+(id)buttonWithBackgroundImage:(NSString *)image;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  设置背景图片与位置
 *
 *  @param image 背景图片
 *  @param frame 按钮位置
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
+(id)buttonWithBackgroundImageFrame:(NSString *)image Frame:(CGRect)frame;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  设置背景图片与位置
 *
 *  @param LeftImage 左图片
 *  @param image 背景图片
 *  @param frame 按钮位置
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
+(id)buttonWithImageTitle:(NSString *)LeftImage Title:(NSString *)title Frame:(CGRect)frame;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  设置背景图片与位置
 *
 *  @param image 上图片
 *  @param title 标题
 *  @param frame 按钮位置
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
+(id)buttonWithUpImageNextTilte:(NSString *)image Title:(NSString *)title Frame:(CGRect)frame;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  圆角按钮
 *
 *  @param title 标题
 *  @param frame 按钮位置
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
+(id)buttonWithFillet:(NSString *)title Frame:(CGRect)frame;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  圆角按钮
 *
 *  @param image 背景图片
 *  @param title 标题
 *  @param frame 按钮位置
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
+(id)buttonWithFillet:(NSString *)image Title:(NSString *)title Frame:(CGRect)frame;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  圆角按钮
 *
 *  @param title 标题
 *  @param frame 按钮位置
 *  @param color 标题字体颜色
 *  @param mode 标题显示位置
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
+(id)buttonWithFillet:(NSString *)title Frame:(CGRect)frame TitleColor:(UIColor *)color Moode:(UIControlContentHorizontalAlignment)mode;


@end
