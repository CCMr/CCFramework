//
//  CCColor.m
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

#import "CCColor.h"
#import "CCUtilities.h"

static NSString *kCCHueKey = @"h";
static NSString *kCCSaturationKey = @"s";
static NSString *kCCBrightnessKey = @"b";
static NSString *kCCAlphaKey = @"a";

@implementation CCColor

+ (CCColor *)randomColor
{
    float components[4];
    
    for (int i = 0; i < 4; i++) {
        components[i] = CCRandomFloat();
    }
    
    components[3] = 0.5 + (components[3] * 0.5);
    
    CCColor *color = [(CCColor *)[CCColor alloc] initWithHue:components[0]
                                                  saturation:components[1]
                                                  brightness:components[2]
                                                       alpha:components[3]];
    
    return color;
}

+ (CCColor *)colorWithWhite:(float)white
                      alpha:(CGFloat)alpha
{
    CCColor *color = [(CCColor *)[CCColor alloc] initWithHue:0
                                                  saturation:0
                                                  brightness:white
                                                       alpha:alpha];
    
    return color;
}

+ (CCColor *)colorWithRed:(float)red
                    green:(float)green
                     blue:(float)blue
                    alpha:(CGFloat)alpha
{
    float hue, saturation, brightness;
    
    CCRGBtoHSV(red, green, blue, &hue, &saturation, &brightness);
    
    CCColor *color = [(CCColor *)[CCColor alloc] initWithHue:hue
                                                  saturation:saturation
                                                  brightness:brightness
                                                       alpha:alpha];
    
    return color;
}

+ (CCColor *)colorWithHue:(CGFloat)hue
               saturation:(CGFloat)saturation
               brightness:(CGFloat)brightness
                    alpha:(CGFloat)alpha
{
    CCColor *color = [(CCColor *)[CCColor alloc] initWithHue:hue
                                                  saturation:saturation
                                                  brightness:brightness
                                                       alpha:alpha];
    
    return color;
}

- (CCColor *)initWithHue:(CGFloat)hue
              saturation:(CGFloat)saturation
              brightness:(CGFloat)brightness
                   alpha:(CGFloat)alpha
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    _hue = CCClamp(0.0f, 1.0f, hue);
    _saturation = CCClamp(0.0f, 1.0f, saturation);
    _brightness = CCClamp(0.0f, 1.0f, brightness);
    _alpha = CCClamp(0.0f, 1.0f, alpha);
    
    return self;
}

/*
 - (void)encodeWithWDCoder:(id<CCCoder>)coder deep:(BOOL)deep
 {
 [coder encodeFloat:_hue forKey:kCCHueKey];
 [coder encodeFloat:_saturation forKey:kCCSaturationKey];
 [coder encodeFloat:_brightness forKey:kCCBrightnessKey];
 [coder encodeFloat:_alpha forKey:kCCAlphaKey];
 }
 
 - (void)updateWithWDDecoder:(id<CCDecoder>)decoder deep:(BOOL)deep
 {
 _hue = CCClamp(0.0f, 1.0f, [decoder decodeFloatForKey:kCCHueKey]);
 _saturation = CCClamp(0.0f, 1.0f, [decoder decodeFloatForKey:kCCSaturationKey]);
 _brightness = CCClamp(0.0f, 1.0f, [decoder decodeFloatForKey:kCCBrightnessKey]);
 _alpha = CCClamp(0.0f, 1.0f, [decoder decodeFloatForKey:kCCAlphaKey]);
 }
 */

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: H: %f, S: %f, V:%f, A: %f", [super description], _hue, _saturation, _brightness, _alpha];
}

- (BOOL)isEqual:(CCColor *)color
{
    if (color == self) {
        return YES;
    }
    
    if (![color isKindOfClass:[CCColor class]]) {
        return NO;
    }
    
    return (_hue == color.hue &&
            _saturation == color.saturation &&
            _brightness == color.brightness &&
            _alpha == color.alpha);
}

- (NSUInteger)hash
{
    int h = 256.f * _hue;
    int s = 256.f * _saturation;
    int b = 256.f * _brightness;
    int a = 256.f * _alpha;
    return (h << 24) | (s << 16) | (b << 8) | (a);
}

