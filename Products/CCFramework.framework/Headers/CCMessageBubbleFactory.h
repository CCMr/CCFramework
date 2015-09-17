//
//  CCMessageBubbleFactory.h
//  CCFramework
//
//  Created by C C on 15/8/17.
//  Copyright (c) 2015年 C C. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EnumConfig.h"

@interface CCMessageBubbleFactory : NSObject

+ (UIImage *)bubbleImageViewForType:(CCBubbleMessageType)type
                              style:(CCBubbleImageViewStyle)style
                          meidaType:(CCBubbleMessageMediaType)mediaType;

@end
