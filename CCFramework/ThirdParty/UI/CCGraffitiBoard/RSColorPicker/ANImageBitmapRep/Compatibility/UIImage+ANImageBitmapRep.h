//
//  UIImage+ANImageBitmapRep.h
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

@class ANImageBitmapRep;

#import <UIKit/UIKit.h>

@interface UIImage (ANImageBitmapRep)

#if __has_feature(objc_arc) == 1
+ (UIImage *)imageFromImageBitmapRep:(ANImageBitmapRep *)ibr __attribute__((ns_returns_autoreleased));
- (ANImageBitmapRep *)imageBitmapRep __attribute__((ns_returns_autoreleased));
- (UIImage *)imageByScalingToSize:(CGSize)sz __attribute__((ns_returns_autoreleased));
- (UIImage *)imageFittingFrame:(CGSize)sz __attribute__((ns_returns_autoreleased));
- (UIImage *)imageFillingFrame:(CGSize)sz __attribute__((ns_returns_autoreleased));
#else
+ (UIImage *)imageFromImageBitmapRep:(ANImageBitmapRep *)ibr;
- (ANImageBitmapRep *)imageBitmapRep;
- (UIImage *)imageByScalingToSize:(CGSize)sz;
- (UIImage *)imageFittingFrame:(CGSize)sz;
- (UIImage *)imageFillingFrame:(CGSize)sz;
#endif

@end

#endif
