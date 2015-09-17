//
//  CCMessageBubbleView.m
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

#import "CCMessageBubbleView.h"
#import "CCMessageBubbleHelper.h"
#import "CCAnimatedImage.h"
#import "Config.h"
#import "UIButton+BUIButton.h"

#define kCCHaveBubbleMargin 15.0f // 距离气泡上下边的间隙

#define kCCVoiceMargin 20.0f // 语音间隙

#define kCCArrowMarginWidth 9.0f // 箭头宽度

#define kCCLeftTextHorizontalBubblePadding 15.0f // 文本的水平间隙
#define kCCRightTextHorizontalBubblePadding 15.0f // 文本的水平间隙

#define kCCUnReadDotSize 10.0f // 语音未读的红点大小

#define kCCSendNotSuccessfulSize 30.0f //发送未成功消息按钮大小

#define kCCNoneBubblePhotoMargin (kCCHaveBubbleMargin - kCCBubblePhotoMargin) // 在没有气泡的时候，也就是在图片、视频、地理位置的时候，图片内部做了Margin，所以需要减去内部的Margin

@interface CCMessageBubbleView ()

@property (nonatomic, weak, readwrite) SETextView *displayTextView;

@property (nonatomic, weak, readwrite) UIImageView *bubbleImageView;

@property (nonatomic, weak, readwrite) CCAnimatedImageView *emotionImageView;

@property (nonatomic, weak, readwrite) UIImageView *animationVoiceImageView;

@property (nonatomic, weak, readwrite) UIImageView *voiceUnreadDotImageView;

@property (nonatomic, weak, readwrite) UIButton *sendNotSuccessfulButton;

@property (nonatomic, weak, readwrite) UIActivityIndicatorView *indicatorView;

@property (nonatomic, weak, readwrite) CCBubblePhotoImageView *bubblePhotoImageView;

@property (nonatomic, weak, readwrite) UIImageView *videoPlayImageView;

@property (nonatomic, weak, readwrite) UILabel *geolocationsLabel;

@property (nonatomic, strong, readwrite) id <CCMessageModel> message;

@end

@implementation CCMessageBubbleView

#pragma mark - Bubble view

// 获取文本的实际大小
+ (CGFloat)neededWidthForText:(NSString *)text {
    CGSize stringSize;
    NSRange range = [text rangeOfString:@"\n" options:0];
    if (range.length > 0) {
        NSArray *array = [text componentsSeparatedByString:@"\n"];
        stringSize = CGSizeMake(0, 0);
        CGSize temp;
        for (int i = 0; i < array.count; i++) {
            temp = [[array objectAtIndex:i] sizeWithFont:[[CCMessageBubbleView appearance] font] constrainedToSize:CGSizeMake(MAXFLOAT, 20)];
            if (temp.width > stringSize.width) {
                stringSize = temp;
            }
        }
    } else {
        stringSize = [text sizeWithFont:[[CCMessageBubbleView appearance] font]
                      constrainedToSize:CGSizeMake(MAXFLOAT, 20)];
    }

    return roundf(stringSize.width);
}

// 计算文本实际的大小
+ (CGSize)neededSizeForText:(NSString *)text {
    CGFloat maxWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]) * (kIsiPad ? 0.8 : (kIs_iPhone_6 ? 0.6 : (kIs_iPhone_6P ? 0.62 : 0.55)));

    CGFloat dyWidth = [CCMessageBubbleView neededWidthForText:text];

    CGSize textSize = [SETextView frameRectWithAttributtedString:[[CCMessageBubbleHelper sharedMessageBubbleHelper] bubbleAttributtedStringWithText:text]
                                                  constraintSize:CGSizeMake(maxWidth, MAXFLOAT)
                                                     lineSpacing:kCCTextLineSpacing
                                                            font:[[CCMessageBubbleView appearance] font]].size;
    return CGSizeMake((dyWidth > textSize.width ? textSize.width : dyWidth), textSize.height);
}

