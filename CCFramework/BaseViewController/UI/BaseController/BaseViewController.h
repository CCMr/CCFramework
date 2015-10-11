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
#import <CoreMotion/CoreMotion.h>

#import "CustomIOS7AlertView.h"
#import "CCPopMenuView.h"
//#import "CCTableViewCell.h"
#import "MBProgressHUD.h"

#import "CCLanguage.h"
#import "CCThemeManager.h"

@interface BaseViewController : UIViewController<MBProgressHUDDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

/**
 *  @author CC, 2015-10-09
 *
 *  @brief  扩展递归该对象
 */
@property (nonatomic, strong) UINavigationController *extendNavigationController;

/**
 *  @author CC, 2015-10-09
 *
 *  @brief  扩展递归该对象
 */
@property (nonatomic, strong) UITabBarController *extendTabBarController;

/**
 *  @author C C, 15-08-18
 *
 *  @brief  弹出层
 *
 *  @since <#1.0#>
 */
@property (nonatomic, strong) MBProgressHUD *HUD;

/**
 *  @author C C, 15-08-18
 *
 *  @brief  弹出提示层
 *
 *  @since <#1.0#>
 */
@property (nonatomic, strong) CustomIOS7AlertView *mAlertView;

/**
 *  @author C C, 2015-08-02
 *
 *  @brief  是否启用软盘监听
 *
 *  @since 1.0
 */
@property (nonatomic, assign) BOOL isNotKeyboard;

/**
 *  @author C C, 2015-06-19 09:06:24
 *
 *  @brief  展开Cell
 *
 *  @since 1.0
 */
//@property (nonatomic, retain) CCTableViewCell *currentCell;

-(void)InitNavigation;

-(void)InitControl;

-(void)InitLoadData;

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

- (void)bottomPopView:(UIView *)popView;
- (void)bottomPopViewHidden;

/**
 *  @author C C, 15-08-18
 *
 *  @brief  push新的控制器到导航控制器
 *
 *  @param newViewController 目标新的控制器对象
 *
 *  @since <#1.0#>
 */
- (void)pushNewViewController:(UIViewController *)newViewController;

/**
 *  @author CC, 15-09-25
 *
 *  @brief  返回到指定页面
 *
 *  @param viewControllerClass 指定页面
 */
- (void)popToViewController :(Class)viewControllerClass;

/**
 *  @author C C, 2015-07-23
 *
 *  @brief  弹出消息
 *
 *  @param LabelText        <#LabelText description#>
 *  @param detailsLabelText <#detailsLabelText description#>
 *
 *  @since 1.0
 */
- (void)hudMessages:(NSString *)LabelText
   DetailsLabelText:(NSString *)detailsLabelText;

/**
 *  @author C C, 15-08-18
 *
 *  @brief  底部提示
 *
 *  @param detailsLabelText 提示内容
 *
 *  @since <#1.0#>
 */
- (void)hudToastMessage:(NSString *)detailsLabelText;

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
//返回键默认存在
- (void)pressLeftBarButton:(id)sender;
//右键 默认不存在
- (void)pressRightBarButton:(id)sender;

- (void)setLeftBarButtonWithTitle:(NSString *)title
                        imageName:(NSString *)imageName;

- (void)setRightBarButtonWithTitle:(NSString *)title
                         imageName:(NSString *)imageName;
//default  left NO  , right YES
- (void)setLeftBarButtonHidden:(BOOL)isLeftHidden
          rightBarButtonHidden:(BOOL)isRightHidden;

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
@end
