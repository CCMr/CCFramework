//
//  UIBezierPath+Additions.m
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

#import "UIBezierPath+Additions.h"
#import <objc/runtime.h>

typedef struct BezierSubpath {
    CGPoint startPoint;
    CGPoint controlPoint1;
    CGPoint controlPoint2;
    CGPoint endPoint;
    CGFloat length;
    CGPathElementType type;
} BezierSubpath;

typedef void (^BezierSubpathEnumerator)(const CGPathElement *element);

static void bezierSubpathFunction(void *info, CGPathElement const *element)
{
    BezierSubpathEnumerator block = (__bridge BezierSubpathEnumerator)info;
    block(element);
}

@implementation UIBezierPath (Additions)

#pragma mark -
#pragma mark :. Length
#pragma mark :. Internal

- (void)enumerateSubpaths:(BezierSubpathEnumerator)enumeratorBlock
{
    CGPathApply(self.CGPath, (__bridge void *)enumeratorBlock, bezierSubpathFunction);
}

- (NSUInteger)countSubpaths
{
    __block NSUInteger count = 0;
    [self enumerateSubpaths:^(const CGPathElement *element) {
        if (element->type != kCGPathElementMoveToPoint) {
            count++;
        }
    }];
    if (count == 0) {
        return 1;
    }
    return count;
}

- (void)extractSubpaths:(BezierSubpath *)subpathArray
{
    __block CGPoint currentPoint = CGPointZero;
    __block NSUInteger i = 0;
    [self enumerateSubpaths:^(const CGPathElement *element) {
        
        CGPathElementType type = element->type;
        CGPoint *points = element->points;
        
        CGFloat subLength = 0.0f;
        CGPoint endPoint = CGPointZero;
        
        BezierSubpath subpath;
        subpath.type = type;
        subpath.startPoint = currentPoint;
        
        /*
         *  All paths, no matter how complex, are created through a combination of these path elements.
         */
        switch (type) {
            case kCGPathElementMoveToPoint:
                
                endPoint = points[0];
                
                break;
            case kCGPathElementAddLineToPoint:
                
                endPoint = points[0];
                
                subLength = linearLineLength(currentPoint, endPoint);
                
                break;
            case kCGPathElementAddQuadCurveToPoint:
                
                endPoint = points[1];
                CGPoint controlPoint = points[0];
                
                subLength = quadCurveLength(currentPoint, endPoint, controlPoint);
                
                subpath.controlPoint1 = controlPoint;
                
                break;
            case kCGPathElementAddCurveToPoint:
                
                endPoint = points[2];
                CGPoint controlPoint1 = points[0];
                CGPoint controlPoint2 = points[1];
                
                subLength = cubicCurveLength(currentPoint, endPoint, controlPoint1, controlPoint2);
                
                subpath.controlPoint1 = controlPoint1;
                subpath.controlPoint2 = controlPoint2;
                
                break;
            case kCGPathElementCloseSubpath:
            default:
                break;
        }
        
        subpath.length = subLength;
        subpath.endPoint = endPoint;
        
        if (type != kCGPathElementMoveToPoint) {
            subpathArray[i] = subpath;
            i++;
        }
        
        currentPoint = endPoint;
    }];
    if (i == 0) {
        subpathArray[0].length = 0.0f;
        subpathArray[0].endPoint = currentPoint;
    }
}

- (CGPoint)pointAtPercent:(CGFloat)t ofSubpath:(BezierSubpath)subpath
{
    
    CGPoint p = CGPointZero;
    switch (subpath.type) {
        case kCGPathElementAddLineToPoint:
            p = linearBezierPoint(t, subpath.startPoint, subpath.endPoint);
            break;
        case kCGPathElementAddQuadCurveToPoint:
            p = quadBezierPoint(t, subpath.startPoint, subpath.controlPoint1, subpath.endPoint);
            break;
        case kCGPathElementAddCurveToPoint:
            p = cubicBezierPoint(t, subpath.startPoint, subpath.controlPoint1, subpath.controlPoint2, subpath.endPoint);
            break;
        default:
            break;
    }
    return p;
}