+ (CCColor *)colorWithDictionary:(NSDictionary *)dict
{
    float hue = [dict[@"hue"] floatValue];
    float saturation = [dict[@"saturation"] floatValue];
    float brightness = [dict[@"brightness"] floatValue];
    float alpha = [dict[@"alpha"] floatValue];
    
    return [CCColor colorWithHue:hue
                      saturation:saturation
                      brightness:brightness
                           alpha:alpha];
}

- (NSDictionary *)dictionary
{
    NSNumber *hue = @(_hue);
    NSNumber *saturation = @(_saturation);
    NSNumber *brightness = @(_brightness);
    NSNumber *alpha = @(_alpha);
    
    return @{ @"hue" : hue,
              @"saturation" : saturation,
              @"brightness" : brightness,
              @"alpha" : alpha };
}

+ (CCColor *)colorWithData:(NSData *)data
{
    UInt16 *values = (UInt16 *)[data bytes];
    float components[4];
    
    for (int i = 0; i < 4; i++) {
        components[i] = CFSwapInt16LittleToHost(values[i]);
        components[i] /= USHRT_MAX;
    }
    
    return [CCColor colorWithHue:components[0]
                      saturation:components[1]
                      brightness:components[2]
                           alpha:components[3]];
}

+ (CCColor *)colorWithUIColor:(UIColor *)color
{
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    return [CCColor colorWithHue:components[0]
                      saturation:components[1]
                      brightness:components[2]
                           alpha:components[3]];
}

- (NSData *)colorData
{
    UInt16 data[4];
    
    data[0] = _hue * USHRT_MAX;
    data[1] = _saturation * USHRT_MAX;
    data[2] = _brightness * USHRT_MAX;
    data[3] = _alpha * USHRT_MAX;
    
    for (int i = 0; i < 4; i++) {
        data[i] = CFSwapInt16HostToLittle(data[i]);
    }
    
    return [NSData dataWithBytes:data length:8];
}

- (void)set
{
    [[self UIColor] set];
}

- (UIColor *)UIColor
{
    return [UIColor colorWithHue:_hue
                      saturation:_saturation
                      brightness:_brightness
                           alpha:_alpha];
}

- (UIColor *)opaqueUIColor
{
    return [UIColor colorWithHue:_hue
                      saturation:_saturation
                      brightness:_brightness
                           alpha:1.0];
}

- (CGColorRef)CGColor
{
    return [[self UIColor] CGColor];
}

- (CGColorRef)opaqueCGColor
{
    return [[self opaqueUIColor] CGColor];
}

- (CCColor *)colorWithAlphaComponent:(float)alpha
{
    return [CCColor colorWithHue:_hue
                      saturation:_saturation
                      brightness:_brightness
                           alpha:alpha];
}

- (CCColor *)adjustColor:(CCColor * (^)(CCColor *color))adjustment
{
    return adjustment(self);
}

- (float)red
{
    float r, g, b;
    
    CCHSVtoRGB(_hue, _saturation, _brightness, &r, &g, &b);
    
    return r;
}

- (float)green
{
    float r, g, b;
    
    CCHSVtoRGB(_hue, _saturation, _brightness, &r, &g, &b);
    
    return g;
}

- (float)blue
{
    float r, g, b;
    
    CCHSVtoRGB(_hue, _saturation, _brightness, &r, &g, &b);
    
    return b;
}

- (CCColor *)colorBalanceRed:(float)rShift
                       green:(float)gShift
                        blue:(float)bShift
{
    float r, g, b;
    float h, s, v;
    
    CCHSVtoRGB(_hue, _saturation, _brightness, &r, &g, &b);
    
    r = CCClamp(0, 1, r + rShift);
    g = CCClamp(0, 1, g + gShift);
    b = CCClamp(0, 1, b + bShift);
    
    CCRGBtoHSV(r, g, b, &h, &s, &v);
    return [CCColor colorWithHue:h
                      saturation:s
                      brightness:v
                           alpha:_alpha];
}

