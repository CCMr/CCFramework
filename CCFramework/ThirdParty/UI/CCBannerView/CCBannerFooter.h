//
//  CCBannerFooter.h
//  CCFramework
//
//  Created by CC on 16/1/27.
//  Copyright © 2016年 CC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CCBannerFooterState) {
    /** 正常状态下的footer提示 */
    CCBannerFooterStateIdle = 0,
    /** 被拖至触发点的footer提示 */
    CCBannerFooterStateTrigger,
};

@interface CCBannerFooter : UICollectionReusableView

@property(nonatomic, assign) CCBannerFooterState state;

@property(nonatomic, strong) UIImageView *arrowView;
@property(nonatomic, strong) UILabel *label;

@property(nonatomic, copy) NSString *idleTitle;
@property(nonatomic, copy) NSString *triggerTitle;

@end

