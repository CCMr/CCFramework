//
//  CCTeletTextLabel.h
//  CCFramework
//
//  Created by CC on 16/7/11.
//  Copyright © 2016年 CC. All rights reserved.
//

#import <CCFramework/CCFramework.h>

@interface CCTeletTextLabel : UILabel

@property(nonatomic, copy) void (^didClickLinkBlock)();

/**
 *  @author CC, 16-07-11
 *
 *  @brief  图文混排
 *
 *  @param text         文本内容
 *  @param DefaultImage 默认图片
 *  @param replaceAry   替换标签
 *  @param teletextPath 图片地址
 *  @param teletextSize 图片大小
 *                      命名规则 @[@{ @"width" : 20, @"height" : 20}]
 */
- (void)coreTeletext:(NSString *)text
        DefaultImage:(UIImage *)defalutImage
          ReplaceAry:(NSArray<NSString *> *)replaceAry
        TeletextPath:(NSArray<NSString *> *)teletextPath
        teletextSize:(NSArray<NSDictionary *> *)teletextSize;

@end
