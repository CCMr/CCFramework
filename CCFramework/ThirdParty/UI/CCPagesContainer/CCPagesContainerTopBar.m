//
//  CCPagesContainerTopBar.m
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

#import "CCPagesContainerTopBar.h"
#import "UIButton+BUIButton.h"

@interface CCPagesContainerTopBar ()

@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSArray *itemViews;

- (void)layoutItemViews;

@end

@implementation CCPagesContainerTopBar

CGFloat const CCPagesContainerTopBarItemViewWidth = 70;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.scrollView];
        self.font = [UIFont systemFontOfSize:14];
        self.itemTitleColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark - Public

- (CGPoint)centerForSelectedItemAtIndex:(NSUInteger)index
{
    CGPoint center = ((UIView *)self.itemViews[index]).center;
    CGPoint offset = [self contentOffsetForSelectedItemAtIndex:index];
    center.x -= offset.x - (CGRectGetMinX(self.scrollView.frame));
    return center;
}

- (CGPoint)contentOffsetForSelectedItemAtIndex:(NSUInteger)index
{
    if (self.itemViews.count < index || self.itemViews.count == 1) {
        return CGPointZero;
    } else {
        CGFloat totalOffset = self.scrollView.contentSize.width - CGRectGetWidth(self.scrollView.frame);
        return CGPointMake(index * totalOffset / (self.itemViews.count - 1), 0.);
    }
}

- (void)setItemTitleColor:(UIColor *)itemTitleColor
{
    if (![_itemTitleColor isEqual:itemTitleColor]) {
        _itemTitleColor = itemTitleColor;
        for (UIButton *button in self.itemViews) {
            [button setTitleColor:itemTitleColor forState:UIControlStateNormal];
        }
    }
}

#pragma mark * Overwritten setters

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    self.backgroundImageView.image = backgroundImage;
}

- (void)setItemTitles:(NSArray *)itemTitles
{
    if (_itemTitles != itemTitles) {
        _itemTitles = itemTitles;
        NSMutableArray *mutableItemViews = [NSMutableArray arrayWithCapacity:itemTitles.count];
        for (NSUInteger i = 0; i < itemTitles.count; i++) {
            UIButton *itemView = [self addItemView:i Title:itemTitles[i]];
            [mutableItemViews addObject:itemView];
        }
        self.itemViews = [NSArray arrayWithArray:mutableItemViews];
        [self layoutItemViews];
    }
}

- (void)setFont:(UIFont *)font
{
    if (![_font isEqual:font]) {
        _font = font;
        for (UIButton *itemView in self.itemViews) {
            //设置文字颜色
            switch (_topBarType) {
                case CCPageContaiinerTopBarTypeText:
                case CCPageContaiinerTopBarTypeLeftMapRightText:
                    [itemView.titleLabel setFont:font];
                    break;
                case CCPageContaiinerTopBarTypeUPMapNextText:
                {
                    UILabel *titleLabel = (UILabel *)[itemView viewWithTag:9999];
                    [titleLabel setFont:font];
                }
                    break;
                default:
                    break;
            }

        }
    }
}

#pragma mark - Private

- (UIButton *)addItemView: (NSUInteger)index
                    Title: (NSString *)title
{
    CGRect frame = CGRectMake(0., 0., CCPagesContainerTopBarItemViewWidth, CGRectGetHeight(self.frame));
    UIButton *itemView;
    switch (_topBarType) {
        case CCPageContaiinerTopBarTypeText:
            itemView = [[UIButton alloc] initWithFrame:frame];
            [itemView setTitle:title forState:UIControlStateNormal];
            break;
        case CCPageContaiinerTopBarTypeUPMapNextText:
            itemView = [UIButton buttonWithUpImageNextTilte:[_topBarImageAry objectAtIndex:index] Title:title Frame:frame];
            break;
        case CCPageContaiinerTopBarTypeLeftMapRightText:
            itemView = [UIButton buttonWithImageTitle:[_topBarImageAry objectAtIndex:index] Title:title Frame:frame];
            break;
        default:
            break;
    }
    [itemView addTarget:self action:@selector(itemViewTapped:) forControlEvents:UIControlEventTouchUpInside];
    itemView.titleLabel.font = self.font;
    [itemView setTitleColor:self.itemTitleColor forState:UIControlStateNormal];
    [self.scrollView addSubview:itemView];
    return itemView;
}

- (void)itemViewTapped:(UIButton *)sender
{
    [self.delegate itemAtIndex:[self.itemViews indexOfObject:sender] didSelectInPagesContainerTopBar:self];
}

- (void)layoutItemViews
{
    CGFloat x = self.topBarItemsOffset;
    for (NSUInteger i = 0; i < self.itemViews.count; i++) {
        CGFloat width;
        switch (_topBarType) {
            case CCPageContaiinerTopBarTypeText:
                width = [self.itemTitles[i] sizeWithFont:self.font].width;
                break;
            case CCPageContaiinerTopBarTypeUPMapNextText:
                width = CCPagesContainerTopBarItemViewWidth;
                break;
            case CCPageContaiinerTopBarTypeLeftMapRightText:
                width = [self.itemTitles[i] sizeWithFont:self.font].width + ((UIButton *)self.itemTitles[i]).imageView.frame.size.width;
                break;
            default:
                break;
        }
        UIView *itemView = self.itemViews[i];
        itemView.frame = CGRectMake(x, 0., width, CGRectGetHeight(self.frame));
        x += width + self.topBarItemsOffset;
    }
    self.scrollView.contentSize = CGSizeMake(x, CGRectGetHeight(self.scrollView.frame));
    CGRect frame = self.scrollView.frame;
    if (CGRectGetWidth(self.frame) > x) {
        frame.origin.x = (CGRectGetWidth(self.frame) - x) / 2.;
        frame.size.width = x;
    } else {
        frame.origin.x = 0.;
        frame.size.width = CGRectGetWidth(self.frame);
    }
    self.scrollView.frame = frame;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutItemViews];
}

#pragma mark * Lazy getters

- (UIImageView *)backgroundImageView
{
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self insertSubview:_backgroundImageView belowSubview:self.scrollView];
    }
    return _backgroundImageView;
}

@end