// 计算图片实际大小
+ (CGSize)neededSizeForPhoto:(UIImage *)photo {
    // 这里需要缩放后的size
    CGSize photoSize = CGSizeMake(140, 140);
    return photoSize;
}

// 计算语音实际大小
+ (CGSize)neededSizeForVoicePath:(NSString *)voicePath voiceDuration:(NSString *)voiceDuration {
    // 这里的100只是暂时固定，到时候会根据一个函数来计算
    float gapDuration = (!voiceDuration || voiceDuration.length == 0 ? -1 : [voiceDuration floatValue] - 1.0f);
    CGSize voiceSize = CGSizeMake(100 + (gapDuration > 0 ? (120.0 / (60 - 1) * gapDuration) : 0), 42);
    return voiceSize;
}

// 计算Emotion的高度
+ (CGSize)neededSizeForEmotion {
    return CGSizeMake(100, 100);
}

// 计算LocalPostion的高度
+ (CGSize)neededSizeForLocalPostion {
    return CGSizeMake(140, 140);
}

// 计算Cell需要实际Message内容的大小
+ (CGFloat)calculateCellHeightWithMessage:(id <CCMessageModel>)message {
    CGSize size = [CCMessageBubbleView getBubbleFrameWithMessage:message];
    return size.height;
}

// 获取Cell需要的高度
+ (CGSize)getBubbleFrameWithMessage:(id <CCMessageModel>)message {
    CGSize bubbleSize;
    switch (message.messageMediaType) {
        case CCBubbleMessageMediaTypeText: {
            CGSize needTextSize = [CCMessageBubbleView neededSizeForText:message.text];
            bubbleSize = CGSizeMake(needTextSize.width + kCCLeftTextHorizontalBubblePadding + kCCRightTextHorizontalBubblePadding + kCCArrowMarginWidth, needTextSize.height + kCCHaveBubbleMargin * 4); //这里*4的原因是：气泡内部的文本也做了margin，而且margin的大小和气泡的margin一样大小，所以需要加上*2的间隙大小
            break;
        }
        case CCBubbleMessageMediaTypeVoice: {
            // 这里的宽度是不定的，高度是固定的，根据需要根据语音长短来定制啦
            CGSize needVoiceSize = [CCMessageBubbleView neededSizeForVoicePath:message.voicePath voiceDuration:message.voiceDuration];
            bubbleSize = CGSizeMake(needVoiceSize.width, needVoiceSize.height + kCCHaveBubbleMargin * 2);
            break;
        }
        case CCBubbleMessageMediaTypeEmotion: {
            // 是否固定大小呢？
            CGSize emotionSize = [CCMessageBubbleView neededSizeForEmotion];
            bubbleSize = CGSizeMake(emotionSize.width, emotionSize.height + kCCHaveBubbleMargin * 2);
            break;
        }
        case CCBubbleMessageMediaTypePhoto: {
            CGSize needPhotoSize = [CCMessageBubbleView neededSizeForPhoto:message.photo];
            bubbleSize = CGSizeMake(needPhotoSize.width, needPhotoSize.height + kCCNoneBubblePhotoMargin * 2);
            break;
        }
        case CCBubbleMessageMediaTypeVideo: {
            CGSize needVideoConverPhotoSize = [CCMessageBubbleView neededSizeForPhoto:message.videoConverPhoto];
            bubbleSize = CGSizeMake(needVideoConverPhotoSize.width, needVideoConverPhotoSize.height + kCCNoneBubblePhotoMargin * 2);
            break;
        }
        case CCBubbleMessageMediaTypeLocalPosition: {
            // 固定大小，必须的
            CGSize localPostionSize = [CCMessageBubbleView neededSizeForLocalPostion];
            bubbleSize = CGSizeMake(localPostionSize.width, localPostionSize.height + kCCNoneBubblePhotoMargin * 2);
            break;
        }
        default:
            break;
    }
    return bubbleSize;
}

#pragma mark - UIAppearance Getters

