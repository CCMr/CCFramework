//
//  CCPathButton.m
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

#import "CCPathButton.h"
#import "CCButton.h"
#import "CCProperty.h"

@implementation CCPathModel

- (instancetype)initWithTitle:(NSString *)title
                        Image:(UIImage *)image
{
    if (self = [super init]) {
        self.title = title;
        self.image = image;
    }
    return self;
}

@end

@interface CCPathButton ()

#pragma mark - Private Property

@property(strong, nonatomic) NSMutableArray *itemButtonImages;
@property(strong, nonatomic) NSMutableArray *itemButtonHighlightedImages;

@property(strong, nonatomic) UIImage *centerImage;
@property(strong, nonatomic) UIImage *centerHighlightedImage;

@property(assign, nonatomic) CGSize bloomSize;
@property(assign, nonatomic) CGSize foldedSize;

@property(assign, nonatomic) CGPoint foldCenter;
@property(assign, nonatomic) CGPoint bloomCenter;
@property(assign, nonatomic) CGPoint expandCenter;
@property(assign, nonatomic) CGPoint pathCenterButtonBloomCenter;

@property(strong, nonatomic) UIView *bottomView;
@property(strong, nonatomic) UIButton *pathCenterButton;
@property(strong, nonatomic) NSMutableArray *itemButtons;

@property(assign, nonatomic) SystemSoundID foldSound;
@property(assign, nonatomic) SystemSoundID bloomSound;
@property(assign, nonatomic) SystemSoundID selectedSound;

@property(assign, nonatomic, getter=isBloom) BOOL bloom;

@end

@implementation CCPathButton

#pragma mark - Initialization

- (instancetype)initWithCenterImage:(UIImage *)centerImage
                   highlightedImage:(UIImage *)centerHighlightedImage
{
    return [self initWithButtonFrame:CGRectZero
                         centerImage:centerImage
                    highlightedImage:centerHighlightedImage];
}

- (instancetype)initWithButtonFrame:(CGRect)centerButtonFrame
                        centerImage:(UIImage *)centerImage
                   highlightedImage:(UIImage *)centerHighlightedImage
{
    
    if (self = [super init]) {
        self.centerImage = centerImage;
        self.centerHighlightedImage = centerHighlightedImage;
        self.itemButtonImages = [[NSMutableArray alloc] init];
        self.itemButtonHighlightedImages = [[NSMutableArray alloc] init];
        self.itemButtons = [[NSMutableArray alloc] init];
        if (centerButtonFrame.size.width == 0 && centerButtonFrame.size.height == 0) {
            [self configureViewsLayoutWithButtonSize:self.centerImage.size];
        } else {
            [self configureViewsLayoutWithButtonSize:centerButtonFrame.size];
            self.ccButtonCenter = centerButtonFrame.origin;
        }
        
        _bloomDirection = kCCPathButtonBloomDirectionTop;
        _bloomSoundPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"bloom" ofType:@"caf"];
        _foldSoundPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"fold" ofType:@"caf"];
        _itemSoundPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"selected" ofType:@"caf"];
        
        _allowSounds = YES;
        
        _bottomViewColor = [UIColor blackColor];
        
        _allowSubItemRotation = YES;
        
        _basicDuration = 0.3f;
    }
    return self;
}

