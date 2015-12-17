//
//  BitmapDrawManipulator.m
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

#import "BitmapDrawManipulator.h"

@implementation BitmapDrawManipulator

- (void)drawImage:(CGImageRef)image inRect:(CGRect)rect
{
    BMPoint size = [bitmapContext bitmapSize];
    // It's kind of rude to prevent them from doing something kind of cool, so let's not.
    // NSAssert(frame.origin.x >= 0 && frame.origin.x + frame.size.width <= size.x, @"Cropping frame must be within the bitmap.");
    // NSAssert(frame.origin.y >= 0 && frame.origin.y + frame.size.height <= size.y, @"Cropping frame must be within the bitmap.");
    
    CGPoint offset = CGPointMake(rect.origin.x, (size.y - (rect.origin.y + rect.size.height)));
    
    CGContextRef context = [[self bitmapContext] context];
    CGContextSaveGState(context);
    CGContextDrawImage(context, CGRectMake(offset.x, offset.y, rect.size.width, rect.size.height), image);
    CGContextRestoreGState(context);
    [self.bitmapContext setNeedsUpdate:YES];
}

- (void)drawEllipseInFrame:(CGRect)frame color:(CGColorRef)color
{
    CGContextRef context = [[self bitmapContext] context];
    CGContextSaveGState(context);
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -[bitmapContext bitmapSize].y);
    CGContextSetFillColorWithColor(context, color);
    CGContextFillEllipseInRect(context, frame);
    CGContextRestoreGState(context);
    [self.bitmapContext setNeedsUpdate:YES];
}

@end
