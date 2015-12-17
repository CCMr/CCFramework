//
//  CCBaseBrush.h
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

#import "CCBaseBrush.h"
#import "CCLineBrush.h"
#import "CCArrowBrush.h"
#import "CCPencilBrush.h"
#import "CCEraserBrush.h"
#import "CCCircleBrush.h"
#import "CCSquareBrush.h"
#import "CCEllipseBrush.h"
#import "CCDashLineBrush.h"
#import "CCRectangleBrush.h"


@interface CCBaseBrush ()

/** 是否需要绘制. */
@property(nonatomic, readwrite) BOOL needsDraw;

/** 初始点. */
@property(nonatomic, readwrite) CGPoint startPoint;

/** 上一点. */
@property(nonatomic, readwrite) CGPoint previousPoint;

/** 当前点. */
@property(nonatomic, readwrite) CGPoint currentPoint;

@end


@implementation CCBaseBrush
@synthesize lineWidth = _lineWidth, lineColor = _lineColor;

+ (id<CCPaintBrush>)brushWithType:(CCBrushType)brushType
{
    switch (brushType) {
        case CCBrushTypePencil:
            return [CCPencilBrush new];
            
        case CCBrushTypeEraser:
            return [CCEraserBrush new];
            
        case CCBrushTypeLine:
            return [CCLineBrush new];
            
        case CCBrushTypeDashLine:
            return [CCDashLineBrush new];
            
        case CCBrushTypeRectangle:
            return [CCRectangleBrush new];
            
        case CCBrushTypeSquare:
            return [CCSquareBrush new];
            
        case CCBrushTypeEllipse:
            return [CCEllipseBrush new];
            
        case CCBrushTypeCircle:
            return [CCCircleBrush new];
            
        case CCBrushTypeArrow:
            return [CCArrowBrush new];
    }
    return nil;
}

#pragma mark - CCPaintBrush 协议方法

- (void)beginAtPoint:(CGPoint)point
{
    self.startPoint = point;
    self.currentPoint = point;
    self.previousPoint = point;
    self.needsDraw = YES;
}

- (void)moveToPoint:(CGPoint)point
{
    self.previousPoint = self.currentPoint;
    self.currentPoint = point;
}

- (void)end
{
    self.needsDraw = NO;
}

- (void)drawInContext:(CGContextRef)context
{
    [self configureContext:context];
    
    CGContextStrokePath(context);
}

- (CGRect)redrawRect
{
    // 根据 起点, 上一点, 当前点 三点计算包含三点的最小重绘矩形.适用于画矩形,椭圆之类的图案.
    CGFloat minX = fmin(fmin(self.startPoint.x, self.previousPoint.x), self.currentPoint.x) - self.lineWidth / 2;
    CGFloat minY = fmin(fmin(self.startPoint.y, self.previousPoint.y), self.currentPoint.y) - self.lineWidth / 2;
    CGFloat maxX = fmax(fmax(self.startPoint.x, self.previousPoint.x), self.currentPoint.x) + self.lineWidth / 2;
    CGFloat maxY = fmax(fmax(self.startPoint.y, self.previousPoint.y), self.currentPoint.y) + self.lineWidth / 2;
    
    return CGRectMake(minX, minY, maxX - minX, maxY - minY);
}

#pragma mark - 配置上下文

- (void)configureContext:(CGContextRef)context
{
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
}

@end