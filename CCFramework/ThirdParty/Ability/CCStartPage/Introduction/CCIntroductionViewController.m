//
//  CCIntroductionViewController.m
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


#import "CCIntroductionViewController.h"

@interface CCIntroductionViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *pagingScrollView;
/**
 *  @author CC, 15-08-17
 *
 *  @brief  完成按钮
 *
 *  @since 1.0
 */
@property (nonatomic, strong) UIButton *enterButton;

/**
 *  @author CC, 15-08-17
 *
 *  @brief  页码控件
 *
 *  @since 1.0
 */
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, assign) NSInteger centerPageIndex;

@property (nonatomic, strong) NSArray *backgroundViews;
@property (nonatomic, strong) NSArray *scrollViewPages;

@end

@implementation CCIntroductionViewController

/**
 *  @author CC, 15-08-17
 *
 *  @brief  初始化控件
 *
 *  @param coverNames 简介图片数组
 *  @param bgNames    背景图片数组
 *
 *  @return 返回当前控件
 *
 *  @since 1.0
 */
- (id)initWithCoverImageNames:(NSArray *)coverNames
         backgroundImageNames:(NSArray *)bgNames
{
    if (self = [super  init]) {
        [self initSelfWithCoverNames:coverNames backgroundImageNames:bgNames];
    }
    return self;
}

/**
 *  @author CC, 15-08-17
 *
 *  @brief  初始化控件
 *
 *  @param coverNames 简介图片数组
 *  @param bgNames    背景图片数组
 *  @param button     完成按钮
 *
 *  @return 返回当前控件
 *
 *  @since 1.0
 */
- (id)initWithCoverImageNames:(NSArray *)coverNames
         backgroundImageNames:(NSArray *)bgNames
                       button:(UIButton *)button
{
    if (self = [super init]) {
        [self initSelfWithCoverNames:coverNames backgroundImageNames:bgNames];
        self.enterButton = button;
    }
    return self;
}

/**
 *  @author CC, 15-08-17
 *
 *  @brief  初始化数组
 *
 *  @param coverNames 简介图片数组
 *  @param bgNames    背景图片数组
 *
 *  @since 1.0
 */
- (void)initSelfWithCoverNames:(NSArray *)coverNames
          backgroundImageNames:(NSArray *)bgNames
{
    self.coverImageNames = coverNames;
    self.backgroundImageNames = bgNames;
}

/**
 *  @author CC, 15-08-17
 *
 *  @brief  初始化
 *
 *  @since 1.0
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self addBackgroundViews];

    _pagingScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _pagingScrollView.delegate = self;
    _pagingScrollView.pagingEnabled = YES;
    _pagingScrollView.showsHorizontalScrollIndicator = NO;

    [self.view addSubview:self.pagingScrollView];

    _pageControl = [[UIPageControl alloc] initWithFrame:[self frameOfPageControl]];
    self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
    [self.view addSubview:self.pageControl];

    if (!self.enterButton) {
        self.enterButton = [UIButton new];
        [self.enterButton setTitle:NSLocalizedString(@"Enter", nil) forState:UIControlStateNormal];
        self.enterButton.layer.borderWidth = 0.5;
        self.enterButton.layer.borderColor = [UIColor whiteColor].CGColor;
    }

    [_enterButton addTarget:self action:@selector(enter:) forControlEvents:UIControlEventTouchUpInside];
    _enterButton.frame = [self frameOfEnterButton];
    _enterButton.alpha = 0;
    [self.view addSubview:_enterButton];

    [self reloadPages];
}

/**
 *  @author CC, 15-08-17
 *
 *  @brief  初始化控件属性
 *
 *  @since 1.0
 */
- (void)reloadPages
{
    _pageControl.numberOfPages = [[self coverImageNames] count];
    _pagingScrollView.contentSize = [self contentSizeOfScrollView];

    __block CGFloat x = 0;
    [[self scrollViewPages] enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        obj.frame = CGRectOffset(obj.frame, x, 0);
        [self.pagingScrollView addSubview:obj];

        x += obj.frame.size.width;
    }];

    // fix enterButton can not presenting if ScrollView have only one page
    if (_pageControl.numberOfPages == 1) {
        _enterButton.alpha = 1;
        _pageControl.alpha = 0;
    }

    // fix ScrollView can not scrolling if it have only one page
    if (_pagingScrollView.contentSize.width == _pagingScrollView.frame.size.width) {
        _pagingScrollView.contentSize = CGSizeMake(_pagingScrollView.contentSize.width + 1, _pagingScrollView.contentSize.height);
    }
}

/**
 *  @author CC, 15-08-17
 *
 *  @brief  添加背景图片
 *
 *  @since 1.0
 */
