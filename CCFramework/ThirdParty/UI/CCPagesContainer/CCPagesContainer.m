//
//  CCPageContainerScrollView.m
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

#import "CCPagesContainer.h"
#import "config.h"
#import "CCPagesContainerTopBar.h"
#import "CCPageIndicatorView.h"

@interface CCPagesContainer () <CCPagesContainerTopBarDelegate, UIScrollViewDelegate>

@property(strong, nonatomic) CCPagesContainerTopBar *topBar;
@property(strong, nonatomic) UIScrollView *scrollView;
@property(weak, nonatomic) UIScrollView *observingScrollView;
@property(strong, nonatomic) UIView *pageIndicatorView;

@property(assign, nonatomic) BOOL shouldObserveContentOffset;
@property(readonly, assign, nonatomic) CGFloat scrollWidth;
@property(readonly, assign, nonatomic) CGFloat scrollHeight;

@property(readonly, assign, nonatomic) int currentIndex;

- (void)layoutSubviews;
- (void)startObservingContentOffsetForScrollView:(UIScrollView *)scrollView;
- (void)stopObservingContentOffset;

@end


@implementation CCPagesContainer

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)dealloc
{
    [self stopObservingContentOffset];
}

- (void)setUp
{
    _isBarTop = YES;
    _HidetabBar = NO;
    _topBarType = CCPageContaiinerTopBarTypeText;
    _indicatorType = CCPageIndicatorViewTypeInvertedTriangle;
    _topBarImageAry = [NSArray array];
    _topBarSelectedImageAry = [NSArray array];
    _topBarItemsOffset = 30;
    _topBarHeight = 44;
    _selectedIndex = 0;
    _topIndicatiorColor = [UIColor whiteColor];
    _topBarBackgroundColor = [UIColor colorWithWhite:0.1 alpha:1.];
    _topBarItemLabelsFont = [UIFont systemFontOfSize:12];
    _pageIndicatorViewSize = CGSizeMake(22., 9.);
    self.pageItemsTitleColor = [UIColor lightGrayColor];
    self.selectedPageItemTitleColor = [UIColor whiteColor];
}

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.shouldObserveContentOffset = YES;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.,
                                                                     _isBarTop ? self.topBarHeight : 0,
                                                                     winsize.width,
                                                                     CGRectGetHeight(self.view.frame) - self.topBarHeight)];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.bounces = YES;
    [self.view addSubview:self.scrollView];
    [self startObservingContentOffsetForScrollView:self.scrollView];
    
    self.topBar = [[CCPagesContainerTopBar alloc] initWithFrame:CGRectMake(0.,
                                                                           _isBarTop ? 0 : CGRectGetHeight(self.view.frame) - self.topBarHeight,
                                                                           winsize.width,
                                                                           self.topBarHeight)];
    self.topBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.topBar.itemTitleColor = self.pageItemsTitleColor;
    self.topBar.delegate = self;
    [self.view addSubview:self.topBar];
    self.topBar.backgroundColor = self.topBarBackgroundColor;
}

- (void)viewDidUnload
{
    [self stopObservingContentOffset];
    self.scrollView = nil;
    self.topBar = nil;
    self.pageIndicatorView = nil;
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self lifeCycleCallback:@"viewDidAppear:" Animated:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self layoutSubviews];
    [self lifeCycleCallback:@"viewWillAppear:" Animated:animated];
}

