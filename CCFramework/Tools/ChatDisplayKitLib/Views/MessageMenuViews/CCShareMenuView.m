//
//  CCShareMenuView.m
//  CCFramework
//
//  Created by C C on 15/8/18.
//  Copyright (c) 2015年 C C. All rights reserved.
//

#import "CCShareMenuView.h"
#import "Config.h"

// 每行有4个
#define kCCShareMenuPerRowItemCount (isiPad ? 10 : 4)
#define kCCShareMenuPerColum 2

@interface CCShareMenuItemView : UIView

/**
 *  第三方按钮
 */
@property(nonatomic, weak) UIButton *shareMenuItemButton;
/**
 *  第三方按钮的标题
 */
@property(nonatomic, weak) UILabel *shareMenuItemTitleLabel;

/**
 *  配置默认控件的方法
 */
- (void)setup;
@end

@implementation CCShareMenuItemView

- (void)setup
{
    if (!_shareMenuItemButton) {
        UIButton *shareMenuItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
        shareMenuItemButton.frame = CGRectMake((CGRectGetWidth(self.bounds) - kCCShareMenuItemWidth) / 2, 0, kCCShareMenuItemWidth, kCCShareMenuItemWidth);
        shareMenuItemButton.backgroundColor = [UIColor clearColor];
        [self addSubview:shareMenuItemButton];

        self.shareMenuItemButton = shareMenuItemButton;
    }

    if (!_shareMenuItemTitleLabel) {
        UILabel *shareMenuItemTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.bounds) - kCCShareMenuItemWidth) / 2, CGRectGetMaxY(self.shareMenuItemButton.frame), kCCShareMenuItemWidth, KCCShareMenuItemHeight - kCCShareMenuItemWidth)];
        shareMenuItemTitleLabel.backgroundColor = [UIColor clearColor];
        shareMenuItemTitleLabel.textColor = [UIColor blackColor];
        shareMenuItemTitleLabel.font = [UIFont systemFontOfSize:12];
        shareMenuItemTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:shareMenuItemTitleLabel];

        self.shareMenuItemTitleLabel = shareMenuItemTitleLabel;
    }
}

- (void)awakeFromNib
{
    [self setup];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

@end

@interface CCShareMenuView () <UIScrollViewDelegate>

/**
 *  这是背景滚动视图
 */
@property(nonatomic, weak) UIScrollView *shareMenuScrollView;

/**
 *  显示页码的视图
 */
@property(nonatomic, weak) UIPageControl *shareMenuPageControl;

/**
 *  第三方按钮点击的事件
 *
 *  @param sender 第三方按钮对象
 */
- (void)shareMenuItemButtonClicked:(UIButton *)sender;

/**
 *  配置默认控件
 */
- (void)setup;

@end

@implementation CCShareMenuView

- (void)shareMenuItemButtonClicked:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(didSelecteShareMenuItem:atIndex:)]) {
        NSInteger index = sender.tag;
        if (index < self.shareMenuItems.count) {
            [self.delegate didSelecteShareMenuItem:[self.shareMenuItems objectAtIndex:index] atIndex:index];
        }
    }
}

