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
    for (NSString *replaceStr in replaceAry)
        text = [text stringByReplacingOccurrencesOfString:replaceStr withString:OBJECT_REPLACEMENT_CHARACTER];

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];

    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:OBJECT_REPLACEMENT_CHARACTER options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *resultArray = [re matchesInString:text options:0 range:NSMakeRange(0, text.length)];

    @try {
        for (int i = 0; i < resultArray.count; i++) {
            NSDictionary *sizeDic = [teletextSize objectAtIndex:i];
            NSTextCheckingResult *match = [resultArray objectAtIndex:i];

            NSString *path = @"";
            if (teletextPath.count && i < teletextPath.count)
                path = [teletextPath objectAtIndex:i];

            CGSize size = CGSizeMake([[sizeDic objectForKey:@"width"] integerValue], [[sizeDic objectForKey:@"height"] integerValue]);
            UIImage *emojiImage = [UIImage imageWithContentsOfFile:path];
            if (emojiImage)
                size = CGSizeMake(emojiImage.size.width < size.width ? emojiImage.size.width : size.width, emojiImage.size.height < size.height ? emojiImage.size.height : size.height);

            // Resize Emoji Image
            UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
            [emojiImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
            UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            NSTextAttachment *textAttachment = [NSTextAttachment new];
            textAttachment.image = resizedImage;

            NSAttributedString *rep = [NSAttributedString attributedStringWithAttachment:textAttachment];
            [attributedString replaceCharactersInRange:[match range] withAttributedString:rep];
        }
    } @catch (NSException *exception) {

    } @finally {
    }

    return attributedString;
}

@end
