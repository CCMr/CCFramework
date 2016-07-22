//
//  NSMutableAttributedString+Attribute.h
//  CCFramework
//
//  Created by CC on 16/7/20.
//  Copyright © 2016年 CC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSMutableAttributedString (Attribute)

/**
 * 设置字体大小
 */
- (void)setFont:(UIFont *)font;
- (void)setFont:(UIFont *)font range:(NSRange)range;
- (void)setFont:(UIFont *)font links:(NSArray *)links;

/**
 * 设置字体颜色
 */
- (void)setTextColor:(UIColor *)textColor;
- (void)setTextColor:(UIColor *)textColor range:(NSRange)range;
- (void)setTextColor:(UIColor *)textColor links:(NSArray *)links;

/**
 * 根据传入的属性和字符串，返回对应的属性字符串
 */
+ (NSAttributedString *)attributedString:(NSString *)string
                               textColor:(UIColor *)textColor
                                    font:(UIFont *)font;

@end
