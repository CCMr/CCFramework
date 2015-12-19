//
//  CCColorComparator.m
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


#import "CCColorComparator.h"
#import "CCUtilities.h"
#import "CCColor.h"

@interface CCColorComparator ()

@property(nonatomic, assign) CGRect leftCircle;

@property(nonatomic, assign) CGRect rightCircle;

@end

@implementation CCColorComparator

- (instancetype)init
{
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _initialColor = [CCColor whiteColor];
    _currentColor = [CCColor whiteColor];
    
    [self computeCircleRects];
    [self buildInsetShadowView];
    
    self.backgroundColor = nil;
    self.opaque = NO;
}

- (void)computeCircleRects
{
    CGRect bounds = CGRectInset([self bounds], 1, 1);
    
    _leftCircle = bounds;
    _leftCircle.size.width /= 2;
    _leftCircle.size.height /= 2;
    
    float inset = floorf(bounds.size.width * 0.125f);
    _rightCircle = CGRectInset(bounds, inset, inset);
    _rightCircle = CGRectOffset(_rightCircle, inset, inset);
}

- (void)buildInsetShadowView
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
    
    // paint the left shadowed circle
    [self insetCircleInRect:_leftCircle context:ctx];
    
    // knock out a hole for the right shadowed circle
    [[UIColor whiteColor] set];
    CGContextSetBlendMode(ctx, kCGBlendModeClear);
    CGContextFillEllipseInRect(ctx, CGRectInset(_rightCircle, -3, -3));
    CGContextSetBlendMode(ctx, kCGBlendModeNormal);
    
    // paint the right shadowed circle
    [self insetCircleInRect:CGRectInset(_rightCircle, 1, 1) context:ctx];
    
    CGContextRestoreGState(ctx);
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:result];
    [self addSubview:imageView];
}


- (void)insetCircleInRect:(CGRect)rect context:(CGContextRef)ctx
{
    CGContextSaveGState(ctx);
    CGContextAddEllipseInRect(ctx, rect);
    CGContextClip(ctx);
    
    CGContextSetShadow(ctx, CGSizeMake(0, 4), 8);
    CGContextAddRect(ctx, CGRectInset(rect, -20, -20));
    CGContextAddEllipseInRect(ctx, CGRectInset(rect, -1, -1));
    CGContextEOFillPath(ctx);
    CGContextRestoreGState(ctx);
}

- (void)paintTransparentColor:(CCColor *)color
                       inRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    [path addClip];
    
    CCDrawCheckersInRect(ctx, rect, 8);
    [[color UIColor] set];
    CGContextFillRect(ctx, rect);
    CGContextRestoreGState(ctx);
}

- (void)drawRect:(CGRect)clip
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
    
    if (_initialColor.alpha < 1.0) {
        [self paintTransparentColor:_initialColor inRect:_leftCircle];
    } else {
        [[_initialColor opaqueUIColor] set];
        CGContextFillEllipseInRect(ctx, _leftCircle);
    }
    
    if (_currentColor.alpha < 1.0) {
        [self paintTransparentColor:_currentColor inRect:_rightCircle];
    } else {
        [[_currentColor opaqueUIColor] set];
        CGContextFillEllipseInRect(ctx, _rightCircle);
    }
    
    [[UIColor whiteColor] set];
    CGContextSetLineWidth(ctx, 4);
    CGContextSetBlendMode(ctx, kCGBlendModeClear);
    CGContextStrokeEllipseInRect(ctx, CGRectInset(_rightCircle, -1, -1));
    CGContextSetBlendMode(ctx, kCGBlendModeNormal);
    
    CGContextRestoreGState(ctx);
}

- (CCColor *)color
{
    return self.tappedColor;
}

- (void)takeColorFrom:(id)sender
{
    [self setCurrentColor:(CCColor *)[sender color]];
}

- (void)setCurrentColor:(CCColor *)color
{
    _currentColor = color;
    
    [self setNeedsDisplay];
}

- (void)setOldColor:(CCColor *)color
{
    _initialColor = color;
    
    [self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    self.initialTap = [touch locationInView:self];
    
    CGRect upperLeft = [self bounds];
    upperLeft.size.width /= 2;
    upperLeft.size.height /= 2;
    
    self.tappedColor = CGRectContainsPoint(upperLeft, self.initialTap) ? _initialColor : _currentColor;
    
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    if (!self.moved) {
        [[UIApplication sharedApplication] sendAction:self.action
                                                   to:self.target
                                                 from:self
                                             forEvent:nil];
        return;
    }
    
    [super touchesEnded:touches
              withEvent:event];
}

@end
