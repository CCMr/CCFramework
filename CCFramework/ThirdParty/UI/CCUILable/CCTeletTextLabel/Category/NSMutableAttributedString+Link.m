//
//  NSMutableAttributedString+Link.m
//  CCFramework
//
//  Created by CC on 16/7/19.
//  Copyright © 2016年 CC. All rights reserved.
//

#import "NSMutableAttributedString+Link.h"
#import "CCTeletTextLink.h"


@implementation NSMutableAttributedString (Link)

- (NSArray *)analysisLinkColor:(UIColor *)linkColor
                      linkFont:(UIFont *)linkFont
{
    __block NSMutableArray *links = [NSMutableArray array];
    [self enumerateAttribute:NSLinkAttributeName inRange:NSMakeRange(0, self.length) options:0 usingBlock:^(id _Nullable value, NSRange range, BOOL *_Nonnull stop) {
        if (value) {
            NSString *linkValue = nil;
            if ([value isKindOfClass:[NSURL class]]) {
                linkValue = [value absoluteString];
            }else if ([value isKindOfClass:[NSString class]]) {
                linkValue = value;
            }else if ([value isKindOfClass:[NSAttributedString class]]) {
                linkValue = [value string];
            }

            if (linkValue.length > 0) {
                CCTeletTextLink *link = [CCTeletTextLink new];
                link.text = linkValue;
                link.linkRange = range;
                [links addObject:link];

                // 设置超文本字体大小和颜色
                [self setFont:linkFont range:range];
                [self setTextColor:linkColor range:range];
            }
        }
    }];
    return links;
}

- (NSArray *)analysisLinkRegexps:(NSArray *)allRegexps
                         Regexps:(NSArray *)regexps
                           Links:(NSArray *)links
{
    __block NSMutableArray *linkArray = [NSMutableArray array];
    for (NSRegularExpression *regexp in regexps) {
        [regexp enumerateMatchesInString:self.string options:0 range:NSMakeRange(0, self.length) usingBlock:^(NSTextCheckingResult *result, __unused NSMatchingFlags flags, __unused BOOL *stop) {
            //去重处理
            for (CCTeletTextLink *link in links){
                if (NSMaxRange(NSIntersectionRange(link.linkRange, result.range))>0)
                    return;
            }

            //这个刚好和MLLinkType对应
            NSInteger linkType = [allRegexps indexOfObject:regexp]+1;

            if (linkType != 0) {
                CCTeletTextLink *link = [CCTeletTextLink new];
                link.text = [self.string substringWithRange:result.range];
                link.linkRange = result.range;
                [linkArray addObject:link];
            }
        }];
    }
      return linkArray;
}

- (void)setFont:(UIFont *)font range:(NSRange)range
{
    // 移除以前的字体大小
    [self removeAttribute:NSFontAttributeName range:range];
    // 设置字体颜色
    [self addAttribute:NSFontAttributeName value:font range:range];
}

- (void)setTextColor:(UIColor *)textColor range:(NSRange)range
{
    // 移除以前的
    [self removeAttribute:NSForegroundColorAttributeName range:range];
    // 设置字体颜色
    [self addAttribute:NSForegroundColorAttributeName value:textColor range:range];
}



@end
