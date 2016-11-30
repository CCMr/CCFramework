//
//  UIViewController+Additions.h
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
#import "CCViewControllerProtocolDelegate.h"
#import "BaseViewManger.h"
#import "BaseViewModel.h"

// noticeStatistics 注册改通知 用于统计
#define noticeStatisticsWillAppear @"NOTICESTATISTICSWILLAPPEAR"
#define noticeStatisticsWillDisappear @"NOTICESTATISTICSWILLDISAPPEAR"

typedef void (^_CCViewControllerWillAppearInjectBlock)(UIViewController *viewController, BOOL animated);

@interface UIViewController (Additions) <CCViewControllerProtocolDelegate>

@property(readonly) UIView *navigationBarView;

/**
 *  @brief  找到当前viewcontroler所在的tableView
 */
@property(readonly) UITableView *tableView;

/**
 *  @author CC, 16-03-15
 *
 *  @brief 是否隐藏底部TabBar
 */
@property(nonatomic, assign) BOOL tabBarHidden;

@property(nonatomic, strong) __kindof BaseViewModel *cc_viewModel;
@property(nonatomic, strong) __kindof BaseViewManger *cc_viewManger;

/**
 包含在导航中时，交互式弹出手势是否禁用
 */
@property (nonatomic, assign) BOOL cc_interactivePopDisabled;

/**
 指示此视图控制器喜欢其导航栏隐藏或不隐藏，
 检查基于视图控制器的导航栏的外观是否启用。
 默认为NO，栏更有可能显示。
 */
@property (nonatomic, assign) BOOL cc_prefersNavigationBarHidden;

@property(nonatomic, copy) void (^slideBackHandler)(UIViewController *vc);

/**
 当开始交互式弹出时，最大允许到左边缘的初始距离
 手势。 0默认情况下，这意味着它将忽略此限制。
 */
@property (nonatomic, assign) CGFloat cc_interactivePopMaxAllowedInitialDistanceToLeftEdge;

@property(nonatomic, copy) _CCViewControllerWillAppearInjectBlock cc_willAppearInjectBlock;

- (void)backButtonTouched:(void (^)(UIViewController *vc))backButtonHandler;
- (void)slideBackTouched:(void (^)(UIViewController *vc))slideBackHandler;

/**
 *  @brief  视图层级
 *
 *  @return 视图层级字符串
 */
- (NSString *)recursiveDescription;

/**
 *  @author CC, 16-08-01
 *
 *  @brief 选项卡红点是否显示
 *
 *  @param index   选项卡下标
 *  @param isPoint 是否显示
 */
- (void)tabBatPoint:(NSInteger)index
            IsPoint:(BOOL)isPoint;

#pragma mark :. 导航栏loading效果
- (void)startLoading:(NSString *)title;
- (void)stopLoading;

#pragma mark -
#pragma mark :. Relationship

@property(readonly, copy) NSString *cc_identifier;
@property(nonatomic, strong) __kindof UITableView *cc_tableView;
@property(nonatomic, weak) __kindof UIViewController *cc_sourceVC;


#pragma mark -
#pragma mark :. pushViewController

/**
 *  @author CC, 2016-03-14
 *
 *  @brief  push新的控制器到导航控制器
 *
 *  @param newViewController 目标新的控制器对象
 */
- (void)pushNewViewController:(UIViewController *)newViewController;

/**
 *  @author CC, 2016-03-14
 *
 *  @brief  push新的控制器到导航控制器
 *
 *  @param newViewController 目标新的控制器对象
 *  @param animated          动画
 */
- (void)pushNewViewController:(UIViewController *)newViewController
                     Animated:(BOOL)animated;

/**
 *  @author CC, 2016-03-14
 *
 *  @brief  push新的控制器到导航控制器(返回按钮无文字)
 *
 *  @param newViewController 目标新的控制器对象
 */
- (void)pushNewViewControllerWithBack:(UIViewController *)newViewController;

/**
 *  @author CC, 2016-03-14
 *
 *  @brief  push新的控制器到导航控制器(返回按钮无文字)
 *
 *  @param newViewController 目标新的控制器对象
 *  @param animated          动画
 */