- (void)addBackgroundViews
{
    CGRect frame = self.view.bounds;
    NSMutableArray *tmpArray = [NSMutableArray new];
    [[[[self backgroundImageNames] reverseObjectEnumerator] allObjects] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:obj]];
        imageView.frame = frame;
        imageView.tag = idx + 1;
        [tmpArray addObject:imageView];
        [self.view addSubview:imageView];
    }];

    self.backgroundViews = [[tmpArray reverseObjectEnumerator] allObjects];
}

/**
 *  @author CC, 15-08-17
 *
 *  @brief  页码位置
 *
 *  @return 返回页码位置
 *
 *  @since 1.0
 */
- (CGRect)frameOfPageControl
{
    return CGRectMake(0, self.view.bounds.size.height - 30, self.view.bounds.size.width, 30);
}

/**
 *  @author CC, 15-08-17
 *
 *  @brief  设置完成按钮位置
 *
 *  @return 返回按钮位置
 *
 *  @since 1.0
 */
- (CGRect)frameOfEnterButton
{
    CGSize size = self.enterButton.bounds.size;
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        size = CGSizeMake(self.view.frame.size.width * 0.6, 40);
    }
    return CGRectMake(self.view.frame.size.width / 2 - size.width / 2, self.pageControl.frame.origin.y - size.height, size.width, size.height);
}

/**
 *  @author CC, 15-08-17
 *
 *  @brief  完成按钮事件回调
 *
 *  @param sender 当前按钮
 *
 *  @since 1.0
 */
- (void)enter:(id)sender
{
    if (_didSelectedEnter) {
        _didSelectedEnter(@"");
    }
}

/**
 *  @author CC, 15-08-17
 *
 *  @brief  设置回调函数
 *
 *  @param enterBlock 回调函数
 *
 *  @since 1.0
 */
- (void)didSelectedEnter:(Completion)enterBlock
{
    _didSelectedEnter = enterBlock;
}

/**
 *  @author CC, 15-08-17
 *
 *  @brief  当前页的位置
 *
 *  @return 返回页码
 *
 *  @since 1.0
 */
- (CGSize)contentSizeOfScrollView
{
    UIView *view = [[self scrollViewPages] firstObject];
    return CGSizeMake(view.frame.size.width * self.scrollViewPages.count, view.frame.size.height);
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x / self.view.frame.size.width;
    CGFloat alpha = 1 - ((scrollView.contentOffset.x - index * self.view.frame.size.width) / self.view.frame.size.width);

    if ([self.backgroundViews count] > index) {
        UIView *v = [self.backgroundViews objectAtIndex:index];
        if (v) {
            [v setAlpha:alpha];
        }
    }

    self.pageControl.currentPage = scrollView.contentOffset.x / (scrollView.contentSize.width / [self numberOfPagesInPagingScrollView]);

    [self pagingScrollViewDidChangePages:scrollView];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView.panGestureRecognizer translationInView:scrollView.superview].x < 0) {
        if (![self hasNext:self.pageControl]) {
            [self enter:nil];
        }
    }
}

#pragma mark - UIScrollView & UIPageControl DataSource
- (BOOL)hasNext:(UIPageControl*)pageControl
{
    return pageControl.numberOfPages > pageControl.currentPage + 1;
}

- (BOOL)isLast:(UIPageControl*)pageControl
{
    return pageControl.numberOfPages == pageControl.currentPage + 1;
}

- (NSInteger)numberOfPagesInPagingScrollView
{
    return [[self coverImageNames] count];
}

- (void)pagingScrollViewDidChangePages:(UIScrollView *)pagingScrollView
{
    if ([self isLast:self.pageControl]) {
        if (self.pageControl.alpha == 1) {
            self.enterButton.alpha = 0;

            [UIView animateWithDuration:0.4 animations:^{
                self.enterButton.alpha = 1;
                self.pageControl.alpha = 0;
            }];
        }
    } else {
        if (self.pageControl.alpha == 0) {
            [UIView animateWithDuration:0.4 animations:^{
                self.enterButton.alpha = 0;
                self.pageControl.alpha = 1;
            }];
        }
    }
}

- (BOOL)hasEnterButtonInView:(UIView*)page
{
    __block BOOL result = NO;
    [page.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (obj && obj == self.enterButton) {
            result = YES;
        }
    }];
    return result;
}

- (UIImageView*)scrollViewPage:(NSString*)imageName
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    CGSize size = {[[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height};
    imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, size.width, size.height);
    return imageView;
}

- (NSArray*)scrollViewPages
{
    if ([self numberOfPagesInPagingScrollView] == 0) {
        return nil;
    }

    if (_scrollViewPages) {
        return _scrollViewPages;
    }

    NSMutableArray *tmpArray = [NSMutableArray new];
    [self.coverImageNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

        UIImageView *v = [self scrollViewPage:obj];
        [tmpArray addObject:v];

    }];

    _scrollViewPages = tmpArray;

    return _scrollViewPages;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