#pragma mark - Public

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated
{
    NSAssert(selectedIndex < self.viewControllers.count, @"selectedIndex should belong within the range of the view controllers array");
    UIButton *previosSelectdItem = self.topBar.itemViews[self.selectedIndex];
    UIButton *nextSelectdItem = self.topBar.itemViews[selectedIndex];
    
    [self.scrollView setContentOffset:CGPointMake(selectedIndex * self.scrollWidth, 0.) animated:animated];
    if (selectedIndex == _selectedIndex) {
        self.pageIndicatorView.center = CGPointMake([self.topBar centerForSelectedItemAtIndex:selectedIndex].x,
                                                    [self pageIndicatorCenterY]);
    }
    [UIView animateWithDuration:(animated) ? 0.3 : 0. delay:0. options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        switch (_topBarType) {
            case CCPageContaiinerTopBarTypeText:
            case CCPageContaiinerTopBarTypeLeftMapRightText:
                [previosSelectdItem setTitleColor:self.pageItemsTitleColor forState:UIControlStateNormal];
                [nextSelectdItem setTitleColor:self.selectedPageItemTitleColor forState:UIControlStateNormal];
                break;
            case CCPageContaiinerTopBarTypeUPMapNextText:
            {
                UILabel *titleLabel = (UILabel *)[previosSelectdItem viewWithTag:9999];
                titleLabel.textColor = self.pageItemsTitleColor;
                
                //图片替换
                if (_topBarSelectedImageAry.count) {
                    UIImageView *imageView = (UIImageView *)[previosSelectdItem viewWithTag:8888];
                    imageView.image = [UIImage imageNamed:_topBarImageAry[_selectedIndex]];
                    
                    
                    imageView = (UIImageView *)[nextSelectdItem viewWithTag:8888];
                    imageView.image = [UIImage imageNamed:_topBarSelectedImageAry[selectedIndex]];
                }
                
                titleLabel = (UILabel *)[nextSelectdItem viewWithTag:9999];
                titleLabel.textColor = self.selectedPageItemTitleColor;
            }
                break;
            default:
                break;
        }
        
    } completion:^(BOOL finished) {
        for (NSUInteger i = 0; i < self.viewControllers.count; i++) {
            UIViewController *viewController = self.viewControllers[i];
            viewController.view.frame = CGRectMake(i * self.scrollWidth, 0., self.scrollWidth, self.scrollHeight);
            [self.scrollView addSubview:viewController.view];
        }
    }];
    _selectedIndex = selectedIndex;
    [self slidingCallback];
}

- (void)updateLayoutForNewOrientation:(UIInterfaceOrientation)orientation
{
    [self layoutSubviews];
}

#pragma mark * Overwritten setters

- (void)setPageIndicatorViewSize:(CGSize)size
{
    if ([self.pageIndicatorView isKindOfClass:[CCPageIndicatorView class]]) {
        if (!CGSizeEqualToSize(self.pageIndicatorView.frame.size, size)) {
            _pageIndicatorViewSize = size;
            [self layoutSubviews];
        }
    }
}

