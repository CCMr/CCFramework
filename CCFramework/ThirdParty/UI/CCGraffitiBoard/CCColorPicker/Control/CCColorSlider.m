//
//  CCColorSlider.m
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

#import "CCColorSlider.h"
#import "CCUtilities.h"
#import "CCColorIndicator.h"
#import "CCColor.h"
#import "UIView+Frame.h"

#define kCornerRadius 10
#define kIndicatorInset 10

@interface CCColorSlider ()

@property(nonatomic, assign) CGImageRef hueImage;
@property(nonatomic, assign) CGShadingRef shadingRef;

@end

@interface CCColorSlider (Private)

- (CGImageRef)cc_hueImage;

- (void)cc_buildHueImage;

- (void)positionIndicator_;

@end

static void evaluateShading(void *info, const CGFloat *in, CGFloat *out)
{
    CCColorSlider *slider = (__bridge CCColorSlider *)info;
    CCColor *color = slider.color;
    CGFloat blend = in[0];
    float hue, saturation, brightness;
    float r1 = 0, g1 = 0, b1 = 0;
    float r2 = 0, g2 = 0, b2 = 0;
    float r = 0, g = 0, b = 0;
    BOOL blendRGB = YES;
    
    hue = color.hue;
    saturation = color.saturation;
    brightness = color.brightness;
    
    if (slider.mode == CCColorSliderModeAlpha) {
        CCHSVtoRGB(color.hue, color.saturation, color.brightness, &r, &g, &b);
        blendRGB = NO;
    } else if (slider.mode == CCColorSliderModeBrightness) {
        CCHSVtoRGB(hue, saturation, 0.0, &r1, &g1, &b1);
        CCHSVtoRGB(hue, saturation, 1.0, &r2, &g2, &b2);
    } else if (slider.mode == CCColorSliderModeSaturation) {
        CCHSVtoRGB(hue, 0.0, brightness, &r1, &g1, &b1);
        CCHSVtoRGB(hue, 1.0, brightness, &r2, &g2, &b2);
    } else if (slider.mode == CCColorSliderModeRed) {
        r1 = 0;
        r2 = 1;
        g1 = g2 = color.green;
        b1 = b2 = color.blue;
    } else if (slider.mode == CCColorSliderModeGreen) {
        r1 = r2 = color.red;
        g1 = 0;
        g2 = 1;
        b1 = b2 = color.blue;
    } else if (slider.mode == CCColorSliderModeBlue) {
        r1 = r2 = color.red;
        g1 = g2 = color.green;
        b1 = 0;
        b2 = 1;
    } else if (slider.mode == CCColorSliderModeRedBalance) {
        r1 = 0;
        r2 = 1;
        g1 = 1;
        g2 = 0;
        b1 = 1;
        b2 = 0;
    } else if (slider.mode == CCColorSliderModeGreenBalance) {
        r1 = 1;
        r2 = 0;
        g1 = 0;
        g2 = 1;
        b1 = 1;
        b2 = 0;
    } else if (slider.mode == CCColorSliderModeBlueBalance) {
        r1 = 1;
        r2 = 0;
        g1 = 1;
        g2 = 0;
        b1 = 0;
        b2 = 1;
    }
    
    if (blendRGB) {
        r = (blend * r2) + (1.0f - blend) * r1;
        g = (blend * g2) + (1.0f - blend) * g1;
        b = (blend * b2) + (1.0f - blend) * b1;
    }
    
    out[0] = r;
    out[1] = g;
    out[2] = b;
    out[3] = (slider.mode == CCColorSliderModeAlpha ? in[0] : 1.0f);
}

static void release(void *info)
{
}

@implementation CCColorSlider

- (instancetype)init
{
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _indicator = [CCColorIndicator colorIndicator];
    _indicator.sharpCenter = CCCenterOfRect([self bounds]);
    [self addSubview:_indicator];
    
    self.opaque = NO;
    self.backgroundColor = nil;
    self.clearsContextBeforeDrawing = YES;
    self.contentMode = UIViewContentModeRedraw;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect bounds = CGRectInset(self.bounds, -10, -10);
    return CGRectContainsPoint(bounds, point);
}

