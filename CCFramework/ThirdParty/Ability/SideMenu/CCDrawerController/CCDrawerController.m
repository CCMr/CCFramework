//
// CCDrawerController.h
// CCFramework
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


#import "CCDrawerController.h"
#import "UIViewController+CCDrawerController.h"
#import "CCDrawerVisualState.h"
#import <QuartzCore/QuartzCore.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
#define IF_IOS7_OR_GREATER(...) \
if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_6_1) \
{ \
__VA_ARGS__ \
}
#else
#define IF_IOS7_OR_GREATER(...)
#endif

CGFloat const CCDrawerDefaultWidth = 320.0f;
CGFloat const CCDrawerDefaultAnimationVelocity = 840.0f;

NSTimeInterval const CCDrawerDefaultFullAnimationDelay = 0.10f;

CGFloat const CCDrawerDefaultBounceDistance = 50.0f;

NSTimeInterval const CCDrawerDefaultBounceAnimationDuration = 0.2f;
CGFloat const CCDrawerDefaultSecondBounceDistancePercentage = .25f;

CGFloat const CCDrawerDefaultShadowRadius = 10.0f;
CGFloat const CCDrawerDefaultShadowOpacity = 0.8;

NSTimeInterval const CCDrawerMinimumAnimationDuration = 0.15f;

CGFloat const CCDrawerBezelRange = 20.0f;

CGFloat const CCDrawerPanVelocityXAnimationThreshold = 200.0f;

/** The amount of overshoot that is panned linearly. The remaining percentage nonlinearly asymptotes to the max percentage. */
CGFloat const CCDrawerOvershootLinearRangePercentage = 0.75f;

/** The percent of the possible overshoot width to use as the actual overshoot percentage. */
CGFloat const CCDrawerOvershootPercentage = 0.1f;

typedef BOOL (^CCDrawerGestureShouldRecognizeTouchBlock)(CCDrawerController *drawerController, UIGestureRecognizer *gesture, UITouch *touch);
typedef void (^CCDrawerGestureCompletionBlock)(CCDrawerController *drawerController, UIGestureRecognizer *gesture);

static CAKeyframeAnimation *bounceKeyFrameAnimationForDistanceOnView(CGFloat distance, UIView *view)
{
    CGFloat factors[32] = {0, 32, 60, 83, 100, 114, 124, 128, 128, 124, 114, 100, 83, 60, 32,
        0, 24, 42, 54, 62, 64, 62, 54, 42, 24, 0, 18, 28, 32, 28, 18, 0};
    
    NSMutableArray *values = [NSMutableArray array];
    
    for (int i = 0; i < 32; i++) {
        CGFloat positionOffset = factors[i] / 128.0f * distance + CGRectGetMidX(view.bounds);
        [values addObject:@(positionOffset)];
    }
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
    animation.repeatCount = 1;
    animation.duration = .8;
    animation.fillMode = kCAFillModeForwards;
    animation.values = values;
    animation.removedOnCompletion = YES;
    animation.autoreverses = NO;
    
    return animation;
}

static NSString *CCDrawerLeftDrawerKey = @"CCDrawerLeftDrawer";
static NSString *CCDrawerRightDrawerKey = @"CCDrawerRightDrawer";
static NSString *CCDrawerCenterKey = @"CCDrawerCenter";
static NSString *CCDrawerOpenSideKey = @"CCDrawerOpenSide";

@interface CCDrawerCenterContainerView : UIView
@property(nonatomic, assign) CCDrawerOpenCenterInteractionMode centerInteractionMode;
@property(nonatomic, assign) CCDrawerSide openSide;
@end

@implementation CCDrawerCenterContainerView

- (UIView *)hitTest:(CGPoint)point
          withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point
                           withEvent:event];
    if (hitView &&
        self.openSide != CCDrawerSideNone) {
        UINavigationBar *navBar = [self navigationBarContainedWithinSubviewsOfView:self];
        CGRect navBarFrame = [navBar convertRect:navBar.bounds toView:self];
        if ((self.centerInteractionMode == CCDrawerOpenCenterInteractionModeNavigationBarOnly &&
             CGRectContainsPoint(navBarFrame, point) == NO) ||
            self.centerInteractionMode == CCDrawerOpenCenterInteractionModeNone) {
            hitView = nil;
        }
    }
    return hitView;
}

- (UINavigationBar *)navigationBarContainedWithinSubviewsOfView:(UIView *)view
{
    UINavigationBar *navBar = nil;
    for (UIView *subview in [view subviews]) {
        if ([view isKindOfClass:[UINavigationBar class]]) {
            navBar = (UINavigationBar *)view;
            break;
        } else {
            navBar = [self navigationBarContainedWithinSubviewsOfView:subview];
            if (navBar != nil) {
                break;
            }
        }
    }
    return navBar;
}
@end

@interface CCDrawerController () <UIGestureRecognizerDelegate> {
    CGFloat _maximumRightDrawerWidth;
    CGFloat _maximumLeftDrawerWidth;
    UIColor *_statusBarViewBackgroundColor;
}

@property(nonatomic, assign, readwrite) CCDrawerSide openSide;

@property(nonatomic, strong) UIView *childControllerContainerView;
@property(nonatomic, strong) CCDrawerCenterContainerView *centerContainerView;
@property(nonatomic, strong) UIView *dummyStatusBarView;

@property(nonatomic, assign) CGRect startingPanRect;
@property(nonatomic, copy) CCDrawerControllerDrawerVisualStateBlock drawerVisualState;
@property(nonatomic, copy) CCDrawerGestureShouldRecognizeTouchBlock gestureShouldRecognizeTouch;
@property(nonatomic, copy) CCDrawerGestureCompletionBlock gestureCompletion;
@property(nonatomic, assign, getter=isAnimatingDrawer) BOOL animatingDrawer;

@property (nonatomic, assign, readwrite) BOOL panGestureEnabled;

@property(strong, readwrite, nonatomic) UIImageView *backgroundImageView;

@end

@implementation CCDrawerController

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonSetup];
    }
    return self;
}

- (instancetype)initWithCenterViewController:(UIViewController *)centerViewController
                    leftDrawerViewController:(UIViewController *)leftDrawerViewController
                   rightDrawerViewController:(UIViewController *)rightDrawerViewController
{
    NSParameterAssert(centerViewController);
    self = [super init];
    if (self) {
        [self setCenterViewController:centerViewController];
        [self setLeftDrawerViewController:leftDrawerViewController];
        [self setRightDrawerViewController:rightDrawerViewController];
    }
    return self;
}

- (instancetype)initWithCenterViewController:(UIViewController *)centerViewController
                    leftDrawerViewController:(UIViewController *)leftDrawerViewController
{
    return [self initWithCenterViewController:centerViewController
                     leftDrawerViewController:leftDrawerViewController
                    rightDrawerViewController:nil];
}

- (instancetype)initWithCenterViewController:(UIViewController *)centerViewController
                   rightDrawerViewController:(UIViewController *)rightDrawerViewController
{
    return [self initWithCenterViewController:centerViewController
                     leftDrawerViewController:nil
                    rightDrawerViewController:rightDrawerViewController];
}

- (void)commonSetup
{
    [self setInteractivePopGestureRecognizerEnabled:YES];
    [self setDrawerAnimationType:CCDrawerAnimationTypeParallax];
    [self setPanGestureEnabled:YES];
    [self setMaximumLeftDrawerWidth:CCDrawerDefaultWidth];
    [self setMaximumRightDrawerWidth:CCDrawerDefaultWidth];
    
    [self setAnimationVelocity:CCDrawerDefaultAnimationVelocity];
    
    [self setShowsShadow:YES];
    [self setShouldStretchDrawer:YES];
    
    [self setOpenDrawerGestureModeMask:CCOpenDrawerGestureModeNone];
    [self setCloseDrawerGestureModeMask:CCCloseDrawerGestureModeNone];
    [self setCenterHiddenInteractionMode:CCDrawerOpenCenterInteractionModeNavigationBarOnly];
    
    // set shadow related default values
    [self setShadowOpacity:CCDrawerDefaultShadowOpacity];
    [self setShadowRadius:CCDrawerDefaultShadowRadius];
    [self setShadowOffset:CGSizeMake(0, -3)];
    [self setShadowColor:[UIColor clearColor]];
    
    // set default bezel range for panGestureReconizer
    [self setBezelPanningCenterViewRange:CCDrawerBezelRange];
    
    // set defualt panVelocityXAnimationThreshold
    [self setPanVelocityXAnimationThreshold:CCDrawerPanVelocityXAnimationThreshold];
}

