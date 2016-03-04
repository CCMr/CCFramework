//
//  UIView+Animation.m
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

#import "UIView+Animation.h"
#import <objc/runtime.h>

@implementation UIView (Animation)

#pragma mark -
#pragma mark :. Animation

// Very helpful function
float radiansForDegrees(int degrees)
{
    return degrees * M_PI / 180;
}

- (void)moveTo:(CGPoint)destination duration:(float)secs option:(UIViewAnimationOptions)option
{
    [self moveTo:destination duration:secs option:option delegate:nil callback:nil];
}

- (void)moveTo:(CGPoint)destination duration:(float)secs option:(UIViewAnimationOptions)option delegate:(id)delegate callback:(SEL)method
{
    [UIView animateWithDuration:secs delay:0.0 options:option
                     animations:^{
                         self.frame = CGRectMake(destination.x,destination.y, self.frame.size.width, self.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         if (delegate != nil) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                             [delegate performSelector:method];
#pragma clang diagnostic pop
                             
                         }
                     }];
}

- (void)raceTo:(CGPoint)destination withSnapBack:(BOOL)withSnapBack
{
    [self raceTo:destination withSnapBack:withSnapBack delegate:nil callback:nil];
}

- (void)raceTo:(CGPoint)destination withSnapBack:(BOOL)withSnapBack delegate:(id)delegate callback:(SEL)method
{
    CGPoint stopPoint = destination;
    if (withSnapBack) {
        // Determine our stop point, from which we will "snap back" to the final destination
        int diffx = destination.x - self.frame.origin.x;
        int diffy = destination.y - self.frame.origin.y;
        if (diffx < 0) {
            // Destination is to the left of current position
            stopPoint.x -= 10.0;
        } else if (diffx > 0) {
            stopPoint.x += 10.0;
        }
        if (diffy < 0) {
            // Destination is to the left of current position
            stopPoint.y -= 10.0;
        } else if (diffy > 0) {
            stopPoint.y += 10.0;
        }
    }
    
    // Do the animation
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.frame = CGRectMake(stopPoint.x, stopPoint.y, self.frame.size.width, self.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         if (withSnapBack) {
                             [UIView animateWithDuration:0.1 
                                                   delay:0.0 
                                                 options:UIViewAnimationOptionCurveLinear
                                              animations:^{
                                                  self.frame = CGRectMake(destination.x, destination.y, self.frame.size.width, self.frame.size.height);
                                              }
                                              completion:^(BOOL finished) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                                                  [delegate performSelector:method];
#pragma clang diagnostic pop
                                                  
                                              }];
                         } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                             [delegate performSelector:method];
#pragma clang diagnostic pop
                         }
                     }];
}


#pragma mark :. Transforms

- (void)rotate:(int)degrees secs:(float)secs delegate:(id)delegate callback:(SEL)method
{
    [UIView animateWithDuration:secs
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.transform = CGAffineTransformRotate(self.transform, radiansForDegrees(degrees));
                     }
                     completion:^(BOOL finished) { 
                         if (delegate != nil) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                             [delegate performSelector:method];
#pragma clang diagnostic pop
                         }
                     }];
}

- (void)scale:(float)secs x:(float)scaleX y:(float)scaleY delegate:(id)delegate callback:(SEL)method
{
    [UIView animateWithDuration:secs
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.transform = CGAffineTransformScale(self.transform, scaleX, scaleY);
                     }
                     completion:^(BOOL finished) { 
                         if (delegate != nil) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                             [delegate performSelector:method];
#pragma clang diagnostic pop
                         }
                     }];
}

- (void)spinClockwise:(float)secs
{
    [UIView animateWithDuration:secs / 4
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.transform = CGAffineTransformRotate(self.transform, radiansForDegrees(90));
                     }
                     completion:^(BOOL finished) { 
                         [self spinClockwise:secs];
                     }];
}

- (void)spinCounterClockwise:(float)secs
{
    [UIView animateWithDuration:secs / 4
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.transform = CGAffineTransformRotate(self.transform, radiansForDegrees(270));
                     }
                     completion:^(BOOL finished) { 
                         [self spinCounterClockwise:secs];
                     }];
}


#pragma mark :. Transitions

- (void)curlDown:(float)secs
{
    [UIView transitionWithView:self duration:secs
                       options:UIViewAnimationOptionTransitionCurlDown
                    animations:^{ [self setAlpha:1.0];
                    }
                    completion:nil];
}

- (void)curlUpAndAway:(float)secs
{
    [UIView transitionWithView:self duration:secs
                       options:UIViewAnimationOptionTransitionCurlUp
                    animations:^{ [self setAlpha:0];
                    }
                    completion:nil];
}

- (void)drainAway:(float)secs
{
    self.tag = 20;
    [NSTimer scheduledTimerWithTimeInterval:secs / 50 target:self selector:@selector(drainTimer:) userInfo:nil repeats:YES];
}

- (void)drainTimer:(NSTimer *)timer
{
    CGAffineTransform trans = CGAffineTransformRotate(CGAffineTransformScale(self.transform, 0.9, 0.9), 0.314);
    self.transform = trans;
    self.alpha = self.alpha * 0.98;
    self.tag = self.tag - 1;
    if (self.tag <= 0) {
        [timer invalidate];
        [self removeFromSuperview];
    }
}

