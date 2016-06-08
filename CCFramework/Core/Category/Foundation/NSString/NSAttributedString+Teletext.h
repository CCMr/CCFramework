//
//  NSAttributedString+Teletext.h
//  CCFramework
//
//  Created by CC on 16/5/30.
//  Copyright © 2016年 CC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (Teletext)

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
                                 teletextSize:(NSArray<NSDictionary *> *)teletextSize;

@end
