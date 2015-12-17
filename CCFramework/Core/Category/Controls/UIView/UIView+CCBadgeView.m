//
//  UIView+CCBadgeView.m
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

#import "UIView+CCBadgeView.h"
#import <objc/runtime.h>

@implementation CCCircleView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextAddEllipseInRect(context, CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect)));

    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.829 green:0.194 blue:0.257 alpha:1.000].CGColor);

    CGContextFillPath(context);
}

@end


static NSString const * CCBadgeViewKey = @"CCBadgeViewKey";
static NSString const * CCBadgeViewFrameKey = @"CCBadgeViewFrameKey";
static NSString const * CCCircleBadgeViewKey = @"CCCircleBadgeViewKey";

@implementation UIView (CCBadgeView)

- (void)setBadgeViewFrame:(CGRect)badgeViewFrame {
    objc_setAssociatedObject(self, &CCBadgeViewFrameKey, NSStringFromCGRect(badgeViewFrame), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGRect)badgeViewFrame {
    return CGRectFromString(objc_getAssociatedObject(self, &CCBadgeViewFrameKey));
}

- (CCBadgeView *)badgeView {
    CCBadgeView *badgeView = objc_getAssociatedObject(self, &CCBadgeViewKey);
    if (badgeView)
        return badgeView;

    badgeView = [[CCBadgeView alloc] initWithFrame:self.badgeViewFrame];
    [self addSubview:badgeView];

    self.badgeView = badgeView;

    return badgeView;
}

- (void)setBadgeView:(CCBadgeView *)badgeView {
    objc_setAssociatedObject(self, &CCBadgeViewKey, badgeView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CCCircleView *)setupCircleBadge {
    self.opaque = NO;
    self.clipsToBounds = NO;
    CGRect circleViewFrame = CGRectMake(CGRectGetWidth(self.bounds) - 4, 0, 8, 8);

    CCCircleView *circleView = objc_getAssociatedObject(self, &CCCircleBadgeViewKey);
    if (!circleView) {
        circleView = [[CCCircleView alloc] initWithFrame:circleViewFrame];
        [self addSubview:circleView];
        objc_setAssociatedObject(self, &CCCircleBadgeViewKey, circleView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    circleView.frame = circleViewFrame;
    circleView.hidden = NO;

    return circleView;
}

- (void)destroyCircleBadge {
    CCCircleView *circleView = objc_getAssociatedObject(self, &CCCircleBadgeViewKey);
    if (circleView) {
        circleView.hidden = YES;
    }
}

@end
