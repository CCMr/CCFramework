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
#import "UIButton+Additions.h"

@interface CCPagesContainerTopBar ()

@property(strong, nonatomic) UIImageView *backgroundImageView;
@property(strong, nonatomic) UIScrollView *scrollView;
@property(strong, nonatomic) NSMutableArray *itemViews;

@property(strong, nonatomic) NSArray *itemLineViews;

@property(nonatomic, strong) UIView *line;

@property(nonatomic, assign) CGFloat CCPagesContainerTopBarItemViewWidth;

- (void)layoutItemViews;

@end

@implementation CCPagesContainerTopBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _IsDividingLine = NO;
        _CCPagesContainerTopBarItemViewWidth = 70;
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.scrollView];
        
        self.line = [[UIView alloc] initWithFrame:self.bounds];
        self.line.backgroundColor = [UIColor colorWithRed:215 / 255.f green:215 / 255.f blue:215 / 255.f alpha:1.f];
        [self addSubview:self.line];
        
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
        
        if (_IsCovered)
            _CCPagesContainerTopBarItemViewWidth = (CGRectGetWidth(self.frame) - (_itemTitles.count * self.topBarItemsOffset)) / _itemTitles.count;
        
        NSMutableArray *mutableItemViews = [NSMutableArray arrayWithCapacity:itemTitles.count];
        NSMutableArray *mutableLineViews = [NSMutableArray array];
        for (NSUInteger i = 0; i < itemTitles.count; i++) {
            UIButton *itemView = [self addItemView:i Title:itemTitles[i]];
            [mutableItemViews addObject:itemView];
            
            [mutableLineViews addObject:[self addLine]];
        }
        self.itemViews = mutableItemViews;
        self.itemLineViews = [NSArray arrayWithArray:mutableLineViews];
        
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
                case CCPageContaiinerTopBarTypeUPMapNextText: {
                    UILabel *titleLabel = (UILabel *)[itemView viewWithTag:9999];
                    [titleLabel setFont:font];
                } break;
                default:
                    break;
            }
        }
    }
}

- (void)setIsCovered:(BOOL)IsCovered
{
    _IsCovered = IsCovered;
    [self layoutItemViews];
}

#pragma mark - Private

- (UIView *)addLine
{
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 0.5, CGRectGetHeight(self.frame) - 20)];
    line.backgroundColor = [UIColor lightGrayColor];
    line.hidden = YES;
    [self.scrollView addSubview:line];
    
    return line;
}

- (UIButton *)addItemView:(NSUInteger)index
                    Title:(NSString *)title
{
    
    CGRect frame = CGRectMake(0., 0., _CCPagesContainerTopBarItemViewWidth, CGRectGetHeight(self.frame));
    UIButton *itemView;
    switch (_topBarType) {
        case CCPageContaiinerTopBarTypeText:
            itemView = [[UIButton alloc] initWithFrame:frame];
            [itemView setTitle:title forState:UIControlStateNormal];
            break;
        case CCPageContaiinerTopBarTypeUPMapNextText: {
            itemView = [UIButton buttonWithUpImageNextTilte:[_topBarImageAry objectAtIndex:index]
                                                      Title:title
                                                      Frame:frame];
            
            UILabel *titleLabel = (UILabel *)[itemView viewWithTag:9999];
            [titleLabel setTextColor:self.itemTitleColor];
        } break;
        case CCPageContaiinerTopBarTypeLeftMapRightText:
            itemView = [UIButton buttonWithImageTitle:[_topBarImageAry objectAtIndex:index]
                                                Title:title
                                                Frame:frame];
            break;
        case CCPageContaiinerTopBarTypeLeftTextRightMap:
            itemView = [UIButton buttonLeftTitleWithImage:[_topBarImageAry objectAtIndex:index]
                                                Title:title
                                                Frame:frame];
            break;
        default:
            break;
    }
    [itemView addTarget:self action:@selector(itemViewTapped:) forControlEvents:UIControlEventTouchUpInside];
    itemView.titleLabel.font = self.font;
    [itemView setTitleColor:self.itemTitleColor forState:UIControlStateNormal];
    itemView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:itemView];
    return itemView;
}

- (void)replaceView:(UIView *)view Index:(NSInteger)index
{
    if (_topBarType == CCPageContaiinerTopBarTypeLeftTextRightMap) {
        UIButton *button = (UIButton *)view;
        [button removeFromSuperview];
        
        button = [UIButton buttonWithLeftTitleImage:button.imageView.image
                                              Title:button.titleLabel.text
                                              Frame:button.frame];
        button.titleLabel.font = self.font;
        [button setTitleColor:self.itemTitleColor forState:UIControlStateNormal];
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(itemViewTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.scrollView addSubview:button];
        [self.itemViews replaceObjectAtIndex:index withObject:button];
    }
}

- (void)itemViewTapped:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(itemAtIndex:didSelectInPagesContainerTopBar:)])
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
                width = _CCPagesContainerTopBarItemViewWidth;
                break;
            case CCPageContaiinerTopBarTypeLeftMapRightText:
            case CCPageContaiinerTopBarTypeLeftTextRightMap:
                width = [self.itemTitles[i] sizeWithFont:self.font].width + ((UIButton *)self.itemViews[i]).imageView.frame.size.width;
                break;
            default:
                break;
        }
        UIView *itemView = self.itemViews[i];
        if (_IsCovered) {
            width = (CGRectGetWidth(self.frame) - (self.itemViews.count * self.topBarItemsOffset)) / self.itemViews.count;
            self.scrollView.scrollEnabled = NO;
        }
        itemView.frame = CGRectMake(x, 0., width, CGRectGetHeight(self.frame));
        [self replaceView:itemView Index:i];
        
        UIView *images = [itemView viewWithTag:8888];
        CGRect frame = images.frame;
        frame.origin.x = (width - frame.size.width) / 2;
        images.frame = frame;
        
        UIView *title = [itemView viewWithTag:9999];
        frame = title.frame;
        frame.size.width = width;
        title.frame = frame;
        
        x += width + self.topBarItemsOffset;
        
        if (self.IsDividingLine) {
            UIView *line = [self.itemLineViews objectAtIndex:i];
            frame = line.frame;
            frame.origin.x = x;
            line.frame = frame;
            line.hidden = NO;
            
            x += line.frame.size.width;
        }
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
    
    frame.origin.y = CGRectGetHeight(self.bounds);
    frame.size.height = .5;
    self.line.frame = frame;
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