- (UIFont *)font {
    if (_font == nil) {
        _font = [[[self class] appearance] font];
    }

    if (_font != nil) {
        return _font;
    }

    return [UIFont systemFontOfSize:16.0f];
}

#pragma mark - Getters

// 获取气泡的位置以及大小，比如有文字的气泡，语音的气泡，图片的气泡，地理位置的气泡，Emotion的气泡，视频封面的气泡
- (CGRect)bubbleFrame {
    // 1.先得到MessageBubbleView的实际大小
    CGSize bubbleSize = [CCMessageBubbleView getBubbleFrameWithMessage:self.message];

    // 2.计算起泡的大小和位置
    CGFloat paddingX = 0.0f;
    if (self.message.bubbleMessageType == CCBubbleMessageTypeSending) {
        paddingX = CGRectGetWidth(self.bounds) - bubbleSize.width;
    }

    // 最终减去上下边距的像素就可以得到气泡的位置以及大小
    return CGRectIntegral(
                          CGRectMake(paddingX,
                                     kCCHaveBubbleMargin,
                                     bubbleSize.width,
                                     bubbleSize.height - kCCHaveBubbleMargin * 2)
                          );
}

#pragma mark - Configure Methods

- (void)configureCellWithMessage:(id <CCMessageModel>)message {
    _message = message;

    [self configureBubbleImageView:message];

    [self configureMessageDisplayMediaWithMessage:message];
}

- (void)configureBubbleImageView:(id <CCMessageModel>)message {
    CCBubbleMessageMediaType currentType = message.messageMediaType;

    _voiceDurationLabel.hidden = YES;
    _voiceUnreadDotImageView.hidden = YES;

    CCMessageSendType sendType = message.messageSendState;
    switch (sendType) {
        case CCMessageSendTypeFailure:
            _sendNotSuccessfulButton.hidden = NO;
            break;
        case CCMessageSendTypeRunIng:
            _indicatorView.hidden = NO;
            [_indicatorView startAnimating];
            break;
        default:
            _sendNotSuccessfulButton.hidden = YES;
            _indicatorView.hidden = YES;
            [_indicatorView stopAnimating];
            break;
    }

    switch (currentType) {
        case CCBubbleMessageMediaTypeVoice: {
            _voiceDurationLabel.hidden = NO;
            _voiceUnreadDotImageView.hidden = message.isRead;
        }
        case CCBubbleMessageMediaTypeText:
        case CCBubbleMessageMediaTypeEmotion: {
            _bubbleImageView.image = [CCMessageBubbleFactory bubbleImageViewForType:message.bubbleMessageType style:CCBubbleImageViewStyleWeChat meidaType:message.messageMediaType];
            // 只要是文本、语音、第三方表情，背景的气泡都不能隐藏
            _bubbleImageView.hidden = NO;

            // 只要是文本、语音、第三方表情，都需要把显示尖嘴图片的控件隐藏了
            _bubblePhotoImageView.hidden = YES;


            if (currentType == CCBubbleMessageMediaTypeText) {
                // 如果是文本消息，那文本消息的控件需要显示
                _displayTextView.hidden = NO;
                // 那语言的gif动画imageView就需要隐藏了
                _animationVoiceImageView.hidden = YES;
                _emotionImageView.hidden = YES;
            } else {
                // 那如果不文本消息，必须把文本消息的控件隐藏了啊
                _displayTextView.hidden = YES;

                // 对语音消息的进行特殊处理，第三方表情可以直接利用背景气泡的ImageView控件
                if (currentType == CCBubbleMessageMediaTypeVoice) {
                    [_animationVoiceImageView removeFromSuperview];
                    _animationVoiceImageView = nil;

                    UIImageView *animationVoiceImageView = [CCMessageVoiceFactory messageVoiceAnimationImageViewWithBubbleMessageType:message.bubbleMessageType];
                    [self addSubview:animationVoiceImageView];
                    _animationVoiceImageView = animationVoiceImageView;
                    _animationVoiceImageView.hidden = NO;
                } else {
                    _emotionImageView.hidden = NO;

                    _bubbleImageView.hidden = YES;
                    _animationVoiceImageView.hidden = YES;
                }
            }
            break;
        }
        case CCBubbleMessageMediaTypePhoto:
        case CCBubbleMessageMediaTypeVideo:
        case CCBubbleMessageMediaTypeLocalPosition: {
            // 只要是图片和视频消息，必须把尖嘴显示控件显示出来
            _bubblePhotoImageView.hidden = NO;

            _videoPlayImageView.hidden = (currentType != CCBubbleMessageMediaTypeVideo);

            _geolocationsLabel.hidden = (currentType != CCBubbleMessageMediaTypeLocalPosition);

            // 那其他的控件都必须隐藏
            _displayTextView.hidden = YES;
            _bubbleImageView.hidden = YES;
            _animationVoiceImageView.hidden = YES;
            _emotionImageView.hidden = YES;
            break;
        }
        default:
            break;
    }
}

