//
//  UIBarButtonItem+Addition.m
//  CCFramework
//
//  Created by CC on 15/9/28.
//  Copyright (c) 2015年 CC. All rights reserved.
//

#import "UIBarButtonItem+Addition.h"
#import "UIButton+BUIButton.h"
#import "NSString+BNSString.h"

@implementation UIBarButtonItem (Addition)

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
                              Action: (SEL)action
{
    UIButton * button = [ UIButton buttonWithType : UIButtonTypeCustom ];
    [button setImage:[UIImage imageNamed:backgroundImage ] forState:UIControlStateNormal];
    [button setFrame:CGRectMake (0,0,35,35)];
    [[button layer] setCornerRadius:17];
    [[button layer] setMasksToBounds:YES];
    [button addTarget:target action :action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itme = [[UIBarButtonItem alloc] initWithCustomView:button];
    return itme;
}

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
                                       Action: (SEL)action
{
    UIButton *button = [UIButton buttonWithImageTitle:backgroundImage Title:title Frame:CGRectMake(0, 0, [title calculateTextWidthHeight].width+10, 40)];
    [button addTarget:target action :action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itme = [[UIBarButtonItem alloc] initWithCustomView:button];
    return itme;
}


@end
