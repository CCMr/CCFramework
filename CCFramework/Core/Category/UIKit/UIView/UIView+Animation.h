//
//  UIView+Animation.h
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

float radiansForDegrees(int degrees);

@interface UIView (Animation)

// Moves
- (void)moveTo:(CGPoint)destination
      duration:(float)secs
        option:(UIViewAnimationOptions)option;

- (void)moveTo:(CGPoint)destination
      duration:(float)secs
        option:(UIViewAnimationOptions)option
      delegate:(id)delegate
      callback:(SEL)method;

- (void)raceTo:(CGPoint)destination
  withSnapBack:(BOOL)withSnapBack;

- (void)raceTo:(CGPoint)destination
  withSnapBack:(BOOL)withSnapBack
      delegate:(id)delegate
      callback:(SEL)method;

// Transforms
- (void)rotate:(int)degrees
          secs:(float)secs
      delegate:(id)delegate
      callback:(SEL)method;

- (void)scale:(float)secs
            x:(float)scaleX
            y:(float)scaleY
     delegate:(id)delegate
     callback:(SEL)method;

- (void)spinClockwise:(float)secs;

- (void)spinCounterClockwise:(float)secs;

// Transitions
- (void)curlDown:(float)secs;
- (void)curlUpAndAway:(float)secs;
- (void)drainAway:(float)secs;

// Effects
- (void)changeAlpha:(float)newAlpha secs:(float)secs;
- (void)pulse:(float)secs continuously:(BOOL)continuously;

//add subview
- (void)addSubviewWithFadeAnimation:(UIView *)subview;


#pragma mark -
#pragma mark :. Draggable

/** The pan gestures that handles the view dragging
 *
 * @param panGesture The tint color of the blurred view. Set to nil to reset.
 */
@property(nonatomic) UIPanGestureRecognizer *panGesture;

/**
 A caging area such that the view can not be moved outside
 of this frame.
 
 If @c cagingArea is not @c CGRectZero, and @c cagingArea does not contain the
 view's frame then this does nothing (ie. if the bounds of the view extend the
 bounds of @c cagingArea).
 
 Optional. If not set, defaults to @c CGRectZero, which will result
 in no caging behavior.
 */
@property(nonatomic) CGRect cagingArea;

/**
 Restricts the area of the view where the drag action starts.
 
 Optional. If not set, defaults to self.view.
 */
@property(nonatomic) CGRect handle;

/**
 Restricts the movement along the X axis
 */
@property(nonatomic) BOOL shouldMoveAlongX;

/**
 Restricts the movement along the Y axis
 */
@property(nonatomic) BOOL shouldMoveAlongY;

/**
 Notifies when dragging started
 */
@property(nonatomic, copy) void (^draggingStartedBlock)();

/**
 Notifies when dragging ended
 */
@property(nonatomic, copy) void (^draggingEndedBlock)();

/** Enables the dragging
 *
 * Enables the dragging state of the view
 */
- (void)enableDragging;

/** Disable or enable the view dragging
 *
 * @param draggable The boolean that enables or disables the draggable state
 */
- (void)setDraggable:(BOOL)draggable;

#pragma mark -
#pragma mark :. Genie

typedef NS_ENUM(NSUInteger, CCRectEdge) {
    CCRectEdgeTop = 0,
    CCRectEdgeLeft = 1,
    CCRectEdgeBottom = 2,
    CCRectEdgeRight = 3
};

/*
 * After the animation has completed the view's transform will be changed to match the destination's rect, i.e.
 * view's transform (and thus the frame) will change, however the bounds and center will *not* change.
 */
- (void)genieInTransitionWithDuration:(NSTimeInterval)duration
                      destinationRect:(CGRect)destRect
                      destinationEdge:(CCRectEdge)destEdge
                           completion:(void (^)())completion;

/*
 * After the animation has completed the view's transform will be changed to CGAffineTransformIdentity.
 */
- (void)genieOutTransitionWithDuration:(NSTimeInterval)duration
                             startRect:(CGRect)startRect
                             startEdge:(CCRectEdge)startEdge
                            completion:(void (^)())completion;


