//
//  CCTeletTextLabel+Utils.h
//  CCFramework
//
//  Created by CC on 16/7/19.
//  Copyright © 2016年 CC. All rights reserved.
//

#import "CCTeletTextLabel.h"

@class CCTeletTextLink, CCTeletTextImage;

@interface CCTeletTextLabel (Utils)

/*************************只读属性*************************/
/**
 * frameRef
 */
@property(nonatomic, assign, readonly) CTFrameRef frameRef;

/**
 * 存放link数据模型的数组
 */
@property(nonatomic, strong, readonly) NSMutableArray *linkArr;

/**
 * 存放图片数据模型的数组
 */
@property(nonatomic, strong, readonly) NSMutableArray *imageArr;


/*************************共有方法*************************/

/**
 * 检测点击位置是否在链接上
 * ->若在链接上，返回CCTeletTextLink
 *   包含超文本内容和range
 * ->如果没点中反回nil
 */
- (CCTeletTextLink *)touchLinkWithPosition:(CGPoint)position;

/**
 * 监测点击的位置是否在图片上
 * ->若在链接上，返回CCTeletTextImage
 * ->如果没点中反回nil
 */
- (CCTeletTextImage *)touchContentOffWithPosition:(CGPoint)position;

@end
