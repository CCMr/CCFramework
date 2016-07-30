//
//  CCRealTimeBlur.h
//  CCFramework
//
//  Created by CC on 16/1/26.
//  Copyright © 2016年 CC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

typedef void (^WillShowBlurViewBlcok)(void);
typedef void (^DidShowBlurViewBlcok)(BOOL finished);

typedef void (^WillDismissBlurViewBlcok)(void);
typedef void (^DidDismissBlurViewBlcok)(BOOL finished);


static NSString *const CCRealTimeBlurKey = @"CCRealTimeBlurKey";

static NSString *const CCRealTimeWillShowBlurViewBlcokBlcokKey = @"CCRealTimeWillShowBlurViewBlcokBlcokKey";
static NSString *const CCRealTimeDidShowBlurViewBlcokBlcokKey = @"CCRealTimeDidShowBlurViewBlcokBlcokKey";

static NSString *const CCRealTimeWillDismissBlurViewBlcokKey = @"CCRealTimeWillDismissBlurViewBlcokKey";
static NSString *const CCRealTimeDidDismissBlurViewBlcokKey = @"CCRealTimeDidDismissBlurViewBlcokKey";

typedef NS_ENUM(NSInteger, CCBlurStyle) {
    // 垂直梯度背景从黑色到半透明的。
    CCBlurStyleBlackGradient = 0,
    // 类似UIToolbar的半透明背景
    CCBlurStyleTranslucent,
    // 黑色半透明背景
    CCBlurStyleBlackTranslucent,
    // 纯白色
    CCBlurStyleWhite,
    // 白色毛玻璃
    CCBlurStyleFrstedGlass
};

@interface CCRealTimeBlur : UIView

/**
 *  Default is CCBlurStyleTranslucent  蒙版动画状态
 */
@property(nonatomic, assign) CCBlurStyle blurStyle;
/**
 *  蒙版是否显示
 */
@property(nonatomic, assign) BOOL showed;

// Default is 0.3  蒙版显示时间 即蒙版从进入 到 动画完成的 时间 默认 0.3 从进入到动画执行 0.3秒
@property(nonatomic, assign) NSTimeInterval showDuration;

// Default is 0.3  蒙版消失时间 即蒙版从消失 到 动画完成的 时间 默认 0.3 从消失到动画执行 0.3秒
@property(nonatomic, assign) NSTimeInterval disMissDuration;

/**
 *  是否触发点击手势，默认关闭 蒙版是否有点击事件
 */
@property(nonatomic, assign) BOOL hasTapGestureEnable;

#pragma mark - 蒙版显示或者消失时， 做的操作
#pragma mark WillShow 即将显示
@property(nonatomic, copy) WillShowBlurViewBlcok willShowBlurViewcomplted;
#pragma mark DidShow  已经显示
@property(nonatomic, copy) DidShowBlurViewBlcok didShowBlurViewcompleted;
#pragma mark WillDismiss 即将消失
@property(nonatomic, copy) WillDismissBlurViewBlcok willDismissBlurViewCompleted;
#pragma mark DidDismiss  已经消失
@property(nonatomic, copy) DidDismissBlurViewBlcok didDismissBlurViewCompleted;


#pragma mark - show
- (void)showBlurViewAtView:(UIView *)currentView;

- (void)showBlurViewAtViewController:(UIViewController *)currentViewContrller;

#pragma mark - disMiss
- (void)disMiss;

@end

// ==========================================
//  UIView (CCRealTimeBlur)蒙版  实时模糊 分类
// ==========================================

@interface UIView (CCRealTimeBlur)

@property(nonatomic, copy) WillShowBlurViewBlcok willShowBlurViewcomplted;
@property(nonatomic, copy) DidShowBlurViewBlcok didShowBlurViewcompleted;


@property(nonatomic, copy) WillDismissBlurViewBlcok willDismissBlurViewCompleted;
@property (nonatomic, copy) DidDismissBlurViewBlcok didDismissBlurViewCompleted;

- (void)showRealTimeBlurWithBlurStyle:(CCBlurStyle)blurStyle;
- (void)showRealTimeBlurWithBlurStyle:(CCBlurStyle)blurStyle hasTapGestureEnable:(BOOL)hasTapGestureEnable;
- (void)disMissRealTimeBlur;

@end
