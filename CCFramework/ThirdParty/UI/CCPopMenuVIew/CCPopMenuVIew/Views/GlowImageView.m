//
//  GlowImageView.m
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

#import "GlowImageView.h"

@implementation GlowImageView

/**
 *  设置阴影的颜色
 */
- (void)setGlowColor:(UIColor *)newGlowColor
{
    _glowColor = newGlowColor;
    if (newGlowColor) {
        [self setUpProperty];
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

/**
 *   根据阴影 设置图层 默认属性
 */
- (void)setUpProperty
{
    self.layer.shadowColor = self.glowColor.CGColor;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-5, -5, CGRectGetWidth(self.bounds) + 10, CGRectGetHeight(self.bounds) + 10) cornerRadius:(CGRectGetHeight(self.bounds) + 10) / 2.0].CGPath;
    self.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.layer.shadowOpacity = 0.5;
    self.layer.masksToBounds = NO;
}

@end
