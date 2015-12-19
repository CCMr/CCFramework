//
//  CCColorIndicator.m
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

#import "CCColorIndicator.h"
#import "CCColor.h"
#import "CCUtilities.h"

@implementation CCColorIndicator

+ (CCColorIndicator *)colorIndicator
{
    CCColorIndicator *indicator = [[CCColorIndicator alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    return indicator;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (!self) {
        return nil;
    }
    
    self.color = [CCColor whiteColor];
    self.opaque = NO;
    
    UIView *overlay = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:overlay];
    
    overlay.layer.borderColor = [UIColor whiteColor].CGColor;
    overlay.layer.borderWidth = 3;
    overlay.layer.cornerRadius = CGRectGetWidth(self.bounds) / 2.0f;
    
    overlay.layer.shadowOpacity = 0.5f;
    overlay.layer.shadowRadius = 1;
    overlay.layer.shadowOffset = CGSizeMake(0, 0);
    
    return self;
}

- (void)setColor:(CCColor *)color
{
    if ([color isEqual:_color]) {
        return;
    }
    
    _color = color;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (![self color]) {
        return;
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect bounds = CGRectInset([self bounds], 2, 2);
    
    if (self.alphaMode) {
        CGContextSaveGState(ctx);
        CGContextAddEllipseInRect(ctx, bounds);
        CGContextClip(ctx);
        CCDrawTransparencyDiamondInRect(ctx, bounds);
        CGContextRestoreGState(ctx);
        [[self color] set];
    } else {
        [[[self color] opaqueUIColor] set];
    }
    
    CGContextFillEllipseInRect(ctx, bounds);
}

- (BOOL)pointInside:(CGPoint)point
          withEvent:(UIEvent *)event
{
    return NO;
}


@end
