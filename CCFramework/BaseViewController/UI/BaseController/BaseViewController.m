
//
//  BaseViewController.m
//  BaseViewController
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
#import "BaseViewController.h"
#import "BaseNavigationController.h"
#import "Config.h"
#import "CCNSLog.h"
#import "UIButton+BUIButton.h"
#import "UIView+BUIView.h"

@interface BaseViewController () <MBProgressHUDDelegate> {
    BOOL touchYES, inside;
    CGRect PopMenuFrame;
}

/**
 *  @author CC, 2015-07-23 10:07:50
 *
 *  @brief  底部视图
 *
 *  @since 1.0
 */
@property(nonatomic, copy) UIView *BottomPopView;

/**
 *  @author CC, 2015-07-23 10:07:03
 *
 *  @brief  时间选择器选中时间
 *
 *  @since 1.0
 */
@property(nonatomic, assign) NSDate *SelectedDate;

@property(nonatomic, assign) UIButton *leftBarButton;
@property(nonatomic, assign) UIButton *rightBarButton;

@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
            self.extendedLayoutIncludesOpaqueBars = NO;
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.modalPresentationCapturesStatusBarAppearance = NO;
            self.automaticallyAdjustsScrollViewInsets = YES;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    if (_isNotKeyboard) {
        cc_NoticeObserver(self, @selector(keyboardWillShow:), UIKeyboardWillShowNotification, nil);
        cc_NoticeObserver(self, @selector(keyboardWillHide:), UIKeyboardWillHideNotification, nil);
    }
    
    cc_NoticeObserver(self, @selector(receiveLanguageChangedNotification:), CCNotificationLanguageChanged, nil);
    cc_NoticeObserver(self, @selector(receiveLanguageChangedNotification:), CCThemeDidChangeNotification, nil);
    
    [self InitNavigation];
}

/**
 *  @author CC, 2015-11-17
 *  
 *  @brief  提示窗初始化
 */
- (MBProgressHUD *)HUD
{
    if (!_HUD) {
        if (self.navigationController != nil) {
            _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:_HUD];
            _HUD.delegate = self;
        }
    }
    return _HUD;
}

- (CustomIOSAlertView *)alertView
{
    if (!_alertView) {
        _alertView = [[CustomIOSAlertView alloc] init];
        _alertView.containerView.backgroundColor = [UIColor whiteColor];
        _alertView.parentView.backgroundColor = [UIColor whiteColor];
        _alertView.dialogView.backgroundColor = [UIColor whiteColor];
        [_alertView setButtonTitles:@[]];
        [_alertView setUseMotionEffects:YES];
    }
    return _alertView;
}

#pragma mark - 底部弹出视图
- (void)bottomPopView:(UIView *)popView
{
    popView.tag = 9999999;
    
    _BottomPopView = [[UIView alloc] init];
    _BottomPopView.backgroundColor = cc_ColorRGBA(0, 0, 0, .3);
    [_BottomPopView addSubview:popView];
    
    
    UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topViewController.presentedViewController != nil)
        topViewController = topViewController.presentedViewController;
    
    if ([topViewController.view viewWithTag:9999999])
        [[topViewController.view viewWithTag:9999999] removeFromSuperview];
    
    _BottomPopView.frame = topViewController.view.bounds;
    [topViewController.view addSubview:_BottomPopView];
    
    
    [UIView animateWithDuration:0.3 animations:^{
        popView.frame =  CGRectMake(0, _BottomPopView.frame.size.height - popView.frame.size.height, winsize.width, popView.frame.size.height);
    }];
}

- (void)bottomPopViewHidden
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = [_BottomPopView viewWithTag:9999999].frame;
        frame.origin.y = _BottomPopView.frame.size.height;
        [_BottomPopView viewWithTag:9999999].frame = frame;
    } completion:^(BOOL finished) {
        [_BottomPopView removeFromSuperview];
    }];
}

#pragma mark - 初始化导航栏
- (void)InitNavigation
{
}

- (UIButton *)leftBarButton
{
    if (!_leftBarButton) {
        UIButton *leftButton = [UIButton buttonWith];
        [leftButton setImage:[UIImage imageNamed:@"public_back_btu_normal"] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(pressLeftBarButton:) forControlEvents:UIControlEventTouchUpInside];
        [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.navigationItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] init] initWithCustomView:leftButton]];
        leftButton.hidden = YES;
        _leftBarButton = leftButton;
    }
    
    return _leftBarButton;
}


- (UIButton *)rightBarButton
{
    if (!_rightBarButton) {
        UIButton *rightButton = [UIButton buttonWith];
        [rightButton addTarget:self action:@selector(pressRightBarButton:) forControlEvents:UIControlEventTouchUpInside];
        [rightButton setImage:nil forState:UIControlStateNormal];
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] init] initWithCustomView:rightButton]];
        rightButton.hidden = YES;
        _rightBarButton = rightButton;
    }
    
    return _rightBarButton;
}

