//
//  CCMessageAvatarFactory.h
//  CCFramework
//
//  Created by C C on 15/8/17.
//  Copyright (c) 2015年 C C. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EnumConfig.h"

// 头像大小以及头像与其他控件的距离
static CGFloat const kCCAvatarImageSize = 40.0f;
static CGFloat const kCCAlbumAvatarSpacing = 15.0f;

@interface CCMessageAvatarFactory : NSObject

+ (UIImage *)avatarImageNamed:(UIImage *)originImage
            messageAvatarType:(CCMessageAvatarType)type;

@end
