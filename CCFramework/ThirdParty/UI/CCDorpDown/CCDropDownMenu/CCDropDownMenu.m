//
//  CCDropDownMenu.m
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

#import "CCDropDownMenu.h"
#import "config.h"
#import "UIView+BUIView.h"
#import "CCPagesContainerTopBar.h"

#define kCCDuration 0.3

@interface CCDropDownMenu () <CCPagesContainerTopBarDelegate>

/**
 *  @author CC, 2016-01-09
 *  
 *  @brief 顶部菜单滑动视图
 */
@property(nonatomic, strong) CCPagesContainerTopBar *topMenuScrollView;

/**
 *  @author CC, 2016-01-09
 *  
 *  @brief 显示视图
 */
@property(nonatomic, strong) UIView *galleryView;

/**
 *  @author CC, 2016-01-09
 *  
 *  @brief 背景查看视图
 */
@property(nonatomic, strong) UIView *backGroundView;

/**
 *  @author CC, 2016-01-09
 *  
 *  @brief 当前选中
 */
@property(nonatomic, assign) NSInteger currentSelectedMenudIndex;

/**
 *  @author CC, 2016-01-09
 *  
 *  @brief 是否显示
 */
@property(nonatomic, assign) BOOL show;


@property(nonatomic, strong) NSArray *titleAry;
@property(nonatomic, strong) NSMutableArray *imageAry;
@property(nonatomic, strong) NSArray *viewAry;

@end

@implementation CCDropDownMenu

- (instancetype)init
{
    if (self = [super init]) {
        [self initialization];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialization];
    }
    return self;
}

/**
 *  @author CC, 2016-01-09
 *  
 *  @brief 下拉菜单
 *
 *  @param frame      菜单栏位置
 *  @param itemsTitle 菜单栏标题
 *  @param itemsView  对应菜单显示视图
 */
- (instancetype)initWithFrame:(CGRect)frame
                   ItemsTitle:(NSArray *)itemsTitle
                    ItemsView:(NSArray *)itemsView
{
    if (self = [super initWithFrame:frame]) {
        self.titleAry = itemsTitle;
        _imageAry = [NSMutableArray array];
        [self.titleAry enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [self.imageAry addObject:@"Selected"];
        }];
        self.viewAry = itemsView;
        [self initialization];
    }
    return self;
}

/**
 *  @author CC, 2016-01-09
 *  
 *  @brief 初始化对象
 */
- (void)initialization
{
    self.backgroundColor = [UIColor clearColor];
    
    self.pageItemsTitleColor = [UIColor blackColor];
    
    self.topMenuScrollView = [[CCPagesContainerTopBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 44)];
    self.topMenuScrollView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.topMenuScrollView.itemTitleColor = self.pageItemsTitleColor;
    self.topMenuScrollView.delegate = self;
    self.topMenuScrollView.topBarType = CCPageContaiinerTopBarTypeLeftTextRightMap;
    self.topMenuScrollView.topBarImageAry = _imageAry;
    self.topMenuScrollView.itemTitles = self.titleAry;
    self.topMenuScrollView.IsCovered = YES;
    self.topMenuScrollView.IsDividingLine = YES;
    self.topMenuScrollView.itemTitleColor = [UIColor blackColor];
    [self addSubview:self.topMenuScrollView];
    
    _backGroundView = [[UIView alloc] initWithFrame:CGRectZero];
    _backGroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    _backGroundView.opaque = NO;
    UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    [_backGroundView addGestureRecognizer:gesture];
    [self addSubview:_backGroundView];
}

- (void)backgroundTapped:(UITapGestureRecognizer *)paramSender
{
    [self animateIdicator:NO complecte:^{
        _show = NO;
        [self scrollEnabled];
    }];
}

- (void)layoutSubviews
{
    self.topMenuScrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    _backGroundView.frame = CGRectMake(0, self.topMenuScrollView.height, winsize.width, winsize.height);
}

/**
 *  @author CC, 2016-01-09
 *  
 *  @brief 菜单选中
 *
 *  @param index 菜单下标
 *  @param bar   选中视图
 */
