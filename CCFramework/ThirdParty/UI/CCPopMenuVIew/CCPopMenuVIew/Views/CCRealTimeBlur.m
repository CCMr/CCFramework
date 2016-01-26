//
//  CCRealTimeBlur.m
//  CCFramework
//
//  Created by CC on 16/1/26.
//  Copyright © 2016年 CC. All rights reserved.
//

#import "CCRealTimeBlur.h"

@interface CCGradientView : UIView

@end

@implementation CCGradientView

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
        gradientLayer.colors = @[
                                 (id)[[UIColor colorWithWhite:0 alpha:1] CGColor],
                                 (id)[[UIColor colorWithWhite:0 alpha:0.5] CGColor],
                                 ];
    }
    return self;
}

@end

@interface CCRealTimeBlur ()

@property (nonatomic, strong) CCGradientView *gradientBackgroundView;
@property (nonatomic, strong) UIToolbar *blurBackgroundView;
@property (nonatomic, strong) UIView *blackTranslucentBackgroundView;
@property (nonatomic, strong) UIView *whiteBackgroundView;

@end

@implementation CCRealTimeBlur

- (void)showBlurViewAtView:(UIView *)currentView {
    [self showAnimationAtContainerView:currentView];
}

- (void)showBlurViewAtViewController:(UIViewController *)currentViewContrller {
    [self showAnimationAtContainerView:currentViewContrller.view];
}

- (void)disMiss {
    [self hiddenAnimation];
}

#pragma mark - Private

- (void)showAnimationAtContainerView:(UIView *)containerView {
    if (self.showed) {
        [self disMiss];
        return;
    } else {
        if (self.willShowBlurViewcomplted) {
            self.willShowBlurViewcomplted();
        }
    }
    self.alpha = 0.0;
    [containerView insertSubview:self atIndex:0];
    [UIView animateWithDuration:self.showDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.showed = YES;
        if (self.didShowBlurViewcompleted) {
            self.didShowBlurViewcompleted(finished);
        }
    }];
}

- (void)hiddenAnimation {
    [self hiddenAnimationCompletion:^(BOOL finished) {
        
    }];
}

- (void)hiddenAnimationCompletion:(void (^)(BOOL finished))completion {
    if (self.willDismissBlurViewCompleted) {
        self.willDismissBlurViewCompleted();
    }
    
    [UIView animateWithDuration:self.disMissDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
        if (self.didDismissBlurViewCompleted) {
            self.didDismissBlurViewCompleted(finished);
        }
        self.showed = NO;
        [self removeFromSuperview];
    }];
}

- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self hiddenAnimationCompletion:^(BOOL finished) {
        
    }];
}

#pragma mark - Propertys

- (void)setHasTapGestureEnable:(BOOL)hasTapGestureEnable {
    _hasTapGestureEnable = hasTapGestureEnable;
    [self setupTapGesture];
}

- (CCGradientView *)gradientBackgroundView {
    if (!_gradientBackgroundView) {
        _gradientBackgroundView = [[CCGradientView alloc] initWithFrame:self.bounds];
    }
    return _gradientBackgroundView;
}

- (UIToolbar *)blurBackgroundView {
    if (!_blurBackgroundView) {
        _blurBackgroundView = [[UIToolbar alloc] initWithFrame:self.bounds];
        [_blurBackgroundView setBarStyle:UIBarStyleBlackTranslucent];
    }
    return _blurBackgroundView;
}

- (UIView *)blackTranslucentBackgroundView {
    if (!_blackTranslucentBackgroundView) {
        _blackTranslucentBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _blackTranslucentBackgroundView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.500];
    }
    return _blackTranslucentBackgroundView;
}

- (UIView *)whiteBackgroundView {
    if (!_whiteBackgroundView) {
        _whiteBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _whiteBackgroundView.backgroundColor = [UIColor clearColor];
        _whiteBackgroundView.tintColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    }
    return _whiteBackgroundView;
}

- (UIView *)backgroundView {
    switch (self.blurStyle) {
        case CCBlurStyleBlackGradient:
            return self.gradientBackgroundView;
            break;
        case CCBlurStyleTranslucent:
            return self.blurBackgroundView;
        case CCBlurStyleBlackTranslucent:
            return self.blackTranslucentBackgroundView;
            break;
        case CCBlurStyleWhite:
            return self.whiteBackgroundView;
            break;
        default:
            break;
    }
}

