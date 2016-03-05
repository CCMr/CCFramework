//
//  NSURLRequest+Identify.m
//  CCFramework
//
//  Created by CC on 16/3/5.
//  Copyright © 2016年 CC. All rights reserved.
//

#import "NSURLRequest+Identify.h"
#import <objc/runtime.h>

@implementation NSURLRequest (Identify)

- (NSString *)requestId {
    return objc_getAssociatedObject(self, @"requestId");
}

- (void)setRequestId:(NSString *)requestId {
    objc_setAssociatedObject(self, @"requestId", requestId, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSNumber*)startTime {
    return objc_getAssociatedObject(self, @"startTime");
}

- (void)setStartTime:(NSNumber*)startTime {
    objc_setAssociatedObject(self, @"startTime", startTime, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