- (void)itemAtIndex:(NSUInteger)index didSelectInPagesContainerTopBar:(CCPagesContainerTopBar *)bar
{
    if (index == _currentSelectedMenudIndex && _show) {
        [self animateIdicator:NO complecte:^{
            _show = NO;
            [self scrollEnabled];
        }];
    } else {
        if (self.galleryView)
            [self.galleryView removeFromSuperview];
        
        self.galleryView = [self.viewAry objectAtIndex:index];
        [self animateIdicator:YES complecte:^{
            _show = YES;
            [self scrollEnabled];
            self.currentSelectedMenudIndex = index;
        }];
    }
}

/**
 *  @author CC, 2016-01-09
 *  
 *  @brief 控制父类滚动效果
 */
- (void)scrollEnabled
{
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        scrollView.scrollEnabled = !_show;
    }
    
    if (!_show) {
        UIButton *previosSelectdItem = self.topMenuScrollView.itemViews[self.currentSelectedMenudIndex];
        [previosSelectdItem setTitleColor:self.pageItemsTitleColor forState:UIControlStateNormal];
        previosSelectdItem.imageView.transform = CGAffineTransformMakeRotation(0);
    }
}

- (void)setCurrentSelectedMenudIndex:(NSInteger)currentSelectedMenudIndex
{
    [self setCurrentSelectedMenudIndex:currentSelectedMenudIndex animated:YES];
}

- (void)setCurrentSelectedMenudIndex:(NSUInteger)selectedIndex
                            animated:(BOOL)animated
{
    UIButton *previosSelectdItem = self.topMenuScrollView.itemViews[self.currentSelectedMenudIndex];
    UIButton *nextSelectdItem = self.topMenuScrollView.itemViews[selectedIndex];
    
    [UIView animateWithDuration:(animated) ? 0.3 : 0. delay:0. options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [previosSelectdItem setTitleColor:self.pageItemsTitleColor forState:UIControlStateNormal];
        previosSelectdItem.imageView.transform = CGAffineTransformMakeRotation(0);
        
        [nextSelectdItem setTitleColor:self.selectedPageItemTitleColor forState:UIControlStateNormal];
        nextSelectdItem.imageView.transform = CGAffineTransformMakeRotation(M_PI);
        
    } completion:nil];
    _currentSelectedMenudIndex = selectedIndex;
}


#pragma mark :. Animation
- (void)animateIdicator:(BOOL)forward
              complecte:(void (^)())complete
{
    [self animateBackGroundView:forward complete:^{
        [self animateGalleryView:forward complete:^{
            if (complete)
                complete();
        }];
    }];
}

/**
 *  @author CC, 2016-01-09
 *  
 *  @brief 背景动画
 *
 *  @param show     是否显示
 *  @param complete 完成回调 
 */
- (void)animateBackGroundView:(BOOL)show
                     complete:(void (^)())complete
{
    if (show) {
        [self.superview addSubview:self.backGroundView];
        [self.backGroundView.superview addSubview:self];
        
        [UIView animateWithDuration:kCCDuration animations:^{
            self.backGroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        }];
    } else {
        [UIView animateWithDuration:kCCDuration animations:^{
            self.backGroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        } completion:^(BOOL finished) {
            [self.backGroundView removeFromSuperview];
        }];
    }
    complete();
}

/**
 *  @author CC, 2016-01-09
 *  
 *  @brief 展示视图动画
 *
 *  @param show     是否显示
 *  @param complete 完成回调
 */
- (void)animateGalleryView:(BOOL)show
                  complete:(void (^)())complete
{
    CGRect frame = self.galleryView.frame;
    if (show) {
        self.galleryView.frame = CGRectMake(0, self.y + self.height, winsize.width, 0);
        [self.superview addSubview:self.galleryView];
        
        [UIView animateWithDuration:kCCDuration animations:^{
            self.galleryView.frame = CGRectMake(0, self.y + self.height, winsize.width, frame.size.height);
        }];
    } else {
        [UIView animateWithDuration:kCCDuration animations:^{
            self.galleryView.frame = CGRectMake(0, self.y + self.height, winsize.width, 0);
        } completion:^(BOOL finished) {
            [self.galleryView removeFromSuperview];
            self.galleryView.frame = frame;
        }];
    }
    complete();
}


@end
