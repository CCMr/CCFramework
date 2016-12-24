//
//  CCMessage.m
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


#import "CCMessage.h"
#import "NSString+Additions.h"

@interface CCMessage ()

@property(nonatomic, strong) NSString *objuniqueID;

@end

@implementation CCMessage

- (NSString *)objuniqueID
{
    return _objuniqueID;
}

- (instancetype)init
{
    if (self = [super init]) {
        _objuniqueID = [NSString UUID];
        _uniqueID = _objuniqueID;
    }
    return self;
}

/**
 *  @author CC, 16-08-25
 *
 *  @brief 通知消息
 *
 *  @param text      消息内容
 *  @param sender    发送人
 *  @param timestamp 发送的时间
 */
- (instancetype)initWithNotice:(NSString *)text
                        sender:(NSString *)sender
                     timestamp:(NSDate *)timestamp
{
    
    if (self = [super init]) {
        _objuniqueID = [NSString UUID];
        self.noticeContent = text;
        
        self.sender = sender;
        self.timestamp = timestamp;
        
        self.messageMediaType = CCBubbleMessageMediaTypeNotice;
    }
    return self;
}

- (instancetype)initWithText:(NSString *)text
                      sender:(NSString *)sender
                   timestamp:(NSDate *)timestamp
{
    if (self = [super init]) {
        _objuniqueID = [NSString UUID];
        self.text = text;
        
        self.sender = sender;
        self.timestamp = timestamp;
        
        self.messageMediaType = CCBubbleMessageMediaTypeText;
    }
    return self;
}

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
                       timestamp:(NSDate *)timestamp
{
    if (self = [super init]) {
        _objuniqueID = [NSString UUID];
        self.text = text;
        self.teletextPath = telextPath;
        self.teletextReplaceStr = teletextReplaceStr;
        self.sender = sender;
        self.timestamp = timestamp;
        self.messageMediaType = CCBubbleMessageMediaTypeTeletext;
    }
    return self;
}

/**
 *  初始化图片类型的消息
 *
 *  @param photo          目标图片 @{@"image":image,@"imageType":imageType}
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
                    timestamp:(NSDate *)timestamp
{
    if (self = [super init]) {
        _objuniqueID = [NSString UUID];
        self.photo = photo;
        self.thumbnailUrl = thumbnailUrl;
        self.originPhotoUrl = originPhotoUrl;
        
        self.sender = sender;
        self.timestamp = timestamp;
        
        self.messageMediaType = CCBubbleMessageMediaTypePhoto;
    }
    return self;
}

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
                    timestamp:(NSDate *)timestamp
{
    if (self = [super init]) {
        _objuniqueID = [NSString UUID];
        self.photo = photo;
        self.thumbnailUrl = thumbnailUrl;
        self.savePath = savePath;
        
        self.sender = sender;
        self.timestamp = timestamp;
        
        self.messageMediaType = CCBubbleMessageMediaTypePhoto;
    }
    return self;
}

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
                               timestamp:(NSDate *)timestamp
{
    if (self = [super init]) {
        _objuniqueID = [NSString UUID];
        self.videoConverPhoto = videoConverPhoto;
        self.videoPath = videoPath;
        self.videoUrl = videoUrl;
        
        self.sender = sender;
        self.timestamp = timestamp;
        
        self.messageMediaType = CCBubbleMessageMediaTypeVideo;
    }
    return self;
}

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
                        timestamp:(NSDate *)timestamp
{
    
    return [self initWithVoicePath:voicePath
                          voiceUrl:voiceUrl
                     voiceDuration:voiceDuration
                            sender:sender
                         timestamp:timestamp
                            isRead:NO];
}

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
                           isRead:(BOOL)isRead
{
    if (self = [super init]) {
        _objuniqueID = [NSString UUID];
        self.voicePath = voicePath;
        self.voiceUrl = voiceUrl;
        self.voiceDuration = voiceDuration;
        
        self.sender = sender;
        self.timestamp = timestamp;
        self.isRead = isRead;
        
        self.messageMediaType = CCBubbleMessageMediaTypeVoice;
    }
    return self;
}

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
                          timestamp:(NSDate *)timestamp
{
    if (self = [super init]) {
        _objuniqueID = [NSString UUID];
        self.emotionPath = emotionPath;
        self.emotionUrl = emotionUrl;
        self.sender = sender;
        self.timestamp = timestamp;
        
        self.messageMediaType = CCBubbleMessageMediaTypeEmotion;
    }
    return self;
}

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
                                 timestamp:(NSDate *)timestamp
{
    if (self = [super init]) {
        _objuniqueID = [NSString UUID];
        self.localPositionPhoto = localPositionPhoto;
        self.geolocations = geolocations;
        self.location = location;
        
        self.sender = sender;
        self.timestamp = timestamp;
        
        self.messageMediaType = CCBubbleMessageMediaTypeLocalPosition;
    }
    return self;
}

/**
 *  @author CC, 16-09-22
 *
 *  @brief 初始化文件消息类型
 *
 *  @param filePath  文件URL
 *  @param fileName  文件名称
 *  @param fileSize  文件大小
 *  @param sender    发送者
 *  @param timestamp 发送时间
 *
 *  @return 返回Message model 对象
 */
