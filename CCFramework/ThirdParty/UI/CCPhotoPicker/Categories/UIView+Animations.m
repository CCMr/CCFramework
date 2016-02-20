//
//  UIView+Animations.m
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

#import "UIView+Animations.h"

@implementation UIView (Animations)


+ (void)animationWithLayer:(CALayer *)layer type:(CCAnimationType)type {
    NSNumber *animationScale1 = type == CCAnimationTypeSmaller ? @(1.15) : @(0.7);
    NSNumber *animationScale2 = type == CCAnimationTypeBigger ? @(0.92) : @(1.15);
    
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        [layer setValue:animationScale1 forKeyPath:@"transform.scale"];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
            [layer setValue:animationScale2 forKeyPath:@"transform.scale"];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                [layer setValue:@(1.0) forKeyPath:@"transform.scale"];
            } completion:nil];
        }];
    }];
}

+ (CABasicAnimation *)animationWithFromValue:(id)fromValue toValue:(id)toValue duration:(CGFloat)duration forKeypath:(NSString *)keypath {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keypath];
    animation.fromValue = fromValue;
    animation.toValue   = toValue;
    animation.duration = duration;
    animation.repeatCount = 0;
    animation.autoreverses = NO;
    //保证动画不会复原到初始位置
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    return animation;
}
@end