#pragma mark - State Restoration
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    if (self.leftDrawerViewController) {
        [coder encodeObject:self.leftDrawerViewController forKey:CCDrawerLeftDrawerKey];
    }
    
    if (self.rightDrawerViewController) {
        [coder encodeObject:self.rightDrawerViewController forKey:CCDrawerRightDrawerKey];
    }
    
    if (self.centerViewController) {
        [coder encodeObject:self.centerViewController forKey:CCDrawerCenterKey];
    }
    
    [coder encodeInteger:self.openSide forKey:CCDrawerOpenSideKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    UIViewController *controller;
    CCDrawerSide openside;
    
    [super decodeRestorableStateWithCoder:coder];
    
    if ((controller = [coder decodeObjectForKey:CCDrawerLeftDrawerKey])) {
        self.leftDrawerViewController = controller;
    }
    
    if ((controller = [coder decodeObjectForKey:CCDrawerRightDrawerKey])) {
        self.rightDrawerViewController = controller;
    }
    
    if ((controller = [coder decodeObjectForKey:CCDrawerCenterKey])) {
        self.centerViewController = controller;
    }
    
    if ((openside = [coder decodeIntegerForKey:CCDrawerOpenSideKey])) {
        [self openDrawerSide:openside animated:false completion:nil];
    }
}
#pragma mark - Open/Close methods
- (void)toggleDrawerSide:(CCDrawerSide)drawerSide
                animated:(BOOL)animated
              completion:(void (^)(BOOL finished))completion
{
    NSParameterAssert(drawerSide != CCDrawerSideNone);
    if (self.openSide == CCDrawerSideNone) {
        [self openDrawerSide:drawerSide animated:animated completion:completion];
    } else {
        if ((drawerSide == CCDrawerSideLeft &&
             self.openSide == CCDrawerSideLeft) ||
            (drawerSide == CCDrawerSideRight &&
             self.openSide == CCDrawerSideRight)) {
                [self closeDrawerAnimated:animated completion:completion];
            } else if (completion) {
                completion(NO);
            }
    }
}

- (void)closeDrawerAnimated:(BOOL)animated
                 completion:(void (^)(BOOL finished))completion
{
    [self closeDrawerAnimated:animated
                     velocity:self.animationVelocity
             animationOptions:UIViewAnimationOptionCurveEaseInOut
                   completion:completion];
}

- (void)closeDrawerAnimated:(BOOL)animated
                   velocity:(CGFloat)velocity
           animationOptions:(UIViewAnimationOptions)options
                 completion:(void (^)(BOOL finished))completion
{
    if (self.isAnimatingDrawer) {
        if (completion) {
            completion(NO);
        }
    } else {
        [self setAnimatingDrawer:animated];
        CGRect newFrame = self.childControllerContainerView.bounds;
        
        CGFloat distance = ABS(CGRectGetMinX(self.centerContainerView.frame));
        NSTimeInterval duration = MAX(distance / ABS(velocity), CCDrawerMinimumAnimationDuration);
        
        BOOL leftDrawerVisible = CGRectGetMinX(self.centerContainerView.frame) > 0;
        BOOL rightDrawerVisible = CGRectGetMinX(self.centerContainerView.frame) < 0;
        
        CCDrawerSide visibleSide = CCDrawerSideNone;
        CGFloat percentVisble = 0.0;
        
        if (leftDrawerVisible) {
            CGFloat visibleDrawerPoints = CGRectGetMinX(self.centerContainerView.frame);
            percentVisble = MAX(0.0, visibleDrawerPoints / self.maximumLeftDrawerWidth);
            visibleSide = CCDrawerSideLeft;
        } else if (rightDrawerVisible) {
            CGFloat visibleDrawerPoints = CGRectGetWidth(self.centerContainerView.frame) - CGRectGetMaxX(self.centerContainerView.frame);
            percentVisble = MAX(0.0, visibleDrawerPoints / self.maximumRightDrawerWidth);
            visibleSide = CCDrawerSideRight;
        }
        
        UIViewController *sideDrawerViewController = [self sideDrawerViewControllerForSide:visibleSide];
        
        [self updateDrawerVisualStateForDrawerSide:visibleSide percentVisible:percentVisble];
        
        [sideDrawerViewController beginAppearanceTransition:NO animated:animated];
        
        [UIView animateWithDuration:(animated ? duration : 0.0)
                              delay:0.0
                            options:options
                         animations:^{
                             [self setNeedsStatusBarAppearanceUpdateIfSupported];
                             [self.centerContainerView setFrame:newFrame];
                             [self updateDrawerVisualStateForDrawerSide:visibleSide percentVisible:0.0];
                         }
                         completion:^(BOOL finished) {
                             [sideDrawerViewController endAppearanceTransition];
                             [self setOpenSide:CCDrawerSideNone];
                             [self resetDrawerVisualStateForDrawerSide:visibleSide];
                             [self setAnimatingDrawer:NO];
                             if(completion){
                                 completion(finished);
                             }
                         }];
    }
}

- (void)openDrawerSide:(CCDrawerSide)drawerSide
              animated:(BOOL)animated
            completion:(void (^)(BOOL finished))completion
{
    NSParameterAssert(drawerSide != CCDrawerSideNone);
    
    [self openDrawerSide:drawerSide
                animated:animated
                velocity:self.animationVelocity
        animationOptions:UIViewAnimationOptionCurveEaseInOut
              completion:completion];
}

- (void)openDrawerSide:(CCDrawerSide)drawerSide
              animated:(BOOL)animated
              velocity:(CGFloat)velocity
      animationOptions:(UIViewAnimationOptions)options
            completion:(void (^)(BOOL finished))completion
{
    NSParameterAssert(drawerSide != CCDrawerSideNone);
    if (self.isAnimatingDrawer) {
        if (completion) {
            completion(NO);
        }
    } else {
        [self setAnimatingDrawer:animated];
        UIViewController *sideDrawerViewController = [self sideDrawerViewControllerForSide:drawerSide];
        if (self.openSide != drawerSide) {
            [self prepareToPresentDrawer:drawerSide animated:animated];
        }
        
        if (sideDrawerViewController) {
            CGRect newFrame;
            CGRect oldFrame = self.centerContainerView.frame;
            if (drawerSide == CCDrawerSideLeft) {
                newFrame = self.centerContainerView.frame;
                newFrame.origin.x = self.maximumLeftDrawerWidth;
            } else {
                newFrame = self.centerContainerView.frame;
                newFrame.origin.x = 0 - self.maximumRightDrawerWidth;
            }
            
            CGFloat distance = ABS(CGRectGetMinX(oldFrame) - newFrame.origin.x);
            NSTimeInterval duration = MAX(distance / ABS(velocity), CCDrawerMinimumAnimationDuration);
            
            [UIView
             animateWithDuration:(animated ? duration : 0.0)
             delay:0.0
             options:options
             animations:^{
                 [self setNeedsStatusBarAppearanceUpdateIfSupported];
                 [self.centerContainerView setFrame:newFrame];
                 [self updateDrawerVisualStateForDrawerSide:drawerSide percentVisible:1.0];
             }
             completion:^(BOOL finished) {
                 //End the appearance transition if it already wasn't open.
                 if(drawerSide != self.openSide){
                     [sideDrawerViewController endAppearanceTransition];
                 }
                 [self setOpenSide:drawerSide];
                 
                 [self resetDrawerVisualStateForDrawerSide:drawerSide];
                 [self setAnimatingDrawer:NO];
                 if(completion){
                     completion(finished);
                 }
             }];
        }
    }
}