- (void)configureMessageDisplayMediaWithMessage:(id <CCMessageModel>)message {
    switch (message.messageMediaType) {
        case CCBubbleMessageMediaTypeText:
            _displayTextView.attributedText = [[CCMessageBubbleHelper sharedMessageBubbleHelper] bubbleAttributtedStringWithText:[message text]];
            break;
        case CCBubbleMessageMediaTypePhoto:
            [_bubblePhotoImageView configureMessagePhoto:message.photo thumbnailUrl:message.thumbnailUrl originPhotoUrl:message.originPhotoUrl onBubbleMessageType:self.message.bubbleMessageType];
            break;
        case CCBubbleMessageMediaTypeVideo:
            [_bubblePhotoImageView configureMessagePhoto:message.videoConverPhoto thumbnailUrl:message.thumbnailUrl originPhotoUrl:message.originPhotoUrl onBubbleMessageType:self.message.bubbleMessageType];
            break;
        case CCBubbleMessageMediaTypeVoice:
            break;
        case CCBubbleMessageMediaTypeEmotion:
            // 直接设置GIF
            if (message.emotionPath) {
                NSData *animatedData = [NSData dataWithContentsOfFile:message.emotionPath];
                CCAnimatedImage *animatedImage = [[CCAnimatedImage alloc] initWithAnimatedGIFData:animatedData];
                _emotionImageView.animatedImage = animatedImage;
            }
            break;
        case CCBubbleMessageMediaTypeLocalPosition:
            [_bubblePhotoImageView configureMessagePhoto:message.localPositionPhoto thumbnailUrl:nil originPhotoUrl:nil onBubbleMessageType:self.message.bubbleMessageType];

            _geolocationsLabel.text = message.geolocations;
            break;
        default:
            break;
    }

    [self setNeedsLayout];
}

- (void)configureVoiceDurationLabelFrameWithBubbleFrame:(CGRect)bubbleFrame {
    CGRect voiceFrame = _voiceDurationLabel.frame;
    voiceFrame.origin.x = (self.message.bubbleMessageType == CCBubbleMessageTypeSending ? bubbleFrame.origin.x - CGRectGetWidth(voiceFrame) : bubbleFrame.origin.x + bubbleFrame.size.width);
    _voiceDurationLabel.frame = voiceFrame;
    _voiceDurationLabel.textAlignment = (self.message.bubbleMessageType == CCBubbleMessageTypeSending ? NSTextAlignmentRight : NSTextAlignmentLeft);
}

- (void)configureVoiceUnreadDotImageViewFrameWithBubbleFrame:(CGRect)bubbleFrame {
    CGRect voiceUnreadDotFrame = _voiceUnreadDotImageView.frame;
    voiceUnreadDotFrame.origin.x = (self.message.bubbleMessageType == CCBubbleMessageTypeSending ? bubbleFrame.origin.x + kCCUnReadDotSize : CGRectGetMaxX(bubbleFrame) - kCCUnReadDotSize * 2);
    voiceUnreadDotFrame.origin.y = CGRectGetMidY(bubbleFrame) - kCCUnReadDotSize / 2.0;
    _voiceUnreadDotImageView.frame = voiceUnreadDotFrame;
}

