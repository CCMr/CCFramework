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

#import "UIViewController+Additions.h"
#import "NSObject+Additions.h"
#import "NSString+Additions.h"
#import "CCProperty.h"
#import "UIView+Method.h"
#import "UITableView+Additions.h"
#import "UITabBar+Additional.h"
#import <objc/runtime.h>
#import "CCNSLog.h"

@import StoreKit;

#pragma mark -
#pragma mark :. ScrollingStatusBar

@interface CCScrollingHandler : NSObject

- (instancetype)initWithDidScrollBlock:(void (^)(UIScrollView *scrollView))didScrollBlock;

@end

NSString *const CCScrollingHandlerDidScrollBlock = @"CCScrollingHandlerDidScrollBlock";

@implementation CCScrollingHandler

- (instancetype)initWithDidScrollBlock:(void (^)(UIScrollView *scrollView))didScrollBlock
{
    if (self = [super init]) {
        self.didScrollBlock = didScrollBlock;
    }
    return self;
}

#pragma mark :. Properties

- (void)setDidScrollBlock:(void (^)(UITableView *tableView))didScrollBlock
{
    objc_setAssociatedObject(self, (__bridge const void *)(CCScrollingHandlerDidScrollBlock), didScrollBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(UITableView *tableView))didScrollBlock
{
    return objc_getAssociatedObject(self, (__bridge const void *)(CCScrollingHandlerDidScrollBlock));
}

#pragma mark :. KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (![keyPath isEqualToString:@"contentOffset"]) {
        return;
    }

    if (self.didScrollBlock) {
        self.didScrollBlock(object);
    }
}

@end


@interface CCStatusBarWindow : UIWindow

@end

@implementation CCStatusBarWindow

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    /*
     20 points hardcoded for performance reason (default portrait status bar height)
     */
    return point.y <= 20.;
}

@end

#pragma mark -
#pragma mark :. ScrollingStatusBar

@interface UIViewController (SKStoreProductViewControllerDelegate) <SKStoreProductViewControllerDelegate>

@end

@implementation UIViewController (Additions)


static inline void AutomaticWritingSwizzleSelector(Class class, SEL originalSelector, SEL swizzledSelector)
{
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    if (class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AutomaticWritingSwizzleSelector([self class], @selector(viewWillAppear:), @selector(cc_viewWillAppear:));
        AutomaticWritingSwizzleSelector([self class], @selector(viewWillDisappear:), @selector(cc_viewWillDisappear:));
    });
}

- (void)cc_viewWillAppear:(BOOL)animated
{
    [self cc_viewWillAppear:animated];

    NSString *mClassName = [NSString stringWithUTF8String:object_getClassName(self)];
    CCNSLogger(@"viewDidAppear : %@", mClassName);

    if (self.navigationController.visibleViewController)
        cc_NoticePost(noticeStatisticsWillAppear, [NSString stringWithUTF8String:object_getClassName(self)]);
}

- (void)cc_viewWillDisappear:(BOOL)animated
{
    [self cc_viewWillDisappear:animated];
    NSString *mClassName = [NSString stringWithUTF8String:object_getClassName(self)];

    if (self.navigationController.visibleViewController)
        cc_NoticePost(noticeStatisticsWillDisappear, [NSString stringWithUTF8String:object_getClassName(self)]);
}

- (UITableView *)tableView
{
    return [self.view findSubViewWithSubViewClass:[UITableView class]];
}

- (BOOL)tabBarHidden
{
    return self.tabBarController.tabBar.hidden;
}

/**
 *  @author CC, 16-03-15
 *
 *  @brief 是否隐藏底部TabBar
 */
