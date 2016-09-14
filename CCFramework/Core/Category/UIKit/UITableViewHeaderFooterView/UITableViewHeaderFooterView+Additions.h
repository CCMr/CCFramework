//
//  UITableViewHeaderFooterView+Additions.h
//  CCFramework
//
//  Created by CC on 16/9/8.
//  Copyright © 2016年 CC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewHeaderFooterView (Additions)

/**
 *  @author CC, 16-09-08
 *
 *  @brief  当前Cell数据源
 */
@property(nonatomic, copy) id cc_dataSources;

/**
 *  @author C C, 16-09-08
 *
 *  @brief  Cell 获取下标
 */
@property(nonatomic, assign) NSInteger cc_Section;

/**
 *  @author CC, 16-09-08
 *
 *  @brief  背景线图片
 */
@property(nonatomic, copy) UIImage *backgroundImage;

/**
 *  @author CC, 16-09-08
 *
 *  @brief 设置背景颜色
 */
@property(nonatomic, copy) UIColor *backgroundViewColor;

- (void)cc_headerFooterWillDisplayWithModel:(id)cModel
                                    section:(NSInteger)section;

@end
