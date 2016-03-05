//
//  NSURLSessionTask+Data.h
//  CCFramework
//
//  Created by CC on 16/3/5.
//  Copyright © 2016年 CC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLSessionTask (Data)

- (NSString*)taskDataIdentify;
- (void)setTaskDataIdentify:(NSString*)name;

- (NSMutableData*)responseDatas;
- (void)setResponseDatas:(NSMutableData*)data;

@end
