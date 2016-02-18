//
//  CCLaunchAnimation.m
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

#import "CCLaunchAnimation.h"
#import "config.h"
#import "CCBacktrace.h"
#import "CALayer+Transition.h"
#import "UIView+CCFlipImageView.h"

@implementation CCLaunchAnimation

static const CGFloat duration = 1.5f;

+ (void)animationWithWindow:(UIWindow *)window
{
    [self animationWithWindow:window
                  LaunchImage:nil];
}

+ (void)animationWithWindow:(UIWindow *)window
                LaunchImage:(UIImage *)launchImage
{
    [self animationWithWindow:window
                  LaunchImage:launchImage
                AnimationType:CCLaunchAnimationTypeLite];
}

+ (void)animationWithWindow:(UIWindow *)window
                LaunchImage:(UIImage *)launchImage
              AnimationType:(CCLaunchAnimationType)animationType
{
    UIImageView *launchImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    launchImageView.image = launchImage ?: [self LaunchImage];
    [window.rootViewController.view addSubview:launchImageView];
    
    switch (animationType) {
        case CCLaunchAnimationTypeLite:
            [self liteAnimation:launchImageView];
            break;
        case CCLaunchAnimationTypePlus:
            [self plusAnimation:launchImageView];
            break;
        case CCLaunchAnimationTypeCool:
            [self coolAnimation:launchImageView
                    WindowLayer:window.layer];
            break;
        case CCLaunchAnimationTypeFlip:
            [self flipAnimation:launchImageView
                     WindowView:window.rootViewController.view];
            break;
    }
}

+ (void)liteAnimation:(UIImageView *)launchImageView
{
    [UIView animateWithDuration:2.5 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        launchImageView.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.0);
        launchImageView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [launchImageView removeFromSuperview];
    }];
}

+ (void)plusAnimation:(UIImageView *)launchImageView
{
    CABasicAnimation *rotationAnim = [CABasicAnimation animationWithKeyPath:[NSString stringWithFormat:@"transform.rotation.z"]];
    rotationAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    rotationAnim.fromValue = @(0);
    rotationAnim.toValue = @(M_PI_2);
    rotationAnim.duration = duration;
    rotationAnim.autoreverses = NO;
    rotationAnim.removedOnCompletion = YES;
    rotationAnim.repeatCount = 0;
    rotationAnim.fillMode = kCAFillModeForwards;
    rotationAnim.removedOnCompletion = NO;
    launchImageView.layer.anchorPoint = CGPointMake(0, 1);
    launchImageView.layer.position = CGPointMake(0, launchImageView.layer.bounds.size.height);
    
    
    cc_dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{    
        [launchImageView removeFromSuperview];
    });
}

+ (void)coolAnimation:(UIImageView *)launchImageView
          WindowLayer:(CALayer *)layer
{
    cc_dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [launchImageView removeFromSuperview];
        [layer transitionWithAnimType:CCTransitionAnimTypeRippleEffect 
                              subType:CCTransitionSubtypesFromRamdom
                                curve:CCTransitionCurveRamdom 
                             duration:1.6];
    });
}

+ (void)flipAnimation:(UIImageView *)launchImageView
           WindowView:(UIView *)windowView
{
    [launchImageView removeFromSuperview];
    UIImage *image = [self cutFromView:windowView];
    [windowView addSubview:launchImageView];
    
    UIImageView *launchImageView2 = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    launchImageView2.image = image;
    
    [windowView addSubview:launchImageView2];
    [windowView addSubview:launchImageView];
    
    cc_dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [launchImageView flipToView:launchImageView2];
        [launchImageView removeFromSuperview];
        [launchImageView2 removeFromSuperview];
    });
}

+ (UIImage *)cutFromView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    [[UIColor clearColor] setFill];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/**
 *  获取启动图片
 */
+ (UIImage *)LaunchImage
{
    NSString *imageName = @"LaunchImage-700";
    
    if (iPhone5) imageName = @"LaunchImage-700-568h";
    
    if (iPhone6) imageName = @"LaunchImage-800-667h";
    
    if (iPhone6P) imageName = @"LaunchImage-800-Portrait-736h";
    
    UIImage *image = [UIImage imageNamed:imageName];
    
    NSAssert(image != nil, @"CC 提示您：请添加启动图片！");
    
    return image;
}

@end
