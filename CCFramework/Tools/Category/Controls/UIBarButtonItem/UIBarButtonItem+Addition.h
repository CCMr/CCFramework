//
//  UIBarButtonItem+Addition.h
//  CCFramework
//
//  Created by CC on 15/9/28.
//  Copyright (c) 2015年 CC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Addition)

/**
 *  @author CC, 15-09-28
 *
 *  @brief  图片按钮
 *
 *  @param backgroundImage 背景图片
 *  @param target          当前页面
 *  @param action          页面回调函数
 *
 *  @return 返回当前对象
 */
+ (UIBarButtonItem *)filletWithAction: (NSString *)backgroundImage
                               Target: (id)target
                               Action: (SEL)action;

/**
 *  @author C C, 2015-09-28
 *
 *  @brief  图片文字
 *
 *  @param backgroundImage 左图
 *  @param title           文字
 *  @param target          当前页面
 *  @param action          页面回调函数
 *
 *  @return 返回当前对象
 */
+ (UIBarButtonItem *)buttonItemWithImageTitle: (NSString *)backgroundImage
                                         Tile: (NSString *)title
                                       Target: (id)target
                                       Action: (SEL)action;

@end