- (void)setTabBarHidden:(BOOL)tabBarHidden
{
    if ([self.tabBarController.view.subviews count] < 2) return;

    UIView *contentView;

    if ([[self.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]])
        contentView = [self.tabBarController.view.subviews objectAtIndex:1];
    else
        contentView = [self.tabBarController.view.subviews objectAtIndex:0];

    if (tabBarHidden)
        contentView.frame = self.tabBarController.view.bounds;
    else {
        contentView.frame = CGRectMake(self.tabBarController.view.bounds.origin.x,
                                       self.tabBarController.view.bounds.origin.y,
                                       self.tabBarController.view.bounds.size.width,
                                       self.tabBarController.view.bounds.size.height - self.tabBarController.tabBar.frame.size.height);
    }

    self.tabBarController.tabBar.hidden = tabBarHidden;
}

/**
 *  @author CC, 16-08-01
 *
 *  @brief 选项卡红点是否显示
 *
 *  @param index   选项卡下标
 *  @param isPoint 是否显示
 */
- (void)tabBatPoint:(NSInteger)index
            IsPoint:(BOOL)isPoint
{
    if (isPoint) {
        [self.tabBarController.tabBar showBadgePointOnItemIndex:index];
    } else
        [self.tabBarController.tabBar hideBadgePointOnItemIndex:index];
}

static const void *BackButtonHandlerKey = &BackButtonHandlerKey;

- (void)backButtonTouched:(void (^)(UIViewController *vc))backButtonHandler
{
    objc_setAssociatedObject(self, BackButtonHandlerKey, backButtonHandler, OBJC_ASSOCIATION_COPY);
}
- (void (^)(UIViewController *vc))backButtonHandler
{
    return objc_getAssociatedObject(self, BackButtonHandlerKey);
}

/**
 *  @brief  视图层级
 *
 *  @return 视图层级字符串
 */
- (NSString *)recursiveDescription
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"\n"];
    [self addDescriptionToString:description indentLevel:0];
    return description;
}

- (void)addDescriptionToString:(NSMutableString *)string indentLevel:(NSInteger)indentLevel
{
    NSString *padding = [@"" stringByPaddingToLength:indentLevel withString:@" " startingAtIndex:0];
    [string appendString:padding];
    [string appendFormat:@"%@, %@", [self debugDescription], NSStringFromCGRect(self.view.frame)];

    for (UIViewController *childController in self.childViewControllers) {
        [string appendFormat:@"\n%@>", padding];
        [childController addDescriptionToString:string indentLevel:indentLevel + 1];
    }
}

