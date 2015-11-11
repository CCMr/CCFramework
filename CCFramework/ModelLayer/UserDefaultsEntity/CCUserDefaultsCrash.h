//
//  GVUserDefaults.h
//  GVUserDefaults
//
//  Created by Kevin Renskers on 18-12-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCUserDefaults.h"

@interface CCUserDefaultsCrash : CCUserDefaults

/**
 *  @author CC, 2015-07-30
 *
 *  @brief  是否存在奔溃日志
 *
 *  @since 1.0
 */
@property(nonatomic) BOOL isCrash;

/**
 *  @author CC, 2015-07-30
 *
 *  @brief  奔溃日志内容
 *
 *  @since 1.0
 */
@property(nonatomic, copy) NSMutableArray *crashArray;

@end