/**
 *  @author CC, 15-09-15
 *
 *  @brief  设置未发送成功按钮位置
 *
 *  @param bubbleFrame 当前气泡位置
 *
 *  @since 1.0
 */
- (void)configureSendNotSuccessfulButtonFrameWithBubbleFrame:(CGRect)bubbleFrame {
    CGRect sendNotSuccessfulButtonFrame = _sendNotSuccessfulButton.frame;
    sendNotSuccessfulButtonFrame.origin.x = (self.message.bubbleMessageType == CCBubbleMessageTypeSending ? bubbleFrame.origin.x - CGRectGetWidth(sendNotSuccessfulButtonFrame) : bubbleFrame.origin.x + bubbleFrame.size.width);
    sendNotSuccessfulButtonFrame.origin.y = CGRectGetMidY(bubbleFrame) - kCCSendNotSuccessfulSize / 2.0;
    _sendNotSuccessfulButton.frame = sendNotSuccessfulButtonFrame;
}

/**
 *  @author CC, 15-09-15
 *
 *  @brief  设置发送加载loading
 *
 *  @param bubbleFrame 当前气泡位置
 *
 *  @since 1.0
 */
- (void)configureIndicatorViewFrameWithBubbleFrame:(CGRect)bubbleFrame {
    CGRect indicatorViewFrame = _indicatorView.frame;
    indicatorViewFrame.origin.x = (self.message.bubbleMessageType == CCBubbleMessageTypeSending ? bubbleFrame.origin.x - CGRectGetWidth(indicatorViewFrame) : bubbleFrame.origin.x + bubbleFrame.size.width);
    indicatorViewFrame.origin.y = CGRectGetMidY(bubbleFrame) - kCCSendNotSuccessfulSize / 2.0;
    _indicatorView.frame = indicatorViewFrame;
}

#pragma mark - Life cycle