- (void)setPageItemsTitleColor:(UIColor *)pageItemsTitleColor
{
    if (![_pageItemsTitleColor isEqual:pageItemsTitleColor]) {
        _pageItemsTitleColor = pageItemsTitleColor;
        self.topBar.itemTitleColor = pageItemsTitleColor;
        [self.topBar.itemViews[self.selectedIndex] setTitleColor:self.selectedPageItemTitleColor forState:UIControlStateNormal];
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setSelectedPageItemTitleColor:(UIColor *)selectedPageItemTitleColor
{
    if (![_selectedPageItemTitleColor isEqual:selectedPageItemTitleColor]) {
        _selectedPageItemTitleColor = selectedPageItemTitleColor;
        [self.topBar.itemViews[self.selectedIndex] setTitleColor:selectedPageItemTitleColor forState:UIControlStateNormal];
    }
}

- (void)setTopBarBackgroundColor:(UIColor *)topBarBackgroundColor
{
    _topBarBackgroundColor = topBarBackgroundColor;
    self.topBar.backgroundColor = topBarBackgroundColor;
    if ([self.pageIndicatorView isKindOfClass:[CCPageIndicatorView class]]) {
        [(CCPageIndicatorView *)self.pageIndicatorView setColor:topBarBackgroundColor];
    }
}

- (void)setTopBarBackgroundImage:(UIImage *)topBarBackgroundImage
{
    self.topBar.backgroundImage = topBarBackgroundImage;
}

- (void)setTopBarHeight:(NSUInteger)topBarHeight
{
    if (_topBarHeight != topBarHeight) {
        _topBarHeight = topBarHeight;
        [self layoutSubviews];
    }
}

- (void)setTopBarItemLabelsFont:(UIFont *)font
{
    self.topBar.font = font;
}

- (void)setIndicatorType:(CCPageIndicatorViewType)indicatorType
{
    _indicatorType = indicatorType;
    
    CCPageIndicatorView *indicatorView = (CCPageIndicatorView *)self.pageIndicatorView;
    indicatorView.indicatorType = _indicatorType;
    
    [self layoutSubviews];
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    if (_viewControllers != viewControllers) {
        _viewControllers = viewControllers;
        if (_topBarType == CCPageContaiinerTopBarTypeUPMapNextText) {
            self.topBar.topBarType = _topBarType;
            self.topBar.topBarImageAry = _topBarImageAry;
        }
        self.topBar.itemTitles = [viewControllers valueForKey:@"title"];
        for (UIViewController *viewController in viewControllers) {
            [viewController willMoveToParentViewController:self];
            viewController.view.frame = CGRectMake(0., 0, CGRectGetWidth(self.scrollView.frame), self.scrollHeight);
            [self.scrollView addSubview:viewController.view];
            [viewController didMoveToParentViewController:self];
        }
        [self layoutSubviews];
        self.selectedIndex = 0;
        self.pageIndicatorView.center = CGPointMake([self.topBar centerForSelectedItemAtIndex:self.selectedIndex].x,
                                                    [self pageIndicatorCenterY]);
    }
}

- (void)setPageIndicatorImage:(UIImage *)pageIndicatorImage
{
    _pageIndicatorImage = pageIndicatorImage;
    self.pageIndicatorViewSize = (pageIndicatorImage) ? pageIndicatorImage.size : self.pageIndicatorViewSize;
    if ((pageIndicatorImage && [self.pageIndicatorView isKindOfClass:[CCPageIndicatorView class]]) || (!pageIndicatorImage && [self.pageIndicatorView isKindOfClass:[UIImageView class]])) {
        [self.pageIndicatorView removeFromSuperview];
        self.pageIndicatorView = nil;
    }
    if (pageIndicatorImage) {
        if ([self.pageIndicatorView isKindOfClass:[CCPageIndicatorView class]]) {
            [self.pageIndicatorView removeFromSuperview];
            self.pageIndicatorView = nil;
        }
        [(UIImageView *)self.pageIndicatorView setImage:pageIndicatorImage];
    } else {
        if ([self.pageIndicatorView isKindOfClass:[UIImageView class]]) {
            [self.pageIndicatorView removeFromSuperview];
            self.pageIndicatorView = nil;
        }
        [(CCPageIndicatorView *)self.pageIndicatorView setColor:self.topBarBackgroundColor];
    }
}

- (void)setTopBarItemsOffset:(CGFloat)topBarItemsOffset
{
    self.topBar.topBarItemsOffset = topBarItemsOffset;
}

- (void)setTopIndicatiorColor:(UIColor *)topIndicatiorColor
{
    _topIndicatiorColor = topIndicatiorColor;
    [self layoutSubviews];
}

- (void)setIsBarTop:(BOOL)isBarTop
{
    _isBarTop = isBarTop;
    [self layoutSubviews];
}

- (void)setBounces:(BOOL)bounces
{
    self.scrollView.bounces = bounces;
}

- (void)setIsCoverd:(BOOL)IsCoverd
{
    [self layoutSubviews];
    self.topBar.IsCovered = IsCoverd;
}

- (void)setHidetabBar:(BOOL)HidetabBar
{
    _HidetabBar = HidetabBar;
    [self layoutSubviews];
}

- (void)setScrollEnabled:(BOOL)scrollEnabled
{
    self.scrollView.scrollEnabled = scrollEnabled;
}

#pragma mark - Private

/**
 *  @author CC, 15-09-28
 *
 *  @brief  滑动回调函数
 */
- (void)slidingCallback
{
    SEL setupDefaultSEL = NSSelectorFromString(@"viewWillRefresh");
    UIViewController *viewController = self.viewControllers[self.selectedIndex];
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        viewController = ((UINavigationController *)viewController).visibleViewController;
    }
    if ([viewController respondsToSelector:setupDefaultSEL])
        [viewController performSelector:setupDefaultSEL withObject:nil afterDelay:.1];
}

/**
 *  @author CC, 15-11-20
 *
 *  @brief  生命周期回传
 */
- (void)lifeCycleCallback:(NSString *)lifeCycleName Animated:(BOOL)animated
{
    for (id view in self.viewControllers) {
        SEL setupDefaultSEL = NSSelectorFromString(lifeCycleName);
        
        UIViewController *viewController = view;
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            viewController = ((UINavigationController *)viewController).visibleViewController;
        }
        
        if ([viewController respondsToSelector:setupDefaultSEL])
            [viewController performSelector:setupDefaultSEL withObject:@(animated) afterDelay:.1];
    }
}

