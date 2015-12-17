//
//  RSColorPickerState.h
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
#import "RSColorFunctions.h"

/**
 * Represents the state of a color picker. This includes
 * the position on the color picker (for a square picker) that
 * is selected.
 *
 * Terms used:
 * "size" - the diameter of the color picker
 * "padding" - the amount of pixels on each side of the color picker
 *             reserved for padding
 */
@interface RSColorPickerState : NSObject {
    CGPoint scaledRelativePoint; // H & S
    CGFloat brightness;		 // V
    CGFloat alpha;		 // A
}

@property(readonly) CGFloat hue, saturation, brightness, alpha;

/**
 * Creates a state with a 1.0 alpha and 1.0 brightness that would arise
 * by selecting `point` on a color picker of diameter `size` and padding `padding`.
 */
+ (RSColorPickerState *)stateForPoint:(CGPoint)point size:(CGFloat)size padding:(CGFloat)padding;

/**
 * Create a state with a given color.
 */
- (id)initWithColor:(UIColor *)selectionColor;

/**
 * Create a state given a point on the unit circle and brightness+alpha
 */
- (id)initWithScaledRelativePoint:(CGPoint)p brightness:(CGFloat)V alpha:(CGFloat)A;

/**
 * Create a state given HSVA components.
 */
- (id)initWithHue:(CGFloat)H saturation:(CGFloat)S brightness:(CGFloat)V alpha:(CGFloat)A;

- (UIColor *)color;

/**
 * Returns the position of this state on a color picker of size `size` and padding `padding`.
 * Note: this point may be outside of the unit circle if a point outside the unit circle
 * was picked to generate this state.
 */
- (CGPoint)selectionLocationWithSize:(CGFloat)size padding:(CGFloat)padding;

// This class is immutable, so these are helpful!
- (RSColorPickerState *)stateBySettingBrightness:(CGFloat)newBright;
- (RSColorPickerState *)stateBySettingAlpha:(CGFloat)newAlpha;
- (RSColorPickerState *)stateBySettingHue:(CGFloat)newHue;
- (RSColorPickerState *)stateBySettingSaturation:(CGFloat)newSaturation;

@end
