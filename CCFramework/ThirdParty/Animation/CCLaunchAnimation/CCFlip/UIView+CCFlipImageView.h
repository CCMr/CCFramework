//
//  UIView+CCFlipImageView.h
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
#import "CCFlipImageView.h"

typedef void(^CCFlipImageViewViewUpdateBlock)(void);

@interface UIView (CCFlipImageView)

// Flip transition to another view

- (void)flipToView:(UIView*)view;

- (void)flipToView:(UIView*)view
        completion:(CCFlipImageViewCompletionBlock)completion;

- (void)flipToView:(UIView*)view
          duration:(CGFloat)duration
        completion:(CCFlipImageViewCompletionBlock)completion;

- (void)flipToView:(UIView*)view
          duration:(CGFloat)duration
         direction:(CCFlipImageViewFlipDirection)direction
        completion:(CCFlipImageViewCompletionBlock)completion;

- (void)flipToView:(UIView*)view
          duration:(CGFloat)duration
        removeView:(BOOL)removeFromSuperView
         direction:(CCFlipImageViewFlipDirection)direction
        completion:(CCFlipImageViewCompletionBlock)completion;

// Update a view using a flip animation

- (void)updateWithFlipAnimationUpdates:(CCFlipImageViewViewUpdateBlock)updates;

- (void)updateWithFlipAnimationUpdates:(CCFlipImageViewViewUpdateBlock)updates
                             completion:(CCFlipImageViewCompletionBlock)completion;

- (void)updateWithFlipAnimationDuration:(CGFloat)duration
                                updates:(CCFlipImageViewViewUpdateBlock)updates
                             completion:(CCFlipImageViewCompletionBlock)completion;

- (void)updateWithFlipAnimationDuration:(CGFloat)duration
                              direction:(CCFlipImageViewFlipDirection)direction
                                updates:(CCFlipImageViewViewUpdateBlock)updates
                             completion:(CCFlipImageViewCompletionBlock)completion;

@end
