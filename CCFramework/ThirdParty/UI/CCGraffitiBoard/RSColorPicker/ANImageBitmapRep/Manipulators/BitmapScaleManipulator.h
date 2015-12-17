//
//  ScalableBitmapRep.h
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

@protocol BitmapScaleManipulator <NSObject>

@optional
- (void)setSize:(BMPoint)aSize;
- (void)setSizeFittingFrame:(BMPoint)aSize;
- (void)setSizeFillingFrame:(BMPoint)aSize;

@end

@interface BitmapScaleManipulator : BitmapContextManipulator {
}

/**
 * Stretches the bitmap context to a specified size.
 * @param aSize The new size to make the bitmap.
 * If this is the same as the current size, the bitmap
 * will not be changed.
 */
- (void)setSize:(BMPoint)aSize;

/**
 * Scales the image to fit a particular frame without stretching (bringing out of scale).
 * @param aSize The size to which the image scaled.
 * @discussion The actual image itself will most likely be smaller than the specified
 * size, leaving transparent edges to make the image fit the exact size.
 */
- (void)setSizeFittingFrame:(BMPoint)aSize;

/**
 * Scales the image to fill a particular frame without stretching.
 * This will most likely cause the left and right or top and bottom
 * edges of the image to be cut off.
 * @param aSize The size that the image will be forced to fill.
 */
- (void)setSizeFillingFrame:(BMPoint)aSize;

@end
