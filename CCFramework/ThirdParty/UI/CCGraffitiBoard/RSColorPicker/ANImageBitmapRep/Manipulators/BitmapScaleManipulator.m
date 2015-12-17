//
//  ScalableBitmapRep.m
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

#import "BitmapScaleManipulator.h"


@implementation BitmapScaleManipulator

- (void)setSize:(BMPoint)aSize
{
    CGContextRef newContext = [CGContextCreator newARGBBitmapContextWithSize:CGSizeMake(aSize.x, aSize.y)];
    CGImageRef image = [bitmapContext CGImage];
    CGContextDrawImage(newContext, CGRectMake(0, 0, aSize.x, aSize.y), image);
    [bitmapContext setContext:newContext];
    CGContextRelease(newContext);
}

- (void)setSizeFittingFrame:(BMPoint)aSize
{
    CGSize oldSize = CGSizeMake([bitmapContext bitmapSize].x, [bitmapContext bitmapSize].y);
    CGSize newSize = CGSizeMake(aSize.x, aSize.y);
    
    float wratio = newSize.width / oldSize.width;
    float hratio = newSize.height / oldSize.height;
    float scaleRatio;
    if (wratio < hratio) {
        scaleRatio = wratio;
    } else {
        scaleRatio = hratio;
    }
    scaleRatio = scaleRatio;
    
    CGSize newContentSize = CGSizeMake(oldSize.width * scaleRatio, oldSize.height * scaleRatio);
    CGImageRef image = [bitmapContext CGImage];
    CGContextRef newContext = [CGContextCreator newARGBBitmapContextWithSize:CGSizeMake(aSize.x, aSize.y)];
    CGContextDrawImage(newContext, CGRectMake(newSize.width / 2 - (newContentSize.width / 2),
                                              newSize.height / 2 - (newContentSize.height / 2),
                                              newContentSize.width, newContentSize.height),
                       image);
    [bitmapContext setContext:newContext];
    CGContextRelease(newContext);
}

- (void)setSizeFillingFrame:(BMPoint)aSize
{
    CGSize oldSize = CGSizeMake([bitmapContext bitmapSize].x, [bitmapContext bitmapSize].y);
    CGSize newSize = CGSizeMake(aSize.x, aSize.y);
    
    float wratio = newSize.width / oldSize.width;
    float hratio = newSize.height / oldSize.height;
    float scaleRatio;
    if (wratio > hratio) { // only difference from -setSizeFittingFrame:
        scaleRatio = wratio;
    } else {
        scaleRatio = hratio;
    }
    scaleRatio = scaleRatio;
    
    CGSize newContentSize = CGSizeMake(oldSize.width * scaleRatio, oldSize.height * scaleRatio);
    CGImageRef image = [bitmapContext CGImage];
    CGContextRef newContext = [CGContextCreator newARGBBitmapContextWithSize:CGSizeMake(aSize.x, aSize.y)];
    CGContextDrawImage(newContext, CGRectMake(newSize.width / 2 - (newContentSize.width / 2),
                                              newSize.height / 2 - (newContentSize.height / 2),
                                              newContentSize.width, newContentSize.height),
                       image);
    [bitmapContext setContext:newContext];
    CGContextRelease(newContext);
}

@end
