//
//  CCAnimatedImage.h
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
#import "CCAnimatedImageView.h"

@protocol CCAnimatedImageDebugDelegate;

@interface CCAnimatedImage : NSObject

/**
 *  @author CC, 15-08-17
 *
 *  @brief  Guaranteed to be loaded; usually equivalent to `-imageLazilyCachedAtIndex:0`
 *
 *  @since <#1.0#>
 */
@property (nonatomic, strong, readonly) UIImage *posterImage;

/**
 *  @author CC, 15-08-17
 *
 *  @brief  The `.posterImage`'s `.size`
 *
 *  @since <#1.0#>
 */
@property (nonatomic, assign, readonly) CGSize size;

/**
 *  @author CC, 15-08-17
 *
 *  @brief  0 means repeating the animation indefinitely
 *
 *  @since <#1.0#>
 */
@property (nonatomic, assign, readonly) NSUInteger loopCount;

/**
 *  @author CC, 15-08-17
 *
 *  @brief  Of type `NSTimeInterval` boxed in `NSNumber`s
 *
 *  @since <#1.0#>
 */
@property (nonatomic, strong, readonly) NSArray *delayTimes;

/**
 *  @author CC, 15-08-17
 *
 *  @brief  Number of valid frames; equal to `[.delayTimes count]`
 *
 *  @since <#1.0#>
 */
@property (nonatomic, assign, readonly) NSUInteger frameCount;

/**
 *  @author CC, 15-08-17
 *
 *  @brief  Current size of intelligently chosen buffer window; can range in the interval [1..frameCount]
 *
 *  @since <#1.0#>
 */
@property (nonatomic, assign, readonly) NSUInteger frameCacheSizeCurrent;

/**
 *  @author CC, 15-08-17
 *
 *  @brief  Allow to cap the cache size; 0 means no specific limit (default)
 *
 *  @since <#1.0#>
 */
@property (nonatomic, assign) NSUInteger frameCacheSizeMax;

/**
 *  @author CC, 15-08-17
 *
 *  @brief  Intended to be called from main thread synchronously; will return immediately.
 *          If the result isn't cached, will return `nil`; the caller should then pause playback, not increment frame counter and keep polling.
 *          After an initial loading time, depending on `frameCacheSize`, frames should be available immediately from the cache.
 *
 *  @param index <#index description#>
 *
 *  @return <#return value description#>
 *
 *  @since <#1.0#>
 */
- (UIImage *)imageLazilyCachedAtIndex:(NSUInteger)index;

/**
 *  @author CC, 15-08-17
 *
 *  @brief  Pass either a `UIImage` or an `FLAnimatedImage` and get back its size
 *
 *  @param image <#image description#>
 *
 *  @return <#return value description#>
 *
 *  @since <#1.0#>
 */
+ (CGSize)sizeForImage:(id)image;

/**
 *  @author CC, 15-08-17
 *
 *  @brief  Designated initializer
 *          On success, returns a new `FLAnimatedImage` with all fields populated, on failure returns `nil` and an error will be logged.
 *
 *  @param data <#data description#>
 *
 *  @return <#return value description#>
 *
 *  @since <#1.0#>
 */
- (instancetype)initWithAnimatedGIFData:(NSData *)data;

/**
 *  @author CC, 15-08-17
 *
 *  @brief  The data the receiver was initialized with; read-only
 *
 *  @since <#1.0#>
 */
@property (nonatomic, strong, readonly) NSData *data;

#if DEBUG
/**
 *  @author CC, 15-08-17
 *
 *  @brief  Only intended to report internal state for debugging
 *
 *  @since <#1.0#>
 */
@property (nonatomic, weak) id<CCAnimatedImageDebugDelegate> debug_delegate;
#endif

@end


@interface CCWeakProxy : NSProxy

+ (instancetype)weakProxyForObject:(id)targetObject;

@end


#if DEBUG
@protocol CCAnimatedImageDebugDelegate <NSObject>

@optional

- (void)debug_animatedImage:(CCAnimatedImage *)animatedImage didUpdateCachedFrames:(NSIndexSet *)indexesOfFramesInCache;
- (void)debug_animatedImage:(CCAnimatedImage *)animatedImage didRequestCachedFrame:(NSUInteger)index;
- (CGFloat)debug_animatedImagePredrawingSlowdownFactor:(CCAnimatedImage *)animatedImage;

@end
#endif

