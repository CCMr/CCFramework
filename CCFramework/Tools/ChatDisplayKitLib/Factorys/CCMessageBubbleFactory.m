//
//  CCMessageBubbleFactory.m
//  CCFramework
//
//  Created by C C on 15/8/17.
//  Copyright (c) 2015年 C C. All rights reserved.
//

#import "CCMessageBubbleFactory.h"
#import "Config.h"

@implementation CCMessageBubbleFactory

+ (UIImage *)bubbleImageViewForType:(CCBubbleMessageType)type
                              style:(CCBubbleImageViewStyle)style
                          meidaType:(CCBubbleMessageMediaType)mediaType {
    NSString *messageTypeString;

    switch (style) {
        case CCBubbleImageViewStyleWeChat:
            // 类似微信的
            messageTypeString = @"weChatBubble";
            break;
        default:
            break;
    }

    switch (type) {
        case CCBubbleMessageTypeSending:
            // 发送
            messageTypeString = [messageTypeString stringByAppendingString:@"_Sending"];
            break;
        case CCBubbleMessageTypeReceiving:
            // 接收
            messageTypeString = [messageTypeString stringByAppendingString:@"_Receiving"];
            break;
        default:
            break;
    }

    switch (mediaType) {
        case CCBubbleMessageMediaTypePhoto:
        case CCBubbleMessageMediaTypeVideo:
            messageTypeString = [messageTypeString stringByAppendingString:@"_Solid"];
            break;
        case CCBubbleMessageMediaTypeText:
        case CCBubbleMessageMediaTypeVoice:
            messageTypeString = [messageTypeString stringByAppendingString:@"_Solid"];
            break;
        default:
            break;
    }


    UIImage *bublleImage = [UIImage imageNamed:messageTypeString];
    UIEdgeInsets bubbleImageEdgeInsets = [self bubbleImageEdgeInsetsWithStyle:style];
    UIImage *edgeBubbleImage = CC_STRETCH_IMAGE(bublleImage, bubbleImageEdgeInsets);
    return edgeBubbleImage;
}

+ (UIEdgeInsets)bubbleImageEdgeInsetsWithStyle:(CCBubbleImageViewStyle)style {
    UIEdgeInsets edgeInsets;
    switch (style) {
        case CCBubbleImageViewStyleWeChat:
            // 类似微信的
            edgeInsets = UIEdgeInsetsMake(30, 28, 85, 28);
            break;
        default:
            break;
    }
    return edgeInsets;
}


@end
