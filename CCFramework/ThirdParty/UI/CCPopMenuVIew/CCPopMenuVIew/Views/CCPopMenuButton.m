//
//  CCPopMenuButton.m
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

#import "CCPopMenuButton.h"
#import "POP.h"
#import "CCPopMenuItem.h"
#import "GlowImageView.h"

@interface CCPopMenuButton ()

@property(nonatomic, strong) GlowImageView *iconImageView;
@property(nonatomic, strong) UILabel *titleLabel;

@property(nonatomic, strong) CCPopMenuItem *menuItem;

@property(nonatomic, assign) BOOL isClick;

@end

@implementation CCPopMenuButton

- (instancetype)initWithFrame:(CGRect)frame
                     menuItem:(CCPopMenuItem *)menuItem
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.menuItem = menuItem;
        
        self.iconImageView = [[GlowImageView alloc] initWithFrame:CGRectMake(0, 0, menuItem.iconImage.size.width, menuItem.iconImage.size.height)];
        self.iconImageView.userInteractionEnabled = NO;
        [self.iconImageView setImage:menuItem.iconImage forState:UIControlStateNormal];
        self.iconImageView.glowColor = menuItem.glowColor;
        self.iconImageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.iconImageView.bounds));
        [self addSubview:self.iconImageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.iconImageView.frame), CGRectGetWidth(self.bounds), 35)];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = menuItem.title;
        CGPoint center = self.titleLabel.center;
        center.x = CGRectGetMidX(self.bounds);
        self.titleLabel.center = center;
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)setTextColor:(UIColor *)TextColor
{
    _TextColor = TextColor;
    self.titleLabel.textColor = TextColor;
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    if (!self.isClick) {
        // 播放缩放动画
        POPSpringAnimation *scaleAnimation = [POPSpringAnimation animation];
        scaleAnimation.springBounciness = 20; // value between 0-20
        scaleAnimation.springSpeed = 20;      // value between 0-20
        scaleAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewScaleXY];
        scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.3, 1.3)];
        [self pop_addAnimation:scaleAnimation forKey:@"scaleAnimationKey"];
    }
    self.isClick = YES;
    [self.superview.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.userInteractionEnabled = NO;
    }];
    self.userInteractionEnabled = YES;
}

- (void)touchesCancelled:(NSSet *)touches
               withEvent:(UIEvent *)event
{
    [self disMissCompleted:NULL];
}

- (void)disMissCompleted:(void (^)(BOOL finished))completed
{
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animation];
    scaleAnimation.springBounciness = 16; // value between 0-20
    scaleAnimation.springSpeed = 14;      // value between 0-20
    scaleAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewScaleXY];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.0, 1.0)];
    scaleAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (completed) {
            completed(finished);
            
        }
    };
    [self pop_addAnimation:scaleAnimation forKey:@"scaleAnimationKey"];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self disMissCompleted:^(BOOL finished) {
        [self.superview.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.userInteractionEnabled = YES;
        }];
        if (self.didSelctedItemCompleted) {
            self.didSelctedItemCompleted(self.menuItem);
        }
    }];
}


@end
