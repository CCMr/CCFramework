//
//  GVUserDefaults.h
//  GVUserDefaults
//
//  Created by Kevin Renskers on 18-12-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseEntity.h"

@interface CCUserDefaults : NSObject

/**
 *  @author CC, 2015-07-29
 *
 *  @brief  单列模式
 *
 *  @return 当前对象
 *
 *  @since 1.0
 */
+ (instancetype)manager;

@end