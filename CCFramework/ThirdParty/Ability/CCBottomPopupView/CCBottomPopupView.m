//
//  CCBottomPopupView.m
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

#import "CCBottomPopupView.h"
#import "UIView+Frame.h"

#define kCCDuration 0.3
#define kSemiModalModalViewTag 10003
#define kSemiModalScreenshotTag 10002

#define CATransform3DPerspective(t, x, y) (CATransform3DConcat(t, CATransform3DMake(1, 0, 0, x, 0, 1, 0, y, 0, 0, 1, 0, 0, 0, 0, 1)))
#define CATransform3DMakePerspective(x, y) (CATransform3DPerspective(CATransform3DIdentity, x, y))

CG_INLINE CATransform3D CATransform3DMake(CGFloat m11, CGFloat m12, CGFloat m13, CGFloat m14,
                                          CGFloat m21, CGFloat m22, CGFloat m23, CGFloat m24,
                                          CGFloat m31, CGFloat m32, CGFloat m33, CGFloat m34,
                                          CGFloat m41, CGFloat m42, CGFloat m43, CGFloat m44)
{
    CATransform3D t;
    t.m11 = m11;
    t.m12 = m12;
    t.m13 = m13;
    t.m14 = m14;
    t.m21 = m21;
    t.m22 = m22;
    t.m23 = m23;
    t.m24 = m24;
    t.m31 = m31;
    t.m32 = m32;
    t.m33 = m33;
    t.m34 = m34;
    t.m41 = m41;
    t.m42 = m42;
    t.m43 = m43;
    t.m44 = m44;
    return t;
}

@implementation CCBottomPopupView

/**
 *  @author CC, 2016-01-05
 *  
 *  @brief  添加视图对象
 *
 *  @return 返回主对象视图
 */
+ (UIView *)parentTarget
{
    UIWindow *windowView = [UIApplication sharedApplication].keyWindow;
    return windowView;
}

/**
 *  @author CC, 2016-01-05
 *  
 *  @brief  截取视图
 *
 *  @param screenshotContainer 被截取的视图
 *
 *  @return 返回截取的视图对象
 */
