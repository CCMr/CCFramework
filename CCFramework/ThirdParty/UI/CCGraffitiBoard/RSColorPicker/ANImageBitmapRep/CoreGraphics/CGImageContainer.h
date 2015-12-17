//
//  CGImageContainer.h
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

#import <Foundation/Foundation.h>
#import "TargetConditionals.h"

#if TARGET_OS_IPHONE
#import <CoreGraphics/CoreGraphics.h>
#elif TARGET_OS_MAC
#import <Quartz/Quartz.h>
#endif

#if __has_feature(objc_arc) != 1

@interface CGImageContainer : NSObject {
    CGImageRef image;
}

/**
 * The image that this container encloses.
 */
@property(readonly) CGImageRef image;

/**
 * Create a new image container with an image.
 * @param anImage Will be retained and enclosed in this class.
 * This object will be released when the CGImageContainer is
 * deallocated.  This can be nil.
 * @return The new image container, or nil if anImage is nil.
 */
- (id)initWithImage:(CGImageRef)anImage;

/**
 * Create a new image container with an image.
 * @param anImage Will be retained and enclosed in this class.
 * This object will be released when the CGImageContainer is
 * deallocated.  This can be nil.
 * @return The new image container, or nil if anImage is nil.
 * The image container returned will be autoreleased.
 */
+ (CGImageContainer *)imageContainerWithImage:(CGImageRef)anImage;

@end

#else

id CGImageReturnAutoreleased(CGImageRef original) __attribute__((ns_returns_autoreleased));

#endif