#pragma mark :. Public API

- (CGFloat)length
{
    
    NSUInteger subpathCount = [self countSubpaths];
    BezierSubpath subpaths[subpathCount];
    [self extractSubpaths:subpaths];
    
    CGFloat length = 0.0f;
    for (NSUInteger i = 0; i < subpathCount; i++) {
        length += subpaths[i].length;
    }
    return length;
}

- (CGPoint)pointAtPercentOfLength:(CGFloat)percent
{
    
    if (percent < 0.0f) {
        percent = 0.0f;
    } else if (percent > 1.0f) {
        percent = 1.0f;
    }
    
    NSUInteger subpathCount = [self countSubpaths];
    BezierSubpath subpaths[subpathCount];
    [self extractSubpaths:subpaths];
    
    CGFloat length = 0.0f;
    for (NSUInteger i = 0; i < subpathCount; i++) {
        length += subpaths[i].length;
    }
    
    CGFloat pointLocationInPath = length * percent;
    CGFloat currentLength = 0;
    BezierSubpath subpathContainingPoint;
    for (NSUInteger i = 0; i < subpathCount; i++) {
        if (currentLength + subpaths[i].length >= pointLocationInPath) {
            subpathContainingPoint = subpaths[i];
            break;
        } else {
            currentLength += subpaths[i].length;
        }
    }
    
    CGFloat lengthInSubpath = pointLocationInPath - currentLength;
    if (subpathContainingPoint.length == 0) {
        return subpathContainingPoint.endPoint;
    } else {
        CGFloat t = lengthInSubpath / subpathContainingPoint.length;
        return [self pointAtPercent:t ofSubpath:subpathContainingPoint];
    }
}

#pragma mark :. Math helpers

CGFloat linearLineLength(CGPoint fromPoint, CGPoint toPoint)
{
    return sqrtf(powf(toPoint.x - fromPoint.x, 2) + powf(toPoint.y - fromPoint.y, 2));
}

CGFloat quadCurveLength(CGPoint fromPoint, CGPoint toPoint, CGPoint controlPoint)
{
    int iterations = 100;
    CGFloat length = 0;
    
    for (int idx = 0; idx < iterations; idx++) {
        float t = idx * (1.0 / iterations);
        float tt = t + (1.0 / iterations);
        
        CGPoint p = quadBezierPoint(t, fromPoint, controlPoint, toPoint);
        CGPoint pp = quadBezierPoint(tt, fromPoint, controlPoint, toPoint);
        
        length += linearLineLength(p, pp);
    }
    
    return length;
}

CGFloat cubicCurveLength(CGPoint fromPoint, CGPoint toPoint, CGPoint controlPoint1, CGPoint controlPoint2)
{
    int iterations = 100;
    CGFloat length = 0;
    
    for (int idx = 0; idx < iterations; idx++) {
        float t = idx * (1.0 / iterations);
        float tt = t + (1.0 / iterations);
        
        CGPoint p = cubicBezierPoint(t, fromPoint, controlPoint1, controlPoint2, toPoint);
        CGPoint pp = cubicBezierPoint(tt, fromPoint, controlPoint1, controlPoint2, toPoint);
        
        length += linearLineLength(p, pp);
    }
    return length;
}

CGPoint linearBezierPoint(float t, CGPoint start, CGPoint end)
{
    CGFloat dx = end.x - start.x;
    CGFloat dy = end.y - start.y;
    
    CGFloat px = start.x + (t * dx);
    CGFloat py = start.y + (t * dy);
    
    return CGPointMake(px, py);
}

CGPoint quadBezierPoint(float t, CGPoint start, CGPoint c1, CGPoint end)
{
    CGFloat x = QuadBezier(t, start.x, c1.x, end.x);
    CGFloat y = QuadBezier(t, start.y, c1.y, end.y);
    
    return CGPointMake(x, y);
}