#pragma mark :. NavBarLoading
static char NavBarOrigTitleKey;
- (void)setNavBarOrigTitle:(NSString *)navBarOrigTitle
{
    objc_setAssociatedObject(self, &NavBarOrigTitleKey, navBarOrigTitle, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)navBarOrigTitle
{
    return objc_getAssociatedObject(self, &NavBarOrigTitleKey);
}

static char NavBarIsLoadingKey;
- (void)setIsLoading:(BOOL)isLoading
{
    objc_setAssociatedObject(self, &NavBarIsLoadingKey, @(isLoading), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isLoading
{
    return [objc_getAssociatedObject(self, &NavBarIsLoadingKey) boolValue];
}

- (void)startLoading:(NSString *)title
{
    if (!self.isLoading) {
        self.navBarOrigTitle = self.navigationItem.title;
        UIView *navBarLoadingContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        self.navigationItem.titleView = navBarLoadingContainer;
        self.isLoading = YES;

        UILabel *loadingTitleLabel = [[UILabel alloc] init];
        loadingTitleLabel.textAlignment = NSTextAlignmentCenter;
        loadingTitleLabel.textColor = self.navigationController.navigationBar.tintColor;
        loadingTitleLabel.text = title;

        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityIndicator startAnimating];
        [navBarLoadingContainer addSubview:loadingTitleLabel];
        [navBarLoadingContainer addSubview:activityIndicator];

        CGFloat padding = 5;
        NSLayoutConstraint *trailingConstraintForLabel = [NSLayoutConstraint constraintWithItem:loadingTitleLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:loadingTitleLabel.superview attribute:NSLayoutAttributeTrailing multiplier:1 constant:-padding];
        NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:loadingTitleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:loadingTitleLabel.superview attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];

        NSLayoutConstraint *leadingConstraintForIndicator = [NSLayoutConstraint constraintWithItem:activityIndicator attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:activityIndicator.superview attribute:NSLayoutAttributeLeading multiplier:1 constant:padding];
        NSLayoutConstraint *centerYConstraintForIndicator = [NSLayoutConstraint constraintWithItem:activityIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:loadingTitleLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];

        loadingTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        [loadingTitleLabel.superview addConstraints:@[ trailingConstraintForLabel, centerYConstraint, centerYConstraintForIndicator, leadingConstraintForIndicator ]];
    }
}

- (void)stopLoading
{
    if (self.isLoading) {
        self.navigationItem.titleView = nil;
        self.navigationItem.title = self.navBarOrigTitle;
        self.isLoading = NO;
    }
}

#pragma mark :. 操作对象
- (BaseViewModel *)cc_viewModel
{
    BaseViewModel *curVM = objc_getAssociatedObject(self, @selector(cc_viewModel));
    if (curVM) return curVM;
    if (![self respondsToSelector:@selector(cc_classOfViewModel)]) {
        NSException *exp = [NSException exceptionWithName:@"not found cc_classOfViewModel" reason:@"you forgot to add cc_classOfViewModel() in VivewController" userInfo:nil];
        [exp raise];
    }
    curVM = [[[self cc_classOfViewModel] alloc] init];
    self.cc_viewModel = curVM;
    return curVM;
}

- (void)setCc_viewModel:(__kindof NSObject *)cc_viewModel
{
    objc_setAssociatedObject(self, @selector(cc_viewModel), cc_viewModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BaseViewManger *)cc_viewManger
{
    BaseViewManger *curVM = objc_getAssociatedObject(self, @selector(cc_viewManger));
    if (curVM) return curVM;
    if (![self respondsToSelector:@selector(cc_classOfViewManger)]) {
        NSException *exp = [NSException exceptionWithName:@"not found cc_classOfViewManger" reason:@"you forgot to add cc_classOfViewManger() in VivewController" userInfo:nil];
        [exp raise];
    }
    curVM = [[[self cc_classOfViewManger] alloc] init];
    self.cc_viewManger = curVM;
    return curVM;
}

- (void)setCc_viewManger:(__kindof NSObject *)cc_viewManger
{
    objc_setAssociatedObject(self, @selector(cc_viewManger), cc_viewManger, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -
#pragma mark :. Relationship

- (NSString *)cc_identifier
{
    NSString *curIdentifier = [self associatedValueForKey:_cmd];
    if (curIdentifier) return curIdentifier;

    NSString *curClassName = NSStringFromClass([self class]);
    curIdentifier = [curClassName matchWithRegex:@"(?<=^CC)\\S+(?=VC$)" atIndex:0];
    CCAssert(curIdentifier, @"className should prefix with 'SUI' and suffix with 'VC'");

    if (!cc_NilOrNull(curClassName)) {
        [self copyAssociateValue:curClassName withKey:_cmd];
    }
    return curIdentifier;
}

- (UITableView *)cc_tableView
{
    UITableView *curTableView = [self associatedValueForKey:@selector(cc_tableView)];
    if (curTableView) return curTableView;

    if ([self isKindOfClass:[UITableViewController class]]) {
        curTableView = (UITableView *)self.view;
    } else {
        curTableView = [self.view findSubViewWithSubViewNSString:@"UITableView"];
    }

    if (curTableView) self.cc_tableView = curTableView;
    return curTableView;
}
- (void)setCc_tableView:(UITableView *)cc_tableView
{
    cc_tableView.cc_vc = self;
    [self associateValue:cc_tableView withKey:@selector(cc_tableView)];
}

- (UIViewController *)cc_sourceVC
{
    __block UIViewController *curVC = [self associatedValueForKey:@selector(cc_sourceVC)];
    if (curVC) return curVC;

    if (self.navigationController) {
        __block BOOL curFlag = NO;
        [self.navigationController.viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIViewController *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if (curFlag) {
                curVC = obj;
                self.cc_sourceVC = curVC;
                *stop = YES;
            }
            if (obj == self) {
                curFlag = YES;
            }
        }];
    }
    return curVC;
}
- (void)setCc_sourceVC:(UIViewController *)cc_sourceVC
{
    [self associateValue:cc_sourceVC withKey:@selector(cc_sourceVC)];
}

#pragma mark -
#pragma mark :. PushViewController

/**
 *  @author CC, 2016-03-14
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
 *  @author CC, 2016-03-14
 *
 *  @brief  push新的控制器到导航控制器
 *
 *  @param newViewController 目标新的控制器对象
 *  @param animated          动画
 */
- (void)pushNewViewController:(UIViewController *)newViewController
                     Animated:(BOOL)animated
{
    [self.navigationController pushViewController:newViewController animated:animated];
}

/**
 *  @author CC, 2016-03-14
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
 *  @author CC, 2016-03-14
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
 *  @author CC, 2016-03-14
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
                                  Animated:(BOOL)animated
{
    self.navigationController.topViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:nil];
    [self.navigationController pushViewController:newViewController animated:animated];
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

/**
 *  @author CC, 16-07-30
 *
 *  @brief 返回上级页面
 */
- (void)popViewControllerAnimated
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  @author CC, 16-07-30
 *
 *  @brief 返回顶级页面
 */
- (void)popToRootViewControllerAnimated
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark :. presentViewController
- (void)presentViewController:(UIViewController *)newViewController
{
    [self presentViewController:newViewController Animated:YES];
}

- (void)presentViewController:(UIViewController *)newViewController
                     Animated:(BOOL)animated
{
    if (self.parentViewController)
        [self.parentViewController presentViewController:newViewController animated:animated completion:nil];
    else
        [[[[UIApplication sharedApplication].windows firstObject] rootViewController] presentViewController:newViewController animated:animated completion:nil];
}

#pragma mark -
#pragma mark :. PopupViewController

#define kPopupModalAnimationDuration 0.35
#define kCCPopupViewController @"kCCPopupViewController"
#define kCCPopupBackgroundView @"kCCPopupBackgroundView"
#define kCCSourceViewTag 23941
#define kCCPopupViewTag 23942
#define kCCOverlayViewTag 23945

static NSString *CCPopupViewDismissedKey = @"CCPopupViewDismissed";
static void *const keypath = (void *)&keypath;

- (UIViewController *)popupViewController
{
    return objc_getAssociatedObject(self, kCCPopupViewController);
}

- (void)setPopupViewController:(UIViewController *)popupViewController
{
    objc_setAssociatedObject(self, kCCPopupViewController, popupViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)popupBackgroundView
{
    return objc_getAssociatedObject(self, kCCPopupBackgroundView);
}

- (void)setPopupBackgroundView:(UIView *)popupBackgroundView
{
    objc_setAssociatedObject(self, kCCPopupBackgroundView, popupBackgroundView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)presentPopupViewController:(UIViewController *)popupViewController
                     animationType:(CCPopupViewAnimation)animationType
                   backgroundTouch:(BOOL)enable
                         dismissed:(void (^)(void))dismissed
{
    self.popupViewController = popupViewController;
    [self presentPopupView:popupViewController.view
             animationType:animationType
           backgroundTouch:enable
                 dismissed:dismissed];
}

- (void)presentPopupViewController:(UIViewController *)popupViewController
                     animationType:(CCPopupViewAnimation)animationType
{
    [self presentPopupViewController:popupViewController
                       animationType:animationType
                     backgroundTouch:YES
                           dismissed:nil];
}

- (void)dismissPopupViewControllerWithanimationType:(CCPopupViewAnimation)animationType
{
    UIView *sourceView = [self topView];
    UIView *popupView = [sourceView viewWithTag:kCCPopupViewTag];
    UIView *overlayView = [sourceView viewWithTag:kCCOverlayViewTag];

    switch (animationType) {
        case CCPopupViewAnimationSlideBottomTop:
        case CCPopupViewAnimationSlideBottomBottom:
        case CCPopupViewAnimationSlideTopTop:
        case CCPopupViewAnimationSlideTopBottom:
        case CCPopupViewAnimationSlideLeftLeft:
        case CCPopupViewAnimationSlideLeftRight:
        case CCPopupViewAnimationSlideRightLeft:
        case CCPopupViewAnimationSlideRightRight:
            [self slideViewOut:popupView
                    sourceView:sourceView
                   overlayView:overlayView
             withAnimationType:animationType];
            break;

        default:
            [self fadeViewOut:popupView
                   sourceView:sourceView
                  overlayView:overlayView];
            break;
    }
}

#pragma mark :. View Handling

- (void)presentPopupView:(UIView *)popupView
           animationType:(CCPopupViewAnimation)animationType
{
    [self presentPopupView:popupView
             animationType:animationType
           backgroundTouch:YES
                 dismissed:nil];
}

- (UIViewController *)topViewControllers
{
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewControllerWithRootViewController:(UIViewController *)rootViewController
{
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController *presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        if (rootViewController) {
            return rootViewController;
        } else {
            UIViewController *recentView = self;

            while (recentView.parentViewController != nil) {
                recentView = recentView.parentViewController;
            }
            return recentView;
        }
    }
}

- (void)presentPopupView:(UIView *)popupView
           animationType:(CCPopupViewAnimation)animationType
         backgroundTouch:(BOOL)enable
               dismissed:(void (^)(void))dismissed
{
    UIView *sourceView = [self topView];
    sourceView.tag = kCCSourceViewTag;
    popupView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    popupView.tag = kCCPopupViewTag;

    // check if source view controller is not in destination
    if ([sourceView.subviews containsObject:popupView]) return;

    // customize popupView
    popupView.layer.shadowPath = [UIBezierPath bezierPathWithRect:popupView.bounds].CGPath;
    popupView.layer.masksToBounds = NO;
    popupView.layer.shadowOffset = CGSizeMake(5, 5);
    popupView.layer.shadowRadius = 5;
    popupView.layer.shadowOpacity = 0.5;
    popupView.layer.shouldRasterize = YES;
    popupView.layer.rasterizationScale = [[UIScreen mainScreen] scale];

    // Add semi overlay
    UIView *overlayView = [[UIView alloc] initWithFrame:sourceView.bounds];
    overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    overlayView.tag = kCCOverlayViewTag;
    overlayView.backgroundColor = [UIColor clearColor];

    // BackgroundView
    self.popupBackgroundView = [[UIView alloc] initWithFrame:sourceView.bounds];
    self.popupBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.popupBackgroundView.backgroundColor = [UIColor clearColor];
    self.popupBackgroundView.alpha = 0.0f;
    [overlayView addSubview:self.popupBackgroundView];

    // Make the Background Clickable
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    dismissButton.backgroundColor = [UIColor clearColor];
    dismissButton.frame = sourceView.bounds;
    [overlayView addSubview:dismissButton];

    popupView.alpha = 0.0f;
    [overlayView addSubview:popupView];
    [sourceView addSubview:overlayView];


    [dismissButton addTarget:self action:@selector(dismissPopupViewControllerWithanimation:) forControlEvents:UIControlEventTouchUpInside];
    switch (animationType) {
        case CCPopupViewAnimationSlideBottomTop:
        case CCPopupViewAnimationSlideBottomBottom:
        case CCPopupViewAnimationSlideTopTop:
        case CCPopupViewAnimationSlideTopBottom:
        case CCPopupViewAnimationSlideLeftLeft:
        case CCPopupViewAnimationSlideLeftRight:
        case CCPopupViewAnimationSlideRightLeft:
        case CCPopupViewAnimationSlideRightRight:
            dismissButton.tag = animationType;
            [self slideViewIn:popupView
                   sourceView:sourceView
                  overlayView:overlayView
            withAnimationType:animationType];
            break;
        default:
            dismissButton.tag = CCPopupViewAnimationFade;
            [self fadeViewIn:popupView
                  sourceView:sourceView
                 overlayView:overlayView];
            break;
    }
    dismissButton.enabled = enable;
    [self setDismissedCallback:dismissed];
}

- (UIView *)topView
{

    return [self topViewControllers].view;
}

- (void)dismissPopupViewControllerWithanimation:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *dismissButton = sender;
        switch (dismissButton.tag) {
            case CCPopupViewAnimationSlideBottomTop:
            case CCPopupViewAnimationSlideBottomBottom:
            case CCPopupViewAnimationSlideTopTop:
            case CCPopupViewAnimationSlideTopBottom:
            case CCPopupViewAnimationSlideLeftLeft:
            case CCPopupViewAnimationSlideLeftRight:
            case CCPopupViewAnimationSlideRightLeft:
            case CCPopupViewAnimationSlideRightRight:
                [self dismissPopupViewControllerWithanimationType:dismissButton.tag];
                break;
            default:
                [self dismissPopupViewControllerWithanimationType:CCPopupViewAnimationFade];
                break;
        }
    } else {
        [self dismissPopupViewControllerWithanimationType:CCPopupViewAnimationFade];
    }
}

#pragma mark :. Animations

#pragma mark--- Slide

- (void)slideViewIn:(UIView *)popupView
         sourceView:(UIView *)sourceView
        overlayView:(UIView *)overlayView
  withAnimationType:(CCPopupViewAnimation)animationType
{
    // Generating Start and Stop Positions
    CGSize sourceSize = sourceView.bounds.size;
    CGSize popupSize = popupView.bounds.size;
    CGRect popupStartRect;
    switch (animationType) {
        case CCPopupViewAnimationSlideBottomTop:
        case CCPopupViewAnimationSlideBottomBottom:
            popupStartRect = CGRectMake((sourceSize.width - popupSize.width) / 2,
                                        sourceSize.height,
                                        popupSize.width,
                                        popupSize.height);

            break;
        case CCPopupViewAnimationSlideLeftLeft:
        case CCPopupViewAnimationSlideLeftRight:
            popupStartRect = CGRectMake(-sourceSize.width,
                                        (sourceSize.height - popupSize.height) / 2,
                                        popupSize.width,
                                        popupSize.height);
            break;

        case CCPopupViewAnimationSlideTopTop:
        case CCPopupViewAnimationSlideTopBottom:
            popupStartRect = CGRectMake((sourceSize.width - popupSize.width) / 2,
                                        -popupSize.height,
                                        popupSize.width,
                                        popupSize.height);
            break;

        default:
            popupStartRect = CGRectMake(sourceSize.width,
                                        (sourceSize.height - popupSize.height) / 2,
                                        popupSize.width,
                                        popupSize.height);
            break;
    }
    CGRect popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2,
                                     (sourceSize.height - popupSize.height) / 2,
                                     popupSize.width,
                                     popupSize.height);

    // Set starting properties
    popupView.frame = popupStartRect;
    popupView.alpha = 1.0f;
    [UIView animateWithDuration:kPopupModalAnimationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.popupViewController viewWillAppear:NO];
        self.popupBackgroundView.alpha = 1.0f;
        popupView.frame = popupEndRect;
    } completion:^(BOOL finished) {
        [self.popupViewController viewDidAppear:NO];
    }];
}

