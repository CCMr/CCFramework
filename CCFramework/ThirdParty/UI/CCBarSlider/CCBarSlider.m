//
//  CCBarSlider.m
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

#import "CCBarSlider.h"
#import "CCUtilities.h"

#define kCCOverlayDimension 200
#define kCCOverlayPointerHeight 25

@interface CCBarSlider ()

/**
 *  @author CC, 2015-12-17
 *  
 *  @brief  显示当前值控件
 */
@property(nonatomic, strong) UILabel *currentLabel;

@property(nonatomic, assign) float offset;

@property(nonatomic, assign) BOOL moved;

@end

@implementation CCBarSlider


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (!self) {
        return nil;
    }
    
    self.opaque = NO;
    self.backgroundColor = nil;
    self.contentMode = UIViewContentModeRedraw;
    
    self.thumbSize = 38;
    self.minimumValue = 1;
    self.maximumValue = 50;
    
    CALayer *layer = self.layer;
    layer.shadowRadius = 1;
    layer.shadowOpacity = 0.9f;
    layer.shadowOffset = CGSizeZero;
    
    [self addSubview:self.currentLabel];
    
    return self;
}

- (UILabel *)currentLabel
{
    if (!_currentLabel) {
        UILabel *currentLabel = [[UILabel alloc] initWithFrame:self.bounds];
        currentLabel.opaque = NO;
        currentLabel.backgroundColor = nil;
        currentLabel.font = [UIFont boldSystemFontOfSize:13];
        currentLabel.textAlignment = NSTextAlignmentCenter;
        currentLabel.textColor = [UIColor whiteColor];
        self.currentLabel = currentLabel;
    }
    return _currentLabel;
}

- (float)percentage
{
    float delta = (_maximumValue - _minimumValue);
    float v = (_currentValue - _minimumValue) * (8.0f / delta) + 1.0f;
    v = log(v);
    v /= 2.1972245773362196;
    
    return v;
}

- (void)computeValue:(CGPoint)pt
{
    CGRect trackRect = CGRectInset(self.bounds, 1, 12);
    float percentage;
    
    trackRect = CGRectInset(trackRect, self.thumbSize / 2, 0);
    percentage = (pt.x - CGRectGetMinX(trackRect)) / CGRectGetWidth(trackRect);
    percentage = CCClamp(0.0f, 1.0f, percentage);
    
    float delta = (_maximumValue - _minimumValue);
    self.currentValue = delta * (exp(2.1972245773362196 * percentage) - 1.0f) / 8.0f + _minimumValue;
    
    [self setNeedsDisplay];
}

- (CGRect)thumbRect
{
    CGRect trackRect = CGRectInset(self.bounds, 1, 12);
    float trackLength = CGRectGetWidth(trackRect) - self.thumbSize;
    float centerX = (self.thumbSize / 2) + (trackLength * [self percentage]);
    CGRect thumbRect = CGRectMake(centerX - (_thumbSize / 2) + 1, CGRectGetMinY(trackRect), self.thumbSize, CGRectGetHeight(trackRect));
    
    return thumbRect;
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *path = nil;
    BOOL isPhone = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ? YES : NO;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    float radius = CGRectGetHeight(self.bounds);
    float lineWidth = isPhone ? 2 : 1;
    
    [[UIColor whiteColor] set];
    CGRect trackRect = CGRectInset(self.bounds, 1, 12);
    trackRect = isPhone ? CGRectInset(trackRect, 1, 5) : CGRectInset(trackRect, 0.5, 4.5);
    
    if (!isPhone) {
        [[UIColor colorWithWhite:1.0 alpha:0.1] set];
        
        CGRect leftRect = trackRect;
        leftRect.size.width = 15;
        path = [UIBezierPath bezierPathWithRoundedRect:leftRect cornerRadius:radius];
        [path fill];
        
        CGRect rightRect = trackRect;
        rightRect.origin.x = CGRectGetMaxX(trackRect) - 15;
        rightRect.size.width = 15;
        path = [UIBezierPath bezierPathWithRoundedRect:rightRect cornerRadius:radius];
        [path fill];
        
        [[UIColor whiteColor] set];
        
        // draw a minus inside the track bounds
        path = [UIBezierPath bezierPath];
        path.lineWidth = 2;
        float y = CGRectGetMidY(trackRect);
        [path moveToPoint:CGPointMake(6, y)];
        [path addLineToPoint:CGPointMake(12, y)];
        [path stroke];
        
        // draw a plus inside the track bounds
        path = [UIBezierPath bezierPath];
        path.lineWidth = 2;
        float x = CGRectGetMaxX(self.bounds) - 6;
        [path moveToPoint:CGPointMake(x, y)];
        [path addLineToPoint:CGPointMake(x - 6, y)];
        [path moveToPoint:CGPointMake(x - 3, y - 3)];
        [path addLineToPoint:CGPointMake(x - 3, y + 3)];
        [path stroke];
    }
    
    path = [UIBezierPath bezierPathWithRoundedRect:trackRect cornerRadius:radius];
    path.lineWidth = lineWidth;
    [path stroke];
    
    CGRect thumbRect = [self thumbRect];
    
    // knockout a hole
    path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(thumbRect, -2, -2) cornerRadius:radius];
    CGContextSetBlendMode(ctx, kCGBlendModeClear);
    [path fill];
    
    thumbRect = isPhone ? CGRectInset(thumbRect, 1, 1) : CGRectInset(thumbRect, 0.5, 0.5);
    path = [UIBezierPath bezierPathWithRoundedRect:thumbRect cornerRadius:radius];
    CGContextSetBlendMode(ctx, kCGBlendModeNormal);
    path.lineWidth = lineWidth;
    [[UIColor colorWithWhite:1.0 alpha:0.1] set];
    [path fill];
    [[UIColor whiteColor] set];
    [path stroke];
    
    self.currentLabel.frame = [self thumbRect];
}