CGPoint cubicBezierPoint(float t, CGPoint start, CGPoint c1, CGPoint c2, CGPoint end)
{
    CGFloat x = CubicBezier(t, start.x, c1.x, c2.x, end.x);
    CGFloat y = CubicBezier(t, start.y, c1.y, c2.y, end.y);
    
    return CGPointMake(x, y);
}

float CubicBezier(float t, float start, float c1, float c2, float end)
{
    CGFloat t_ = (1.0 - t);
    CGFloat tt_ = t_ * t_;
    CGFloat ttt_ = t_ * t_ * t_;
    CGFloat tt = t * t;
    CGFloat ttt = t * t * t;
    
    return start * ttt_ + 3.0 * c1 * tt_ * t + 3.0 * c2 * t_ * tt + end * ttt;
}

float QuadBezier(float t, float start, float c1, float end)
{
    CGFloat t_ = (1.0 - t);
    CGFloat tt_ = t_ * t_;
    CGFloat tt = t * t;
    
    return start * tt_ + 2.0 * c1 * t_ * t + end * tt;
}

#pragma mark -
#pragma mark :. ThroughPointsBezier

- (void)setContractionFactor:(CGFloat)contractionFactor
{
    objc_setAssociatedObject(self, @selector(contractionFactor), @(contractionFactor), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)contractionFactor
{
    id contractionFactorAssociatedObject = objc_getAssociatedObject(self, @selector(contractionFactor));
    if (contractionFactorAssociatedObject == nil) {
        return 0.7;
    }
    return [contractionFactorAssociatedObject floatValue];
}

- (void)addBezierThroughPoints:(NSArray *)pointArray
{
    NSAssert(pointArray.count > 0, @"You must give at least 1 point for drawing the curve.");
    
    if (pointArray.count < 3) {
        switch (pointArray.count) {
            case 1: {
                NSValue *point0Value = pointArray[0];
                CGPoint point0 = [point0Value CGPointValue];
                [self addLineToPoint:point0];
            } break;
            case 2: {
                NSValue *point0Value = pointArray[0];
                CGPoint point0 = [point0Value CGPointValue];
                NSValue *point1Value = pointArray[1];
                CGPoint point1 = [point1Value CGPointValue];
                [self addQuadCurveToPoint:point1 controlPoint:ControlPointForTheBezierCanThrough3Point(self.currentPoint, point0, point1)];
            } break;
            default:
                break;
        }
    }
    
    CGPoint previousPoint = CGPointZero;
    
    CGPoint previousCenterPoint = CGPointZero;
    CGPoint centerPoint = CGPointZero;
    CGFloat centerPointDistance = 0;
    
    CGFloat obliqueAngle = 0;
    
    CGPoint previousControlPoint1 = CGPointZero;
    CGPoint previousControlPoint2 = CGPointZero;
    CGPoint controlPoint1 = CGPointZero;
    
    previousPoint = self.currentPoint;
    
    for (int i = 0; i < pointArray.count; i++) {
        
        NSValue *pointIValue = pointArray[i];
        CGPoint pointI = [pointIValue CGPointValue];
        
        if (i > 0) {
            
            previousCenterPoint = CenterPointOf(self.currentPoint, previousPoint);
            centerPoint = CenterPointOf(previousPoint, pointI);
            
            centerPointDistance = DistanceBetweenPoint(previousCenterPoint, centerPoint);
            
            obliqueAngle = ObliqueAngleOfStraightThrough(centerPoint, previousCenterPoint);
            
            previousControlPoint2 = CGPointMake(previousPoint.x - 0.5 * self.contractionFactor * centerPointDistance * cos(obliqueAngle), previousPoint.y - 0.5 * self.contractionFactor * centerPointDistance * sin(obliqueAngle));
            controlPoint1 = CGPointMake(previousPoint.x + 0.5 * self.contractionFactor * centerPointDistance * cos(obliqueAngle), previousPoint.y + 0.5 * self.contractionFactor * centerPointDistance * sin(obliqueAngle));
        }
        
        if (i == 1) {
            
            [self addQuadCurveToPoint:previousPoint controlPoint:previousControlPoint2];
        } else if (i > 1 && i < pointArray.count - 1) {
            
            [self addCurveToPoint:previousPoint controlPoint1:previousControlPoint1 controlPoint2:previousControlPoint2];
        } else if (i == pointArray.count - 1) {
            
            [self addCurveToPoint:previousPoint controlPoint1:previousControlPoint1 controlPoint2:previousControlPoint2];
            [self addQuadCurveToPoint:pointI controlPoint:controlPoint1];
        } else {
        }
        
        previousControlPoint1 = controlPoint1;
        previousPoint = pointI;
    }
}

CGFloat ObliqueAngleOfStraightThrough(CGPoint point1, CGPoint point2) //  [-π/2, 3π/2)
{
    CGFloat obliqueRatio = 0;
    CGFloat obliqueAngle = 0;
    
    if (point1.x > point2.x) {
        
        obliqueRatio = (point2.y - point1.y) / (point2.x - point1.x);
        obliqueAngle = atan(obliqueRatio);
    } else if (point1.x < point2.x) {
        
        obliqueRatio = (point2.y - point1.y) / (point2.x - point1.x);
        obliqueAngle = M_PI + atan(obliqueRatio);
    } else if (point2.y - point1.y >= 0) {
        
        obliqueAngle = M_PI / 2;
    } else {
        obliqueAngle = -M_PI / 2;
    }
    
    return obliqueAngle;
}

CGPoint ControlPointForTheBezierCanThrough3Point(CGPoint point1, CGPoint point2, CGPoint point3)
{
    return CGPointMake(2 * point2.x - (point1.x + point3.x) / 2, 2 * point2.y - (point1.y + point3.y) / 2);
}

CGFloat DistanceBetweenPoint(CGPoint point1, CGPoint point2)
{
    return sqrt((point1.x - point2.x) * (point1.x - point2.x) + (point1.y - point2.y) * (point1.y - point2.y));
}

CGPoint CenterPointOf(CGPoint point1, CGPoint point2)
{
    return CGPointMake((point1.x + point2.x) / 2, (point1.y + point2.y) / 2);
}

#pragma mark -
#pragma mark :. SVG
/**
 *  @brief  UIBezierPath转成SVG
 *
 *  @return SVG
 */
- (NSString *)toSVGString
{
    CGPathRef path = [self CGPath];
    NSMutableString *SVGString = [NSMutableString string];
    [SVGString appendString:@"<path id=\"temporaryID\" d=\""];
    CGPathApply(path, (__bridge_retained void *)SVGString, SVGApplier);
    NSString *lineCap;
    switch (self.lineCapStyle) {
        case kCGLineCapRound:
            lineCap = @"round";
            break;
        case kCGLineCapSquare:
            lineCap = @"square";
            break;
        default:
            lineCap = @"butt";
            break;
    }
    [SVGString appendFormat:@"\" stroke-linecap=\"%@\" stroke-width=\"%i\" fill=\"none\" stroke=\"red\" />", lineCap, (int)self.lineWidth];
    return [NSString stringWithFormat:@"%@", SVGString];
}

static void SVGApplier(void *info, const CGPathElement *element)
{
    NSMutableString *SVGString = (__bridge NSMutableString *)info;
    int nPoints;
    char elementKey;
    switch (element->type) {
        case kCGPathElementMoveToPoint:
            nPoints = 1;
            elementKey = 'M';
            break;
        case kCGPathElementAddLineToPoint:
            nPoints = 1;
            elementKey = 'L';
            break;
        case kCGPathElementAddQuadCurveToPoint:
            nPoints = 2;
            elementKey = 'Q';
            break;
        case kCGPathElementAddCurveToPoint:
            nPoints = 3;
            elementKey = 'C';
            break;
        case kCGPathElementCloseSubpath:
            nPoints = 0;
            elementKey = 'Z';
            break;
        default:
            SVGString = nil;
            return;
    }
    NSString *nextElement = [NSString stringWithFormat:@" %c", elementKey];
    for (int i = 0; i < nPoints; i++) {
        nextElement = [nextElement stringByAppendingString:[NSString stringWithFormat:@" %i %i", (int)element->points[i].x, (int)element->points[i].y]];
    }
    [SVGString appendString:nextElement];
}

#pragma mark -
#pragma mark :. Symbol

#define CGPointWithOffset(originPoint, offsetPoint) \
CGPointMake(originPoint.x + offsetPoint.x, originPoint.y + offsetPoint.y)

// plus
//
//     c-d
//     | |
//  a--b e--f
//  |       |
//  l--k h--g
//     | |
//     j-i
//
+ (UIBezierPath *)customBezierPathOfPlusSymbolWithRect:(CGRect)rect
                                                 scale:(CGFloat)scale {
    CGFloat height     = CGRectGetHeight(rect) * scale;
    CGFloat width      = CGRectGetWidth(rect)  * scale;
    CGFloat size       = (height < width ? height : width) * scale;
    CGFloat thick      = size / 3.f;
    CGFloat twiceThick = thick * 2.f;
    
    CGPoint offsetPoint =
    CGPointMake(CGRectGetMinX(rect) + (CGRectGetWidth(rect)  - size) / 2.f,
                CGRectGetMinY(rect) + (CGRectGetHeight(rect) - size) / 2.f);
    
    UIBezierPath * path = [self bezierPath];
    [path moveToPoint:CGPointWithOffset(CGPointMake(0.f, thick), offsetPoint)];                // a
    [path addLineToPoint:CGPointWithOffset(CGPointMake(thick, thick), offsetPoint)];           // b
    [path addLineToPoint:CGPointWithOffset(CGPointMake(thick, 0.f), offsetPoint)];             // c
    [path addLineToPoint:CGPointWithOffset(CGPointMake(twiceThick, 0.f), offsetPoint)];        // d
    [path addLineToPoint:CGPointWithOffset(CGPointMake(twiceThick, thick), offsetPoint)];      // e
    [path addLineToPoint:CGPointWithOffset(CGPointMake(size, thick), offsetPoint)];            // f
    [path addLineToPoint:CGPointWithOffset(CGPointMake(size, twiceThick), offsetPoint)];       // g
    [path addLineToPoint:CGPointWithOffset(CGPointMake(twiceThick, twiceThick), offsetPoint)]; // h
    [path addLineToPoint:CGPointWithOffset(CGPointMake(twiceThick, size), offsetPoint)];       // i
    [path addLineToPoint:CGPointWithOffset(CGPointMake(thick, size), offsetPoint)];            // j
    [path addLineToPoint:CGPointWithOffset(CGPointMake(thick, twiceThick), offsetPoint)];      // k
    [path addLineToPoint:CGPointWithOffset(CGPointMake(0.f, twiceThick), offsetPoint)];        // l
    [path closePath];
    return path;
}

// minus
+ (UIBezierPath *)customBezierPathOfMinusSymbolWithRect:(CGRect)rect
                                                  scale:(CGFloat)scale {
    CGFloat height = CGRectGetHeight(rect) * scale;
    CGFloat width  = CGRectGetWidth(rect)  * scale;
    CGFloat size   = height < width ? height : width;
    CGFloat thick  = size / 3.f;
    
    return [self bezierPathWithRect:
            CGRectOffset(CGRectMake(0.f, thick, size, thick),
                         CGRectGetMinX(rect) + (CGRectGetWidth(rect)  - width)  / 2.f,
                         CGRectGetMinY(rect) + (CGRectGetHeight(rect) - height) / 2.f)];
}

// check
//
//       /---------> degree = 90˚  |
//       |                         |      /----> topPointOffset = thick / √2
//   /---(----/----> thick         |    |<->|
//   |   |    |                    |    |  /b
//   |   |   d\e                   |    | /  \
//   |   |  / /                    |    a/    \
//  a/b  | / /                     |     \     \
//   \ \  / /                      |
//    \ \c /
//     \ -/--------> bottomHeight = thick * √2
//      \/
//      f     |
//      |<--->|
//         \-------> bottomMarginRight = height - topPointOffset
//
+ (UIBezierPath *)customBezierPathOfCheckSymbolWithRect:(CGRect)rect
                                                  scale:(CGFloat)scale
                                                  thick:(CGFloat)thick {
    CGFloat height, width;
    // height : width = 32 : 25
    if (CGRectGetHeight(rect) > CGRectGetWidth(rect)) {
        height = CGRectGetHeight(rect) * scale;
        width  = height * 32.f / 25.f;
    }
    else {
        width  = CGRectGetWidth(rect) * scale;
        height = width * 25.f / 32.f;
    }
    
    CGFloat topPointOffset    = thick / sqrt(2.f);
    CGFloat bottomHeight      = thick * sqrt(2.f);
    CGFloat bottomMarginRight = height - topPointOffset;
    CGFloat bottomMarginLeft  = width - bottomMarginRight;
    
    CGPoint offsetPoint =
    CGPointMake(CGRectGetMinX(rect) + (CGRectGetWidth(rect)  - width)  / 2.f,
                CGRectGetMinY(rect) + (CGRectGetHeight(rect) - height) / 2.f);
    
    UIBezierPath * path = [self bezierPath];
    [path moveToPoint:
     CGPointWithOffset(CGPointMake(0.f, height - bottomMarginLeft), offsetPoint)];                             // a
    [path addLineToPoint:
     CGPointWithOffset(CGPointMake(topPointOffset, height - bottomMarginLeft - topPointOffset), offsetPoint)]; // b
    [path addLineToPoint:
     CGPointWithOffset(CGPointMake(bottomMarginLeft, height - bottomHeight), offsetPoint)];                    // c
    [path addLineToPoint:
     CGPointWithOffset(CGPointMake(width - topPointOffset, 0.f), offsetPoint)];                                // d
    [path addLineToPoint:
     CGPointWithOffset(CGPointMake(width, topPointOffset), offsetPoint)];                                      // e
    [path addLineToPoint:
     CGPointWithOffset(CGPointMake(bottomMarginLeft, height), offsetPoint)];                                   // f
    [path closePath];
    return path;
}

// cross
//
//                /---> thick |
//     b       d /            |      b
//   a/ \     / \e            |     /|\
//    \  \   /  /             |    / |_/----> offset = thick / √2
//     \  \c/  /              |  a/__|  \
//      \     /               |   \      \
//       \l f/                |___________________________________
//       /   \                |
//      /  i  \               |      c  /---> thick
//     /  / \  \              |      |\/
//   k/  /   \  \g            |   l  |_\f
//    \ /     \ /             |       \----> offset
//     j       h              |      i
//
+ (UIBezierPath *)customBezierPathOfCrossSymbolWithRect:(CGRect)rect
                                                  scale:(CGFloat)scale
                                                  thick:(CGFloat)thick {
    CGFloat height     = CGRectGetHeight(rect) * scale;
    CGFloat width      = CGRectGetWidth(rect)  * scale;
    CGFloat halfHeight = height / 2.f;
    CGFloat halfWidth  = width  / 2.f;
    CGFloat size       = height < width ? height : width;
    CGFloat offset     = thick / sqrt(2.f);
    
    CGPoint offsetPoint =
    CGPointMake(CGRectGetMinX(rect) + (CGRectGetWidth(rect)  - size) / 2.f,
                CGRectGetMinY(rect) + (CGRectGetHeight(rect) - size) / 2.f);
    
    UIBezierPath * path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointWithOffset(CGPointMake(0.f, offset), offsetPoint)];                       // a
    [path addLineToPoint:CGPointWithOffset(CGPointMake(offset, 0.f), offsetPoint)];                    // b
    [path addLineToPoint:CGPointWithOffset(CGPointMake(halfWidth, halfHeight - offset), offsetPoint)]; // c
    [path addLineToPoint:CGPointWithOffset(CGPointMake(width - offset, 0.f), offsetPoint)];            // d
    [path addLineToPoint:CGPointWithOffset(CGPointMake(width, offset), offsetPoint)];                  // e
    [path addLineToPoint:CGPointWithOffset(CGPointMake(halfWidth + offset, halfHeight), offsetPoint)]; // f
    [path addLineToPoint:CGPointWithOffset(CGPointMake(width, height - offset), offsetPoint)];         // g
    [path addLineToPoint:CGPointWithOffset(CGPointMake(width - offset, height), offsetPoint)];         // h
    [path addLineToPoint:CGPointWithOffset(CGPointMake(halfWidth, halfHeight + offset), offsetPoint)]; // i
    [path addLineToPoint:CGPointWithOffset(CGPointMake(offset, height), offsetPoint)];                 // j
    [path addLineToPoint:CGPointWithOffset(CGPointMake(0.f, height - offset), offsetPoint)];           // k
    [path addLineToPoint:CGPointWithOffset(CGPointMake(halfWidth - offset, halfHeight), offsetPoint)]; // l
    [path closePath];
    return path;
}