- (void)layoutSubviews
{
    self.scrollView.frame = CGRectMake(0, _isBarTop ? self.topBarHeight : 0, self.scrollWidth, self.scrollHeight);
    self.topBar.frame = CGRectMake(0., _isBarTop ? 0 : CGRectGetHeight(self.view.frame) - self.topBarHeight, CGRectGetWidth(self.view.frame), self.topBarHeight);
    
    self.pageIndicatorView.hidden = NO;
    if (self.HidetabBar) {
        self.pageIndicatorView.hidden = YES;
        self.scrollView.frame = CGRectMake(0, 0, self.scrollWidth, self.scrollHeight);
        self.topBar.frame = CGRectMake(0, _isBarTop ? -self.topBarHeight : CGRectGetHeight(self.view.frame) + self.topBarHeight, CGRectGetWidth(self.view.frame), self.topBarHeight);
    }
    
    CGFloat x = 0.;
    for (UIViewController *viewController in self.viewControllers) {
        viewController.view.frame = CGRectMake(x, 0, winsize.width, self.scrollHeight);
        x += winsize.width;
    }
    
    self.scrollView.contentSize = CGSizeMake(x, 0);
    [self.scrollView setContentOffset:CGPointMake(self.selectedIndex * self.scrollWidth, 0) animated:YES];
    self.pageIndicatorView.center = CGPointMake([self.topBar centerForSelectedItemAtIndex:self.selectedIndex].x,
                                                [self pageIndicatorCenterY]);
    
    self.topBar.scrollView.contentOffset = [self.topBar contentOffsetForSelectedItemAtIndex:self.selectedIndex];
    self.scrollView.userInteractionEnabled = YES;
    
    
    CGRect frame = CGRectZero;
    switch (_indicatorType) {
        case CCPageIndicatorViewTypeInvertedTriangle:
            frame = CGRectMake(0, _isBarTop ? 44 : CGRectGetHeight(self.view.frame) - self.topBarHeight - self.pageIndicatorViewSize.height, self.pageIndicatorViewSize.width, self.pageIndicatorViewSize.height);
            break;
        case CCPageIndicatorViewTypeHorizontalLine:
        case CCPageIndicatorViewTypeLine:
            frame = CGRectMake(0, _isBarTop ? self.topBarHeight - .5 : CGRectGetHeight(self.view.frame) - self.topBarHeight, CGRectGetWidth([UIScreen mainScreen].bounds) / (_viewControllers.count * 1.0), .5);
            break;
        default:
            break;
    }
    _pageIndicatorView.frame = frame;
    [(CCPageIndicatorView *)_pageIndicatorView setColor:_topIndicatiorColor];
    if (_indicatorType == CCPageIndicatorViewTypeLine) {
        self.pageIndicatorView.backgroundColor = _topIndicatiorColor;
    }
}

- (CGFloat)pageIndicatorCenterY
{
    return CGRectGetMaxY(self.topBar.frame) - 2. + CGRectGetHeight(self.pageIndicatorView.frame) / 2.;
}

- (UIView *)pageIndicatorView
{
    if (!_pageIndicatorView) {
        if (self.pageIndicatorImage) {
            _pageIndicatorView = [[UIImageView alloc] initWithImage:self.pageIndicatorImage];
        } else {
            _pageIndicatorView = [[CCPageIndicatorView alloc] initWithFrame:CGRectZero];
            [(CCPageIndicatorView *)_pageIndicatorView setColor:_topIndicatiorColor];
        }
        [self.view addSubview:self.pageIndicatorView];
    }
    return _pageIndicatorView;
}

- (CGFloat)scrollHeight
{
    return CGRectGetHeight(self.view.bounds) - (self.HidetabBar ? 0 : self.topBarHeight);
}

- (CGFloat)scrollWidth
{
    return CGRectGetWidth(self.scrollView.frame);
}

- (void)startObservingContentOffsetForScrollView:(UIScrollView *)scrollView
{
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    self.observingScrollView = scrollView;
}

- (void)stopObservingContentOffset
{
    if (self.observingScrollView) {
        [self.observingScrollView removeObserver:self forKeyPath:@"contentOffset"];
        self.observingScrollView = nil;
    }
}

#pragma mark - CCPagesContainerTopBar delegate

