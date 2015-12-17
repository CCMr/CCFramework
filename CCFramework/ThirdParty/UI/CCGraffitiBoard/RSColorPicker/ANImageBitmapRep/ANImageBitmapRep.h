//
//  ANImageBitmapRep.h
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

#import "OSCommonImage.h"
#import "BitmapScaleManipulator.h"
#import "BitmapCropManipulator.h"
#import "BitmapRotationManipulator.h"
#import "BitmapDrawManipulator.h"
#import "UIImage+ANImageBitmapRep.h"

typedef struct {
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
} BMPixel;

BMPixel BMPixelMake(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha);
#if TARGET_OS_IPHONE
UIColor *UIColorFromBMPixel(BMPixel pixel);
#elif TARGET_OS_MAC
NSColor *NSColorFromBMPixel(BMPixel pixel);
#endif

@interface ANImageBitmapRep : BitmapContextRep <BitmapScaleManipulator, BitmapCropManipulator, BitmapRotationManipulator, BitmapDrawManipulator, NSCopying> {
#if __has_feature(objc_arc) == 1
    __strong NSArray *baseClasses;
#else
    NSArray *baseClasses;
#endif
}

#if __has_feature(objc_arc) == 1
+ (ANImageBitmapRep *)imageBitmapRepWithCGSize:(CGSize)avgSize __attribute__((ns_returns_autoreleased));
+ (ANImageBitmapRep *)imageBitmapRepWithImage:(ANImageObj *)anImage __attribute__((ns_returns_autoreleased));
#else
+ (ANImageBitmapRep *)imageBitmapRepWithCGSize:(CGSize)avgSize;
+ (ANImageBitmapRep *)imageBitmapRepWithImage:(ANImageObj *)anImage;
#endif

/**
 * Reverses the RGB values of all pixels in the bitmap.  This causes
 * an "inverted" effect.
 */
- (void)invertColors;

/**
 * Scales the image down, then back up again.  Use this to blur an image.
 * @param quality A percentage from 0 to 1, 0 being horrible quality, 1 being
 * perfect quality.
 */
- (void)setQuality:(CGFloat)quality;

/**
 * Darken or brighten the image.
 * @param brightness A percentage from 0 to 2.  In this case, 0 is the darkest
 * and 2 is the brightest.  If this is 1, no change will be made.
 */
- (void)setBrightness:(CGFloat)brightness;

/**
 * Returns a pixel at a given location.
 * @param point The point from which a pixel will be taken.  For all points
 * in a BitmapContextRep, the x and y values start at 0 and end at
 * width - 1 and height - 1 respectively.
 * @return The pixel with values taken from the specified point.
 */
- (BMPixel)getPixelAtPoint:(BMPoint)point;

/**
 * Sets a pixel at a specific location.
 * @param pixel An RGBA pixel represented by an array of four floats.
 * Each component is one float long, and goes from 0 to 1.  
 * In this case, 0 is black and 1 is white.
 * @param point The location of the pixel to change.  For all points
 * in a BitmapContextRep, the x and y values start at 0 and end at
 * width - 1 and height - 1 respectively.
 */
- (void)setPixel:(BMPixel)pixel atPoint:(BMPoint)point;

/**
 * Creates a new UIImage or NSImage from the bitmap context.
 */
#if __has_feature(objc_arc) == 1
- (ANImageObj *)image __attribute__((ns_returns_autoreleased));
#else
- (ANImageObj *)image;
#endif

@end
