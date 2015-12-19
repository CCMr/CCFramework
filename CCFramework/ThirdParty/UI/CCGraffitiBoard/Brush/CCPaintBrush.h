//
//  CCPaintBrush.h
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

@import UIKit;

/** 涂鸦工具. */
typedef NS_ENUM(NSUInteger, CCBrushType) {
    /** 画笔. */
    CCBrushTypePencil,
    /** 橡皮. */
    CCBrushTypeEraser,
    /** 直线. */
    CCBrushTypeLine,
    /** 虚线. */
    CCBrushTypeDashLine,
    /** 矩形. */
    CCBrushTypeRectangle,
    /** 方形. */
    CCBrushTypeSquare,
    /** 椭圆. */
    CCBrushTypeEllipse,
    /** 正圆. */
    CCBrushTypeCircle,
    /** 箭头. */
    CCBrushTypeArrow,
};

@protocol CCPaintBrush <NSObject>

/** 线条粗细. */
@property(nonatomic) CGFloat lineWidth;

/** 线条颜色. */
@property(nonatomic, strong) UIColor *lineColor;

/** 需要重绘的矩形范围. */
@property(nonatomic, readonly) CGRect redrawRect;

/** 是否需要绘制. */
@property(nonatomic, readonly) BOOL needsDraw;

/**
 *  @author CC, 2015-12-19
 *  
 *  @brief  当前画笔类型
 */
@property(nonatomic, assign) CCBrushType currentType;

/** 绘制图案到上下文. */
- (void)drawInContext:(CGContextRef)context;

/** 从指定点开始. */
- (void)beginAtPoint:(CGPoint)point;

/** 移动到指定点. */
- (void)moveToPoint:(CGPoint)point;

/** 移动结束. */
- (void)end;

@end