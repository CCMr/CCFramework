//
//  CCTeletTextLink.h
//  CCFramework
//
//  Created by CC on 16/7/19.
//  Copyright © 2016年 CC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCTeletTextLink : NSObject

/**
 * 超链接文本内容
 */
@property(nonatomic, copy) NSString *text;

/**
 * 超文本内容在字符串中所在的位置
 */
@property(nonatomic, assign) NSRange linkRange;

@end