- (void)setCurrentValue:(float)currentValue
{
    _currentValue = CCClamp(_minimumValue, _maximumValue, currentValue);
    
    self.currentLabel.text = [@((int)_currentValue) stringValue];
    self.currentLabel.frame = [self thumbRect];
    
    [self setNeedsDisplay];
}

- (CGRect)overlayFrame
{
    float pointerHeight = _parentViewForOverlay ? 0 : kCCOverlayPointerHeight;
    
    return CGRectMake(0, 0, kCCOverlayDimension, kCCOverlayDimension + pointerHeight);
}

- (void)showOverlayAtPoint:(CGPoint)pt
{
    //    if (!self.overlay) {
    //        CCBrushSizeOverlay *view = [[CCBrushSizeOverlay alloc] initWithFrame:[self overlayFrame]];
    //
    //        if (parentViewForOverlay) {
    //            view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    //            UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    //
    //            [parentViewForOverlay addSubview:view];
    //            view.sharpCenter = WDCenterOfRect(parentViewForOverlay.bounds);
    //        } else {
    //            [self addSubview:view];
    //        }
    //
    //        self.overlay = view;
    //        [overlay setPreviewImage:[WDActiveState sharedInstance].brush.generator.bigPreview];
    //    }
    //
    //    if (!parentViewForOverlay) {
    //        overlay.sharpCenter = CGPointMake(pt.x, CGRectGetMinY(self.bounds) - (kWDOverlayDimension + kWDOverlayPointerHeight) / 2.0f + 8);
    //    }
    //
    //    [overlay setValue:self.value];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch
                     withEvent:(UIEvent *)event
{
    CGPoint pt = [touch locationInView:self];
    _offset = pt.x - CGRectGetMidX([self thumbRect]);
    
    _moved = NO;
    
    return [super beginTrackingWithTouch:touch withEvent:event];
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch
                        withEvent:(UIEvent *)event
{
    CGPoint pt = [touch locationInView:self];
    
    if (!_moved) {
        _offset = pt.x - CGRectGetMidX([self thumbRect]);
        _moved = YES;
    }
    
    pt.x -= _offset;
    [self computeValue:pt];
    
    [self showOverlayAtPoint:CCCenterOfRect([self thumbRect])];
    
    return [super continueTrackingWithTouch:touch withEvent:event];
}

- (void)endTrackingWithTouch:(UITouch *)touch
                   withEvent:(UIEvent *)event
{
    if (!_moved) {
        self.currentValue = (_offset > 0) ? (_currentValue + 1) : (_currentValue - 1);
    }
    
    //    [self.overlay removeFromSuperview];
    //    self.overlay = nil;
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    //    [self.overlay removeFromSuperview];
    //    self.overlay = nil;
}


@end
