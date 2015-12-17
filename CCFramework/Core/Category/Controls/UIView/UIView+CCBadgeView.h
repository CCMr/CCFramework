//
//  UIView+CCBadgeView.h
//  CCFramework
//
//  Created by C C on 15/8/18.
//  Copyright (c) 2015年 C C. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCBadgeView.h"

@interface CCCircleView : UIView

@end


@interface UIView (CCBadgeView)

@property (nonatomic, assign) CGRect badgeViewFrame;
@property (nonatomic, strong, readonly) CCBadgeView *badgeView;

- (CCCircleView *)setupCircleBadge;

- (void)destroyCircleBadge;


@end
