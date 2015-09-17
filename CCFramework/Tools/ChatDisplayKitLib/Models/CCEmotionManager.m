//
//  CCEmotionManager.m
//  CCFramework
//
//  Created by C C on 15/8/18.
//  Copyright (c) 2015年 C C. All rights reserved.
//

#import "CCEmotionManager.h"

@implementation CCEmotionManager

- (void)dealloc {
    [self.emotions removeAllObjects];
    self.emotions = nil;
}

@end
