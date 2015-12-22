//
//  CCRefreshBaseView.m
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

#import "CCRefreshBaseView.h"
#import "CCRefreshConst.h"
#import "UIView+BUIView.h"
#import "config.h"
#import "Core.h"
#import <objc/message.h>
#import "CCLoadingView.h"

@interface CCRefreshBaseView ()

@property(nonatomic, weak) UILabel *statusLabel;
@property(nonatomic, weak) UIImageView *arrowImage;
@property(nonatomic, weak) UIActivityIndicatorView *activityView;

@property(nonatomic, weak) CCLoadingView *cc_activityView;

@end

@implementation CCRefreshBaseView
#pragma mark - 控件初始化
/**
 *  状态标签
 */
- (UILabel *)statusLabel
{
    if (!_statusLabel) {
        UILabel *statusLabel = [[UILabel alloc] init];
        statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        statusLabel.font = [UIFont boldSystemFontOfSize:13];
        statusLabel.textColor = cc_ColorRGB(150, 150, 150);
        statusLabel.backgroundColor = [UIColor clearColor];
        statusLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_statusLabel = statusLabel];
    }
    return _statusLabel;
}

/**
 *  箭头图片
 */
- (UIImageView *)arrowImage
{
    if (!_arrowImage) {
        UIImageView *arrowImage = [[UIImageView alloc] initWithImage:CCResourceImage(@"arrow")];
        arrowImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_arrowImage = arrowImage];
    }
    return _arrowImage;
}

/**
 *  状态标签
 */
- (UIActivityIndicatorView *)activityView
{
    if (!_activityView) {
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.bounds = self.arrowImage.bounds;
        activityView.autoresizingMask = self.arrowImage.autoresizingMask;
        [self addSubview:_activityView = activityView];
    }
    return _activityView;
}

/**
 *  @author CC, 2015-11-12
 *  
 *  @brief  load图标
 */
