//
//  CCRadarIndicatorView.m
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

#import "CCRadarIndicatorView.h"

#define INDICATOR_START_COLOR [UIColor colorWithRed:1 green:1 blue:1 alpha:1]
#define INDICATOR_END_COLOR [UIColor colorWithRed:1 green:1 blue:1 alpha:0]

@implementation CCRadarIndicatorView

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // Drawing code
    //An opaque type that represents a Quartz 2D drawing environment.
    //一个不透明类型的Quartz 2D绘画环境,相当于一个画布,你可以在上面任意绘画
    CGContextRef context = UIGraphicsGetCurrentContext();

    //画扇形，也就画圆，只不过是设置角度的大小，形成一个扇形
    UIColor *aColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0];
    CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
    CGContextSetLineWidth(context, 0);//线的宽度
    //以self.radius为半径围绕圆心画指定角度扇形
    CGContextMoveToPoint(context, self.center.x, self.center.y);
    // CGContextAddArc(context, self.center.x, self.center.y, self.radius,  -89.7 * M_PI / 180, -90  * M_PI / 180, 1);

    CGContextAddArc(context, self.center.x, self.center.y, self.radius,  -90.5 * M_PI / 180, -90  * M_PI / 180, 0);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke); //绘制路径

    //多个小扇形构造渐变的大扇形  直角扇形
    for (int i = 0; i<=90; i++) {
        //画扇形，也就画圆，只不过是设置角度的大小，形成一个扇形
        UIColor *aColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:i/500.0f];
        CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
        CGContextSetLineWidth(context, 0);//线的宽度
        //以self.radius为半径围绕圆心画指定角度扇形
        CGContextMoveToPoint(context, self.center.x, self.center.y);
        CGContextAddArc(context, self.center.x, self.center.y, self.radius,  (-180 + i) * M_PI / 180, (-180 + i - 1) * M_PI / 180, 1);
        CGContextClosePath(context);
        CGContextDrawPath(context, kCGPathFillStroke); //绘制路径
    }
}

@end
