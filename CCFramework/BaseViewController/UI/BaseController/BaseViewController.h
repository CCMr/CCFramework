//
//  BaseViewController.h
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
#import "CCLanguage.h"
#import "CCThemeManager.h"

@interface BaseViewController : UIViewController <UINavigationControllerDelegate>

/**
 *  @author CC, 2015-10-09
 *
 *  @brief  扩展递归该对象
 */
@property(nonatomic, strong) UINavigationController *extendNavigationController;

/**
 *  @author CC, 2015-10-09
 *
 *  @brief  扩展递归该对象
 */
@property(nonatomic, strong) UITabBarController *extendTabBarController;

/**
 *  @author C C, 2015-08-02
 *
 *  @brief  是否启用软盘监听
 *
 *  @since 1.0
 */
@property(nonatomic, assign) BOOL isNotKeyboard;

#pragma mark - 初始化
/**
 *  @author CC, 2016-01-25
 *  
 *  @brief 初始化导航栏
 */
- (void)initNavigation;

/**
 *  @author CC, 2016-01-25
 *  
 *  @brief 初始化控件
 */
- (void)initControl;

/**
 *  @author CC, 2016-01-25
 *  
 *  @brief 初始化数据
 */
- (void)initWithData;

/**
 *  @author CC, 2016-01-25
 *  
 *  @brief 初始化加载数据
 */
- (void)initLoadData;

/**
 *  @author C C, 2015-08-02
 *
 *  @brief  执行切换语言方法
 *
 *  @since 1.0
 */
- (void)SwitchingLanguages;

/**
 *  @author C C, 2015-08-02
 *
 *  @brief  切换主题
 *
 *  @since 1.0
 */
- (void)SwitchingTheme;

#pragma mark :. 跳转导航栏
/**
 *  @author C C, 15-08-18
 *
 *  @brief  push新的控制器到导航控制器
 *
 *  @param newViewController 目标新的控制器对象
 */
- (void)pushNewViewController:(UIViewController *)newViewController;

/**
 *  @author CC, 2016-01-08
 *  
 *  @brief  push新的控制器到导航控制器
 *
 *  @param newViewController 目标新的控制器对象
 *  @param animated          动画
 */
- (void)pushNewViewController:(UIViewController *)newViewController
                     Animated:(BOOL)animated;

/**
 *  @author CC, 2016-01-08
 *  
 *  @brief  push新的控制器到导航控制器(返回按钮无文字)
 *
 *  @param newViewController 目标新的控制器对象
 */
- (void)pushNewViewControllerWithBack:(UIViewController *)newViewController;

/**
 *  @author CC, 2016-01-08
 *  
 *  @brief  push新的控制器到导航控制器(返回按钮无文字)
 *
 *  @param newViewController 目标新的控制器对象
 *  @param animated          动画
 */
- (void)pushNewViewControllerWithBack:(UIViewController *)newViewController
                             Animated:(BOOL)animated;

/**
 *  @author CC, 2015-11-06
 *  
 *  @brief  push新的控制器到导航控制器 并设置返回文字
 *
 *  @param newViewController 目标新的控制器对象
 *  @param title             标题
 */
- (void)pushNewViewControllerWithBackTitle:(UIViewController *)newViewController
                                 BackTitle:(NSString *)title;

/**
 *  @author CC, 2016-01-08
 *  
 *  @brief  push新的控制器到导航控制器 并设置返回文字
 *
 *  @param newViewController 目标新的控制器对象
 *  @param title             标题
 *  @param animated          动画
 */
- (void)pushNewViewControllerWithBackTitle:(UIViewController *)newViewController
                                 BackTitle:(NSString *)title
                                  Animated:(BOOL)animated;

/**
 *  @author CC, 2015-11-17
 *  
 *  @brief  push多个新的控制器
 *  @param newViewController 多个控制器
 */
- (void)pushMultipleNewViewController:(UIViewController *)newViewController, ... NS_REQUIRES_NIL_TERMINATION;

/**
 *  @author CC, 15-09-25
 *
 *  @brief  返回到指定页面
 *
 *  @param viewControllerClass 指定页面
 */
- (void)popToViewController:(Class)viewControllerClass;

#pragma mark :.
/**
 *  @author C C, 2015-08-02
 *
 *  @brief  隐藏软盘
 *
 *  @since 1.0
 */
- (void)resignFirstResponders;


/**
 *  @author C C, 2015-08-02
 *
 *  @brief  软盘显示回调事件
 *
 *  @param keyboardRect <#keyboardRect description#>
 *
 *  @since 1.0
 */
- (void)BasekeyboardWillShow:(CGRect)keyboardRect;

/**
 *  @author C C, 2015-08-02
 *
 *  @brief  软盘隐藏回调事件
 *
 *  @since 1.0
 */
- (void)BasekeyboardWillHide;

#pragma mark - 导航栏按钮
/**
 *  @author CC, 2016-01-04
 *  
 *  @brief  导航左按钮
 *
 *  @param title                 标题
 *  @param imageName             背景图片
 *  @param onButtonTouchUpInside 回调函数
 */
- (void)setLeftBarButtonWithTitle:(NSString *)title
                        imageName:(NSString *)imageName
         didOnButtonTouchUpInside:(void (^)(UIButton *sender))onButtonTouchUpInside;

/**
 *  @author CC, 2016-01-04
 *  
 *  @brief  导航右按钮
 *
 *  @param title                 标题
 *  @param imageName             背景
 *  @param onButtonTouchUpInside 回调函数
 */
- (void)setRightBarButtonWithTitle:(NSString *)title
                         imageName:(NSString *)imageName
          didOnButtonTouchUpInside:(void (^)(UIButton *sender))onButtonTouchUpInside;

#pragma mark - 隐藏显示TabBar
/**
 *  @author CC, 15-09-16
 *
 *  @brief  隐藏显示TabBar
 *
 *  @param IsHide 是否隐藏
 *
 *  @since 1.0
 */
- (void)setTabBarHideShow:(BOOL)IsHide;

/**
 *  @author C C, 2015-10-11
 *
 *  @brief  隐藏导航栏底部线
 */
- (void)hideNavigationControllerBottomLine;

/**
 *  @author CC, 16-02-24
 *  
 *  @brief 设置导航栏底部线颜色
 *
 *  @param color 颜色
 */
- (void)navigationControllerBottomLineBackgroundColor:(UIColor *)color;

/**
 *  @author CC, 16-02-19
 *  
 *  @brief 释放内存
 */
-(void)deallocs;

@end
