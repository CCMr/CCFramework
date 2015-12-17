//
//  CroppableBitmapRep.h
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

@protocol BitmapCropManipulator

@optional
- (void)cropFrame:(CGRect)frame;
- (void)cropTopFrame:(CGRect)frame;
- (void)cropTopEllipse:(CGRect)frame;
- (CGImageRef)croppedImageWithFrame:(CGRect)frame;

@end

@interface BitmapCropManipulator : BitmapContextManipulator {
}

/**
 * Cuts a part of the bitmap out for a new bitmap.
 * @param frame The rectangle from which a portion of the image will
 * be cut.
 * The coordinates for this start at (0,0).
 * @discussion The coordinates for this method begin in the bottom
 * left corner.  For a coordinate system starting from the top
 * left corner, use cropTopFrame: instead.
 */
- (void)cropFrame:(CGRect)frame;

/**
 * Cuts a part of the bitmap out for a new bitmap.
 * @param frame The rectangle from which a portion of the image will
 * be cut.
 * The coordinates for this start at (0,0).
 * @discussion The coordinates for this method begin in the top
 * left corner.  For a coordinate system starting from the bottom
 * left corner, use cropFrame: instead.
 */
- (void)cropTopFrame:(CGRect)frame;

/**
 * Cuts an ellipse of the bitmap out for a new bitmap.
 * @param frame The rectangle around the ellipse to be cut. The
 * coordinates for this start at (0,0).
 * @discussion The coordinates for this method begin in the top
 * left corner.  There is no alternative.
 */
- (void)cropTopEllipse:(CGRect)frame;

/**
 * Creates a new CGImageRef by cutting out a portion of this one.
 * This takes its behavoir from cropFrame.
 * @return An autoreleased CGImageRef that has been cropped from this
 * image.
 */
- (CGImageRef)croppedImageWithFrame:(CGRect)frame;

@end
