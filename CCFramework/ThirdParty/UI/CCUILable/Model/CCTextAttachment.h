//
//  CCTextAttachment.h
//  CCFramework
//
//  Created by CC on 16/7/14.
//  Copyright © 2016年 CC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCLink.h"

@interface CCTextAttachment : NSTextAttachment

@property(nonatomic, assign) CGRect imageBounds;

@property(nonatomic, strong) CCLink *link;

+ (instancetype)initAttachmentWihtLink:(CCLink *)link;

@end
