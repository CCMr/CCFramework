//
//  CCPageIndicatorView.m
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

#import "CCPageIndicatorView.h"


@implementation CCPageIndicatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       [self setUp];
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    _indicatorType = CCPageIndicatorViewTypeInvertedTriangle;
    self.opaque = NO;
    _color = [UIColor blackColor];
}

#pragma mark - Public

- (void)setColor:(UIColor *)color
{
    if (![_color isEqual:color]) {
        _color = color;
        [self setNeedsDisplay];
    }
}

-(void)setIndicatorType: (CCPageIndicatorViewType)indicatorType
{
    _indicatorType = indicatorType;
}

#pragma mark - Private

- (void)drawRect:(CGRect)rect
{
    switch (_indicatorType) {
        case CCPageIndicatorViewTypeInvertedTriangle:
        {
            CGContextRef context = UIGraphicsGetCurrentContext();

            CGContextClearRect(context, rect);

            CGContextBeginPath(context);
            CGContextMoveToPoint   (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
            CGContextAddLineToPoint(context, CGRectGetMidX(rect), CGRectGetMaxY(rect));
            CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));
            CGContextClosePath(context);

            CGContextSetFillColorWithColor(context, self.color.CGColor);
            CGContextFillPath(context);
        }
            break;

        default:
            break;
    }

}


@end