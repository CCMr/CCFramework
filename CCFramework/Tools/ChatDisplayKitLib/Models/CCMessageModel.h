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
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CCBubbleMessageMediaType) {
    /** 媒体留言文本类型 */
    CCBubbleMessageMediaTypeText = 0,
    /** 媒体留言图片类型 */
    CCBubbleMessageMediaTypePhoto = 1,
    /** 媒体留言视频类型 */
    CCBubbleMessageMediaTypeVideo = 2,
    /** 媒体留言类型 */
    CCBubbleMessageMediaTypeVoice = 3,
    /** 媒体留言表情类型 */
    CCBubbleMessageMediaTypeEmotion = 4,
    /** 媒体留言小表情类型 */
    CCBubbleMessageMediaTypeSmallEmotion = 5,
    /** 媒体留言地理位置类型 */
    CCBubbleMessageMediaTypeLocalPosition = 6,
    /** 媒体留言图文类型 */
    CCBubbleMessageMediaTypeTeletext = 7,
    /** 媒体留言文件类型 */
    CCBubbleMessageMediaTypeFile = 8,
    /** 媒体留言GIF图片类型 */
    CCBubbleMessageMediaTypeGIF = 9,
    /** 媒体留言红包类型 */
    CCBubbleMessageMediaTypeRedPackage = 10,
    /** 媒体通知消息类型 */
    CCBubbleMessageMediaTypeNotice = 20,
    
};

/**
 *  @author C C, 15-08-17
 *
 *  @brief  消息状态
 */
typedef NS_ENUM(NSInteger, CCMessageSendType) {
    /** 发送成功 **/
    CCMessageSendTypeSuccessful = 1,
    /** 发送中 **/
    CCMessageSendTypeRunIng = 2,
    /** 发送失败 **/
    CCMessageSendTypeFailure = 3,
};

/**
 *  @author C C, 15-08-17
 *
 *  @brief  消息体类型
 */
typedef NS_ENUM(NSInteger, CCBubbleMessageType) {
    /** 发送 **/
    CCBubbleMessageTypeSending = 0,
    /** 接收 **/
    CCBubbleMessageTypeReceiving = 1,
};

@class CCMessage;

@protocol CCMessageModel <NSObject>

@required

- (NSString *)objuniqueID;

/**
 *  @author CC, 2016-01-21
 *
 *  @brief 唯一ID
 */
- (NSString *)uniqueID;

#pragma mark - 文本
- (NSString *)text;

/**
 *  @author CC, 2015-12-25
 *
 *  @brief  图文对应路径(键值存放)
 */
- (NSArray *)teletextPath;
- (NSArray *)teletextPhotoSize;

/**
 *  @author CC, 2016-12-28
 *
 *  @brief  图文标示符，用于替换图片标示
 */
- (NSString *)teletextReplaceStr;

#pragma mark - 图片
- (UIImage *)photo;
- (NSString *)thumbnailUrl;
- (NSString *)originPhotoUrl;
- (NSString *)savePath;
- (CGSize)photoSize;

#pragma mark - 视频
- (UIImage *)videoConverPhoto;
- (NSString *)videoPath;
- (NSString *)videoUrl;
- (CGSize)videoPhotoSize;

#pragma mark - 音频
- (NSString *)voicePath;
- (NSString *)voiceUrl;
- (NSString *)voiceDuration;

#pragma mark -  地理位置
- (UIImage *)localPositionPhoto;
- (NSString *)geolocations;
- (CLLocation *)location;
- (CGSize)localPhotoSize;

#pragma mark - 表情
- (NSString *)emotionPath;
- (NSString *)emotionUrl;
- (CGSize)emotionSize;

- (UIImage *)avatar;
- (NSString *)avatarUrl;

#pragma mark - 通知
- (NSString *)noticeContent;
- (NSAttributedString *)noticeAttContent;

#pragma mark - 文件
- (NSString *)fileThumbnailUrl;
- (NSString *)fileOriginPhotoUrl;
- (UIImage *)filePhoto;
- (NSString *)fileName;
- (NSInteger)fileSize;
- (CGSize)filePhotoSize;

#pragma mark - GIF
- (NSString *)gifPath;
- (NSString *)gifUrl;
- (CGSize)gifSize;

#pragma mark - 红包
- (NSString *)redPackageTitle;
- (NSString *)redPackageID;
- (BOOL)isOpen;

/**
 *  @author CC, 2015-11-16
 *
 *  @brief  数据存储ID
 */
- (NSManagedObjectID *)objectID;


- (CCBubbleMessageMediaType)messageMediaType;

/**
 *  @author CC, 15-09-15
 *
 *  @brief  发送消息状态
 *
 *  @return 返回消息状态
 */
- (CCMessageSendType)messageSendState;

/**
 *  @author CC, 15-08-17
 *
 *  @brief  消息体类型
 */
- (CCBubbleMessageType)bubbleMessageType;

@optional

/**
 *  @author CC, 2015-12-21
 *
 *  @brief  是否显示名称
 */
- (BOOL)shouldShowUserName;

/**
 是否显示标签
 */
- (BOOL)shouldShowUserLabel;

- (NSString *)userLabel;

/**
 标签颜色
 */
- (UIColor *)userLabelColor;

/**
 *  @author CC, 15-08-17
 *
 *  @brief  发送人
 */
- (NSString *)sender;

/**
 *  @author CC, 16-08-29
 *
 *  @brief 发送人ID
 */
- (NSString *)senderId;

/**
 *  @author CC, 16-08-06
 *
 *  @brief 发送人名字自定义样式
 */
- (NSAttributedString *)senderAttribute;

/**
 *  @author CC, 15-08-17
 *
 *  @brief  发送时间戳
 */
- (NSDate *)timestamp;

/**
 *  @author CC, 2015-12-05
 *
 *  @brief  是否显示时间
 */
-(BOOL) showdate;

/**
 *  @author CC, 15-08-17
 *
 *  @brief  是否阅读
 */
- (BOOL)isRead;
- (void)setIsRead:(BOOL)isRead;

- (BOOL)selected;
- (void)setSelected:(BOOL)selected;

@end
