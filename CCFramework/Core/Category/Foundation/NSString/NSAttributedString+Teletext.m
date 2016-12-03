//
//  NSAttributedString+Teletext.m
//  CCFramework
//
//  Created by CC on 16/5/30.
//  Copyright © 2016年 CC. All rights reserved.
//

#import "NSAttributedString+Teletext.h"
#import <UIKit/UIKit.h>

static NSString *const OBJECT_REPLACEMENT_CHARACTER = @"\uFFFC";

@implementation NSAttributedString (Teletext)

/**
 *  @author CC, 16-05-30
 *
 *  @brief  图文表情
 *
 *  @param text         文本
 *  @param replaceAry   替换字符
 *  @param teletextPath 表情路劲
 *  @param teletextSize 表情大小
 */
+ (NSAttributedString *)emojiAttributedString:(NSString *)text
                                   ReplaceAry:(NSArray<NSString *> *)replaceAry
                                 TeletextPath:(NSArray<NSString *> *)teletextPath
                                 teletextSize:(NSArray<NSDictionary *> *)teletextSize
{
    for (NSString *replaceStr in replaceAry){
        NSRange range = [text rangeOfString:replaceStr];
        if (range.location != NSNotFound)
            text = [text stringByReplacingCharactersInRange:range withString:OBJECT_REPLACEMENT_CHARACTER];;
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:OBJECT_REPLACEMENT_CHARACTER options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *resultArray = [re matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    @try {
        for (int i = 0; i < resultArray.count; i++) {
            NSDictionary *sizeDic = [teletextSize objectAtIndex:i];
            NSTextCheckingResult *match = [resultArray objectAtIndex:i];
            
            id emoji;
            if (teletextPath.count && i < teletextPath.count)
                emoji = [teletextPath objectAtIndex:i];
            
            CGSize size = CGSizeMake([[sizeDic objectForKey:@"width"] integerValue], [[sizeDic objectForKey:@"height"] integerValue]);
            
            if ([emoji isKindOfClass:[NSString class]]) {
                UIImage *emojiImage = [UIImage imageWithContentsOfFile:emoji];
                if (emojiImage)
                    size = CGSizeMake(emojiImage.size.width < size.width ? emojiImage.size.width : size.width, emojiImage.size.height < size.height ? emojiImage.size.height : size.height);
                
                emoji = emojiImage;
            }
            
            NSTextAttachment *textAttachment = [NSTextAttachment new];
            textAttachment.image = emoji;
            textAttachment.bounds = CGRectMake(0, -4, size.width, size.height);
            
            NSAttributedString *rep = [NSAttributedString attributedStringWithAttachment:textAttachment];
            [attributedString replaceCharactersInRange:[match range] withAttributedString:rep];
        }
    } @catch (NSException *exception) {
        
    } @finally {
    }
    
    return attributedString;
}

@end
