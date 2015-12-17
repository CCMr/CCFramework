//
//  CCCircleBrush.m
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

#import "CCCircleBrush.h"


@implementation CCCircleBrush

- (CGRect)rectToDraw
{
    CGRect rect = super.rectToDraw;
    CGFloat radius = MIN(ABS(self.startPoint.x - self.currentPoint.x),
                         ABS(self.startPoint.y - self.currentPoint.y));
			 
    rect.size = CGSizeMake(radius, radius);
    
    CGFloat startX = self.startPoint.x, startY = self.startPoint.y;
    CGFloat currentX = self.currentPoint.x, currentY = self.currentPoint.y;
    
    // 对原点进行调整,让圆圈始终围绕起点变换大小位置.
    if (currentX < startX) {
        rect.origin.x += startX - currentX - radius;
    }
    if (currentY < startY) {
        rect.origin.y += startY - currentY - radius;
    }
    
    return rect;
}

- (CGRect)redrawRect
{
    // 调整重绘矩形范围,使之匹配实际的圆形.
    CGRect rect = super.redrawRect;
    CGSize size = rect.size;
    CGPoint origin = rect.origin;
    
    CGFloat startX = self.startPoint.x, startY = self.startPoint.y;
    CGFloat currentX = self.currentPoint.x, currentY = self.currentPoint.y;
    
    if (size.height > size.width) {
        if (currentY < startY) {
            origin.y += size.height - size.width;
        }
        size.height = size.width;
    }
    
    if (size.width > size.height) {
        if (currentX < startX) {
            origin.x += size.width - size.height;
        }
        size.width = size.height;
    }
    
    return (CGRect) { origin, size };
}

@end