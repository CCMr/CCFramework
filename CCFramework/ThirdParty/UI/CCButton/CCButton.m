//
//  CCButton.m
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

#import "CCButton.h"
#import "UIView+Frame.h"

/**
 *  定义宏：按钮中文本和图片的间隔
 */
#define cc_padding 7
#define cc_btnRadio 0.6
//    获得按钮的大小
#define cc_btnWidth self.width
#define cc_btnHeight self.height
//    获得按钮中UILabel文本的大小
#define cc_labelWidth self.titleLabel.width
#define cc_labelHeight self.titleLabel.height
//    获得按钮中image图标的大小
#define cc_imageWidth self.imageView.width
#define cc_imageHeight self.imageView.height
//图标在上，文本在下按钮的图文间隔比例（0-1），默认0.8
#define cc_buttonTopRadio 0.8
//图标在下，文本在上按钮的图文间隔比例（0-1），默认0.5
#define cc_buttonBottomRadio 0.5


@implementation CCButton

+ (instancetype)cc_shareButton
{
    return [[self alloc] init];
}

- (instancetype)initWithAlignmentStatus:(CCAlignmentStatus)status
{
    CCButton *cc_button = [[CCButton alloc] init];
    cc_button.status = status;
    return cc_button;
}

- (void)setStatus:(CCAlignmentStatus)status
{
    _status = status;
}

#pragma mark - 左对齐
- (void)alignmentLeft
{
    //    获得按钮的文本的frame
    CGRect titleFrame = self.titleLabel.frame;
    //    设置按钮的文本的x坐标为0-－－左对齐
    titleFrame.origin.x = 0;
    //    获得按钮的图片的frame
    CGRect imageFrame = self.imageView.frame;
    //    设置按钮的图片的x坐标紧跟文本的后面
    imageFrame.origin.x = CGRectGetWidth(titleFrame);
    //    重写赋值frame
    self.titleLabel.frame = titleFrame;
    self.imageView.frame = imageFrame;
}
#pragma mark - 右对齐
- (void)alignmentRight
{
    // 计算文本的的宽度
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    dictM[NSFontAttributeName] = self.titleLabel.font;
    CGRect frame = [self.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dictM context:nil];

    CGRect imageFrame = self.imageView.frame;
    imageFrame.origin.x = self.bounds.size.width - cc_imageWidth;
    CGRect titleFrame = self.titleLabel.frame;
    titleFrame.origin.x = imageFrame.origin.x - frame.size.width;
    //    重写赋值frame
    self.titleLabel.frame = titleFrame;
    self.imageView.frame = imageFrame;
}

#pragma mark - 居中对齐
- (void)alignmentCenter
{
    //    设置文本的坐标
    CGFloat labelX = (cc_btnWidth - cc_labelWidth - cc_imageWidth - cc_padding) * 0.5;
    CGFloat labelY = (cc_btnHeight - cc_labelHeight) * 0.5;

    //    设置label的frame
    self.titleLabel.frame = CGRectMake(labelX, labelY, cc_labelWidth, cc_labelHeight);

    //    设置图片的坐标
    CGFloat imageX = CGRectGetMaxX(self.titleLabel.frame) + cc_padding;
    CGFloat imageY = (cc_btnHeight - cc_imageHeight) * 0.5;
    //    设置图片的frame
    self.imageView.frame = CGRectMake(imageX, imageY, cc_imageWidth, cc_imageHeight);
}

#pragma mark - 图标在上，文本在下(居中)
- (void)alignmentTop
{
    // 计算文本的的宽度
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    dictM[NSFontAttributeName] = self.titleLabel.font;
    CGRect frame = [self.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dictM context:nil];

    CGFloat imageX = (cc_btnWidth - cc_imageWidth) * 0.5;
    CGFloat imageY = (cc_btnHeight - cc_imageHeight - cc_labelHeight) / 3;
    self.imageView.frame = CGRectMake(imageX, imageY, cc_imageWidth, cc_imageHeight);
    self.titleLabel.frame = CGRectMake((self.center.x - frame.size.width) * 0.5, imageY * 2 + cc_imageHeight, cc_labelWidth, cc_labelHeight);
    CGPoint labelCenter = self.titleLabel.center;
    labelCenter.x = self.imageView.center.x;
    self.titleLabel.center = labelCenter;
}

#pragma mark - 图标在下，文本在上(居中)
- (void)alignmentBottom
{
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    // 计算文本的的宽度
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    dictM[NSFontAttributeName] = self.titleLabel.font;
    CGRect frame = [self.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dictM context:nil];

    CGFloat imageX = (cc_btnWidth - cc_imageWidth) * 0.5;
    self.titleLabel.frame = CGRectMake((self.center.x - frame.size.width) * 0.5, cc_btnHeight * 0.5 - cc_labelHeight * (1 + cc_buttonBottomRadio), cc_labelWidth, cc_labelHeight);
    self.imageView.frame = CGRectMake(imageX, cc_btnHeight * 0.5, cc_imageWidth, cc_imageHeight);
    CGPoint labelCenter = self.titleLabel.center;
    labelCenter.x = self.imageView.center.x;
    self.titleLabel.center = labelCenter;
}

/**
 *  布局子控件
 */
- (void)layoutSubviews
{
    [super layoutSubviews];
    // 判断
    if (_status == CCAlignmentStatusNormal) {

    } else if (_status == CCAlignmentStatusLeft) {
        [self alignmentLeft];
    }else if (_status == CCAlignmentStatusCenter){
        [self alignmentCenter];
    }else if (_status == CCAlignmentStatusRight){
        [self alignmentRight];
    }else if (_status == CCAlignmentStatusTop){
        [self alignmentTop];
    }else if (_status == CCAlignmentStatusBottom){
        [self alignmentBottom];
    }
}

@end
