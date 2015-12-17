//
//  OSCommonImage.c
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

#include "OSCommonImage.h"

CGImageRef CGImageFromANImage(ANImageObj *anImageObj)
{
#if TARGET_OS_IPHONE
    return [anImageObj CGImage];
#elif TARGET_OS_MAC
    CGImageSourceRef source;
#if __has_feature(objc_arc) == 1
    source = CGImageSourceCreateWithData((__bridge CFDataRef)[anImageObj TIFFRepresentation], NULL);
#else
    source = CGImageSourceCreateWithData((CFDataRef)[anImageObj TIFFRepresentation], NULL);
#endif
    CGImageRef maskRef = CGImageSourceCreateImageAtIndex(source, 0, NULL);
    CFRelease(source);
#if __has_feature(objc_arc) == 1
    CGImageRef autoreleased = (__bridge CGImageRef)CGImageReturnAutoreleased(maskRef);
    CGImageRelease(maskRef);
    return autoreleased;
#else
    CGImageContainer *container = [CGImageContainer imageContainerWithImage:maskRef];
    CGImageRelease(maskRef);
    return [container image];
#endif
#endif
}

ANImageObj *ANImageFromCGImage(CGImageRef imageRef)
{
#if TARGET_OS_IPHONE
    return [UIImage imageWithCGImage:imageRef];
#elif TARGET_OS_MAC
    NSImage *image = [[NSImage alloc] initWithCGImage:imageRef size:NSZeroSize];
#if __has_feature(objc_arc) == 1
    return image;
#else
    return [image autorelease];
#endif
#endif
}
