//
//  CCBubblePhotoImageView.m
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

#import "CCBubblePhotoImageView.h"
#import "UIView+CCRemoteImage.h"
#import "UIImage+Resize.h"
#import "Config.h"

@interface CCBubblePhotoImageView ()

@property dispatch_semaphore_t semaphore;

/**
 *  消息类型
 */
@property(nonatomic, assign) CCBubbleMessageType bubbleMessageType;

@end

@implementation CCBubblePhotoImageView

- (CCBubbleMessageType)getBubbleMessageType
{
    return self.bubbleMessageType;
}

- (UIActivityIndicatorView *)activityIndicatorView
{
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc]
                                  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicatorView.hidesWhenStopped = YES;
    }
    return _activityIndicatorView;
}

- (void)setMessagePhoto:(UIImage *)messagePhoto
{
    _messagePhoto = messagePhoto;
    [self setNeedsDisplay];
}

- (void)configureMessagePhoto:(UIImage *)messagePhoto
                 thumbnailUrl:(NSString *)thumbnailUrl
               originPhotoUrl:(NSString *)originPhotoUrl
          onBubbleMessageType:(CCBubbleMessageType)bubbleMessageType
{
    self.bubbleMessageType = bubbleMessageType;
    self.messagePhoto = messagePhoto;
    
    if (thumbnailUrl) {
        WEAKSELF;
        [self addSubview:self.activityIndicatorView];
        [self.activityIndicatorView startAnimating];
        self.messagePhoto = [UIImage imageNamed:@"placeholder"];
        [self setImageWithURL:[NSURL URLWithString:thumbnailUrl]
                   placeholer:nil
    showActivityIndicatorView:
         NO completionBlock:^(UIImage *image, NSURL *url, NSError *error) {
             if ([url.absoluteString isEqualToString:thumbnailUrl]) {
                 
                 if (CGRectEqualToRect(weakSelf.bounds, CGRectZero)) {
                     if (weakSelf) {
                         weakSelf.semaphore = dispatch_semaphore_create(0);
                         dispatch_semaphore_wait(weakSelf.semaphore,
                                                 DISPATCH_TIME_FOREVER);
                         weakSelf.semaphore = nil;
                     }
                 }
                 
                 // if image not nil
                 if (image) {
                     // scale image
                     image = [image thumbnailImage:CGRectGetWidth(weakSelf.bounds) * 2
                                 transparentBorder:0
                                      cornerRadius:0
                              interpolationQuality:1.0];
                     dispatch_async(dispatch_get_main_queue(), ^{
                         // if image not nil
                         if (image) {
                             // show image
                             weakSelf.messagePhoto = image;
                             [weakSelf.activityIndicatorView stopAnimating];
                         }
                     });
                 }
             }
         }];
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (self.semaphore) {
        dispatch_semaphore_signal(self.semaphore);
    }
    _activityIndicatorView.center = CGPointMake(
                                                CGRectGetWidth(self.bounds) / 2.0, CGRectGetHeight(self.bounds) / 2.0);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)dealloc
{
    _messagePhoto = nil;
    [self.activityIndicatorView stopAnimating];
    self.activityIndicatorView = nil;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    rect.origin = CGPointZero;
    [self.messagePhoto drawInRect:rect];
    
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height + 1;//莫名其妙会出现绘制底部有残留 +1像素遮盖
    // 简便起见，这里把圆角半径设置为长和宽平均值的1/10
    CGFloat radius = 6;
    CGFloat margin = kCCBubblePhotoMargin;//留出上下左右的边距
    
    CGFloat triangleSize = 8;//三角形的边长
    CGFloat triangleMarginTop = 8;//三角形距离圆角的距离
    
    CGFloat borderOffset = 3;//阴影偏移量
    UIColor *borderColor = [UIColor blackColor];//阴影的颜色
    
    // 获取CGContext，注意UIKit里用的是一个专门的函数
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context,0,0,0,1);//画笔颜色
    CGContextSetLineWidth(context, 1);//画笔宽度
    // 移动到初始点
    CGContextMoveToPoint(context, radius + margin, margin);
    // 绘制第1条线和第1个1/4圆弧
    CGContextAddLineToPoint(context, width - radius - margin, margin);
    CGContextAddArc(context, width - radius - margin, radius + margin, radius, -0.5 * M_PI, 0.0, 0);
    CGContextAddLineToPoint(context, width, margin + radius);
    CGContextAddLineToPoint(context, width, 0);
    CGContextAddLineToPoint(context, radius + margin,0);
    // 闭合路径
    CGContextClosePath(context);
    // 绘制第2条线和第2个1/4圆弧
    CGContextMoveToPoint(context, width - margin, margin + radius);
    CGContextAddLineToPoint(context, width, margin + radius);
    CGContextAddLineToPoint(context, width, height - margin - radius);
    CGContextAddLineToPoint(context, width - margin, height - margin - radius);
    
    float arcSize = 3;//角度的大小
    
    if (self.bubbleMessageType == CCBubbleMessageTypeSending) {
        float arcStartY = margin + radius + triangleMarginTop + triangleSize - (triangleSize - arcSize / margin * triangleSize) / 2;//圆弧起始Y值
        float arcStartX = width - arcSize;//圆弧起始X值
        float centerOfCycleX = width - arcSize - pow(arcSize / margin * triangleSize / 2, 2) / arcSize;//圆心的X值
        float centerOfCycleY = margin + radius + triangleMarginTop + triangleSize / 2;//圆心的Y值
        float radiusOfCycle = hypotf(arcSize / margin * triangleSize / 2, pow(arcSize / margin * triangleSize / 2, 2) / arcSize);//半径
        float angelOfCycle = asinf(0.5 * (arcSize / margin * triangleSize) / radiusOfCycle) * 2;//角度
        //绘制右边三角形
        CGContextAddLineToPoint(context, width - margin , margin + radius + triangleMarginTop + triangleSize);
        CGContextAddLineToPoint(context, arcStartX , arcStartY);
        CGContextAddArc(context, centerOfCycleX, centerOfCycleY, radiusOfCycle, angelOfCycle / 2, 0.0 - angelOfCycle / 2, 1);
        CGContextAddLineToPoint(context, width - margin , margin + radius + triangleMarginTop);
    }
    
    
    CGContextMoveToPoint(context, width - margin, height - radius - margin);
    CGContextAddArc(context, width - radius - margin, height - radius - margin, radius, 0.0, 0.5 * M_PI, 0);
    CGContextAddLineToPoint(context, width - margin - radius, height);
    CGContextAddLineToPoint(context, width, height);
    CGContextAddLineToPoint(context, width, height - radius - margin);
    
    
    // 绘制第3条线和第3个1/4圆弧
    CGContextMoveToPoint(context, width - margin - radius, height - margin);
    CGContextAddLineToPoint(context, width - margin - radius, height);
    CGContextAddLineToPoint(context, margin, height);
    CGContextAddLineToPoint(context, margin, height - margin);
    
    
    CGContextMoveToPoint(context, margin, height-margin);
    CGContextAddArc(context, radius + margin, height - radius - margin, radius, 0.5 * M_PI, M_PI, 0);
    CGContextAddLineToPoint(context, 0, height - margin - radius);
    CGContextAddLineToPoint(context, 0, height);
    CGContextAddLineToPoint(context, margin, height);
    
    
    // 绘制第4条线和第4个1/4圆弧
    CGContextMoveToPoint(context, margin, height - margin - radius);
    CGContextAddLineToPoint(context, 0, height - margin - radius);
    CGContextAddLineToPoint(context, 0, radius + margin);
    CGContextAddLineToPoint(context, margin, radius + margin);
    
    if (!self.bubbleMessageType == CCBubbleMessageTypeSending) {
        float arcStartY = margin + radius + triangleMarginTop + (triangleSize - arcSize / margin * triangleSize) / 2;//圆弧起始Y值
        float arcStartX = arcSize;//圆弧起始X值
        float centerOfCycleX = arcSize + pow(arcSize / margin * triangleSize / 2, 2) / arcSize;//圆心的X值
        float centerOfCycleY = margin + radius + triangleMarginTop + triangleSize / 2;//圆心的Y值
        float radiusOfCycle = hypotf(arcSize / margin * triangleSize / 2, pow(arcSize / margin * triangleSize / 2, 2) / arcSize);//半径
        float angelOfCycle = asinf(0.5 * (arcSize / margin * triangleSize) / radiusOfCycle) * 2;//角度
        //绘制左边三角形
        CGContextAddLineToPoint(context, margin , margin + radius + triangleMarginTop);
        CGContextAddLineToPoint(context, arcStartX , arcStartY);
        CGContextAddArc(context, centerOfCycleX, centerOfCycleY, radiusOfCycle, M_PI + angelOfCycle / 2, M_PI - angelOfCycle / 2, 1);
        CGContextAddLineToPoint(context, margin , margin + radius + triangleMarginTop + triangleSize);
    }
    CGContextMoveToPoint(context, margin, radius + margin);
    CGContextAddArc(context, radius + margin, margin + radius, radius, M_PI, 1.5 * M_PI, 0);
    CGContextAddLineToPoint(context, margin + radius, 0);
    CGContextAddLineToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 0, radius + margin);
    
    CGContextSetShadowWithColor(context, CGSizeMake(0, 0), borderOffset, borderColor.CGColor);//阴影
    CGContextSetBlendMode(context, kCGBlendModeClear);
    
    CGContextDrawPath(context, kCGPathFill);
}

@end
