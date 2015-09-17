//
//  CCPopMenuView.m
//  CCPopMenuView
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

#import "CCPopMenuView.h"
#import "Config.h"

#define CCPopMenuViewTag 1999
#define CCPopMenuViewImageHeight (winsize.width/6.0)
#define CCPopMenuViewTitleHeight 20
#define CCPopMenuViewVerticalPadding 20
#define CCPopMenuViewHorizontalMargin 40
#define CCPopMenuViewRriseAnimationID @"CCPopMenuViewRriseAnimationID"
#define CCPopMenuViewDismissAnimationID @"CCPopMenuViewDismissAnimationID"
#define CCPopMenuViewAnimationTime 0.36
#define CCPopMenuViewAnimationInterval (CCPopMenuViewAnimationTime / 5)


@interface CCPopMenuItemButton : UIControl
- (id)initWithTitle:(NSString*)title andIcon:(NSString *)icon andSelectedBlock:(CCMenuViewSelectedBlock)block;
@property(nonatomic,copy)CCMenuViewSelectedBlock selectedBlock;
@end

@implementation CCPopMenuItemButton
{
    UIImageView *iconView;
    UILabel *titleLabel;
}
- (id)initWithTitle:(NSString *)title andIcon:(NSString *)icon andSelectedBlock:(CCMenuViewSelectedBlock)block
{
    self = [super init];
    if (self) {
        iconView = [UIImageView new];
        iconView.image = [UIImage imageNamed:icon];
        titleLabel = [UILabel new];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = title;
        _selectedBlock = block;
        [self addSubview:iconView];
        [self addSubview:titleLabel];
    }
    return self;
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    iconView.frame = CGRectMake(0, 0, CCPopMenuViewImageHeight, CCPopMenuViewImageHeight);
    titleLabel.frame = CGRectMake(0, CCPopMenuViewImageHeight, CCPopMenuViewImageHeight, CCPopMenuViewTitleHeight);
}


@end

@implementation CCPopMenuView{
    NSMutableArray *buttons;
    UITapGestureRecognizer *ges;
}



- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
        ges.delegate = self;
        [self addGestureRecognizer:ges];
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.6];
        buttons = [[NSMutableArray alloc] initWithCapacity:6];

    }
    return self;
}

- (void)addMenuItemWithTitle:(NSString *)title andIcon:(NSString *)icon andSelectedBlock:(CCMenuViewSelectedBlock)block{
    CCPopMenuItemButton *button = [[CCPopMenuItemButton alloc] initWithTitle:title andIcon:icon andSelectedBlock:block];
    
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
    [buttons addObject:button];
}

- (CGRect)frameForButtonAtIndex:(NSUInteger)index{
    NSUInteger columnCount = 3;
    NSUInteger columnIndex =  index % columnCount;
    
    NSUInteger rowCount = buttons.count / columnCount + (buttons.count%columnCount>0?1:0);
    NSUInteger rowIndex = index / columnCount;
    
    CGFloat itemHeight = (CCPopMenuViewImageHeight + CCPopMenuViewTitleHeight) * rowCount + (rowCount > 1?(rowCount - 1) * CCPopMenuViewHorizontalMargin:0);
    CGFloat offsetY = (self.bounds.size.height - itemHeight) / 2.0;
    CGFloat verticalPadding = (self.bounds.size.width - CCPopMenuViewHorizontalMargin * 2 - CCPopMenuViewImageHeight * 3) / 2.0;
    
    CGFloat offsetX = CCPopMenuViewHorizontalMargin;
    offsetX += (CCPopMenuViewImageHeight+ verticalPadding) * columnIndex;
    
    offsetY += (CCPopMenuViewImageHeight + CCPopMenuViewTitleHeight + CCPopMenuViewVerticalPadding) * rowIndex;
    
    return CGRectMake(offsetX, offsetY, CCPopMenuViewImageHeight, (CCPopMenuViewImageHeight+CCPopMenuViewTitleHeight));
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    for (NSUInteger i = 0; i < buttons.count; i++) {
        CCPopMenuItemButton *button = buttons[i];
        button.frame = [self frameForButtonAtIndex:i];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer.view isKindOfClass:[CCPopMenuItemButton class]])
        return NO;
    
    CGPoint location = [gestureRecognizer locationInView:self];
    for (UIView* subview in buttons) {
        if (CGRectContainsPoint(subview.frame, location))
            return NO;
    }
    return YES;
}

- (void)dismiss:(id)sender
{
    ges.enabled = NO;
    [self dropAnimation];
    
    double delayInSeconds = CCPopMenuViewAnimationTime  + CCPopMenuViewAnimationInterval * (buttons.count + 1);
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self removeFromSuperview];
        ges.enabled = YES;
        
        if (_dismissBlock) {
            _dismissBlock(self);
        }
        
    });
}


- (void)buttonTapped:(CCPopMenuItemButton*)btn{
    [self dismiss:nil];
    double delayInSeconds = CCPopMenuViewAnimationTime;//  + CCPopMenuViewAnimationInterval * (buttons.count + 1);
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        btn.selectedBlock();
    });
}


