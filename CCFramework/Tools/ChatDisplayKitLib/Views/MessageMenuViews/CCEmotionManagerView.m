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
#import "CCEmotionView.h"
#import "Config.h"

@interface CCEmotionManagerView () <UIScrollViewDelegate, CCEmotionSectionBarDelegate, CCEmotionViewDelegate>


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

@property(nonatomic, strong) NSMutableArray *indexs;


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
    if (selectedIndex < 0) return;

    _selectedIndex = selectedIndex;
    self.emotionPageControl.numberOfPages = [[self.indexs objectAtIndex:selectedIndex] integerValue];

    self.emotionPageControl.hidden = NO;
    if (!self.emotionPageControl.numberOfPages)
        self.emotionPageControl.hidden = YES;


    [self.emotionSectionBar currentIndex:_selectedIndex];
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
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - kCCEmotionSectionBarHeight - kCCEmotionPageControlHeight)];
        scrollView.delegate = self;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        [scrollView setScrollsToTop:NO];
        scrollView.pagingEnabled = YES;
        [self addSubview:scrollView];
        self.emotionScrollView = scrollView;
    }

    if (!_emotionPageControl) {
        UIPageControl *emotionPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.emotionScrollView.frame), CGRectGetWidth(self.bounds), kCCEmotionPageControlHeight)];
        emotionPageControl.currentPageIndicatorTintColor = [UIColor colorWithWhite:0.471 alpha:1.000];
        emotionPageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.678 alpha:1.000];
        emotionPageControl.backgroundColor = self.backgroundColor;
        emotionPageControl.hidesForSinglePage = YES;
        emotionPageControl.defersCurrentPageDisplay = YES;
        [self addSubview:emotionPageControl];
        self.emotionPageControl = emotionPageControl;
    }

    if (!_emotionSectionBar) {
        CCEmotionSectionBar *emotionSectionBar = [[CCEmotionSectionBar alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.emotionPageControl.frame), CGRectGetWidth(self.bounds), kCCEmotionSectionBarHeight) showEmotionStoreButton:self.isShowEmotionStoreButton];
        emotionSectionBar.delegate = self;
        emotionSectionBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        emotionSectionBar.backgroundColor = [UIColor whiteColor]; //[UIColor colorWithWhite:0.886 alpha:1.000];
        [emotionSectionBar currentIndex:0];
        [self addSubview:emotionSectionBar];
        self.emotionSectionBar = emotionSectionBar;
    }
}

- (void)initEmotionCollectionView:(NSInteger)index
{
    if (self.emotionScrollView) {
        self.indexs = [NSMutableArray array];
        CGRect frame = CGRectMake(0, 0, self.emotionScrollView.frame.size.width, self.emotionScrollView.frame.size.height);
        for (int i = 0; i < index; i++) {

            CCEmotionManager *emotionManager = [self.dataSource emotionManagerForColumn:i];
            NSInteger numberOfEmotions = emotionManager.emotions.count;
            NSInteger section = 2;
            NSInteger row = 4;
            if (emotionManager.section != 0 && emotionManager.row != 0) {
                section = emotionManager.section;
                row = emotionManager.row;
            }

            numberOfEmotions = (numberOfEmotions / (section * row) + (numberOfEmotions % (section * row) == 0 ? 0 : 1));

            if (emotionManager.emotionType == CCEmotionTypeSmall && i == 0) {
                //添加每页删除按钮
                numberOfEmotions = emotionManager.emotions.count + numberOfEmotions;
                numberOfEmotions = (numberOfEmotions / (section * row) + (numberOfEmotions % (section * row) == 0 ? 0 : 1));
                self.emotionPageControl.numberOfPages = numberOfEmotions;
                self.emotionPageControl.currentPage = 0;
            }

            [self.indexs addObject:@(numberOfEmotions)];


            NSInteger max = section * row;
            if (emotionManager.emotionType == CCEmotionTypeSmall)
                max -= 1;

            for (int j = 0; j < numberOfEmotions; j++) {

                NSArray *data = [emotionManager.emotions subarrayWithRange:NSMakeRange(j * max, j == numberOfEmotions - 1 ? (emotionManager.emotions.count - j * max) % (max + 1) : max)];

                if (data.count) {
                    CCEmotionView *emotionView = [[CCEmotionView alloc] initWithFrame:frame
                                                                              Section:section
                                                                                  Row:row
                                                                           dataSource:data
                                                                          EmotionType:emotionManager.emotionType];
                    //                emotionView.emotionType = emotionManager.emotionType;
                    emotionView.delegate = self;
                    [self.emotionScrollView addSubview:emotionView];
                    frame.origin.x += frame.size.width;
                }
            }
        }
        self.emotionScrollView.contentSize = CGSizeMake(frame.origin.x, self.emotionScrollView.frame.size.height);
    }
}

