//
//  GenerateOperation.m
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

#import "RSGenerateOperation.h"
//#import "ANImageBitmapRep.h"
#import "RSColorFunctions.h"

@implementation RSGenerateOperation

- (id)initWithDiameter:(CGFloat)diameter andPadding:(CGFloat)padding
{
    if ((self = [self init])) {
        _diameter = diameter;
        _padding = padding;
    }
    return self;
}

- (void)main
{
    BMPoint repSize = BMPointMake(_diameter, _diameter);
    
    // Create fresh
    ANImageBitmapRep *rep = [[ANImageBitmapRep alloc] initWithSize:repSize];
    
    CGFloat radius = _diameter / 2.0;
    CGFloat relRadius = radius - _padding;
    CGFloat relX, relY;
    
    int i, x, y;
    int arrSize = powf(_diameter, 2);
    size_t arrDataSize = sizeof(float) * arrSize;
    
    // data
    float *preComputeX = (float *)malloc(arrDataSize);
    float *preComputeY = (float *)malloc(arrDataSize);
    // output
    float *atan2Vals = (float *)malloc(arrDataSize);
    float *distVals = (float *)malloc(arrDataSize);
    
    i = 0;
    for (x = 0; x < _diameter; x++) {
        relX = x - radius;
        for (y = 0; y < _diameter; y++) {
            relY = radius - y;
            
            preComputeY[i] = relY;
            preComputeX[i] = relX;
            i++;
        }
    }
    
    // Use Accelerate.framework to compute the distance and angle of every
    // pixel from the center of the bitmap.
    vvatan2f(atan2Vals, preComputeY, preComputeX, &arrSize);
    vDSP_vdist(preComputeX, 1, preComputeY, 1, distVals, 1, arrSize);
    
    // Compution done, free these
    free(preComputeX);
    free(preComputeY);
    
    i = 0;
    for (x = 0; x < _diameter; x++) {
        for (y = 0; y < _diameter; y++) {
            CGFloat r_distance = fmin(distVals[i], relRadius);
            
            CGFloat angle = atan2Vals[i];
            if (angle < 0.0) angle = (2.0 * M_PI) + angle;
            
            CGFloat perc_angle = angle / (2.0 * M_PI);
            BMPixel thisPixel = RSPixelFromHSV(perc_angle, r_distance / relRadius, 1); // full brightness
            [rep setPixel:thisPixel atPoint:BMPointMake(x, y)];
            
            i++;
        }
    }
    
    // Bitmap generated, free these
    free(atan2Vals);
    free(distVals);
    
    self.bitmap = rep;
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return self.bitmap == nil;
}

- (BOOL)isFinished
{
    return !self.isExecuting;
}

@end
