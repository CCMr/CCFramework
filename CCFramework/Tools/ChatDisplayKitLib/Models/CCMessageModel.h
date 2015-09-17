//
//  XHMessageModel.h
//  MessageDisplayExample
//
//  Created by HUAJIE-1 on 14-4-24.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
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

