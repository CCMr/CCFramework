//
//  NSURLRequest+Identify.h
//  CCFramework
//
//  Created by CC on 16/3/5.
//  Copyright © 2016年 CC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (Identify)

- (NSString *)requestId;
- (void)setRequestId:(NSString *)requestId;


- (NSNumber*)startTime;
- (void)setStartTime:(NSNumber*)startTime;

@end
