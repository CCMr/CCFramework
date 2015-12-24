//
//  CCToolButton.m
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

#import "CCToolButton.h"

#define kCornerRadius 6
#define kTopInset 2.0

@implementation CCToolButton

- (UIImage *)selectedImage
{
    CGRect rect = CGRectMake(0, 0, 30, 30);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
    
    // clip
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 1, kTopInset)
                                                    cornerRadius:kCornerRadius];
    [path addClip];
    
    [[UIColor colorWithRed:(32.0f / 255.0f)green:(105.0f / 255.0f)blue:(221.0f / 255.0f)alpha:0.05] set];
    //[[UIColor colorWithWhite:0.0f alpha:0.05f] set];
    CGContextFillRect(ctx, rect);
    
    // draw donut to create inner shadow
    [[UIColor blackColor] set];
    CGContextAddRect(ctx, CGRectInset(rect, -20, -20));
    path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:kCornerRadius];
    CGContextSetShadowWithColor(ctx, CGSizeZero, 7, [UIColor colorWithWhite:0.0 alpha:0.15].CGColor);
    path.usesEvenOddFillRule = YES;
    [path fill];
    
    CGContextRestoreGState(ctx);
    
    path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 0.5f, kTopInset - 0.5f) cornerRadius:kCornerRadius];
    [[UIColor colorWithWhite:1.0f alpha:1.0f] set];
    [path stroke];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (!self) {
        return nil;
    }
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    CALayer *layer = self.layer;
    layer.shadowRadius = 1;
    layer.shadowOpacity = 0.9f;
    layer.shadowOffset = CGSizeZero;
    layer.shouldRasterize = YES;
    layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    UIImage *bgImage = [[self selectedImage] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
    [self setBackgroundImage:bgImage forState:UIControlStateSelected];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeToolChanged:) name:@"CCActiveToolDidChange" object:nil];
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)activeToolChanged:(NSNotification *)aNotification
{
    self.selected = !self.selected;
}


@end
