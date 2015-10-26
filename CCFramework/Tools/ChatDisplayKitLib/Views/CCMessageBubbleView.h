//
//  CCMessageBubbleView.h
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


#import <UIKit/UIKit.h>

#import "CCBubblePhotoImageView.h"
#import "CCAnimatedImageView.h"
#import "SETextView.h"

//Model
#import "CCMessageModel.h"




#define kCCMessageBubbleDisplayMaxLine 200

#define kCCTextLineSpacing 3.0

@class CCMessageBubbleView;

@protocol CCMessageBubbleViewDelegate <NSObject>

@optional

/**
 *  @author CC, 15-09-15
 *
 *  @brief  消息发送失败重新发送
 *
 *  @since 1.0
 */
- (void)didSendNotSuccessfulCallback;

@end

@interface CCMessageBubbleView : UIView

/**
 *  @author CC, 15-09-15
 *
 *  @brief  气泡消息委托
 *
 *  @since 1.0
 */
@property (nonatomic, weak) id<CCMessageBubbleViewDelegate> delegate;

/**
 *  目标消息Model对象
 */
@property (nonatomic, strong, readonly)  id <CCMessageModel> message;

/**
 *  自定义显示文本消息控件，子类化的原因有两个，第一个是屏蔽Menu的显示。第二是传递手势到下一层，因为文本需要双击的手势
 */
@property (nonatomic, weak, readonly) SETextView *displayTextView;

/**
 *  用于显示气泡的ImageView控件
 */
@property (nonatomic, weak, readonly) UIImageView *bubbleImageView;

/**
 *  专门用于gif表情显示控件
 */
@property (nonatomic, weak, readonly) CCAnimatedImageView *emotionImageView;

/**
 *  用于显示语音的控件，并且支持播放动画
 */
@property (nonatomic, weak, readonly) UIImageView *animationVoiceImageView;

/**
 *  用于显示语音未读的控件，小圆点
 */
@property (nonatomic, weak, readonly) UIImageView *voiceUnreadDotImageView;

/**
 *  @author CC, 15-09-15
 *
 *  @brief  消息发送未成功
 *
 *  @since 1.0
 */
@property (nonatomic, weak, readonly) UIButton *sendNotSuccessfulButton;

/**
 *  @author CC, 15-09-15
 *
 *  @brief  发送加载
 *
 *  @since 1.0
 */
@property (nonatomic, weak,readonly) UIActivityIndicatorView *indicatorView;

/**
 *  用于显示语音时长的label
 */
@property (nonatomic, weak) UILabel *voiceDurationLabel;

/**
 *  用于显示仿微信发送图片的控件
 */
@property (nonatomic, weak, readonly) CCBubblePhotoImageView *bubblePhotoImageView;

/**
 *  显示语音播放的图片控件
 */
@property (nonatomic, weak, readonly) UIImageView *videoPlayImageView;

/**
 *  显示地理位置的文本控件
 */
@property (nonatomic, weak, readonly) UILabel *geolocationsLabel;

/**
 *  设置文本消息的字体
 */
@property (nonatomic, strong) UIFont *font UI_APPEARANCE_SELECTOR;

/**
 *  初始化消息内容显示控件的方法
 *
 *  @param frame   目标Frame
 *  @param message 目标消息Model对象
 *
 *  @return 返回XHMessageBubbleView类型的对象
 */
- (instancetype)initWithFrame:(CGRect)frame
                      message:(id <CCMessageModel>)message;

/**
 *  获取气泡相对于父试图的位置
 *
 *  @return 返回气泡的位置
 */
- (CGRect)bubbleFrame;

/**
 *  根据消息Model对象配置消息显示内容
 *
 *  @param message 目标消息Model对象
 */
- (void)configureCellWithMessage:(id <CCMessageModel>)message;

/**
 *  根据消息Model对象计算消息内容的高度
 *
 *  @param message 目标消息Model对象
 *
 *  @return 返回所需高度
 */
+ (CGFloat)calculateCellHeightWithMessage:(id <CCMessageModel>)message;


@end
