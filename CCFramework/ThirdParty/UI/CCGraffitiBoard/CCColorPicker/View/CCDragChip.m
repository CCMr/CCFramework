//
//  CCDragChip.m
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


#import "CCDragChip.h"
#import "CCColor.h"
#import "CCUtilities.h"

@implementation CCDragChip

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.opaque = NO;
        self.backgroundColor = nil;
        
        // shadow
        self.layer.shadowOffset = CGSizeMake(0, 2);
        self.layer.shadowRadius = 2;
        self.layer.shadowOpacity = 0.25;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGRect bounds = CGRectInset(self.bounds, 1, 1);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:5];
    
    if (self.color.alpha < 1.0) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        [path addClip];
        CCDrawTransparencyDiamondInRect(ctx, self.bounds);
        CGContextRestoreGState(ctx);
    }
    
    [self.color set];
    [path fill];
    
    [[UIColor whiteColor] set];
    path.lineWidth = 2;
    [path stroke];
}


@end
