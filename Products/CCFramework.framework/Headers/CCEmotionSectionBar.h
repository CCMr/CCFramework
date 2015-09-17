//
//  CCEmotionSectionBar.h
//  CCFramework
//
//  Created by C C on 15/8/18.
//  Copyright (c) 2015年 C C. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCEmotionManager.h"

@protocol CCEmotionSectionBarDelegate <NSObject>

/**
 *  点击某一类gif表情的回调方法
 *
 *  @param emotionManager 被点击的管理表情Model对象
 *  @param section        被点击的位置
 */
- (void)didSelecteEmotionManager:(CCEmotionManager *)emotionManager atSection:(NSInteger)section;

@end

@interface CCEmotionSectionBar : UIView

@property (nonatomic, weak) id <CCEmotionSectionBarDelegate> delegate;

/**
 *  数据源
 */
@property (nonatomic, strong) NSArray *emotionManagers;

- (instancetype)initWithFrame:(CGRect)frame showEmotionStoreButton:(BOOL)isShowEmotionStoreButtoned;


/**
 *  根据数据源刷新UI布局和数据
 */
- (void)reloadData;

@end
