//
//  CCFlipImageView.m
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
#import "CCFlipNumberViewImageFactory.h"

#import "CCFlipImageView.h"

const NSTimeInterval CCFlipImageViewDefaultFlipDuration = 1.6;
static NSString *const CCFlipImageAnimationKey = @"CCFlipImageAnimationKey";

typedef NS_OPTIONS(NSUInteger, CCFlipAnimationState) {
    CCFlipAnimationStateFirstHalf,
    CCFlipAnimationStateSecondHalf
};

@interface CCFlipImageView ()

@property(nonatomic, assign) BOOL upscalingAllowed;
@property(nonatomic, assign) CGFloat animationDuration;
@property(nonatomic, assign) CCFlipAnimationState animationState;
@property(nonatomic, strong) NSArray *nextImages;

@property(nonatomic, strong) UIImageView *topImageView;
@property(nonatomic, strong) UIImageView *flipImageView;
@property(nonatomic, strong) UIImageView *bottomImageView;


@property(nonatomic, copy) CCFlipImageViewCompletionBlock completionBlock;

@end


@implementation CCFlipImageView

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        // setup view
        self.backgroundColor = [UIColor clearColor];
        self.autoresizesSubviews = NO;
        
        // default values
        _animationState = CCFlipAnimationStateFirstHalf;
        
        // images & frame
        [self initImagesAndFrames];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image;
{
    self = [self initWithFrame:(CGRect){CGPointZero, image.size}];
    if (self) {
        self.image = image;
    }
    return self;
}

- (void)initImagesAndFrames;
{
    // setup image views
    self.topImageView = [[UIImageView alloc] init];
    self.flipImageView = [[UIImageView alloc] init];
    self.bottomImageView = [[UIImageView alloc] init];
    
    // setup frames
    CGSize size = self.bounds.size;
    self.topImageView.frame = (CGRect){CGPointZero, {size.width, size.height / 2.0}};
    self.bottomImageView.frame = (CGRect){{0, size.height / 2.0}, {size.width, size.height / 2.0}};
    self.flipImageView.frame = (CGRect){CGPointZero, {size.width, size.height / 2.0}};
    
    // set z positions
    self.topImageView.layer.zPosition = -1;
    self.bottomImageView.layer.zPosition = -1;
    self.flipImageView.layer.zPosition = 0;
    
    // add image views
    [self addSubview:self.topImageView];
    [self addSubview:self.bottomImageView];
    [self addSubview:self.flipImageView];
    
    // hide flipview
    self.flipImageView.hidden = YES;
}

#pragma mark -
#pragma mark layout

- (CGSize)sizeThatFits:(CGSize)aSize;
{
    if (!self.topImageView.image) return aSize;
    
    CGSize imageSize = self.topImageView.image.size;
    
    CGFloat ratioW = aSize.width / aSize.height;
    CGFloat origRatioW = imageSize.width / (imageSize.height * 2);
    CGFloat origRatioH = (imageSize.height * 2) / imageSize.width;
    
    if (ratioW > origRatioW) {
        aSize.width = aSize.height * origRatioW;
    } else {
        aSize.height = aSize.width * origRatioH;
    }
    
    if (!self.upscalingAllowed) {
        aSize = [self sizeWithMaximumSize:aSize];
    }
    
    return aSize;
}

- (CGSize)sizeWithMaximumSize:(CGSize)size;
{
    if (!self.topImageView.image) return size;
    
    CGSize imageSize = self.topImageView.image.size;
    
    size.width = MIN(size.width, imageSize.width);
    size.height = MIN(size.height, imageSize.height * 2);
    return size;
}

- (void)setFrame:(CGRect)rect;
{
    rect.size = [self sizeThatFits:rect.size];
    [super setFrame:rect];
    
    // update imageView frames
    rect.origin = CGPointMake(0, 0);
    rect.size.height /= 2.0;
    self.topImageView.frame = rect;
    rect.origin.y += rect.size.height;
    self.bottomImageView.frame = rect;
    
    // update flip imageView frame
    [self updateFlipViewFrame];
    
    // reset Z distance
    [self setZDistance:self.frame.size.height * 3];
}

- (void)setZDistance:(NSUInteger)zDistance;
{
    _zDistance = zDistance;
    
    // setup 3d transform
    CATransform3D aTransform = CATransform3DIdentity;
    aTransform.m34 = -1.0 / zDistance;
    self.layer.sublayerTransform = aTransform;
}

#pragma mark value setter

- (void)setImage:(UIImage *)image;
{
    _image = image;
    if (!image) return;
    
    self.nextImages = [[CCFlipNumberViewImageFactory sharedInstance]
                       generateImagesFromImage:image];
    
    self.topImageView.image = self.nextImages[0];
    self.bottomImageView.image = self.nextImages[1];
}

