//
//  CGContextCreator.m
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

#import "CGContextCreator.h"


@implementation CGContextCreator

- (id)init
{
    if ((self = [super init])) {
        // Initialization code here.
    }
    
    return self;
}

+ (CGContextRef)newARGBBitmapContextWithSize:(CGSize)size
{
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    void *bitmapData;
    int bitmapByteCount;
    int bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = round(size.width);
    size_t pixelsHigh = round(size.height);
    
    bitmapBytesPerRow = (int)(pixelsWide * 4);
    bitmapByteCount = (int)(bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL) {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // allocate
    bitmapData = malloc(bitmapByteCount);
    if (bitmapData == NULL) {
        NSLog(@"Malloc failed which is too bad.  I was hoping to use this memory.");
        CGColorSpaceRelease(colorSpace);
        // even though CGContextRef technically is not a pointer,
        // it's typedef probably is and it is a scalar anyway.
        return NULL;
    }
    
    // Create the bitmap context. We are
    // setting up the image as an ARGB (0-255 per component)
    // 4-byte per/pixel.
    context = CGBitmapContextCreate(bitmapData,
                                    pixelsWide,
                                    pixelsHigh,
                                    8,
                                    bitmapBytesPerRow,
                                    colorSpace,
                                    (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    if (context == NULL) {
        free(bitmapData);
        NSLog(@"Failed to create bitmap!");
    }
    
    CGContextClearRect(context, CGRectMake(0, 0, size.width, size.height));
    CGColorSpaceRelease(colorSpace);
    
    return context;
}

+ (CGContextRef)newARGBBitmapContextWithImage:(CGImageRef)image
{
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    void *bitmapData;
    int bitmapByteCount;
    int bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(image);
    size_t pixelsHigh = CGImageGetHeight(image);
    
    bitmapBytesPerRow = (int)(pixelsWide * 4);
    bitmapByteCount = (int)(bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL) {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // allocate
    bitmapData = malloc(bitmapByteCount);
    if (bitmapData == NULL) {
        NSLog(@"Malloc failed which is too bad.  I was hoping to use this memory.");
        CGColorSpaceRelease(colorSpace);
        // even though CGContextRef technically is not a pointer,
        // it's typedef probably is and it is a scalar anyway.
        return NULL;
    }
    
    // Create the bitmap context. We are
    // setting up the image as an ARGB (0-255 per component)
    // 4-byte per/pixel.
    context = CGBitmapContextCreate(bitmapData,
                                    pixelsWide,
                                    pixelsHigh,
                                    8, // bits per component
                                    bitmapBytesPerRow,
                                    colorSpace,
                                    (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    if (context == NULL) {
        free(bitmapData);
        NSLog(@"Failed to create bitmap!");
    }
    
    // draw the image on the context.
    // CGContextTranslateCTM(context, 0, CGImageGetHeight(image));
    // CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClearRect(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)));
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    
    CGColorSpaceRelease(colorSpace);
    
    return context;
}

#if __has_feature(objc_arc) != 1
- (void)dealloc
{
    [super dealloc];
}
#endif

@end
