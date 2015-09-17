//
//  UIImage+Operations.h
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

#import <UIKit/UIKit.h>

/**
 *  @author CC, 15-09-02
 *
 *  @brief  图片特效
 *
 *  @since 1.0
 */
@interface UIImage (Operations)

// Convolution Oprations
- (UIImage *)gaussianBlur;
- (UIImage *)edgeDetection;
- (UIImage *)emboss;
- (UIImage *)sharpen;
- (UIImage *)unsharpen;

// Geometric Operations
- (UIImage *)rotateInRadians:(float)radians;

// Morphological Operations
- (UIImage *)dilate;
- (UIImage *)erode;
- (UIImage *)dilateWithIterations:(int)iterations;
- (UIImage *)erodeWithIterations:(int)iterations;
- (UIImage *)gradientWithIterations:(int)iterations;
- (UIImage *)tophatWithIterations:(int)iterations;
- (UIImage *)blackhatWithIterations:(int)iterations;

// Histogram Operations
- (UIImage *)equalization;

- (UIImage *)imageBlendedWithImage: (UIImage *)overlayImage
                         blendMode: (CGBlendMode)blendMode
                             alpha:(CGFloat)alpha;

@end