#pragma mark - Updating the Center View Controller
//If animated is NO, then we need to handle all the appearance calls within this method. Otherwise,
//let the method calling this one handle proper appearance methods since they will have more context
- (void)setCenterViewController:(UIViewController *)centerViewController
                       animated:(BOOL)animated
{
    if ([self.centerViewController isEqual:centerViewController]) {
        return;
    }
    
    if (_centerContainerView == nil) {
        // also fixed below in the getter for `childControllerContainerView`. Turns out we have
        // two center container views getting added to the view during init,
        // because the first request self.centerContainerView.bounds was kicking off a
        // viewDidLoad, which caused us to be able to fall through this check twice.
        //
        //The fix is to grab the bounds, and then check again that the child container view has
        //not been created.
        
        CGRect centerFrame = self.childControllerContainerView.bounds;
        if (_centerContainerView == nil) {
            _centerContainerView = [[CCDrawerCenterContainerView alloc] initWithFrame:centerFrame];
            [self.centerContainerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
            [self.centerContainerView setBackgroundColor:[UIColor clearColor]];
            [self.centerContainerView setOpenSide:self.openSide];
            [self.centerContainerView setCenterInteractionMode:self.centerHiddenInteractionMode];
            [self.childControllerContainerView addSubview:self.centerContainerView];
        }
    }
    
    UIViewController *oldCenterViewController = self.centerViewController;
    if (oldCenterViewController) {
        [oldCenterViewController willMoveToParentViewController:nil];
        if (animated == NO) {
            [oldCenterViewController beginAppearanceTransition:NO animated:NO];
        }
        [oldCenterViewController.view removeFromSuperview];
        if (animated == NO) {
            [oldCenterViewController endAppearanceTransition];
        }
        [oldCenterViewController removeFromParentViewController];
    }
    
    _centerViewController = centerViewController;
    
    [self addChildViewController:self.centerViewController];
    [self.centerViewController.view setFrame:self.childControllerContainerView.bounds];
    [self.centerContainerView addSubview:self.centerViewController.view];
    [self.childControllerContainerView bringSubviewToFront:self.centerContainerView];
    [self.centerViewController.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self updateShadowForCenterView];
    
    if (animated == NO) {
        // If drawer is offscreen, then viewWillAppear: will take care of this
        if (self.view.window) {
            [self.centerViewController beginAppearanceTransition:YES animated:NO];
            [self.centerViewController endAppearanceTransition];
        }
        [self.centerViewController didMoveToParentViewController:self];
    }
}

#pragma mark :. 无弹动效果跳转页面

/**
 *  @author CC, 2016-01-06
 *  
 *  @brief  跳转页面
 *
 *  @param newCenterViewController 跳转页面对象
 */
- (void)setCenterViewControllerWithPresen:(UIViewController *)newCenterViewController
{
    [self setCenterViewControllerWithPresen:newCenterViewController
                         withCloseAnimation:YES];
}

/**
 *  @author CC, 2016-01-06
 *  
 *  @brief  跳转页面
 *
 *  @param newCenterViewController 跳转页面对象
 *  @param animated                动画
 */
- (void)setCenterViewControllerWithPresen:(UIViewController *)newCenterViewController
                       withCloseAnimation:(BOOL)animated
{
    [self setCenterViewControllerWithPresen:newCenterViewController
                         withCloseAnimation:animated 
                                 completion:nil];
}

/**
 *  @author CC, 2016-01-06
 *  
 *  @brief  跳转页面
 *
 *  @param newCenterViewController 跳转页面对象
 *  @param animated                动画
 *  @param completion              完成回调
 */
- (void)setCenterViewControllerWithPresen:(UIViewController *)newCenterViewController
                       withCloseAnimation:(BOOL)animated
                               completion:(void (^)(BOOL finished))completion
{
    [self jumpViewControllerAnimation:YES
                 CenterViewController:newCenterViewController
                   withCloseAnimation:animated
                           completion:completion];
}

/**
 *  @author CC, 2016-01-06
 *  
 *  @brief  推送页面
 *
 *  @param newCenterViewController 跳转页面对象
 */
- (void)pushCenterViewController:(UIViewController *)newCenterViewController
{
    [self pushCenterViewController:newCenterViewController 
                withCloseAnimation:YES];
}


/**
 *  @author CC, 2016-01-06
 *  
 *  @brief  推送页面
 *
 *  @param newCenterViewController 跳转页面对象
 *  @param animated                动画
 */
- (void)pushCenterViewController:(UIViewController *)newCenterViewController
              withCloseAnimation:(BOOL)animated
{
    [self pushCenterViewController:newCenterViewController 
                withCloseAnimation:animated 
                        completion:nil];
}

/**
 *  @author CC, 2016-01-06
 *  
 *  @brief  推送页面
 *
 *  @param newCenterViewController 跳转页面对象
 *  @param animated                动画
 *  @param completion              完成回调
 */
- (void)pushCenterViewController:(UIViewController *)newCenterViewController
              withCloseAnimation:(BOOL)animated
                      completion:(void (^)(BOOL finished))completion
{
    [self jumpViewControllerAnimation:NO
                 CenterViewController:newCenterViewController
                   withCloseAnimation:animated
                           completion:completion];
}

/**
 *  @author CC, 2016-01-06
 *  
 *  @brief  跳转页面效果
 *
 *  @param model                   跳转模式
 *  @param newCenterViewController 跳转页面对象
 *  @param animated                动画
 *  @param completion              完成回调
 */
- (void)jumpViewControllerAnimation:(BOOL)model
               CenterViewController:(UIViewController *)newCenterViewController
                 withCloseAnimation:(BOOL)animated
                         completion:(void (^)(BOOL finished))completion
{
    if (self.openSide == CCDrawerSideNone) { //If a side drawer isn't open, there is nothing to animate...
        animated = NO;
    }
    
    BOOL forwardAppearanceMethodsToCenterViewController = ([self.centerViewController isEqual:newCenterViewController] == NO);
    
    UIViewController *oldCenterViewController = self.centerViewController;
    // This needs to be refactored so the appearance logic is easier
    // to follow across the multiple close/setter methods
    if (animated && forwardAppearanceMethodsToCenterViewController) {
        [oldCenterViewController beginAppearanceTransition:NO animated:NO];
    }
    
    [self jumpViewControllerMode:model
            CenterViewController:newCenterViewController
                        Animated:animated];
    
    // Related to note above.
    if (animated && forwardAppearanceMethodsToCenterViewController) {
        [oldCenterViewController endAppearanceTransition];
    }
    
    if (animated) {
        [self updateDrawerVisualStateForDrawerSide:self.openSide percentVisible:1.0];
        if (forwardAppearanceMethodsToCenterViewController) {
            [self.centerViewController beginAppearanceTransition:YES animated:animated];
        }
        [self closeDrawerAnimated:animated
                       completion:^(BOOL finished) {
                           if (forwardAppearanceMethodsToCenterViewController) {
                               [self.centerViewController endAppearanceTransition];
                               [self.centerViewController didMoveToParentViewController:self];
                           }
                           if(completion){
                               completion(finished);
                           }
                       }];
    } else {
        if (completion) {
            completion(YES);
        }
    }
}

#pragma mark :. 弹动效果跳转页面

/**
 *  @author CC, 2016-01-06
 *  
 *  @brief  跳转页面
 *
 *  @param newCenterViewController 跳转的页面对象
 */
- (void)setCenterViewControllerWithFull:(UIViewController *)newCenterViewController
{
    [self setCenterViewControllerWithFull:newCenterViewController
                   withFullCloseAnimation:YES];
}

/**
 *  @author CC, 2016-01-06
 *  
 *  @brief  跳转页面
 *
 *  @param newCenterViewController 跳转的页面对象
 *  @param animated                动画
 */
- (void)setCenterViewControllerWithFull:(UIViewController *)newCenterViewController
                 withFullCloseAnimation:(BOOL)animated
{
    [self setCenterViewControllerWithFull:newCenterViewController
                   withFullCloseAnimation:animated
                               completion:nil];
}

/**
 *  @author CC, 2016-01-06
 *  
 *  @brief  跳转页面
 *
 *  @param newCenterViewController 跳转的页面对象
 *  @param animated                动画
 *  @param completion              完成回调
 */
- (void)setCenterViewControllerWithFull:(UIViewController *)newCenterViewController
                 withFullCloseAnimation:(BOOL)animated
                             completion:(void (^)(BOOL finished))completion
{
    [self jumpViewControllerAnimation:YES
                 CenterViewController:newCenterViewController
               withFullCloseAnimation:animated
                           completion:completion];
}

/**
 *  @author CC, 2016-01-06
 *  
 *  @brief  推送页面
 *
 *  @param newCenterViewController 推送的页面对象
 */
- (void)pushCenterViewControllerWithFull:(UIViewController *)newCenterViewController
{
    [self pushCenterViewControllerWithFull:newCenterViewController
                    withFullCloseAnimation:YES];
}

/**
 *  @author CC, 2016-01-06
 *  
 *  @brief  推送页面
 *
 *  @param newCenterViewController 推送的页面对象
 *  @param animated                动画
 */
- (void)pushCenterViewControllerWithFull:(UIViewController *)newCenterViewController
                  withFullCloseAnimation:(BOOL)animated
{
    [self pushCenterViewControllerWithFull:newCenterViewController
                    withFullCloseAnimation:animated
                                completion:nil];
}

/**
 *  @author CC, 2016-01-06
 *  
 *  @brief  推送页面
 *
 *  @param newCenterViewController 推送的页面对象
 *  @param animated                动画
 *  @param completion              完成回调
 */
- (void)pushCenterViewControllerWithFull:(UIViewController *)newCenterViewController
                  withFullCloseAnimation:(BOOL)animated
                              completion:(void (^)(BOOL finished))completion
{
    [self jumpViewControllerAnimation:NO
                 CenterViewController:newCenterViewController
               withFullCloseAnimation:animated
                           completion:completion];
}

/**
 *  @author CC, 2016-01-06
 *  
 *  @brief  跳转页面效果
 *
 *  @param model                   跳转模式
 *  @param newCenterViewController 跳转页面对象
 *  @param animated                动画
 *  @param completion              完成回调
 */
- (void)jumpViewControllerAnimation:(BOOL)model
               CenterViewController:(UIViewController *)newCenterViewController
             withFullCloseAnimation:(BOOL)animated
                         completion:(void (^)(BOOL finished))completion
{
    if (self.openSide != CCDrawerSideNone && animated) {
        BOOL forwardAppearanceMethodsToCenterViewController = ([self.centerViewController isEqual:newCenterViewController] == NO);
        
        UIViewController *sideDrawerViewController = [self sideDrawerViewControllerForSide:self.openSide];
        
        CGFloat targetClosePoint = 0.0f;
        if (self.openSide == CCDrawerSideRight) {
            targetClosePoint = -CGRectGetWidth(self.childControllerContainerView.bounds);
        } else if (self.openSide == CCDrawerSideLeft) {
            targetClosePoint = CGRectGetWidth(self.childControllerContainerView.bounds);
        }
        
        CGFloat distance = ABS(self.centerContainerView.frame.origin.x - targetClosePoint);
        NSTimeInterval firstDuration = [self animationDurationForAnimationDistance:distance];
        
        CGRect newCenterRect = self.centerContainerView.frame;
        
        [self setAnimatingDrawer:animated];
        
        UIViewController *oldCenterViewController = self.centerViewController;
        if (forwardAppearanceMethodsToCenterViewController) {
            [oldCenterViewController beginAppearanceTransition:NO animated:animated];
        }
        newCenterRect.origin.x = targetClosePoint;
        [UIView animateWithDuration:firstDuration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.centerContainerView setFrame:newCenterRect];
                             [sideDrawerViewController.view setFrame:self.childControllerContainerView.bounds];
                         }
                         completion:^(BOOL finished) {
                             
                             CGRect oldCenterRect = self.centerContainerView.frame;
                             
                             [self jumpViewControllerMode:model 
                                     CenterViewController:newCenterViewController 
                                                 Animated:animated];
                             
                             [self.centerContainerView setFrame:oldCenterRect];
                             [self updateDrawerVisualStateForDrawerSide:self.openSide percentVisible:1.0];
                             if(forwardAppearanceMethodsToCenterViewController) {
                                 [oldCenterViewController endAppearanceTransition];
                                 [self.centerViewController beginAppearanceTransition:YES animated:animated];
                             }
                             [sideDrawerViewController beginAppearanceTransition:NO animated:animated];
                             [UIView animateWithDuration:[self animationDurationForAnimationDistance:CGRectGetWidth(self.childControllerContainerView.bounds)]
                                                   delay:CCDrawerDefaultFullAnimationDelay
                                                 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                                  [self.centerContainerView setFrame:self.childControllerContainerView.bounds];
                                                  [self updateDrawerVisualStateForDrawerSide:self.openSide percentVisible:0.0];
                                              } completion:^(BOOL finished) {
                                                  if (forwardAppearanceMethodsToCenterViewController) {
                                                      [self.centerViewController endAppearanceTransition];
                                                      [self.centerViewController didMoveToParentViewController:self];
                                                  }
                                                  [sideDrawerViewController endAppearanceTransition];
                                                  [self resetDrawerVisualStateForDrawerSide:self.openSide];
                                                  
                                                  [sideDrawerViewController.view setFrame:sideDrawerViewController.cc_visibleDrawerFrame];
                                                  
                                                  [self setOpenSide:CCDrawerSideNone];
                                                  [self setAnimatingDrawer:NO];
                                                  if(completion){
                                                      completion(finished);
                                                  }
                                              }];
                         }];
    } else {
        [self jumpViewControllerMode:model
                CenterViewController:newCenterViewController
                            Animated:animated];
        
        if (self.openSide != CCDrawerSideNone) {
            
            [self closeDrawerAnimated:animated
                           completion:completion];
        } else if (completion) {
            
            completion(YES);
        }
    }
}