- (void)dealloc
{
    if (self.hueImage)
        CGImageRelease(self.hueImage);
    
    
    if (self.shadingRef)
        CGShadingRelease(self.shadingRef);
}

- (CGShadingRef)newShadingRef
{
    CGShadingRef gradient;
    CGFloat domain[] = {0.0f, 1.0f};
    CGFloat range[] = {0.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f};
    CGFunctionCallbacks callbacks;
    
    callbacks.version = 0;
    callbacks.evaluate = evaluateShading;
    callbacks.releaseInfo = release;
    
    CGPoint start = CGPointMake(0.0, 10.0f);
    CGPoint end = CGPointMake(CGRectGetWidth(self.bounds), 10.0f);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGFunctionRef gradientFunction = CGFunctionCreate((__bridge void *)(self), 1, domain, 4, range, &callbacks);
    
    if (self.reversed) {
        gradient = CGShadingCreateAxial(colorspace, end, start, gradientFunction, NO, NO);
    } else {
        gradient = CGShadingCreateAxial(colorspace, start, end, gradientFunction, NO, NO);
    }
    
    CGFunctionRelease(gradientFunction);
    CGColorSpaceRelease(colorspace);
    
    return gradient;
}

- (void)setFrame:(CGRect)frame
{
    BOOL sizeChanged = !CGSizeEqualToSize(frame.size, self.frame.size);
    
    [super setFrame:frame];
    
    if (sizeChanged) {
        CGShadingRelease(self.shadingRef);
        self.shadingRef = nil;
    }
    
    [self positionIndicator_];
}

- (CGShadingRef)shadingRef
{
    if (!_shadingRef) {
        _shadingRef = [self newShadingRef];
    }
    return _shadingRef;
}

- (BOOL)colorChanged:(CCColor *)color
{
    if (!color) {
        return YES;
    }
    
    BOOL hueChanged = color.hue != _color.hue;
    BOOL satChanged = color.saturation != _color.saturation;
    BOOL brightnessChanged = color.brightness != _color.brightness;
    
    switch (_mode) {
        case CCColorSliderModeBrightness:
            return (hueChanged || satChanged);
            break;
        case CCColorSliderModeSaturation:
            return (hueChanged || brightnessChanged);
            break;
        default:
            return (hueChanged || brightnessChanged || satChanged);
            break;
    }
    
    return NO;
}

- (void)setColor:(CCColor *)color
{
    switch (_mode) {
        case CCColorSliderModeAlpha:
            _floatValue = [color alpha];
            break;
        case CCColorSliderModeHue:
            _floatValue = [color hue];
            break;
        case CCColorSliderModeBrightness:
            _floatValue = [color brightness];
            break;
        case CCColorSliderModeSaturation:
            _floatValue = [color saturation];
            break;
        case CCColorSliderModeRed:
        case CCColorSliderModeRedBalance:
            _floatValue = [color red];
            break;
        case CCColorSliderModeGreen:
        case CCColorSliderModeGreenBalance:
            _floatValue = [color green];
            break;
        case CCColorSliderModeBlue:
        case CCColorSliderModeBlueBalance:
            _floatValue = [color blue];
            break;
        default:
            break;
    }
    
    if ([self colorChanged:color]) {
        if (_mode != CCColorSliderModeHue && _shadingRef) {
            CGShadingRelease(_shadingRef);
            _shadingRef = NULL;
        }
        
        [self setNeedsDisplay];
    }
    
    _color = color;
    
    [self positionIndicator_];
    
    if (self.reversed) {
        [_indicator setColor:[color colorWithAlphaComponent:(1.0f - color.alpha)]];
    } else {
        if (_mode == CCColorSliderModeHue) {
            color = [CCColor colorWithHue:color.hue
                               saturation:1
                               brightness:1
                                    alpha:1];
        }
        
        [_indicator setColor:color];
    }
}