- (void)pressLeftBarButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pressRightBarButton:(id)sender
{
    //do nothing
}

- (void)setLeftBarButtonWithTitle:(NSString *)title imageName:(NSString *)imageName
{
    [self.leftBarButton setTitle:title forState:UIControlStateNormal];
    [self.leftBarButton setImage:[UIImage imageNamed:cc_SafeString(imageName)] forState:UIControlStateNormal];
    self.leftBarButton.hidden = NO;
}

- (void)setRightBarButtonWithTitle:(NSString *)title imageName:(NSString *)imageName
{
    [self.rightBarButton setTitle:title forState:UIControlStateNormal];
    [self.rightBarButton setImage:[UIImage imageNamed:cc_SafeString(imageName)] forState:UIControlStateNormal];
    self.rightBarButton.hidden = NO;
}

//default  left NO  , right YES
- (void)setLeftBarButtonHidden:(BOOL)isLeftHidden rightBarButtonHidden:(BOOL)isRightHidden
{
    self.leftBarButton.hidden = isLeftHidden;
    self.rightBarButton.hidden = isRightHidden;
}

#pragma mark - 初始化页面控件
- (void)InitControl
{
}

#pragma mark - 初始化数据
- (void)InitLoadData
{
}

#pragma mark - 语言
/**
 *  @author CC, 2015-08-02
 *
 *  @brief  <#Description#>
 *
 *  @param notification <#notification description#>
 *
 *  @since <#version number#>
 */
- (void)receiveLanguageChangedNotification:(NSNotification *)notification
{
    if ([notification.name isEqualToString:CCNotificationLanguageChanged]) {
        [self SwitchingLanguages];
    }
}
/**
 *  @author CC, 2015-08-02
 *
 *  @brief  执行切换语言方法
 *
 *  @since 1.0
 */
- (void)SwitchingLanguages
{
}

#pragma mark - 主题
/**
 *  @author CC, 2015-08-02
 *
 *  @brief  <#Description#>
 *
 *  @param notification <#notification description#>
 *
 *  @since <#version number#>
 */
- (void)receiveThemeChangedNotification:(NSNotification *)notification
{
    if ([notification.name isEqualToString:CCThemeDidChangeNotification]) {
        [self SwitchingTheme];
    }
}

/**
 *  @author CC, 2015-08-02
 *
 *  @brief  切换主题
 *
 *  @since 1.0
 */
- (void)SwitchingTheme
{
}

#pragma mark - 基础功能
/**
 *  @author CC, 15-08-18
 *
 *  @brief  push新的控制器到导航控制器
 *
 *  @param newViewController 目标新的控制器对象
 *
 *  @since <#1.0#>
 */
- (void)pushNewViewController:(UIViewController *)newViewController
{
    if (self.navigationController)
        [self.navigationController pushViewController:newViewController animated:YES];
    else
        [self.extendNavigationController pushViewController:newViewController animated:YES];
}

/**
 *  @author CC, 2015-11-06
 *  
 *  @brief  push新的控制器到导航控制器 并设置返回文字
 *
 *  @param newViewController 目标新的控制器对象
 *  @param title             标题
 */
- (void)pushNewViewControllerWithBackTitle:(UIViewController *)newViewController BackTitle:(NSString *)title
{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:nil];
    if (self.navigationController)
        [self.navigationController pushViewController:newViewController animated:YES];
    else
        [self.extendNavigationController pushViewController:newViewController animated:YES];
}

/**
 *  @author CC, 2015-11-17
 *  
 *  @brief  push多个新的控制器
 *  @param newViewController 多个控制器
 */
- (void)pushMultipleNewViewController:(UIViewController *)newViewController, ... NS_REQUIRES_NIL_TERMINATION
{
    NSMutableArray *array = [NSMutableArray array];
    if (newViewController) {
        va_list arguments;
        id eachObject;
        va_start(arguments, newViewController);
        while ((eachObject = va_arg(arguments, id))) {
            [array addObject:eachObject];
        }
        va_end(arguments);
    }
    
    __block UIViewController *selfViewControler = newViewController;
    [array enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        UIViewController *objViewController = obj;
        BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:objViewController];
        nav.view.frame = selfViewControler.view.bounds;
        [selfViewControler addChildViewController:nav];
        [selfViewControler.view addSubview:nav.view];
        [nav didMoveToParentViewController:selfViewControler];
        
        selfViewControler = nav;
    }];
    [self pushNewViewController:newViewController];
}

/**
 *  @author CC, 15-09-25
 *
 *  @brief  返回到指定页面
 *
 *  @param viewControllerClass 指定页面
 */
- (void)popToViewController:(Class)viewControllerClass
{
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:viewControllerClass])
            [self.navigationController popToViewController:obj animated:YES];
    }];
}

/**
 *  @author CC, 15-08-18
 *
 *  @brief  提示消息
 *
 *  @param LabelText        标题
 *  @param detailsLabelText 详细
 *
 *  @since <#1.0#>
 */