#pragma mark :. Effects

- (void)changeAlpha:(float)newAlpha secs:(float)secs
{
    [UIView animateWithDuration:secs
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.alpha = newAlpha;
                     }
                     completion:nil];
}

- (void)pulse:(float)secs continuously:(BOOL)continuously
{
    [UIView animateWithDuration:secs / 2
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         // Fade out, but not completely
                         self.alpha = 0.3;
                     }
                     completion:^(BOOL finished) { 
                         [UIView animateWithDuration:secs/2 
                                               delay:0.0 
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              // Fade in
                                              self.alpha = 1.0;
                                          }
                                          completion:^(BOOL finished) { 
                                              if (continuously) {
                                                  [self pulse:secs continuously:continuously];
                                              }
                                          }];
                     }];
}
#pragma mark :. add subview

- (void)addSubviewWithFadeAnimation:(UIView *)subview
{
    
    CGFloat finalAlpha = subview.alpha;
    
    subview.alpha = 0.0;
    [self addSubview:subview];
    [UIView animateWithDuration:0.2 animations:^{
        subview.alpha = finalAlpha;
    }];
}


#pragma mark -
#pragma mark :. Draggable

- (void)setPanGesture:(UIPanGestureRecognizer *)panGesture
{
    objc_setAssociatedObject(self, @selector(panGesture), panGesture, OBJC_ASSOCIATION_RETAIN);
}

- (UIPanGestureRecognizer *)panGesture
{
    return objc_getAssociatedObject(self, @selector(panGesture));
}

- (void)setCagingArea:(CGRect)cagingArea
{
    if (CGRectEqualToRect(cagingArea, CGRectZero) ||
        CGRectContainsRect(cagingArea, self.frame)) {
        NSValue *cagingAreaValue = [NSValue valueWithCGRect:cagingArea];
        objc_setAssociatedObject(self, @selector(cagingArea), cagingAreaValue, OBJC_ASSOCIATION_RETAIN);
    }
}

- (CGRect)cagingArea
{
    NSValue *cagingAreaValue = objc_getAssociatedObject(self, @selector(cagingArea));
    return [cagingAreaValue CGRectValue];
}

- (void)setHandle:(CGRect)handle
{
    CGRect relativeFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if (CGRectContainsRect(relativeFrame, handle)) {
        NSValue *handleValue = [NSValue valueWithCGRect:handle];
        objc_setAssociatedObject(self, @selector(handle), handleValue, OBJC_ASSOCIATION_RETAIN);
    }
}

- (CGRect)handle
{
    NSValue *handleValue = objc_getAssociatedObject(self, @selector(handle));
    return [handleValue CGRectValue];
}

- (void)setShouldMoveAlongY:(BOOL)newShould
{
    NSNumber *shouldMoveAlongYBool = [NSNumber numberWithBool:newShould];
    objc_setAssociatedObject(self, @selector(shouldMoveAlongY), shouldMoveAlongYBool, OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)shouldMoveAlongY
{
    NSNumber *moveAlongY = objc_getAssociatedObject(self, @selector(shouldMoveAlongY));
    return (moveAlongY) ? [moveAlongY boolValue] : YES;
}

- (void)setShouldMoveAlongX:(BOOL)newShould
{
    NSNumber *shouldMoveAlongXBool = [NSNumber numberWithBool:newShould];
    objc_setAssociatedObject(self, @selector(shouldMoveAlongX), shouldMoveAlongXBool, OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)shouldMoveAlongX
{
    NSNumber *moveAlongX = objc_getAssociatedObject(self, @selector(shouldMoveAlongX));
    return (moveAlongX) ? [moveAlongX boolValue] : YES;
}

- (void)setDraggingStartedBlock:(void (^)())draggingStartedBlock
{
    objc_setAssociatedObject(self, @selector(draggingStartedBlock), draggingStartedBlock, OBJC_ASSOCIATION_RETAIN);
}

- (void (^)())draggingStartedBlock
{
    return objc_getAssociatedObject(self, @selector(draggingStartedBlock));
}

- (void)setDraggingEndedBlock:(void (^)())draggingEndedBlock
{
    objc_setAssociatedObject(self, @selector(draggingEndedBlock), draggingEndedBlock, OBJC_ASSOCIATION_RETAIN);
}

- (void (^)())draggingEndedBlock
{
    return objc_getAssociatedObject(self, @selector(draggingEndedBlock));
}

- (void)handlePan:(UIPanGestureRecognizer *)sender
{
    // Check to make you drag from dragging area
    CGPoint locationInView = [sender locationInView:self];
    if (!CGRectContainsPoint(self.handle, locationInView)) {
        return;
    }
    
    [self adjustAnchorPointForGestureRecognizer:sender];
    
    if (sender.state == UIGestureRecognizerStateBegan && self.draggingStartedBlock) {
        self.draggingStartedBlock();
    }
    
    if (sender.state == UIGestureRecognizerStateEnded && self.draggingEndedBlock) {
        self.draggingEndedBlock();
    }
    
    CGPoint translation = [sender translationInView:[self superview]];
    
    CGFloat newXOrigin = CGRectGetMinX(self.frame) + (([self shouldMoveAlongX]) ? translation.x : 0);
    CGFloat newYOrigin = CGRectGetMinY(self.frame) + (([self shouldMoveAlongY]) ? translation.y : 0);
    
    CGRect cagingArea = self.cagingArea;
    
    CGFloat cagingAreaOriginX = CGRectGetMinX(cagingArea);
    CGFloat cagingAreaOriginY = CGRectGetMinY(cagingArea);
    
    CGFloat cagingAreaRightSide = cagingAreaOriginX + CGRectGetWidth(cagingArea);
    CGFloat cagingAreaBottomSide = cagingAreaOriginY + CGRectGetHeight(cagingArea);
    
    if (!CGRectEqualToRect(cagingArea, CGRectZero)) {
        
        // Check to make sure the view is still within the caging area
        if (newXOrigin <= cagingAreaOriginX ||
            newYOrigin <= cagingAreaOriginY ||
            newXOrigin + CGRectGetWidth(self.frame) >= cagingAreaRightSide ||
            newYOrigin + CGRectGetHeight(self.frame) >= cagingAreaBottomSide) {
            
            // Don't move
            newXOrigin = CGRectGetMinX(self.frame);
            newYOrigin = CGRectGetMinY(self.frame);
        }
    }
    
    [self setFrame:CGRectMake(newXOrigin,
                              newYOrigin,
                              CGRectGetWidth(self.frame),
                              CGRectGetHeight(self.frame))];
    
    [sender setTranslation:(CGPoint) {0, 0 } inView:[self superview]];
}

- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = self;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}

- (void)setDraggable:(BOOL)draggable
{
    [self.panGesture setEnabled:draggable];
}

- (void)enableDragging
{
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.panGesture setMaximumNumberOfTouches:1];
    [self.panGesture setMinimumNumberOfTouches:1];
    [self.panGesture setCancelsTouchesInView:NO];
    [self setHandle:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addGestureRecognizer:self.panGesture];
}

