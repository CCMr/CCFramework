//
//  CCRadarPointView.m
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

#import "CCRadarPointView.h"
#import "UIView+CCRemoteImage.h"

#define Radius 150
#define ImageRadius 20

@interface CCRadarPointView()

@property (nonatomic, strong) UIButton *avaterButton;

@end

@implementation CCRadarPointView

- (instancetype)init
{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    _avaterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _avaterButton.imageView.contentMode = UIViewContentModeScaleToFill;
    [_avaterButton addTarget:self action:@selector(didSelectItemAtIndex) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_avaterButton];
}

-(void)didSelectItemAtIndex
{
    if ([self.delegate respondsToSelector:@selector(didSeletcdRadarPointView:)])
        [self.delegate didSeletcdRadarPointView:self];
}

/**
 *  @author CC, 15-09-30
 *
 *  @brief  设置头像
 *
 *  @param avater 头像地址
 */
- (void)setAvater:(NSString *)avater
{
    _avater = avater;
    [self.avaterButton setImageWithURL:[NSURL URLWithString:avater] placeholer:[UIImage imageNamed:avater]];
}

-(void)setRadius:(CGFloat)radius
{
    _radius = radius;
    [self layoutSubviews];
}

-(void)setImageRadius:(CGFloat)imageRadius
{
    _imageRadius = imageRadius;
    [self layoutSubviews];
}

- (void)layoutSubviews
{
    _avaterButton.frame = self.bounds;

    CGFloat radius = Radius;
    if (self.radius)
        radius = self.radius;

    CGFloat imageRadius = ImageRadius;
    if (self.imageRadius)
        imageRadius = self.imageRadius;

    int radarradius = radius - imageRadius - 40; //雷达半径-头像半径-poing半径，表示在雷达中，头像外；
    int iamgeRadius = imageRadius + 20;
    int banban= ( arc4random() % radarradius ) + iamgeRadius;

    self.pointAngle = arc4random() % 360;
    self.pointRadius = banban;
}

@end