/**
 *  @author CC, 2016-01-06
 *  
 *  @brief  跳转页面模式
 *
 *  @param mode                    模式
 *  @param newCenterViewController 跳转页面对象
 *  @param animated                动画
 */
- (void)jumpViewControllerMode:(BOOL)mode
          CenterViewController:(UIViewController *)newCenterViewController
                      Animated:(BOOL)animated
{
    if (mode) {
        [self setCenterViewController:newCenterViewController animated:animated];
    } else {
        UINavigationController *navigationController;
        if ([self.centerViewController isKindOfClass:[UINavigationController class]]) {
            navigationController = (UINavigationController *)self.centerViewController;
        } else {
            UITabBarController *tabBar = (UITabBarController *)self.centerViewController;
            navigationController = [tabBar.viewControllers objectAtIndex:tabBar.selectedIndex];
        }
        
        [navigationController pushViewController:newCenterViewController animated:NO];
    }
}

#pragma mark - Size Methods
- (void)setMaximumLeftDrawerWidth:(CGFloat)width
                         animated:(BOOL)animated
                       completion:(void (^)(BOOL finished))completion
{
    [self setMaximumDrawerWidth:width
                        forSide:CCDrawerSideLeft
                       animated:animated
                     completion:completion];
}

- (void)setMaximumRightDrawerWidth:(CGFloat)width
                          animated:(BOOL)animated
                        completion:(void (^)(BOOL finished))completion
{
    [self setMaximumDrawerWidth:width
                        forSide:CCDrawerSideRight
                       animated:animated
                     completion:completion];
}

- (void)setMaximumDrawerWidth:(CGFloat)width
                      forSide:(CCDrawerSide)drawerSide
                     animated:(BOOL)animated
                   completion:(void (^)(BOOL finished))completion
{
    NSParameterAssert(width > 0);
    NSParameterAssert(drawerSide != CCDrawerSideNone);
    
    UIViewController *sideDrawerViewController = [self sideDrawerViewControllerForSide:drawerSide];
    CGFloat oldWidth = 0.f;
    NSInteger drawerSideOriginCorrection = 1;
    if (drawerSide == CCDrawerSideLeft) {
        oldWidth = _maximumLeftDrawerWidth;
        _maximumLeftDrawerWidth = width;
    } else if (drawerSide == CCDrawerSideRight) {
        oldWidth = _maximumRightDrawerWidth;
        _maximumRightDrawerWidth = width;
        drawerSideOriginCorrection = -1;
    }
    
    CGFloat distance = ABS(width - oldWidth);
    NSTimeInterval duration = [self animationDurationForAnimationDistance:distance];
    
    if (self.openSide == drawerSide) {
        CGRect newCenterRect = self.centerContainerView.frame;
        newCenterRect.origin.x = drawerSideOriginCorrection * width;
        [UIView
         animateWithDuration:(animated ? duration : 0)
         delay:0.0
         options:UIViewAnimationOptionCurveEaseInOut
         animations:^{
             [self.centerContainerView setFrame:newCenterRect];
             [sideDrawerViewController.view setFrame:sideDrawerViewController.cc_visibleDrawerFrame];
         }
         completion:^(BOOL finished) {
             if(completion != nil){
                 completion(finished);
             }
         }];
    } else {
        [sideDrawerViewController.view setFrame:sideDrawerViewController.cc_visibleDrawerFrame];
        if (completion != nil) {
            completion(YES);
        }
    }
}

#pragma mark - Bounce Methods
- (void)bouncePreviewForDrawerSide:(CCDrawerSide)drawerSide
                        completion:(void (^)(BOOL finished))completion
{
    NSParameterAssert(drawerSide != CCDrawerSideNone);
    [self bouncePreviewForDrawerSide:drawerSide
                            distance:CCDrawerDefaultBounceDistance
                          completion:completion];
}

- (void)bouncePreviewForDrawerSide:(CCDrawerSide)drawerSide
                          distance:(CGFloat)distance
                        completion:(void (^)(BOOL finished))completion
{
    NSParameterAssert(drawerSide != CCDrawerSideNone);
    
    UIViewController *sideDrawerViewController = [self sideDrawerViewControllerForSide:drawerSide];
    
    if (sideDrawerViewController == nil ||
        self.openSide != CCDrawerSideNone) {
        if (completion) {
            completion(NO);
        }
        return;
    } else {
        [self prepareToPresentDrawer:drawerSide animated:YES];
        
        [self updateDrawerVisualStateForDrawerSide:drawerSide percentVisible:1.0];
        
        [CATransaction begin];
        [CATransaction
         setCompletionBlock:^{
             [sideDrawerViewController endAppearanceTransition];
             [sideDrawerViewController beginAppearanceTransition:NO animated:NO];
             [sideDrawerViewController endAppearanceTransition];
             if(completion){
                 completion(YES);
             }
         }];
        
        CGFloat modifier = ((drawerSide == CCDrawerSideLeft) ? 1.0 : -1.0);
        CAKeyframeAnimation *animation = bounceKeyFrameAnimationForDistanceOnView(distance * modifier, self.centerContainerView);
        [self.centerContainerView.layer addAnimation:animation forKey:@"bouncing"];
        
        [CATransaction commit];
    }
}