#pragma mark -
#pragma mark :. Genie

/* Animation parameters
 *
 * Genie effect consists of two such subanimations: the curves subanimation and the slide subanimation.
 * There former one moves Bezier curves outlining the effect's shape, while the latter one slides
 * the subject view towards/from the destination/start rect. 
 
 * These parameters describe the percentages of progress at which the subanimations should start/end.
 * These values must be in range [0, 1]!
 *
 * Example: 
 * Assuming that duration of animation is set to 2 seconds then the curves subanimation will start
 * at 0.0 and will end at 0.8 seconds while the slide subanimation will start at 0.6 seconds and
 * will end at 2.0 seconds.
 */

static const double curvesAnimationStart = 0.0;
static const double curvesAnimationEnd = 0.4;
static const double slideAnimationStart = 0.3;
static const double slideAnimationEnd = 1.0;

/* Performance parameters
 *
 * Because the default linear interpolation of nontrivial CATransform3D causes them to act *wildly*
 * I've decided to use discrete animations, i.e. each frame is distinct and is calculated separately.
 * While this makes sure that animations behave correctly, it *may* cause some performance issues for
 * very long durations and/or large views.
 */

static const CGFloat kSliceSize = 10.0f; // height/width of a single slice
static const NSTimeInterval kFPS = 60.0; // assumed animation's FPS


/* Antialiasing parameter
 *
 * While there is a visible difference between 0.0 and 1.0 values in kRenderMargin constant, larger values
 * do not seem to provide any significant improvement in edges quality and will decrease performance.
 * The default value works great and you should change it only if you manage to convince yourself
 * that it does bring quality improvement.
 */

static const CGFloat kRenderMargin = 2.0;


#pragma mark :. Structs & enums boilerplate

#define isEdgeVertical(d) (!((d)&1))
#define isEdgeNegative(d) (((d)&2))
#define axisForEdge(d) ((CCAxis)isEdgeVertical(d))
#define perpAxis(d) ((CCAxis)(!(BOOL)d))

typedef NS_ENUM(NSInteger, CCAxis) {
    CCAxisX = 0,
    CCAxisY = 1
};

// It's not an ego issue that I wanted to have my own CGPoints, it's just that it's easier
// to access specific axis by treating point as two element array, therefore I'm using union.
// Moreover, CGFloat is a typedefed float, and floats have much lower precision, causing slices
// to misalign occasionaly. Using doubles completely (?) removed the issue.

typedef union CCPoint {
    struct {
        double x, y;
    };
    double v[2];
} CCPoint;

static inline CCPoint CCPointMake(double x, double y)
{
    CCPoint p;
    p.x = x;
    p.y = y;
    return p;
}

typedef union CCTrapezoid {
    struct {
        CCPoint a, b, c, d;
    };
    CCPoint v[4];
} CCTrapezoid;


typedef struct CCSegment {
    CCPoint a;
    CCPoint b;
} CCSegment;

static inline CCSegment CCSegmentMake(CCPoint a, CCPoint b)
{
    CCSegment s;
    s.a = a;
    s.b = b;
    return s;
}

typedef CCSegment CCBezierCurve;

