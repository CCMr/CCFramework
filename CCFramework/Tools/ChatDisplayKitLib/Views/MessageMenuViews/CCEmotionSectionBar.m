//
//  CCEmotionSectionBar.m
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


#import "CCEmotionSectionBar.h"

#define kCCStoreManagerItemWidth 40

@interface CCEmotionSectionBar ()

/**
 *  是否显示表情商店的按钮
 */
@property(nonatomic, assign) BOOL isShowEmotionStoreButton; // default is YES


@property(nonatomic, weak) UIScrollView *sectionBarScrollView;
@property(nonatomic, weak) UIButton *storeManagerItemButton;

@property(nonatomic, assign) NSInteger currentIndex;

@end

@implementation CCEmotionSectionBar

/**
 *  @author CC, 2015-12-03
 *  
 *  @brief  选中事件
 *
 *  @param sender 按钮
 */
- (void)sectionButtonClicked:(UIButton *)sender
{
    [self currentIndex:sender.tag];
    if ([self.delegate respondsToSelector:@selector(didSelecteEmotionManager:atSection:)]) {
        NSInteger section = sender.tag;
        if (section < self.emotionManagers.count) {
            [self.delegate didSelecteEmotionManager:[self.emotionManagers objectAtIndex:section] atSection:section];
        }
    }
}

/**
 *  @author CC, 2015-12-03
 *  
 *  @brief  商店按钮事件
 *
 *  @param sender 按钮
 */
- (void)didStoreClicked:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(didSectionBarStore)])
        [self.delegate didSectionBarStore];
}

/**
 *  @author CC, 2015-12-03
 *  
 *  @brief  选中下标
 *
 *  @param index 下标
 */
- (void)currentIndex:(NSInteger)index
{
    _currentIndex = index;
    for (UIButton *button in self.sectionBarScrollView.subviews) {
        button.backgroundColor = [UIColor clearColor];
        if (button.tag == index) {
            button.backgroundColor = self.superview.backgroundColor; // [UIColor whiteColor];
            [self.sectionBarScrollView scrollRectToVisible:CGRectMake(button.frame.origin.x, 0, self.sectionBarScrollView.frame.size.width, self.sectionBarScrollView.frame.size.height) animated:YES];
        }
    }
}

- (UIButton *)cratedButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, kCCStoreManagerItemWidth, CGRectGetHeight(self.bounds));
    [button addTarget:self action:@selector(sectionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)reloadData
{
    if (!self.emotionManagers.count)
        return;
    
    [self.sectionBarScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (CCEmotionManager *emotionManager in self.emotionManagers) {
        NSInteger index = [self.emotionManagers indexOfObject:emotionManager];
        UIButton *sectionButton = [self cratedButton];
        sectionButton.tag = index;
        [sectionButton setTitle:emotionManager.emotionName forState:UIControlStateNormal];
        sectionButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [sectionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        if (_currentIndex == index)
            sectionButton.backgroundColor = self.superview.backgroundColor;// [UIColor whiteColor];
        
        CGRect sectionButtonFrame = sectionButton.frame;
        sectionButtonFrame.origin.x = index * (CGRectGetWidth(sectionButtonFrame));
        sectionButton.frame = sectionButtonFrame;
        
        
        [self.sectionBarScrollView addSubview:sectionButton];
    }
    
    [self.sectionBarScrollView setContentSize:CGSizeMake(self.emotionManagers.count * kCCStoreManagerItemWidth, CGRectGetHeight(self.bounds))];
}

#pragma mark - Lefy cycle

- (void)setup
{
    if (!_sectionBarScrollView) {
        CGFloat scrollWidth = CGRectGetWidth(self.bounds);
        if (self.isShowEmotionStoreButton) {
            scrollWidth -= kCCStoreManagerItemWidth;
        }
        UIScrollView *sectionBarScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollWidth, CGRectGetHeight(self.bounds))];
        [sectionBarScrollView setScrollsToTop:NO];
        sectionBarScrollView.showsVerticalScrollIndicator = NO;
        sectionBarScrollView.showsHorizontalScrollIndicator = NO;
        sectionBarScrollView.pagingEnabled = NO;
        [self addSubview:sectionBarScrollView];
        _sectionBarScrollView = sectionBarScrollView;
    }
    
    if (self.isShowEmotionStoreButton) {
        UIButton *storeManagerItemButton = [self cratedButton];
        
        CGRect storeManagerItemButtonFrame = storeManagerItemButton.frame;
        storeManagerItemButtonFrame.origin.x = CGRectGetWidth(self.bounds) - kCCStoreManagerItemWidth;
        storeManagerItemButton.frame = storeManagerItemButtonFrame;
        
        [storeManagerItemButton setTitle:@"商店" forState:UIControlStateNormal];
        [storeManagerItemButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [storeManagerItemButton addTarget:self action:@selector(didStoreClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:storeManagerItemButton];
        _storeManagerItemButton = storeManagerItemButton;
    }
}

- (instancetype)initWithFrame:(CGRect)frame
       showEmotionStoreButton:(BOOL)isShowEmotionStoreButtoned
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.isShowEmotionStoreButton = isShowEmotionStoreButtoned;
        [self setup];
    }
    return self;
}

- (void)dealloc
{
    self.emotionManagers = nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview) {
        [self reloadData];
    }
}

@end
