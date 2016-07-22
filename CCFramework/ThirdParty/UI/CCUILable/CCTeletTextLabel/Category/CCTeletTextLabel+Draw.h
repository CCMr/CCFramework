//
//  CCTeletTextLabel+Draw.h
//  CCFramework
//
//  Created by CC on 16/7/19.
//  Copyright © 2016年 CC. All rights reserved.
//

#import "CCTeletTextLabel.h"

@class CCTeletTextLink;

@interface CCTeletTextLabel (Draw)

/*************************只读属性*************************/
/**
 * 属性字符串
 */
@property(nonatomic, strong, readonly) NSMutableAttributedString *mutableAttributedText;

/**
 * frameRef
 */
@property(nonatomic, assign, readonly) CTFrameRef frameRef;

/**
 * 选中超文本的数据模型
 */
@property(nonatomic, strong, readonly) CCTeletTextLink *activeLink;

/*************************共有方法*************************/

/**
 * 绘制图片
 */
- (void)drawImages;

/**
 * 绘制文字
 */
- (void)frameLineDraw;

/**
 * 绘制高亮背景颜色
 */
- (void)drawHighlightedColor;


@end
