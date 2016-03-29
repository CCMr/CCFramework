//
//  CCPhotoBrowser.m
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

#import <QuartzCore/QuartzCore.h>
#import "CCPhotoBrowser.h"
#import "CCPhoto.h"
#import "CCPhotoView.h"
#import "CCPhotoToolbar.h"
#import "Config.h"
#import "UIControl+Additions.h"
#import "UIButton+Additions.h"
#import "SDWebImageDownloader.h"
#import "UIViewController+Additions.h"
#import "UIView+Method.h"
#import "UIView+Frame.h"

#define kPadding 10
#define kPhotoViewTagOffset 1000
#define kPhotoViewIndex(photoView) ([photoView tag] - kPhotoViewTagOffset)

@interface CCPhotoBrowser () <CCPhotoViewDelegate, CCPhotoToolbarDelegate>

@property(nonatomic, strong) UIScrollView *photoScrollView;
@property(nonatomic, strong) NSMutableSet *visiblePhotoViews;
@property(nonatomic, strong) NSMutableSet *reusablePhotoViews;
@property(nonatomic, strong) CCPhotoToolbar *toolbar;
@property(nonatomic, strong) UIView *topBar;
@property(nonatomic, strong) UIButton *stateButton;

@property(nonatomic, assign) PhotoBrowserType photoType;

@end

@implementation CCPhotoBrowser

#pragma mark - Lifecycle
- (void)loadView
{
    self.view = [[UIView alloc] init];
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor blackColor];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (instancetype)initWithBarType:(PhotoBrowserType)type
{
    if (self = [super init]) {
        self.photoType = type;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self initialization];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CCPhoto *photo = _photos[_currentPhotoIndex];
    self.stateButton.selected = photo.selectd;
    [self showPhotos];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)initialization
{
    [self.view addSubview:self.photoScrollView];
    if (self.bottomBar) {
        CGRect frame = self.bottomBar.frame;
        frame.origin.y = winsize.height - _bottomBar.height;
        self.bottomBar.frame = frame;
        self.bottomBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self.view addSubview:self.bottomBar];
    } else {
        [self.view addSubview:self.toolbar];
    }
    
    if (self.photoType == PhotoBrowserTypePushNavigationBar) {
        [self pushNavigationTool];
    } else if (self.photoType == PhotoBrowserTypePush) {
        [self.view addSubview:self.topBar];
    }
}

#pragma mark :. 保留系统导航栏
- (void)pushNavigationTool
{
    [self backButtonTouched:^(UIViewController *vc) {
        CCPhotoBrowser *viewController = (CCPhotoBrowser *)vc;
        if (viewController.backPhotoBlock) {
            NSMutableArray *array = [NSMutableArray array];
            [viewController.photos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CCPhoto *photo = obj;
                [array addObject:photo.image];
            }];
            viewController.backPhotoBlock(array);
        }
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deletePhoto)];
}

- (void)deletePhoto
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.photos];
    [array removeObjectAtIndex:self.currentPhotoIndex];
    self.photos = array;
    if (array.count) {
        NSInteger index = self.currentPhotoIndex - 1;
        if (index < 0)
            index = 0;
        
        [_photoScrollView removeAllSubviews];
        self.currentPhotoIndex = index;
    } else {
        self.backPhotoBlock(@[]);
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)show
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (self.photoType == PhotoBrowserTypeShow) {
        [window addSubview:self.view];
        [window.rootViewController addChildViewController:self];
        window.windowLevel = UIWindowLevelAlert;
    } else if (self.photoType == PhotoBrowserTypePush) {
        [window.rootViewController presentPopupViewController:self animationType:CCPopupViewAnimationSlideRightLeft];
    }
}

#pragma mark - 创建导航栏
- (UIView *)topBar
{
    if (!_topBar) {
        CGFloat originY = iOS7Later ? 20 : 0;
        _topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, originY + 44)];
        _topBar.backgroundColor = [UIColor colorWithRed:34 / 255.0f green:34 / 255.0f blue:34 / 255.0f alpha:.7f];
        
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setImage:CCResourceImage(@"navi_back") forState:UIControlStateNormal];
        [backButton setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        [backButton sizeToFit];
        backButton.frame = CGRectMake(12, _topBar.frame.size.height / 2 - backButton.frame.size.height / 2 + originY / 2, backButton.frame.size.width, backButton.frame.size.height);
        [backButton addTarget:self action:@selector(handleBackAction) forControlEvents:UIControlEventTouchUpInside];
        [_topBar addSubview:backButton];
        
        UIButton *stateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [stateButton setImage:CCResourceImage(@"photo_def_previewVc") forState:UIControlStateNormal];
        [stateButton setImage:CCResourceImage(@"photo_sel_photoPickerVc") forState:UIControlStateSelected];
        [stateButton setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        [stateButton sizeToFit];
        stateButton.frame = CGRectMake(_topBar.frame.size.width - 12 - stateButton.frame.size.width, _topBar.frame.size.height / 2 - stateButton.frame.size.height / 2 + originY / 2, stateButton.frame.size.width, stateButton.frame.size.height);
        [stateButton addTarget:self action:@selector(handleStateChangeAction:) forControlEvents:UIControlEventTouchUpInside];
//        [_topBar addSubview:self.stateButton = stateButton];
    }
    return _topBar;
}