- (void)configureViewsLayoutWithButtonSize:(CGSize)centerButtonSize
{
    // Init some property only once
    //
    self.foldedSize = centerButtonSize;
    self.bloomSize = [UIScreen mainScreen].bounds.size;
    
    self.bloom = NO;
    self.bloomRadius = 105.0f;
    self.bloomAngel = 120.0f;
    
    // Configure the view's center, it will change after the frame folded or bloomed
    //
    self.foldCenter = CGPointMake(self.bloomSize.width / 2, self.bloomSize.height - 25.5f);
    self.bloomCenter = CGPointMake(self.bloomSize.width / 2, self.bloomSize.height / 2);
    
    // Configure the CCPathButton's origin frame
    //
    self.frame = CGRectMake(0, 0, self.foldedSize.width, self.foldedSize.height);
    self.center = self.foldCenter;
    _pathCenterButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.centerImage.size.width, self.centerImage.size.height)];
    [_pathCenterButton setImage:self.centerImage forState:UIControlStateNormal];
    //    [_pathCenterButton setImage:self.centerHighlightedImage forState:UIControlStateHighlighted];
    [_pathCenterButton addTarget:self action:@selector(centerButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    _pathCenterButton.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    [self addSubview:_pathCenterButton];
    
    // Configure bottom view
    //
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bloomSize.width * 2, self.bloomSize.height * 2)];
    _bottomView.backgroundColor = self.bottomViewColor;
    _bottomView.alpha = 0.0f;
}

#pragma mark - Configure Bottom View Color

- (void)setBottomViewColor:(UIColor *)bottomViewColor
{
    
    if (bottomViewColor) {
        _bottomView.backgroundColor = bottomViewColor;
    }
    _bottomViewColor = bottomViewColor;
}

#pragma mark - Configure Button Sound

- (void)setBloomSoundPath:(NSString *)bloomSoundPath
{
    
    _bloomSoundPath = bloomSoundPath;
    
    [self configureSounds];
}

- (void)setFoldSoundPath:(NSString *)foldSoundPath
{
    
    _foldSoundPath = foldSoundPath;
    
    [self configureSounds];
}

- (void)setItemSoundPath:(NSString *)itemSoundPath
{
    
    _itemSoundPath = itemSoundPath;
    
    [self configureSounds];
}

- (void)configureSounds
{
    
    // Configure bloom sound
    //
    NSURL *bloomSoundURL = [NSURL fileURLWithPath:self.bloomSoundPath];
    
    // Configure fold sound
    //
    NSURL *foldSoundURL = [NSURL fileURLWithPath:self.foldSoundPath];
    
    // Configure selected sound
    //
    NSURL *selectedSoundURL = [NSURL fileURLWithPath:self.itemSoundPath];
    
    if (self.allowSounds) {
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)bloomSoundURL, &_bloomSound);
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)foldSoundURL, &_foldSound);
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)selectedSoundURL, &_selectedSound);
    } else {
        AudioServicesDisposeSystemSoundID(_bloomSound);
        AudioServicesDisposeSystemSoundID(_foldSound);
        AudioServicesDisposeSystemSoundID(_selectedSound);
    }
}

#pragma mark - Configure Center Button Images

- (void)setCenterImage:(UIImage *)centerImage
{
    
    if (!centerImage) {
        NSLog(@"Load center image failed ... ");
        return;
    }
    _centerImage = centerImage;
}

- (void)setCenterHighlightedImage:(UIImage *)highlightedImage
{
    
    if (!highlightedImage) {
        NSLog(@"Load highted image failed ... ");
        return;
    }
    _centerHighlightedImage = highlightedImage;
}

#pragma mark - Configure Button's Center

- (void)setCcButtonCenter:(CGPoint)ccButtonCenter
{
    
    _ccButtonCenter = ccButtonCenter;
    
    // reset the CCPathButton's center
    //
    self.center = ccButtonCenter;
}

#pragma mark - Configure Expand Center Point

- (void)setPathCenterButtonBloomCenter:(CGPoint)centerButtonBloomCenter
{
    
    // Just set the bloom center once
    //
    if (_pathCenterButtonBloomCenter.x == 0) {
        _pathCenterButtonBloomCenter = centerButtonBloomCenter;
    }
    return;
}

- (void)setAllowSounds:(BOOL)soundsEnable
{
    _allowSounds = soundsEnable;
    
    [self configureSounds];
}

#pragma mark - Expand Status

- (BOOL)isBloom
{
    return _bloom;
}