static const int CCTrapezoidWinding[4][4] = {
    [CCRectEdgeTop] = {0, 1, 2, 3},
    [CCRectEdgeLeft] = {2, 0, 3, 1},
    [CCRectEdgeBottom] = {3, 2, 1, 0},
    [CCRectEdgeRight] = {1, 3, 0, 2},
};

#pragma mark :. publics

- (void)genieInTransitionWithDuration:(NSTimeInterval)duration
                      destinationRect:(CGRect)destRect
                      destinationEdge:(CCRectEdge)destEdge
                           completion:(void (^)())completion
{
    
    [self genieTransitionWithDuration:duration
                                 edge:destEdge
                      destinationRect:destRect
                              reverse:NO
                           completion:completion];
}

- (void)genieOutTransitionWithDuration:(NSTimeInterval)duration
                             startRect:(CGRect)startRect
                             startEdge:(CCRectEdge)startEdge
                            completion:(void (^)())completion
{
    [self genieTransitionWithDuration:duration
                                 edge:startEdge
                      destinationRect:startRect
                              reverse:YES
                           completion:completion];
}

#pragma mark :. privates


- (void)genieTransitionWithDuration:(NSTimeInterval)duration
                               edge:(CCRectEdge)edge
                    destinationRect:(CGRect)destRect
                            reverse:(BOOL)reverse
                         completion:(void (^)())completion
{
    assert(!CGRectIsNull(destRect));
    
    CCAxis axis = axisForEdge(edge);
    CCAxis pAxis = perpAxis(axis);
    
    self.transform = CGAffineTransformIdentity;
    
    UIImage *snapshot = [self renderSnapshotWithMarginForAxis:axis];
    NSArray *slices = [self sliceImage:snapshot toLayersAlongAxis:axis];
    
    // Bezier calculations
    CGFloat xInset = axis == CCAxisY ? -kRenderMargin : 0.0f;
    CGFloat yInset = axis == CCAxisX ? -kRenderMargin : 0.0f;
    
    CGRect marginedDestRect = CGRectInset(destRect, xInset * destRect.size.width / self.bounds.size.width, yInset * destRect.size.height / self.bounds.size.height);
    CGFloat endRectDepth = isEdgeVertical(edge) ? marginedDestRect.size.height : marginedDestRect.size.width;
    CCSegment aPoints = bezierEndPointsForTransition(edge, [self convertRect:CGRectInset(self.bounds, xInset, yInset) toView:self.superview]);
    
    CCSegment bEndPoints = bezierEndPointsForTransition(edge, marginedDestRect);
    CCSegment bStartPoints = aPoints;
    bStartPoints.a.v[axis] = bEndPoints.a.v[axis];
    bStartPoints.b.v[axis] = bEndPoints.b.v[axis];
    
    CCBezierCurve first = {aPoints.a, bStartPoints.a};
    CCBezierCurve second = {aPoints.b, bStartPoints.b};
    
    // View hierarchy setup
    
    NSString *sumKeyPath = isEdgeVertical(edge) ? @"@sum.bounds.size.height" : @"@sum.bounds.size.width";
    CGFloat totalSize = [[slices valueForKeyPath:sumKeyPath] floatValue];
    
    CGFloat sign = isEdgeNegative(edge) ? -1.0 : 1.0;
    
    if (sign * (aPoints.a.v[axis] - bEndPoints.a.v[axis]) > 0.0f) {
        
        
        NSLog(@"Genie Effect ERROR: The distance between %@ edge of animated view and %@ edge of %@ rect is incorrect. Animation will not be performed!", edgeDescription(edge), edgeDescription(edge), reverse ? @"star" : @"destination");
        if (completion) {
            completion();
        }
        return;
    } else if (sign * (aPoints.a.v[axis] + sign * totalSize - bEndPoints.a.v[axis]) > 0.0f) {
        NSLog(@"Genie Effect Warning: The %@ edge of animated view overlaps %@ edge of %@ rect. Glitches may occur.", edgeDescription((edge + 2) % 4), edgeDescription(edge), reverse ? @"start" : @"destination");
    }
    
    UIView *containerView = [[UIView alloc] initWithFrame:[self.superview bounds]];
    containerView.clipsToBounds = self.superview.clipsToBounds; // if superview does it then we should probably do it as well
    containerView.backgroundColor = [UIColor clearColor];
    [self.superview insertSubview:containerView belowSubview:self];
    
    NSMutableArray *transforms = [NSMutableArray arrayWithCapacity:[slices count]];
    
    for (CALayer *layer in slices) {
        [containerView.layer addSublayer:layer];
        
        // With 'Renders with edge antialiasing' = YES in info.plist the slices are
        // rendered with a border, this disables this making the UIView appear as supposed
        [layer setEdgeAntialiasingMask:0];
        
        [transforms addObject:[NSMutableArray array]];
    }
    
    BOOL previousHiddenState = self.hidden;
    self.hidden = YES; // hide self throught animation, slices will be shown instead
    
    // Animation frames
    
    NSInteger totalIter = duration * kFPS;
    double tSignShift = reverse ? -1.0 : 1.0;
    
    for (int i = 0; i < totalIter; i++) {
        
        double progress = ((double)i) / ((double)totalIter - 1.0);
        double t = tSignShift * (progress - 0.5) + 0.5;
        
        double curveP = progressOfSegmentWithinTotalProgress(curvesAnimationStart, curvesAnimationEnd, t);
        
        first.b.v[pAxis] = easeInOutInterpolate(curveP, bStartPoints.a.v[pAxis], bEndPoints.a.v[pAxis]);
        second.b.v[pAxis] = easeInOutInterpolate(curveP, bStartPoints.b.v[pAxis], bEndPoints.b.v[pAxis]);
        
        double slideP = progressOfSegmentWithinTotalProgress(slideAnimationStart, slideAnimationEnd, t);
        
        NSArray *trs = [self transformationsForSlices:slices
                                                 edge:edge
                                        startPosition:easeInOutInterpolate(slideP, first.a.v[axis], first.b.v[axis])
                                            totalSize:totalSize
                                          firstBezier:first
                                         secondBezier:second
                                       finalRectDepth:endRectDepth];
        
        [trs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [(NSMutableArray *)transforms[idx] addObject:obj];
        }];
    }
    
    // Animation firing
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        
        [containerView removeFromSuperview];
        
        CGSize startSize = self.frame.size;
        CGSize endSize = destRect.size;
        
        CGPoint startOrigin = self.frame.origin;
        CGPoint endOrigin = destRect.origin;
        
        if (! reverse) {
            CGAffineTransform transform = CGAffineTransformMakeTranslation(endOrigin.x - startOrigin.x, endOrigin.y - startOrigin.y); // move to destination
            transform = CGAffineTransformTranslate(transform, -startSize.width/2.0, -startSize.height/2.0); // move top left corner to origin
            transform = CGAffineTransformScale(transform, endSize.width/startSize.width, endSize.height/startSize.height); // scale
            transform = CGAffineTransformTranslate(transform, startSize.width/2.0, startSize.height/2.0); // move back
            
            self.transform = transform;
        }
        
        self.hidden = previousHiddenState;
        
        if (completion) {
            completion();
        }
    }];
    
    [slices enumerateObjectsUsingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
        
        CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        anim.duration = duration;
        anim.values = transforms[idx];
        anim.calculationMode = kCAAnimationDiscrete;
        anim.removedOnCompletion = NO;
        anim.fillMode = kCAFillModeForwards;
        [layer addAnimation:anim forKey:@"transform"];
    }];
    
    [CATransaction commit];
}


