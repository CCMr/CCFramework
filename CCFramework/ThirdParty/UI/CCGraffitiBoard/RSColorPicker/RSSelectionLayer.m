//
//  RSSelectionView.m
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
#import "RSSelectionLayer.h"

/*
 @interface RSSelectionLayer ()
 
 @property (nonatomic, strong) CGColorRef outerRingColor __attribute__((NSObject));
 @property (nonatomic, strong) CGColorRef innerRingColor __attribute__((NSObject));
 
 @end
 */
@implementation RSSelectionLayer

- (void)drawInContext:(CGContextRef)ctx
{
    /*
     if (!self.outerRingColor || !self.innerRingColor) {
     self.outerRingColor = [[UIColor colorWithWhite:1 alpha:0.4] CGColor];
     self.innerRingColor = [[UIColor colorWithWhite:0 alpha:1] CGColor];
     }
     */
    CGRect rect = self.bounds;
    
    CGContextSetLineWidth(ctx, 3);
    //    CGContextSetStrokeColorWithColor(ctx, self.outerRingColor);
    CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 0.4); // 这有个内存泄露,改成这样好了.
    CGContextStrokeEllipseInRect(ctx, CGRectInset(rect, 1.5, 1.5));
    
    CGContextSetLineWidth(ctx, 2);
    //    CGContextSetStrokeColorWithColor(ctx, self.innerRingColor);
    CGContextSetRGBStrokeColor(ctx, 0, 0, 0, 1.0);
    CGContextStrokeEllipseInRect(ctx, CGRectInset(rect, 3, 3));
}

@end