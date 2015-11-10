//
//  CCMessageBubbleFactory.m
//  CCFramework
//
// Copyright (c) 2015 CC ( http://www.ccskill.com )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
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
    messageTypeString =
        [messageTypeString stringByAppendingString:@"_Receiving"];
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
  UIEdgeInsets bubbleImageEdgeInsets =
      [self bubbleImageEdgeInsetsWithStyle:style];
  UIImage *edgeBubbleImage = cc_Stretch_Image(bublleImage, bubbleImageEdgeInsets);
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
