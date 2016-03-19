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
#import "UIView+Frame.h"
#import <objc/message.h>
#import "UIScrollView+Additions.h"


// objc_msgSend
#define msgSend(...) ((void (*)(void *, SEL, UIView *))objc_msgSend)(__VA_ARGS__)
#define msgTarget(target) (__bridge void *)(target)

static CGFloat const kTransformRotateRate = 0.05 * M_PI;
const CGFloat CCTransformRefreshViewHeight = 25.0;
const CGFloat CCTransformRefreshFastAnimationDuration = 0.25;
const CGFloat CCTransformRefreshTop = 20.0;


NSString *const CCTransformRefreshContentOffset = @"contentOffset";

typedef enum {
    CCTransformRefreshStatePulling = 1,    // 松开就可以进行刷新的状态
    CCTransformRefreshStateNormal = 2,     // 普通状态
    CCTransformRefreshStateRefreshing = 3, // 正在刷新中的状态
    CCTransformRefreshStateWillRefreshing = 4
} CCTransformRefreshState;

@interface CCTransformRefresh ()

@property(nonatomic, assign) CCTransformRefreshState state;


@property(nonatomic, assign) BOOL canChangeFrame;

@property(nonatomic, strong) UIImageView *transformImage;
@property(nonatomic, strong) UIActivityIndicatorView *indicatorActivityView;
@property(nonatomic, assign) CGFloat currentOffset;
@property(nonatomic, assign) CGFloat beginOffset;

@end

@implementation CCTransformRefresh


+ (instancetype)Transformheader:(NSString *)traImage
{
    CCTransformRefresh *transform = [[CCTransformRefresh alloc] init];
    transform.transformImage.image = [UIImage imageNamed:traImage];
    return transform;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    frame.size.height = CCTransformRefreshViewHeight;
    frame.size.width = CCTransformRefreshViewHeight;
    if (self = [super initWithFrame:frame]) {
        // 1.自己的属性
        //        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        
        // 2.设置默认状态
        self.state = CCTransformRefreshStateNormal;
    }
    return self;
}


- (UIImageView *)transformImage
{
    if (!_transformImage) {
        UIImageView *transformImage = [[UIImageView alloc] initWithFrame:self.bounds];
        transformImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_transformImage = transformImage];
    }
    return _transformImage;
}

- (UIActivityIndicatorView *)indicatorActivityView
{
    if (!_indicatorActivityView) {
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicatorView.frame = CGRectMake(0, 0, 30, 30);
        [self addSubview:_indicatorActivityView = indicatorView];
    }
    return _indicatorActivityView;
}


- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    // 旧的父控件
    [self.superview removeObserver:self forKeyPath:CCTransformRefreshContentOffset context:nil];
    
    if (newSuperview) { // 新的父控件
        [newSuperview addObserver:self forKeyPath:CCTransformRefreshContentOffset options:NSKeyValueObservingOptionNew context:nil];
        
        // 设置自己的位置和尺寸
        self.y = -self.height;
        self.x = 10;
        // 记录UIScrollView
        _scrollView = (UIScrollView *)newSuperview;
        // 记录UIScrollView最开始的contentInset
        _scrollViewOriginalInset = _scrollView.contentInset;
    }
}

#pragma mark - 监听UIScrollView的contentOffset属性
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 不能跟用户交互就直接返回
    if (!self.userInteractionEnabled || self.alpha <= 0.01 || self.hidden) return;
    
    // 如果正在刷新，直接返回
    if (self.state == CCTransformRefreshStateRefreshing) return;
    
    if ([CCTransformRefreshContentOffset isEqualToString:keyPath]) {
        [self adjustStateWithContentOffset];
    }
}

/**
 *  调整状态
 */