// arrow
//
//            /----> thick
// LEFT:    b-c                  RIGHT:   b-c
//         / /                             \ \
//       a/ /d                             a\ \d
//        \ \                               / /
//         \ \                             / /
//          f-e                           f-e
//
//
// UP:       a                   DOWN:  f      b
//          /\                          |\    /|
//         / d\                         | \  / |
//       f/ /\ \b                       e\ \/ /c
//       | /  \ |                         \ a/
//       |/    \|                          \/
//       e      c                           d
//
+ (UIBezierPath *)customBezierPathOfArrowSymbolWithRect:(CGRect)rect
                                                  scale:(CGFloat)scale
                                                  thick:(CGFloat)thick
                                              direction:(UIBezierPathArrowDirection)direction {
    CGFloat height     = CGRectGetHeight(rect) * scale;
    CGFloat width      = CGRectGetWidth(rect)  * scale;
    CGFloat halfHeight = height / 2.f;
    CGFloat halfWidth  = width  / 2.f;
    
    CGPoint offsetPoint =
    CGPointMake(CGRectGetMinX(rect) + (CGRectGetWidth(rect)  - width)  / 2.f,
                CGRectGetMinY(rect) + (CGRectGetHeight(rect) - height) / 2.f);
    
    UIBezierPath * path = [self bezierPath];
    if (direction == kUIBezierPathArrowDirectionLeft || direction == kUIBezierPathArrowDirectionRight) {
        if (direction == UISwipeGestureRecognizerDirectionLeft) {
            [path moveToPoint:CGPointWithOffset(CGPointMake(0.f, halfHeight), offsetPoint)];          // a
            [path addLineToPoint:CGPointWithOffset(CGPointMake(width - thick, 0.f), offsetPoint)];    // b
            [path addLineToPoint:CGPointWithOffset(CGPointMake(width, 0.f), offsetPoint)];            // c
            [path addLineToPoint:CGPointWithOffset(CGPointMake(thick, halfHeight), offsetPoint)];     // d
            [path addLineToPoint:CGPointWithOffset(CGPointMake(width, height), offsetPoint)];         // e
            [path addLineToPoint:CGPointWithOffset(CGPointMake(width - thick, height), offsetPoint)]; // f
        }
        else {
            [path moveToPoint:CGPointWithOffset(CGPointMake(width - thick, halfHeight), offsetPoint)]; // a
            [path addLineToPoint:CGPointWithOffset(CGPointMake(0.f, 0.f), offsetPoint)];               // b
            [path addLineToPoint:CGPointWithOffset(CGPointMake(thick, 0.f), offsetPoint)];             // c
            [path addLineToPoint:CGPointWithOffset(CGPointMake(width, halfHeight), offsetPoint)];      // d
            [path addLineToPoint:CGPointWithOffset(CGPointMake(thick, height), offsetPoint)];          // e
            [path addLineToPoint:CGPointWithOffset(CGPointMake(0.f, height), offsetPoint)];            // f
        }
    }
    else {
        if (direction == kUIBezierPathArrowDirectionUp) {
            [path moveToPoint:CGPointWithOffset(CGPointMake(halfWidth, 0.f), offsetPoint)];           // a
            [path addLineToPoint:CGPointWithOffset(CGPointMake(width, height - thick), offsetPoint)]; // b
            [path addLineToPoint:CGPointWithOffset(CGPointMake(width, height), offsetPoint)];         // c
            [path addLineToPoint:CGPointWithOffset(CGPointMake(halfWidth, thick), offsetPoint)];      // d
            [path addLineToPoint:CGPointWithOffset(CGPointMake(0.f, height), offsetPoint)];           // e
            [path addLineToPoint:CGPointWithOffset(CGPointMake(0.f, height - thick), offsetPoint)];   // f
        }
        else {
            [path moveToPoint:CGPointWithOffset(CGPointMake(halfWidth, height - thick), offsetPoint)]; // a
            [path addLineToPoint:CGPointWithOffset(CGPointMake(width, 0.f), offsetPoint)];             // b
            [path addLineToPoint:CGPointWithOffset(CGPointMake(width, thick), offsetPoint)];           // c
            [path addLineToPoint:CGPointWithOffset(CGPointMake(halfWidth, height), offsetPoint)];      // d
            [path addLineToPoint:CGPointWithOffset(CGPointMake(0.f, thick), offsetPoint)];             // e
            [path addLineToPoint:CGPointWithOffset(CGPointMake(0.f, 0.f), offsetPoint)];               // f
        }
    }
    [path closePath];
    return path;
}