- (void)slideViewOut:(UIView *)popupView
          sourceView:(UIView *)sourceView
         overlayView:(UIView *)overlayView
   withAnimationType:(CCPopupViewAnimation)animationType
{
    // Generating Start and Stop Positions
    CGSize sourceSize = sourceView.bounds.size;
    CGSize popupSize = popupView.bounds.size;
    CGRect popupEndRect;
    switch (animationType) {
        case CCPopupViewAnimationSlideBottomTop:
        case CCPopupViewAnimationSlideTopTop:
            popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2,
                                      -popupSize.height,
                                      popupSize.width,
                                      popupSize.height);
            break;
        case CCPopupViewAnimationSlideBottomBottom:
        case CCPopupViewAnimationSlideTopBottom:
            popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2,
                                      sourceSize.height,
                                      popupSize.width,
                                      popupSize.height);
            break;
        case CCPopupViewAnimationSlideLeftRight:
        case CCPopupViewAnimationSlideRightRight:
            popupEndRect = CGRectMake(sourceSize.width,
                                      popupView.frame.origin.y,
                                      popupSize.width,
                                      popupSize.height);
            break;
        default:
            popupEndRect = CGRectMake(-popupSize.width,
                                      popupView.frame.origin.y,
                                      popupSize.width,
                                      popupSize.height);
            break;
    }

    [UIView animateWithDuration:kPopupModalAnimationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.popupViewController viewWillDisappear:NO];
        popupView.frame = popupEndRect;
        self.popupBackgroundView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [popupView removeFromSuperview];
        [overlayView removeFromSuperview];
        [self.popupViewController viewDidDisappear:NO];
        self.popupViewController = nil;

        id dismissed = [self dismissedCallback];
        if (dismissed != nil){
            ((void(^)(void))dismissed)();
            [self setDismissedCallback:nil];
        }
    }];
}

