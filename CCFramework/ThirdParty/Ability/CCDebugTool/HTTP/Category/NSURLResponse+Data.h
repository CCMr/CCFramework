//
//  NSURLResponse+Data.h
//  CCFramework
//
//  Created by CC on 16/3/5.
//  Copyright © 2016年 CC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLResponse (Data)


- (NSData *)responseData;
- (void)setResponseData:(NSData *)responseData;

@end
