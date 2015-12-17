//
//  BitmapContextRep.m
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

#import "BitmapContextRep.h"

BMPoint BMPointMake(long x, long y)
{
    BMPoint p;
    p.x = x;
    p.y = y;
    return p;
}

BMPoint BMPointFromSize(CGSize size)
{
    return BMPointMake(round(size.width), round(size.height));
}

BMPoint BMPointFromPoint(CGPoint point)
{
    return BMPointMake(round(point.x), round(point.y));
}

@implementation BitmapContextRep

- (id)initWithImage:(ANImageObj *)image
{
    if ((self = [super init])) {
        CGImageRef img = CGImageFromANImage(image);
        context = [CGContextCreator newARGBBitmapContextWithImage:img];
        bitmapData = CGBitmapContextGetData(context);
        lastImage = CGImageRetain(img);
    }
    return self;
}

- (id)initWithCGImage:(CGImageRef)img
{
    if ((self = [super init])) {
        context = [CGContextCreator newARGBBitmapContextWithImage:img];
        bitmapData = CGBitmapContextGetData(context);
        lastImage = CGImageRetain(img);
    }
    return self;
}

- (id)initWithSize:(BMPoint)sizePoint
{
    if ((self = [super init])) {
        if (sizePoint.x == 0 || sizePoint.y == 0) {
#if __has_feature(objc_arc)
            return nil;
#else
            [super dealloc];
            return nil;
#endif
        }
        context = [CGContextCreator newARGBBitmapContextWithSize:CGSizeMake(sizePoint.x, sizePoint.y)];
        bitmapData = CGBitmapContextGetData(context);
        lastImage = CGBitmapContextCreateImage(context);
    }
    return self;
}

- (CGContextRef)context
{
    return context;
}

- (void)setContext:(CGContextRef)aContext
{
    if (context == aContext) return;
    // free previous.
    CGContextRelease(context);
    free(bitmapData);
    // create new.
    context = CGContextRetain(aContext);
    bitmapData = CGBitmapContextGetData(aContext);
    [self setNeedsUpdate:YES];
}

- (BMPoint)bitmapSize
{
    BMPoint point;
    point.x = (long)CGBitmapContextGetWidth(context);
    point.y = (long)CGBitmapContextGetHeight(context);
    return point;
}

- (void)setNeedsUpdate:(BOOL)flag
{
    needsUpdate = flag;
}

- (void)getRawPixel:(UInt8 *)rgba atPoint:(BMPoint)point
{
    size_t width = CGBitmapContextGetWidth(context);
    NSAssert(point.x >= 0 && point.x < width, @"Point must be within bitmap.");
    NSAssert(point.y >= 0 && point.y < CGBitmapContextGetHeight(context), @"Point must be within bitmap.");
    unsigned char *argbData = &bitmapData[((point.y * width) + point.x) * 4];
    rgba[0] = argbData[1]; // red
    rgba[1] = argbData[2]; // green
    rgba[2] = argbData[3]; // blue
    rgba[3] = argbData[0]; // alpha
    [self setNeedsUpdate:YES];
}

- (void)setRawPixel:(const UInt8 *)rgba atPoint:(BMPoint)point
{
    size_t width = CGBitmapContextGetWidth(context);
    NSAssert(point.x >= 0 && point.x < width, @"Point must be within bitmap.");
    NSAssert(point.y >= 0 && point.y < CGBitmapContextGetHeight(context), @"Point must be within bitmap.");
    unsigned char *argbData = &bitmapData[((point.y * width) + point.x) * 4];
    argbData[1] = rgba[0]; // red
    argbData[2] = rgba[1]; // green
    argbData[3] = rgba[2]; // blue
    argbData[0] = rgba[3]; // alpha
    [self setNeedsUpdate:YES];
}

- (CGImageRef)CGImage
{
    if (needsUpdate) {
        CGImageRelease(lastImage);
        lastImage = CGBitmapContextCreateImage(context);
        needsUpdate = NO;
    }
#if __has_feature(objc_arc) == 1
    return (__bridge CGImageRef)CGImageReturnAutoreleased(lastImage);
#else
    return (CGImageRef)[[CGImageContainer imageContainerWithImage:lastImage] image];
#endif
}

- (unsigned char *)bitmapData
{
    return bitmapData;
}

- (void)dealloc
{
    CGContextRelease(context);
    free(bitmapData);
    if (lastImage != NULL) {
        CGImageRelease(lastImage);
    }
#if __has_feature(objc_arc) != 1
    [super dealloc];
#endif
}

@end