#pragma mark - Center Button Delegate

- (void)centerButtonTapped
{
    self.isBloom ? [self pathCenterButtonFold] : [self pathCenterButtonBloom];
}

#pragma mark - Caculate The Item's End Point

- (CGPoint)createEndPointWithRadius:(CGFloat)itemExpandRadius
                           andAngel:(CGFloat)angel
{
    switch (self.bloomDirection) {
            
        case kCCPathButtonBloomDirectionTop:
            
            return CGPointMake(self.pathCenterButtonBloomCenter.x + cosf((angel + 1) * M_PI) * itemExpandRadius,
                               self.pathCenterButtonBloomCenter.y + sinf((angel + 1) * M_PI) * itemExpandRadius);
        case kCCPathButtonBloomDirectionBottomLeft:
            
            return CGPointMake(self.pathCenterButtonBloomCenter.x + cosf((angel + 0.25) * M_PI) * itemExpandRadius,
                               self.pathCenterButtonBloomCenter.y + sinf((angel + 0.25) * M_PI) * itemExpandRadius);
            
        case kCCPathButtonBloomDirectionLeft:
            
            return CGPointMake(self.pathCenterButtonBloomCenter.x + cosf((angel + 0.5) * M_PI) * itemExpandRadius,
                               self.pathCenterButtonBloomCenter.y + sinf((angel + 0.5) * M_PI) * itemExpandRadius);
            
        case kCCPathButtonBloomDirectionTopLeft:
            
            return CGPointMake(self.pathCenterButtonBloomCenter.x + cosf((angel + 0.75) * M_PI) * itemExpandRadius,
                               self.pathCenterButtonBloomCenter.y + sinf((angel + 0.75) * M_PI) * itemExpandRadius);
            
        case kCCPathButtonBloomDirectionBottom:
            
            return CGPointMake(self.pathCenterButtonBloomCenter.x + cosf(angel * M_PI) * itemExpandRadius,
                               self.pathCenterButtonBloomCenter.y + sinf(angel * M_PI) * itemExpandRadius);
            
        case kCCPathButtonBloomDirectionBottomRight:
            
            return CGPointMake(self.pathCenterButtonBloomCenter.x + cosf((angel + 1.75) * M_PI) * itemExpandRadius,
                               self.pathCenterButtonBloomCenter.y + sinf((angel + 1.75) * M_PI) * itemExpandRadius);
            
        case kCCPathButtonBloomDirectionRight:
            
            return CGPointMake(self.pathCenterButtonBloomCenter.x + cosf((angel + 1.5) * M_PI) * itemExpandRadius,
                               self.pathCenterButtonBloomCenter.y + sinf((angel + 1.5) * M_PI) * itemExpandRadius);
            
        case kCCPathButtonBloomDirectionTopRight:
            
            return CGPointMake(self.pathCenterButtonBloomCenter.x + cosf((angel + 1.25) * M_PI) * itemExpandRadius,
                               self.pathCenterButtonBloomCenter.y + sinf((angel + 1.25) * M_PI) * itemExpandRadius);
            
        default:
            
            NSAssert(self.bloomDirection, @"CCPathButtonError: An error occur when you configuring the bloom direction");
            return CGPointZero;
    }
}


#pragma mark - Center Button Fold