- (void)reloadData
{
    if (!_shareMenuItems.count)
        return;

    [self.shareMenuScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    CGFloat paddingX = 16;
    CGFloat paddingY = 16;
    for (CCShareMenuItem *shareMenuItem in self.shareMenuItems) {
        NSInteger index = [self.shareMenuItems indexOfObject:shareMenuItem];
        NSInteger page = index / (kCCShareMenuPerRowItemCount * kCCShareMenuPerColum);
        CGRect shareMenuItemViewFrame = [self frameWithPerRowItem:paddingX paddingY:paddingY atIndex:index onPage:page];

        CCShareMenuItemView *shareMenuItemView = [[CCShareMenuItemView alloc] initWithFrame:shareMenuItemViewFrame];
        shareMenuItemView.shareMenuItemButton.tag = index;
        [shareMenuItemView.shareMenuItemButton addTarget:self action:@selector(shareMenuItemButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [shareMenuItemView.shareMenuItemButton setImage:shareMenuItem.normalIconImage forState:UIControlStateNormal];
        shareMenuItemView.shareMenuItemTitleLabel.text = shareMenuItem.title;

        [self.shareMenuScrollView addSubview:shareMenuItemView];
    }

    self.shareMenuPageControl.numberOfPages = (self.shareMenuItems.count / (kCCShareMenuPerRowItemCount * 2) + (self.shareMenuItems.count % (kCCShareMenuPerRowItemCount * 2) ? 1 : 0));
    [self.shareMenuScrollView setContentSize:CGSizeMake(((self.shareMenuItems.count / (kCCShareMenuPerRowItemCount * 2) + (self.shareMenuItems.count % (kCCShareMenuPerRowItemCount * 2) ? 1 : 0)) * CGRectGetWidth(self.bounds)), CGRectGetHeight(self.shareMenuScrollView.bounds))];
}

- (CGRect)frameWithPerRowItem:(CGFloat)paddingX
                     paddingY:(CGFloat)paddingY
                      atIndex:(NSInteger)index
                       onPage:(NSInteger)page
{
    CGFloat itemW = (CGRectGetWidth(self.bounds) - (kCCShareMenuPerRowItemCount + 1) * paddingX) / kCCShareMenuPerRowItemCount;
    CGFloat itemH = (CGRectGetHeight(self.shareMenuScrollView.bounds) - (kCCShareMenuPerColum + 1) * paddingY) / kCCShareMenuPerColum;

    CGRect itemFrame = CGRectMake((index % kCCShareMenuPerRowItemCount) * (itemW + paddingX) + paddingX + (page * CGRectGetWidth(self.bounds)), ((index / kCCShareMenuPerRowItemCount) - kCCShareMenuPerColum * page) * (itemH + paddingY) + paddingY, itemW, itemH);
    return itemFrame;
}

#pragma mark - Life cycle

- (void)setup
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    if (!_shareMenuScrollView) {
        UIScrollView *shareMenuScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - kXHShareMenuPageControlHeight)];
        shareMenuScrollView.delegate = self;
        shareMenuScrollView.canCancelContentTouches = NO;
        shareMenuScrollView.delaysContentTouches = YES;
        shareMenuScrollView.backgroundColor = self.backgroundColor;
        shareMenuScrollView.showsHorizontalScrollIndicator = NO;
        shareMenuScrollView.showsVerticalScrollIndicator = NO;
        [shareMenuScrollView setScrollsToTop:NO];
        shareMenuScrollView.pagingEnabled = YES;
        [self addSubview:shareMenuScrollView];

        self.shareMenuScrollView = shareMenuScrollView;
    }

    if (!_shareMenuPageControl) {
        UIPageControl *shareMenuPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.shareMenuScrollView.bounds), CGRectGetWidth(self.bounds), kXHShareMenuPageControlHeight)];
        shareMenuPageControl.currentPageIndicatorTintColor = [UIColor colorWithWhite:0.471 alpha:1.000];
        shareMenuPageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.678 alpha:1.000];
        shareMenuPageControl.backgroundColor = self.backgroundColor;
        shareMenuPageControl.hidesForSinglePage = YES;
        shareMenuPageControl.defersCurrentPageDisplay = YES;
        [self addSubview:shareMenuPageControl];

        self.shareMenuPageControl = shareMenuPageControl;
    }
}

- (void)awakeFromNib
{
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)dealloc
{
    self.shareMenuItems = nil;
    self.shareMenuScrollView = nil;
    self.shareMenuPageControl = nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview) {
        [self reloadData];
    }
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //每页宽度
    CGFloat pageWidth = scrollView.frame.size.width;
    //根据当前的坐标与页宽计算当前页码
    NSInteger currentPage = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth)+1;
    [self.shareMenuPageControl setCurrentPage:currentPage];
}

@end
