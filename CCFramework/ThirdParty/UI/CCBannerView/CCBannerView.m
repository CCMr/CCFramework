//
//  CCBannerView.m
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

#import "CCBannerView.h"
#import "CCBannerFooter.h"
#import "UIImageView+WebCache.h"
#import "config.h"

// 总共的item数
#define kccTotalItems (self.itemCount * 20000)

#define kCCFooterWidth 64.0
#define kCCPageControlHeight 32.0

@interface CCBannerView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property(nonatomic, strong) CCBannerFooter *footer;
@property(nonatomic, strong, readwrite) UIPageControl *pageControl;

@property(nonatomic, assign) NSInteger itemCount;
@property(nonatomic, strong) NSTimer *timer;

@end

@implementation CCBannerView

@synthesize scrollInterval = _scrollInterval;
@synthesize autoScroll = _autoScroll;
@synthesize shouldLoop = _shouldLoop;
@synthesize pageControl = _pageControl;

static NSString *banner_item = @"banner_item";
static NSString *banner_footer = @"banner_footer";

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialization];
    }
    return self;
}

- (void)initialization
{
    self.placeImage = CCResourceImage(@"placeholderImage");
    [self addSubview:self.collectionView];
    [self addSubview:self.pageControl];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self updateSubviewsFrame];
}

- (void)updateSubviewsFrame
{
    // collectionView
    self.flowLayout.itemSize = self.bounds.size;
    self.flowLayout.footerReferenceSize = CGSizeMake(kCCFooterWidth, self.frame.size.height);
    self.collectionView.frame = self.bounds;
    
    // pageControl
    if (CGRectEqualToRect(self.pageControl.frame, CGRectZero)) {
        // 若未对pageControl设置过frame, 则使用以下默认frame
        CGFloat w = self.frame.size.width;
        CGFloat h = kCCPageControlHeight;
        CGFloat x = 0;
        CGFloat y = self.frame.size.height - h;
        self.pageControl.frame = CGRectMake(x, y, w, h);
    }
}

// 配置默认起始位置
- (void)fixDefaultPosition
{
    if (self.itemCount == 0)
        return;
    
    if (self.shouldLoop) {
        // 总item数的中间
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:(kccTotalItems / 2) inSection:0]
                                        atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
            self.pageControl.currentPage = 0;
        });
    } else {
        // 第0个item
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
                                        atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
            self.pageControl.currentPage = 0;
        });
    }
    
    if (self.bannerTitleAry) {
        CGRect frame = self.pageControl.frame;
        frame.origin.x = CGRectGetWidth(self.bounds) - 100;
        frame.size.width = 90;
        self.pageControl.frame = frame;
    }
}

#pragma mark - Reload

- (void)reloadData
{
    if (self.itemCount == 0)
        return;
    
    // 设置pageControl总页数
    self.pageControl.numberOfPages = self.itemCount;
    
    // 刷新数据
    [self.collectionView reloadData];
    
    // 开启定时器
    [self startTimer];
}

#pragma mark - NSTimer

- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)startTimer
{
    if (!self.autoScroll) return;
    
    [self stopTimer];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.scrollInterval
                                                  target:self
                                                selector:@selector(autoScrollToNextItem)
                                                userInfo:nil
                                                 repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

// 定时器方法
- (void)autoScrollToNextItem
{
    if (self.itemCount == 0 ||
        self.itemCount == 1 ||
        !self.autoScroll) {
        return;
    }
    
    NSIndexPath *currentIndexPath = [[self.collectionView indexPathsForVisibleItems] firstObject];
    NSUInteger currentItem = currentIndexPath.item;
    NSUInteger nextItem = currentItem + 1;
    
    if (nextItem >= kccTotalItems) {
        return;
    }
    
    if (self.shouldLoop) {
        // 无限往下翻页
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:nextItem inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionLeft
                                            animated:YES];
    } else {
        if ((currentItem % self.itemCount) == self.itemCount - 1) { //当前最后一张, 回到第0张
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
                                        atScrollPosition:UICollectionViewScrollPositionLeft
                                                animated:YES];
        } else { // 往下翻页
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:nextItem inSection:0]
                                        atScrollPosition:UICollectionViewScrollPositionLeft
                                                animated:YES];
        }
    }
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    if (self.shouldLoop)
        return kccTotalItems;
    else
        return self.itemCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *Cell = [collectionView dequeueReusableCellWithReuseIdentifier:banner_item forIndexPath:indexPath];
    
    NSString *imagePath = [self.bannerImageAry objectAtIndex:indexPath.item % self.itemCount];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.frame = Cell.bounds;
    [Cell addSubview:imageView];
    if ([imagePath hasPrefix:@"http://"])
        [imageView sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:self.placeImage];
    else
        imageView.image = [UIImage imageNamed:imagePath];
    
    if (self.bannerTitleAry) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(Cell.bounds) - 20, CGRectGetWidth(Cell.bounds), 20)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = [self.bannerTitleAry objectAtIndex:indexPath.item % self.itemCount];
        [Cell addSubview:titleLabel];
    }
    
    return Cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)theCollectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)theIndexPath
{
    UICollectionReusableView *footer = nil;
    
    if (kind == UICollectionElementKindSectionFooter) {
        footer = [theCollectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                       withReuseIdentifier:banner_footer
                                                              forIndexPath:theIndexPath];
        self.footer = (CCBannerFooter *)footer;
        
        // 配置footer的提示语
        if (self.idleTitle)
            self.footer.idleTitle = self.idleTitle;
        if (self.triggerTitle)
            self.footer.triggerTitle = self.triggerTitle;
    }
    
    if (self.showFooter)
        self.footer.hidden = NO;
    else
        self.footer.hidden = YES;
    
    return footer;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.CCBannerDidTapAtIndex)
        self.CCBannerDidTapAtIndex(indexPath.item % self.itemCount);
}