#pragma mark - Life Cycle

- (void)setup {
    self.showDuration = self.disMissDuration = 0.3;
    self.blurStyle = CCBlurStyleTranslucent;
    self.backgroundColor = [UIColor clearColor];
    
    _hasTapGestureEnable = NO;
}

- (void)setupTapGesture {
    if (self.hasTapGestureEnable) {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
        [self addGestureRecognizer:tapGestureRecognizer];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        UIView *backgroundView = [self backgroundView];
        backgroundView.userInteractionEnabled = NO;
        [self addSubview:backgroundView];
    }
}

@end

#pragma mark - UIView CCRealTimeBlur分类的实现

@implementation UIView (CCRealTimeBlur)

#pragma mark - Show Block

- (WillShowBlurViewBlcok)willShowBlurViewcomplted {
    return objc_getAssociatedObject(self, &CCRealTimeWillShowBlurViewBlcokBlcokKey);
}

- (void)setWillShowBlurViewcomplted:(WillShowBlurViewBlcok)willShowBlurViewcomplted {
    objc_setAssociatedObject(self, &CCRealTimeWillShowBlurViewBlcokBlcokKey, willShowBlurViewcomplted, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (DidShowBlurViewBlcok)didShowBlurViewcompleted {
    return objc_getAssociatedObject(self, &CCRealTimeDidShowBlurViewBlcokBlcokKey);
}

- (void)setDidShowBlurViewcompleted:(DidShowBlurViewBlcok)didShowBlurViewcompleted {
    objc_setAssociatedObject(self, &CCRealTimeDidShowBlurViewBlcokBlcokKey, didShowBlurViewcompleted, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark - dismiss block

- (WillDismissBlurViewBlcok)willDismissBlurViewCompleted {
    return objc_getAssociatedObject(self, &CCRealTimeWillDismissBlurViewBlcokKey);
}

- (void)setWillDismissBlurViewCompleted:(WillDismissBlurViewBlcok)willDismissBlurViewCompleted {
    objc_setAssociatedObject(self, &CCRealTimeWillDismissBlurViewBlcokKey, willDismissBlurViewCompleted, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (DidDismissBlurViewBlcok)didDismissBlurViewCompleted {
    return objc_getAssociatedObject(self, &CCRealTimeDidDismissBlurViewBlcokKey);
}

- (void)setDidDismissBlurViewCompleted:(DidDismissBlurViewBlcok)didDismissBlurViewCompleted {
    objc_setAssociatedObject(self, &CCRealTimeDidDismissBlurViewBlcokKey, didDismissBlurViewCompleted, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark - RealTimeBlur HUD


- (CCRealTimeBlur *)realTimeBlur {
    return objc_getAssociatedObject(self, &CCRealTimeBlurKey);
}

- (void)setRealTimeBlur:(CCRealTimeBlur *)realTimeBlur {
    objc_setAssociatedObject(self, &CCRealTimeBlurKey, realTimeBlur, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - 分类 公开方法

- (void)showRealTimeBlurWithBlurStyle:(CCBlurStyle)blurStyle {
    [self showRealTimeBlurWithBlurStyle:blurStyle hasTapGestureEnable:NO];
}

- (void)showRealTimeBlurWithBlurStyle:(CCBlurStyle)blurStyle hasTapGestureEnable:(BOOL)hasTapGestureEnable {
    CCRealTimeBlur *realTimeBlur = [self realTimeBlur];
    if (!realTimeBlur) {
        realTimeBlur = [[CCRealTimeBlur alloc] initWithFrame:self.bounds];
        realTimeBlur.blurStyle = blurStyle;
        [self setRealTimeBlur:realTimeBlur];
    }
    realTimeBlur.hasTapGestureEnable = hasTapGestureEnable;
    
    realTimeBlur.willShowBlurViewcomplted = self.willShowBlurViewcomplted;
    realTimeBlur.didShowBlurViewcompleted = self.didShowBlurViewcompleted;
    
    realTimeBlur.willDismissBlurViewCompleted = self.willDismissBlurViewCompleted;
    realTimeBlur.didDismissBlurViewCompleted = self.didDismissBlurViewCompleted;
    
    [realTimeBlur showBlurViewAtView:self];
}

- (void)disMissRealTimeBlur {
    [[self realTimeBlur] disMiss];
}

@end
