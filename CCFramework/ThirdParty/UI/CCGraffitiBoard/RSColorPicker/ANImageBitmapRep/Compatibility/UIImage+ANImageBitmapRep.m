//
//  UIImage+ANImageBitmapRep.m
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

#import "TargetConditionals.h"

#if TARGET_OS_IPHONE

#import "UIImage+ANImageBitmapRep.h"
#import "ANImageBitmapRep.h"

@implementation UIImage (ANImageBitmapRep)


+ (UIImage *)imageFromImageBitmapRep:(ANImageBitmapRep *)ibr
{
    return [ibr image];
}

- (ANImageBitmapRep *)imageBitmapRep
{
#if __has_feature(objc_arc) == 1
    return [[ANImageBitmapRep alloc] initWithImage:self];
#else
    return [[[ANImageBitmapRep alloc] initWithImage:self] autorelease];
#endif
}

- (UIImage *)imageByScalingToSize:(CGSize)sz
{
    ANImageBitmapRep *imageBitmap = [[ANImageBitmapRep alloc] initWithImage:self];
    [imageBitmap setSize:BMPointMake(round(sz.width), round(sz.height))];
    UIImage *scaled = [imageBitmap image];
#if __has_feature(objc_arc) != 1
    [imageBitmap release];
#endif
    return scaled;
}

- (UIImage *)imageFittingFrame:(CGSize)sz
{
    ANImageBitmapRep *imageBitmap = [[ANImageBitmapRep alloc] initWithImage:self];
    [imageBitmap setSizeFittingFrame:BMPointMake(round(sz.width), round(sz.height))];
    UIImage *scaled = [imageBitmap image];
#if __has_feature(objc_arc) != 1
    [imageBitmap release];
#endif
    return scaled;
}

- (UIImage *)imageFillingFrame:(CGSize)sz
{
    ANImageBitmapRep *imageBitmap = [[ANImageBitmapRep alloc] initWithImage:self];
    [imageBitmap setSizeFillingFrame:BMPointMake(round(sz.width), round(sz.height))];
    UIImage *scaled = [imageBitmap image];
#if __has_feature(objc_arc) != 1
    [imageBitmap release];
#endif
    return scaled;
}

@end

#endif
