//
//  CCRefreshTableFooterView.m
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
//  上拉加载更多


#import "CCRefreshFooterView.h"
#import "CCRefreshConst.h"
#import "UIView+Frame.h"
#import "UIScrollView+Additions.h"

@interface CCRefreshFooterView ()

@property(assign, nonatomic) NSInteger lastRefreshCount;

@property(nonatomic, weak) UIImageView *activityImageView;

@end

@implementation CCRefreshFooterView

+ (instancetype)footer
{
    return [[CCRefreshFooterView alloc] init];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.pullToRefreshText = CCRefreshFooterPullToRefresh;
        self.releaseToRefreshText = CCRefreshFooterReleaseToRefresh;
        self.refreshingText = CCRefreshFooterRefreshing;
    }
    return self;
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

#pragma mark - 设置图片
- (void)setActivityImage:(UIImage *)image
{
    self.activityImageView.size = CGSizeMake(43, 35); //image.size;
    self.activityImageView.image = image;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (self.style == CCRefreshViewStyleImageView) {
        self.statusLabel.hidden = YES;
        self.activityImageView.center = CGPointMake(self.centerX, -self.centerY);
    } else {
        self.activityImageView.hidden = YES;
        self.arrowImage.hidden = YES;
        self.statusLabel.frame = self.bounds;
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];

    // 旧的父控件
    [self.superview removeObserver:self forKeyPath:CCRefreshContentSize context:nil];

    if (newSuperview) { // 新的父控件
        // 监听
        [newSuperview addObserver:self forKeyPath:CCRefreshContentSize options:NSKeyValueObservingOptionNew context:nil];

        // 重新调整frame
        [self adjustFrameWithContentSize];
    }
}

#pragma mark 重写调整frame
- (void)adjustFrameWithContentSize
{
    // 内容的高度
    CGFloat contentHeight = self.scrollView.contentSizeHeight;
    // 表格的高度
    CGFloat scrollHeight = self.scrollView.height - self.scrollViewOriginalInset.top - self.scrollViewOriginalInset.bottom;
    // 设置位置和尺寸
    self.y = MAX(contentHeight, scrollHeight);
}

#pragma mark 监听UIScrollView的属性
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 不能跟用户交互，直接返回
    if (!self.userInteractionEnabled || self.alpha <= 0.01 || self.hidden) return;

    if ([CCRefreshContentSize isEqualToString:keyPath]) {
        // 调整frame
        [self adjustFrameWithContentSize];
    } else if ([CCRefreshContentOffset isEqualToString:keyPath]) {
        // 如果正在刷新，直接返回
        if (self.state == CCRefreshStateRefreshing) return;

        // 调整状态
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
    // 尾部控件刚好出现的offsetY
    CGFloat happenOffsetY = [self happenOffsetY];

    // 如果是向下滚动到看不见尾部控件，直接返回
    if (currentOffsetY <= happenOffsetY) return;

    if (self.scrollView.isDragging) {
        // 普通 和 即将刷新 的临界点
        CGFloat normal2pullingOffsetY = happenOffsetY + self.height;

        if (self.state == CCRefreshStateNormal && currentOffsetY > normal2pullingOffsetY) {
            // 转为即将刷新状态
            self.state = CCRefreshStatePulling;
        } else if (self.state == CCRefreshStatePulling && currentOffsetY <= normal2pullingOffsetY) {
            // 转为普通状态
            self.state = CCRefreshStateNormal;
        }
    } else if (self.state == CCRefreshStatePulling) { // 即将刷新 && 手松开
        // 开始刷新
        self.state = CCRefreshStateRefreshing;
    }
}

#pragma mark - 状态相关
#pragma mark 设置状态
- (void)setState:(CCRefreshState)state
{
    // 1.一样的就直接返回
    if (self.state == state) return;

    // 2.保存旧状态
    CCRefreshState oldState = self.state;

    // 3.调用父类方法
    [super setState:state];

    // 4.根据状态来设置属性
    switch (state) {
        case CCRefreshStateNormal: {
            // 刷新完毕
            if (CCRefreshStateRefreshing == oldState) {
                self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
                [UIView animateWithDuration:CCRefreshSlowAnimationDuration animations:^{
                    self.scrollView.contentInsetBottom = self.scrollViewOriginalInset.bottom;
                }];
            } else {
                // 执行动画
                [UIView animateWithDuration:CCRefreshFastAnimationDuration animations:^{
                    self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
                }];
            }

            CGFloat deltaH = [self heightForContentBreakView];
            NSInteger currentCount = [self totalDataCountInScrollView];
            // 刚刷新完毕
            if (CCRefreshStateRefreshing == oldState && deltaH > 0 && currentCount != self.lastRefreshCount) {
                self.scrollView.contentOffsetY = self.scrollView.contentOffsetY;
            }
            break;
        }

        case CCRefreshStatePulling: {
            [UIView animateWithDuration:CCRefreshFastAnimationDuration animations:^{
                self.arrowImage.transform = CGAffineTransformIdentity;
            }];
            break;
        }

        case CCRefreshStateRefreshing: {
            // 记录刷新前的数量
            self.lastRefreshCount = [self totalDataCountInScrollView];

            [UIView animateWithDuration:CCRefreshFastAnimationDuration animations:^{
                CGFloat bottom = self.height + self.scrollViewOriginalInset.bottom;
                CGFloat deltaH = [self heightForContentBreakView];
                if (deltaH < 0) { // 如果内容高度小于view的高度
                    bottom -= deltaH;
                }
                self.scrollView.contentInsetBottom = bottom;
            }];
            break;
        }

        default:
            break;
    }
}

- (NSInteger)totalDataCountInScrollView
{
    NSInteger totalCount = 0;
    if ([self.scrollView isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self.scrollView;

        for (NSInteger section = 0; section < tableView.numberOfSections; section++) {
            totalCount += [tableView numberOfRowsInSection:section];
        }
    } else if ([self.scrollView isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self.scrollView;

        for (NSInteger section = 0; section < collectionView.numberOfSections; section++) {
            totalCount += [collectionView numberOfItemsInSection:section];
        }
    }
    return totalCount;
}

#pragma mark 获得scrollView的内容 超出 view 的高度
- (CGFloat)heightForContentBreakView
{
    CGFloat h = self.scrollView.frame.size.height - self.scrollViewOriginalInset.bottom - self.scrollViewOriginalInset.top;
    return self.scrollView.contentSize.height - h;
}

#pragma mark - 在父类中用得上
/**
 *  刚好看到上拉刷新控件时的contentOffset.y
 */
- (CGFloat)happenOffsetY
{
    CGFloat deltaH = [self heightForContentBreakView];
    if (deltaH > 0) {
        return deltaH - self.scrollViewOriginalInset.top;
    } else {
        return - self.scrollViewOriginalInset.top;
    }
}
@end