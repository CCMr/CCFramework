
//
//  BaseViewController.m
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
#import "BaseViewController.h"
#import "Config.h"
#import "CCNSLog.h"
#import "UIBarButtonItem+Additions.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
            self.extendedLayoutIncludesOpaqueBars = NO;
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.modalPresentationCapturesStatusBarAppearance = NO;
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    cc_NoticeObserver(self, @selector(receiveLanguageChangedNotification:), CCNotificationLanguageChanged, nil);
    cc_NoticeObserver(self, @selector(receiveLanguageChangedNotification:), CCThemeDidChangeNotification, nil);

    [self initNavigation];
    [self initWithData];
    [self initEventhandler];
}

- (void)setIsNotKeyboard:(BOOL)isNotKeyboard
{
    _isNotKeyboard = isNotKeyboard;
    if (_isNotKeyboard) {
        cc_NoticeObserver(self, @selector(keyboardWillShow:), UIKeyboardWillShowNotification, nil);
        cc_NoticeObserver(self, @selector(keyboardWillHide:), UIKeyboardWillHideNotification, nil);
    }
}

#pragma mark - 初始化导航栏


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
         didOnButtonTouchUpInside:(void (^)(UIButton *sender))onButtonTouchUpInside
{
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem buttonItemWithTitle:title
                                                                 BackgroundImage:imageName
                                                        didOnButtonTouchUpInside:onButtonTouchUpInside];
}

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
          didOnButtonTouchUpInside:(void (^)(UIButton *sender))onButtonTouchUpInside
{
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem buttonItemWithTitle:title
                                                                  BackgroundImage:imageName
                                                         didOnButtonTouchUpInside:onButtonTouchUpInside];
}

#pragma mark - 初始化
/**
 *  @author CC, 2016-01-25
 *
 *  @brief 初始化导航栏
 */
- (void)initNavigation
{
}

/**
 *  @author CC, 2016-01-25
 *
 *  @brief 初始化控件
 */
- (void)initControl
{
}

/**
 *  @author CC, 16-03-17
 *
 *  @brief 初始化事件处理
 */
- (void)initEventhandler
{
}

/**
 *  @author CC, 2016-01-25
 *
 *  @brief 初始化数据
 */
- (void)initWithData
{
}

/**
 *  @author CC, 2016-01-25
 *
 *  @brief 初始化加载数据
 */
- (void)initLoadData
{
}

#pragma mark - 语言
/**
 *  @author CC, 2015-08-02
 *
 *  @brief  切换语言
 *
 *  @param notification 回调通知
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
 *  @brief  切换主体
 *
 *  @param notification 回调通知
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
 */
- (void)pushNewViewController:(UIViewController *)newViewController
{
    [self pushNewViewController:newViewController Animated:YES];
}

/**
 *  @author CC, 2016-01-08
 *
 *  @brief  push新的控制器到导航控制器
 *
 *  @param newViewController 目标新的控制器对象
 *  @param animated          动画
 */
- (void)pushNewViewController:(UIViewController *)newViewController
                     Animated:(BOOL)animated
{
    if (self.navigationController)
        [self.navigationController pushViewController:newViewController animated:animated];
    else
        [self.extendNavigationController pushViewController:newViewController animated:animated];
}

/**
 *  @author CC, 2016-01-08
 *
 *  @brief  push新的控制器到导航控制器(返回按钮无文字)
 *
 *  @param newViewController 目标新的控制器对象
 */
- (void)pushNewViewControllerWithBack:(UIViewController *)newViewController
{
    [self pushNewViewControllerWithBackTitle:newViewController
                                   BackTitle:@""];
}

/**
 *  @author CC, 2016-01-08
 *
 *  @brief  push新的控制器到导航控制器(返回按钮无文字)
 *
 *  @param newViewController 目标新的控制器对象
 *  @param animated          动画
 */
- (void)pushNewViewControllerWithBack:(UIViewController *)newViewController
                             Animated:(BOOL)animated
{
    [self pushNewViewControllerWithBackTitle:newViewController
                                   BackTitle:@""
                                    Animated:animated];
}


