//
//  CCFileAttribute.m
//  CCFramework
//
//  Created by C C on 15/8/17.
//  Copyright (c) 2015年 C C. All rights reserved.
//

#import "CCFileAttribute.h"

@implementation CCFileAttribute

- (id)initWithPath:(NSString *)filePath attributes:(NSDictionary *)attributes {
    self = [super init];
    if(self){
        self.filePath = filePath;
        self.fileAttributes = attributes;
    }
    return self;
}

- (NSDate *)fileModificationDate {
    return [_fileAttributes fileModificationDate];
}

- (NSString *)description {
    return self.filePath;
}

@end
