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
#import <objc/runtime.h>

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

- (UIViewController *)topViewController
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
    
    return [self topViewController].view;
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
#pragma mark :. ScrollingStatusBar

NSString *const UIViewControllerScrollingStatusBarContext = @"UIViewControllerScrollingStatusBarContext";
NSString *const UIViewControllerScrollingHandler = @"UIViewControllerScrollingHandler";
NSString *const UIViewControllerStatusBarView = @"UIViewControllerStatusBarView";
NSString *const UIViewControllerScrollView = @"UIViewControllerScrollView";

#pragma mark--- Properties

- (void)setScrollingHandler:(CCScrollingHandler *)handler
{
    objc_setAssociatedObject(self, (__bridge const void *)(UIViewControllerScrollingHandler), handler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CCScrollingHandler *)scrollingHandler
{
    return objc_getAssociatedObject(self, (__bridge const void *)(UIViewControllerScrollingHandler));
}

- (void)setStatusBarView:(UIView *)statusBarView
{
    objc_setAssociatedObject(self, (__bridge const void *)(UIViewControllerStatusBarView), statusBarView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)statusBarView
{
    return objc_getAssociatedObject(self, (__bridge const void *)(UIViewControllerStatusBarView));
}

- (void)setScrollView:(UIScrollView *)scrollView
{
    objc_setAssociatedObject(self, (__bridge const void *)(UIViewControllerScrollView), scrollView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIScrollView *)scrollView
{
    return objc_getAssociatedObject(self, (__bridge const void *)(UIViewControllerScrollView));
}

#pragma mark--- Gestures

- (void)statusBarViewTap:(UITapGestureRecognizer *)tap
{
    [self.scrollView setContentOffset:CGPointMake(0, -self.scrollView.contentInset.top) animated:YES];
}

#pragma mark--- UI

static UIWindow *fakeStatusBarWindow = nil;
- (UIWindow *)fakeStatusBarWindow
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fakeStatusBarWindow = [[CCStatusBarWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        fakeStatusBarWindow.backgroundColor = [UIColor clearColor];
        fakeStatusBarWindow.userInteractionEnabled = YES;
        fakeStatusBarWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        fakeStatusBarWindow.windowLevel = UIWindowLevelStatusBar;
        fakeStatusBarWindow.hidden = NO;
    });
    return fakeStatusBarWindow;
}

- (void)createStatusBarView
{
    CGRect frame = [UIApplication sharedApplication].statusBarFrame;
    frame.size.height *= 2;
    self.statusBarView = [[UIView alloc] initWithFrame:frame];
    self.statusBarView.clipsToBounds = YES;
    self.statusBarView.backgroundColor = [UIColor clearColor];
    UIView *statusBarImageView = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:NO];
    UIView *statusBarImageViewClipView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height * 0.5)];
    statusBarImageViewClipView.clipsToBounds = YES;
    [statusBarImageViewClipView addSubview:statusBarImageView];
    [self.statusBarView addSubview:statusBarImageViewClipView];
    [self.statusBarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(statusBarViewTap:)]];
    [self.fakeStatusBarWindow addSubview:self.statusBarView];
}

#pragma mark--- Helpers

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY > -scrollView.contentInset.top) {
        if (!self.statusBarView) {
            [self createStatusBarView];
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        }
        self.statusBarView.frame = (CGRect){.origin = CGPointMake(self.statusBarView.frame.origin.x, MAX(-self.statusBarView.frame.size.height * 0.5, -scrollView.contentInset.top - offsetY)), .size = self.statusBarView.frame.size};
    } else {
        if (self.statusBarView) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
            [self.statusBarView removeFromSuperview];
            self.statusBarView = nil;
        }
    }
}

#pragma mark--- Interface

- (void)enableStatusBarScrollingAlongScrollView:(UIScrollView *)scrollView
{
    NSParameterAssert(scrollView);
    
    __weak id wSelf = self;
    self.scrollingHandler = [[CCScrollingHandler alloc] initWithDidScrollBlock:^(UIScrollView *scrollView) {
        [wSelf scrollViewDidScroll:scrollView];
    }];
    
    self.scrollView = scrollView;
    [scrollView addObserver:self.scrollingHandler forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:(__bridge void *)(UIViewControllerScrollingStatusBarContext)];
}

- (void)disableStatusBarScrollingAlongScrollView:(UITableView *)scrollView
{
    self.scrollView = nil;
    [scrollView removeObserver:self.scrollingHandler forKeyPath:@"contentOffset" context:(__bridge void *)(UIViewControllerScrollingStatusBarContext)];
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
        
        if (result && !error)
        {
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
    
    UIViewController *vc = [self topViewController];
    void (^handler)(UIViewController *vc) = [vc backButtonHandler];
    if (handler) {
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(self);
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self popViewControllerAnimated:YES];
        });
    }
    
    return NO;
}

@end