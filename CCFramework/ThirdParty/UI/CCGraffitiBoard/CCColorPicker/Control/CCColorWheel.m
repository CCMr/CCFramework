//
//  CCColorWheel.m
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

#import "CCColorWheel.h"
#import "CCColor.h"
#import "CCColorIndicator.h"
#import "CCUtilities.h"
#import "UIView+BUIView.h"
#import "config.h"

#define wheelWidth 35

@interface CCColorWheel ()

@property(nonatomic, assign) CGImageRef wheelImage;
@property(nonatomic, strong) CCColorIndicator *indicator;
@property(nonatomic, assign) CGPoint value;

@end

@implementation CCColorWheel

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
    CGRect frame = [self frame];
    float width = CGRectGetWidth(frame);
    float height = CGRectGetHeight(frame);
    float diameter = MIN(width, height);
    _radius = floor(diameter / 2.0f);
    
    _indicator = [[CCColorIndicator alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    _indicator.sharpCenter = [self hueConstrainPoint:CGPointMake(0, 1)];
    _indicator.opaque = NO;
    _indicator.color = nil;
    [self addSubview:_indicator];
}

- (CGPoint)hueConstrainPoint:(CGPoint)pt
{
    CGPoint center = CCCenterOfRect([self bounds]);
    CGPoint delta = CCSubtractPoints(pt, center);
    
    delta = CCNormalizePoint(delta);
    delta = CCMultiplyPointScalar(delta, [self radius] - (wheelWidth / 2.0f + 1));
    
    return CCAddPoints(center, delta);
}

- (void)drawRect:(CGRect)rect
{
    CGRect bounds = CGRectInset(self.bounds, 1, 1);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
    CGContextAddEllipseInRect(ctx, bounds);
    CGContextAddEllipseInRect(ctx, CGRectInset(bounds, wheelWidth, wheelWidth));
    CGContextEOClip(ctx);
    CGContextDrawImage(ctx, self.bounds, CCResourceImage(@"color_wheel").CGImage);
    
    CGContextSetShadow(ctx, CGSizeMake(0, 4), 8);
    CGContextAddRect(ctx, CGRectInset(bounds, -20, -20));
    CGContextAddEllipseInRect(ctx, CGRectInset(bounds, -1, -1));
    CGContextAddEllipseInRect(ctx, CGRectInset(bounds, wheelWidth + 1, wheelWidth + 1));
    CGContextEOFillPath(ctx);
    
    CGContextRestoreGState(ctx);
    
    // stroke oval
    [[UIColor whiteColor] set];
    CGContextSetLineWidth(ctx, 1.5f);
    CGContextStrokeEllipseInRect(ctx, bounds);
    CGContextStrokeEllipseInRect(ctx, CGRectInset(bounds, wheelWidth, wheelWidth));
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch
                     withEvent:(UIEvent *)event
{
    CGPoint pt = [touch locationInView:self];
    CGPoint center = CCCenterOfRect([self bounds]);
    CGPoint delta = CCSubtractPoints(pt, center);
    float distance = CCDistance(delta, CGPointZero) / [self radius];
    
    if (distance >= 1.0f) {
        return NO;
    }
    
    _value = [self hueConstrainPoint:pt];
    _indicator.sharpCenter = _value;
    
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch
                        withEvent:(UIEvent *)event
{
    _value = [self hueConstrainPoint:[touch locationInView:self]];
    
    _indicator.sharpCenter = _value;
    
    return [super continueTrackingWithTouch:touch
                                  withEvent:event];
}

- (void)dealloc
{
    CGImageRelease(_wheelImage);
}

- (float)hue
{
    CGPoint center = CCCenterOfRect([self bounds]);
    
    CGPoint delta = CCSubtractPoints(_value, center);
    float angle = -atan2(delta.y, delta.x);
    if (angle < 0.0) {
        angle += 2 * M_PI;
    }
    
    angle *= (180.0 / M_PI);
    angle = fmod(angle, 360.0f);
    
    return (angle / 360.0f);
}

- (CCColor *)color
{
    return [CCColor colorWithHue:[self hue]
                      saturation:[self.Color saturation]
                      brightness:[self.Color brightness]
                           alpha:1.0f];
}

- (void)setColor:(CCColor *)Color
{
    CGPoint center = CCCenterOfRect([self bounds]);
    
    float hue = [Color hue];
    hue *= -(2 * M_PI);
    
    _Color = Color;
    
    _value.x = cos(hue) * [self radius];
    _value.y = sin(hue) * [self radius];
    _value = CCAddPoints(center, _value);
    _indicator.sharpCenter = [self hueConstrainPoint:_value];
}

@end

@implementation CCColorWheel (Private)

- (CGImageRef)cc_wheelImage
{
    if (!_wheelImage) {
        [self cc_buildWheelImage];
    }
    
    return _wheelImage;
}

- (void)cc_buildWheelImage
{
    int x, y;
    int radius = [self radius];
    CGPoint currentPt, center = CGPointMake(radius, radius);
    CGPoint delta;
    float angle;
    float r, g, b;
    int diameter = radius * 2;
    int bpr = diameter * 4;
    UInt8 *data, *ptr;
    
    ptr = data = calloc(1, sizeof(unsigned char) * diameter * bpr);
    
    for (y = 0; y < diameter; y++) {
        for (x = 0; x < diameter; x++) {
            // compute hue angle
            currentPt = CGPointMake(x, y);
            delta = CCSubtractPoints(currentPt, center);
            
            angle = atan2(delta.y, delta.x);
            if (angle < 0.0) {
                angle += 2 * M_PI;
            }
            angle /= (2.0f * M_PI);
            
            CCHSVtoRGB(angle, 1.0f, 1.0f, &r, &g, &b);
            
            ptr[x * 4] = 255;
            ptr[x * 4 + 1] = r * 255;
            ptr[x * 4 + 2] = g * 255;
            ptr[x * 4 + 3] = b * 255;
        }
        ptr += bpr;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(data, diameter, diameter, 8, bpr, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    
    _wheelImage = CGBitmapContextCreateImage(ctx);
    
    // clean up
    free(data);
    CGContextRelease(ctx);
}

@end