- (void)setMode:(CCColorSliderMode)mode
{
    _mode = mode;
    _indicator.alphaMode = (mode == CCColorSliderModeAlpha);
    
    if (_mode != CCColorSliderModeHue && _shadingRef) {
        CGShadingRelease(_shadingRef);
        _shadingRef = NULL;
    }
    
    [self setNeedsDisplay];
}

- (void)setReversed:(BOOL)reversed
{
    _reversed = reversed;
    [self setNeedsDisplay];
}

- (UIImage *)borderImage
{
    static UIImage *borderImage = nil;
    
    if (borderImage && !CGSizeEqualToSize(borderImage.size, self.bounds.size)) {
        borderImage = nil;
    }
    
    if (!borderImage) {
        borderImage = [UIImage imageNamed:@"slider_border"];
        borderImage = [borderImage stretchableImageWithLeftCapWidth:16 topCapHeight:0];
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0f);
        [borderImage drawInRect:[self bounds]];
        borderImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return borderImage;
}

- (void)drawRect:(CGRect)clip
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect bounds = [self bounds];
    
    CGContextSaveGState(ctx);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:8];
    [path addClip];
    
    if (_mode == CCColorSliderModeAlpha) {
        CCDrawCheckersInRect(ctx, bounds, 8);
    }
    
    if (_mode == CCColorSliderModeHue) {
        CGContextDrawImage(ctx, self.bounds, [self cc_hueImage]);
    } else {
        CGContextDrawShading(ctx, [self shadingRef]);
    }
    
    CGContextRestoreGState(ctx);
    
    [[self borderImage] drawInRect:bounds blendMode:kCGBlendModeMultiply alpha:0.5f];
}

- (float)indicatorCenterX_
{
    CGRect trackRect = CGRectInset(self.bounds, kIndicatorInset, 0);
    
    return roundf(_floatValue * CGRectGetWidth(trackRect) + CGRectGetMinX(trackRect));
}

- (void)computeValue_:(CGPoint)pt
{
    CGRect trackRect = CGRectInset(self.bounds, kIndicatorInset, 0);
    float percentage;
    
    percentage = (pt.x - CGRectGetMinX(trackRect)) / CGRectGetWidth(trackRect);
    percentage = CCClamp(0.0f, 1.0f, percentage);
    
    _floatValue = percentage;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint pt = [touch locationInView:self];
    
    [self computeValue_:pt];
    [self positionIndicator_];
    
    return [super beginTrackingWithTouch:touch withEvent:event];
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint pt = [touch locationInView:self];
    
    [self computeValue_:pt];
    [self positionIndicator_];
    
    return [super continueTrackingWithTouch:touch withEvent:event];
}

@end

@implementation CCColorSlider (Private)

- (CGImageRef)cc_hueImage
{
    if (!_hueImage) {
        [self cc_buildHueImage];
    }
    
    return _hueImage;
}

- (void)cc_buildHueImage
{
    int x, y;
    float r, g, b;
    int width = CGRectGetWidth(self.bounds);
    int height = CGRectGetHeight(self.bounds);
    int bpr = width * 4;
    UInt8 *data, *ptr;
    
    ptr = data = calloc(1, sizeof(unsigned char) * height * bpr);
    
    for (x = 0; x < width; x++) {
        float angle = ((float)x) / width;
        CCHSVtoRGB(angle, 1.0f, 1.0f, &r, &g, &b);
        
        for (y = 0; y < height; y++) {
            ptr[y * bpr + x * 4] = 255;
            ptr[y * bpr + x * 4 + 1] = r * 255;
            ptr[y * bpr + x * 4 + 2] = g * 255;
            ptr[y * bpr + x * 4 + 3] = b * 255;
        }
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(data, width, height, 8, bpr, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    
    _hueImage = CGBitmapContextCreateImage(ctx);
    
    // clean up
    free(data);
    CGContextRelease(ctx);
}

- (void)positionIndicator_
{
    _indicator.sharpCenter = CGPointMake([self indicatorCenterX_], _indicator.center.y);
}

@end
