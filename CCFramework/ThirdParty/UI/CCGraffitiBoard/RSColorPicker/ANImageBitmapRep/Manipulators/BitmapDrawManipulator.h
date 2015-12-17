//
//  BitmapDrawManipulator.h
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

@protocol BitmapDrawManipulator

@optional

- (void)drawImage:(CGImageRef)image
           inRect:(CGRect)rect;

- (void)drawEllipseInFrame:(CGRect)frame
                     color:(CGColorRef)color;

@end

@interface BitmapDrawManipulator : BitmapContextManipulator

/**
 * Overlays an image on the existing bitmap.
 * @param image The image to be overlayed.
 * @param rect The frame in which the image will be drawn.
 * The coordinates for this begin at the top-left hand
 * corner of the view.
 */
- (void)drawImage:(CGImageRef)image
           inRect:(CGRect)rect;

/**
 * Draws a colored ellipse in a given rectangle.
 * @param frame The rectangle in which to draw the ellipse
 * @param color The fill color for the ellipse.  The coordinates
 * for this begin at the top-left hand corner of the view.
 */
- (void)drawEllipseInFrame:(CGRect)frame
                     color:(CGColorRef)color;

@end