// pencil
//
//       c  /---> thick
//       /\/
//      /  \d
//     /   /
//   b/   /
//   |   /
//  a|__/e
//     \--------> edgeWidth = thick / √2
//
+ (UIBezierPath *)customBezierPathOfPencilSymbolWithRect:(CGRect)rect
                                                   scale:(CGFloat)scale
                                                   thick:(CGFloat)thick {
    CGFloat height    = CGRectGetHeight(rect) * scale;
    CGFloat width     = CGRectGetWidth(rect)  * scale;
    CGFloat edgeWidth = thick / sqrt(2.f);
    
    CGPoint offsetPoint =
    CGPointMake(CGRectGetMinX(rect) + (CGRectGetWidth(rect)  - width)  / 2.f,
                CGRectGetMinY(rect) + (CGRectGetHeight(rect) - height) / 2.f);
    
    UIBezierPath * path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointWithOffset(CGPointMake(0.f, height), offsetPoint)];                // a
    [path addLineToPoint:CGPointWithOffset(CGPointMake(0.f, height - edgeWidth), offsetPoint)]; // b
    [path addLineToPoint:CGPointWithOffset(CGPointMake(width - edgeWidth, 0.f), offsetPoint)];  // c
    [path addLineToPoint:CGPointWithOffset(CGPointMake(width, edgeWidth), offsetPoint)];        // d
    [path addLineToPoint:CGPointWithOffset(CGPointMake(edgeWidth, height), offsetPoint)];       // e
    [path closePath];
    return path;
}

@end
