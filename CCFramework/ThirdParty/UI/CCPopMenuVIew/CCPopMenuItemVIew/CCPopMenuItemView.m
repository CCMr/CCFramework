//
//  CCPopMenuItemView.m
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

#import "CCPopMenuItemView.h"

@interface CCPopMenuItemView ()

@property(nonatomic, strong) UIView *menuSelectedBackgroundView;

@property(nonatomic, strong) UIImageView *separatorLineImageView;

@property(nonatomic, strong) UILabel *badge;

@end

@implementation CCPopMenuItemView

- (void)setupPopMenuItem:(CCPopMenuItem *)popMenuItem
             atIndexPath:(NSIndexPath *)indexPath
                isBottom:(BOOL)isBottom
{
    self.popMenuItem = popMenuItem;
    self.textLabel.textAlignment = popMenuItem.textAlignment;
    self.textLabel.text = popMenuItem.title;
    if (popMenuItem.titleFont)
        self.textLabel.font = popMenuItem.titleFont;
    self.imageView.image = popMenuItem.iconImage;

    self.badge.text = nil;
    self.badge.hidden = YES;
    if (popMenuItem.badgeValue && [popMenuItem.badgeValue integerValue] != 0) {
        self.badge.text = popMenuItem.badgeValue;
        self.badge.hidden = NO;
    }
    if (popMenuItem.badgeBGColor)
        self.badge.backgroundColor = popMenuItem.badgeBGColor;

    self.separatorLineImageView.hidden = isBottom;
}

#pragma mark - Propertys

- (UIView *)menuSelectedBackgroundView
{
    if (!_menuSelectedBackgroundView) {
        _menuSelectedBackgroundView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        _menuSelectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _menuSelectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.216 green:0.242 blue:0.263 alpha:0.9];
    }
    return _menuSelectedBackgroundView;
}

- (UIImageView *)separatorLineImageView
{
    if (!_separatorLineImageView) {
        _separatorLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kCCMenuItemViewImageSapcing, kCCMenuItemViewHeight - kCCSeparatorLineImageViewHeight, kCCMenuTableViewWidth - kCCMenuItemViewImageSapcing * 2, kCCSeparatorLineImageViewHeight)];
        _separatorLineImageView.backgroundColor = [UIColor colorWithRed:0.468 green:0.519 blue:0.549 alpha:0.900];
    }
    return _separatorLineImageView;
}

- (void)setLineColor:(UIColor *)lineColor
{
    _lineColor = lineColor;
    self.separatorLineImageView.backgroundColor = lineColor;
}

#pragma mark - Life Cycle

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor blackColor];
        self.textLabel.font = [UIFont systemFontOfSize:15];
        //        self.selectedBackgroundView = self.menuSelectedBackgroundView;

        _badge = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _badge.font = [UIFont systemFontOfSize:13];
        _badge.textAlignment = NSTextAlignmentCenter;
        _badge.textColor = [UIColor whiteColor];
        _badge.backgroundColor = [UIColor redColor];
        _badge.layer.cornerRadius = 10;
        _badge.clipsToBounds = YES;
        _badge.hidden = YES;
        self.accessoryView = _badge;
        [self.contentView addSubview:self.separatorLineImageView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect imageViewFrame = self.imageView.frame;
    imageViewFrame.origin.x = 15;
    self.imageView.frame = imageViewFrame;

    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.origin.x = 0;
    if (self.imageView.image)
        textLabelFrame.origin.x = imageViewFrame.origin.x + imageViewFrame.size.width + 10;

    textLabelFrame.size.width = self.frame.size.width - textLabelFrame.origin.x;
    if (!self.badge.hidden)
        textLabelFrame.size.width = textLabelFrame.size.width - 30;
    self.textLabel.frame = textLabelFrame;

    CGFloat y = (self.frame.size.height - 20) / 2;
    CGRect badgeFrame = self.badge.frame;
    badgeFrame.origin.x = textLabelFrame.origin.x + textLabelFrame.size.width;
    badgeFrame.origin.y = y;
    self.badge.frame = badgeFrame;

    if (self.paddedSeparator) {
        CGRect separatorLineFrame = self.separatorLineImageView.frame;
        separatorLineFrame.origin.x = 0;
        separatorLineFrame.size.width = self.frame.size.width;
        self.separatorLineImageView.frame = separatorLineFrame;
    }
}

@end
