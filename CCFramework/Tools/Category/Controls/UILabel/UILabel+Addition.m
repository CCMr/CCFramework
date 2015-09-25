//
//  UILabel+Addition.m
//  CCFramework
//
//  Created by CC on 15/9/25.
//  Copyright (c) 2015年 CC. All rights reserved.
//

#import "UILabel+Addition.h"

@implementation UILabel (Addition)

/**
 *  @author CC, 15-09-25
 *
 *  @brief  设置CellLabel背景颜色
 *
 *  @param color 颜色值
 */
- (void)cellLabelSetColor: (UIColor *)color
{
    [self setBackgroundColor:color];
    [self performSelector:@selector(setBackgroundColor:) withObject:color afterDelay:0.01];
}

@end
