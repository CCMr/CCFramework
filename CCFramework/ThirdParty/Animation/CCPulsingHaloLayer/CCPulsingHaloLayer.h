//
//  CCPulsingHaloLayer.h
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

#import <QuartzCore/QuartzCore.h>

@interface CCPulsingHaloLayer : CAReplicatorLayer

/**
 *	The default value of this property is @c 60pt.
 */
@property (nonatomic, assign) CGFloat radius;

/**
 *	The default value of this property is @c 0.0.
 */
@property (nonatomic, assign) CGFloat fromValueForRadius;

/**
 *	The default value of this property is @c 0.45.
 */
@property (nonatomic, assign) CGFloat fromValueForAlpha;

/**
 *	The value of this property should be ranging from @c 0 to @c 1 (exclusive).
 *
 *	The default value of this property is @c 0.2.
 */
@property (nonatomic, assign) CGFloat keyTimeForHalfOpacity;

/**
 *	The animation duration in seconds.
 *
 *	The default value of this property is @c 3.
 */
@property (nonatomic, assign) NSTimeInterval animationDuration;

/**
 *	The animation interval in seconds.
 *
 *	The default value of this property is @c 0.
 */
@property (nonatomic, assign) NSTimeInterval pulseInterval;

/**
 *	The default value of this property is @c INFINITY.
 */
@property (nonatomic, assign) float repeatCount;

/**
 *	The default value of this property is @c YES.
 */
@property (nonatomic, assign) BOOL useTimingFunction;

/**
 *	The default value of this property is @c 1.
 */
@property (nonatomic, assign) NSInteger haloLayerNumber;

/**
 *	The animation delay in seconds.
 *
 *	The default value of this property is @c 1.
 */
@property (nonatomic, assign) NSTimeInterval startInterval;

- (instancetype)initWithRepeatCount:(float)repeatCount;

- (instancetype)initWithLayerNumber:(NSInteger)layerNumber;

@end