- (void)handleBackAction
{
    [self photoViewSingleTap:nil];
    [self photoViewDidEndZoom:nil];
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissPopupViewControllerWithanimationType:CCPopupViewAnimationSlideLeftRight];
}

- (void)handleStateChangeAction:(UIButton *)sender
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didSelectd:)]) {
        CCPhoto *photo = _photos[_currentPhotoIndex];
        photo.selectd = !photo.selectd;
        sender.selected = !sender.selected;
        
        CAKeyframeAnimation *scaoleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        scaoleAnimation.duration = 0.25;
        scaoleAnimation.autoreverses = YES;
        scaoleAnimation.values = @[ [NSNumber numberWithFloat:1.0], [NSNumber numberWithFloat:1.2], [NSNumber numberWithFloat:1.0] ];
        scaoleAnimation.fillMode = kCAFillModeForwards;
        
        [sender.layer removeAllAnimations];
        [sender.layer addAnimation:scaoleAnimation forKey:@"transform.rotate"];
        
        [_toolbar updataSelectd];
        
        NSUInteger indexs = _currentPhotoIndex;
        if (photo.IsIndex)
            indexs = photo.asssetIndex;
        [self.delegate didSelectd:indexs];
    }
}

#pragma mark :. 底部工具条

- (CCPhotoToolbar *)toolbar
{
    if (!_toolbar) {
        _toolbar = [[CCPhotoToolbar alloc] initWithFrame:CGRectMake(0, winsize.height - 44, winsize.width, 44)];
        _toolbar.photoToolbarDelegate = self;
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _toolbar.photos = _photos;
        [_toolbar updataSelectd];
        [self updateTollbarState];
    }
    return _toolbar;
}

#pragma mark 创建UIScrollView

- (UIScrollView *)photoScrollView
{
    if (!_photoScrollView) {
        CGRect frame = self.view.bounds;
        frame.origin.x -= kPadding;
        frame.size.width += (2 * kPadding);
        _photoScrollView = [[UIScrollView alloc] initWithFrame:frame];
        _photoScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _photoScrollView.pagingEnabled = YES;
        _photoScrollView.delegate = self;
        _photoScrollView.showsHorizontalScrollIndicator = NO;
        _photoScrollView.showsVerticalScrollIndicator = NO;
        _photoScrollView.backgroundColor = [UIColor clearColor];
        _photoScrollView.contentSize = CGSizeMake(_photoScrollView.frame.size.width * _photos.count, 0);
        _photoScrollView.contentOffset = CGPointMake(_currentPhotoIndex * frame.size.width, 0);
    }
    return _photoScrollView;
}

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    
    if (photos.count > 1) {
        _visiblePhotoViews = [NSMutableSet set];
        _reusablePhotoViews = [NSMutableSet set];
    }
    
    for (int i = 0; i < _photos.count; i++) {
        CCPhoto *photo = _photos[i];
        photo.index = i;
        photo.firstShow = i == _currentPhotoIndex;
    }
}

#pragma mark 设置选中的图片
- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex
{
    _currentPhotoIndex = currentPhotoIndex;
    
    self.title = [NSString stringWithFormat:@"%zi/%zi", _currentPhotoIndex + 1, self.photos.count];
    
    for (int i = 0; i < _photos.count; i++) {
        CCPhoto *photo = _photos[i];
        photo.firstShow = i == currentPhotoIndex;
    }
    
    if ([self isViewLoaded]) {
        _photoScrollView.contentOffset = CGPointMake(_currentPhotoIndex * _photoScrollView.frame.size.width, 0);
        
        // 显示所有的相片
        [self showPhotos];
    }
}

#pragma mark - CCPhotoView代理
- (void)photoViewSingleTap:(CCPhotoView *)photoView
{
    if (self.photoType == PhotoBrowserTypeShow) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        window.windowLevel = UIWindowLevelNormal;
        self.view.backgroundColor = [UIColor clearColor];
        
        // 移除工具条
        [_toolbar removeFromSuperview];
        [self.topBar removeFromSuperview];
    } else if (self.photoType == PhotoBrowserTypePush) {
        if (photoView) {
            [self setBarHidden:!self.topBar.hidden animated:YES];
        }
    }
}

- (void)setBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (!animated) {
        self.topBar.hidden = self.toolbar.hidden = hidden;
        self.bottomBar.y -= hidden ? 40 : -80;
        return;
    }
    [UIView animateWithDuration:.15 animations:^{
        self.topBar.alpha = self.toolbar.alpha = hidden ? .0f : 1.0f;
        if (hidden)
            self.bottomBar.y += 40;
        else
             self.bottomBar.y -= 40;
    } completion:^(BOOL finished) {
        self.topBar.hidden = self.toolbar.hidden = hidden;
        [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
    }];
}

- (void)photoViewDidEndZoom:(CCPhotoView *)photoView
{
    if (self.photoType == PhotoBrowserTypeShow) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }
}