- (void)adjustStateWithContentOffset
{
    // 当前的contentOffset
    CGFloat currentOffsetY = self.scrollView.contentOffsetY;
    // 头部控件刚好出现的offsetY
    CGFloat happenOffsetY = -self.scrollViewOriginalInset.top;
    
    // 如果是向上滚动到看不见头部控件，直接返回
    if (currentOffsetY >= happenOffsetY) return;
    
    if (self.scrollView.isDragging) {
        // 普通 和 即将刷新 的临界点
        CGFloat normal2pullingOffsetY = happenOffsetY - self.height;
        
        if (self.state == CCTransformRefreshStateNormal && currentOffsetY < normal2pullingOffsetY) {
            // 转为即将刷新状态
            self.state = CCTransformRefreshStatePulling;
        } else if (self.state == CCTransformRefreshStatePulling && currentOffsetY >= normal2pullingOffsetY) {
            // 转为普通状态
            self.state = CCTransformRefreshStateNormal;
        }
        
        if (_currentOffset < currentOffsetY) { // 向上滚动
            if (![_transformImage.layer animationForKey:@"rotationAnimation"] && !_indicatorActivityView.isAnimating)
                [self transformWithClockwise:YES];
        } else { // 向下滚动
            if (![_transformImage.layer animationForKey:@"rotationAnimation"] && !_indicatorActivityView.isAnimating)
                [self transformWithClockwise:NO];
        }
        
        if (currentOffsetY < -50) //固定位置
            self.y = currentOffsetY + 20;
        
        _currentOffset = currentOffsetY;
    } else if (self.state == CCTransformRefreshStatePulling) { // 即将刷新 && 手松开
        // 开始刷新
        self.state = CCTransformRefreshStateRefreshing;
    }
}

- (void)drawRect:(CGRect)rect
{
    if (self.state == CCTransformRefreshStateWillRefreshing) {
        self.state = CCTransformRefreshStateRefreshing;
    }
}

- (void)beginTransformRefreshing
{
    if (self.state == CCTransformRefreshStateRefreshing) {
        // 回调
        if ([self.beginRefreshingTaget respondsToSelector:self.beginRefreshingAction])
            msgSend(msgTarget(self.beginRefreshingTaget), self.beginRefreshingAction, self);
        
        if (self.beginRefreshingCallback)
            self.beginRefreshingCallback();
    } else {
        if (self.window) {
            self.state = CCTransformRefreshStateRefreshing;
        } else {
            _state = CCTransformRefreshStateWillRefreshing;
            [self setNeedsDisplay];
        }
    }
}

- (void)endTransformRefreshing
{
    double delayInSeconds = 0.3;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        self.state = CCTransformRefreshStateNormal;
        [self.transformImage.layer removeAllAnimations];
        [self.indicatorActivityView stopAnimating];
        self.y = -self.height;
    });
}

#pragma mark 设置状态
- (void)setState:(CCTransformRefreshState)state
{
    // 1.一样的就直接返回
    if (self.state == state) return;
    
    // 2.保存旧状态
    CCTransformRefreshState oldState = self.state;
    
    // 3.存储状态
    _state = state;
    
    // 4.根据状态执行不同的操作
    switch (state) {
        case CCTransformRefreshStateNormal: // 下拉可以刷新
        {
            // 刷新完毕
            if (CCTransformRefreshStateRefreshing == oldState) {
                [self endTransformRefreshing];
                [UIView animateWithDuration:CCTransformRefreshFastAnimationDuration animations:^{
                    self.y -= self.height + CCTransformRefreshTop;
                }];
            } else {
                // 执行动画
            }
            break;
        }
        case CCTransformRefreshStatePulling: // 准备开始刷新
        {
            break;
        }
        case CCTransformRefreshStateRefreshing: // 正在刷新中
        {
            // 执行动画
            [UIView animateWithDuration:CCTransformRefreshFastAnimationDuration animations:^{
                self.y = 20;
            }];
            
            [self continueTransform];
            [self beginTransformRefreshing];
            break;
        }
            
        default:
            break;
    }
}

/**
 *  @author CC, 16-03-19
 *  
 *  @brief 旋转动画
 */
- (void)continueTransform
{
    if (_transformImage != nil) {
        _transformImage.transform = CGAffineTransformIdentity;
        [_transformImage.layer removeAllAnimations];
        CABasicAnimation *rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
        rotationAnimation.duration = 0.8;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = CGFLOAT_MAX;
        [_transformImage.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    } else {
        [_indicatorActivityView startAnimating];
    }
}

/**
 *  @author CC, 16-03-19
 *  
 *  @brief 拉动动画
 *
 *  @param clockwise 上下拉
 */
- (void)transformWithClockwise:(BOOL)clockwise
{
    if (_transformImage != nil) {
        _transformImage.transform = CGAffineTransformRotate(_transformImage.transform, clockwise ? kTransformRotateRate : -kTransformRotateRate);
    } else {
        _indicatorActivityView.transform = CGAffineTransformRotate(_indicatorActivityView.transform, clockwise ? kTransformRotateRate : -kTransformRotateRate);
    }
}

@end
