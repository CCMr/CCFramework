//
//  CCTransformRefresh.m
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

#import "CCTransformRefresh.h"
#import <objc/message.h>
#import "UIScrollView+Additions.h"
#import "config.h"

// objc_msgSend
#define msgSend(...) ((void (*)(void *, SEL, UIView *))objc_msgSend)(__VA_ARGS__)
#define msgTarget(target) (__bridge void *)(target)

#define kCCTransformRefreshAnimationKey @"RotateAnimationKey"
NSString *const CCTransformRefreshContentOffset = @"contentOffset";
static const CGFloat criticalY = -90.f;

typedef enum {
    CCTransformRefreshStateNormal = 1,     // 普通状态
    CCTransformRefreshStateRefreshing = 2, // 正在刷新中的状态
    CCTransformRefreshStateWillRefreshing = 3
} CCTransformRefreshState;


@interface CCTransformRefresh ()

@property(nonatomic, assign) CCTransformRefreshState state;

@property(nonatomic, strong) CABasicAnimation *rotateAnimation;


@end

@implementation CCTransformRefresh

+ (instancetype)Transformheader:(NSString *)traImage
{
    CCTransformRefresh *transform = [CCTransformRefresh new];
    transform.center = CGPointMake(40, -30);
    return transform;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    self.backgroundColor = [UIColor clearColor];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:CCResourceImage(@"wechat_moment")];
    self.bounds = imageView.bounds;
    [self addSubview:imageView];
    
    _rotateAnimation = [[CABasicAnimation alloc] init];
    _rotateAnimation.keyPath = @"transform.rotation.z";
    _rotateAnimation.fromValue = @0;
    _rotateAnimation.toValue = @(M_PI * 2);
    _rotateAnimation.duration = 1.0;
    _rotateAnimation.repeatCount = MAXFLOAT;
}

- (void)setState:(CCTransformRefreshState)state
{
    _state = state;
    
    if (state == CCTransformRefreshStateRefreshing) {
        [self beginTransformRefreshing];
    }
}

- (void)beginTransformRefreshing
{
    if (self.state == CCTransformRefreshStateRefreshing) {
        [self.layer addAnimation:_rotateAnimation forKey:kCCTransformRefreshAnimationKey];
        // 回调
        if ([self.beginRefreshingTaget respondsToSelector:self.beginRefreshingAction]) {
            msgSend(msgTarget(self.beginRefreshingTaget), self.beginRefreshingAction, self);
        }
        
        if (self.beginRefreshingCallback) {
            self.beginRefreshingCallback();
        }
    } else {
        if (self.window) {
            self.state = CCTransformRefreshStateRefreshing;
        } else {
            _state = CCTransformRefreshStateRefreshing;
            [self setNeedsDisplay];
        }
    }
}

- (void)endTransformRefreshing
{
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self.layer removeAnimationForKey:kCCTransformRefreshAnimationKey];
        [UIView animateWithDuration:0.3 animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            self.state = CCTransformRefreshStateNormal;
        }];
    });
}

- (void)adjustStateWithContentOffset
{
    CGFloat currentOffsetY = self.scrollView.contentOffsetY;
    CGFloat rotateValue = currentOffsetY / 80.0 * M_PI;
    
    if (currentOffsetY < criticalY) {
        currentOffsetY = criticalY;
        
        if (self.scrollView.isDragging && self.state != CCTransformRefreshStateWillRefreshing) {
            self.state = CCTransformRefreshStateWillRefreshing;
        } else if (!self.scrollView.isDragging && self.state == CCTransformRefreshStateWillRefreshing) {
            self.state = CCTransformRefreshStateRefreshing;
        }
    }
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, 0, -currentOffsetY);
    transform = CGAffineTransformRotate(transform, rotateValue);
    
    self.transform = transform;
}

- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    [scrollView addObserver:self forKeyPath:CCTransformRefreshContentOffset options:NSKeyValueObservingOptionNew context:nil];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (!newSuperview) {
        [self.scrollView removeObserver:self forKeyPath:CCTransformRefreshContentOffset];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *, id> *)change context:(void *)context
{
    // 不能跟用户交互就直接返回
    if (!self.userInteractionEnabled || self.alpha <= 0.01 || self.hidden) return;
    
    // 如果正在刷新，直接返回
    if (self.state == CCTransformRefreshStateRefreshing) return;
    
    if ([CCTransformRefreshContentOffset isEqualToString:keyPath]) {
        [self adjustStateWithContentOffset];
    }
}


@end

