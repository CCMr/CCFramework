//
//  CCUtilities.m
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

#import "CCUtilities.h"
#include <CommonCrypto/CommonHMAC.h>

#pragma mark :. 颜色处理

FOUNDATION_EXPORT void CCHSVtoRGB(float h, float s, float v, float *r, float *g, float *b)
{
    if (s == 0) {
        *r = *g = *b = v;
    } else {
        float f, p, q, t;
        int i;
        
        h *= 360;
        
        if (h == 360.0f) {
            h = 0.0f;
        }
        
        h /= 60;
        i = floor(h);
        
        f = h - i;
        p = v * (1.0 - s);
        q = v * (1.0 - (s * f));
        t = v * (1.0 - (s * (1.0 - f)));
        
        switch (i) {
            case 0:
                *r = v;
                *g = t;
                *b = p;
                break;
            case 1:
                *r = q;
                *g = v;
                *b = p;
                break;
            case 2:
                *r = p;
                *g = v;
                *b = t;
                break;
            case 3:
                *r = p;
                *g = q;
                *b = v;
                break;
            case 4:
                *r = t;
                *g = p;
                *b = v;
                break;
            case 5:
                *r = v;
                *g = p;
                *b = q;
                break;
        }
    }
}

FOUNDATION_EXPORT void CCRGBtoHSV(float r, float g, float b, float *h, float *s, float *v)
{
    float max = MAX(r, MAX(g, b));
    float min = MIN(r, MIN(g, b));
    float delta = max - min;
    
    *v = max;
    *s = (max != 0.0f) ? (delta / max) : 0.0f;
    
    if (*s == 0.0f) {
        *h = 0.0f;
    } else {
        if (r == max) {
            *h = (g - b) / delta;
        } else if (g == max) {
            *h = 2.0f + (b - r) / delta;
        } else if (b == max) {
            *h = 4.0f + (r - g) / delta;
        }
        
        *h *= 60.0f;
        
        if (*h < 0.0f) {
            *h += 360.0f;
        }
    }
    
    *h /= 360.0f;
}


/**
 *  @author CC, 2015-12-18
 *  
 *  @brief  随机浮点
 */
FOUNDATION_EXPORT float CCRandomFloat()
{
    float r = random() % 10000;
    return r / 10000.0f;
}

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
FOUNDATION_EXPORT void CCDrawCheckersInRect(CGContextRef ctx, CGRect dest, int size)
{
    CGRect square = CGRectMake(0, 0, size, size);
    float startx = CGRectGetMinX(dest);
    float starty = CGRectGetMinY(dest);
    
    CGContextSaveGState(ctx);
    CGContextClipToRect(ctx, dest);
    
    [[UIColor colorWithWhite:0.9f alpha:1.0f] set];
    CGContextFillRect(ctx, dest);
    
    [[UIColor colorWithWhite:0.78f alpha:1.0f] set];
    for (int y = 0; y * size < CGRectGetHeight(dest); y++) {
        for (int x = 0; x * size < CGRectGetWidth(dest); x++) {
            if ((y + x) % 2) {
                square.origin.x = startx + x * size;
                square.origin.y = starty + y * size;
                CGContextFillRect(ctx, square);
            }
        }
    }
    
    CGContextRestoreGState(ctx);
}


/**
 *  @author CC, 2015-12-18
 *  
 *  @brief  绘制透明矩形
 *
 *  @param ctx  绘画
 *  @param dest 位置
 */
FOUNDATION_EXPORT void CCDrawTransparencyDiamondInRect(CGContextRef ctx, CGRect dest)
{
    float minX = CGRectGetMinX(dest);
    float maxX = CGRectGetMaxX(dest);
    float minY = CGRectGetMinY(dest);
    float maxY = CGRectGetMaxY(dest);
    
    CGContextSaveGState(ctx);
    [[UIColor whiteColor] set];
    CGContextFillRect(ctx, dest);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, minX, minY);
    CGPathAddLineToPoint(path, NULL, maxX, minY);
    CGPathAddLineToPoint(path, NULL, minX, maxY);
    CGPathCloseSubpath(path);
    
    [[UIColor blackColor] set];
    CGContextAddPath(ctx, path);
    CGContextFillPath(ctx);
    CGContextRestoreGState(ctx);
    
    CGPathRelease(path);
}

/**
 *  @author CC, 2015-12-18
 *  
 *  @brief  绘制点
 *
 *  @param vector 位置
 */
