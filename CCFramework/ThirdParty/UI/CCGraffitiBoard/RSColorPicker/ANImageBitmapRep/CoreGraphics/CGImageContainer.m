//
//  CGImageContainer.m
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

#import "CGImageContainer.h"

#if __has_feature(objc_arc) != 1

@implementation CGImageContainer

@synthesize image;

- (id)initWithImage:(CGImageRef)anImage
{
    if ((self = [super init])) {
        image = CGImageRetain(anImage);
    }
    return self;
}

+ (CGImageContainer *)imageContainerWithImage:(CGImageRef)anImage
{
    CGImageContainer *container = [(CGImageContainer *)[CGImageContainer alloc] initWithImage:anImage];
    return [container autorelease];
}

- (void)dealloc
{
    CGImageRelease(image);
    [super dealloc];
}

@end

#else

__attribute__((ns_returns_autoreleased))
id CGImageReturnAutoreleased(CGImageRef original)
{
    // CGImageRetain(original);
    return (__bridge id)original;
}

#endif