- (instancetype)initWithFile:(NSString *)fileThumbnailUrl
                    FileName:(NSString *)fileName
                    FileSize:(NSInteger)fileSize
                      sender:(NSString *)sender
                   timestamp:(NSDate *)timestamp
{
    if (self = [super init]) {
        _objuniqueID = [NSString UUID];
        self.fileThumbnailUrl = fileThumbnailUrl;
        self.fileName = fileName;
        self.fileSize = fileSize;
        
        self.sender = sender;
        self.timestamp = timestamp;
        
        self.messageMediaType = CCBubbleMessageMediaTypeFile;
    }
    return self;
}

/**
 *  @author CC, 16-09-22
 *
 *  @brief 初始化文件消息类型
 *
 *  @param filePhoto 文件图片
 *  @param fileName  文件名称
 *  @param fileSize  文件大小
 *  @param sender    发送者
 *  @param timestamp 发送时间
 *
 *  @return 返回Message model 对象
 */
- (instancetype)initWithFilePhoto:(UIImage *)filePhoto
                         FileName:(NSString *)fileName
                         FileSize:(NSInteger)fileSize
                           sender:(NSString *)sender
                        timestamp:(NSDate *)timestamp
{
    if (self = [super init]) {
        _objuniqueID = [NSString UUID];
        self.filePhoto = filePhoto;
        self.fileName = fileName;
        self.fileSize = fileSize;
        
        self.sender = sender;
        self.timestamp = timestamp;
        
        self.messageMediaType = CCBubbleMessageMediaTypeFile;
    }
    return self;
}


/**
 初始化GIF消息类型
 
 @param gifPath   GIF路径
 @param gifUrl    GIF链接
 @param sender    发送人
 @param timestamp 发送时间
 */
- (instancetype)initWithGIFPath:(NSString *)gifPath
                         GIFUrl:(NSString *)gifUrl
                         sender:(NSString *)sender
                      timestamp:(NSDate *)timestamp
{
    if (self = [super init]) {
        _objuniqueID = [NSString UUID];
        self.gifPath = gifPath;
        self.gifUrl = gifUrl;
        self.sender = sender;
        self.timestamp = timestamp;
        
        self.messageMediaType = CCBubbleMessageMediaTypeGIF;
    }
    return self;
}

/**
 初始化红包消息类型
 
 @param redPackageTitle 红包标题
 @param sender 发送人
 @param timestamp 发送时间
 */
- (instancetype)initWithRedPackage:(NSString *)redPackageTitle
                            sender:(NSString *)sender
                         timestamp:(NSDate *)timestamp
{
    if (self = [super init]) {
        _objuniqueID = [NSString UUID];
        self.redPackageTitle = redPackageTitle;
        self.sender = sender;
        self.timestamp = timestamp;
        
        self.messageMediaType = CCBubbleMessageMediaTypeRedPackage;
    }
    return self;
}

