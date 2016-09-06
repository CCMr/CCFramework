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
#import "UIButton+Additions.h"

#define kCCStoreManagerItemWidth 50

@interface CCEmotionSectionBar ()

/**
 *  @author CC, 16-09-01
 *
 *  @brief 商店按钮
 */
@property(nonatomic, weak) UIButton *storeManagerItemButton;

@property(nonatomic, weak) UIScrollView *sectionBarScrollView;

/**
 *  @author CC, 16-09-01
 *
 *  @brief 发送消息按钮
 */
@property(nonatomic, weak) UIButton *sendMessageItemButton;

/**
 *  @author CC, 16-09-01
 *
 *  @brief 表情管理按钮
 */
@property(nonatomic, weak) UIButton *emojiManagerItemButton;

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
 *  @author CC, 16-08-04
 *
 *  @brief 发送按钮事件
 *
 *  @param sender 按钮
 */
- (void)didSectionBarSend:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(didSectionBarSend)]) {
        self.isSendButton = NO;
        [self.delegate didSectionBarSend];
    }
}

/**
 *  @author CC, 16-09-01
 *
 *  @brief 表情管理事件
 */
- (void)didEmojiManagerClick:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(didEmojiManage)]) {
        [self.delegate didEmojiManage];
    }
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

    [self switchingButton:_currentIndex];
}

- (void)switchingButton:(BOOL)isShow
{
    CGFloat hideX = CGRectGetMaxX(self.bounds) + 20;
    CGFloat showX = CGRectGetMaxX(self.bounds) - kCCStoreManagerItemWidth;

    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.sendMessageItemButton.frame;
        frame.origin.x = isShow?hideX:showX;
        self.sendMessageItemButton.frame = frame;

        frame = self.emojiManagerItemButton.frame;
        frame.origin.x = isShow?showX:hideX;
        self.emojiManagerItemButton.frame = frame;
    }];
}

- (UIButton *)cratedButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, kCCStoreManagerItemWidth, CGRectGetHeight(self.bounds));
    [button addTarget:self action:@selector(sectionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    return button;
}

- (UIButton *)crateItemButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(CGRectGetMaxX(self.bounds) + 20, 0, kCCStoreManagerItemWidth, CGRectGetHeight(self.bounds));
    button.backgroundColor = [UIColor whiteColor];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];

    button.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    button.layer.shadowOffset = CGSizeMake(-2.0, 10);
    button.layer.shadowOpacity = 10;
    button.layer.shadowRadius = 10;
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
        if (emotionManager.emotionName)
            [sectionButton setTitle:emotionManager.emotionName forState:UIControlStateNormal];
        else if ([emotionManager.emotionIcon rangeOfString:@"http://"].location != NSNotFound) {
            [sectionButton sd_setImageWithURL:[NSURL URLWithString:emotionManager.emotionIcon] forState:UIControlStateNormal];
        } else {
            UIImage *sourceImage = [UIImage imageWithContentsOfFile:emotionManager.emotionIcon];
            UIGraphicsBeginImageContext(CGSizeMake(25, 25)); // this will crop
            [sourceImage drawInRect:CGRectMake(0, 0, 25, 25)];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            [sectionButton setImage:newImage forState:UIControlStateNormal];
            [sectionButton setImage:newImage forState:UIControlStateHighlighted];
        }

        sectionButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [sectionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        if (_currentIndex == index)
            sectionButton.backgroundColor = self.superview.backgroundColor; // [UIColor whiteColor];

        CGRect sectionButtonFrame = sectionButton.frame;
        sectionButtonFrame.origin.x = index * (CGRectGetWidth(sectionButtonFrame));
        sectionButton.frame = sectionButtonFrame;


        [self.sectionBarScrollView addSubview:sectionButton];
    }

    [self.sectionBarScrollView setContentSize:CGSizeMake((self.emotionManagers.count + 2) * kCCStoreManagerItemWidth, CGRectGetHeight(self.bounds))];
}

#pragma mark - Lefy cycle

- (void)setup
{
    if (!_storeManagerItemButton) {
        UIButton *storeManagerItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
        storeManagerItemButton.frame = CGRectMake(0, 0, kCCStoreManagerItemWidth, CGRectGetHeight(self.bounds));
        storeManagerItemButton.backgroundColor = [UIColor whiteColor];
        storeManagerItemButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [storeManagerItemButton setTitle:@"商店" forState:UIControlStateNormal];
        [storeManagerItemButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [storeManagerItemButton addTarget:self action:@selector(didStoreClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:storeManagerItemButton];
        _storeManagerItemButton = storeManagerItemButton;
    }

    if (!_sectionBarScrollView) {
        UIScrollView *sectionBarScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(kCCStoreManagerItemWidth, 0, CGRectGetWidth(self.bounds) - kCCStoreManagerItemWidth, CGRectGetHeight(self.bounds))];
        [sectionBarScrollView setScrollsToTop:NO];
        sectionBarScrollView.showsVerticalScrollIndicator = NO;
        sectionBarScrollView.showsHorizontalScrollIndicator = NO;
        sectionBarScrollView.pagingEnabled = NO;
        [self addSubview:sectionBarScrollView];
        _sectionBarScrollView = sectionBarScrollView;
    }

    if (!_sendMessageItemButton) {
        UIButton *sendMessageItemButton = [self crateItemButton];
        [sendMessageItemButton setTitle:@"发送" forState:UIControlStateNormal];
        [sendMessageItemButton addTarget:self action:@selector(didSectionBarSend:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:sendMessageItemButton];
        _sendMessageItemButton = sendMessageItemButton;
    }

    if (!_emojiManagerItemButton) {
        UIButton *emojiManagerItemButton = [self crateItemButton];
        [emojiManagerItemButton setTitle:@"管理" forState:UIControlStateNormal];
        [emojiManagerItemButton addTarget:self action:@selector(didEmojiManagerClick:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:emojiManagerItemButton];
        _emojiManagerItemButton = emojiManagerItemButton;
    }
}

- (void)setIsSendButton:(BOOL)isSendButton
{
    _isSendButton = isSendButton;

    self.sendMessageItemButton.backgroundColor = [UIColor whiteColor];
    [self.sendMessageItemButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    self.sendMessageItemButton.enabled = NO;
    if (isSendButton) {
        self.sendMessageItemButton.enabled = YES;
        self.sendMessageItemButton.backgroundColor = [UIColor colorWithRed:46.f / 255.f green:169.f / 255.f blue:223.f / 255.f alpha:1.f];
        [self.sendMessageItemButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

- (instancetype)init
{
    if (self = [super init]) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // Initialization code
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
