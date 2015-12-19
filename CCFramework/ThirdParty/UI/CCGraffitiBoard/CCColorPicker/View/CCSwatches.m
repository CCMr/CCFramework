//
//  CCSwatches.m
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

#import "CCSwatches.h"
#import "CCColor.h"
#import "CCUtilities.h"

const float kSwatchCornerRadius = 5.0f;
const float kSwatchSize = 45.0f;

@implementation CCSwatches

- (void)buildInsetShadowView
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0f);
    
    CGRect swatchRect = CGRectMake(0, 0, kSwatchSize, kSwatchSize);
    NSInteger swatchesPerRow = [self swatchesPerRow];
    NSInteger numRows = [self numRows];
    
    // build the shadow image once
    UIGraphicsBeginImageContextWithOptions(swatchRect.size, NO, 0.0f);
    [self insetCircleInRect:CGRectInset(swatchRect, 3, 3)];
    
    // white border
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(swatchRect, 2.5f, 2.5f)
                                                    cornerRadius:kSwatchCornerRadius];
    [[UIColor whiteColor] set];
    path.lineWidth = 1.0f;
    [path stroke];
    
    UIImage *shadow = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // now stamp the shadow image for each swatch
    for (int y = 0; y < numRows; y++) {
        swatchRect.origin.y = y * kSwatchSize;
        for (int x = 0; x < swatchesPerRow; x++) {
            swatchRect.origin.x = x * kSwatchSize;
            [shadow drawInRect:swatchRect];
        }
    }
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    _shadowOverlay = [[UIImageView alloc] initWithImage:result];
    [self addSubview:_shadowOverlay];
}

- (void)setFrame:(CGRect)frame
{
    BOOL sizeChanged = !CGSizeEqualToSize(frame.size, self.frame.size);
    
    [super setFrame:frame];
    
    if (sizeChanged || !self.shadowOverlay) {
        [_shadowOverlay removeFromSuperview];
        _shadowOverlay = nil;
        
        [self buildInsetShadowView];
    }
}

- (void)awakeFromNib
{
    _highlightIndex = -1;
    _initialIndex = -1;
    
    self.opaque = NO;
    self.backgroundColor = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (!self) {
        return nil;
    }
    
    [self awakeFromNib];
    
    return self;
}

- (void)insetCircleInRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:kSwatchCornerRadius];
    [path addClip];
    
    CGContextSetShadow(ctx, CGSizeMake(0, 2), 8);
    CGContextAddRect(ctx, CGRectInset(rect, -8, -8));
    
    path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, -1, -1) cornerRadius:kSwatchCornerRadius];
    path.usesEvenOddFillRule = YES;
    [path fill];
    CGContextRestoreGState(ctx);
}

- (void)drawSwatchInRect:(CGRect)rect color:(CCColor *)color
{
    if (!color) {
        UIImage *image = [UIImage imageNamed:@"swatch_add.png"];
        CGPoint corner = rect.origin;
        corner.x += ceilf((CGRectGetWidth(rect) - image.size.width) / 2.0f);
        corner.y += ceilf((CGRectGetHeight(rect) - image.size.height) / 2.0f);
        [image drawAtPoint:corner blendMode:kCGBlendModeNormal alpha:0.2f];
    } else {
        [color set];
        
        CGRect colorRect = CGRectInset(rect, 3, 3);
        
        if (color.alpha < 1.0) {
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:colorRect cornerRadius:kSwatchCornerRadius];
            
            CGContextSaveGState(ctx);
            [path addClip];
            CCDrawTransparencyDiamondInRect(ctx, rect);
            CGContextRestoreGState(ctx);
        }
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:colorRect cornerRadius:kSwatchCornerRadius];
        [path fill];
    }
}

- (NSInteger)swatchesPerRow
{
    return CGRectGetWidth(self.bounds) / kSwatchSize;
}

- (NSInteger)numRows
{
    return CGRectGetHeight(self.bounds) / kSwatchSize;
}

- (void)drawRect:(CGRect)rect
{
    CGRect swatch = CGRectMake(0, 0, kSwatchSize, kSwatchSize);
    NSUInteger index = 0;
    CCColor *swatchColor;
    NSUInteger swatchesPerRow = [self swatchesPerRow];
    NSUInteger numRows = [self numRows];
    
    for (int y = 0; y < numRows; y++) {
        swatch.origin.y = y * kSwatchSize;
        
        for (int x = 0; x < swatchesPerRow; x++) {
            swatch.origin.x = x * kSwatchSize;
            
            if (CGRectIntersectsRect(swatch, rect)) {
//                swatchColor = [[CCActiveState sharedInstance] swatchAtIndex:index];
                
                if (index == _initialIndex) {
                    swatchColor = nil;
                }
                
                if (index == _highlightIndex) {
                    swatchColor = _highlightColor;
                }
                
                [self drawSwatchInRect:swatch color:swatchColor];
            }
            
            index++;
        }
    }
}

