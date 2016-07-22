//
//  NSMutableAttributedString+Attribute.m
//  CCFramework
//
//  Created by CC on 16/7/20.
//  Copyright © 2016年 CC. All rights reserved.
//

#import "NSMutableAttributedString+Attribute.h"
#import "CCTeletTextLink.h"

// 行间距
static CGFloat kLineSpacing = 3.f;
// 段间距
static CGFloat kParagraphSpacing = 5.f;

@implementation NSMutableAttributedString (Attribute)

/**
 * 设置字体大小
 */
- (void)setFont:(UIFont *)font
{
    [self setFont:font range:NSMakeRange(0, self.string.length)];
}

- (void)setFont:(UIFont *)font range:(NSRange)range
{
    // 移除以前的字体大小
    [self removeAttribute:NSFontAttributeName range:range];
    // 设置字体颜色
    [self addAttribute:NSFontAttributeName value:font range:range];
}

- (void)setFont:(UIFont *)font links:(NSArray *)links
{
    for (CCTeletTextLink *linkData in links) {
        // 设置字体
        [self setFont:font range:linkData.linkRange];
    }
}

/**
 * 设置字体颜色
 */
- (void)setTextColor:(UIColor *)textColor
{
    [self setTextColor:textColor range:NSMakeRange(0, self.string.length)];
}

- (void)setTextColor:(UIColor *)textColor range:(NSRange)range
{
    // 移除以前的
    [self removeAttribute:NSForegroundColorAttributeName range:range];
    // 设置字体颜色
    [self addAttribute:NSForegroundColorAttributeName value:textColor range:range];
}

- (void)setTextColor:(UIColor *)textColor links:(NSArray *)links
{
    for (CCTeletTextLink *linkData in links) {
        // 设置颜色
        [self setTextColor:textColor range:linkData.linkRange];
    }
}

/**
 * 根据传入的属性和字符串，返回对应的属性字符串
 */
+ (NSAttributedString *)attributedString:(NSString *)string
                               textColor:(UIColor *)textColor
                                    font:(UIFont *)font
{
    // 设置段落样式
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = kLineSpacing;
    paragraphStyle.paragraphSpacing = kParagraphSpacing;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByCharWrapping;

    // 设置文本属性字典
    NSDictionary *attributes = @{
                                 NSFontAttributeName : font,
                                 NSForegroundColorAttributeName : textColor,
                                 NSParagraphStyleAttributeName : paragraphStyle
                                 };
    // 初始化可变字符串

    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithData:[string dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    [attString setAttributes:attributes range:NSMakeRange(0, attString.string.length)];

    return attString;
}


@end