- (void)pathCenterButtonFold
{
    if ([_delegate respondsToSelector:@selector(willDismissCCPathButtonItems:)]) {
        [_delegate willDismissCCPathButtonItems:self];
    }
    
    if (self.allowSounds) {
        AudioServicesPlaySystemSound(self.foldSound);
    }
    
    CGFloat itemGapAngel = self.bloomAngel / (self.itemButtons.count - 1);
    CGFloat currentAngel = (180.0f - self.bloomAngel) / 2.0f;
    
    // Load item buttons from array
    //
    for (int i = 0; i < self.itemButtons.count; i++) {
        UIButton *itemButton = self.itemButtons[i];
        CGPoint farPoint = [self createEndPointWithRadius:self.bloomRadius + 5.0f andAngel:currentAngel / 180.0f];
        
        CAAnimationGroup *foldAnimation = [self foldAnimationFromPoint:itemButton.center withFarPoint:farPoint];
        
        [itemButton.layer addAnimation:foldAnimation forKey:@"foldAnimation"];
        itemButton.center = self.pathCenterButtonBloomCenter;
        
        currentAngel += itemGapAngel;
    }
    
    [self bringSubviewToFront:self.pathCenterButton];
    [self resizeToFoldedFrame];
    
    // CCPathButton Delegate
    //
    if ([_delegate respondsToSelector:@selector(didDismissCCPathButtonItems:)]) {
        [_delegate didDismissCCPathButtonItems:self];
    }
}

- (void)resizeToFoldedFrame
{
    
    if (self.allowCenterButtonRotation) {
        [UIView animateWithDuration:0.0618f * 3
                              delay:0.0618f * 2
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             //                             _pathCenterButton.transform = CGAffineTransformMakeRotation(0);
                             [_pathCenterButton setImage:_centerImage forState:UIControlStateNormal];
                         }
                         completion:nil];
    }
    
    [UIView animateWithDuration:0.1f
                          delay:self.basicDuration + 0.05f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         _bottomView.alpha = 0.0f;
                     }
                     completion:nil];
		  
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // Remove the button items from the superview
        //
        [self.itemButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        self.frame = CGRectMake(0, 0, self.foldedSize.width, self.foldedSize.height);
        self.center = _ccButtonCenter;
        
        self.pathCenterButton.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        
        [self.bottomView removeFromSuperview];
    });
    
    _bloom = NO;
}

- (CAAnimationGroup *)foldAnimationFromPoint:(CGPoint)endPoint
                                withFarPoint:(CGPoint)farPoint
{
    // 1.Configure rotation animation
    //
    CAKeyframeAnimation *rotationAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.values = @[ @(0), @(M_PI), @(M_PI * 2) ];
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotationAnimation.duration = self.basicDuration + 0.05f;
    
    // 2.Configure moving animation
    //
    CAKeyframeAnimation *movingAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    // Create moving path
    //
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, endPoint.x, endPoint.y);
    CGPathAddLineToPoint(path, NULL, farPoint.x, farPoint.y);
    CGPathAddLineToPoint(path, NULL, self.pathCenterButtonBloomCenter.x, self.pathCenterButtonBloomCenter.y);
    
    movingAnimation.keyTimes = @[ @(0.0f), @(0.75), @(1.0) ];
    
    movingAnimation.path = path;
    movingAnimation.duration = self.basicDuration + 0.05f;
    CGPathRelease(path);
    
    // 3.Merge animation together
    //
    CAAnimationGroup *animations = [CAAnimationGroup animation];
    animations.animations = (self.allowSubItemRotation ? @[ rotationAnimation, movingAnimation ] : @[ movingAnimation ]);
    animations.duration = self.basicDuration + 0.05f;
    
    return animations;
}

#pragma mark - Center Button Bloom

- (void)setBloomDirection:(kCCPathButtonBloomDirection)bloomDirection
{
    
    _bloomDirection = bloomDirection;
    
    if (bloomDirection == kCCPathButtonBloomDirectionBottomLeft |
        bloomDirection == kCCPathButtonBloomDirectionBottomRight |
        bloomDirection == kCCPathButtonBloomDirectionTopLeft |
        bloomDirection == kCCPathButtonBloomDirectionTopRight) {
        
        _bloomAngel = 90.0f;
    }
}

