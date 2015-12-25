//
//  CCEmotionTextAttachment.h
//  CCFramework
//
//  Created by CC on 15/12/24.
//  Copyright © 2015年 CC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCEmotionTextAttachment : NSTextAttachment

/**
 *  @author CC, 2015-12-24
 *  
 *  @brief  表情显示大小
 */
@property(nonatomic, assign) CGSize emotionSize;

/**
 *  @author CC, 2015-12-24
 *  
 *  @brief  表情本地路径
 */
@property(nonatomic, strong) NSString *emotionPath;

@end
