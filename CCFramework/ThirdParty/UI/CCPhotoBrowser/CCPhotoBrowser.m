/*
 *  CCPhotoBrowser.m
 *  CCPhotoBrowser
 *
 * Copyright (c) 2015 CC (http://www.ccskill.com)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import <QuartzCore/QuartzCore.h>
#import "CCPhotoBrowser.h"
#import "CCPhoto.h"
#import "CCPhotoView.h"
#import "CCPhotoToolbar.h"
#import "Config.h"
#import "UIControl+BUIControl.h"
#import "UIButton+BUIButton.h"
#import "ResourcesPhotos.h"
#import "SDWebImageDownloader.h"

#define kPadding 10
#define kPhotoViewTagOffset 1000
#define kPhotoViewIndex(photoView) ([photoView tag] - kPhotoViewTagOffset)

@interface CCPhotoBrowser () <CCPhotoViewDelegate, CCPhotoToolbarDelegate> {
    // 滚动的view
    UIScrollView *_photoScrollView;
    // 所有的图片view
    NSMutableSet *_visiblePhotoViews;
    NSMutableSet *_reusablePhotoViews;
    // 工具条
    CCPhotoToolbar *_toolbar;
    // 导航栏
    UIView *_NavigationBar;
    
    //选中按钮
    UIButton *NavRightBtn;
    
    BOOL _NavigationBarHiddenInited;
}
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

- (id)initWithNavigationBar
{
    if (self = [super init]) {
        _NavigationBarHiddenInited = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 1.创建UIScrollView
    [self createScrollView];
    
    // 2.创建工具条
    [self createToolbar];
    
    if (_NavigationBarHiddenInited)
        [self NavigationBar];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CCPhoto *photo = _photos[_currentPhotoIndex];
    [NavRightBtn setImage:photo.selectd ? [ResourcesPhotos assetsYES] : [ResourcesPhotos assetsNO] forState:UIControlStateNormal];
}

- (void)show
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.view];
    [window.rootViewController addChildViewController:self];
    window.windowLevel = UIWindowLevelAlert;
    
    if (_currentPhotoIndex == 0) {
        [self showPhotos];
    }
}

#pragma mark - 创建导航栏
- (void)NavigationBar
{
    _NavigationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winsize.width, 44)];
    //    _NavigationBar.backgroundColor = Color(0, 0, 0, .5);
    _NavigationBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_NavigationBar];
    
    UIButton *NavLeftBtn = [UIButton buttonWith];
    NavLeftBtn.frame = CGRectMake(10, 10, 15, 25);
    [NavLeftBtn setImage:[ResourcesPhotos retuens] forState:UIControlStateNormal];
    [NavLeftBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        [self photoViewSingleTap:nil];
        [self photoViewDidEndZoom:nil];
    }];
    [_NavigationBar addSubview:NavLeftBtn];
    
    
    NavRightBtn = [UIButton buttonWith];
    NavRightBtn.frame = CGRectMake(winsize.width - 50, 5, 35, 35);
    [NavRightBtn setImage:[ResourcesPhotos assetsNO] forState:UIControlStateNormal];
    [NavRightBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        if (self.delegate != nil && [self.delegate  respondsToSelector:@selector(didSelectd:)]){
            CCPhoto *photo = _photos[_currentPhotoIndex];
            photo.selectd = !photo.selectd;
            [NavRightBtn setImage:photo.selectd ? [ResourcesPhotos assetsYES] : [ResourcesPhotos assetsNO] forState:UIControlStateNormal];
            [_toolbar updataSelectd];
            
            NSUInteger indexs = _currentPhotoIndex;
            if (photo.IsIndex)
                indexs = photo.asssetIndex;
            [self.delegate didSelectd:indexs];
        }
    }];
    [_NavigationBar addSubview:NavRightBtn];
}

#pragma mark 创建工具条
- (void)createToolbar
{
    CGFloat barHeight = 44;
    CGFloat barY = self.view.frame.size.height - barHeight;
    _toolbar = [[CCPhotoToolbar alloc] init];
    if (_NavigationBarHiddenInited)
        _toolbar = [[CCPhotoToolbar alloc] initWithComplete];
    _toolbar.photoToolbarDelegate = self;
    _toolbar.frame = CGRectMake(0, barY, self.view.frame.size.width, barHeight);
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _toolbar.photos = _photos;
    [_toolbar updataSelectd];
    [self.view addSubview:_toolbar];
    
    [self updateTollbarState];
}

#pragma mark 创建UIScrollView
- (void)createScrollView
{
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
    _photoScrollView.contentSize = CGSizeMake(frame.size.width * _photos.count, 0);
    [self.view addSubview:_photoScrollView];
    _photoScrollView.contentOffset = CGPointMake(_currentPhotoIndex * frame.size.width, 0);
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
     UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.windowLevel = UIWindowLevelNormal;
    self.view.backgroundColor = [UIColor clearColor];
    
    // 移除工具条
    [_toolbar removeFromSuperview];
    [_NavigationBar removeFromSuperview];
}

- (void)photoViewDidEndZoom:(CCPhotoView *)photoView
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
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
    _currentPhotoIndex = _photoScrollView.contentOffset.x / _photoScrollView.frame.size.width;
    _toolbar.currentPhotoIndex = _currentPhotoIndex;
    CCPhoto *photo = _photos[_currentPhotoIndex];
    [NavRightBtn setImage:photo.selectd ? [ResourcesPhotos assetsYES] : [ResourcesPhotos assetsNO] forState:UIControlStateNormal];
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self showPhotos];
    [self updateTollbarState];
}
@end