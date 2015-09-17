//
//  EnumConfig.h
//  EnumConfig
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

#ifndef CCFramework__EnumConfig_h
#define CCFramework__EnumConfig_h

#pragma mark - 聊天
typedef NS_ENUM(NSInteger, CCMessageType) {
    /** 未读消息 **/
    CCMessageTypeHaveread,
    /** 已读消息 **/
    CCMessageTypeUnread,
};

/**
 *  @author C C, 15-08-17
 *
 *  @brief  消息状态
 *
 *  @since 1.0
 */
typedef NS_ENUM(NSInteger, CCMessageSendType) {
    /** 发送成功 **/
    CCMessageSendTypeSuccessful,
    /** 发送中 **/
    CCMessageSendTypeRunIng,
    /** 发送失败 **/
    CCMessageSendTypeFailure,
};

typedef NS_ENUM(NSInteger, CCBubbleMessageMediaType) {
    /** 媒体留言文本类型 **/
    CCBubbleMessageMediaTypeText = 0,
    /** 媒体留言图片类型 **/
    CCBubbleMessageMediaTypePhoto = 1,
    /** 媒体留言视频类型 **/
    CCBubbleMessageMediaTypeVideo = 2,
    /** 媒体留言类型 **/
    CCBubbleMessageMediaTypeVoice = 3,
    /** 媒体留言表情类型 **/
    CCBubbleMessageMediaTypeEmotion = 4,
    /** 媒体留言地理位置类型 **/
    CCBubbleMessageMediaTypeLocalPosition = 5,
};

/**
 *  @author C C, 15-08-17
 *
 *  @brief  消息体类型
 *
 *  @since 1.0
 */
typedef NS_ENUM(NSInteger, CCBubbleMessageType) {
    /** 发送 **/
    CCBubbleMessageTypeSending = 0,
    /** 接收 **/
    CCBubbleMessageTypeReceiving = 1,
};

/**
 *  @author C C, 15-08-17
 *
 *  @brief  气泡图片样式
 *
 *  @since 1.0
 */
typedef NS_ENUM(NSUInteger, CCBubbleImageViewStyle) {
    /** 气泡图片样式微信 **/
    CCBubbleImageViewStyleWeChat = 0
};

/**
 *  @author C C, 15-08-17
 *
 *  @brief  长按消息体状态
 *
 *  @since 1.0
 */
typedef NS_ENUM(NSInteger, CCBubbleMessageMenuSelecteType) {

    /** 消息选中文本复制 **/
    CCBubbleMessageMenuSelecteTypeTextCopy = 0,
    /** 消息选中文本转发 **/
    CCBubbleMessageMenuSelecteTypeTextTranspond = 1,
    /** 消息选中文本收藏 **/
    CCBubbleMessageMenuSelecteTypeTextFavorites = 2,
    /** 消息选中文本更多 **/
    CCBubbleMessageMenuSelecteTypeTextMore = 3,

    /** 消息选中图片复制 **/
    CCBubbleMessageMenuSelecteTypePhotoCopy = 4,
    /** 消息选中图片转发 **/
    CCBubbleMessageMenuSelecteTypePhotoTranspond = 5,
    /** 消息选中图片收藏 **/
    CCBubbleMessageMenuSelecteTypePhotoFavorites = 6,
    /** 消息选中图片更多 **/
    CCBubbleMessageMenuSelecteTypePhotoMore = 7,

    /** 消息选中视频转发 **/
    CCBubbleMessageMenuSelecteTypeVideoTranspond = 8,
    /** 消息选中视频收藏 **/
    CCBubbleMessageMenuSelecteTypeVideoFavorites = 9,
    /** 消息选中视频更对 **/
    CCBubbleMessageMenuSelecteTypeVideoMore = 10,

    /** 消息选中语音播放 **/
    CCBubbleMessageMenuSelecteTypeVoicePlay = 11,
    /** 消息选中语音收藏 **/
    CCBubbleMessageMenuSelecteTypeVoiceFavorites = 12,
    /** 消息选中语音转文本 **/
    CCBubbleMessageMenuSelecteTypeVoiceTurnToText = 13,
    /** 消息选中语音更多 **/
    CCBubbleMessageMenuSelecteTypeVoiceMore = 14,
};