/**
 *  @author CC, 2015-11-06
 *
 *  @brief  push新的控制器到导航控制器 并设置返回文字
 *
 *  @param newViewController 目标新的控制器对象
 *  @param title             标题
 */
- (void)pushNewViewControllerWithBackTitle:(UIViewController *)newViewController
                                 BackTitle:(NSString *)title
{
    [self pushNewViewControllerWithBackTitle:newViewController
                                   BackTitle:title
                                    Animated:YES];
}

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
                                  Animated:(BOOL)animated
{
    if (self.navigationController) {
        self.navigationController.topViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:nil];
        [self.navigationController pushViewController:newViewController animated:animated];
    } else {
        self.extendNavigationController.topViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:nil];
        [self.extendNavigationController pushViewController:newViewController animated:animated];
    }
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
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:objViewController];
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

#pragma mark - 页面加载完成事件
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //    NSString *mClassName = [NSString stringWithUTF8String:object_getClassName(self.navigationController.visibleViewController)];
    //    CCNSLogger(@"viewDidAppear : %@", mClassName);
}

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  页面隐藏软盘
 *
 *  @param touches <#touches description#>
 *  @param event   <#event description#>
 */
- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    [self closeKeyboard:self.view];
}

/**
 *  @author CC, 16-01-28
 *
 *  @brief 关闭键盘
 *
 *  @param views 对应视图
 */
- (void)closeKeyboard:(UIView *)views
{
    NSArray *ary = views.subviews;
    for (UIView *v in ary) {
        if (v.subviews.count)
            [self closeKeyboard:v];
        [v endEditing:YES];
    }
}

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  隐藏软盘
 *
 *  @since 1.0
 */
- (void)resignFirstResponders
{
    [self closeKeyboard:self.view];
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

- (void)BasekeyboardWillShow:(CGRect)keyboardRect
{
}

- (void)BasekeyboardWillHide
{
}

#pragma mark - 隐藏显示TabBar

/**
 *  @author C C, 2015-10-11
 *
 *  @brief  隐藏导航栏底部线
 */
- (void)hideNavigationControllerBottomLine
{
    [self navigationControllerBottomLine:YES
                         BackgroundColor:nil];
}

/**
 *  @author CC, 16-02-24
 *
 *  @brief 设置导航栏底部线颜色
 *
 *  @param color 颜色
 */
- (void)navigationControllerBottomLineBackgroundColor:(UIColor *)color
{
    [self navigationControllerBottomLine:NO
                         BackgroundColor:color];
}

/**
 *  @author CC, 16-02-24
 *
 *  @brief 导航栏底部线设置
 *
 *  @param hiden 是否隐藏
 *  @param color 颜色
 */
- (void)navigationControllerBottomLine:(BOOL)hiden
                       BackgroundColor:(UIColor *)color
{
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        NSArray *subArray = self.navigationController.navigationBar.subviews;
        for (UIView *subV in subArray) {
//            if ([subV isKindOfClass:[UIImageView class]]) {
                for (UIView *subVs in subV.subviews) {
                    if ([subVs isKindOfClass:[UIImageView class]]) {
                        subVs.hidden = hiden;
                        CGRect f = subVs.frame;
                        f.size.height = 0.5;
                        subVs.frame = f;
                        if (color)
                            subVs.backgroundColor = color;
                    }
                }
//            }
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

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection
              withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
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
    cc_NoticeremoveObserver(self, UIKeyboardWillShowNotification, nil);
    cc_NoticeremoveObserver(self, UIKeyboardWillHideNotification, nil);
    cc_NoticeremoveObserver(self, CCNotificationLanguageChanged, nil);
    cc_NoticeremoveObserver(self, CCThemeDidChangeNotification, nil);
    [self deallocs];
}

/**
 *  @author CC, 16-02-19
 *
 *  @brief 释放内存
 */
-(void)deallocs
{

}

@end