- (void)photoViewImageFinishLoad:(CCPhotoView *)photoView
{
    _toolbar.currentPhotoIndex = _currentPhotoIndex;
}

#pragma mark - CCPhotoToolbar代理
- (void)didComplete:(CCPhotoToolbar *)toolbar
{
    [self photoViewSingleTap:nil];
    [self photoViewDidEndZoom:nil];
    
    // 通知代理
    if ([self.delegate respondsToSelector:@selector(didComplete:)])
        [self.delegate didComplete:_currentPhotoIndex];
}

#pragma mark 显示照片
- (void)showPhotos
{
    // 只有一张图片
    if (_photos.count == 1) {
        [self showPhotoViewAtIndex:0];
        return;
    }
    
    CGRect visibleBounds = _photoScrollView.bounds;
    int firstIndex = (int)floorf((CGRectGetMinX(visibleBounds) + kPadding * 2) / CGRectGetWidth(visibleBounds));
    int lastIndex = (int)floorf((CGRectGetMaxX(visibleBounds) - kPadding * 2 - 1) / CGRectGetWidth(visibleBounds));
    if (firstIndex < 0) firstIndex = 0;
    if (firstIndex >= _photos.count) firstIndex = (int)_photos.count - 1;
    if (lastIndex < 0) lastIndex = 0;
    if (lastIndex >= _photos.count) lastIndex = (int)_photos.count - 1;
    
    // 回收不再显示的ImageView
    NSInteger photoViewIndex;
    for (CCPhotoView *photoView in _visiblePhotoViews) {
        photoViewIndex = kPhotoViewIndex(photoView);
        if (photoViewIndex < firstIndex || photoViewIndex > lastIndex) {
            [_reusablePhotoViews addObject:photoView];
            [photoView removeFromSuperview];
        }
    }
    
    [_visiblePhotoViews minusSet:_reusablePhotoViews];
    while (_reusablePhotoViews.count > 2) {
        [_reusablePhotoViews removeObject:[_reusablePhotoViews anyObject]];
    }
    
    for (NSUInteger index = firstIndex; index <= lastIndex; index++) {
        if (![self isShowingPhotoViewAtIndex:index]) {
            [self showPhotoViewAtIndex:index];
        }
    }
}

#pragma mark 显示一个图片view
- (void)showPhotoViewAtIndex:(NSUInteger)index
{
    CCPhotoView *photoView = [self dequeueReusablePhotoView];
    if (!photoView) { // 添加新的图片view
        photoView = [[CCPhotoView alloc] init];
        photoView.photoViewDelegate = self;
    }
    
    photoView.isHandleSingle = self.photoType == PhotoBrowserTypeShow;
    
    // 调整当期页的frame
    CGRect bounds = _photoScrollView.bounds;
    CGRect photoViewFrame = bounds;
    photoViewFrame.size.width -= (2 * kPadding);
    photoViewFrame.origin.x = (bounds.size.width * index) + kPadding;
    photoView.tag = kPhotoViewTagOffset + index;
    
    CCPhoto *photo = _photos[index];
    photoView.frame = photoViewFrame;
    photoView.photo = photo;
    
    [_visiblePhotoViews addObject:photoView];
    [_photoScrollView addSubview:photoView];
    
    [self loadImageNearIndex:index];
}

#pragma mark 加载index附近的图片
- (void)loadImageNearIndex:(NSUInteger)index
{
    if (index > 0) {
        CCPhoto *photo = _photos[index - 1];
        [SDWebImageDownloader.sharedDownloader downloadImageWithURL:photo.url options:0 progress:nil completed:nil];
    }
    
    if (index < _photos.count - 1) {
        CCPhoto *photo = _photos[index + 1];
        [SDWebImageDownloader.sharedDownloader downloadImageWithURL:photo.url options:0 progress:nil completed:nil];
    }
}

#pragma mark index这页是否正在显示
- (BOOL)isShowingPhotoViewAtIndex:(NSUInteger)index
{
    for (CCPhotoView *photoView in _visiblePhotoViews) {
        if (kPhotoViewIndex(photoView) == index) {
            return YES;
        }
    }
    return NO;
}

#pragma mark 循环利用某个view
- (CCPhotoView *)dequeueReusablePhotoView
{
    CCPhotoView *photoView = [_reusablePhotoViews anyObject];
    if (photoView) {
        [_reusablePhotoViews removeObject:photoView];
    }
    return photoView;
}

#pragma mark 更新toolbar状态
- (void)updateTollbarState
{
    _photoScrollView.contentSize = CGSizeMake(_photoScrollView.frame.size.width * _photos.count, 0);
    _currentPhotoIndex = _photoScrollView.contentOffset.x / _photoScrollView.frame.size.width;
    if (!self.bottomBar)
        _toolbar.currentPhotoIndex = _currentPhotoIndex;
    CCPhoto *photo = _photos[_currentPhotoIndex];
    
    self.stateButton.selected = photo.selectd;
    
    self.title = [NSString stringWithFormat:@"%zi/%zi", _currentPhotoIndex + 1, self.photos.count];
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self showPhotos];
    [self updateTollbarState];
}
@end