/**
 *  @author C C, 15-08-17
 *
 *  @brief  加载图片状态
 *
 *  @since 1.0
 */
typedef NS_ENUM(NSInteger, UIImageViewURLDownloadState) {
    UIImageViewURLDownloadStateUnknown = 0,
    UIImageViewURLDownloadStateLoaded,
    UIImageViewURLDownloadStateWaitingForLoad,
    UIImageViewURLDownloadStateNowLoading,
    UIImageViewURLDownloadStateFailed,
};

/**
 *  @author C C, 15-08-17
 *
 *  @brief  头像状态
 *
 *  @since 1.0
 */
typedef NS_ENUM(NSInteger, CCMessageAvatarType) {
    CCMessageAvatarTypeNormal = 0,
    CCMessageAvatarTypeSquare,
    CCMessageAvatarTypeCircle
};

/**
 *  @author C C, 15-08-18
 *
 *  @brief  二维码扫描
 *
 *  @since <#1.0#>
 */
typedef NS_ENUM(NSInteger, CCScanningStyle) {
    /** 扫描二维码 **/
    CCScanningStyleQRCode = 0,
    /** 扫描杂志封面 **/
    CCScanningStyleBook,
    /** 扫描街景 **/
    CCScanningStyleStreet,
    /** 扫描翻译 **/
    CCScanningStyleWord,
};

/**
 *  @author C C, 15-08-18
 *
 *  @brief  按钮标题类型
 *
 *  @since <#1.0#>
 */
typedef NS_ENUM(NSInteger, CCButtonTitlePostionType){
    /** 底部 **/
    CCButtonTitlePostionTypeBottom = 0,
};

/**
 *  @author C C, 15-08-18
 *
 *  @brief  输入VIew类型
 *
 *  @since <#1.0#>
 */
typedef NS_ENUM(NSUInteger, CCInputViewType) {
    /** 默认 **/
    CCInputViewTypeNormal = 0,
    /** 文本 **/
    CCInputViewTypeText,
    /** 表情 **/
    CCInputViewTypeEmotion,
    /** 共享菜单 **/
    CCInputViewTypeShareMenu,
};

/**
 *  @author C C, 15-08-18
 *
 *  @brief  底部菜单选项
 *
 *  @since <#1.0#>
 */
typedef NS_ENUM(NSInteger, CCShareMenuItemType) {
    /** 照片 **/
    CCShareMenuItemTypePhoto,
    CCShareMenuItemTypeVideo,
};

/**
 *  @author C C, 15-08-18
 *
 *  @brief  上传文件类型
 *
 *  @since 1.0
 */
typedef NS_ENUM(NSInteger, CCUploadFormFileType) {
    /** 图片Jpeg **/
    CCUploadFormFileTypeImageJpeg,
};

#pragma mark - PageContainer
/**
 *  @author CC, 15-09-11
 *
 *  @brief  CCPageContainer按钮类型
 *
 *  @since 1.0
 */
typedef NS_ENUM(NSInteger, CCPageContaiinerTopBarType) {
    /** 纯文本 **/
    CCPageContaiinerTopBarTypeText = 0,
    /** 上图下文本 **/
    CCPageContaiinerTopBarTypeUPMapNextText,
    /** 左图右文本 **/
    CCPageContaiinerTopBarTypeLeftMapRightText,
};

/**
 *  @author CC, 15-09-11
 *
 *  @brief  CCPageIndicatorView类型
 *
 *  @since 1.0
 */
typedef NS_ENUM(NSInteger, CCPageIndicatorViewType) {
    /** 倒三角 **/
    CCPageIndicatorViewTypeInvertedTriangle = 0,
    /** 水平横线 **/
    CCPageIndicatorViewTypeHorizontalLine,
};

#endif