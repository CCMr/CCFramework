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
#import "UIView+Frame.h"
#import "config.h"
#import "Core.h"
#import <objc/message.h>
#import "CCLoadLogoView.h"

@interface CCRefreshBaseView ()

@property(nonatomic, weak) UILabel *statusLabel;
@property(nonatomic, weak) UIImageView *arrowImage;
@property(nonatomic, weak) UIActivityIndicatorView *activityView;

@property(nonatomic, weak) CCLoadLogoView *cc_activityView;

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
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicatorView.frame = CGRectMake(0, 0, 20, 20);
        [self addSubview:indicatorView];
        _activityView = indicatorView;
    }
    return _activityView;
}

/**
 *  @author CC, 2015-11-12
 *
 *  @brief  load图标
 */
- (CCLoadLogoView *)cc_activityView
{
    if (!_cc_activityView) {
        CCLoadLogoView *loadingView = [[CCLoadLogoView alloc] initWithLogo:@"arrow" Frame:CGRectMake(0, 0, 40, 40)];
        [loadingView setLineColor:[UIColor lightGrayColor]];
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

    if (self.style == CCRefreshViewStyleIndicatorView) {
        self.activityView.center = CGPointMake(self.width / 2, self.height * 0.4);
    } else if (self.style == CCRefreshViewStyleDefault) {
        // 1.箭头
        CGFloat arrowX = self.width * 0.5 - 100;
        self.arrowImage.center = CGPointMake(arrowX, self.height * 0.5);

        self.cc_activityView.center = self.arrowImage.center;
        self.activityView.center = self.arrowImage.center;
    } else if (self.style == CCRefreshViewStyleIndicator) {
        self.activityView.center = CGPointMake(self.centerX, self.height * 0.5);
    }
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

#pragma mark - 设置样式
- (void)setStyle:(CCRefreshViewStyle)style
{
    _style = style;
    if (_style == CCRefreshViewStyleImageView) {
        self.statusLabel.hidden = YES;
        self.arrowImage.hidden = YES;
    } else if (_style == CCRefreshViewStyleIndicator) {
        self.statusLabel.hidden = YES;
        self.arrowImage.hidden = YES;
        self.activityView.hidden = NO;
        self.height = 30;
        [self setNeedsDisplay];
    } else {
        self.statusLabel.hidden = NO;
        self.arrowImage.hidden = NO;
        if (style == CCRefreshViewStyleIndicatorView) {
            self.statusLabel.hidden = YES;
            self.arrowImage.hidden = YES;
        }
    }
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
                    if (self.style == CCRefreshViewStyleIndicatorView || self.style == CCRefreshViewStyleIndicator)
                        self.activityView.alpha = 0.0;
                    else if (self.style == CCRefreshViewStyleDefault)
                        self.cc_activityView.alpha = 0.0;

                } completion:^(BOOL finished) {

                    if (self.style == CCRefreshViewStyleIndicatorView || self.style == CCRefreshViewStyleIndicator){// 停止转圈圈
                        [self.activityView stopAnimating];
                        self.activityView.alpha = 1.0;
                    }else if (self.style == CCRefreshViewStyleDefault){ // 恢复alpha
                        [self.cc_activityView stopAnimation];
                        self.cc_activityView.alpha = 1.0;
                    }

                }];

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(CCRefreshSlowAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // 等头部回去
                    // 停止转圈圈
                    if (self.style == CCRefreshViewStyleIndicatorView || self.style == CCRefreshViewStyleIndicator){
                        [self.activityView stopAnimating];
                    }else if (self.style == CCRefreshViewStyleDefault){
                        // 显示箭头
                        self.arrowImage.hidden = NO;
                        [self.cc_activityView stopAnimation];
                    }

                    // 设置文字
                    [self settingLabelText];
                });
                // 直接返回
                return;
            } else {
                // 停止转圈圈
                if (self.style == CCRefreshViewStyleIndicatorView || self.style == CCRefreshViewStyleIndicator) {
                    [self.activityView stopAnimating];
                } else if (self.style == CCRefreshViewStyleDefault) {
                    [self.cc_activityView stopAnimation];
                    // 显示箭头
                    self.arrowImage.hidden = NO;
                }
            }
            break;
        }

        case CCRefreshStatePulling:
            if (self.style == CCRefreshViewStyleIndicatorView || self.style == CCRefreshViewStyleIndicator) {
                [self.activityView startAnimating];
            } else if (self.style == CCRefreshViewStyleDefault)
                [self.cc_activityView startAnimation];
            break;

        case CCRefreshStateRefreshing: {

            if (self.style == CCRefreshViewStyleIndicatorView || self.style == CCRefreshViewStyleIndicator) {
                [self.activityView startAnimating];
            } else if (self.style == CCRefreshViewStyleDefault)
                [self.cc_activityView startAnimation];

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