- (UIImage *)renderSnapshotWithMarginForAxis:(CCAxis)axis
{
    CGSize contextSize = self.frame.size;
    CGFloat xOffset = 0.0f;
    CGFloat yOffset = 0.0f;
    
    if (axis == CCAxisY) {
        xOffset = kRenderMargin;
        contextSize.width += 2.0 * kRenderMargin;
    } else {
        yOffset = kRenderMargin;
        contextSize.height += 2.0 * kRenderMargin;
    }
    
    UIGraphicsBeginImageContextWithOptions(contextSize, NO, 0.0); // if you want to see border added for antialiasing pass YES as second param
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, xOffset, yOffset);
    
    [self.layer renderInContext:context];
    
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshot;
}


- (NSArray *)sliceImage:(UIImage *)image toLayersAlongAxis:(CCAxis)axis
{
    CGFloat totalSize = axis == CCAxisY ? image.size.height : image.size.width;
    
    CCPoint origin = {0.0, 0.0};
    origin.v[axis] = kSliceSize;
    
    CGFloat scale = image.scale;
    CGSize sliceSize = axis == CCAxisY ? CGSizeMake(image.size.width, kSliceSize) : CGSizeMake(kSliceSize, image.size.height);
    
    NSInteger count = (NSInteger)ceilf(totalSize / kSliceSize);
    NSMutableArray *slices = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count; i++) {
        CGRect rect = {i * origin.x * scale, i * origin.y * scale, sliceSize.width * scale, sliceSize.height * scale};
        CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
        UIImage *sliceImage = [UIImage imageWithCGImage:imageRef
                                                  scale:image.scale
                                            orientation:image.imageOrientation];
        CGImageRelease(imageRef);
        CALayer *layer = [CALayer layer];
        layer.anchorPoint = CGPointZero;
        layer.bounds = CGRectMake(0.0, 0.0, sliceImage.size.width, sliceImage.size.height);
        layer.contents = (__bridge id)(sliceImage.CGImage);
        layer.contentsScale = image.scale;
        [slices addObject:layer];
    }
    
    return slices;
}


