//
//  NSMutableAttributedString+Image.h
//  CCFramework
//
//  Created by CC on 16/7/19.
//  Copyright © 2016年 CC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSMutableAttributedString (Image)

/**
 *  @author CC, 16-07-19
 *
 *  @brief 检查内容中所带的图片，并处理图片相关内容
 *         ->返回存放图片对象（CCTeletTextImage）的数组
 *
 *  @param font         字体
 *  @param replaceLabel 替换标签
 *  @param replacePath  图片路径
 *  @param replaceSize  图片大小
 */
- (NSArray *)analysisImage:(UIFont *)font
              ReplaceLabel:(NSArray<NSString *> *)replaceLabel
               ReplacePath:(NSArray<NSString *> *)replacePath
               ReplaceSize:(NSArray<NSDictionary *> *)replaceSize
                AdjustType:(NSInteger)adjustType;

@end
