//
//  CCPopMenuView.m
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

#import "CCPopMenuView.h"
#import "CCPopMenuButton.h"
#import "CCRealTimeBlur.h"
#import <POP.h>

#define MenuButtonHeight 110
#define MenuButtonVerticalPadding 10
#define MenuButtonHorizontalMargin 10
#define MenuButtonAnimationTime 0.2
#define MenuButtonAnimationInterval (MenuButtonAnimationTime / 5)

#define kMenuButtonBaseTag 100

@interface CCPopMenuView ()

@property(nonatomic, strong) CCRealTimeBlur *realTimeBlur;

@property(nonatomic, strong, readwrite) NSArray *items;

@property(nonatomic, strong) CCPopMenuItem *selectedItem;

@property(nonatomic, assign, readwrite) BOOL isShowed;

@property(nonatomic, assign) CGPoint startPoint;
@property(nonatomic, assign) CGPoint endPoint;

@end

@implementation CCPopMenuView


#pragma mark - Life Cycle

- (id)initWithFrame:(CGRect)frame
              items:(NSArray *)items
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.items = items;
        
        [self setup];
    }
    return self;
}

- (instancetype)initWithItems:(NSArray *)items
{
    if (self = [super init]) {
        self.items = items;
        [self setup];
    }
    return self;
}

// 设置属性
- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.perRowItemCount = 3;
    
    typeof(self) __weak weakSelf = self;
    _realTimeBlur = [[CCRealTimeBlur alloc] initWithFrame:self.bounds];
    _realTimeBlur.showDuration = 0.3;
    _realTimeBlur.disMissDuration = 0.5;
    _realTimeBlur.willShowBlurViewcomplted = ^(void) {
        weakSelf.isShowed = YES;
        [weakSelf showButtons];
    };
    
    _realTimeBlur.willDismissBlurViewCompleted = ^(void) {
        [weakSelf hidenButtons];
        if (weakSelf.didSelectedItemCompletion)
            weakSelf.didSelectedItemCompletion(nil);
    };
    _realTimeBlur.didDismissBlurViewCompleted = ^(BOOL finished) {
        weakSelf.isShowed = NO;
        if (finished && weakSelf.selectedItem) {
            if (weakSelf.didSelectedItemCompletion) {
                weakSelf.didSelectedItemCompletion(weakSelf.selectedItem);
                weakSelf.selectedItem = nil;
            }
        }
        [weakSelf removeFromSuperview];
    };
    _realTimeBlur.hasTapGestureEnable = YES;
}

- (void)setBackgroundType:(CCStyle)backgroundType
{
    _backgroundType = backgroundType;
    CCBlurStyle style = CCBlurStyleBlackTranslucent;
    switch (backgroundType) {
        case CCBlackGradient: {
            style = CCBlurStyleBlackGradient;
            break;
        }
        case CCTranslucent: {
            style = CCBlurStyleTranslucent;
            break;
        }
        case CCBlackTranslucent: {
            style = CCBlurStyleBlackTranslucent;
            break;
        }
        case CCWhite: {
            style = CCBlurStyleWhite;
            break;
        }
    }
    self.realTimeBlur.blurStyle = style;
}

#pragma mark - 公开方法

- (void)showMenuAtView:(UIView *)containerView
{
    if (self.frame.size.width == 0 && self.frame.size.height == 0) {
        self.frame = containerView.bounds;
        self.realTimeBlur.frame = containerView.bounds;
    }
    
    CGPoint startPoint = CGPointMake(0, CGRectGetHeight(self.bounds));
    CGPoint endPoint = startPoint;
    switch (self.menuAnimationType) {
        case kPopMenuAnimationTypeNetEase:
            startPoint.x = CGRectGetMidX(self.bounds);
            endPoint.x = startPoint.x;
            break;
        default:
            break;
    }
    [self showMenuAtView:containerView
              startPoint:startPoint
                endPoint:endPoint];
}

- (void)showMenuAtView:(UIView *)containerView
            startPoint:(CGPoint)startPoint
              endPoint:(CGPoint)endPoint
{
    if (self.isShowed) {
        return;
    }
    self.startPoint = startPoint;
    self.endPoint = endPoint;
    [containerView addSubview:self];
    [self.realTimeBlur showBlurViewAtView:self];
}

- (void)dismissMenu
{
    if (!self.isShowed) {
        return;
    }
    [self.realTimeBlur disMiss];
}

#pragma mark - 私有方法
/**
 *  添加菜单按钮
 */