- (void)collectionView:(UICollectionView *)collectionView
  didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *currentIndexPath = [[collectionView indexPathsForVisibleItems] firstObject];
    self.pageControl.currentPage = currentIndexPath.item % self.itemCount;
}


#pragma mark - UIScrollViewDelegate
#pragma mark timer相关

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // 用户滑动的时候停止定时器
    [self stopTimer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 用户停止滑动的时候开启定时器
    [self startTimer];
}

#pragma mark footer相关

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.showFooter) return;
    
    static CGFloat lastOffset;
    CGFloat footerDisplayOffset = (scrollView.contentOffset.x - (self.frame.size.width * (self.itemCount - 1)));
    
    // footer的动画
    if (footerDisplayOffset > 0) {
        // 开始出现footer
        if (footerDisplayOffset > kCCFooterWidth) {
            if (lastOffset > 0) return;
            self.footer.state = CCBannerFooterStateTrigger;
        } else {
            if (lastOffset < 0) return;
            self.footer.state = CCBannerFooterStateIdle;
        }
        lastOffset = footerDisplayOffset - kCCFooterWidth;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    if (!self.showFooter) return;
    
    CGFloat footerDisplayOffset = (scrollView.contentOffset.x - (self.frame.size.width * (self.itemCount - 1)));
    
    // 通知footer代理
    if (footerDisplayOffset > kCCFooterWidth) {
        if (self.CCBannerFooterDidTrigger)
            self.CCBannerFooterDidTrigger(self);
    }
}

#pragma mark - setters & getters
#pragma mark 属性

/**
 *  @author CC, 16-01-27
 *  
 *  @brief 设置图片
 */
- (void)setBannerImageAry:(NSArray *)bannerImageAry
{
    _bannerImageAry = bannerImageAry;
    // 刷新数据
    [self reloadData];
    
    // 配置默认起始位置
    [self fixDefaultPosition];
}

/**
 *  @author CC, 16-01-27
 *  
 *  @brief 设置标题
 */
- (void)setBannerTitleAry:(NSArray *)bannerTitleAry
{
    _bannerTitleAry = bannerTitleAry;
    // 刷新数据
    [self reloadData];
    
    // 配置默认起始位置
    [self fixDefaultPosition];
}

- (NSInteger)itemCount
{
    if (self.bannerImageAry)
        return self.bannerImageAry.count;
    
    return 0;
}

/**
 *  是否需要循环滚动
 */
- (void)setShouldLoop:(BOOL)shouldLoop
{
    _shouldLoop = shouldLoop;
    
    [self reloadData];
    
    // 重置默认起始位置
    [self fixDefaultPosition];
}

- (BOOL)shouldLoop
{
    if (self.showFooter) {
        // 如果footer存在就不应该有循环滚动
        return NO;
    }
    if (self.itemCount == 1) {
        // 只有一个item也不应该有循环滚动
        return NO;
    }
    return _shouldLoop;
}

/**
 *  是否显示footer
 */
- (void)setShowFooter:(BOOL)showFooter
{
    _showFooter = showFooter;
    
    [self reloadData];
}

/**
 *  是否自动滑动
 */
- (void)setAutoScroll:(BOOL)autoScroll
{
    _autoScroll = autoScroll;
    
    if (autoScroll) {
        [self startTimer];
    } else {
        [self stopTimer];
    }
}

- (BOOL)autoScroll
{
    if (self.itemCount < 2) {
        // itemCount小于2时, 禁用自动滚动
        return NO;
    }
    return _autoScroll;
}

/**
 *  自动滑动间隔时间
 */
- (void)setScrollInterval:(NSTimeInterval)scrollInterval
{
    _scrollInterval = scrollInterval;
    
    [self startTimer];
}

- (NSTimeInterval)scrollInterval
{
    if (!_scrollInterval) {
        _scrollInterval = 3.0; // default
    }
    return _scrollInterval;
}

#pragma mark 控件

/**
 *  collectionView
 */
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
        _collectionView.pagingEnabled = YES;
        _collectionView.alwaysBounceHorizontal = YES; // 小于等于一页时, 允许bounce
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.scrollsToTop = NO;
        _collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        // 注册cell
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:banner_item];
        
        // 注册 \ 配置footer
        [_collectionView registerClass:[CCBannerFooter class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:banner_footer];
        _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, -kCCFooterWidth);
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout
{
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.sectionInset = UIEdgeInsetsZero;
    }
    return _flowLayout;
}

- (void)setPageControl:(UIPageControl *)pageControl
{
    // 移除旧oageControl
    [_pageControl removeFromSuperview];
    // 赋值
    _pageControl = pageControl;
    
    // 添加新pageControl
    _pageControl.userInteractionEnabled = NO;
    _pageControl.autoresizingMask = UIViewAutoresizingNone;
    _pageControl.backgroundColor = [UIColor redColor];
    [self addSubview:_pageControl];
    
    [self reloadData];
}

- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.autoresizingMask = UIViewAutoresizingNone;
    }
    return _pageControl;
}

@end
