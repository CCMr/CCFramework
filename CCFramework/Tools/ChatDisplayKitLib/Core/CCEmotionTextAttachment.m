//
//  CCEmotionTextAttachment.m
//  CCFramework
//
//  Created by CC on 15/12/24.
//  Copyright © 2015年 CC. All rights reserved.
//

#import "CCEmotionTextAttachment.h"
#import "UIImage+MultiFormat.h"

@implementation CCEmotionTextAttachment

- (instancetype)init
{
    if (self = [super init]) {
        [self initialization];
    }
    return self;
}

- (void)initialization
{
}

- (void)setEmotionPath:(NSString *)emotionPath
{
    _emotionPath = emotionPath;
    if (_emotionPath) {
        self.image = [UIImage sd_imageWithData:[NSData dataWithContentsOfFile:emotionPath]];
    }
}

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer
                      proposedLineFragment:(CGRect)lineFrag
                             glyphPosition:(CGPoint)position
                            characterIndex:(NSUInteger)charIndex
{
    return CGRectMake(0, 0, _emotionSize.width, _emotionSize.height);
}

@end