- (NSArray *)transformationsForSlices:(NSArray *)slices
                                 edge:(CCRectEdge)edge
                        startPosition:(CGFloat)startPosition
                            totalSize:(CGFloat)totalSize
                          firstBezier:(CCBezierCurve)first
                         secondBezier:(CCBezierCurve)second
                       finalRectDepth:(CGFloat)rectDepth
{
    NSMutableArray *transformations = [NSMutableArray arrayWithCapacity:[slices count]];
    
    CCAxis axis = axisForEdge(edge);
    
    CGFloat rectPartStart = first.b.v[axis];
    CGFloat sign = isEdgeNegative(edge) ? -1.0 : 1.0;
    
    assert(sign * (startPosition - rectPartStart) <= 0.0);
    
    __block CGFloat position = startPosition;
    __block CCTrapezoid trapezoid = {0};
    trapezoid.v[CCTrapezoidWinding[edge][0]] = bezierAxisIntersection(first, axis, position);
    trapezoid.v[CCTrapezoidWinding[edge][1]] = bezierAxisIntersection(second, axis, position);
    
    NSEnumerationOptions enumerationOptions = isEdgeNegative(edge) ? NSEnumerationReverse : 0;
    
    [slices enumerateObjectsWithOptions:enumerationOptions usingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
        
        CGFloat size = isEdgeVertical(edge) ? layer.bounds.size.height : layer.bounds.size.width;
        CGFloat endPosition = position + sign*size; // we're not interested in slices' origins since they will be moved around anyway
        
        double overflow = sign*(endPosition - rectPartStart);
        
        if (overflow <= 0.0f) { // slice is still in bezier part
            trapezoid.v[CCTrapezoidWinding[edge][2]] = bezierAxisIntersection(first, axis, endPosition);
            trapezoid.v[CCTrapezoidWinding[edge][3]] = bezierAxisIntersection(second, axis, endPosition);
        }
        else { // final rect part
            CGFloat shrunkSliceDepth = overflow*rectDepth/(double)totalSize; // how deep inside final rect "bottom" part of slice is
            
            trapezoid.v[CCTrapezoidWinding[edge][2]] = first.b;
            trapezoid.v[CCTrapezoidWinding[edge][2]].v[axis] += sign*shrunkSliceDepth;
            
            trapezoid.v[CCTrapezoidWinding[edge][3]] = second.b;
            trapezoid.v[CCTrapezoidWinding[edge][3]].v[axis] += sign*shrunkSliceDepth;
        }
        
        CATransform3D transform = [self transformRect:layer.bounds toTrapezoid:trapezoid];
        [transformations addObject:[NSValue valueWithCATransform3D:transform]];
        
        trapezoid.v[CCTrapezoidWinding[edge][0]] = trapezoid.v[CCTrapezoidWinding[edge][2]]; // next one starts where previous one ends
        trapezoid.v[CCTrapezoidWinding[edge][1]] = trapezoid.v[CCTrapezoidWinding[edge][3]];
        
        position = endPosition;
    }];
    
    if (isEdgeNegative(edge)) {
        return [[transformations reverseObjectEnumerator] allObjects];
    }
    
    return transformations;
}

// based on http://stackoverflow.com/a/12820877/558816
// X and Y is always assumed to be 0, that's why it's been dropped in the calculations
// All calculations are on doubles, to make sure that we get as much precsision as we can
// since even minor errors in transform matrix may cause major glitches
- (CATransform3D)transformRect:(CGRect)rect toTrapezoid:(CCTrapezoid)trapezoid
{
    
    double W = rect.size.width;
    double H = rect.size.height;
    
    double x1a = trapezoid.a.x;
    double y1a = trapezoid.a.y;
    
    double x2a = trapezoid.b.x;
    double y2a = trapezoid.b.y;
    
    double x3a = trapezoid.c.x;
    double y3a = trapezoid.c.y;
    
    double x4a = trapezoid.d.x;
    double y4a = trapezoid.d.y;
    
    double y21 = y2a - y1a,
	   y32 = y3a - y2a,
	   y43 = y4a - y3a,
	   y14 = y1a - y4a,
	   y31 = y3a - y1a,
	   y42 = y4a - y2a;
	   
	   
    double a = -H * (x2a * x3a * y14 + x2a * x4a * y31 - x1a * x4a * y32 + x1a * x3a * y42);
    double b = W * (x2a * x3a * y14 + x3a * x4a * y21 + x1a * x4a * y32 + x1a * x2a * y43);
    double c = -H * W * x1a * (x4a * y32 - x3a * y42 + x2a * y43);
    
    double d = H * (-x4a * y21 * y3a + x2a * y1a * y43 - x1a * y2a * y43 - x3a * y1a * y4a + x3a * y2a * y4a);
    double e = W * (x4a * y2a * y31 - x3a * y1a * y42 - x2a * y31 * y4a + x1a * y3a * y42);
    double f = -(W * (x4a * (H * y1a * y32) - x3a * (H)*y1a * y42 + H * x2a * y1a * y43));
    
    double g = H * (x3a * y21 - x4a * y21 + (-x1a + x2a) * y43);
    double h = W * (-x2a * y31 + x4a * y31 + (x1a - x3a) * y42);
    double i = H * (W * (-(x3a * y2a) + x4a * y2a + x2a * y3a - x4a * y3a - x2a * y4a + x3a * y4a));
    
    const double kEpsilon = 0.0001;
    
    if (fabs(i) < kEpsilon) {
        i = kEpsilon * (i > 0 ? 1.0 : -1.0);
    }
    
    CATransform3D transform = {a / i, d / i, 0, g / i, b / i, e / i, 0, h / i, 0, 0, 1, 0, c / i, f / i, 0, 1.0};
    
    return transform;
}


#pragma mark :. C convinience functions

