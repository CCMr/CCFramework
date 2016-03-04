//
//  UIActionSheet+Additions.h
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

@interface UIActionSheet (Additions) <UIAlertViewDelegate, UIActionSheetDelegate>

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  扩展属性
 *
 *  @since 1.0
 */
@property(nonatomic, strong) UIView *sheetBackgroundView;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  设置视图
 *
 *  @param views
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (id)initWithContentView:(UIView *)views;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  隐藏视图
 *
 *  @param index
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (void)hide:(NSInteger)index;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  Block返回结果
 *
 *  @param actionSheet
 *  @param buttonIndex
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  Block返回结果
 *
 *  @param actionSheet
 *  @param buttonIndex
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (void)config:(void (^)(NSInteger buttonIndex))completionHandler;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  Block返回结果
 *
 *  @param view 显示父类视图
 *  @param buttonIndex
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (void)showInView:(UIView *)view
withCompletionHandler:(void (^)(NSInteger buttonIndex))completionHandler;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  Block返回结果
 *
 *  @param view 显示父类视图
 *  @param buttonIndex
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (void)showFromToolbar:(UIToolbar *)view
  withCompletionHandler:(void (^)(NSInteger buttonIndex))completionHandler;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  Block返回结果
 *
 *  @param view 显示父类视图
 *  @param buttonIndex
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (void)showFromTabBar:(UITabBar *)view
 withCompletionHandler:(void (^)(NSInteger buttonIndex))completionHandler;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  Block返回结果
 *
 *  @param view 显示父类视图
 *  @param buttonIndex
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (void)showFromRect:(CGRect)rect
              inView:(UIView *)view
            animated:(BOOL)animated
withCompletionHandler:(void (^)(NSInteger buttonIndex))completionHandler;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  Block返回结果
 *
 *  @param view 显示父类视图
 *  @param buttonIndex
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (void)showFromBarButtonItem:(UIBarButtonItem *)item
                     animated:(BOOL)animated
        withCompletionHandler:(void (^)(NSInteger buttonIndex))completionHandler;

@end
