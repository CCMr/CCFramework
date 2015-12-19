//
//  CCColorWell.m
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

#import "CCColorWell.h"
#import "CCColor.h"
#import "CCUtilities.h"

const float kCCColorWellShadowOpacity = 0.8f;

@implementation CCColorWell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (!self) {
        return nil;
    }
    
    [self buildShape];
    
    self.opaque = NO;
    self.backgroundColor = nil;
    
    return self;
}

- (void)buildShape
{
    float inset = _phoneLandscapeMode ? 11 : 8;
    float cornerRadius = _phoneLandscapeMode ? 3 : 5;
    
    CGRect box = CGRectInset(self.bounds, inset, inset);
    
    box = CGRectOffset(box, 0, 1);
    self.shape = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(box, 0.5, 0.5) cornerRadius:cornerRadius];
    self.shape.lineWidth = 1;
    
    CALayer *layer = self.layer;
    layer.shadowRadius = 1;
    layer.shadowOpacity = kCCColorWellShadowOpacity;
    layer.shadowOffset = CGSizeZero;
    layer.shadowPath = [self shape].CGPath;
}

- (void)setColor:(CCColor *)inColor
{
    _color = inColor;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (_color.alpha < 1.0) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        [self.shape addClip];
        CCDrawTransparencyDiamondInRect(ctx, self.shape.bounds);
        CGContextRestoreGState(ctx);
    }
    
    [self.color set];
    [self.shape fill];
    
    [[UIColor whiteColor] set];
    [self.shape stroke];
}

- (void)setPhoneLandscapeMode:(BOOL)inPhoneLandscapeMode
{
    _phoneLandscapeMode = inPhoneLandscapeMode;
    [self buildShape];
    [self setNeedsDisplay];
}


@end
