//
//  CCSegmentedView.m
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

#import "CCSegmentedView.h"
#import "config.h"

@interface CCSegmentedView () {

    CGFloat labelWidht;
    CGFloat labelHeight;
    NSInteger titleNumber;
    NSInteger lastSelectNumber;
}

@property(nonatomic, strong) UIView *shadeView;
@property(nonatomic, strong) UIView *topLabelView;
@property(nonatomic, strong) NSMutableArray *botLabelArray;
@property(nonatomic, strong) NSMutableArray *topLabelArray;
@property(nonatomic, strong) NSMutableArray *lineArray;
@property(nonatomic, strong) UIPanGestureRecognizer *pan;

@end

@implementation CCSegmentedView

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles
{
    if (self = [super initWithFrame:frame]) {
        [self baseInit];
        [self setTitles:titles];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self baseInit];
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self baseInit];
    }

    return self;
}

- (void)baseInit
{
    self.cornerRadius = 4;
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderWidth = 1;
    self.layer.borderColor = [self.tintColor CGColor];
    self.layer.cornerRadius = self.cornerRadius;
    self.clipsToBounds = YES;

    self.botLabelArray = [[NSMutableArray alloc] init];
    self.topLabelArray = [[NSMutableArray alloc] init];
    self.lineArray = [[NSMutableArray alloc] init];

    _titles = @[ @"First", @"Second" ];

    [self setSubViewWithTitles:_titles];
}

- (void)setTitles:(NSArray *)titles
{
    _titles = titles;
    [self setSubViewWithTitles:titles];
}

- (void)setSubViewWithTitles:(NSArray *)titles
{
    for (UIView *view in [self subviews])
        [view removeFromSuperview];

    titleNumber = self.titles.count;
    labelWidht = self.frame.size.width / titleNumber;
    labelHeight = self.frame.size.height;

    [self.botLabelArray removeAllObjects];

    for (int i = 0; i < titleNumber; i++) {
        UILabel *titleLabel = [self labelWithFrame:CGRectMake(i * (labelWidht), 0, labelWidht, labelHeight) text:titles[i] textColor:self.tintColor];
        [self.botLabelArray addObject:titleLabel];
        [self addSubview:titleLabel];
    }

    self.shadeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, labelWidht, labelHeight)];
    self.shadeView.backgroundColor = self.tintColor;
    self.shadeView.clipsToBounds = YES;

    [self addSubview:self.shadeView];

    self.topLabelView = [[UIView alloc] initWithFrame:self.bounds];
    self.topLabelView.backgroundColor = [UIColor clearColor];

    [self.shadeView addSubview:self.topLabelView];

    [self.topLabelArray removeAllObjects];

    for (int i = 0; i < titleNumber; i++) {
        UILabel *titleLabel = [self labelWithFrame:CGRectMake(i * (labelWidht), 0, labelWidht, labelHeight) text:titles[i] textColor:[UIColor whiteColor]];
        [self.topLabelArray addObject:titleLabel];
        [self.topLabelView addSubview:titleLabel];
    }

    for (int i = 0; i < titleNumber; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(i * (labelWidht), 0, labelWidht, labelHeight);
        button.backgroundColor = [UIColor clearColor];
        button.tag = i;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:button];
    }

    for (int i = 1; i < titleNumber; i++) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(i * labelWidht, 0, 0.5, labelHeight)];
        line.backgroundColor = self.tintColor;
        [self.lineArray addObject:line];
        [self addSubview:line];
    }
}

- (UILabel *)labelWithFrame:(CGRect)frame
                       text:(NSString *)text
                  textColor:(UIColor *)textColor
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:frame];

    titleLabel.text = text;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = textColor;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15];

    return titleLabel;
}

- (void)setCornerRadius:(NSInteger)cornerRadius
{
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
    self.shadeView.layer.cornerRadius = cornerRadius;
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    for (UILabel *label in self.botLabelArray)
        label.textColor = textColor;

    for (UIView *line in self.lineArray)
        line.backgroundColor = textColor;

    self.shadeView.backgroundColor = textColor;
    self.layer.borderColor = [textColor CGColor];
}

- (void)setTextFont:(UIFont *)textFont
{
    _textFont = textFont;
    for (UILabel *label in self.botLabelArray)
        label.font = textFont;
}

- (void)setViewColor:(UIColor *)viewColor
{
    _viewColor = viewColor;
    self.backgroundColor = viewColor;
    for (UILabel *label in self.topLabelArray) {
        if (viewColor != [UIColor clearColor])
            label.textColor = viewColor;
    }
}

