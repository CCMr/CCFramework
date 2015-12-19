//
//  CCUtilities.h
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

#import <UIKit/UIKit.h>

#pragma mark :. 颜色处理

FOUNDATION_EXPORT void CCHSVtoRGB(float h, float s, float v, float *r, float *g, float *b);
FOUNDATION_EXPORT void CCRGBtoHSV(float r, float g, float b, float *h, float *s, float *v);

/**
 *  @author CC, 2015-12-18
 *  
 *  @brief  随机浮点(10000)
 */
FOUNDATION_EXPORT float CCRandomFloat();

#pragma mark :. 绘图

/**
 *  @author CC, 2015-12-18
 *  
 *  @brief  绘制选中矩形
 *
 *  @param ctx  绘画
 *  @param dest 位置
 *  @param size 大小
 */
FOUNDATION_EXPORT void CCDrawCheckersInRect(CGContextRef ctx, CGRect dest, int size);

/**
 *  @author CC, 2015-12-18
 *  
 *  @brief  绘制透明矩形
 *
 *  @param ctx  绘画
 *  @param dest 位置
 */
FOUNDATION_EXPORT void CCDrawTransparencyDiamondInRect(CGContextRef ctx, CGRect dest);

/**
 *  @author CC, 2015-12-18
 *  
 *  @brief  绘制点
 *
 *  @param vector 位置
 */
FOUNDATION_EXPORT CGPoint CCNormalizePoint(CGPoint vector);

#pragma mark :. 常用函数

/**
 *  @author CC, 2015-12-18
 *  
 *  @brief  转屏调整
 *
 *  @param orientation 转屏位置
 *
 *  @return 返回调整动画
 */
FOUNDATION_EXPORT CGAffineTransform CCTransformForOrientation(UIInterfaceOrientation orientation);

FOUNDATION_EXPORT NSData *CCSHA1DigestForData(NSData *data);

FOUNDATION_EXPORT float CCIntDistance(int x1, int y1, int x2, int y2);

FOUNDATION_EXPORT CGPoint CCAddPoints(CGPoint a, CGPoint b);

FOUNDATION_EXPORT CGPoint CCSubtractPoints(CGPoint a, CGPoint b);

FOUNDATION_EXPORT CGSize CCAddSizes(CGSize a, CGSize b);

FOUNDATION_EXPORT float CCDistance(CGPoint a, CGPoint b);

FOUNDATION_EXPORT float CCClamp(float min, float max, float value);

FOUNDATION_EXPORT CGPoint CCCenterOfRect(CGRect rect);

FOUNDATION_EXPORT CGRect CCMultiplyRectScalar(CGRect r, float s);

FOUNDATION_EXPORT CGSize CCMultiplySizeScalar(CGSize size, float s);

FOUNDATION_EXPORT CGPoint CCMultiplyPointScalar(CGPoint p, float s);

FOUNDATION_EXPORT CGRect CCRectWithPoints(CGPoint a, CGPoint b);

FOUNDATION_EXPORT CGRect CCRectWithPointsConstrained(CGPoint a, CGPoint b, BOOL constrained);

FOUNDATION_EXPORT CGRect CCFlipRectWithinRect(CGRect src, CGRect dst);

FOUNDATION_EXPORT CGPoint CCFloorPoint(CGPoint pt);

FOUNDATION_EXPORT CGPoint CCRoundPoint(CGPoint pt);

FOUNDATION_EXPORT CGPoint CCAveragePoints(CGPoint a, CGPoint b);

FOUNDATION_EXPORT CGSize CCRoundSize(CGSize size);

FOUNDATION_EXPORT float CCMagnitude(CGPoint point);