#pragma mark - Setting Drawer Visual State
- (void)setDrawerVisualStateBlock:(void (^)(CCDrawerController *, CCDrawerSide, CGFloat))drawerVisualStateBlock
{
    [self setDrawerVisualState:drawerVisualStateBlock];
}

#pragma mark - Setting Custom Gesture Handler Block
- (void)setGestureShouldRecognizeTouchBlock:(BOOL (^)(CCDrawerController *, UIGestureRecognizer *, UITouch *))gestureShouldRecognizeTouchBlock
{
    [self setGestureShouldRecognizeTouch:gestureShouldRecognizeTouchBlock];
}

#pragma mark - Setting the Gesture Completion Block
- (void)setGestureCompletionBlock:(void (^)(CCDrawerController *, UIGestureRecognizer *))gestureCompletionBlock
{
    [self setGestureCompletion:gestureCompletionBlock];
}

#pragma mark - Subclass Methods
- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    return NO;
}

- (BOOL)shouldAutomaticallyForwardRotationMethods
{
    return NO;
}

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers
{
    return NO;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    [self setupGestureRecognizers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.centerViewController beginAppearanceTransition:YES animated:animated];
    
    if (self.openSide == CCDrawerSideLeft) {
        [self.leftDrawerViewController beginAppearanceTransition:YES animated:animated];
    } else if (self.openSide == CCDrawerSideRight) {
        [self.rightDrawerViewController beginAppearanceTransition:YES animated:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateShadowForCenterView];
    [self.centerViewController endAppearanceTransition];
    
    if (self.openSide == CCDrawerSideLeft) {
        [self.leftDrawerViewController endAppearanceTransition];
    } else if (self.openSide == CCDrawerSideRight) {
        [self.rightDrawerViewController endAppearanceTransition];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.centerViewController beginAppearanceTransition:NO animated:animated];
    if (self.openSide == CCDrawerSideLeft) {
        [self.leftDrawerViewController beginAppearanceTransition:NO animated:animated];
    } else if (self.openSide == CCDrawerSideRight) {
        [self.rightDrawerViewController beginAppearanceTransition:NO animated:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.centerViewController endAppearanceTransition];
    if (self.openSide == CCDrawerSideLeft) {
        [self.leftDrawerViewController endAppearanceTransition];
    } else if (self.openSide == CCDrawerSideRight) {
        [self.rightDrawerViewController endAppearanceTransition];
    }
}

#pragma mark Rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    //If a rotation begins, we are going to cancel the current gesture and reset transform and anchor points so everything works correctly
    BOOL gestureInProgress = NO;
    for (UIGestureRecognizer *gesture in self.view.gestureRecognizers) {
        if (gesture.state == UIGestureRecognizerStateChanged) {
            [gesture setEnabled:NO];
            [gesture setEnabled:YES];
            gestureInProgress = YES;
        }
        if (gestureInProgress) {
            [self resetDrawerVisualStateForDrawerSide:self.openSide];
        }
    }
    if ([self needsManualForwardingOfRotationEvents]) {
        for (UIViewController *childViewController in self.childViewControllers) {
            [childViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
        }
    }
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    //We need to support the shadow path rotation animation
    if (self.showsShadow) {
        CGPathRef oldShadowPath = self.centerContainerView.layer.shadowPath;
        if (oldShadowPath) {
            CFRetain(oldShadowPath);
        }
        
        [self updateShadowForCenterView];
        
        if (oldShadowPath) {
            [self.centerContainerView.layer addAnimation:((^{
                CABasicAnimation *transition = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
                transition.fromValue = (__bridge id)oldShadowPath;
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.duration = duration;
                return transition;
            })())forKey:@"transition"];
            CFRelease(oldShadowPath);
        }
    }
    
    if ([self needsManualForwardingOfRotationEvents]) {
        for (UIViewController *childViewController in self.childViewControllers) {
            [childViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
        }
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

#pragma mark - 转屏
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
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


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    if ([self needsManualForwardingOfRotationEvents]) {
        for (UIViewController *childViewController in self.childViewControllers) {
            [childViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
        }
    }
}

#pragma mark - Setters

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    if (self.backgroundImageView)
        self.backgroundImageView.image = backgroundImage;
}

- (void)setRightDrawerViewController:(UIViewController *)rightDrawerViewController
{
    [self setDrawerViewController:rightDrawerViewController
                          forSide:CCDrawerSideRight];
}

- (void)setLeftDrawerViewController:(UIViewController *)leftDrawerViewController
{
    [self setDrawerViewController:leftDrawerViewController
                          forSide:CCDrawerSideLeft];
}

- (void)setDrawerViewController:(UIViewController *)viewController
                        forSide:(CCDrawerSide)drawerSide
{
    NSParameterAssert(drawerSide != CCDrawerSideNone);
    
    UIViewController *currentSideViewController = [self sideDrawerViewControllerForSide:drawerSide];
    
    if (currentSideViewController == viewController) {
        return;
    }
    
    if (currentSideViewController != nil) {
        [currentSideViewController beginAppearanceTransition:NO animated:NO];
        [currentSideViewController.view removeFromSuperview];
        [currentSideViewController endAppearanceTransition];
        [currentSideViewController willMoveToParentViewController:nil];
        [currentSideViewController removeFromParentViewController];
    }
    
    UIViewAutoresizing autoResizingMask = 0;
    if (drawerSide == CCDrawerSideLeft) {
        _leftDrawerViewController = viewController;
        autoResizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        
    } else if (drawerSide == CCDrawerSideRight) {
        _rightDrawerViewController = viewController;
        autoResizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    }
    
    if (viewController) {
        [self addChildViewController:viewController];
        
        if ((self.openSide == drawerSide) &&
            [self.childControllerContainerView.subviews containsObject:self.centerContainerView]) {
            [self.childControllerContainerView insertSubview:viewController.view belowSubview:self.centerContainerView];
            [viewController beginAppearanceTransition:YES animated:NO];
            [viewController endAppearanceTransition];
        } else {
            [self.childControllerContainerView addSubview:viewController.view];
            [self.childControllerContainerView sendSubviewToBack:viewController.view];
            [viewController.view setHidden:YES];
        }
        [viewController didMoveToParentViewController:self];
        [viewController.view setAutoresizingMask:autoResizingMask];
        [viewController.view setFrame:viewController.cc_visibleDrawerFrame];
    }
}

- (void)setCenterViewController:(UIViewController *)centerViewController
{
    [self setCenterViewController:centerViewController
                         animated:NO];
}

- (void)setShowsShadow:(BOOL)showsShadow
{
    _showsShadow = showsShadow;
    [self updateShadowForCenterView];
}

- (void)setShadowRadius:(CGFloat)shadowRadius
{
    _shadowRadius = shadowRadius;
    [self updateShadowForCenterView];
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity
{
    _shadowOpacity = shadowOpacity;
    [self updateShadowForCenterView];
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
    _shadowOffset = shadowOffset;
    [self updateShadowForCenterView];
}

- (void)setShadowColor:(UIColor *)shadowColor
{
    _shadowColor = shadowColor;
    [self updateShadowForCenterView];
}

- (void)setOpenSide:(CCDrawerSide)openSide
{
    if (_openSide != openSide) {
        _openSide = openSide;
        [self.centerContainerView setOpenSide:openSide];
        if (openSide == CCDrawerSideNone) {
            [self.leftDrawerViewController.view setHidden:YES];
            [self.rightDrawerViewController.view setHidden:YES];
        }
        [self setNeedsStatusBarAppearanceUpdateIfSupported];
    }
}

- (void)setCenterHiddenInteractionMode:(CCDrawerOpenCenterInteractionMode)centerHiddenInteractionMode
{
    if (_centerHiddenInteractionMode != centerHiddenInteractionMode) {
        _centerHiddenInteractionMode = centerHiddenInteractionMode;
        [self.centerContainerView setCenterInteractionMode:centerHiddenInteractionMode];
    }
}

- (void)setMaximumLeftDrawerWidth:(CGFloat)maximumLeftDrawerWidth
{
    [self setMaximumLeftDrawerWidth:maximumLeftDrawerWidth
                           animated:NO
                         completion:nil];
}

- (void)setMaximumRightDrawerWidth:(CGFloat)maximumRightDrawerWidth
{
    [self setMaximumRightDrawerWidth:maximumRightDrawerWidth
                            animated:NO
                          completion:nil];
}

- (void)setShowsStatusBarBackgroundView:(BOOL)showsDummyStatusBar
{
    if (showsDummyStatusBar != _showsStatusBarBackgroundView) {
        _showsStatusBarBackgroundView = showsDummyStatusBar;
        CGRect frame = self.childControllerContainerView.frame;
        if (_showsStatusBarBackgroundView) {
            frame.origin.y = 20;
            frame.size.height = CGRectGetHeight(self.view.bounds) - 20;
        } else {
            frame.origin.y = 0;
            frame.size.height = CGRectGetHeight(self.view.bounds);
        }
        [self.childControllerContainerView setFrame:frame];
        [self.dummyStatusBarView setHidden:!showsDummyStatusBar];
    }
}

- (void)setStatusBarViewBackgroundColor:(UIColor *)dummyStatusBarColor
{
    _statusBarViewBackgroundColor = dummyStatusBarColor;
    [self.dummyStatusBarView setBackgroundColor:_statusBarViewBackgroundColor];
}

- (void)setAnimatingDrawer:(BOOL)animatingDrawer
{
    _animatingDrawer = animatingDrawer;
    [self.view setUserInteractionEnabled:!animatingDrawer];
}

#pragma mark - Getters
- (CGFloat)maximumLeftDrawerWidth
{
    if (self.leftDrawerViewController) {
        return _maximumLeftDrawerWidth;
    } else {
        return 0;
    }
}

- (CGFloat)maximumRightDrawerWidth
{
    if (self.rightDrawerViewController) {
        return _maximumRightDrawerWidth;
    } else {
        return 0;
    }
}

- (CGFloat)visibleLeftDrawerWidth
{
    return MAX(0.0, CGRectGetMinX(self.centerContainerView.frame));
}

- (CGFloat)visibleRightDrawerWidth
{
    if (CGRectGetMinX(self.centerContainerView.frame) < 0) {
        return CGRectGetWidth(self.childControllerContainerView.bounds) - CGRectGetMaxX(self.centerContainerView.frame);
    } else {
        return 0.0f;
    }
}

- (UIView *)childControllerContainerView
{
    if (_childControllerContainerView == nil) {
        //Turns out we have two child container views getting added to the view during init,
        //because the first request self.view.bounds was kicking off a viewDidLoad, which
        //caused us to be able to fall through this check twice.
        //
        //The fix is to grab the bounds, and then check again that the child container view has
        //not been created.
        CGRect childContainerViewFrame = self.view.bounds;
        if (_childControllerContainerView == nil) {
            _childControllerContainerView = [[UIView alloc] initWithFrame:childContainerViewFrame];
            [_childControllerContainerView setBackgroundColor:[UIColor clearColor]];
            [_childControllerContainerView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
            [self.view addSubview:_childControllerContainerView];
        }
    }
    return _childControllerContainerView;
}

- (UIView *)dummyStatusBarView
{
    if (_dummyStatusBarView == nil) {
        _dummyStatusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 20)];
        [_dummyStatusBarView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [_dummyStatusBarView setBackgroundColor:self.statusBarViewBackgroundColor];
        [_dummyStatusBarView setHidden:!_showsStatusBarBackgroundView];
        [self.view addSubview:_dummyStatusBarView];
    }
    return _dummyStatusBarView;
}

- (UIColor *)statusBarViewBackgroundColor
{
    if (_statusBarViewBackgroundColor == nil) {
        _statusBarViewBackgroundColor = [UIColor blackColor];
    }
    return _statusBarViewBackgroundColor;
}

#pragma mark - Gesture Handlers

- (void)tapGestureCallback:(UITapGestureRecognizer *)tapGesture
{
    if (self.openSide != CCDrawerSideNone &&
        self.isAnimatingDrawer == NO) {
        [self closeDrawerAnimated:YES completion:^(BOOL finished) {
            if(self.gestureCompletion){
                self.gestureCompletion(self, tapGesture);
            }
        }];
    }
}

/**
 *  @author CC, 2015-10-19
 *
 *  @brief  屏蔽所有页面都能滑动
 */
- (void)detectingIsSideslip
{
    if ([self.centerViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBar = (UITabBarController *)self.centerViewController;
        UINavigationController *nav = [tabBar.viewControllers objectAtIndex:tabBar.selectedIndex];
        if (nav.viewControllers.count > 1)
            self.panGestureEnabled = NO;
        else
            self.panGestureEnabled = YES;
    }
}

- (void)panGestureCallback:(UIPanGestureRecognizer *)panGesture
{
    if (!self.panGestureEnabled) return;
        
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            if (self.animatingDrawer) {
                [panGesture setEnabled:NO];
                break;
            } else {
                self.startingPanRect = self.centerContainerView.frame;
            }
        }
        case UIGestureRecognizerStateChanged: {
            self.view.userInteractionEnabled = NO;
            CGRect newFrame = self.startingPanRect;
            CGPoint translatedPoint = [panGesture translationInView:self.centerContainerView];
            newFrame.origin.x = [self roundedOriginXForDrawerConstriants:CGRectGetMinX(self.startingPanRect) + translatedPoint.x];
            newFrame = CGRectIntegral(newFrame);
            CGFloat xOffset = newFrame.origin.x;
            
            CCDrawerSide visibleSide = CCDrawerSideNone;
            CGFloat percentVisible = 0.0;
            if (xOffset > 0) {
                visibleSide = CCDrawerSideLeft;
                percentVisible = xOffset / self.maximumLeftDrawerWidth;
            } else if (xOffset < 0) {
                visibleSide = CCDrawerSideRight;
                percentVisible = ABS(xOffset) / self.maximumRightDrawerWidth;
            }
            UIViewController *visibleSideDrawerViewController = [self sideDrawerViewControllerForSide:visibleSide];
            
            if (self.openSide != visibleSide) {
                //Handle disappearing the visible drawer
                UIViewController *sideDrawerViewController = [self sideDrawerViewControllerForSide:self.openSide];
                [sideDrawerViewController beginAppearanceTransition:NO animated:NO];
                [sideDrawerViewController endAppearanceTransition];
                
                //Drawer is about to become visible
                [self prepareToPresentDrawer:visibleSide animated:NO];
                [visibleSideDrawerViewController endAppearanceTransition];
                [self setOpenSide:visibleSide];
            } else if (visibleSide == CCDrawerSideNone) {
                [self setOpenSide:CCDrawerSideNone];
            }
            
            [self updateDrawerVisualStateForDrawerSide:visibleSide percentVisible:percentVisible];
            
            [self.centerContainerView setCenter:CGPointMake(CGRectGetMidX(newFrame), CGRectGetMidY(newFrame))];
            
            newFrame = self.centerContainerView.frame;
            newFrame.origin.x = floor(newFrame.origin.x);
            newFrame.origin.y = floor(newFrame.origin.y);
            self.centerContainerView.frame = newFrame;
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            self.startingPanRect = CGRectNull;
            CGPoint velocity = [panGesture velocityInView:self.childControllerContainerView];
            [self finishAnimationForPanGestureWithXVelocity:velocity.x completion:^(BOOL finished) {
                if(self.gestureCompletion){
                    self.gestureCompletion(self, panGesture);
                }
            }];
            self.view.userInteractionEnabled = YES;
            break;
        }
        default:
            break;
    }
}

#pragma mark - iOS 7 Status Bar Helpers
- (UIViewController *)childViewControllerForStatusBarStyle
{
    return [self childViewControllerForSide:self.openSide];
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return [self childViewControllerForSide:self.openSide];
}

- (void)setNeedsStatusBarAppearanceUpdateIfSupported
{
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
}

#pragma mark - iOS 8 Rotation Helpers
- (BOOL)needsManualForwardingOfRotationEvents
{
    BOOL isIOS8 = (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1);
    return !isIOS8;
}

#pragma mark - Animation helpers
- (void)finishAnimationForPanGestureWithXVelocity:(CGFloat)xVelocity
                                       completion:(void (^)(BOOL finished))completion
{
    CGFloat currentOriginX = CGRectGetMinX(self.centerContainerView.frame);
    
    CGFloat animationVelocity = MAX(ABS(xVelocity), self.panVelocityXAnimationThreshold * 2);
    
    if (self.openSide == CCDrawerSideLeft) {
        CGFloat midPoint = self.maximumLeftDrawerWidth / 2.0;
        if (xVelocity > self.panVelocityXAnimationThreshold) {
            [self openDrawerSide:CCDrawerSideLeft animated:YES velocity:animationVelocity animationOptions:UIViewAnimationOptionCurveEaseOut completion:completion];
        } else if (xVelocity < -self.panVelocityXAnimationThreshold) {
            [self closeDrawerAnimated:YES velocity:animationVelocity animationOptions:UIViewAnimationOptionCurveEaseOut completion:completion];
        } else if (currentOriginX < midPoint) {
            [self closeDrawerAnimated:YES completion:completion];
        } else {
            [self openDrawerSide:CCDrawerSideLeft animated:YES completion:completion];
        }
    } else if (self.openSide == CCDrawerSideRight) {
        currentOriginX = CGRectGetMaxX(self.centerContainerView.frame);
        CGFloat midPoint = (CGRectGetWidth(self.childControllerContainerView.bounds) - self.maximumRightDrawerWidth) + (self.maximumRightDrawerWidth / 2.0);
        if (xVelocity > self.panVelocityXAnimationThreshold) {
            [self closeDrawerAnimated:YES velocity:animationVelocity animationOptions:UIViewAnimationOptionCurveEaseOut completion:completion];
        } else if (xVelocity < -self.panVelocityXAnimationThreshold) {
            [self openDrawerSide:CCDrawerSideRight animated:YES velocity:animationVelocity animationOptions:UIViewAnimationOptionCurveEaseOut completion:completion];
        } else if (currentOriginX > midPoint) {
            [self closeDrawerAnimated:YES completion:completion];
        } else {
            [self openDrawerSide:CCDrawerSideRight animated:YES completion:completion];
        }
    } else {
        if (completion) {
            completion(NO);
        }
    }
}

- (void)updateDrawerVisualStateForDrawerSide:(CCDrawerSide)drawerSide
                              percentVisible:(CGFloat)percentVisible
{
    if (self.drawerVisualState) {
        self.drawerVisualState(self, drawerSide, percentVisible);
    } else if (self.shouldStretchDrawer) {
        [self applyOvershootScaleTransformForDrawerSide:drawerSide
                                         percentVisible:percentVisible];
    }
}

- (void)applyOvershootScaleTransformForDrawerSide:(CCDrawerSide)drawerSide
                                   percentVisible:(CGFloat)percentVisible
{
    
     CCDrawerControllerDrawerVisualStateBlock visualStateBlock = nil;
    switch (self.drawerAnimationType) {
        case CCDrawerAnimationTypeSlide:
           visualStateBlock=  [CCDrawerVisualState slideVisualStateBlock];
            break;
        case CCDrawerAnimationTypeSlideAndScale:
            visualStateBlock= [CCDrawerVisualState slideAndScaleVisualStateBlock];
            break;
        case CCDrawerAnimationTypeParallax:
             visualStateBlock=[CCDrawerVisualState parallaxVisualStateBlockWithParallaxFactor:2.0];
            break;
        case CCDrawerAnimationTypeSwingingDoor:
           visualStateBlock=  [CCDrawerVisualState swingingDoorVisualStateBlock];
            break;
        default:{
             visualStateBlock =  ^(CCDrawerController * drawerController, CCDrawerSide drawerSide, CGFloat percentVisible){
                UIViewController *sideDrawerViewController;
                CATransform3D transform;
                CGFloat maxDrawerWidth = 0.0;
                
                if(drawerSide == CCDrawerSideLeft){
                    sideDrawerViewController = drawerController.leftDrawerViewController;
                    maxDrawerWidth = drawerController.maximumLeftDrawerWidth;
                }
                else if(drawerSide == CCDrawerSideRight){
                    sideDrawerViewController = drawerController.rightDrawerViewController;
                    maxDrawerWidth = drawerController.maximumRightDrawerWidth;
                }
                
                if(percentVisible > 1.0){
                    transform = CATransform3DMakeScale(percentVisible, 1.f, 1.f);
                    
                    if(drawerSide == CCDrawerSideLeft){
                        transform = CATransform3DTranslate(transform, maxDrawerWidth * (percentVisible-1.f)/2, 0.f, 0.f);
                    }else if(drawerSide == CCDrawerSideRight){
                        transform = CATransform3DTranslate(transform, -maxDrawerWidth * (percentVisible-1.f)/2, 0.f, 0.f);
                    }
                }
                else {
                    transform = CATransform3DIdentity;
                }
                [sideDrawerViewController.view.layer setTransform:transform];
             };
        }break;
    }
    
    visualStateBlock(self,drawerSide,percentVisible);
    
//    if (percentVisible >= 1.f) {
//        CATransform3D transform = CATransform3DIdentity;
//        UIViewController *sideDrawerViewController = [self sideDrawerViewControllerForSide:drawerSide];
//        if (drawerSide == CCDrawerSideLeft) {
//            transform = CATransform3DMakeScale(percentVisible, 1.f, 1.f);
//            transform = CATransform3DTranslate(transform, self.maximumLeftDrawerWidth * (percentVisible - 1.f) / 2, 0.f, 0.f);
//        } else if (drawerSide == CCDrawerSideRight) {
//            transform = CATransform3DMakeScale(percentVisible, 1.f, 1.f);
//            transform = CATransform3DTranslate(transform, -self.maximumRightDrawerWidth * (percentVisible - 1.f) / 2, 0.f, 0.f);
//        }
//        sideDrawerViewController.view.layer.transform = transform;
//    }
}

- (void)resetDrawerVisualStateForDrawerSide:(CCDrawerSide)drawerSide
{
    UIViewController *sideDrawerViewController = [self sideDrawerViewControllerForSide:drawerSide];
    
    [sideDrawerViewController.view.layer setAnchorPoint:CGPointMake(0.5f, 0.5f)];
    [sideDrawerViewController.view.layer setTransform:CATransform3DIdentity];
    [sideDrawerViewController.view setAlpha:1.0];
}

- (CGFloat)roundedOriginXForDrawerConstriants:(CGFloat)originX
{
    
    if (originX < -self.maximumRightDrawerWidth) {
        if (self.shouldStretchDrawer &&
            self.rightDrawerViewController) {
            CGFloat maxOvershoot = (CGRectGetWidth(self.centerContainerView.frame) - self.maximumRightDrawerWidth) * CCDrawerOvershootPercentage;
            return originXForDrawerOriginAndTargetOriginOffset(originX, -self.maximumRightDrawerWidth, maxOvershoot);
        } else {
            return -self.maximumRightDrawerWidth;
        }
    } else if (originX > self.maximumLeftDrawerWidth) {
        if (self.shouldStretchDrawer &&
            self.leftDrawerViewController) {
            CGFloat maxOvershoot = (CGRectGetWidth(self.centerContainerView.frame) - self.maximumLeftDrawerWidth) * CCDrawerOvershootPercentage;
            return originXForDrawerOriginAndTargetOriginOffset(originX, self.maximumLeftDrawerWidth, maxOvershoot);
        } else {
            return self.maximumLeftDrawerWidth;
        }
    }
    
    return originX;
}

static inline CGFloat originXForDrawerOriginAndTargetOriginOffset(CGFloat originX, CGFloat targetOffset, CGFloat maxOvershoot)
{
    CGFloat delta = ABS(originX - targetOffset);
    CGFloat maxLinearPercentage = CCDrawerOvershootLinearRangePercentage;
    CGFloat nonLinearRange = maxOvershoot * maxLinearPercentage;
    CGFloat nonLinearScalingDelta = (delta - nonLinearRange);
    CGFloat overshoot = nonLinearRange + nonLinearScalingDelta * nonLinearRange / sqrt(pow(nonLinearScalingDelta, 2.f) + 15000);
    
    if (delta < nonLinearRange) {
        return originX;
    } else if (targetOffset < 0) {
        return targetOffset - round(overshoot);
    } else {
        return targetOffset + round(overshoot);
    }
}

#pragma mark - Helpers
- (void)setupGestureRecognizers
{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureCallback:)];
    [pan setDelegate:self];
    [self.view addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureCallback:)];
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
}

- (void)prepareToPresentDrawer:(CCDrawerSide)drawer animated:(BOOL)animated
{
    CCDrawerSide drawerToHide = CCDrawerSideNone;
    if (drawer == CCDrawerSideLeft) {
        drawerToHide = CCDrawerSideRight;
    } else if (drawer == CCDrawerSideRight) {
        drawerToHide = CCDrawerSideLeft;
    }
    
    UIViewController *sideDrawerViewControllerToPresent = [self sideDrawerViewControllerForSide:drawer];
    UIViewController *sideDrawerViewControllerToHide = [self sideDrawerViewControllerForSide:drawerToHide];
    
    [self.childControllerContainerView sendSubviewToBack:sideDrawerViewControllerToHide.view];
    [sideDrawerViewControllerToHide.view setHidden:YES];
    [sideDrawerViewControllerToPresent.view setHidden:NO];
    [self resetDrawerVisualStateForDrawerSide:drawer];
    [sideDrawerViewControllerToPresent.view setFrame:sideDrawerViewControllerToPresent.cc_visibleDrawerFrame];
    [self updateDrawerVisualStateForDrawerSide:drawer percentVisible:0.0];
    [sideDrawerViewControllerToPresent beginAppearanceTransition:YES animated:animated];
}

- (void)updateShadowForCenterView
{
    UIView *centerView = self.centerContainerView;
    if (self.showsShadow) {
        centerView.layer.masksToBounds = NO;
        centerView.layer.shadowRadius = self.shadowRadius;
        centerView.layer.shadowOpacity = self.shadowOpacity;
        centerView.layer.shadowOffset = self.shadowOffset;
        centerView.layer.shadowColor = [self.shadowColor CGColor];
        
        /** In the event this gets called a lot, we won't update the shadowPath
         unless it needs to be updated (like during rotation) */
        if (centerView.layer.shadowPath == NULL) {
            centerView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.centerContainerView.bounds] CGPath];
        } else {
            CGRect currentPath = CGPathGetPathBoundingBox(centerView.layer.shadowPath);
            if (CGRectEqualToRect(currentPath, centerView.bounds) == NO) {
                centerView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.centerContainerView.bounds] CGPath];
            }
        }
    } else if (centerView.layer.shadowPath != NULL) {
        centerView.layer.shadowRadius = 0.f;
        centerView.layer.shadowOpacity = 0.f;
        centerView.layer.shadowOffset = CGSizeMake(0, -3);
        centerView.layer.shadowPath = NULL;
        centerView.layer.masksToBounds = YES;
    }
    
    if (self.leftDrawerViewController || self.rightDrawerViewController) {
        UIImageView *leftBackgroundImageView = (UIImageView *)[self.leftDrawerViewController.view viewWithTag:99999];
        if (!leftBackgroundImageView) {
            self.backgroundImageView = ({
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
                imageView.image = self.backgroundImage;
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                imageView.tag = 99999;
                imageView;
            });
            [self.leftDrawerViewController.view addSubview:self.backgroundImageView];
            [self.leftDrawerViewController.view sendSubviewToBack:self.backgroundImageView];
        }
    }
    
   
}

