//
//  CCColor.h
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
#import <UIKit/UIKit.h>

@interface CCColor : NSObject <NSCopying>

@property(nonatomic, readonly) CGFloat hue;
@property(nonatomic, readonly) CGFloat saturation;
@property(nonatomic, readonly) CGFloat brightness;
@property(nonatomic, readonly) CGFloat alpha;
@property(nonatomic, readonly) float red;
@property(nonatomic, readonly) float green;
@property(nonatomic, readonly) float blue;

+ (CCColor *)randomColor;

+ (CCColor *)colorWithHue:(CGFloat)hue
               saturation:(CGFloat)saturation
               brightness:(CGFloat)brightness
                    alpha:(CGFloat)alpha;

+ (CCColor *)colorWithWhite:(float)white
                      alpha:(CGFloat)alpha;

+ (CCColor *)colorWithRed:(float)red
                    green:(float)green
                     blue:(float)blue
                    alpha:(CGFloat)alpha;

- (CCColor *)initWithHue:(CGFloat)hue
              saturation:(CGFloat)saturation
              brightness:(CGFloat)brightness
                   alpha:(CGFloat)alpha;

+ (CCColor *)colorWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionary;

+ (CCColor *)colorWithData:(NSData *)data;

+ (CCColor *)colorWithUIColor:(UIColor *)color;

- (NSData *)colorData;

- (UIColor *)UIColor;

- (UIColor *)opaqueUIColor;

- (CGColorRef)CGColor;

- (CGColorRef)opaqueCGColor;

- (void)set;

- (CCColor *)adjustColor:(CCColor * (^)(CCColor *color))adjustment;

- (CCColor *)colorBalanceRed:(float)rShift
                       green:(float)gShift
                        blue:(float)bShift;

- (CCColor *)adjustHue:(float)hShift
            saturation:(float)sShift
            brightness:(float)bShift;

- (CCColor *)inverted;

- (CCColor *)desaturated;

- (CCColor *)colorWithAlphaComponent:(float)alpha;

+ (CCColor *)blackColor;

+ (CCColor *)grayColor;

+ (CCColor *)whiteColor;

+ (CCColor *)cyanColor;

+ (CCColor *)redColor;

+ (CCColor *)magentaColor;

+ (CCColor *)greenColor;

+ (CCColor *)yellowColor;

+ (CCColor *)blueColor;

- (NSString *)hexValue;

- (CCColor *)complement;

- (CCColor *)blendedColorWithFraction:(float)fraction
                              ofColor:(CCColor *)color;

- (void)drawEyedropperSwatchInRect:(CGRect)rect;


@end