#pragma mark--- Fade

- (void)fadeViewIn:(UIView *)popupView
        sourceView:(UIView *)sourceView
       overlayView:(UIView *)overlayView
{
    // Generating Start and Stop Positions
    CGSize sourceSize = sourceView.bounds.size;
    CGSize popupSize = popupView.bounds.size;
    CGRect popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2,
                                     (sourceSize.height - popupSize.height) / 2,
                                     popupSize.width,
                                     popupSize.height);

    // Set starting properties
    popupView.frame = popupEndRect;
    popupView.alpha = 0.0f;

    [UIView animateWithDuration:kPopupModalAnimationDuration animations:^{
        [self.popupViewController viewWillAppear:NO];
        self.popupBackgroundView.alpha = 0.5f;
        popupView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [self.popupViewController viewDidAppear:NO];
    }];
}

- (void)fadeViewOut:(UIView *)popupView
         sourceView:(UIView *)sourceView
        overlayView:(UIView *)overlayView
{
    [UIView animateWithDuration:kPopupModalAnimationDuration animations:^{
        [self.popupViewController viewWillDisappear:NO];
        self.popupBackgroundView.alpha = 0.0f;
        popupView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [popupView removeFromSuperview];
        [overlayView removeFromSuperview];
        [self.popupViewController viewDidDisappear:NO];
        self.popupViewController = nil;

        id dismissed = [self dismissedCallback];
        if (dismissed != nil){
            ((void(^)(void))dismissed)();
            [self setDismissedCallback:nil];
        }
    }];
}

