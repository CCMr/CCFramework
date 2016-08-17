//
//  CCMessage.h
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
#import "CCMessageModel.h"
#import <CoreData/CoreData.h>
#import "BaseEntity.h"

@interface CCMessage : BaseEntity <CCMessageModel, NSCoding, NSCopying>

/**
 *  @author CC, 2016-01-21
 *
 *  @brief 唯一ID
 */
@property(nonatomic, copy) NSString *uniqueID;

@property(nonatomic, copy) NSString *text;

/**
 *  @author CC, 2015-12-25
 *
 *  @brief  图文对应路径(键值存放)
 */
@property(nonatomic, copy) NSArray *teletextPath;

/**
 *  @author CC, 2016-12-28
 *
 *  @brief  图文标示符，用于替换图片标示
 */
@property(nonatomic, copy) NSString *teletextReplaceStr;

#pragma mark - 图片
@property(nonatomic, strong) UIImage *photo;
@property(nonatomic, copy) NSString *thumbnailUrl;
@property(nonatomic, copy) NSString *originPhotoUrl;

/**
 *  @author CC, 16-08-17
 *
 *  @brief 加载后保存路径
 */
@property(nonatomic, copy) NSString *savePath;

#pragma mark - 视频
@property(nonatomic, strong) UIImage *videoConverPhoto;
@property(nonatomic, copy) NSString *videoPath;
@property(nonatomic, copy) NSString *videoUrl;

#pragma mark - 音频
@property(nonatomic, copy) NSString *voicePath;
@property(nonatomic, copy) NSString *voiceUrl;
@property(nonatomic, copy) NSString *voiceDuration;

#pragma mark - 表情
@property(nonatomic, copy) NSString *emotionPath;
@property(nonatomic, copy) NSString *emotionUrl;

#pragma mark -  地理位置
@property(nonatomic, strong) UIImage *localPositionPhoto;
@property(nonatomic, copy) NSString *geolocations;
@property(nonatomic, strong) CLLocation *location;

@property(nonatomic, strong) UIImage *avatar;
@property(nonatomic, copy) NSString *avatarUrl;

/**
 *  @author CC, 2015-11-16
 *
 *  @brief  数据存储ID
 */
@property(nonatomic, copy) NSManagedObjectID *objectID;

/**
 *  @author CC, 15-08-17
 *
 *  @brief  发送人
 *
 *  @since 1.0
 */
@property(nonatomic, copy) NSString *sender;

/**
 *  @author CC, 16-08-06
 *
 *  @brief 发送人名字自定义样式
 */
@property(nonatomic, copy) NSAttributedString *senderAttribute;

/**
 *  @author CC, 15-08-17
 *
 *  @brief  发送时间戳
 */
@property(nonatomic, strong) NSDate *timestamp;

/**
 *  @author CC, 2015-12-05
 *
 *  @brief  是否显示时间
 */
@property(nonatomic, assign) BOOL showdate;

/**
 *  @author CC, 2015-12-21
 *
 *  @brief  是否显示名称
 */
@property(nonatomic, assign) BOOL shouldShowUserName;

@property(nonatomic, assign) BOOL sended;

/**
 *  @author CC, 15-08-17
 *
 *  @brief  媒体留言类型
 */
@property(nonatomic, assign) CCBubbleMessageMediaType messageMediaType;

/**
 *  @author CC, 15-09-15
 *
 *  @brief  发送消息状态
 */
@property(nonatomic, assign) CCMessageSendType messageSendState;

/**
 *  @author CC, 15-08-17
 *
 *  @brief  消息体类型
 */
@property(nonatomic, assign) CCBubbleMessageType bubbleMessageType;

/**
 *  @author CC, 15-08-17
 *
 *  @brief  是否阅读
 */
@property(nonatomic) BOOL isRead;

/**
 *  @author CC, 2015-11-16
 *
 *  @brief  编辑状态下选中
 */
@property(nonatomic) BOOL selected;


/**
 *  初始化文本消息
 *
 *  @param text   发送的目标文本
 *  @param sender 发送者的名称
 *  @param date   发送的时间
 *
 *  @return 返回Message model 对象
 */
- (instancetype)initWithText:(NSString *)text
                      sender:(NSString *)sender
                   timestamp:(NSDate *)timestamp;

/**
 *  @author CC, 2015-12-25
 *
 *  @brief  初始化图文消息
 *
 *  @param text       发送的目标文本
 *  @param telextPath 发送目标的图片路径
 *  @param sender     发送者的名称
 *  @param timestamp  发送的时间
 *
 *  @return 返回Message model 对象
 */