- (void)pushNewViewControllerWithBack:(UIViewController *)newViewController
                             Animated:(BOOL)animated;


/**
 *  @author CC, 2016-03-14
 *
 *  @brief  push新的控制器到导航控制器 并设置返回文字
 *
 *  @param newViewController 目标新的控制器对象
 *  @param title             标题
 */
- (void)pushNewViewControllerWithBackTitle:(UIViewController *)newViewController
                                 BackTitle:(NSString *)title;

/**
 *  @author CC, 2016-03-14
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
 *  @author CC, 2016-03-14
 *
 *  @brief  push多个新的控制器
 *  @param newViewController 多个控制器
 */
- (void)pushMultipleNewViewController:(UIViewController *)newViewController, ... NS_REQUIRES_NIL_TERMINATION;

/**
 *  @author CC, 2016-03-14
 *
 *  @brief  返回到指定页面
 *
 *  @param viewControllerClass 指定页面
 */
- (void)popToViewController:(Class)viewControllerClass;

/**
 *  @author CC, 16-07-30
 *
 *  @brief 返回上级页面
 */
- (void)popViewControllerAnimated;

/**
 *  @author CC, 16-07-30
 *
 *  @brief 返回顶级页面
 */
- (void)popToRootViewControllerAnimated;

#pragma mark -
#pragma mark :. presentViewController
- (void)presentViewController:(UIViewController *)newViewController;

- (void)presentViewController:(UIViewController *)newViewController Animated:(BOOL)animated;
;

#pragma mark -
#pragma mark :. PopupViewController

typedef NS_ENUM(NSInteger, CCPopupViewAnimation) {
    CCPopupViewAnimationFade = 0,
    CCPopupViewAnimationSlideBottomTop = 1,
    CCPopupViewAnimationSlideBottomBottom,
    CCPopupViewAnimationSlideTopTop,
    CCPopupViewAnimationSlideTopBottom,
    CCPopupViewAnimationSlideLeftLeft,
    CCPopupViewAnimationSlideLeftRight,
    CCPopupViewAnimationSlideRightLeft,
    CCPopupViewAnimationSlideRightRight,
};

@property(nonatomic, retain) UIViewController *popupViewController;
@property(nonatomic, retain) UIView *popupBackgroundView;

- (void)presentPopupViewController:(UIViewController *)popupViewController
                     animationType:(CCPopupViewAnimation)animationType;

- (void)presentPopupViewController:(UIViewController *)popupViewController
                     animationType:(CCPopupViewAnimation)animationType
                   backgroundTouch:(BOOL)enable
                         dismissed:(void (^)(void))dismissed;

- (void)dismissPopupViewControllerWithanimationType:(CCPopupViewAnimation)animationType;

#pragma mark -
#pragma makk :.StoreKit

@property NSString *campaignToken;
@property(nonatomic, copy) void (^loadingStoreKitItemBlock)(void);
@property(nonatomic, copy) void (^loadedStoreKitItemBlock)(void);

/**
 *  @author CC, 16-03-03
 *
 *  @brief 跳转商店
 *
 *  @param itemIdentifier 上架Identifier
 */
- (void)presentStoreKitItemWithIdentifier:(NSInteger)itemIdentifier;

/**
 *  @author CC, 16-03-03
 *
 *  @brief 拼接上架地址
 *
 *  @param identifier 商店Identifier
 */
+ (NSURL *)appURLForIdentifier:(NSInteger)identifier;

+ (void)openAppURLForIdentifier:(NSInteger)identifier;

+ (void)openAppReviewURLForIdentifier:(NSInteger)identifier;

/**
 *  @author CC, 16-03-03
 *
 *  @brief 校验是否是商店地址
 *
 *  @param URLString 网址
 */
+ (BOOL)containsITunesURLString:(NSString *)URLString;

/**
 *  @author CC, 16-03-03
 *
 *  @brief 商店地址获取Identifier
 *
 *  @param URLString 商店地址
 */
+ (NSInteger)IDFromITunesURL:(NSString *)URLString;

@end