- (void)showButtons
{
    NSArray *items = [self menuItems];
    
    NSInteger perRowItemCount = self.perRowItemCount;
    
    CGFloat menuButtonWidth = (CGRectGetWidth(self.bounds) - ((perRowItemCount + 1) * MenuButtonHorizontalMargin)) / perRowItemCount;
    
    typeof(self) __weak weakSelf = self;
    for (int index = 0; index < items.count; index++) {
        
        CCPopMenuItem *menuItem = items[index];
        // 如果没有自定义index，就按照正常流程，从0开始
        if (menuItem.index < 0) {
            menuItem.index = index;
        }
        CCPopMenuButton *menuButton = (CCPopMenuButton *)[self viewWithTag:kMenuButtonBaseTag + index];
        
        CGRect toRect = [self getFrameWithItemCount:items.count
                                    perRowItemCount:perRowItemCount
                                  perColumItemCount:items.count / perRowItemCount + (items.count % perRowItemCount > 0 ? 1 : 0)
                                          itemWidth:menuButtonWidth
                                         itemHeight:MenuButtonHeight
                                           paddingX:MenuButtonVerticalPadding
                                           paddingY:MenuButtonHorizontalMargin
                                            atIndex:index
                                             onPage:0];
        
        CGRect fromRect = toRect;
        
        switch (self.menuAnimationType) {
            case kPopMenuAnimationTypeSina:
                fromRect.origin.y = self.startPoint.y;
                break;
            case kPopMenuAnimationTypeNetEase:
                fromRect.origin.x = self.startPoint.x - menuButtonWidth / 2.0;
                fromRect.origin.y = -(self.startPoint.y / 3);
                break;
            default:
                break;
        }
        if (!menuButton) {
            menuButton = [[CCPopMenuButton alloc] initWithFrame:fromRect menuItem:menuItem];
            menuButton.tag = kMenuButtonBaseTag + index;
            if (self.backgroundType == CCWhite)
                menuButton.TextColor = [UIColor blackColor];
            
            menuButton.didSelctedItemCompleted = ^(CCPopMenuItem *menuItem) {
                weakSelf.selectedItem = menuItem;
                [weakSelf dismissMenu];
            };
            [self addSubview:menuButton];
        } else {
            menuButton.frame = fromRect;
        }
        
        double delayInSeconds = index * MenuButtonAnimationInterval;
        
        [self initailzerAnimationWithToPostion:toRect
                                   formPostion:fromRect
                                        atView:menuButton
                                     beginTime:delayInSeconds];
    }
}
/**
 *  隐藏按钮
 */
- (void)hidenButtons
{
    NSArray *items = [self menuItems];
    
    for (int index = 0; index < items.count; index++) {
        CCPopMenuButton *menuButton = (CCPopMenuButton *)[self viewWithTag:kMenuButtonBaseTag + index];
        
        CGRect fromRect = menuButton.frame;
        
        CGRect toRect = fromRect;
        
        switch (self.menuAnimationType) {
            case kPopMenuAnimationTypeSina:
                toRect.origin.y = self.endPoint.y;
                break;
            case kPopMenuAnimationTypeNetEase:
                toRect.origin.x = self.endPoint.x - CGRectGetMidX(menuButton.bounds);
                toRect.origin.y = self.endPoint.y;
                break;
            default:
                break;
        }
        double delayInSeconds = (items.count - index) * MenuButtonAnimationInterval;
        
        [self initailzerAnimationWithToPostion:toRect
                                   formPostion:fromRect
                                        atView:menuButton
                                     beginTime:delayInSeconds];
    }
}

- (NSArray *)menuItems
{
    return self.items;
}

/**
 *  通过目标的参数，获取一个grid布局  网格布局
 *
 *  @param perRowItemCount   每行有多少列
 *  @param perColumItemCount 每列有多少行
 *  @param itemWidth         gridItem的宽度
 *  @param itemHeight        gridItem的高度
 *  @param paddingX          gridItem之间的X轴间隔
 *  @param paddingY          gridItem之间的Y轴间隔
 *  @param index             某个gridItem所在的index序号
 *  @param page              某个gridItem所在的页码
 *
 *  @return 返回一个已经处理好的gridItem frame
 */
- (CGRect)getFrameWithItemCount:(NSInteger)itemCount
                perRowItemCount:(NSInteger)perRowItemCount
              perColumItemCount:(NSInteger)perColumItemCount
                      itemWidth:(CGFloat)itemWidth
                     itemHeight:(NSInteger)itemHeight
                       paddingX:(CGFloat)paddingX
                       paddingY:(CGFloat)paddingY
                        atIndex:(NSInteger)index
                         onPage:(NSInteger)page
{
    
    NSUInteger rowCount = itemCount / perRowItemCount + (itemCount % perColumItemCount > 0 ? 1 : 0);
    CGFloat insetY = (CGRectGetHeight(self.bounds) - (itemHeight + paddingY) * rowCount) / 2.0;
    
    CGFloat originX = (index % perRowItemCount) * (itemWidth + paddingX) + paddingX + (page * CGRectGetWidth(self.bounds));
    CGFloat originY = ((index / perRowItemCount) - perColumItemCount * page) * (itemHeight + paddingY) + paddingY;
    
    CGRect itemFrame = CGRectMake(originX, originY + insetY, itemWidth, itemHeight);
    return itemFrame;
}

#pragma mark - Animation

- (void)initailzerAnimationWithToPostion:(CGRect)toRect
                             formPostion:(CGRect)fromRect
                                  atView:(UIView *)view
                               beginTime:(CFTimeInterval)beginTime
{
    POPSpringAnimation *springAnimation = [POPSpringAnimation animation];
    springAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewFrame];
    springAnimation.removedOnCompletion = YES;
    springAnimation.beginTime = beginTime + CACurrentMediaTime();
    CGFloat springBounciness = 10 - beginTime * 2;
    springAnimation.springBounciness = springBounciness; // value between 0-20
    
    CGFloat springSpeed = 12 - beginTime * 2;
    springAnimation.springSpeed = springSpeed; // value between 0-20
    springAnimation.toValue = [NSValue valueWithCGRect:toRect];
    springAnimation.fromValue = [NSValue valueWithCGRect:fromRect];
    
    [view pop_addAnimation:springAnimation forKey:@"POPSpringAnimationKey"];
}

@end