- (instancetype)initWithTeletext:(NSString *)text
                      TelextPath:(NSArray *)telextPath
              TeletextReplaceStr:(NSString *)teletextReplaceStr
                          sender:(NSString *)sender
                       timestamp:(NSDate *)timestamp;

/**
 *  初始化图片类型的消息
 *
 *  @param photo          目标图片
 *  @param thumbnailUrl   目标图片在服务器的缩略图地址
 *  @param originPhotoUrl 目标图片在服务器的原图地址
 *  @param sender         发送者
 *  @param date           发送时间
 *
 *  @return 返回Message model 对象
 */
- (instancetype)initWithPhoto:(UIImage *)photo
                 thumbnailUrl:(NSString *)thumbnailUrl
               originPhotoUrl:(NSString *)originPhotoUrl
                       sender:(NSString *)sender
                    timestamp:(NSDate *)timestamp;

/**
 *  @author CC, 16-08-17
 *
 *  @brief 初始化图片类型的消息
 *
 *  @param photo        目标图片
 *  @param thumbnailUrl 目标图片在服务器的缩略图地址
 *  @param savePath     目标保存本地路径
 *  @param sender       发送者
 *  @param timestamp    发送时间
 */
- (instancetype)initWithPhoto:(UIImage *)photo
                 thumbnailUrl:(NSString *)thumbnailUrl
                     savePath:(NSString *)savePath
                       sender:(NSString *)sender
                    timestamp:(NSDate *)timestamp;

/**
 *  初始化视频类型的消息
 *
 *  @param videoConverPhoto 目标视频的封面图
 *  @param videoPath        目标视频的本地路径，如果是下载过，或者是从本地发送的时候，会存在
 *  @param videoUrl         目标视频在服务器上的地址
 *  @param sender           发送者
 *  @param date             发送时间
 *
 *  @return 返回Message model 对象
 */
- (instancetype)initWithVideoConverPhoto:(UIImage *)videoConverPhoto
                               videoPath:(NSString *)videoPath
                                videoUrl:(NSString *)videoUrl
                                  sender:(NSString *)sender
                               timestamp:(NSDate *)timestamp;

/**
 *  初始化语音类型的消息
 *
 *  @param voicePath        目标语音的本地路径
 *  @param voiceUrl         目标语音在服务器的地址
 *  @param voiceDuration    目标语音的时长
 *  @param sender           发送者
 *  @param date             发送时间
 *
 *  @return 返回Message model 对象
 */
- (instancetype)initWithVoicePath:(NSString *)voicePath
                         voiceUrl:(NSString *)voiceUrl
                    voiceDuration:(NSString *)voiceDuration
                           sender:(NSString *)sender
                        timestamp:(NSDate *)timestamp;

/**
 *  初始化语音类型的消息。增加已读未读标记
 *
 *  @param voicePath        目标语音的本地路径
 *  @param voiceUrl         目标语音在服务器的地址
 *  @param voiceDuration    目标语音的时长
 *  @param sender           发送者
 *  @param date             发送时间
 *  @param isRead           已读未读标记
 *
 *  @return 返回Message model 对象
 */
- (instancetype)initWithVoicePath:(NSString *)voicePath
                         voiceUrl:(NSString *)voiceUrl
                    voiceDuration:(NSString *)voiceDuration
                           sender:(NSString *)sender
                        timestamp:(NSDate *)timestamp
                           isRead:(BOOL)isRead;

/**
 *  初始化gif表情类型的消息
 *
 *  @param emotionPath 表情的路径
 *  @param sender      发送者
 *  @param timestamp   发送时间
 *
 *  @return 返回Message model 对象
 */
- (instancetype)initWithEmotionPath:(NSString *)emotionPath
                         EmotionUrl:(NSString *)emotionUrl
                             sender:(NSString *)sender
                          timestamp:(NSDate *)timestamp;

/**
 *  初始化地理位置的消息
 *
 *  @param localPositionPhoto 地理位置默认显示的图
 *  @param geolocations       地理位置的信息
 *  @param location           地理位置的经纬度
 *  @param sender             发送者
 *  @param timestamp          发送时间
 *
 *  @return 返回Message model 对象
 */
- (instancetype)initWithLocalPositionPhoto:(UIImage *)localPositionPhoto
                              geolocations:(NSString *)geolocations
                                  location:(CLLocation *)location
                                    sender:(NSString *)sender
                                 timestamp:(NSDate *)timestamp;

@end
