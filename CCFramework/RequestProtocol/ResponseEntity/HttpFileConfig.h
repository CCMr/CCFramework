//
//  HttpFileConfig.h
//  CCFramework
//
//  Created by CC on 16/3/11.
//  Copyright © 2016年 CC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpFileConfig : NSObject

/**
 *  @author CC, 16-03-10
 *  
 *  @brief 文件数据
 */
@property (nonatomic, strong) NSData *fileData;

/**
 *  @author CC, 16-03-10
 *  
 *  @brief  服务器接收参数名
 */
@property (nonatomic, copy) NSString *name;

/**
 *  @author CC, 16-03-10
 *  
 *  @brief 文件名
 */
@property (nonatomic, copy) NSString *fileName;

/**
 *  @author CC, 16-03-10
 *  
 *  @brief 文件类型
 */
@property (nonatomic, copy) NSString *mimeType;

@end
