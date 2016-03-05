//
//  NSURLResponse+Data.m
//  CCFramework
//
//  Created by CC on 16/3/5.
//  Copyright © 2016年 CC. All rights reserved.
//

#import "NSURLResponse+Data.h"
#import <objc/runtime.h>

@implementation NSURLResponse (Data)

- (NSData *)responseData
{
    return objc_getAssociatedObject(self, @"responseData");
}

- (void)setResponseData:(NSData *)responseData
{
    objc_setAssociatedObject(self, @"responseData", responseData, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
@end
