//
//  SmoothViewController.m
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

#import "SmoothViewController.h"
#import "SmoothScrollView.h"

@interface SmoothViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) SmoothScrollView *scrollView;

/**
 *  @author CC, 15-08-17
 *
 *  @brief  页码控件
 *
 *  @since 1.0
 */
@property (nonatomic, strong) UIPageControl *pageControl;

/**
 *  @author CC, 15-08-17
 *
 *  @brief  完成按钮
 *
 *  @since 1.0
 */
@property (nonatomic, strong) UIButton *enterButton;

@end

@implementation SmoothViewController

/**
 *  @author CC, 15-08-17
 *
 *  @brief  初始化控件
 *
 *  @param bgNames    背景图片数组
 *
 *  @return 返回当前控件
 *
 *  @since 1.0
 */
- (id)initWithCoverImageNames: (NSArray *)bgNames
{
    if (self = [super init]) {
        _images = bgNames;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initPrepare];
}

/**
 *  @author CC, 15-08-21
 *
 *  @brief  是否显示
 *
 *  @return <#return value description#>
 *
 *  @since <#1.0#>
 */
+ (BOOL)canShowNewFeature
{
    BOOL firstStart = NO;
    if (![userDefaults objectForKey:@"firstStart"] || [[userDefaults objectForKey:@"firstStart"] isEqualToString:@"YES"]) {
        firstStart = YES;
        [userDefaults setObject:@"YES" forKey:@"firstStart"];
        [userDefaults synchronize];
    }
     return firstStart;
}

- (void)initPrepare
{
    _scrollView = [[SmoothScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_scrollView];

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
 *  @author CC, 15-09-11
 *
 *  @brief  设置完成按钮背景图片
 *
 *  @param enterBackgroundImage 图片
 *
 *  @since 1.0
 */
-(void)setEnterBackgroundImage:(NSString *)enterBackgroundImage
{
    [self.enterButton setBackgroundImage:[UIImage imageNamed:enterBackgroundImage] forState:UIControlStateNormal];
}

/**
 *  @author CC, 15-09-11
 *
 *  @brief  设置完成按钮大小
 *
 *  @param enterSzie 大小
 *
 *  @since 1.0
 */
- (void)setEnterSzie:(CGSize)enterSzie
{
    self.enterButton.frame = CGRectMake(self.view.frame.size.width / 2 - enterSzie.width / 2, self.pageControl.frame.origin.y - enterSzie.height, enterSzie.width, enterSzie.height);
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
    _pageControl.numberOfPages = [_images count];
    _scrollView.contentSize = [self contentSizeOfScrollView];

    WEAKSELF
    [_images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIImageView *imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:obj]];
        [weakSelf.scrollView addSubview:imageV];
    }];

    // fix enterButton can not presenting if ScrollView have only one page
    if (_pageControl.numberOfPages == 1) {
        _enterButton.alpha = 1;
        _pageControl.alpha = 0;
    }

    // fix ScrollView can not scrolling if it have only one page
    if (_scrollView.contentSize.width == _scrollView.frame.size.width) {
        _scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width + 1, _scrollView.contentSize.height);
    }
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
    [userDefaults setObject:@"NO" forKey:@"firstStart"];
    [userDefaults synchronize];

    if (_didSelectedEnter) {
        _didSelectedEnter(@"");
    }
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
 *  @brief  当前页的位置
 *
 *  @return 返回页码
 *
 *  @since 1.0
 */
- (CGSize)contentSizeOfScrollView
{
    return CGSizeMake(_scrollView.frame.size.width * _images.count, _scrollView.frame.size.height);
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

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = scrollView.contentOffset.x / (scrollView.contentSize.width / [self numberOfPagesInPagingScrollView]);

    [self pagingScrollViewDidChangePages:scrollView];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView.panGestureRecognizer translationInView:scrollView.superview].x < 0) {
        if (![self hasNext:self.pageControl]) {
//            [self enter:nil];
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
    return [_images count];
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

#pragma mark - 转屏
-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

-(void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id  context) {
        if (newCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {

        } else {

        }
        self.view.frame = self.view.bounds;
        [self.view setNeedsLayout];
    } completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
