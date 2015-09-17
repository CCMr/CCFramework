//
//  CCVideoOutputSampleBufferFactory.h
//  CCFramework
//
//  Created by C C on 15/8/18.
//  Copyright (c) 2015年 C C. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface CCVideoOutputSampleBufferFactory : NSObject

+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end