- (CGRect)rectForSwatchIndex:(NSInteger)index
{
    NSUInteger x = index % [self swatchesPerRow];
    NSUInteger y = index / [self swatchesPerRow];
    
    return CGRectMake(x * kSwatchSize, y * kSwatchSize, kSwatchSize, kSwatchSize);
}

- (void)setHighlightIndex:(NSInteger)index
{
    if (index == _highlightIndex) {
        return;
    }
    
    [self setNeedsDisplayInRect:[self rectForSwatchIndex:_highlightIndex]];
    _highlightIndex = index;
    [self setNeedsDisplayInRect:[self rectForSwatchIndex:_highlightIndex]];
}

- (void)dragMoved:(UITouch *)touch colorChip:(CCDragChip *)chip
      colorSource:(id)colorSource
{
    CGPoint pt = [touch locationInView:self];
    
    if (!CGRectContainsPoint(self.bounds, pt)) {
        self.highlightIndex = -1;
        self.highlightColor = nil;
    } else {
        self.highlightIndex = [self indexAtPoint:pt];
        self.highlightColor = chip.color;
    }
    
    [self setNeedsDisplayInRect:[self rectForSwatchIndex:_highlightIndex]];
}

- (void)dragExited
{
    [self setNeedsDisplayInRect:[self rectForSwatchIndex:_highlightIndex]];
    self.highlightIndex = -1;
    self.highlightColor = nil;
}

- (void)dragEnded
{
    [self setNeedsDisplayInRect:[self rectForSwatchIndex:_initialIndex]];
    _initialIndex = -1;
}

- (BOOL)dragEnded:(UITouch *)touch
        colorChip:(CCDragChip *)chip
      colorSource:(id)colorSource
      destination:(CGPoint *)flyLoc
{
    CGPoint pt = [touch locationInView:self];
    
    self.highlightIndex = -1;
    self.highlightColor = nil;
    
    if (!CGRectContainsPoint(self.bounds, pt)) {
        return NO;
    }
    
    if (_initialIndex >= 0) {
//        [[CCActiveState sharedInstance] setSwatch:nil
//                                          atIndex:_initialIndex];
        
        [self setNeedsDisplayInRect:[self rectForSwatchIndex:_initialIndex]];
    }
    
    NSInteger index = [self indexAtPoint:pt];
    
    *flyLoc = [self convertPoint:CCCenterOfRect([self rectForSwatchIndex:index]) toView:chip.superview];
    
//    [[CCActiveState sharedInstance] setSwatch:[chip color]
//                                      atIndex:index];
    
    [self setNeedsDisplayInRect:[self rectForSwatchIndex:index]];
    
    return YES;
}

- (CCColor *)color
{
    return self.tappedColor;
}

- (NSInteger)indexAtPoint:(CGPoint)pt
{
    NSInteger x = ((int)pt.x) / kSwatchSize, y = ((int)pt.y) / kSwatchSize;
    return (y * [self swatchesPerRow] + x);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    _initialIndex = [self indexAtPoint:[touch locationInView:self]];
//    self.tappedColor = [[CCActiveState sharedInstance] swatchAtIndex:_initialIndex];
    
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setNeedsDisplayInRect:[self rectForSwatchIndex:_initialIndex]];
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.moved) {
        [super touchesEnded:touches withEvent:event];
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self];
    
    if (!CGRectContainsPoint(self.bounds, pt)) {
        return;
    }
    
//    NSInteger index = [self indexAtPoint:pt];
//    CCColor *color = [[CCActiveState sharedInstance] swatchAtIndex:index];
//    
//    if (touch.tapCount == 2) {
//        [_delegate doubleTapped:self];
//    } else if (color) {
//        [_delegate setColor:color];
//    } else {
//        [[CCActiveState sharedInstance] setSwatch:[CCActiveState sharedInstance].paintColor
//                                          atIndex:index];
//        
//        [self setNeedsDisplayInRect:[self rectForSwatchIndex:index]];
//    }
//    
//    _initialIndex = -1;
}

@end