+ (UIImageView *)cc_addOrUpdateParentScreenshotInView:(UIView *)screenshotContainer
{
    UIView *target = [self parentTarget];
    UIView *semiView = [target viewWithTag:kSemiModalModalViewTag];
    
    screenshotContainer.hidden = YES; // screenshot without the overlay!
    semiView.hidden = YES;
    
    UIGraphicsBeginImageContextWithOptions(target.bounds.size, YES, [[UIScreen mainScreen] scale]);
    if ([target respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
        [target drawViewHierarchyInRect:target.bounds afterScreenUpdates:NO];
    else
        [target.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    screenshotContainer.hidden = NO;
    semiView.hidden = NO;
    
    UIImageView *screenshot = (id)[screenshotContainer viewWithTag:kSemiModalScreenshotTag];
    if (screenshot) {
        screenshot.image = image;
    } else {
        screenshot = [[UIImageView alloc] initWithImage:image];
        screenshot.tag = kSemiModalScreenshotTag;
        screenshot.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [screenshotContainer addSubview:screenshot];
    }
    return screenshot;
}

/**
 *  @author CC, 2016-01-05
 *  
 *  @brief  弹出视图
 *
 *  @param view 视图
 */
+ (void)showInView:(UIView *)view
{
    [self showInView:view
      BackgroundView:nil];
}

/**
 *  @author CC, 2016-01-05
 *  
 *  @brief  弹出视图
 *
 *  @param view           视图
 *  @param backgroundView 背景视图
 */
+ (void)showInView:(UIView *)view
    BackgroundView:(UIView *)backgroundView
{
    [self showInView:view
      BackgroundView:backgroundView
          Completion:nil];
}

/**
 *  @author CC, 2016-01-05
 *  
 *  @brief  弹出视图
 *
 *  @param view           视图
 *  @param backgroundView 背景视图
 *  @param completion     完成回调
 */
+ (void)showInView:(UIView *)view
    BackgroundView:(UIView *)backgroundView
        Completion:(void (^)())completion
{
    UIView *target = [self parentTarget];
    if (![target.subviews containsObject:view]) {
        
        // Calulate all frames
        CGFloat semiViewHeight = view.frame.size.height;
        CGRect vf = target.bounds;
        CGRect semiViewFrame;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            // We center the view and mantain aspect ration
            semiViewFrame = CGRectMake((vf.size.width - view.frame.size.width) / 2.0, vf.size.height - semiViewHeight, view.frame.size.width, semiViewHeight);
        } else {
            semiViewFrame = CGRectMake(0, vf.size.height - semiViewHeight, vf.size.width, semiViewHeight);
        }
        CGRect overlayFrame = CGRectMake(0, 0, vf.size.width, vf.size.height - semiViewHeight);
        
        // Add semi overlay
        UIView *overlay = [[UIView alloc] init];
        if (backgroundView)
            overlay = backgroundView;
        
        overlay.frame = target.bounds;
        overlay.backgroundColor = [UIColor blackColor];
        overlay.userInteractionEnabled = YES;
        overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // Take screenshot and scale
        UIImageView *overlayImageView = [self cc_addOrUpdateParentScreenshotInView:overlay];
        [target addSubview:overlay];
        
        // Dismiss button
        // Don't use UITapGestureRecognizer to avoid complex handling
        UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [dismissButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        dismissButton.backgroundColor = [UIColor clearColor];
        dismissButton.frame = overlayFrame;
        [overlay addSubview:dismissButton];
        
        // Begin overlay animation
        [UIView animateWithDuration:kCCDuration animations:^{
            overlayImageView.layer.transform = CATransform3DMakePerspective(0, -0.0007);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                
                float newWidht = overlayImageView.frame.size.width * 0.7;
                float newHeight = overlayImageView.frame.size.height * 0.9;
                overlayImageView.frame = CGRectMake(([[UIScreen mainScreen]bounds].size.width - newWidht) / 2, 22, newWidht, newHeight);
                overlayImageView.layer.transform = CATransform3DMakePerspective(0, 0);
            } completion:nil];
        }];
        
        [UIView animateWithDuration:0.5 animations:^{
            overlayImageView.alpha = 0.8;
        }];
        
        // Present view animated
        view.frame = CGRectOffset(semiViewFrame, 0, +semiViewHeight);
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) // Don't resize the view width on rotating
            view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        else
            view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        
        view.tag = kSemiModalModalViewTag;
        [target addSubview:view];
        view.layer.shadowColor = [[UIColor blackColor] CGColor];
        view.layer.shadowOffset = CGSizeMake(0, -2);
        view.layer.shadowRadius = 5.0;
        view.layer.shadowOpacity = 0.8;
        
        [UIView animateWithDuration:kCCDuration animations:^{
            view.frame = semiViewFrame;
            if (completion)
                completion();
        }];
    }
}

/**
 *  @author CC, 2016-01-05
 *  
 *  @brief  隐藏
 */
+ (void)hide
{
    [self hide:nil];
}

/**
 *  @author CC, 2016-01-05
 *  
 *  @brief  隐藏
 *
 *  @param completion 完成回调
 */
+ (void)hide:(void (^)())completion
{
    UIView *target = [self parentTarget];
    UIView *modal = [target.subviews objectAtIndex:target.subviews.count - 1];
    UIView *overlay = [target.subviews objectAtIndex:target.subviews.count - 2];
    
    // Begin overlay animation
    UIImageView *overlayImageView = (UIImageView *)[overlay.subviews objectAtIndex:0];
    
    [UIView animateWithDuration:kCCDuration animations:^{
        
        overlayImageView.alpha = 1;
        overlayImageView.layer.transform = CATransform3DMakePerspective(0, -0.0007);
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.2 animations:^{
            
            overlayImageView.frame = [[UIScreen mainScreen]bounds];
            overlayImageView
            .layer.transform = CATransform3DMakePerspective(0, 0);
            modal.frame = CGRectMake(0, target.frame.size.height, modal.frame.size.width, modal.frame.size.height);
        } completion:^(BOOL finished) {
            
            [overlay removeFromSuperview];
            [modal removeFromSuperview];
            if (completion)
                completion();
        }];
    }];
}

@end