- (instancetype)initWithFrame:(CGRect)frame
                      message:(id <CCMessageModel>)message {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _message = message;

        // 1、初始化气泡的背景
        if (!_bubbleImageView) {
            //bubble image
            CCAnimatedImageView *bubbleImageView = [[CCAnimatedImageView alloc] init];
            bubbleImageView.frame = self.bounds;
            bubbleImageView.userInteractionEnabled = YES;
            [self addSubview:bubbleImageView];
            _bubbleImageView = bubbleImageView;
        }

        // 2、初始化显示文本消息的TextView
        if (!_displayTextView) {
            SETextView *displayTextView = [[SETextView alloc] initWithFrame:CGRectZero];
            displayTextView.textColor = [UIColor colorWithWhite:0.143 alpha:1.000];
            displayTextView.backgroundColor = [UIColor clearColor];
            displayTextView.selectable = NO;
            displayTextView.lineSpacing = kCCTextLineSpacing;
            displayTextView.font = [[CCMessageBubbleView appearance] font];
            displayTextView.showsEditingMenuAutomatically = NO;
            displayTextView.highlighted = NO;
            [self addSubview:displayTextView];
            _displayTextView = displayTextView;
        }

        // 3、初始化显示图片的控件
        if (!_bubblePhotoImageView) {
            CCBubblePhotoImageView *bubblePhotoImageView = [[CCBubblePhotoImageView alloc] initWithFrame:CGRectZero];
            [self addSubview:bubblePhotoImageView];
            _bubblePhotoImageView = bubblePhotoImageView;

            if (!_videoPlayImageView) {
                UIImageView *videoPlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MessageVideoPlay"]];
                [bubblePhotoImageView addSubview:videoPlayImageView];
                _videoPlayImageView = videoPlayImageView;
            }

            if (!_geolocationsLabel) {
                UILabel *geolocationsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                geolocationsLabel.numberOfLines = 0;
                geolocationsLabel.lineBreakMode = NSLineBreakByTruncatingTail;
                geolocationsLabel.textColor = [UIColor whiteColor];
                geolocationsLabel.backgroundColor = [UIColor clearColor];
                geolocationsLabel.font = [UIFont systemFontOfSize:12];
                [bubblePhotoImageView addSubview:geolocationsLabel];
                _geolocationsLabel = geolocationsLabel;
            }
        }

        // 4、初始化显示语音时长的label
        if (!_voiceDurationLabel) {
            UILabel *voiceDurationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 30, 30)];
            voiceDurationLabel.textColor = [UIColor colorWithWhite:0.579 alpha:1.000];
            voiceDurationLabel.backgroundColor = [UIColor clearColor];
            voiceDurationLabel.font = [UIFont systemFontOfSize:13.f];
            voiceDurationLabel.textAlignment = NSTextAlignmentRight;
            voiceDurationLabel.hidden = YES;
            [self addSubview:voiceDurationLabel];
            _voiceDurationLabel = voiceDurationLabel;
        }

        // 5、初始化显示gif表情的控件
        if (!_emotionImageView) {
            CCAnimatedImageView *emotionImageView = [[CCAnimatedImageView alloc] initWithFrame:CGRectZero];
            [self addSubview:emotionImageView];
            _emotionImageView = emotionImageView;
        }

        // 6. 初始化显示语音未读标记的imageview
        if (!_voiceUnreadDotImageView) {
            UIImageView *voiceUnreadDotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kCCUnReadDotSize, kCCUnReadDotSize)];
            voiceUnreadDotImageView.image = [UIImage imageNamed:@"msg_chat_voice_unread"];
            voiceUnreadDotImageView.hidden = YES;
            [self addSubview:voiceUnreadDotImageView];
            _voiceUnreadDotImageView = voiceUnreadDotImageView;
        }

        // 7. 初始化消息未发送成功时显示重新发送按钮
        if (!_sendNotSuccessfulButton) {
            UIButton *sendNotSuccessfulButton = [UIButton buttonWithBackgroundImage:@""];
            sendNotSuccessfulButton.frame = CGRectMake(0, 0, kCCSendNotSuccessfulSize, kCCSendNotSuccessfulSize);
            sendNotSuccessfulButton.hidden = YES;
            sendNotSuccessfulButton.backgroundColor = [UIColor redColor];
            [sendNotSuccessfulButton addTarget:self action:@selector(sendNotSuccessful:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:sendNotSuccessfulButton];
            _sendNotSuccessfulButton = sendNotSuccessfulButton;
        }

        // 8. 初始化发送消息加载中
        if (!_indicatorView) {
            UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            indicatorView.frame = CGRectMake(0, 0, kCCSendNotSuccessfulSize, kCCSendNotSuccessfulSize);
            indicatorView.hidden = YES;
            [indicatorView startAnimating];
            [self addSubview:indicatorView];
            _indicatorView = indicatorView;
        }
    }
    return self;
}

/**
 *  @author CC, 15-09-15
 *
 *  @brief  为成功消息回调
 *
 *  @param sender <#sender description#>
 *
 *  @since 1.0
 */
- (void)sendNotSuccessful:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didSendNotSuccessfulCallback)])
        [self.delegate didSendNotSuccessfulCallback];
}

- (void)dealloc {
    _message = nil;

    _displayTextView = nil;

    _bubbleImageView = nil;

    _bubblePhotoImageView = nil;

    _animationVoiceImageView = nil;

    _voiceUnreadDotImageView = nil;

    _voiceDurationLabel = nil;

    _emotionImageView = nil;

    _videoPlayImageView = nil;

    _geolocationsLabel = nil;

    _font = nil;

    _sendNotSuccessfulButton = nil;

    _indicatorView = nil;

}