- (void)itemAtIndex:(NSUInteger)index didSelectInPagesContainerTopBar:(CCPagesContainerTopBar *)bar
{
    [self setSelectedIndex:index animated:YES];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSUInteger index = scrollView.contentOffset.x / CGRectGetWidth(self.scrollView.frame);
    if (index != self.selectedIndex)
        self.selectedIndex = index;
    
    self.scrollView.userInteractionEnabled = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        self.scrollView.userInteractionEnabled = YES;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.scrollView.userInteractionEnabled = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.scrollView.userInteractionEnabled = NO;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    
    CGFloat oldX = self.selectedIndex * CGRectGetWidth(self.scrollView.frame);
    if (oldX != self.scrollView.contentOffset.x && self.shouldObserveContentOffset) {
        BOOL scrollingTowards = (self.scrollView.contentOffset.x > oldX);
        NSInteger targetIndex = (scrollingTowards) ? self.selectedIndex + 1 : self.selectedIndex - 1;
        if (targetIndex >= 0 && targetIndex < self.viewControllers.count) {
            CGFloat ratio = (self.scrollView.contentOffset.x - oldX) / CGRectGetWidth(self.scrollView.frame);
            CGFloat previousItemContentOffsetX = [self.topBar contentOffsetForSelectedItemAtIndex:self.selectedIndex].x;
            CGFloat nextItemContentOffsetX = [self.topBar contentOffsetForSelectedItemAtIndex:targetIndex].x;
            CGFloat previousItemPageIndicatorX = [self.topBar centerForSelectedItemAtIndex:self.selectedIndex].x;
            CGFloat nextItemPageIndicatorX = [self.topBar centerForSelectedItemAtIndex:targetIndex].x;
            UIButton *previosSelectedItem = self.topBar.itemViews[self.selectedIndex];
            UIButton *nextSelectedItem = self.topBar.itemViews[targetIndex];
            
            
            CGFloat red, green, blue, alpha, highlightedRed, highlightedGreen, highlightedBlue, highlightedAlpha;
            [self getRed:&red green:&green blue:&blue alpha:&alpha fromColor:self.pageItemsTitleColor];
            [self getRed:&highlightedRed green:&highlightedGreen blue:&highlightedBlue alpha:&highlightedAlpha fromColor:self.selectedPageItemTitleColor];
            
            CGFloat absRatio = fabs(ratio);
            UIColor *prev = [UIColor colorWithRed:red * absRatio + highlightedRed * (1 - absRatio)
                                            green:green * absRatio + highlightedGreen * (1 - absRatio)
                                             blue:blue * absRatio + highlightedBlue * (1 - absRatio)
                                            alpha:alpha * absRatio + highlightedAlpha * (1 - absRatio)];
            UIColor *next = [UIColor colorWithRed:red * (1 - absRatio) + highlightedRed * absRatio
                                            green:green * (1 - absRatio) + highlightedGreen * absRatio
                                             blue:blue * (1 - absRatio) + highlightedBlue * absRatio
                                            alpha:alpha * (1 - absRatio) + highlightedAlpha * absRatio];
            
            [previosSelectedItem setTitleColor:prev forState:UIControlStateNormal];
            [nextSelectedItem setTitleColor:next forState:UIControlStateNormal];
            
            
            if (scrollingTowards) {
                self.topBar.scrollView.contentOffset = CGPointMake(previousItemContentOffsetX +
                                                                   (nextItemContentOffsetX - previousItemContentOffsetX) * ratio,
                                                                   0.);
                self.pageIndicatorView.center = CGPointMake(previousItemPageIndicatorX +
                                                            (nextItemPageIndicatorX - previousItemPageIndicatorX) * ratio,
                                                            [self pageIndicatorCenterY]);
                
            } else {
                self.topBar.scrollView.contentOffset = CGPointMake(previousItemContentOffsetX -
                                                                   (nextItemContentOffsetX - previousItemContentOffsetX) * ratio,
                                                                   0.);
                self.pageIndicatorView.center = CGPointMake(previousItemPageIndicatorX -
                                                            (nextItemPageIndicatorX - previousItemPageIndicatorX) * ratio,
                                                            [self pageIndicatorCenterY]);
            }
        }
    }
}

- (void)getRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha fromColor:(UIColor *)color
{
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor));
    if (colorSpaceModel == kCGColorSpaceModelRGB && CGColorGetNumberOfComponents(color.CGColor) == 4) {
        *red = components[0];
        *green = components[1];
        *blue = components[2];
        *alpha = components[3];
    } else if (colorSpaceModel == kCGColorSpaceModelMonochrome && CGColorGetNumberOfComponents(color.CGColor) == 2) {
        *red = *green = *blue = components[0];
        *alpha = components[1];
    } else {
        *red = *green = *blue = *alpha = 0;
    }
}

@end