static CCSegment bezierEndPointsForTransition(CCRectEdge edge, CGRect endRect)
{
    switch (edge) {
        case CCRectEdgeTop:
            return CCSegmentMake(CCPointMake(CGRectGetMinX(endRect), CGRectGetMinY(endRect)), CCPointMake(CGRectGetMaxX(endRect), CGRectGetMinY(endRect)));
        case CCRectEdgeBottom:
            return CCSegmentMake(CCPointMake(CGRectGetMaxX(endRect), CGRectGetMaxY(endRect)), CCPointMake(CGRectGetMinX(endRect), CGRectGetMaxY(endRect)));
        case CCRectEdgeRight:
            return CCSegmentMake(CCPointMake(CGRectGetMaxX(endRect), CGRectGetMinY(endRect)), CCPointMake(CGRectGetMaxX(endRect), CGRectGetMaxY(endRect)));
        case CCRectEdgeLeft:
            return CCSegmentMake(CCPointMake(CGRectGetMinX(endRect), CGRectGetMaxY(endRect)), CCPointMake(CGRectGetMinX(endRect), CGRectGetMinY(endRect)));
    }
    
    assert(0); // should never happen
}

static inline CGFloat progressOfSegmentWithinTotalProgress(CGFloat a, CGFloat b, CGFloat t)
{
    assert(b > a);
    
    return MIN(MAX(0.0, (t - a) / (b - a)), 1.0);
}

static inline CGFloat easeInOutInterpolate(float t, CGFloat a, CGFloat b)
{
    assert(t >= 0.0 && t <= 1.0); // we don't want any other values
    
    CGFloat val = a + t * t * (3.0 - 2.0 * t) * (b - a);
    
    return b > a ? MAX(a, MIN(val, b)) : MAX(b, MIN(val, a)); // clamping, since numeric precision might bite here
}

static CCPoint bezierAxisIntersection(CCBezierCurve curve, CCAxis axis, CGFloat axisPos)
{
    assert((axisPos >= curve.a.v[axis] && axisPos <= curve.b.v[axis]) || (axisPos >= curve.b.v[axis] && axisPos <= curve.a.v[axis]));
    
    CCAxis pAxis = perpAxis(axis);
    
    CCPoint c1, c2;
    c1.v[pAxis] = curve.a.v[pAxis];
    c1.v[axis] = (curve.a.v[axis] + curve.b.v[axis]) / 2.0;
    
    c2.v[pAxis] = curve.b.v[pAxis];
    c2.v[axis] = (curve.a.v[axis] + curve.b.v[axis]) / 2.0;
    
    double t = (axisPos - curve.a.v[axis]) / (curve.b.v[axis] - curve.a.v[axis]); // first approximation - treating curve as linear segment
    
    const int kIterations = 3; // Newton-Raphson iterations
    
    for (int i = 0; i < kIterations; i++) {
        double nt = 1.0 - t;
        
        double f = nt * nt * nt * curve.a.v[axis] + 3.0 * nt * nt * t * c1.v[axis] + 3.0 * nt * t * t * c2.v[axis] + t * t * t * curve.b.v[axis] - axisPos;
        double df = -3.0 * (curve.a.v[axis] * nt * nt + c1.v[axis] * (-3.0 * t * t + 4.0 * t - 1.0) + t * (3.0 * c2.v[axis] * t - 2.0 * c2.v[axis] - curve.b.v[axis] * t));
        
        t -= f / df;
    }
    
    assert(t >= 0 && t <= 1.0);
    
    double nt = 1.0 - t;
    double intersection = nt * nt * nt * curve.a.v[pAxis] + 3.0 * nt * nt * t * c1.v[pAxis] + 3.0 * nt * t * t * c2.v[pAxis] + t * t * t * curve.b.v[pAxis];
    
    CCPoint ret;
    ret.v[axis] = axisPos;
    ret.v[pAxis] = intersection;
    
    return ret;
}

static inline NSString *edgeDescription(CCRectEdge edge)
{
    NSString *rectEdge[] = {
        [CCRectEdgeBottom] = @"bottom",
        [CCRectEdgeTop] = @"top",
        [CCRectEdgeRight] = @"right",
        [CCRectEdgeLeft] = @"left",
    };
    
    return rectEdge[edge];
}

#pragma mark -
#pragma mark :. Shake

- (void)shake
{
    [self shake:10
	     direction:1
	  currentTimes:0
	     withDelta:5
          speed:0.03
	shakeDirection:ShakeDirectionHorizontal
	    completion:nil];
}

- (void)shake:(int)times
    withDelta:(CGFloat)delta
{
    [self shake:times
	     direction:1
	  currentTimes:0
	     withDelta:delta
          speed:0.03
	shakeDirection:ShakeDirectionHorizontal
	    completion:nil];
}

- (void)shake:(int)times
    withDelta:(CGFloat)delta
   completion:(void (^)())handler
{
    [self shake:times
	     direction:1
	  currentTimes:0
	     withDelta:delta
          speed:0.03
	shakeDirection:ShakeDirectionHorizontal
	    completion:handler];
}

- (void)shake:(int)times
    withDelta:(CGFloat)delta
        speed:(NSTimeInterval)interval
{
    [self shake:times
	     direction:1
	  currentTimes:0
	     withDelta:delta
          speed:interval
	shakeDirection:ShakeDirectionHorizontal
	    completion:nil];
}