- (NSTimeInterval)animationDurationForAnimationDistance:(CGFloat)distance
{
    NSTimeInterval duration = MAX(distance / self.animationVelocity, CCDrawerMinimumAnimationDuration);
    return duration;
}

- (UIViewController *)sideDrawerViewControllerForSide:(CCDrawerSide)drawerSide
{
    UIViewController *sideDrawerViewController = nil;
    if (drawerSide != CCDrawerSideNone) {
        sideDrawerViewController = [self childViewControllerForSide:drawerSide];
    }
    return sideDrawerViewController;
}

- (UIViewController *)childViewControllerForSide:(CCDrawerSide)drawerSide
{
    UIViewController *childViewController = nil;
    switch (drawerSide) {
        case CCDrawerSideLeft:
            childViewController = self.leftDrawerViewController;
            break;
        case CCDrawerSideRight:
            childViewController = self.rightDrawerViewController;
            break;
        case CCDrawerSideNone:
            childViewController = self.centerViewController;
            break;
    }
    return childViewController;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
     [self detectingIsSideslip];
    
    IF_IOS7_OR_GREATER(
                       if (self.interactivePopGestureRecognizerEnabled && [self.centerViewController isKindOfClass:[UINavigationController class]]) {
                           UINavigationController *navigationController = (UINavigationController *)self.centerViewController;
                           if (navigationController.viewControllers.count > 1 && navigationController.interactivePopGestureRecognizer.enabled) {
                               return NO;
                           }
                       });
    
    if (self.openSide == CCDrawerSideNone) {
        CCOpenDrawerGestureMode possibleOpenGestureModes = [self possibleOpenGestureModesForGestureRecognizer:gestureRecognizer
                                                                                                    withTouch:touch];
        return ((self.openDrawerGestureModeMask & possibleOpenGestureModes) > 0);
    } else {
        CCCloseDrawerGestureMode possibleCloseGestureModes = [self possibleCloseGestureModesForGestureRecognizer:gestureRecognizer
                                                                                                       withTouch:touch];
        return ((self.closeDrawerGestureModeMask & possibleCloseGestureModes) > 0);
    }
}

