//
//  CCEmotionManagerView.m
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


#import "CCEmotionManagerView.h"
#import "CCEmotionSectionBar.h"
#import "CCEmotionCollectionViewCell.h"
#import "CCEmotionCollectionViewFlowLayout.h"
#import "Config.h"

@interface CCEmotionManagerView () <UICollectionViewDelegate, UICollectionViewDataSource, CCEmotionSectionBarDelegate>

/**
 *  显示表情的collectView控件
 */
@property(nonatomic, weak) UICollectionView *emotionCollectionView;

/**
 *  显示页码的控件
 */
@property(nonatomic, weak) UIPageControl *emotionPageControl;

@property(nonatomic, weak) UIScrollView *emotionScrollView;

/**
 *  管理多种类别gif表情的滚动试图
 */
@property(nonatomic, weak) CCEmotionSectionBar *emotionSectionBar;

/**
 *  当前选择了哪类gif表情标识
 */
@property(nonatomic, assign) NSInteger selectedIndex;

/**
 *  配置默认控件
 */
- (void)setup;

@end


@implementation CCEmotionManagerView

/**
 *  @author CC, 2015-12-03
 *  
 *  @brief  选中下标
 *
 *  @param selectedIndex 下标
 */
- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    [self.emotionSectionBar currentIndex:_selectedIndex];
    [self.emotionScrollView scrollRectToVisible:CGRectMake(CGRectGetWidth(self.bounds) * _selectedIndex, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - kCCEmotionSectionBarHeight) animated:NO];
}

- (void)reloadData
{
    NSInteger numberOfEmotionManagers = [self.dataSource numberOfEmotionManagers];
    if (!numberOfEmotionManagers) {
        return;
    }
    
    if (!self.emotionSectionBar.emotionManagers.count) {
        self.emotionSectionBar.emotionManagers = [self.dataSource emotionManagersAtManager];
        [self.emotionSectionBar reloadData];
        
        [self initEmotionCollectionView:[self.dataSource emotionManagersAtManager].count];
    }
}

#pragma mark - Life cycle

- (void)setup
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.backgroundColor = [UIColor colorWithWhite:0.961 alpha:1.000];
    self.isShowEmotionStoreButton = YES;
    
    if (!_emotionScrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - kCCEmotionSectionBarHeight)];
        scrollView.delegate = self;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        [scrollView setScrollsToTop:NO];
        scrollView.pagingEnabled = YES;
        [self addSubview:scrollView];
        self.emotionScrollView = scrollView;
    }
    
    if (!_emotionSectionBar) {
        CCEmotionSectionBar *emotionSectionBar = [[CCEmotionSectionBar alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.emotionScrollView.frame), CGRectGetWidth(self.bounds), kCCEmotionSectionBarHeight) showEmotionStoreButton:self.isShowEmotionStoreButton];
        emotionSectionBar.delegate = self;
        emotionSectionBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        emotionSectionBar.backgroundColor = [UIColor colorWithWhite:0.886 alpha:1.000];
        [emotionSectionBar currentIndex:0];
        [self addSubview:emotionSectionBar];
        self.emotionSectionBar = emotionSectionBar;
    }
}

- (void)initEmotionCollectionView:(NSInteger)index
{
    if (self.emotionScrollView) {
        CGFloat x = 0;
        for (int i = 0; i < index; i++) {
            UICollectionView *emotionCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(x, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.emotionScrollView.bounds) - kCCEmotionPageControlHeight) collectionViewLayout:[[CCEmotionCollectionViewFlowLayout alloc] init]];
            emotionCollectionView.backgroundColor = self.backgroundColor;
            [emotionCollectionView registerClass:[CCEmotionCollectionViewCell class] forCellWithReuseIdentifier:kCCEmotionCollectionViewCellIdentifier];
            emotionCollectionView.showsHorizontalScrollIndicator = NO;
            emotionCollectionView.showsVerticalScrollIndicator = NO;
            [emotionCollectionView setScrollsToTop:NO];
            emotionCollectionView.pagingEnabled = YES;
            emotionCollectionView.delegate = self;
            emotionCollectionView.dataSource = self;
            emotionCollectionView.tag = i;
            [self.emotionScrollView addSubview:emotionCollectionView];
            
            
            UIPageControl *emotionPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(x, CGRectGetMaxY(emotionCollectionView.frame), CGRectGetWidth(self.bounds), kCCEmotionPageControlHeight)];
            emotionPageControl.currentPageIndicatorTintColor = [UIColor colorWithWhite:0.471 alpha:1.000];
            emotionPageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.678 alpha:1.000];
            emotionPageControl.backgroundColor = self.backgroundColor;
            emotionPageControl.hidesForSinglePage = YES;
            emotionPageControl.defersCurrentPageDisplay = YES;
            emotionPageControl.tag = 999 + i;
            [self.emotionScrollView addSubview:emotionPageControl];
            x += CGRectGetWidth(self.bounds);
            
            
            CCEmotionManager *emotionManager = [self.dataSource emotionManagerForColumn:i];
            NSInteger numberOfEmotions = emotionManager.emotions.count;
            numberOfEmotions = (numberOfEmotions / (kCCEmotionPerRowItemCount * 2) + (numberOfEmotions % (kCCEmotionPerRowItemCount * 2) ? 0 : 1));
            emotionPageControl.numberOfPages = numberOfEmotions;
        }
        self.emotionScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) * [self.dataSource emotionManagersAtManager].count, self.emotionScrollView.frame.size.height);
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
    self.emotionPageControl = nil;
    self.emotionSectionBar = nil;
    self.emotionCollectionView.delegate = nil;
    self.emotionCollectionView.dataSource = nil;
    self.emotionCollectionView = nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview) {
        [self reloadData];
    }
}

#pragma mark - CCEmotionSectionBar Delegate

- (void)didSelecteEmotionManager:(CCEmotionManager *)emotionManager
                       atSection:(NSInteger)section
{
    if (self.selectedIndex == section) return;
    
    self.selectedIndex = section;
    [self.emotionScrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj isKindOfClass:[UIPageControl class]]) {
            UIPageControl *pageControl = obj;
            pageControl.currentPage = 0;
        }
    }];
    [self reloadData];
}

- (void)didSectionBarStore
{
    if ([self.delegate respondsToSelector:@selector(didStore)])
        [self.delegate didStore];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //每页宽度
    CGFloat pageWidth = scrollView.frame.size.width;
    //根据当前的坐标与页宽计算当前页码
    NSInteger currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if ([scrollView isEqual:self.emotionScrollView]) {
        self.selectedIndex = currentPage;
    } else {
        UIPageControl *emotionPageControl = (UIPageControl *)[self.emotionScrollView viewWithTag:999 + self.selectedIndex];
        [emotionPageControl setCurrentPage:currentPage];
    }
}

#pragma UICollectionView DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    CCEmotionManager *emotionManager = [self.dataSource emotionManagerForColumn:collectionView.tag];
    NSInteger count = emotionManager.emotions.count;
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CCEmotionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCEmotionCollectionViewCellIdentifier forIndexPath:indexPath];
    CCEmotionManager *emotionManager = [self.dataSource emotionManagerForColumn:collectionView.tag];
    cell.emotion = emotionManager.emotions[indexPath.row];
    
    return cell;
}

#pragma mark - UICollectionView delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(didSelecteEmotion:atIndexPath:)]) {
        CCEmotionManager *emotionManager = [self.dataSource emotionManagerForColumn:indexPath.section];
        [self.delegate didSelecteEmotion:emotionManager.emotions[indexPath.row] atIndexPath:indexPath];
    }
}


@end