- (void)hudMessages:(NSString *)LabelText
   DetailsLabelText:(NSString *)detailsLabelText
{
    self.HUD.mode = MBProgressHUDModeText;
    //    HUD.labelFont = Font19And17(systemFontOfSize, 15);
    self.HUD.labelColor = [UIColor whiteColor];
    self.HUD.labelText = LabelText;
    //    HUD.detailsLabelFont = Font19And17(systemFontOfSize, 15);
    self.HUD.detailsLabelText = detailsLabelText;
    self.HUD.detailsLabelColor = [UIColor whiteColor];
    [self.HUD show:YES];
    [self.HUD hide:YES afterDelay:1.5];
}

/**
 *  @author CC, 15-08-18
 *
 *  @brief  底部提示
 *
 *  @param detailsLabelText 提示内容
 */
- (void)hudToastMessage:(NSString *)detailsLabelText
{
    self.HUD.yOffset = (winsize.height - 64) / 2 - 20;
    [self hudMessages:nil DetailsLabelText:detailsLabelText];
}

#pragma mark - 页面加载完成事件
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *mClassName = [NSString stringWithUTF8String:object_getClassName(self.navigationController.visibleViewController)];
    CCNSLogger(@"viewDidAppear : %@", mClassName);
}

/**
 *  @author CC, 2015-07-23 10:07:27
 *
 *  @brief  页面隐藏软盘
 *
 *  @param touches <#touches description#>
 *  @param event   <#event description#>
 *
 *  @since <#version number#>
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    NSArray *array = self.view.subviews;
    UITableView *views = (UITableView *)self.view.subviews.firstObject;
    if (views)
        array = views.subviews;
    for (UIView *v in array) {
        if (touch.view != v) {
            [v endEditing:YES];
        }
    }
}

/**
 *  @author CC, 2015-07-23 10:07:07
 *
 *  @brief  隐藏软盘
 *
 *  @since 1.0
 */
- (void)resignFirstResponders
{
    for (UIView *v in self.view.subviews)
        [v endEditing:YES];
}

#pragma mark - 键盘事件
#define _UIKeyboardFrameEndUserInfoKey (&UIKeyboardFrameEndUserInfoKey != NULL ? UIKeyboardFrameEndUserInfoKey : @"UIKeyboardBoundsUserInfoKey")
- (void)keyboardWillShow:(NSNotification *)notification
{
    //get the keyboard rect
    CGRect _keyboardRect = [[[notification userInfo] objectForKey:_UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    //make an animation
    [UIView animateWithDuration:.25f animations:^{
        [self BasekeyboardWillShow:_keyboardRect];
    }];
}
- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:.25f animations:^{
        [self BasekeyboardWillHide];
    }];
}

- (void)SlideFrame:(BOOL)Up
{
    const int movementDistance = 20;     // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (Up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations:@"anim" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (void)BasekeyboardWillShow:(CGRect)keyboardRect
{
}

- (void)BasekeyboardWillHide
{
}

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
- (void)setTabBarHideShow:(BOOL)IsHide
{
    if ([self.tabBarController.view.subviews count] < 2) return;
    
    UIView *contentView;
    
    if ([[self.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]])
        contentView = [self.tabBarController.view.subviews objectAtIndex:1];
    else
        contentView = [self.tabBarController.view.subviews objectAtIndex:0];
    
    if (IsHide)
        contentView.frame = self.tabBarController.view.bounds;
    else {
        contentView.frame = CGRectMake(self.tabBarController.view.bounds.origin.x,
                                       self.tabBarController.view.bounds.origin.y,
                                       self.tabBarController.view.bounds.size.width,
                                       self.tabBarController.view.bounds.size.height - self.tabBarController.tabBar.frame.size.height);
    }
    
    self.tabBarController.tabBar.hidden = IsHide;
}

/**
 *  @author C C, 2015-10-11
 *
 *  @brief  隐藏导航栏底部线
 */
- (void)hideNavigationControllerBottomLine
{
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        NSArray *list = self.navigationController.navigationBar.subviews;
        for (id obj in list) {
            if ([obj isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView = (UIImageView *)obj;
                NSArray *list2 = imageView.subviews;
                for (id obj2 in list2) {
                    if ([obj2 isKindOfClass:[UIImageView class]]) {
                        UIImageView *imageView2 = (UIImageView *)obj2;
                        imageView2.hidden = YES;
                    }
                }
            }
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - 转屏
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id context) {
        if (newCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
            
        } else {
            
        }
        self.view.frame = self.view.bounds;
        [self.view setNeedsLayout];
    } completion:nil];
}

- (void)dealloc
{
    self.HUD = nil;
    self.alertView = nil;
    cc_NoticeremoveObserver(self, UIKeyboardWillShowNotification, nil);
    cc_NoticeremoveObserver(self, UIKeyboardWillHideNotification, nil);
    cc_NoticeremoveObserver(self, CCNotificationLanguageChanged, nil);
    cc_NoticeremoveObserver(self, CCThemeDidChangeNotification, nil);
}
@end