#pragma mark Gesture Recogizner Delegate Helpers
- (CCCloseDrawerGestureMode)possibleCloseGestureModesForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
                                                                withTouch:(UITouch *)touch
{
    CGPoint point = [touch locationInView:self.childControllerContainerView];
    CCCloseDrawerGestureMode possibleCloseGestureModes = CCCloseDrawerGestureModeNone;
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        if ([self isPointContainedWithinNavigationRect:point]) {
            possibleCloseGestureModes |= CCCloseDrawerGestureModeTapNavigationBar;
        }
        if ([self isPointContainedWithinCenterViewContentRect:point]) {
            possibleCloseGestureModes |= CCCloseDrawerGestureModeTapCenterView;
        }
    } else if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        if ([self isPointContainedWithinNavigationRect:point]) {
            possibleCloseGestureModes |= CCCloseDrawerGestureModePanningNavigationBar;
        }
        if ([self isPointContainedWithinCenterViewContentRect:point]) {
            possibleCloseGestureModes |= CCCloseDrawerGestureModePanningCenterView;
        }
        if ([self isPointContainedWithinRightBezelRect:point] &&
            self.openSide == CCDrawerSideLeft) {
            possibleCloseGestureModes |= CCCloseDrawerGestureModeBezelPanningCenterView;
        }
        if ([self isPointContainedWithinLeftBezelRect:point] &&
            self.openSide == CCDrawerSideRight) {
            possibleCloseGestureModes |= CCCloseDrawerGestureModeBezelPanningCenterView;
        }
        if ([self isPointContainedWithinCenterViewContentRect:point] == NO &&
            [self isPointContainedWithinNavigationRect:point] == NO) {
            possibleCloseGestureModes |= CCCloseDrawerGestureModePanningDrawerView;
        }
    }
    if ((self.closeDrawerGestureModeMask & CCCloseDrawerGestureModeCustom) > 0 &&
        self.gestureShouldRecognizeTouch) {
        if (self.gestureShouldRecognizeTouch(self, gestureRecognizer, touch)) {
            possibleCloseGestureModes |= CCCloseDrawerGestureModeCustom;
        }
    }
    return possibleCloseGestureModes;
}