- (void)shake:(int)times
    withDelta:(CGFloat)delta
        speed:(NSTimeInterval)interval
   completion:(void (^)())handler
{
    [self shake:times
	     direction:1
	  currentTimes:0
	     withDelta:delta
          speed:interval
	shakeDirection:ShakeDirectionHorizontal
	    completion:handler];
}

- (void)shake:(int)times
    withDelta:(CGFloat)delta
        speed:(NSTimeInterval)interval
shakeDirection:(ShakeDirection)shakeDirection
{
    [self shake:times
	     direction:1
	  currentTimes:0
	     withDelta:delta
          speed:interval
	shakeDirection:shakeDirection
	    completion:nil];
}

- (void)shake:(int)times
    withDelta:(CGFloat)delta
        speed:(NSTimeInterval)interval
shakeDirection:(ShakeDirection)shakeDirection
   completion:(void (^)(void))completion
{
    [self shake:times
	     direction:1
	  currentTimes:0
	     withDelta:delta
          speed:interval
	shakeDirection:shakeDirection
	    completion:completion];
}

- (void)shake:(int)times
    direction:(int)direction
 currentTimes:(int)current
    withDelta:(CGFloat)delta
        speed:(NSTimeInterval)interval
shakeDirection:(ShakeDirection)shakeDirection
   completion:(void (^)(void))completionHandler
{
    [UIView animateWithDuration:interval animations:^{
        self.layer.affineTransform = (shakeDirection == ShakeDirectionHorizontal) ? CGAffineTransformMakeTranslation(delta * direction, 0) : CGAffineTransformMakeTranslation(0, delta * direction);
    } completion:^(BOOL finished) {
        if(current >= times) {
            [UIView animateWithDuration:interval animations:^{
                self.layer.affineTransform = CGAffineTransformIdentity;
            } completion:^(BOOL finished){
                if (completionHandler != nil) {
                    completionHandler();
                }
            }];
            return;
        }
        [self shake:(times - 1)
          direction:direction * -1
       currentTimes:current + 1
          withDelta:delta
              speed:interval
     shakeDirection:shakeDirection
         completion:completionHandler];
    }];
}

#pragma mark -
#pragma mark :. Visuals

// Degree -> Rad
#define degToRad(x) (M_PI * (x) / 180.0)

- (void)cornerRadius:(CGFloat)radius strokeSize:(CGFloat)size color:(UIColor *)color
{
    self.layer.cornerRadius = radius;
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = size;
}


- (void)setRoundedCorners:(UIRectCorner)corners radius:(CGFloat)radius
{
    CGRect rect = self.bounds;
    
    // Create the path
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(radius, radius)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = rect;
    maskLayer.path = maskPath.CGPath;
    
    // Set the newly created shape layer as the mask for the view's layer
    self.layer.mask = maskLayer;
}

- (void)shadowWithColor:(UIColor *)color
                 offset:(CGSize)offset
                opacity:(CGFloat)opacity
                 radius:(CGFloat)radius
{
    self.clipsToBounds = NO;
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOffset = offset;
    self.layer.shadowOpacity = opacity;
    self.layer.shadowRadius = radius;
}

- (void)removeFromSuperviewWithFadeDuration:(NSTimeInterval)duration
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
    self.alpha = 0.0;
    [UIView commitAnimations];
}

- (void)addSubview:(UIView *)subview withTransition:(UIViewAnimationTransition)transition duration:(NSTimeInterval)duration
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationTransition:transition forView:self cache:YES];
    [self addSubview:subview];
    [UIView commitAnimations];
}

- (void)removeFromSuperviewWithTransition:(UIViewAnimationTransition)transition duration:(NSTimeInterval)duration
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationTransition:transition forView:self.superview cache:YES];
    [self removeFromSuperview];
    [UIView commitAnimations];
}

- (void)rotateByAngle:(CGFloat)angle
             duration:(NSTimeInterval)duration
          autoreverse:(BOOL)autoreverse
          repeatCount:(CGFloat)repeatCount
       timingFunction:(CAMediaTimingFunction *)timingFunction
{
    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.toValue = [NSNumber numberWithFloat:degToRad(angle)];
    rotation.duration = duration;
    rotation.repeatCount = repeatCount;
    rotation.autoreverses = autoreverse;
    rotation.removedOnCompletion = NO;
    rotation.fillMode = kCAFillModeBoth;
    rotation.timingFunction = timingFunction != nil ? timingFunction : [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.layer addAnimation:rotation forKey:@"rotationAnimation"];
}

- (void)moveToPoint:(CGPoint)newPoint
           duration:(NSTimeInterval)duration
        autoreverse:(BOOL)autoreverse
        repeatCount:(CGFloat)repeatCount
     timingFunction:(CAMediaTimingFunction *)timingFunction
{
    CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position"];
    move.toValue = [NSValue valueWithCGPoint:newPoint];
    move.duration = duration;
    move.removedOnCompletion = NO;
    move.repeatCount = repeatCount;
    move.autoreverses = autoreverse;
    move.fillMode = kCAFillModeBoth;
    move.timingFunction = timingFunction != nil ? timingFunction : [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.layer addAnimation:move forKey:@"positionAnimation"];
}

@end
