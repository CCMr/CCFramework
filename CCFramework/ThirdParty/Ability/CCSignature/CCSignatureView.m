//
//  CCSignatureView.m
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

#import "CCSignatureView.h"

#define INITIAL_COLOR [UIColor blackColor]; // Initial color for line  drawing.
#define FINAL_COLOR [UIColor blackColor];// End color after completd drawing
#define INITIAL_LABEL_TEXT @"Sign Here";

@interface CCSignatureView()

@property (nonatomic, strong) UILabel *lblSignature;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) UIBezierPath *beizerPath;
@property (nonatomic, strong) UIImage *incrImage;
@end

@implementation CCSignatureView
{
    CGPoint points[5];
    uint control;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        float lblHeight = 61;
        self.backgroundColor = [UIColor whiteColor];
        [self setMultipleTouchEnabled:NO];
        _beizerPath = [UIBezierPath bezierPath];
        [_beizerPath setLineWidth:2.0];
        _lblSignature = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height / 2 - lblHeight / 2, self.frame.size.width, lblHeight)];
        _lblSignature.font = [UIFont fontWithName:@"HelveticaNeue" size:51];
        _lblSignature.text = INITIAL_LABEL_TEXT;
        _lblSignature.textColor = [UIColor lightGrayColor];
        _lblSignature.textAlignment = NSTextAlignmentCenter;
        _lblSignature.alpha = 0.3;
        [self addSubview:_lblSignature];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [_incrImage drawInRect:rect];
    [_beizerPath stroke];

    // Set initial color for drawing

    UIColor *fillColor = INITIAL_COLOR;
    [fillColor setFill];
    UIColor *strokeColor = INITIAL_COLOR;
    [strokeColor setStroke];
    [_beizerPath stroke];
}

#pragma mark - UIView Touch Methods

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    if ([_lblSignature superview]){
        [_lblSignature removeFromSuperview];
    }
    control = 0;
    UITouch *touch = [touches anyObject];
    points[0] = [touch locationInView:self];

    CGPoint startPoint = points[0];
    CGPoint endPoint = CGPointMake(startPoint.x + 1.5, startPoint.y
                                   + 2);

    [_beizerPath moveToPoint:startPoint];
    [_beizerPath addLineToPoint:endPoint];

}

- (void)touchesMoved:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    control++;
    points[control] = touchPoint;

    if (control == 4)
    {
        points[3] = CGPointMake((points[2].x + points[4].x)/2.0, (points[2].y + points[4].y)/2.0);

        [_beizerPath moveToPoint:points[0]];
        [_beizerPath addCurveToPoint:points[3] controlPoint1:points[1] controlPoint2:points[2]];

        [self setNeedsDisplay];

        points[0] = points[3];
        points[1] = points[4];
        control = 1;
    }

}

- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    [self drawBitmapImage];
    [self setNeedsDisplay];
    [_beizerPath removeAllPoints];
    control = 0;
}

- (void)touchesCancelled:(NSSet *)touches
               withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

#pragma mark - Bitmap Image Creation

- (void)drawBitmapImage
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);

    if (!_incrImage)
    {
        UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds];
        [[UIColor whiteColor] setFill];
        [rectpath fill];
    }
    [_incrImage drawAtPoint:CGPointZero];

    //Set final color for drawing
    UIColor *strokeColor = FINAL_COLOR;
    [strokeColor setStroke];
    [_beizerPath stroke];
    _incrImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

/**
 *  @author CC, 15-09-01
 *
 *  @brief  清除当前签名
 *
 *  @since 1.0
 */
- (void)clearSignature
{
    _incrImage = nil;
    [self setNeedsDisplay];
}

#pragma mark - Signature image from given path

/**
 *  @author CC, 15-09-01
 *
 *  @brief  签名图片
 *
 *  @return 返回当前签名图片
 *
 *  @since 1.0
 */
- (UIImage *)signatureImage {

    if([_lblSignature superview])
        return nil;

    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);

    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];

    UIImage *signatureImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return signatureImage;
}

@end