- (void)riseAnimation{
    NSUInteger columnCount = 3;
    NSUInteger rowCount = buttons.count / columnCount + (buttons.count%columnCount>0?1:0);
    
    for (NSUInteger index = 0; index < buttons.count; index++) {
        CCPopMenuItemButton *button = buttons[index];
        button.layer.opacity = 0;
        CGRect frame = [self frameForButtonAtIndex:index];
        NSUInteger rowIndex = index / columnCount;
        NSUInteger columnIndex = index % columnCount;
        CGPoint fromPosition = CGPointMake(frame.origin.x + CCPopMenuViewImageHeight / 2.0,frame.origin.y +  (rowCount - rowIndex + 2)*200 + (CCPopMenuViewImageHeight + CCPopMenuViewTitleHeight) / 2.0);
        
        CGPoint toPosition = CGPointMake(frame.origin.x + CCPopMenuViewImageHeight / 2.0,frame.origin.y + (CCPopMenuViewImageHeight + CCPopMenuViewTitleHeight) / 2.0);
        
        double delayInSeconds = rowIndex * columnCount * CCPopMenuViewAnimationInterval;
        if (!columnIndex)
            delayInSeconds += CCPopMenuViewAnimationInterval;
        else if(columnIndex == 2)
            delayInSeconds += CCPopMenuViewAnimationInterval * 2;
        CABasicAnimation *positionAnimation;
        
        positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:fromPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:toPosition];
        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.45f :1.2f :0.75f :1.0f];
        positionAnimation.duration = CCPopMenuViewAnimationTime;
        positionAnimation.beginTime = [button.layer convertTime:CACurrentMediaTime() fromLayer:nil] + delayInSeconds;
        [positionAnimation setValue:[NSNumber numberWithUnsignedInteger:index] forKey:CCPopMenuViewRriseAnimationID];
        positionAnimation.delegate = self;
        
        [button.layer addAnimation:positionAnimation forKey:@"riseAnimation"];
    }
    
    self.alpha = 0;
    [UIView animateWithDuration:2*CCPopMenuViewAnimationTime animations:^{
        self.alpha = 1;
    }];
}

- (void)dropAnimation{
    NSUInteger columnCount = 3;
    for (NSUInteger index = 0; index < buttons.count; index++) {
        CCPopMenuItemButton *button = buttons[index];
        CGRect frame = [self frameForButtonAtIndex:index];
        NSUInteger rowIndex = index / columnCount;
        NSUInteger columnIndex = index % columnCount;
        
        CGPoint toPosition = CGPointMake(frame.origin.x + CCPopMenuViewImageHeight / 2.0,frame.origin.y -  (rowIndex + 2)*200 + (CCPopMenuViewImageHeight + CCPopMenuViewTitleHeight) / 2.0);
        
        CGPoint fromPosition = CGPointMake(frame.origin.x + CCPopMenuViewImageHeight / 2.0,frame.origin.y + (CCPopMenuViewImageHeight + CCPopMenuViewTitleHeight) / 2.0);
        
        double delayInSeconds = rowIndex * columnCount * CCPopMenuViewAnimationInterval;
        if (!columnIndex)
            delayInSeconds += CCPopMenuViewAnimationInterval;
        else if(columnIndex == 2)
            delayInSeconds += CCPopMenuViewAnimationInterval * 2;
        CABasicAnimation *positionAnimation;
        
        positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:fromPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:toPosition];
        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.3 :0.5f :1.0f :1.0f];
        positionAnimation.duration = CCPopMenuViewAnimationTime;
        positionAnimation.beginTime = [button.layer convertTime:CACurrentMediaTime() fromLayer:nil] + delayInSeconds;
        [positionAnimation setValue:[NSNumber numberWithUnsignedInteger:index] forKey:CCPopMenuViewDismissAnimationID];
        positionAnimation.delegate = self;
        
        [button.layer addAnimation:positionAnimation forKey:@"riseAnimation"];
    }
    
    self.alpha = 1;
    [UIView animateWithDuration:CCPopMenuViewAnimationTime animations:^{
        self.alpha = 0;
    }];
}

- (void)animationDidStart:(CAAnimation *)anim{
    NSUInteger columnCount = 3;
    if([anim valueForKey:CCPopMenuViewRriseAnimationID]) {
        NSUInteger index = [[anim valueForKey:CCPopMenuViewRriseAnimationID] unsignedIntegerValue];
        UIView *view = buttons[index];
        CGRect frame = [self frameForButtonAtIndex:index];
        CGPoint toPosition = CGPointMake(frame.origin.x + CCPopMenuViewImageHeight / 2.0,frame.origin.y + (CCPopMenuViewImageHeight + CCPopMenuViewTitleHeight) / 2.0);
        CGFloat toAlpha = 1.0;
        
        view.layer.position = toPosition;
        view.layer.opacity = toAlpha;
        
    }else if([anim valueForKey:CCPopMenuViewDismissAnimationID]) {
        NSUInteger index = [[anim valueForKey:CCPopMenuViewDismissAnimationID] unsignedIntegerValue];
        NSUInteger rowIndex = index / columnCount;
        
        UIView *view = buttons[index];
        CGRect frame = [self frameForButtonAtIndex:index];
        CGPoint toPosition = CGPointMake(frame.origin.x + CCPopMenuViewImageHeight / 2.0,frame.origin.y -  (rowIndex + 2)*200 + (CCPopMenuViewImageHeight + CCPopMenuViewTitleHeight) / 2.0);
        
        view.layer.position = toPosition;
    }
}

- (void)show{
    UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topViewController.presentedViewController != nil)
        topViewController = topViewController.presentedViewController;
    
    if ([topViewController.view viewWithTag:CCPopMenuViewTag])
        [[topViewController.view viewWithTag:CCPopMenuViewTag] removeFromSuperview];
    
    self.frame = topViewController.view.bounds;
    self.alpha = 0;
    [topViewController.view addSubview:self];
    
    
    [self riseAnimation];
}
@end
