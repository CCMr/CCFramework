//
//  UINavigationBar+Additions.h
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

@interface UINavigationBar (Additions)

#pragma mark -
#pragma mark :. Awesome

/*
 
 导航栏变换
 #define NAVBAR_CHANGE_POINT 50
 - (void)scrollViewDidScroll:(UIScrollView *)scrollView
 {
 UIColor * color = [UIColor colorWithRed:0/255.0 green:175/255.0 blue:240/255.0 alpha:1]; //导航栏背景色
 CGFloat offsetY = scrollView.contentOffset.y;
 if (offsetY > NAVBAR_CHANGE_POINT) {
 CGFloat alpha = MIN(1, 1 - ((NAVBAR_CHANGE_POINT + 64 - offsetY) / 64));
 [self.navigationController.navigationBar setBackgroundColor:[color colorWithAlphaComponent:alpha]];
 } else {
 [self.navigationController.navigationBar setBackgroundColor:[color colorWithAlphaComponent:0]];
 }
 }
 
 导航栏缩进
 - (void)scrollViewDidScroll:(UIScrollView *)scrollView
 {
 CGFloat offsetY = scrollView.contentOffset.y;
 if (offsetY > 0) {
 if (offsetY >= 44) {
 [self setNavigationBarTransformProgress:1];
 } else {
 [self setNavigationBarTransformProgress:(offsetY / 44)];
 }
 } else {
 [self setNavigationBarTransformProgress:0];
 self.navigationController.navigationBar.backIndicatorImage = [UIImage new];
 }
 }
 
 - (void)setNavigationBarTransformProgress:(CGFloat)progress
 {
 [self.navigationController.navigationBar setTranslationY:(-44 * progress)];
 [self.navigationController.navigationBar setElementsAlpha:(1-progress)];
 }
 
 */


/**
 *  @author CC, 2016-12-30
 *  
 *  @brief  设置背景颜色
 *
 *  @param backgroundColor 颜色
 */
- (void)setBackgroundColor:(UIColor *)backgroundColor;

/**
 *  @author CC, 2016-12-30
 *  
 *  @brief  设置要素透明度
 *
 *  @param alpha 透明度
 */
- (void)setElementsAlpha:(CGFloat)alpha;

/**
 *  @author CC, 2016-12-30
 *  
 *  @brief  动画
 *
 *  @param translationY 动画值
 */
- (void)setTranslationY:(CGFloat)translationY;

/**
 *  @author CC, 2016-12-30
 *  
 *  @brief  重置
 */
- (void)reset;

/**
 *  @brief  自定义UINavigationBar高度
 *
 *  @param height NavigationBar高度
 */
- (void)setHeight:(CGFloat)height;


@end