- (void)pathCenterButtonBloom
{
    
    // CCPathButton Delegate
    //
    if ([_delegate respondsToSelector:@selector(willPresentCCPathButtonItems:)]) {
        [_delegate willPresentCCPathButtonItems:self];
    }
    
    // Play bloom sound
    //
    if (self.allowSounds) {
        AudioServicesPlaySystemSound(self.bloomSound);
    }
    
    // Configure center button bloom
    //
    // 1. Store the current center point to centerButtonBloomCenter
    //
    self.pathCenterButtonBloomCenter = self.center;
    
    // 2. Resize the CCPathButton's frame
    //
    self.frame = CGRectMake(0, 0, self.bloomSize.width, self.bloomSize.height);
    self.center = CGPointMake(self.bloomSize.width / 2, self.bloomSize.height / 2);
    
    [self insertSubview:self.bottomView belowSubview:self.pathCenterButton];
    
    // 3. Excute the bottom view alpha animation
    //
    [UIView animateWithDuration:0.0618f * 3
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         _bottomView.alpha = 0.618f;
                     }
                     completion:nil];
		  
    // 4. Excute the center button rotation animation
    //
    if (self.allowCenterButtonRotation) {
        [UIView animateWithDuration:0.1575f
                         animations:^{
                             //                             _pathCenterButton.transform = CGAffineTransformMakeRotation(-0.75f * M_PI);
                             [_pathCenterButton setImage:_centerHighlightedImage forState:UIControlStateNormal];
                         }];
    }
    
    self.pathCenterButton.center = self.pathCenterButtonBloomCenter;
    
    // 5. Excute the bloom animation
    //
    CGFloat itemGapAngel = self.bloomAngel / (self.itemButtons.count - 1);
    CGFloat currentAngel = (180.0f - self.bloomAngel) / 2.0f;
    
    for (int i = 0; i < self.itemButtons.count; i++) {
        
        UIButton *pathItemButton = self.itemButtons[i];
        pathItemButton.tag = i;
        pathItemButton.transform = CGAffineTransformMakeTranslation(1, 1);
        pathItemButton.alpha = 1.0f;
        
        // 1. Add pathItem button to the view
        //
        
        pathItemButton.center = self.pathCenterButtonBloomCenter;
        
        [self insertSubview:pathItemButton belowSubview:self.pathCenterButton];
        
        // 2.Excute expand animation
        //
        CGPoint endPoint = [self createEndPointWithRadius:self.bloomRadius andAngel:currentAngel / 180.0f];
        CGPoint farPoint = [self createEndPointWithRadius:self.bloomRadius + 10.0f andAngel:currentAngel / 180.0f];
        CGPoint nearPoint = [self createEndPointWithRadius:self.bloomRadius - 5.0f andAngel:currentAngel / 180.0f];
        
        CAAnimationGroup *bloomAnimation = [self bloomAnimationWithEndPoint:endPoint
                                                                andFarPoint:farPoint
                                                               andNearPoint:nearPoint];
							 
        [pathItemButton.layer addAnimation:bloomAnimation
                                    forKey:@"bloomAnimation"];
        
        pathItemButton.center = endPoint;
        
        currentAngel += itemGapAngel;
    }
    
    // Configure the bloom status
    //
    _bloom = YES;
    
    // CCPathButton Delegate
    //
    if ([_delegate respondsToSelector:@selector(didPresentCCPathButtonItems:)]) {
        [_delegate didPresentCCPathButtonItems:self];
    }
}