- (void)setSelectNumber:(NSInteger)selectNumber
{
    if (selectNumber >= titleNumber)
        selectNumber = titleNumber - 1;

    _selectNumber = selectNumber;

    if ([_delegate respondsToSelector:@selector(didDeselectRowAtIndex:didDeseSelectTitleInteger:)]) {
        BOOL isSelect = NO;
        if (self.didDeselectRowAtIndex)
            isSelect = self.didDeselectRowAtIndex(self, selectNumber);
        else
            isSelect = [_delegate didDeselectRowAtIndex:self didDeseSelectTitleInteger:selectNumber];
        if (isSelect)
            lastSelectNumber = selectNumber;
    } else {
        lastSelectNumber = selectNumber;
    }

    [self selectTitleWithInteger:selectNumber];

    if ([_delegate respondsToSelector:@selector(didSelectRowAtIndex:selectTitleInteger:)])
        [_delegate didSelectRowAtIndex:self selectTitleInteger:self.selectNumber];

    if (self.didSelectRowAtIndex)
        self.didSelectRowAtIndex(self, self.selectNumber);
}

- (void)setSelectNumber:(NSInteger)selectNumber animate:(BOOL)animate
{
    if (animate) {
        [UIView animateWithDuration:0.3 animations:^{
            self.selectNumber = selectNumber;
        }];
    } else {
        self.selectNumber = selectNumber;
    }
}

- (void)buttonClick:(UIButton *)sender
{
    long select = sender.tag;

    if ([_delegate respondsToSelector:@selector(didDeselectRowAtIndex:didDeseSelectTitleInteger:)] || self.didDeselectRowAtIndex) {
        BOOL isSelect = NO;
        if (self.didDeselectRowAtIndex)
            isSelect = self.didDeselectRowAtIndex(self, select);
        else
            isSelect = [_delegate didDeselectRowAtIndex:self didDeseSelectTitleInteger:select];

        if (isSelect)
            lastSelectNumber = select;
    } else {
        lastSelectNumber = select;
    }

    [UIView animateWithDuration:0.3 animations:^{
        [self selectTitleWithInteger:select];
    }];

    if ([_delegate respondsToSelector:@selector(didSelectRowAtIndex:selectTitleInteger:)])
        [_delegate didSelectRowAtIndex:self selectTitleInteger:self.selectNumber];

    if (self.didSelectRowAtIndex)
        self.didSelectRowAtIndex(self, self.selectNumber);
}

- (void)setIsGesture:(BOOL)isGesture
{
    if (self.pan)
        [self removeGestureRecognizer:self.pan];
    
     _isGesture = isGesture;
    if (_isGesture) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [self addGestureRecognizer:pan];
    }
}

- (void)pan:(UIPanGestureRecognizer *)sender
{
    CGPoint pt = [sender translationInView:self];

    CGPoint shadeViewCenter = self.shadeView.center;
    CGPoint topLabelViewCenter = self.topLabelView.center;

    shadeViewCenter.x += pt.x;
    topLabelViewCenter.x -= pt.x;

    if (shadeViewCenter.x < 0) {
        shadeViewCenter.x = 0;
        topLabelViewCenter.x = labelWidht / 2 + self.frame.size.width / 2;
    }

    if (shadeViewCenter.x > self.frame.size.width - 1) {
        shadeViewCenter.x = self.frame.size.width - 1;
        topLabelViewCenter.x = -self.frame.size.width / 2 + labelWidht / 2 + 1;
    }

    self.shadeView.center = shadeViewCenter;
    self.topLabelView.center = topLabelViewCenter;

    if (sender.state == UIGestureRecognizerStateEnded) {
        int select = shadeViewCenter.x / labelWidht;

        if ([_delegate respondsToSelector:@selector(didDeselectRowAtIndex:didDeseSelectTitleInteger:)]) {
            BOOL isSelect = NO;
            if (self.didDeselectRowAtIndex)
                isSelect = self.didDeselectRowAtIndex(self, select);
            else
                isSelect = [_delegate didDeselectRowAtIndex:self didDeseSelectTitleInteger:select];

            if (isSelect)
                lastSelectNumber = select;
        } else {
            lastSelectNumber = select;
        }

        [UIView animateWithDuration:0.3 animations:^{
            [self selectTitleWithInteger:select];
        }];

        if ([_delegate respondsToSelector:@selector(didSelectRowAtIndex:selectTitleInteger:)])
            [_delegate didSelectRowAtIndex:self selectTitleInteger:self.selectNumber];

        if (self.didSelectRowAtIndex)
            self.didSelectRowAtIndex(self, self.selectNumber);
    }

    [sender setTranslation:CGPointZero inView:self];
}

- (void)selectTitleWithInteger:(NSInteger)integer
{
    _selectNumber = integer;
    self.shadeView.frame = CGRectMake(integer * labelWidht, 0, labelWidht, labelHeight);
    self.topLabelView.frame = CGRectMake(-integer * labelWidht, 0, self.frame.size.width, self.frame.size.height);

    UIRectCorner corners = -1;
    if (integer == 0) {
        corners = UIRectCornerTopLeft | UIRectCornerBottomLeft;
    } else if (integer == self.titles.count - 1) {
        corners = UIRectCornerTopRight | UIRectCornerBottomRight;
    }
    [self fillet:corners];
}

- (void)fillet:(UIRectCorner)corners
{
    if (corners == -1) {
        self.shadeView.layer.mask = nil;
    } else {
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.shadeView.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(self.cornerRadius, self.cornerRadius)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.shadeView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.shadeView.layer.mask = maskLayer;
    }
}

@end
