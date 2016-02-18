//
//  UIView+CCFlipImageView.m
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

#import "UIView+CCFlipImageView.h"
#import <QuartzCore/QuartzCore.h>

@interface UIView (CCFlipImageViewHidden)

- (UIImage *)imageSnapshotAfterScreenUpdates:(BOOL)afterScreenUpdates;

- (CCFlipImageView *)addFlipViewWithAnimationFromImage:(UIImage *)fromImage
                                               toImage:(UIImage *)toImage
                                              duration:(NSTimeInterval)duration
                                             direction:(CCFlipImageViewFlipDirection)direction
                                            completion:(CCFlipImageViewCompletionBlock)completion;
@end

@implementation UIView (CCFlipImageView)

#pragma mark Flip transition to another view

- (void)flipToView:(UIView *)view;
{
    [self flipToView:view
            duration:CCFlipImageViewDefaultFlipDuration
          removeView:YES
           direction:CCFlipImageViewFlipDirectionUp
          completion:nil];
}

- (void)flipToView:(UIView *)view
        completion:(CCFlipImageViewCompletionBlock)completion;
{
    [self flipToView:view
            duration:CCFlipImageViewDefaultFlipDuration
          removeView:YES
           direction:CCFlipImageViewFlipDirectionDown
          completion:completion];
}

- (void)flipToView:(UIView *)view
          duration:(CGFloat)duration
        completion:(CCFlipImageViewCompletionBlock)completion;
{
    [self flipToView:view
            duration:duration
          removeView:YES
           direction:CCFlipImageViewFlipDirectionDown
          completion:completion];
}

- (void)flipToView:(UIView *)view
          duration:(CGFloat)duration
         direction:(CCFlipImageViewFlipDirection)direction
        completion:(CCFlipImageViewCompletionBlock)completion;
{
    [self flipToView:view
            duration:duration
          removeView:YES
           direction:direction
          completion:completion];
}

- (void)flipToView:(UIView *)view
          duration:(CGFloat)duration
        removeView:(BOOL)removeFromSuperView
         direction:(CCFlipImageViewFlipDirection)direction
        completion:(CCFlipImageViewCompletionBlock)completion;
{
    // screenshots
    UIImage *oldImage = [self imageSnapshotAfterScreenUpdates:NO];
    UIImage *newImage = [view imageSnapshotAfterScreenUpdates:YES];
    
    // add new view
    [self.superview insertSubview:view belowSubview:self];
    view.frame = self.frame;
    
    // create & add flipview
    [self addFlipViewWithAnimationFromImage:oldImage toImage:newImage
                                   duration:duration
                                  direction:direction
                                 completion:completion];
    
    // remove old view
    if (removeFromSuperView) {
        [self removeFromSuperview];
    }
}

#pragma mark View updates using a flip animation

- (void)updateWithFlipAnimationUpdates:(CCFlipImageViewViewUpdateBlock)updates;
{
    [self updateWithFlipAnimationDuration:CCFlipImageViewDefaultFlipDuration
                                direction:CCFlipImageViewFlipDirectionDown
                                  updates:updates
                               completion:nil];
}

- (void)updateWithFlipAnimationUpdates:(CCFlipImageViewViewUpdateBlock)updates
                            completion:(CCFlipImageViewCompletionBlock)completion;
{
    [self updateWithFlipAnimationDuration:CCFlipImageViewDefaultFlipDuration
                                direction:CCFlipImageViewFlipDirectionDown
                                  updates:updates
                               completion:completion];
}

- (void)updateWithFlipAnimationDuration:(CGFloat)duration
                                updates:(CCFlipImageViewViewUpdateBlock)updates
                             completion:(CCFlipImageViewCompletionBlock)completion;
{
    [self updateWithFlipAnimationDuration:duration
                                direction:CCFlipImageViewFlipDirectionDown
                                  updates:updates
                               completion:completion];
}

- (void)updateWithFlipAnimationDuration:(CGFloat)duration
                              direction:(CCFlipImageViewFlipDirection)direction
                                updates:(CCFlipImageViewViewUpdateBlock)updates
                             completion:(CCFlipImageViewCompletionBlock)completion;
{
    // screenshots & updates
    UIImage *oldImage = [self imageSnapshotAfterScreenUpdates:NO];
    if (updates) updates();
    UIImage *newImage = [self imageSnapshotAfterScreenUpdates:YES];
    
    // create & add flipview
    [self addFlipViewWithAnimationFromImage:oldImage toImage:newImage
                                   duration:duration
                                  direction:direction
                                 completion:completion];
}

#pragma mark Reused Code

- (UIImage *)imageSnapshotAfterScreenUpdates:(BOOL)afterScreenUpdates;
{
    CGSize size = self.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000 // only when SDK is >= ios7
    if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [self drawViewHierarchyInRect:(CGRect) {CGPointZero, size } afterScreenUpdates:afterScreenUpdates];
    } else {
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
#else
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
#endif
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (CCFlipImageView *)addFlipViewWithAnimationFromImage:(UIImage *)fromImage
                                               toImage:(UIImage *)toImage
                                              duration:(NSTimeInterval)duration
                                             direction:(CCFlipImageViewFlipDirection)direction
                                            completion:(CCFlipImageViewCompletionBlock)completion;
{
    NSParameterAssert(fromImage);
    NSParameterAssert(toImage);
    if (!fromImage || !toImage) return nil;
    
    // create & add flipview
    CCFlipImageView *flipImageView = [[CCFlipImageView alloc] initWithImage:fromImage];
    flipImageView.frame = self.frame;
    flipImageView.flipDirection = direction;
    [self.superview insertSubview:flipImageView aboveSubview:self];
    
    // hide actual view while animating (for transculent views)
    self.hidden = YES;
    
    // animate
    __weak typeof(self) blockSelf = self;
    __weak typeof(flipImageView) blockFlipImageView = flipImageView;
    [flipImageView setImageAnimated:toImage duration:duration completion:^(BOOL finished) {
        [blockFlipImageView removeFromSuperview];
        // show view again
        blockSelf.hidden = NO;
        
        // call completion
        if (completion) {
            completion(finished);
        }
    }];
    
    return flipImageView;
}

@end