- (CCColor *)adjustHue:(float)hShift
            saturation:(float)sShift
            brightness:(float)bShift
{
    float h = _hue + hShift;
    BOOL negative = (h < 0);
    h = fmodf(fabs(h), 1.0f);
    if (negative) {
        h = 1.0f - h;
    }
    
    sShift = 1 + sShift;
    bShift = 1 + bShift;
    float s = CCClamp(0, 1, _saturation * sShift);
    float b = CCClamp(0, 1, _brightness * bShift);
    
    return [CCColor colorWithHue:h
                      saturation:s
                      brightness:b
                           alpha:_alpha];
}

- (CCColor *)inverted
{
    float r, g, b;
    
    CCHSVtoRGB(_hue, _saturation, _brightness, &r, &g, &b);
    
    return [CCColor colorWithRed:(1.0f - r)
                           green:(1.0f - g)
                            blue:(1.0f - b)
                           alpha:_alpha];
}

- (CCColor *)desaturated
{
    return [CCColor colorWithHue:_hue
                      saturation:0
                      brightness:_brightness
                           alpha:_alpha];
}

+ (CCColor *)blackColor
{
    return [CCColor colorWithHue:0.0f
                      saturation:0.0f
                      brightness:0.0f
                           alpha:1.0f];
}

+ (CCColor *)grayColor
{
    return [CCColor colorWithHue:0.0f
                      saturation:0.0f
                      brightness:0.25f
                           alpha:1.0f];
}

+ (CCColor *)whiteColor
{
    return [CCColor colorWithHue:0.0f
                      saturation:0.0f
                      brightness:1.0f
                           alpha:1.0f];
}

+ (CCColor *)cyanColor
{
    return [CCColor colorWithRed:0
                           green:1
                            blue:1
                           alpha:1];
}

+ (CCColor *)redColor
{
    return [CCColor colorWithRed:1
                           green:0
                            blue:0
                           alpha:1];
}

+ (CCColor *)magentaColor
{
    return [CCColor colorWithRed:1
                           green:0
                            blue:1
                           alpha:1];
}

+ (CCColor *)greenColor
{
    return [CCColor colorWithRed:0
                           green:1
                            blue:0
                           alpha:1];
}

+ (CCColor *)yellowColor
{
    return [CCColor colorWithRed:1
                           green:1
                            blue:0
                           alpha:1];
}

+ (CCColor *)blueColor
{
    return [CCColor colorWithRed:0
                           green:0
                            blue:1
                           alpha:1];
}

- (CCColor *)complement
{
    float r = 1.0 - self.red;
    float g = 1.0 - self.green;
    float b = 1.0 - self.blue;
    float a = self.alpha;
    
    return [CCColor colorWithRed:r green:g blue:b alpha:a];
}

- (CCColor *)blendedColorWithFraction:(float)blend ofColor:(CCColor *)color
{
    float inR, inG, inB;
    float selfR, selfG, selfB;
    
    CCHSVtoRGB(color.hue, color.saturation, color.brightness, &inR, &inG, &inB);
    CCHSVtoRGB(_hue, _saturation, _brightness, &selfR, &selfG, &selfB);
    
    float r = (blend * inR) + (1.0f - blend) * selfR;
    float g = (blend * inG) + (1.0f - blend) * selfG;
    float b = (blend * inB) + (1.0f - blend) * selfB;
    float a = (blend * color.alpha) + (1.0f - blend) * self.alpha;
    
    return [CCColor colorWithRed:r green:g blue:b alpha:a];
}

- (NSString *)hexValue
{
    float r, g, b;
    
    CCHSVtoRGB(_hue, _saturation, _brightness, &r, &g, &b);
    return [NSString stringWithFormat:@"#%.2x%.2x%.2x", (int)(r * 255 + 0.5f), (int)(g * 255 + 0.5f), (int)(b * 255 + 0.5f)];
}

- (void)drawSwatchInRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CCDrawTransparencyDiamondInRect(ctx, rect);
    
    [self set];
    CGContextFillRect(ctx, rect);
}

- (void)drawEyedropperSwatchInRect:(CGRect)rect
{
    [self drawSwatchInRect:rect];
}

- (BOOL)transformable
{
    return NO;
}

- (BOOL)canPaintStroke
{
    return YES;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

@end
