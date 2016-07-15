//
//  CCTeletTextLabel.h
//  CCFramework
//
//  Created by CC on 16/7/11.
//  Copyright © 2016年 CC. All rights reserved.
//

#import <CCFramework/CCFramework.h>

typedef NS_ENUM(NSInteger, ImageAdjustType) {
    /** 默认不调整(显示给予固定大小) */
    ImageAdjustTypeDefault = 0,
    /** 自适应(图片大小) */
    ImageAdjustTypeImageSize = 1,
    /** 固定宽(显示给予固定宽，高度等比调整) */
    ImageAdjustTypeWidth = 2,
    /** 固定高(显示给予固定高，宽度等比调整) */
    ImageAdjustTypeHeigth = 3,
};


@class CCTeletTextLabel;

typedef void (^didClickLinkBlock)(CCTeletTextLabel *teletTextLabel, NSDictionary *teletTextEvent);

@interface CCTeletTextLabel : UILabel

/**
 *  @author CC, 16-07-15
 *
 *  @brief 图片适应类型
 */
@property(nonatomic, assign) ImageAdjustType adjustType;

- (void)didClickLinkBlock:(didClickLinkBlock)linkBlock;

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