FOUNDATION_EXPORT CGPoint CCNormalizePoint(CGPoint vector)
{
    float distance = CCDistance(CGPointZero, vector);
    
    if (distance == 0.0f) {
        return vector;
    }
    
    return CCMultiplyPointScalar(vector, 1.0f / CCDistance(CGPointZero, vector));
}

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
FOUNDATION_EXPORT CGAffineTransform CCTransformForOrientation(UIInterfaceOrientation orientation)
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            transform = CGAffineTransformRotate(transform, M_PI / -2);
            break;
        case UIInterfaceOrientationLandscapeRight:
            transform = CGAffineTransformRotate(transform, M_PI / 2);
            break;
        default:
            break;
    }
    
    return transform;
}

FOUNDATION_EXPORT NSData *CCSHA1DigestForData(NSData *data)
{
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, NULL, 0, [data bytes], [data length], cHMAC);
    
    return [NSData dataWithBytes:cHMAC length:sizeof(cHMAC)];
}

FOUNDATION_EXPORT float CCIntDistance(int x1, int y1, int x2, int y2)
{
    int xd = (x1 - x2), yd = (y1 - y2);
    return sqrt(xd * xd + yd * yd);
}

FOUNDATION_EXPORT CGPoint CCAddPoints(CGPoint a, CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}

FOUNDATION_EXPORT CGPoint CCSubtractPoints(CGPoint a, CGPoint b)
{
    return CGPointMake(a.x - b.x, a.y - b.y);
}

FOUNDATION_EXPORT CGSize CCAddSizes(CGSize a, CGSize b)
{
    return CGSizeMake(a.width + b.width, a.height + b.height);
}


FOUNDATION_EXPORT float CCDistance(CGPoint a, CGPoint b)
{
    float xd = (a.x - b.x);
    float yd = (a.y - b.y);
    
    return sqrt(xd * xd + yd * yd);
}

FOUNDATION_EXPORT float CCClamp(float min, float max, float value)
{
    return (value < min) ? min : (value > max) ? max : value;
}

FOUNDATION_EXPORT CGPoint CCCenterOfRect(CGRect rect)
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

FOUNDATION_EXPORT CGRect CCMultiplyRectScalar(CGRect r, float s)
{
    return CGRectMake(r.origin.x * s, r.origin.y * s, r.size.width * s, r.size.height * s);
}

FOUNDATION_EXPORT CGSize CCMultiplySizeScalar(CGSize size, float s)
{
    return CGSizeMake(size.width * s, size.height * s);
}

FOUNDATION_EXPORT CGPoint CCMultiplyPointScalar(CGPoint p, float s)
{
    return CGPointMake(p.x * s, p.y * s);
}

FOUNDATION_EXPORT CGRect CCRectWithPoints(CGPoint a, CGPoint b)
{
    float minx = MIN(a.x, b.x);
    float maxx = MAX(a.x, b.x);
    float miny = MIN(a.y, b.y);
    float maxy = MAX(a.y, b.y);
    
    return CGRectMake(minx, miny, maxx - minx, maxy - miny);
}

FOUNDATION_EXPORT CGRect CCRectWithPointsConstrained(CGPoint a, CGPoint b, BOOL constrained)
{
    float minx = MIN(a.x, b.x);
    float maxx = MAX(a.x, b.x);
    float miny = MIN(a.y, b.y);
    float maxy = MAX(a.y, b.y);
    float dimx = maxx - minx;
    float dimy = maxy - miny;
    
    if (constrained) {
        dimx = dimy = MAX(dimx, dimy);
    }
    
    return CGRectMake(minx, miny, dimx, dimy);
}

FOUNDATION_EXPORT CGRect CCFlipRectWithinRect(CGRect src, CGRect dst)
{
    src.origin.y = CGRectGetMaxY(dst) - CGRectGetMaxY(src);
    return src;
}

FOUNDATION_EXPORT CGPoint CCFloorPoint(CGPoint pt)
{
    return CGPointMake(floor(pt.x), floor(pt.y));
}

FOUNDATION_EXPORT CGPoint CCRoundPoint(CGPoint pt)
{
    return CGPointMake(round(pt.x), round(pt.y));
}

FOUNDATION_EXPORT CGPoint CCAveragePoints(CGPoint a, CGPoint b)
{
    return CCMultiplyPointScalar(CCAddPoints(a, b), 0.5f);
}

FOUNDATION_EXPORT CGSize CCRoundSize(CGSize size)
{
    return CGSizeMake(round(size.width), round(size.height));
}

FOUNDATION_EXPORT float CCMagnitude(CGPoint point)
{
    return CCDistance(point, CGPointZero);
}