- (void)setIsSendButton:(BOOL)isSendButton
{
    _isSendButton = isSendButton;
    self.emotionSectionBar.isSendButton = isSendButton;
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
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview) {
        [self reloadData];
    }
}

/**
 *  @author CC, 2015-12-11
 *
 *  @brief  表情视图回调
 *
 *  @param emotionView 表情视图
 *  @param emotion     表情对象
 *  @param emotionType 表情类型
 */
- (void)didSelected:(CCEmotionView *)emotionView
            Emotion:(CCEmotion *)emotion
        EmotionType:(NSInteger)emotionType
{
    if (emotionType == CCEmotionTypedefault) {
        if ([self.delegate respondsToSelector:@selector(didSelecteEmotion:atIndexPath:)]) {
            [self.delegate didSelecteEmotion:emotion
                                 atIndexPath:nil];
        }
    } else if (emotionType == CCEmotionTypeSmall) {
        if ([self.delegate respondsToSelector:@selector(didSelecteSmallEmotion:atIndexPath:)]) {
            [self.delegate didSelecteSmallEmotion:emotion
                                      atIndexPath:nil];
        }
    }
}

#pragma mark - CCEmotionSectionBar Delegate

- (void)didSelecteEmotionManager:(CCEmotionManager *)emotionManager
                       atSection:(NSInteger)section
{
    if (self.selectedIndex == section) return;

    self.emotionPageControl.currentPage = 0;
    self.selectedIndex = section;

    NSInteger index = 0;
    for (int i = 0; i <= self.selectedIndex; i++)
        index += [[self.indexs objectAtIndex:i] integerValue];

    [self.emotionScrollView scrollRectToVisible:CGRectMake(CGRectGetWidth(self.bounds) * (index - self.emotionPageControl.numberOfPages), 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - kCCEmotionSectionBarHeight) animated:NO];

    [self reloadData];
}

- (void)didSectionBarStore
{
    if ([self.delegate respondsToSelector:@selector(didStore)])
        [self.delegate didStore];
}

- (void)didSectionBarSend
{
    if ([self.delegate respondsToSelector:@selector(didSendMessage)])
        [self.delegate didSendMessage];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //每页宽度
    CGFloat pageWidth = scrollView.frame.size.width;
    //根据当前的坐标与页宽计算当前页码
    NSInteger currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if ([scrollView isEqual:self.emotionScrollView]) {

        NSInteger index = 0;
        NSInteger selectIndex = _selectedIndex;
        for (int i = 0; i <= selectIndex; i++)
            index += [[self.indexs objectAtIndex:i] integerValue];

        if (currentPage > index - 1) {
            self.selectedIndex++;
            currentPage = 0;
        } else {
            NSInteger ix = selectIndex;
            if (currentPage < [[self.indexs objectAtIndex:ix] integerValue])
                self.selectedIndex--;
        }
        self.emotionPageControl.currentPage = currentPage;
    }
}

@end