#pragma mark - NSCoding
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _objuniqueID = [aDecoder decodeObjectForKey:@"objuniqueID"];
        _uniqueID = [aDecoder decodeObjectForKey:@"uniqueID"];
        
        _noticeContent = [aDecoder decodeObjectForKey:@"noticeContent"];
        _noticeAttContent = [aDecoder decodeObjectForKey:@"noticeAttContent"];
        
        _text = [aDecoder decodeObjectForKey:@"text"];
        _teletextPath = [aDecoder decodeObjectForKey:@"teletextPath"];
        _teletextReplaceStr = [aDecoder decodeObjectForKey:@"teletextReplaceStr"];
        
        _photo = [aDecoder decodeObjectForKey:@"photo"];
        _photoType = [aDecoder decodeObjectForKey:@"photoType"];
        _photoURL = [aDecoder decodeObjectForKey:@"photoURL"];
        _thumbnailUrl = [aDecoder decodeObjectForKey:@"thumbnailUrl"];
        _originPhotoUrl = [aDecoder decodeObjectForKey:@"originPhotoUrl"];
        _savePath = [aDecoder decodeObjectForKey:@"savePath"];
        
        _videoConverPhoto = [aDecoder decodeObjectForKey:@"videoConverPhoto"];
        _videoPath = [aDecoder decodeObjectForKey:@"videoPath"];
        _videoUrl = [aDecoder decodeObjectForKey:@"videoUrl"];
        
        _voicePath = [aDecoder decodeObjectForKey:@"voicePath"];
        _voiceUrl = [aDecoder decodeObjectForKey:@"voiceUrl"];
        _voiceDuration = [aDecoder decodeObjectForKey:@"voiceDuration"];
        
        _emotionPath = [aDecoder decodeObjectForKey:@"emotionPath"];
        _emotionUrl = [aDecoder decodeObjectForKey:@"emotionUrl"];
        
        _localPositionPhoto = [aDecoder decodeObjectForKey:@"localPositionPhoto"];
        _geolocations = [aDecoder decodeObjectForKey:@"geolocations"];
        _location = [aDecoder decodeObjectForKey:@"location"];
        
        _avatar = [aDecoder decodeObjectForKey:@"avatar"];
        _avatarUrl = [aDecoder decodeObjectForKey:@"avatarUrl"];
        
        _senderId = [aDecoder decodeObjectForKey:@"senderId"];
        _sender = [aDecoder decodeObjectForKey:@"sender"];
        _senderAttribute = [aDecoder decodeObjectForKey:@"senderAttribute"];
        _timestamp = [aDecoder decodeObjectForKey:@"timestamp"];
        _showdate = [[aDecoder decodeObjectForKey:@"showdate"] boolValue];
        
        _messageMediaType = [[aDecoder decodeObjectForKey:@"messageMediaType"] integerValue];
        _messageSendState = [[aDecoder decodeObjectForKey:@"messageSendState"] integerValue];
        _bubbleMessageType = [[aDecoder decodeObjectForKey:@"bubbleMessageType"] integerValue];
        _isRead = [[aDecoder decodeObjectForKey:@"isRead"] boolValue];
        
        _filePhoto = [aDecoder decodeObjectForKey:@"filePhoto"];
        _fileThumbnailUrl = [aDecoder decodeObjectForKey:@"fileThumbnailUrl"];
        _fileName = [aDecoder decodeObjectForKey:@"fileName"];
        _fileSize = [[aDecoder decodeObjectForKey:@"fileSize"] integerValue];
        
        _gifPath = [aDecoder decodeObjectForKey:@"gifPath"];
        _gifUrl = [aDecoder decodeObjectForKey:@"gifUrl"];
        
        _redPackageTitle = [aDecoder decodeObjectForKey:@"redPackageTitle"];
        _redPackageID = [aDecoder decodeObjectForKey:@"redPackageID"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.objuniqueID forKey:@"objuniqueID"];
    [aCoder encodeObject:self.uniqueID forKey:@"uniqueID"];
    
    [aCoder encodeObject:self.noticeContent forKey:@"noticeContent"];
    [aCoder encodeObject:self.noticeAttContent forKey:@"noticeAttContent"];
    
    [aCoder encodeObject:self.text forKey:@"text"];
    [aCoder encodeObject:self.teletextPath forKey:@"teletextPath"];
    [aCoder encodeObject:self.teletextReplaceStr forKey:@"teletextReplaceStr"];
    
    [aCoder encodeObject:self.photo forKey:@"photo"];
    [aCoder encodeObject:self.photoType forKey:@"photoType"];
    [aCoder encodeObject:self.photoURL forKey:@"photoURL"];
    [aCoder encodeObject:self.thumbnailUrl forKey:@"thumbnailUrl"];
    [aCoder encodeObject:self.originPhotoUrl forKey:@"originPhotoUrl"];
    [aCoder encodeObject:self.savePath forKey:@"savePath"];
    
    [aCoder encodeObject:self.videoConverPhoto forKey:@"videoConverPhoto"];
    [aCoder encodeObject:self.videoPath forKey:@"videoPath"];
    [aCoder encodeObject:self.videoUrl forKey:@"videoUrl"];
    
    [aCoder encodeObject:self.voicePath forKey:@"voicePath"];
    [aCoder encodeObject:self.voiceUrl forKey:@"voiceUrl"];
    [aCoder encodeObject:self.voiceDuration forKey:@"voiceDuration"];
    
    [aCoder encodeObject:self.emotionPath forKey:@"emotionPath"];
    [aCoder encodeObject:self.emotionUrl forKey:@"emotionUrl"];
    
    [aCoder encodeObject:self.localPositionPhoto forKey:@"localPositionPhoto"];
    [aCoder encodeObject:self.geolocations forKey:@"geolocations"];
    [aCoder encodeObject:self.location forKey:@"location"];
    
    [aCoder encodeObject:self.avatar forKey:@"avatar"];
    [aCoder encodeObject:self.avatarUrl forKey:@"avatarUrl"];
    
    [aCoder encodeObject:self.senderId forKey:@"senderId"];
    [aCoder encodeObject:self.sender forKey:@"sender"];
    [aCoder encodeObject:self.senderAttribute forKey:@"senderAttribute"];
    [aCoder encodeObject:self.timestamp forKey:@"timestamp"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.showdate] forKey:@"showdate"];
    
    [aCoder encodeObject:[NSNumber numberWithInteger:self.messageMediaType] forKey:@"messageMediaType"];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.bubbleMessageType] forKey:@"bubbleMessageType"];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.messageSendState] forKey:@"messageSendState"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.isRead] forKey:@"isRead"];
    
    [aCoder encodeObject:self.filePhoto forKey:@"filePhoto"];
    [aCoder encodeObject:self.fileThumbnailUrl forKey:@"fileThumbnailUrl"];
    [aCoder encodeObject:self.fileName forKey:@"fileName"];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.fileSize] forKey:@"fileSize"];
    
    [aCoder encodeObject:self.gifPath forKey:@"gifPath"];
    [aCoder encodeObject:self.gifUrl forKey:@"gifUrl"];
    
    [aCoder encodeObject:self.redPackageTitle forKey:@"redPackageTitle"];
    [aCoder encodeObject:self.redPackageTitle forKey:@"redPackageID"];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    CCMessage *message;
    switch (self.messageMediaType) {
        case CCBubbleMessageMediaTypeText:
            message = [[[self class] allocWithZone:zone] initWithText:[self.text copy]
                                                               sender:[self.sender copy]
                                                            timestamp:[self.timestamp copy]];
            break;
        case CCBubbleMessageMediaTypePhoto:
            message = [[[self class] allocWithZone:zone] initWithPhoto:[self.photo copy]
                                                          thumbnailUrl:[self.thumbnailUrl copy]
                                                        originPhotoUrl:[self.originPhotoUrl copy]
                                                                sender:[self.sender copy]
                                                             timestamp:[self.timestamp copy]];
            message.thumbnailUrl = _thumbnailUrl;
            message.photoType = _photoType;
            message.photoURL = _photoURL;
            message.photoSize = _photoSize;
            if (CGSizeEqualToSize(_photoSize, CGSizeMake(0, 0))) {
                message.photoSize = _photo.size;
            }
            
            break;
        case CCBubbleMessageMediaTypeVideo:
            message = [[[self class] allocWithZone:zone] initWithVideoConverPhoto:[self.videoConverPhoto copy]
                                                                        videoPath:[self.videoPath copy]
                                                                         videoUrl:[self.videoUrl copy]
                                                                           sender:[self.sender copy]
                                                                        timestamp:[self.timestamp copy]];
            break;
        case CCBubbleMessageMediaTypeVoice:
            message = [[[self class] allocWithZone:zone] initWithVoicePath:[self.voicePath copy]
                                                                  voiceUrl:[self.voiceUrl copy]
                                                             voiceDuration:[self.voiceDuration copy]
                                                                    sender:[self.sender copy]
                                                                 timestamp:[self.timestamp copy]];
            message.videoPhotoSize = _videoPhotoSize;
            break;
        case CCBubbleMessageMediaTypeEmotion:
            message = [[[self class] allocWithZone:zone] initWithEmotionPath:[self.emotionPath copy]
                                                                  EmotionUrl:[self.emotionUrl copy]
                                                                      sender:[self.sender copy]
                                                                   timestamp:[self.timestamp copy]];
            message.emotionSize = _emotionSize;
            break;
        case CCBubbleMessageMediaTypeLocalPosition:
            message = [[[self class] allocWithZone:zone] initWithLocalPositionPhoto:[self.localPositionPhoto copy]
                                                                       geolocations:[self.geolocations copy]
                                                                           location:[self.location copy]
                                                                             sender:[self.sender copy]
                                                                          timestamp:[self.timestamp copy]];
            break;
        case CCBubbleMessageMediaTypeTeletext:
            message = [[[self class] allocWithZone:zone] initWithTeletext:[self.text copy]
                                                               TelextPath:[self.teletextPath copy]
                                                       TeletextReplaceStr:[self.teletextReplaceStr copy]
                                                                   sender:[self.sender copy]
                                                                timestamp:[self.timestamp copy]];
            message.teletextPhotoSize = _teletextPhotoSize;
            break;
        case CCBubbleMessageMediaTypeNotice:
            message = [[[self class] allocWithZone:zone] initWithNotice:[self.noticeContent copy]
                                                                 sender:[self.sender copy]
                                                              timestamp:[self.timestamp copy]];
            message.noticeAttContent = _noticeAttContent;
            break;
        case CCBubbleMessageMediaTypeFile:
            message = [[[self class] allocWithZone:zone] initWithFile:[self.fileThumbnailUrl copy]
                                                             FileName:[self.fileName copy]
                                                             FileSize:self.fileSize
                                                               sender:[self.sender copy]
                                                            timestamp:[self.timestamp copy]];
            message.filePhoto = _filePhoto;
            message.fileThumbnailUrl = _fileThumbnailUrl;
            message.fileOriginPhotoUrl = _fileOriginPhotoUrl;
            message.fileSize = _fileSize;
            message.filePhotoSize = _filePhotoSize;
            break;
        case CCBubbleMessageMediaTypeGIF:
            message = [[[self class] allocWithZone:zone] initWithGIFPath:[self.gifPath copy]
                                                                  GIFUrl:[self.gifUrl copy]
                                                                  sender:[self.sender copy]
                                                               timestamp:[self.timestamp copy]];
            message.gifSize = _gifSize;
            break;
        case CCBubbleMessageMediaTypeRedPackage:
            message = [[[self class] allocWithZone:zone] initWithRedPackage:[self.redPackageTitle copy]
                                                                     sender:[self.sender copy]
                                                                  timestamp:[self.timestamp copy]];
            message.redPackageID = _redPackageID;
            message.isOpen = _isOpen;
            break;
        default:
            break;
    }
    
    message.objuniqueID = _objuniqueID;
    message.uniqueID = _uniqueID;
    message.savePath = _savePath;
    message.objectID = _objectID;
    message.avatar = _avatar;
    message.senderId = _senderId;
    message.sender = _sender;
    message.timestamp = _timestamp;
    message.showdate = _showdate;
    message.shouldShowUserName = _shouldShowUserName;
    message.shouldShowUserLabel = _shouldShowUserLabel;
    message.userLabel = _userLabel;
    message.userLabelColor = _userLabelColor;
    message.sended = _sended;
    message.messageMediaType = _messageMediaType;
    message.messageSendState = _messageSendState;
    message.bubbleMessageType = _bubbleMessageType;
    message.isRead = _isRead;
    message.selected = _selected;
    message.senderAttribute = _senderAttribute;
    
    return message;
}

- (void)dealloc
{
    _objuniqueID = nil;
    _uniqueID = nil;
    _userLabelColor = nil;
    _userLabel = nil;
    
    _noticeContent = nil;
    _noticeAttContent = nil;
    
    _text = nil;
    _teletextPath = nil;
    _teletextReplaceStr = nil;
    
    _photo = nil;
    _photoType = nil;
    _photoURL = nil;
    _thumbnailUrl = nil;
    _originPhotoUrl = nil;
    _savePath = nil;
    
    _videoConverPhoto = nil;
    _videoPath = nil;
    _videoUrl = nil;
    
    _voicePath = nil;
    _voiceUrl = nil;
    _voiceDuration = nil;
    
    _emotionPath = nil;
    _emotionUrl = nil;
    
    _localPositionPhoto = nil;
    _geolocations = nil;
    _location = nil;
    
    _avatar = nil;
    _avatarUrl = nil;
    
    _senderId = nil;
    _sender = nil;
    _senderAttribute = nil;
    
    _timestamp = nil;
    
    _filePhoto = nil;
    _fileThumbnailUrl = nil;
    _fileName = nil;
    
    _gifPath = nil;
    _gifUrl = nil;
    
    _redPackageTitle = nil;
}


@end