- (void)layoutSubviews {
    [super layoutSubviews];

    CCBubbleMessageMediaType currentType = self.message.messageMediaType;
    CGRect bubbleFrame = [self bubbleFrame];

    [self configureIndicatorViewFrameWithBubbleFrame:bubbleFrame];
    [self configureSendNotSuccessfulButtonFrameWithBubbleFrame:bubbleFrame];

    switch (currentType) {
        case CCBubbleMessageMediaTypeText:
        case CCBubbleMessageMediaTypeVoice:
        case CCBubbleMessageMediaTypeEmotion: {
            // 获取实际气泡的大小
            self.bubbleImageView.frame = bubbleFrame;

            CGFloat textX = CGRectGetMinX(bubbleFrame) + kCCRightTextHorizontalBubblePadding;
            if (self.message.bubbleMessageType == CCBubbleMessageTypeReceiving) {
                textX = CGRectGetMinX(bubbleFrame) + kCCArrowMarginWidth + kCCLeftTextHorizontalBubblePadding;
            }

            CGRect textFrame = CGRectMake(textX,
                                          CGRectGetMinY(bubbleFrame) + kCCHaveBubbleMargin,
                                          CGRectGetWidth(bubbleFrame) - kCCLeftTextHorizontalBubblePadding - kCCRightTextHorizontalBubblePadding - kCCArrowMarginWidth,
                                          bubbleFrame.size.height - kCCHaveBubbleMargin * 2);

            self.displayTextView.frame = CGRectIntegral(textFrame);

            CGRect animationVoiceImageViewFrame = self.animationVoiceImageView.frame;
            CGFloat voiceImagePaddingX = CGRectGetMaxX(bubbleFrame) - kCCVoiceMargin - CGRectGetWidth(animationVoiceImageViewFrame);
            if (self.message.bubbleMessageType == CCBubbleMessageTypeReceiving) {
                voiceImagePaddingX = CGRectGetMinX(bubbleFrame) + kCCVoiceMargin;
            }
            animationVoiceImageViewFrame.origin = CGPointMake(voiceImagePaddingX, CGRectGetMidY(textFrame) - CGRectGetHeight(animationVoiceImageViewFrame) / 2);  // 垂直居中
            self.animationVoiceImageView.frame = animationVoiceImageViewFrame;

            [self configureVoiceDurationLabelFrameWithBubbleFrame:bubbleFrame];
            [self configureVoiceUnreadDotImageViewFrameWithBubbleFrame:bubbleFrame];

            CGRect emotionImageViewFrame = bubbleFrame;
            emotionImageViewFrame.size = [CCMessageBubbleView neededSizeForEmotion];
            self.emotionImageView.frame = emotionImageViewFrame;
            break;
        }
        case CCBubbleMessageMediaTypePhoto:
        case CCBubbleMessageMediaTypeVideo:
        case CCBubbleMessageMediaTypeLocalPosition: {
            CGSize needPhotoSize = [CCMessageBubbleView neededSizeForPhoto:self.message.photo];
            CGFloat paddingX = 0.0f;
            if (self.message.bubbleMessageType == CCBubbleMessageTypeSending) {
                paddingX = CGRectGetWidth(self.bounds) - needPhotoSize.width;
            }
            CGRect photoImageViewFrame = CGRectMake(paddingX, kCCNoneBubblePhotoMargin, needPhotoSize.width, needPhotoSize.height);

            self.bubblePhotoImageView.frame = photoImageViewFrame;

            self.videoPlayImageView.center = CGPointMake(CGRectGetWidth(photoImageViewFrame) / 2.0, CGRectGetHeight(photoImageViewFrame) / 2.0);

            CGRect geolocationsLabelFrame = CGRectMake(11, CGRectGetHeight(photoImageViewFrame) - 47, CGRectGetWidth(photoImageViewFrame) - 20, 40);
            self.geolocationsLabel.frame = geolocationsLabelFrame;

            break;
        }
        default:
            break;
    }
}

@end