- (CAAnimationGroup *)bloomAnimationWithEndPoint:(CGPoint)endPoint
                                     andFarPoint:(CGPoint)farPoint
                                    andNearPoint:(CGPoint)nearPoint
{
    
    // 1.Configure rotation animation
    //
    CAKeyframeAnimation *rotationAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.values = @[ @(0.0), @(-M_PI), @(-M_PI * 1.5), @(-M_PI * 2) ];
    rotationAnimation.duration = self.basicDuration;
    rotationAnimation.keyTimes = @[ @(0.0), @(0.3), @(0.6), @(1.0) ];
    
    // 2.Configure moving animation
    //
    CAKeyframeAnimation *movingAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    // Create moving path
    //
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, self.pathCenterButtonBloomCenter.x, self.pathCenterButtonBloomCenter.y);
    CGPathAddLineToPoint(path, NULL, farPoint.x, farPoint.y);
    CGPathAddLineToPoint(path, NULL, nearPoint.x, nearPoint.y);
    CGPathAddLineToPoint(path, NULL, endPoint.x, endPoint.y);
    
    movingAnimation.path = path;
    movingAnimation.keyTimes = @[ @(0.0), @(0.5), @(0.7), @(1.0) ];
    movingAnimation.duration = self.basicDuration;
    CGPathRelease(path);
    
    // 3.Merge two animation together
    //
    CAAnimationGroup *animations = [CAAnimationGroup animation];
    animations.animations = (self.allowSubItemRotation ? @[ movingAnimation, rotationAnimation ] : @[ movingAnimation ]);
    animations.duration = self.basicDuration;
    animations.delegate = self;
    
    return animations;
}

#pragma mark - Add PathButton Item

- (void)addPathItems:(NSArray *)pathItems
{
    for (CCPathModel *item in pathItems) {
        
        CCButton *itemButton = [[CCButton alloc] initWithFrame:CGRectMake(0, 0, item.image.size.width + 20, item.image.size.height)];
        [itemButton setImage:item.image forState:UIControlStateNormal];
        [itemButton setImage:item.image forState:UIControlStateHighlighted];
        [itemButton setTitle:item.title forState:UIControlStateNormal];
        [itemButton setTitle:item.title forState:UIControlStateHighlighted];
        [itemButton setTitleColor:cc_ColorRGB(84, 90, 100) forState:UIControlStateNormal];
        [itemButton setTitleColor:cc_ColorRGB(84, 90, 100) forState:UIControlStateHighlighted];
        [itemButton setStatus:CCAlignmentStatusTop];
        [itemButton addTarget:self action:@selector(itemButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.itemButtons addObject:itemButton];
    }
}

#pragma mark - CCPathButton Touch Event

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    [self pathCenterButtonFold];
}

#pragma mark - CCPathButton Item Delegate

- (void)itemButtonTapped:(UIButton *)itemButton
{
    
    if ([_delegate respondsToSelector:@selector(didClickItemButtonAtIndex:)]) {
        
        UIButton *selectedButton = self.itemButtons[itemButton.tag];
        
        if (self.allowSounds) {
            AudioServicesPlaySystemSound(self.selectedSound);
        }
        
        
        for (int i = 0; i < self.itemButtons.count; i++) {
            if (i == selectedButton.tag) {
                continue;
            }
            UIButton *unselectedButton = self.itemButtons[i];
            [UIView animateWithDuration:0.0618f * 2
                             animations:^{
                                 unselectedButton.transform = CGAffineTransformMakeScale(0, 0);
                             }];
        }
        
        [UIView animateWithDuration:0.0618f * 5
                         animations:^{
                             selectedButton.transform = CGAffineTransformMakeScale(3, 3);
                             selectedButton.alpha = 0.0f;
                         }
                         completion:^(BOOL finished) {
                             if ([_delegate respondsToSelector:@selector(didClickItemButtonAtIndex:)])
                                 [_delegate didClickItemButtonAtIndex:itemButton.tag];
                         }];
        
        if ([_delegate respondsToSelector:@selector(willDismissCCPathButtonItems:)])
            [_delegate willDismissCCPathButtonItems:self];
        
        
        [self resizeToFoldedFrame];
        
        if ([_delegate respondsToSelector:@selector(didDismissCCPathButtonItems:)])
            [_delegate didDismissCCPathButtonItems:self];
    }
}

#pragma mark - UIGestureRecognizer Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer NS_AVAILABLE_IOS(7_0)
{
    return YES;
}

@end