- (CCLoadingView *)cc_activityView
{
    if (!_cc_activityView) {
        CCLoadingView *loadingView = [[CCLoadingView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        [loadingView initialize];
        loadingView.lineCap = kCALineCapRound;
        loadingView.clockwise = true;
        loadingView.segmentColor = [UIColor lightGrayColor];
        [loadingView startAnimation:CCCircleAnimationFullCircle];
        
        [self addSubview:_cc_activityView = loadingView];
    }
    return _cc_activityView;
}

#pragma mark - 初始化方法
- (instancetype)initWithFrame:(CGRect)frame
{
    frame.size.height = CCRefreshViewHeight;
    if (self = [super initWithFrame:frame]) {
        // 1.自己的属性
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        
        // 2.设置默认状态
        self.state = CCRefreshStateNormal;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 1.箭头
    CGFloat arrowX = self.width * 0.5 - 100;
    self.arrowImage.center = CGPointMake(arrowX, self.height * 0.5);
    
    // 2.指示器
    self.activityView.center = self.arrowImage.center;
    self.cc_activityView.center = self.arrowImage.center;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    // 旧的父控件
    [self.superview removeObserver:self forKeyPath:CCRefreshContentOffset context:nil];
    
    if (newSuperview) { // 新的父控件
        [newSuperview addObserver:self forKeyPath:CCRefreshContentOffset options:NSKeyValueObservingOptionNew context:nil];
        
        // 设置宽度
        self.width = newSuperview.width;
        // 设置位置
        self.x = 0;
        
        // 记录UIScrollView
        _scrollView = (UIScrollView *)newSuperview;
        // 记录UIScrollView最开始的contentInset
        _scrollViewOriginalInset = _scrollView.contentInset;
    }
}

#pragma mark - 显示到屏幕上
- (void)drawRect:(CGRect)rect
{
    if (self.state == CCRefreshStateWillRefreshing) {
        self.state = CCRefreshStateRefreshing;
    }
}

#pragma mark - 刷新相关
#pragma mark 是否正在刷新
- (BOOL)isRefreshing
{
    return CCRefreshStateRefreshing == self.state;
}

#pragma mark 开始刷新
- (void)beginRefreshing
{
    if (self.state == CCRefreshStateRefreshing) {
        // 回调
        if ([self.beginRefreshingTaget respondsToSelector:self.beginRefreshingAction]) {
            msgSend(msgTarget(self.beginRefreshingTaget), self.beginRefreshingAction, self);
        }
        
        if (self.beginRefreshingCallback) {
            self.beginRefreshingCallback();
        }
    } else {
        if (self.window) {
            self.state = CCRefreshStateRefreshing;
        } else {
            _state = CCRefreshStateWillRefreshing;
            [self setNeedsDisplay];
        }
    }
}

#pragma mark 结束刷新
- (void)endRefreshing
{
    double delayInSeconds = 0.3;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        self.state = CCRefreshStateNormal;
    });
}

#pragma mark - 设置状态
- (void)setPullToRefreshText:(NSString *)pullToRefreshText
{
    _pullToRefreshText = [pullToRefreshText copy];
    [self settingLabelText];
}
- (void)setReleaseToRefreshText:(NSString *)releaseToRefreshText
{
    _releaseToRefreshText = [releaseToRefreshText copy];
    [self settingLabelText];
}
- (void)setRefreshingText:(NSString *)refreshingText
{
    _refreshingText = [refreshingText copy];
    [self settingLabelText];
}
- (void)settingLabelText
{
    switch (self.state) {
        case CCRefreshStateNormal:
            // 设置文字
            self.statusLabel.text = self.pullToRefreshText;
            break;
        case CCRefreshStatePulling:
            // 设置文字
            self.statusLabel.text = self.releaseToRefreshText;
            break;
        case CCRefreshStateRefreshing:
            // 设置文字
            self.statusLabel.text = self.refreshingText;
            break;
        default:
            break;
    }
}

- (void)setState:(CCRefreshState)state
{
    // 0.存储当前的contentInset
    if (self.state != CCRefreshStateRefreshing) {
        _scrollViewOriginalInset = self.scrollView.contentInset;
    }
    
    // 1.一样的就直接返回(暂时不返回)
    if (self.state == state) return;
    
    // 2.旧状态
    CCRefreshState oldState = self.state;
    
    // 3.存储状态
    _state = state;
    
    // 4.根据状态执行不同的操作
    switch (state) {
        case CCRefreshStateNormal: // 普通状态
        {
            if (oldState == CCRefreshStateRefreshing) {
                [UIView animateWithDuration:CCRefreshSlowAnimationDuration * 0.6 animations:^{
                    //                    self.activityView.alpha = 0.0;
                    self.cc_activityView.alpha = 0.0;
                } completion:^(BOOL finished) {
                    // 停止转圈圈
                    //                    [self.activityView stopAnimating];
                    [self.cc_activityView stopAnimation];
                    // 恢复alpha
                    //                    self.activityView.alpha = 1.0;
                    self.cc_activityView.alpha = 1.0;
                }];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(CCRefreshSlowAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // 等头部回去
                    // 再次设置回normal
                    //                    _state = CCRefreshStatePulling;
                    //                    self.state = CCRefreshStateNormal;
                    // 显示箭头
                    self.arrowImage.hidden = NO;
                    
                    // 停止转圈圈
                    //                    [self.activityView stopAnimating];
                    [self.cc_activityView stopAnimation];
                    
                    // 设置文字
                    [self settingLabelText];
                });
                // 直接返回
                return;
            } else {
                // 显示箭头
                self.arrowImage.hidden = NO;
                
                // 停止转圈圈
                //                [self.activityView stopAnimating];
                [self.cc_activityView stopAnimation];
            }
            break;
        }
            
        case CCRefreshStatePulling:
            break;
            
        case CCRefreshStateRefreshing: {
            // 开始转圈圈
            //            [self.activityView startAnimating];
            [self.cc_activityView startAnimation:CCCircleAnimationFullCircle];
            // 隐藏箭头
            self.arrowImage.hidden = YES;
            
            // 回调
            if ([self.beginRefreshingTaget respondsToSelector:self.beginRefreshingAction]) {
                msgSend(msgTarget(self.beginRefreshingTaget), self.beginRefreshingAction, self);
            }
            
            if (self.beginRefreshingCallback) {
                self.beginRefreshingCallback();
            }
            break;
        }
        default:
            break;
    }
    
    // 5.设置文字
    [self settingLabelText];
}
@end