//
//  RotatableBitmapRep.h
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

#import <Foundation/Foundation.h>
#import "BitmapContextManipulator.h"

@protocol BitmapRotationManipulator

@optional
- (void)rotate:(CGFloat)degrees;
- (CGImageRef)imageByRotating:(CGFloat)degrees;

@end

@interface BitmapRotationManipulator : BitmapContextManipulator {
}

/**
 * Rotate the image bitmap around its center by a certain number of degrees.
 * @param degrees The degrees from 0 to 360.  This is not measured in radians.
 * @discussion This will resize the image if needed.
 */
- (void)rotate:(CGFloat)degrees;

/**
 * Create a new image by rotating this image bitmap around its center by a specified
 * number of degrees.
 * @param degrees The degrees (not in radians) by which the image should be rotated.
 * @discussion This will resize the image if needed.
 */
- (CGImageRef)imageByRotating:(CGFloat)degrees;

@end