#pragma mark -
#pragma mark :. Shake

typedef NS_ENUM(NSInteger, ShakeDirection) {
    ShakeDirectionHorizontal = 0,
    ShakeDirectionVertical
};

/** Shake the UIView
 *
 * Shake the view a default number of times
 */
- (void)shake;

/** Shake the UIView
 *
 * Shake the view a given number of times
 *
 * @param times The number of shakes
 * @param delta The width of the shake
 */
- (void)shake:(int)times withDelta:(CGFloat)delta;

/** Shake the UIView
 *
 * Shake the view a given number of times
 *
 * @param times The number of shakes
 * @param delta The width of the shake
 * @param handler A block object to be executed when the shake sequence ends
 */
- (void)shake:(int)times withDelta:(CGFloat)delta completion:(void( (^)()))handler;

/** Shake the UIView at a custom speed
 *
 * Shake the view a given number of times with a given speed
 *
 * @param times The number of shakes
 * @param delta The width of the shake
 * @param interval The duration of one shake
 */
- (void)shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval;

/** Shake the UIView at a custom speed
 *
 * Shake the view a given number of times with a given speed
 *
 * @param times The number of shakes
 * @param delta The width of the shake
 * @param interval The duration of one shake
 * @param handler A block object to be executed when the shake sequence ends
 */
- (void)shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval completion:(void( (^)()))handler;

/** Shake the UIView at a custom speed
 *
 * Shake the view a given number of times with a given speed
 *
 * @param times The number of shakes
 * @param delta The width of the shake
 * @param interval The duration of one shake
 * @param direction of the shake
 */
- (void)shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval shakeDirection:(ShakeDirection)shakeDirection;

/** Shake the UIView at a custom speed
 *
 * Shake the view a given number of times with a given speed, with a completion handler
 *
 * @param times The number of shakes
 * @param delta The width of the shake
 * @param interval The duration of one shake
 * @param direction of the shake
 * @param completion to be called when the view is done shaking
 */
- (void)shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval shakeDirection:(ShakeDirection)shakeDirection completion:(void (^)(void))completion;


#pragma mark -
#pragma mark :. Visuals

/*
 *  Sets a corners with radius, given stroke size & color
 */
- (void)cornerRadius:(CGFloat)radius
          strokeSize:(CGFloat)size
               color:(UIColor *)color;
/*
 *  Sets a corners
 */
- (void)setRoundedCorners:(UIRectCorner)corners
                   radius:(CGFloat)radius;

/*
 *  Draws shadow with properties
 */
- (void)shadowWithColor:(UIColor *)color
                 offset:(CGSize)offset
                opacity:(CGFloat)opacity
                 radius:(CGFloat)radius;

/*
 *  Removes from superview with fade
 */
- (void)removeFromSuperviewWithFadeDuration:(NSTimeInterval)duration;

/*
 *  Adds a subview with given transition & duration
 */
- (void)addSubview:(UIView *)view withTransition:(UIViewAnimationTransition)transition duration:(NSTimeInterval)duration;

/*
 *  Removes view from superview with given transition & duration
 */
- (void)removeFromSuperviewWithTransition:(UIViewAnimationTransition)transition duration:(NSTimeInterval)duration;

/*
 *  Rotates view by given angle. TimingFunction can be nil and defaults to kCAMediaTimingFunctionEaseInEaseOut.
 */
- (void)rotateByAngle:(CGFloat)angle
             duration:(NSTimeInterval)duration
          autoreverse:(BOOL)autoreverse
          repeatCount:(CGFloat)repeatCount
       timingFunction:(CAMediaTimingFunction *)timingFunction;

/*
 *  Moves view to point. TimingFunction can be nil and defaults to kCAMediaTimingFunctionEaseInEaseOut.
 */
- (void)moveToPoint:(CGPoint)newPoint
           duration:(NSTimeInterval)duration
        autoreverse:(BOOL)autoreverse
        repeatCount:(CGFloat)repeatCount
     timingFunction:(CAMediaTimingFunction *)timingFunction;

@end