- (void)setImageAnimated:(UIImage *)image;
{
    [self setImageAnimated:image
                  duration:CCFlipImageViewFlipDirectionDown
                completion:nil];
}

- (void)setImageAnimated:(UIImage *)image
              completion:(CCFlipImageViewCompletionBlock)completion;
{
    [self setImageAnimated:image
                  duration:CCFlipImageViewFlipDirectionDown
                completion:completion];
}

- (void)setImageAnimated:(UIImage *)image
                duration:(CGFloat)duration
              completion:(CCFlipImageViewCompletionBlock)completion;
{
    _image = image;
    if (!image) return;
    
    // update current images (in case animation isnt finished)
    self.topImageView.image = self.nextImages[0];
    self.bottomImageView.image = self.nextImages[1];
    
    // remove any running animation
    [self.flipImageView.layer removeAnimationForKey:CCFlipImageAnimationKey];
    
    // set animation parameter
    self.animationDuration = duration;
    self.completionBlock = completion;
    self.animationState = CCFlipAnimationStateFirstHalf;
    self.nextImages = [[CCFlipNumberViewImageFactory sharedInstance]
                       generateImagesFromImage:image];
    
    // animate
    [self runAnimation];
}

#pragma mark -
#pragma mark animation

- (void)runAnimation;
{
    [self updateFlipViewFrame];
    
    BOOL isTopDown = (self.flipDirection == CCFlipImageViewFlipDirectionDown);
    
    // setup animation
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.duration = self.animationDuration / 2.0;
    animation.delegate = self;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    // exchange images & setup animation
    if (self.animationState == CCFlipAnimationStateFirstHalf) {
        // remove any old animations
        [self.flipImageView.layer removeAllAnimations];
        
        // setup first animation half
        self.flipImageView.image = isTopDown ? self.topImageView.image : self.bottomImageView.image;
        self.topImageView.image = isTopDown ? self.nextImages[0] : self.topImageView.image;
        self.bottomImageView.image = isTopDown ? self.bottomImageView.image : self.nextImages[1];
        
        animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0.0, 1, 0, 0)];
        animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(isTopDown ? -M_PI_2 : M_PI_2, 1, 0, 0)];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    } else {
        // setup second animation half
        self.flipImageView.image = isTopDown ? self.nextImages[1] : self.nextImages[0];
        
        animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(isTopDown ? M_PI_2 : -M_PI_2, 1, 0, 0)];
        animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0.0, 1, 0, 0)];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    }
    
    // add/start animation
    [self.flipImageView.layer addAnimation:animation forKey:CCFlipImageAnimationKey];
    
    // show animated view
    self.flipImageView.hidden = NO;
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished
{
    if (!finished) {
        if (self.completionBlock) {
            CCFlipImageViewCompletionBlock block = self.completionBlock;
            self.completionBlock = nil;
            block(NO);
        }
        return;
    }
    
    if (self.animationState == CCFlipAnimationStateFirstHalf) {
        // do second animation step
        self.animationState = CCFlipAnimationStateSecondHalf;
        [self runAnimation];
    } else {
        // reset state
        self.animationState = CCFlipAnimationStateFirstHalf;
        
        // update images
        BOOL isTopDown = (self.flipDirection == CCFlipImageViewFlipDirectionDown);
        if (isTopDown) {
            self.bottomImageView.image = self.flipImageView.image;
        } else {
            self.topImageView.image = self.flipImageView.image;
        }
        
        // remove old animation
        [self.flipImageView.layer removeAnimationForKey:CCFlipImageAnimationKey];
        
        // hide animated view
        self.flipImageView.hidden = YES;
        
        // call completion block
        if (self.completionBlock) {
            CCFlipImageViewCompletionBlock block = self.completionBlock;
            self.completionBlock = nil;
            block(YES);
        }
    }
}

- (void)updateFlipViewFrame;
{
    BOOL isTopDown = (self.flipDirection == CCFlipImageViewFlipDirectionDown);
    if ((isTopDown && self.animationState == CCFlipAnimationStateFirstHalf) ||
        (!isTopDown && self.animationState == CCFlipAnimationStateSecondHalf)) {
        self.flipImageView.layer.anchorPoint = CGPointMake(0.5, 1.0);
        self.flipImageView.frame = self.topImageView.frame;
    } else {
        self.flipImageView.layer.anchorPoint = CGPointMake(0.5, 0.0);
        self.flipImageView.frame = self.bottomImageView.frame;
    }
}

@end