#pragma mark :. Category Accessors
#pragma mark--- Dismissed

- (void)setDismissedCallback:(void (^)(void))dismissed
{
    objc_setAssociatedObject(self, &CCPopupViewDismissedKey, dismissed, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(self.popupViewController, &CCPopupViewDismissedKey, dismissed, OBJC_ASSOCIATION_RETAIN);
}

- (void (^)(void))dismissedCallback
{
    return objc_getAssociatedObject(self, &CCPopupViewDismissedKey);
}

#pragma mark -
#pragma mark :. StoreKit

NSString *const affiliateTokenKey = @"at";
NSString *const campaignTokenKey = @"ct";
NSString *const iTunesAppleString = @"itunes.apple.com";

- (void)presentStoreKitItemWithIdentifier:(NSInteger)itemIdentifier
{
    SKStoreProductViewController *storeViewController = [[SKStoreProductViewController alloc] init];
    storeViewController.delegate = self;

    NSString *campaignToken = self.campaignToken ?: @"";

    NSDictionary *parameters = @{
                                 SKStoreProductParameterITunesItemIdentifier : @(itemIdentifier),
                                 affiliateTokenKey : affiliateTokenKey,
                                 campaignTokenKey : campaignToken,
                                 };

    if (self.loadingStoreKitItemBlock) {
        self.loadingStoreKitItemBlock();
    }
    [storeViewController loadProductWithParameters:parameters completionBlock:^(BOOL result, NSError *error) {
        if (self.loadedStoreKitItemBlock) {
            self.loadedStoreKitItemBlock();
        }

        if (result && !error){
            [self presentViewController:storeViewController animated:YES completion:nil];
        }
    }];
}

#pragma mark--- Delegation - SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark--- Public methods

+ (NSURL *)appURLForIdentifier:(NSInteger)identifier
{
    NSString *appURLString = [NSString stringWithFormat:@"https://itunes.apple.com/app/id%li", (long)identifier];
    return [NSURL URLWithString:appURLString];
}

+ (void)openAppReviewURLForIdentifier:(NSInteger)identifier
{
    NSString *reviewURLString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%li", (long)identifier];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:reviewURLString]];
}

+ (void)openAppURLForIdentifier:(NSInteger)identifier
{
    NSString *appURLString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%li", (long)identifier];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appURLString]];
}

+ (BOOL)containsITunesURLString:(NSString *)URLString
{
    return ([URLString rangeOfString:iTunesAppleString].location != NSNotFound);
}

+ (NSInteger)IDFromITunesURL:(NSString *)URLString
{
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"id\\d+" options:0 error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:URLString options:0 range:NSMakeRange(0, URLString.length)];

    NSString *idString = [URLString substringWithRange:match.range];
    if (idString.length > 0) {
        idString = [idString stringByReplacingOccurrencesOfString:@"id" withString:@""];
    }

    return [idString integerValue];
}

