//
//  CCRefreshHeaderView.h
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
//  下拉刷新

#import "CCRefreshHeaderView.h"
#import "CCRefreshConst.h"
#import "config.h"
#import "UIView+Frame.h"
#import "UIScrollView+Additions.h"

@interface CCRefreshHeaderView ()
// 最后的更新时间
@property(nonatomic, strong) NSDate *lastUpdateTime;
@property(nonatomic, weak) UILabel *lastUpdateTimeLabel;

@property(nonatomic, weak) UIImageView *activityImageView;

@end

@implementation CCRefreshHeaderView
#pragma mark - 控件初始化
/**
 *  时间标签
 */
- (UILabel *)lastUpdateTimeLabel
{
    if (!_lastUpdateTimeLabel) {
        // 1.创建控件
        UILabel *lastUpdateTimeLabel = [[UILabel alloc] init];
        lastUpdateTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        lastUpdateTimeLabel.font = [UIFont boldSystemFontOfSize:12];
        lastUpdateTimeLabel.textColor = cc_ColorRGB(150, 150, 150);
        lastUpdateTimeLabel.backgroundColor = [UIColor clearColor];
        lastUpdateTimeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_lastUpdateTimeLabel = lastUpdateTimeLabel];

        // 2.加载时间
        if (self.dateKey) {
            self.lastUpdateTime = [[NSUserDefaults standardUserDefaults] objectForKey:self.dateKey];
        } else {
            self.lastUpdateTime = [[NSUserDefaults standardUserDefaults] objectForKey:CCRefreshHeaderTimeKey];
        }
    }
    return _lastUpdateTimeLabel;
}

/**
 *  @author CC, 16-08-18
 *
 *  @brief 自定义独立图片
 */
- (UIImageView *)activityImageView
{
    if (!_activityImageView) {
        UIImageView *activityImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
        [self addSubview:_activityImageView = activityImageView];
    }
    return _activityImageView;
}

+ (instancetype)header
{
    return [[CCRefreshHeaderView alloc] init];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.pullToRefreshText = CCRefreshHeaderPullToRefresh;
        self.releaseToRefreshText = CCRefreshHeaderReleaseToRefresh;
        self.refreshingText = CCRefreshHeaderRefreshing;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.style == CCRefreshViewStyleImageView) {
        self.activityImageView.center = CGPointMake(self.centerX, -self.centerY);
    } else if (self.style == CCRefreshViewStyleIndicator) {

    } else {
        CGFloat statusX = 0;
        CGFloat statusY = 0;
        CGFloat statusHeight = self.height * 0.5;
        CGFloat statusWidth = self.width;
        // 1.状态标签
        self.statusLabel.frame = CGRectMake(statusX, statusY, statusWidth, statusHeight);

        // 2.时间标签
        CGFloat lastUpdateY = statusHeight;
        CGFloat lastUpdateX = 0;
        CGFloat lastUpdateHeight = statusHeight;
        CGFloat lastUpdateWidth = statusWidth;
        self.lastUpdateTimeLabel.frame = CGRectMake(lastUpdateX, lastUpdateY, lastUpdateWidth, lastUpdateHeight);
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];

    // 设置自己的位置和尺寸
    self.y = -self.height;
}

#pragma mark - 设置图片
- (void)setActivityImage:(UIImage *)image
{
    self.activityImageView.size = image.size;
    self.activityImageView.image = image;
}

#pragma mark - 状态相关
#pragma mark 设置最后的更新时间
- (void)setLastUpdateTime:(NSDate *)lastUpdateTime
{
    _lastUpdateTime = lastUpdateTime;

    // 1.归档
    if (self.dateKey) {
        [[NSUserDefaults standardUserDefaults] setObject:lastUpdateTime forKey:self.dateKey];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:lastUpdateTime forKey:CCRefreshHeaderTimeKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];

    // 2.更新时间
    [self updateTimeLabel];
}

#pragma mark 更新时间字符串
- (void)updateTimeLabel
{
    if (!self.lastUpdateTime) return;

    // 1.获得年月日
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *cmp1 = [calendar components:unitFlags fromDate:_lastUpdateTime];
    NSDateComponents *cmp2 = [calendar components:unitFlags fromDate:[NSDate date]];

    // 2.格式化日期
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if ([cmp1 day] == [cmp2 day]) { // 今天
        formatter.dateFormat = @"今天 HH:mm";
    } else if ([cmp1 year] == [cmp2 year]) { // 今年
        formatter.dateFormat = @"MM-dd HH:mm";
    } else {
        formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    }
    NSString *time = [formatter stringFromDate:self.lastUpdateTime];

    // 3.显示日期
    self.lastUpdateTimeLabel.text = [NSString stringWithFormat:@"最后更新：%@", time];
}

#pragma mark - 监听UIScrollView的contentOffset属性
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 不能跟用户交互就直接返回
    if (!self.userInteractionEnabled || self.alpha <= 0.01 || self.hidden) return;

    // 如果正在刷新，直接返回
    if (self.state == CCRefreshStateRefreshing) return;

    if ([CCRefreshContentOffset isEqualToString:keyPath]) {
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

        if (self.state == CCRefreshStateNormal && currentOffsetY < normal2pullingOffsetY) {
            // 转为即将刷新状态
            self.state = CCRefreshStatePulling;
        } else if (self.state == CCRefreshStatePulling && currentOffsetY >= normal2pullingOffsetY) {
            // 转为普通状态
            self.state = CCRefreshStateNormal;
        }
    } else if (self.state == CCRefreshStatePulling) { // 即将刷新 && 手松开
        // 开始刷新
        self.state = CCRefreshStateRefreshing;
    }
}

#pragma mark 设置状态
- (void)setState:(CCRefreshState)state
{
    // 1.一样的就直接返回
    if (self.state == state) return;

    // 2.保存旧状态
    CCRefreshState oldState = self.state;

    // 3.调用父类方法
    [super setState:state];

    // 4.根据状态执行不同的操作
    switch (state) {
        case CCRefreshStateNormal: // 下拉可以刷新
        {
            // 刷新完毕
            if (CCRefreshStateRefreshing == oldState) {
                self.arrowImage.transform = CGAffineTransformIdentity;
                // 保存刷新时间
                self.lastUpdateTime = [NSDate date];

                [UIView animateWithDuration:CCRefreshSlowAnimationDuration animations:^{
                    self.scrollView.contentInsetTop -= self.height;
                }];
            } else {
                // 执行动画
                [UIView animateWithDuration:CCRefreshFastAnimationDuration animations:^{
                    self.arrowImage.transform = CGAffineTransformIdentity;
                }];
            }
            break;
        }

        case CCRefreshStatePulling: // 松开可立即刷新
        {
            // 执行动画
            [UIView animateWithDuration:CCRefreshFastAnimationDuration animations:^{
                self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
            }];
            break;
        }

        case CCRefreshStateRefreshing: // 正在刷新中
        {
            // 执行动画
            [UIView animateWithDuration:CCRefreshFastAnimationDuration animations:^{
                // 1.增加滚动区域
                CGFloat top = self.scrollViewOriginalInset.top + self.height;
                self.scrollView.contentInsetTop = top;

                // 2.设置滚动位置
                self.scrollView.contentOffsetY = - top;
            }];
            break;
        }

        default:
            break;
    }
}
@end