- (CCOpenDrawerGestureMode)possibleOpenGestureModesForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
                                                              withTouch:(UITouch *)touch
{
    CGPoint point = [touch locationInView:self.childControllerContainerView];
    CCOpenDrawerGestureMode possibleOpenGestureModes = CCOpenDrawerGestureModeNone;
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        if ([self isPointContainedWithinNavigationRect:point]) {
            possibleOpenGestureModes |= CCOpenDrawerGestureModePanningNavigationBar;
        }
        if ([self isPointContainedWithinCenterViewContentRect:point]) {
            possibleOpenGestureModes |= CCOpenDrawerGestureModePanningCenterView;
        }
        if ([self isPointContainedWithinLeftBezelRect:point] &&
            self.leftDrawerViewController) {
            possibleOpenGestureModes |= CCOpenDrawerGestureModeBezelPanningCenterView;
        }
        if ([self isPointContainedWithinRightBezelRect:point] &&
            self.rightDrawerViewController) {
            possibleOpenGestureModes |= CCOpenDrawerGestureModeBezelPanningCenterView;
        }
    }
    if ((self.openDrawerGestureModeMask & CCOpenDrawerGestureModeCustom) > 0 &&
        self.gestureShouldRecognizeTouch) {
        if (self.gestureShouldRecognizeTouch(self, gestureRecognizer, touch)) {
            possibleOpenGestureModes |= CCOpenDrawerGestureModeCustom;
        }
    }
    return possibleOpenGestureModes;
}

- (BOOL)isPointContainedWithinNavigationRect:(CGPoint)point
{
    CGRect navigationBarRect = CGRectNull;
    if ([self.centerViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationBar *navBar = [(UINavigationController *)self.centerViewController navigationBar];
        navigationBarRect = [navBar convertRect:navBar.bounds toView:self.childControllerContainerView];
        navigationBarRect = CGRectIntersection(navigationBarRect, self.childControllerContainerView.bounds);
    }
    return CGRectContainsPoint(navigationBarRect, point);
}

- (BOOL)isPointContainedWithinCenterViewContentRect:(CGPoint)point
{
    CGRect centerViewContentRect = self.centerContainerView.frame;
    centerViewContentRect = CGRectIntersection(centerViewContentRect, self.childControllerContainerView.bounds);
    return (CGRectContainsPoint(centerViewContentRect, point) &&
            [self isPointContainedWithinNavigationRect:point] == NO);
}

- (BOOL)isPointContainedWithinLeftBezelRect:(CGPoint)point
{
    CGRect leftBezelRect = CGRectNull;
    CGRect tempRect;
    CGRectDivide(self.childControllerContainerView.bounds, &leftBezelRect, &tempRect, self.bezelPanningCenterViewRange, CGRectMinXEdge);
    return (CGRectContainsPoint(leftBezelRect, point) &&
            [self isPointContainedWithinCenterViewContentRect:point]);
}

- (BOOL)isPointContainedWithinRightBezelRect:(CGPoint)point
{
    CGRect rightBezelRect = CGRectNull;
    CGRect tempRect;
    CGRectDivide(self.childControllerContainerView.bounds, &rightBezelRect, &tempRect, self.bezelPanningCenterViewRange, CGRectMaxXEdge);
    
    return (CGRectContainsPoint(rightBezelRect, point) &&
            [self isPointContainedWithinCenterViewContentRect:point]);
}


@end