#pragma mark--- Associated objects

- (void)setCampaignToken:(NSString *)campaignToken
{
    objc_setAssociatedObject(self, @selector(setCampaignToken:), campaignToken, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)campaignToken
{
    return objc_getAssociatedObject(self, @selector(setCampaignToken:));
}

- (void)setLoadingStoreKitItemBlock:(void (^)(void))loadingStoreKitItemBlock
{
    objc_setAssociatedObject(self, @selector(setLoadingStoreKitItemBlock:), loadingStoreKitItemBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void (^)(void))loadingStoreKitItemBlock
{
    return objc_getAssociatedObject(self, @selector(setLoadingStoreKitItemBlock:));
}

- (void)setLoadedStoreKitItemBlock:(void (^)(void))loadedStoreKitItemBlock
{
    objc_setAssociatedObject(self, @selector(setLoadedStoreKitItemBlock:), loadedStoreKitItemBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void (^)(void))loadedStoreKitItemBlock
{
    return objc_getAssociatedObject(self, @selector(setLoadedStoreKitItemBlock:));
}

@end


@implementation UINavigationController (Additions)

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    if ([self.viewControllers count] < [navigationBar.items count])
        return YES;

    UIWindow *windowView = [UIApplication sharedApplication].keyWindow;
    [[windowView viewWithTag:999999] removeFromSuperview];

    UIViewController *vc = [self topViewController];
    void (^handler)(UIViewController *vc) = [vc backButtonHandler];
    if (handler) {
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(vc);
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self popViewControllerAnimated:YES];
        });
    }

    return NO;
}

@end