//
//  CCMessageModel.h
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
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "EnumConfig.h"

@class CCMessage;

@protocol CCMessageModel <NSObject>

@required
- (NSString *)text;

#pragma mark - 图片
- (UIImage *)photo;
- (NSString *)thumbnailUrl;
- (NSString *)originPhotoUrl;

#pragma mark - 视频
- (UIImage *)videoConverPhoto;
- (NSString *)videoPath;
- (NSString *)videoUrl;

#pragma mark - 音频
- (NSString *)voicePath;
- (NSString *)voiceUrl;
- (NSString *)voiceDuration;

#pragma mark -  地理位置
- (UIImage *)localPositionPhoto;
- (NSString *)geolocations;
- (CLLocation *)location;

- (NSString *)emotionPath;

- (UIImage *)avatar;
- (NSString *)avatarUrl;

- (CCBubbleMessageMediaType)messageMediaType;

/**
 *  @author CC, 15-09-15
 *
 *  @brief  发送消息状态
 *
 *  @return 返回消息状态
 *
 *  @since 1.0
 */
- (CCMessageSendType)messageSendState;

/**
 *  @author CC, 15-08-17
 *
 *  @brief  消息体类型
 *
 *  @since <#1.0#>
 */
- (CCBubbleMessageType)bubbleMessageType;

@optional

- (BOOL)shouldShowUserName;

/**
 *  @author CC, 15-08-17
 *
 *  @brief  发送人
 *
 *  @since 1.0
 */
- (NSString *)sender;

/**
 *  @author CC, 15-08-17
 *
 *  @brief  发送时间戳
 *
 *  @since 1.0
 */
- (NSDate *)timestamp;

/**
 *  @author CC, 15-08-17
 *
 *  @brief  是否阅读
 *
 *  @since 1.0
 */
- (BOOL)isRead;
- (void)setIsRead:(BOOL)isRead;

@end
