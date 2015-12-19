//
//  CCColorSourceView.m
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

#import "CCColorSourceView.h"
#import "CCDragChip.h"
#import "CCUtilities.h"
#import "UIView+BUIView.h"

#define kChipSize 50
#define kChipVerticalOffset 1.25

@implementation CCColorSourceView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    if (self = [super initWithCoder:aDecoder]) {
        self.exclusiveTouch = YES;
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    _initialTap = [[touches anyObject] locationInView:self];
    _moved = NO;
}

- (void)touchesMoved:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    if (![self color]) {
        return;
    }
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self.superview];
    
    if (!_moved) {
        _moved = YES;
        
        self.dragChip = [[CCDragChip alloc] initWithFrame:CGRectMake(0, 0, kChipSize, kChipSize)];
        self.dragChip.color = [self color];
        [window addSubview:self.dragChip];
    }
    
    CGPoint center = CCAddPoints(pt, CGPointMake(0, -kChipVerticalOffset * kChipSize));
    
    self.dragChip.sharpCenter = [self.superview convertPoint:center
                                                      toView:window];
    
    self.dragChip.transform = CCTransformForOrientation([UIApplication sharedApplication].statusBarOrientation);
    
    id newTarget = nil;
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIView *target = [keyWindow hitTest:[touch locationInView:keyWindow] withEvent:event];
    
    if ([target respondsToSelector:@selector(dragMoved:colorChip:colorSource:)]) {
        [(id<CCColorDragging>)target dragMoved:touch
                                     colorChip:self.dragChip
                                   colorSource:self];
        newTarget = target;
    }
    
    if (_lastTarget != newTarget) {
        [(id<CCColorDragging>)_lastTarget dragExited];
        _lastTarget = newTarget;
    }
}

- (void)chipAnimationDidStop:(NSString *)animationID
                    finished:(NSNumber *)finished
                     context:(void *)context
{
    [self.dragChip removeFromSuperview];
    self.dragChip = nil;
}

- (void)touchesCancelled:(NSSet *)touches
               withEvent:(UIEvent *)event
{
    [self.dragChip removeFromSuperview];
    self.dragChip = nil;
}

- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    if (![self color]) {
        return;
    }
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    UITouch *touch = [touches anyObject];
    BOOL accepted = NO;
    CGPoint flyLoc;
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIView *target = [keyWindow hitTest:[touch locationInView:keyWindow] withEvent:event];
    
    if ([target respondsToSelector:@selector(dragEnded:colorChip:colorSource:destination:)]) {
        accepted = [(id<CCColorDragging>)target dragEnded:touch
                                                colorChip:self.dragChip
                                              colorSource:self
                                              destination:&flyLoc];
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(chipAnimationDidStop:finished:context:)];
    
    self.dragChip.alpha = 0;
    if (!accepted) {
        self.dragChip.center = [self convertPoint:_initialTap toView:window];
    } else {
        self.dragChip.center = flyLoc;
        self.dragChip.transform = CGAffineTransformScale(self.dragChip.transform, 0.1f, 0.1f);
    }
    
    [self dragEnded];
    
    [UIView commitAnimations];
}

- (CCColor *)color
{
    return nil;
}

- (void)dragEnded
{
}

@end
