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
#import "CCTool.h"
#import "UIButton+Additions.h"
#import "UIImageView+Additions.h"
#import "CCMessagePhotoImageView.h"
//Factorys
#import "CCMessageBubbleFactory.h"
#import "CCMessageVoiceFactory.h"

#define kCCHaveBubbleMargin 5.0f      // 文本、视频、表情气泡上下边的间隙
#define kCCHaveBubbleVoiceMargin 8.5f // 语音气泡上下边的间隙
#define kCCHaveBubblePhotoMargin 6.5f // 图片、地理位置气泡上下边的间隙

#define kCCVoiceMargin 20.0f // 播放语音时的动画控件距离头像的间隙

#define kCCArrowMarginWidth 5.2f // 箭头宽度

#define kCCTopAndBottomBubbleMargin 8.0f	 // 文本在气泡内部的上下间隙
#define kCCLeftTextHorizontalBubblePadding 10.0f  // 文本的水平间隙
#define kCCRightTextHorizontalBubblePadding 10.0f // 文本的水平间隙

#define kCCUnReadDotSize 10.0f // 语音未读的红点大小

#define kCCSendNotSuccessfulSize 25.0f //发送未成功消息按钮大小

#define kCCNoneBubblePhotoMargin (kCCHaveBubbleMargin - kCCBubblePhotoMargin)							 // 在没有气泡的时候，也就是在图片、视频、地理位置的时候，图片内部做了Margin，所以需要减去内部的Margin
#define kCCMaxWidth CGRectGetWidth([[UIScreen mainScreen] bounds]) * (isiPad ? 0.8 : (iPhone6 ? 0.6 : (iPhone6P ? 0.62 : 0.55))) // 文本只有一行的时候，宽度可能出现很小到最大的情况，所以需要计算一行文字需要的宽度
#define kCCMaxHeight 250													 //最大高度

//文本中的表情
static NSString *const OBJECT_REPLACEMENT_CHARACTER = @"\uFFFC";


@interface CCMessageBubbleView ()

@property(nonatomic, weak, readwrite) SETextView *displayTextView;

@property(nonatomic, weak, readwrite) UIImageView *bubbleImageView;

@property(nonatomic, weak, readwrite) CCAnimatedImageView *emotionImageView;

@property(nonatomic, weak, readwrite) UIImageView *animationVoiceImageView;

@property(nonatomic, weak, readwrite) UIImageView *voiceUnreadDotImageView;

@property(nonatomic, weak, readwrite) UIButton *sendNotSuccessfulButton;

@property(nonatomic, weak, readwrite) UIActivityIndicatorView *indicatorView;

@property(nonatomic, weak, readwrite) CCBubblePhotoImageView *bubblePhotoImageView;

@property(nonatomic, weak, readwrite) UIImageView *videoPlayImageView;

@property(nonatomic, weak, readwrite) UILabel *geolocationsLabel;

@property(nonatomic, strong, readwrite) id<CCMessageModel> message;

@end

@implementation CCMessageBubbleView

#pragma mark -网络图片大小
/**
 *  @author CC, 16-08-01
 *
 *  @brief 根据图片url获取图片尺寸
 */
+ (CGSize)obtainImageSizeWithURL:(id)imageURL
{
    NSURL *URL = nil;
    if ([imageURL isKindOfClass:[NSURL class]]) {
        URL = imageURL;
    }
    if ([imageURL isKindOfClass:[NSString class]]) {
        URL = [NSURL URLWithString:imageURL];
    }
    if (URL == nil)
        return CGSizeZero; // url不正确返回CGSizeZero

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    NSString *pathExtendsion = [URL.pathExtension lowercaseString];

    CGSize urlImageSize = CGSizeZero;
    if ([pathExtendsion isEqualToString:@"png"]) {
        urlImageSize = [self getPNGImageSizeWithRequest:request];
    } else if ([pathExtendsion isEqual:@"gif"]) {
        urlImageSize = [self getGIFImageSizeWithRequest:request];
    } else {
        urlImageSize = [self getJPGImageSizeWithRequest:request];
    }

    if (CGSizeEqualToSize(CGSizeZero, urlImageSize)) { // 如果获取文件头信息失败,发送异步请求请求原图
        NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:URL] returningResponse:nil error:nil];
        UIImage *image = [UIImage imageWithData:data];
        if (image)
            urlImageSize = image.size;
    }

    return urlImageSize;
}

/**
 *  @author CC, 16-08-01
 *
 *  @brief 获取PNG图片的大小
 */
+ (CGSize)getPNGImageSizeWithRequest:(NSMutableURLRequest *)request
{
    [request setValue:@"bytes=16-23" forHTTPHeaderField:@"Range"];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (data.length == 8) {
        int w1 = 0, w2 = 0, w3 = 0, w4 = 0;
        [data getBytes:&w1 range:NSMakeRange(0, 1)];
        [data getBytes:&w2 range:NSMakeRange(1, 1)];
        [data getBytes:&w3 range:NSMakeRange(2, 1)];
        [data getBytes:&w4 range:NSMakeRange(3, 1)];
        int w = (w1 << 24) + (w2 << 16) + (w3 << 8) + w4;
        int h1 = 0, h2 = 0, h3 = 0, h4 = 0;
        [data getBytes:&h1 range:NSMakeRange(4, 1)];
        [data getBytes:&h2 range:NSMakeRange(5, 1)];
        [data getBytes:&h3 range:NSMakeRange(6, 1)];
        [data getBytes:&h4 range:NSMakeRange(7, 1)];
        int h = (h1 << 24) + (h2 << 16) + (h3 << 8) + h4;
        return CGSizeMake(w, h);
    }
    return CGSizeZero;
}

/**
 *  @author CC, 16-08-01
 *
 *  @brief 获取gif图片的大小
 */
+ (CGSize)getGIFImageSizeWithRequest:(NSMutableURLRequest *)request
{
    [request setValue:@"bytes=6-9" forHTTPHeaderField:@"Range"];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (data.length == 4) {
        short w1 = 0, w2 = 0;
        [data getBytes:&w1 range:NSMakeRange(0, 1)];
        [data getBytes:&w2 range:NSMakeRange(1, 1)];
        short w = w1 + (w2 << 8);
        short h1 = 0, h2 = 0;
        [data getBytes:&h1 range:NSMakeRange(2, 1)];
        [data getBytes:&h2 range:NSMakeRange(3, 1)];
        short h = h1 + (h2 << 8);
        return CGSizeMake(w, h);
    }
    return CGSizeZero;
}

/**
 *  @author CC, 16-08-01
 *
 *  @brief 获取jpg图片的大小
 */
+ (CGSize)getJPGImageSizeWithRequest:(NSMutableURLRequest *)request
{
    [request setValue:@"bytes=0-209" forHTTPHeaderField:@"Range"];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];

    if ([data length] <= 0x58) {
        return CGSizeZero;
    }

    if ([data length] < 210) { // 肯定只有一个DQT字段
        short w1 = 0, w2 = 0;
        [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
        [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
        short w = (w1 << 8) + w2;
        short h1 = 0, h2 = 0;
        [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
        [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
        short h = (h1 << 8) + h2;
        return CGSizeMake(w, h);
    } else {
        short word = 0x0;
        [data getBytes:&word range:NSMakeRange(0x15, 0x1)];
        if (word == 0xdb) {
            [data getBytes:&word range:NSMakeRange(0x5a, 0x1)];
            if (word == 0xdb) { // 两个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0xa5, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0xa6, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0xa3, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0xa4, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            } else { // 一个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            }
        } else {
            return CGSizeZero;
        }
    }
}

#pragma mark - Bubble view

// 获取文本的实际大小
+ (CGFloat)neededWidthForText:(NSString *)text
{
    UIFont *systemFont = [[CCMessageBubbleView appearance] font];
    CGSize textSize = CGSizeMake(CGFLOAT_MAX, 20); // rough accessory size
    CGSize sizeWithFont = [text sizeWithFont:systemFont constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];

#if defined(__LP64__) && __LP64__
    return ceil(sizeWithFont.width);
#else
    return ceilf(sizeWithFont.width);
#endif
}

// 计算文本实际的大小
+ (CGSize)neededSizeForText:(NSString *)text
{
    // 实际处理文本的时候
    CGFloat dyWidth = [CCMessageBubbleView neededWidthForText:text];

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
        dyWidth += 10;

    CGSize textSize = [SETextView frameRectWithAttributtedString:[[CCMessageBubbleHelper sharedMessageBubbleHelper] bubbleAttributtedStringWithText:text]
                                                  constraintSize:CGSizeMake(kCCMaxWidth, MAXFLOAT)
                                                     lineSpacing:kCCTextLineSpacing
                                                            font:[[CCMessageBubbleView appearance] font]].size;
    return CGSizeMake((dyWidth > textSize.width ? textSize.width : dyWidth), textSize.height);
}

//计算图文最大的大小
+ (CGSize)neededSizeForTeletext:(id<CCMessageModel>)message
{
    NSString *text = [[message text] stringByReplacingOccurrencesOfString:message.teletextReplaceStr withString:@""];
    text = [text stringByReplacingOccurrencesOfString:message.teletextReplaceStr withString:OBJECT_REPLACEMENT_CHARACTER];
    CGSize size = [CCMessageBubbleView neededSizeForText:text];
    BOOL isWrap = NO;
    for (NSDictionary *d in message.teletextPath) {
        NSString *path = [d objectForKey:@"path"];

        UIImage *image = [UIImage imageWithContentsOfFile:path];
        if (image) {
            if (image.size.height > size.height)
                size = CGSizeMake(size.width, size.height + (image.size.height - size.height));

            size = CGSizeMake(image.size.width + size.width, size.height);
        } else if ([path rangeOfString:@"http://"].location != NSNotFound) { //网络加载图片时
            size = CGSizeMake(100 + size.width, 100 + size.height);
        }

        CGFloat w = size.width;
        if (w > kCCMaxWidth) { //超过显示最大宽度
            isWrap = YES;
            w = image.size.width;
            size.height += image.size.height;
        }

        size = CGSizeMake(w, size.height);
    }

    if (isWrap)
        size = CGSizeMake(kCCMaxWidth, size.height);

    size.height = [self displayTextViewWithHeight:message Size:size];

    return size;
}

+ (CGFloat)displayTextViewWithHeight:(id<CCMessageModel>)message
                                Size:(CGSize)size
{

    SETextView *displayTextView = [[SETextView alloc] initWithFrame:CGRectZero];
    displayTextView.textColor = [UIColor colorWithWhite:0.143 alpha:1.000];
    displayTextView.backgroundColor = [UIColor clearColor];
    displayTextView.selectable = NO;
    displayTextView.lineSpacing = kCCTextLineSpacing;
    displayTextView.font = [[CCMessageBubbleView appearance] font];
    displayTextView.showsEditingMenuAutomatically = NO;
    displayTextView.highlighted = NO;


    NSString *text = [[message text] stringByReplacingOccurrencesOfString:message.teletextReplaceStr withString:OBJECT_REPLACEMENT_CHARACTER];

    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:@"\uFFFC" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *resultArray = [re matchesInString:text options:0 range:NSMakeRange(0, text.length)];

    for (int i = 0; i < resultArray.count; i++) {

        NSTextCheckingResult *match = [resultArray objectAtIndex:i];

        NSString *path = @"";
        if (message.teletextPath.count && i < message.teletextPath.count)
            path = [[message.teletextPath objectAtIndex:i] objectForKey:@"path"];

        CGSize size = CGSizeMake(20, 20);
        UIImage *Images = [UIImage imageWithContentsOfFile:path];
        if (Images)
            size = CGSizeMake(Images.size.width < 100 ? Images.size.width : 100, Images.size.height < 100 ? Images.size.height : 100);
        else if ([path rangeOfString:@"http://"].location != NSNotFound) { //网络加载图片时
            size = CGSizeMake(100, 100);
        }

        CCMessagePhotoImageView *messagePhotoImageView = [[CCMessagePhotoImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        messagePhotoImageView.imageFilePath = path;

        [displayTextView addObject:messagePhotoImageView size:size replaceRange:[match range]];
    }

    displayTextView.attributedText = [[CCMessageBubbleHelper sharedMessageBubbleHelper] bubbleAttributtedStringWithText:text];

    return [displayTextView sizeThatFits:size].height;
}

// 计算图片实际大小
+ (CGSize)neededSizeForPhoto:(UIImage *)photo
                    imageURL:(NSString *)url
{
    CGSize photoSize = CGSizeMake(150, 150);
    if (photo) {
        if (photo.size.width > photoSize.width && photo.size.height > photoSize.height) {
            CGRect frame = [CCTool neededSizeForPhoto:photo Size:photoSize];
            photoSize.width = frame.size.width > kCCMaxWidth ? kCCMaxWidth : frame.size.width;
            photoSize.height = frame.size.height;
            if (frame.size.width > kCCMaxWidth)
                photoSize.height = (kCCMaxWidth / frame.size.width) * frame.size.width;

            if (photoSize.height > kCCMaxHeight)
                photoSize.height = kCCMaxHeight;
        } else if (photo.size.width > kCCMaxWidth) {
            photoSize.width = kCCMaxWidth;
        } else {
            photoSize.width = photo.size.width < 30 ? 30 : photo.size.width;
            photoSize.height = photo.size.height < 30 ? 30 : photo.size.height;
        }
    } else {
        CGSize imageSize = [CCMessageBubbleView obtainImageSizeWithURL:url];
        if (imageSize.width != 0 || imageSize.height != 0) {
            photoSize.width = imageSize.width > kCCMaxWidth ? kCCMaxWidth : imageSize.width;
            photoSize.height = imageSize.height;
            if (imageSize.width > kCCMaxWidth)
                photoSize.height = (kCCMaxWidth / imageSize.width) * imageSize.width;

            if (photoSize.height > kCCMaxHeight)
                photoSize.height = kCCMaxHeight;
        }
    }

    return photoSize;
}

// 计算语音实际大小
+ (CGSize)neededSizeForVoicePath:(NSString *)voicePath voiceDuration:(NSString *)voiceDuration
{
    // 这里的100只是暂时固定，到时候会根据一个函数来计算
    float gapDuration = (!voiceDuration || voiceDuration.length == 0 ? -1 : [voiceDuration floatValue] - 1.0f);
    CGSize voiceSize = CGSizeMake(100 + (gapDuration > 0 ? (120.0 / (60 - 1) * gapDuration) : 0), 42);
    return voiceSize;
}

// 计算Emotion的高度
+ (CGSize)neededSizeForEmotion
{
    return CGSizeMake(100, 100);
}

// 算SmallEmotion的高度
+ (CGSize)neededSizeForSmallEmotion
{
    return CGSizeMake(30, 30);
}

// 计算LocalPostion的高度
+ (CGSize)neededSizeForLocalPostion
{
    return CGSizeMake(140, 140);
}

// 计算Cell需要实际Message内容的大小
+ (CGFloat)calculateCellHeightWithMessage:(id<CCMessageModel>)message
{
    CGSize size = [CCMessageBubbleView getBubbleFrameWithMessage:message];
    return size.height;
}

// 获取Cell需要的高度
+ (CGSize)getBubbleFrameWithMessage:(id<CCMessageModel>)message
{
    CGSize bubbleSize;
    switch (message.messageMediaType) {
        case CCBubbleMessageMediaTypeText: { //文本
            CGSize needTextSize = [CCMessageBubbleView neededSizeForText:message.text];
            bubbleSize = CGSizeMake(needTextSize.width + kCCLeftTextHorizontalBubblePadding + kCCRightTextHorizontalBubblePadding + kCCArrowMarginWidth, needTextSize.height + kCCHaveBubbleMargin * 2 + kCCTopAndBottomBubbleMargin * 2); //这里*4的原因是：气泡内部的文本也做了margin，而且margin的大小和气泡的margin一样大小，所以需要加上*2的间隙大小
            break;
        }
        case CCBubbleMessageMediaTypeTeletext: { //图文
            CGSize needTextSize = [CCMessageBubbleView neededSizeForTeletext:message];

            bubbleSize = CGSizeMake(needTextSize.width + kCCLeftTextHorizontalBubblePadding + kCCRightTextHorizontalBubblePadding + kCCArrowMarginWidth, needTextSize.height + kCCHaveBubbleMargin * 2 + kCCTopAndBottomBubbleMargin * 2);
            break;
        }
        case CCBubbleMessageMediaTypeVoice: {
            // 这里的宽度是不定的，高度是固定的，根据需要根据语音长短来定制啦
            CGSize needVoiceSize = [CCMessageBubbleView neededSizeForVoicePath:message.voicePath voiceDuration:message.voiceDuration];
            bubbleSize = CGSizeMake(needVoiceSize.width, needVoiceSize.height + kCCHaveBubbleVoiceMargin * 2);
            break;
        }
        case CCBubbleMessageMediaTypeEmotion: {
            // 是否固定大小呢？
            CGSize emotionSize = [CCMessageBubbleView neededSizeForEmotion];
            bubbleSize = CGSizeMake(emotionSize.width, emotionSize.height + kCCHaveBubbleMargin * 2);
            break;
        }
        case CCBubbleMessageMediaTypeSmallEmotion: {
            CGSize smallEmotionSize = [CCMessageBubbleView neededSizeForSmallEmotion];
            bubbleSize = CGSizeMake(smallEmotionSize.width + kCCLeftTextHorizontalBubblePadding + kCCRightTextHorizontalBubblePadding + kCCArrowMarginWidth, smallEmotionSize.height + kCCHaveBubbleMargin * 2 + kCCTopAndBottomBubbleMargin * 2);
            break;
        }
        case CCBubbleMessageMediaTypeVideo: {
            CGSize needVideoConverPhotoSize = [CCMessageBubbleView neededSizeForPhoto:message.videoConverPhoto imageURL:nil];
            bubbleSize = CGSizeMake(needVideoConverPhotoSize.width, needVideoConverPhotoSize.height + kCCNoneBubblePhotoMargin * 2);
            break;
        }
        case CCBubbleMessageMediaTypePhoto: {
            CGSize needPhotoSize = [CCMessageBubbleView neededSizeForPhoto:message.photo imageURL:message.originPhotoUrl];
            bubbleSize = CGSizeMake(needPhotoSize.width, needPhotoSize.height + kCCHaveBubblePhotoMargin * 2);
            break;
        }
        case CCBubbleMessageMediaTypeLocalPosition: {
            // 固定大小，必须的
            CGSize localPostionSize = [CCMessageBubbleView neededSizeForLocalPostion];
            bubbleSize = CGSizeMake(localPostionSize.width, localPostionSize.height + kCCHaveBubblePhotoMargin * 2);
            break;
        }
        default:
            break;
    }
    return bubbleSize;
}

#pragma mark - UIAppearance Getters

- (UIFont *)font
{
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
- (CGRect)bubbleFrame
{
    // 1.先得到MessageBubbleView的实际大小
    CGSize bubbleSize = [CCMessageBubbleView getBubbleFrameWithMessage:self.message];

    // 2.计算起泡的大小和位置
    CGFloat paddingX = 0.0f;
    if (self.message.bubbleMessageType == CCBubbleMessageTypeSending) {
        paddingX = CGRectGetWidth(self.bounds) - bubbleSize.width;
    }

    CCBubbleMessageMediaType currentMessageMediaType = self.message.messageMediaType;

    // 最终减去上下边距的像素就可以得到气泡的位置以及大小
    CGFloat marginY = 0.0;
    CGFloat topSumForBottom = 0.0;
    switch (currentMessageMediaType) {
        case CCBubbleMessageMediaTypeVoice:
            marginY = kCCHaveBubbleVoiceMargin;
            topSumForBottom = kCCHaveBubbleVoiceMargin * 2;
            break;
        case CCBubbleMessageMediaTypePhoto:
        case CCBubbleMessageMediaTypeLocalPosition:
            marginY = kCCHaveBubblePhotoMargin;
            topSumForBottom = kCCHaveBubblePhotoMargin * 2;
            break;
        default:
            // 文本、视频、表情
            marginY = kCCHaveBubbleMargin;
            topSumForBottom = kCCHaveBubbleMargin * 2;
            break;
    }

    return CGRectMake(paddingX,
                      marginY,
                      bubbleSize.width,
                      bubbleSize.height - topSumForBottom);
}

#pragma mark - Configure Methods

- (void)configureCellWithMessage:(id<CCMessageModel>)message
{
    _message = message;

    [self configureBubbleImageView:message];

    [self configureMessageDisplayMediaWithMessage:message];
}

- (void)configureBubbleImageView:(id<CCMessageModel>)message
{
    CCBubbleMessageMediaType currentType = message.messageMediaType;

    _voiceDurationLabel.hidden = YES;
    _voiceUnreadDotImageView.hidden = YES;

    [_sendNotSuccessfulButton setImage:@""];
    _sendNotSuccessfulButton.hidden = YES;
    _indicatorView.hidden = YES;
    [_indicatorView stopAnimating];
    if (message.bubbleMessageType == CCBubbleMessageTypeSending) {

        CCMessageSendType sendStatusType = message.messageSendState;
        switch (sendStatusType) {
            case CCMessageSendTypeFailure:
                [_sendNotSuccessfulButton setImage:@"caveat"];
                _sendNotSuccessfulButton.hidden = NO;
                _indicatorView.hidden = YES;
                [_indicatorView stopAnimating];

                break;
            case CCMessageSendTypeRunIng:
                _sendNotSuccessfulButton.hidden = YES;
                _indicatorView.hidden = NO;
                [_indicatorView startAnimating];
                break;
            case CCMessageSendTypeSuccessful:
                _sendNotSuccessfulButton.hidden = YES;
                _indicatorView.hidden = YES;
                [_indicatorView stopAnimating];
                break;
            default:
                break;
        }
    }


    switch (currentType) {
        case CCBubbleMessageMediaTypeVoice: {
            _voiceDurationLabel.hidden = NO;
            _voiceUnreadDotImageView.hidden = message.isRead;
        }
        case CCBubbleMessageMediaTypeText:
        case CCBubbleMessageMediaTypeEmotion:
        case CCBubbleMessageMediaTypeSmallEmotion:
        case CCBubbleMessageMediaTypeTeletext: {
            _bubbleImageView.image = [CCMessageBubbleFactory bubbleImageViewForType:message.bubbleMessageType
                                                                              style:CCBubbleImageViewStyleWeChat
                                                                          meidaType:message.messageMediaType];
            // 只要是文本、语音、第三方表情，背景的气泡都不能隐藏
            _bubbleImageView.hidden = NO;

            // 只要是文本、语音、第三方表情，都需要把显示尖嘴图片的控件隐藏了
            _bubblePhotoImageView.hidden = YES;


            if (currentType == CCBubbleMessageMediaTypeText || currentType == CCBubbleMessageMediaTypeTeletext) {
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
                } else if (currentType == CCBubbleMessageMediaTypeSmallEmotion) { //小表情
                    _animationVoiceImageView.hidden = YES;
                    _emotionImageView.hidden = NO;
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

- (void)configureMessageDisplayMediaWithMessage:(id<CCMessageModel>)message
{
    _displayTextView.textColor = [UIColor colorWithWhite:0.143 alpha:1.000];
    if (self.message.bubbleMessageType == CCBubbleMessageTypeSending)
        _displayTextView.textColor = [UIColor whiteColor];

    switch (message.messageMediaType) {
        case CCBubbleMessageMediaTypeText:
            [_displayTextView clearAttachments];
            _displayTextView.attributedText = [[CCMessageBubbleHelper sharedMessageBubbleHelper] bubbleAttributtedStringWithText:[message text]];
            break;
        case CCBubbleMessageMediaTypeTeletext: {
            [_displayTextView clearAttachments];
            NSString *text = [[message text] stringByReplacingOccurrencesOfString:message.teletextReplaceStr withString:OBJECT_REPLACEMENT_CHARACTER];

            NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:@"\uFFFC" options:NSRegularExpressionCaseInsensitive error:nil];
            NSArray *resultArray = [re matchesInString:text options:0 range:NSMakeRange(0, text.length)];

            for (int i = 0; i < resultArray.count; i++) {

                NSTextCheckingResult *match = [resultArray objectAtIndex:i];

                NSString *path = @"";
                if (message.teletextPath.count && i < message.teletextPath.count)
                    path = [[message.teletextPath objectAtIndex:i] objectForKey:@"path"];

                CGSize size = CGSizeMake(20, 20);
                UIImage *Images = [UIImage imageWithContentsOfFile:path];
                if (Images)
                    size = CGSizeMake(Images.size.width < 100 ? Images.size.width : 100, Images.size.height < 100 ? Images.size.height : 100);
                else if ([path rangeOfString:@"http://"].location != NSNotFound) { //网络加载图片时
                    size = CGSizeMake(100, 100);
                }

                CCMessagePhotoImageView *messagePhotoImageView = [[CCMessagePhotoImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
                messagePhotoImageView.imageFilePath = path;

                [_displayTextView addObject:messagePhotoImageView size:size replaceRange:[match range]];
            }

            _displayTextView.attributedText = [[CCMessageBubbleHelper sharedMessageBubbleHelper] bubbleAttributtedStringWithText:text];

            break;
        }
        case CCBubbleMessageMediaTypePhoto:
            [_bubblePhotoImageView configureMessagePhoto:message.photo
                                            thumbnailUrl:message.thumbnailUrl
                                          originPhotoUrl:message.originPhotoUrl
                                     onBubbleMessageType:self.message.bubbleMessageType];
            break;
        case CCBubbleMessageMediaTypeVideo:
            [_bubblePhotoImageView configureMessagePhoto:message.videoConverPhoto
                                            thumbnailUrl:message.thumbnailUrl
                                          originPhotoUrl:message.originPhotoUrl
                                     onBubbleMessageType:self.message.bubbleMessageType];
            break;
        case CCBubbleMessageMediaTypeVoice:
            break;
        case CCBubbleMessageMediaTypeEmotion:
        case CCBubbleMessageMediaTypeSmallEmotion:
            // 直接设置GIF
            if (message.emotionPath) {
                NSData *animatedData = [NSData dataWithContentsOfFile:message.emotionPath];
                if (animatedData) {
                    CCAnimatedImage *animatedImage = [[CCAnimatedImage alloc] initWithAnimatedGIFData:animatedData];
                    _emotionImageView.animatedImage = animatedImage;
                } else {
                    [_emotionImageView sd_setImageWithURLStr:message.emotionUrl];
                }
            } else {
                [_emotionImageView sd_setImageWithURLStr:message.emotionUrl];
            }
            break;
        case CCBubbleMessageMediaTypeLocalPosition:
            [_bubblePhotoImageView configureMessagePhoto:message.localPositionPhoto
                                            thumbnailUrl:nil
                                          originPhotoUrl:nil
                                     onBubbleMessageType:self.message.bubbleMessageType];

            _geolocationsLabel.text = message.geolocations;
            break;
        default:
            break;
    }

    [self setNeedsLayout];
}

- (void)configureVoiceDurationLabelFrameWithBubbleFrame:(CGRect)bubbleFrame
{
    CGRect voiceFrame = _voiceDurationLabel.frame;
    voiceFrame.origin.x = (self.message.bubbleMessageType == CCBubbleMessageTypeSending ? bubbleFrame.origin.x - CGRectGetWidth(voiceFrame) - 5 : bubbleFrame.origin.x + bubbleFrame.size.width + 5);
    _voiceDurationLabel.frame = voiceFrame;
    _voiceDurationLabel.textAlignment = (self.message.bubbleMessageType == CCBubbleMessageTypeSending ? NSTextAlignmentRight : NSTextAlignmentLeft);
}

- (void)configureVoiceUnreadDotImageViewFrameWithBubbleFrame:(CGRect)bubbleFrame
{
    CGRect voiceUnreadDotFrame = _voiceUnreadDotImageView.frame;
    voiceUnreadDotFrame.origin.x = (self.message.bubbleMessageType == CCBubbleMessageTypeSending ? bubbleFrame.origin.x - CGRectGetWidth(voiceUnreadDotFrame) + 5 : bubbleFrame.origin.x + bubbleFrame.size.width + 5);
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
- (void)configureSendNotSuccessfulButtonFrameWithBubbleFrame:(CGRect)bubbleFrame
{
    CGRect sendNotSuccessfulButtonFrame = _sendNotSuccessfulButton.frame;
    sendNotSuccessfulButtonFrame.origin.x = (self.message.bubbleMessageType == CCBubbleMessageTypeSending ? bubbleFrame.origin.x - (CGRectGetWidth(sendNotSuccessfulButtonFrame) + 5) : bubbleFrame.origin.x + bubbleFrame.size.width + 5);
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
- (void)configureIndicatorViewFrameWithBubbleFrame:(CGRect)bubbleFrame
{
    CGRect indicatorViewFrame = _indicatorView.frame;
    indicatorViewFrame.origin.x = (self.message.bubbleMessageType == CCBubbleMessageTypeSending ? bubbleFrame.origin.x - (CGRectGetWidth(indicatorViewFrame) + 5) : bubbleFrame.origin.x + bubbleFrame.size.width + 5);
    indicatorViewFrame.origin.y = CGRectGetMidY(bubbleFrame) - kCCSendNotSuccessfulSize / 2.0;
    _indicatorView.frame = indicatorViewFrame;
}

#pragma mark - Life cycle

- (instancetype)initWithFrame:(CGRect)frame
                      message:(id<CCMessageModel>)message
{
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
            UILabel *voiceDurationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 50, 30)];
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
            UIImageView *voiceUnreadDotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 12, kCCUnReadDotSize, kCCUnReadDotSize)];
            voiceUnreadDotImageView.backgroundColor = [UIColor redColor];
            cc_View_Radius(voiceUnreadDotImageView, kCCUnReadDotSize / 2);
            voiceUnreadDotImageView.hidden = YES;
            [self addSubview:voiceUnreadDotImageView];
            _voiceUnreadDotImageView = voiceUnreadDotImageView;
        }

        // 7. 初始化消息未发送成功时显示重新发送按钮
        if (!_sendNotSuccessfulButton) {
            UIButton *sendNotSuccessfulButton = [UIButton buttonWithBackgroundImage:@""];
            sendNotSuccessfulButton.frame = CGRectMake(0, 0, kCCSendNotSuccessfulSize, kCCSendNotSuccessfulSize);
            sendNotSuccessfulButton.hidden = YES;
            [sendNotSuccessfulButton addTarget:self action:@selector(sendNotSuccessful:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:sendNotSuccessfulButton];
            _sendNotSuccessfulButton = sendNotSuccessfulButton;
        }

        // 8. 初始化发送消息加载中
        if (!_indicatorView) {
            UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            indicatorView.frame = CGRectMake(0, 0, kCCSendNotSuccessfulSize, kCCSendNotSuccessfulSize);
            indicatorView.hidden = YES;
            [indicatorView stopAnimating];
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

- (void)dealloc
{
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

- (void)layoutSubviews
{
    [super layoutSubviews];

    CCBubbleMessageMediaType currentType = self.message.messageMediaType;
    CGRect bubbleFrame = [self bubbleFrame];

    [self configureIndicatorViewFrameWithBubbleFrame:bubbleFrame];
    [self configureSendNotSuccessfulButtonFrameWithBubbleFrame:bubbleFrame];

    switch (currentType) {
        case CCBubbleMessageMediaTypeText:
        case CCBubbleMessageMediaTypeVoice:
        case CCBubbleMessageMediaTypeEmotion:
        case CCBubbleMessageMediaTypeSmallEmotion:
        case CCBubbleMessageMediaTypeTeletext: {
            // 获取实际气泡的大小
            CGRect bubbleFrame = [self bubbleFrame];
            self.bubbleImageView.frame = bubbleFrame;

            if (currentType == CCBubbleMessageMediaTypeVoice) {
                // 配置语音播放的位置
                CGRect animationVoiceImageViewFrame = self.animationVoiceImageView.frame;
                CGFloat voiceImagePaddingX = CGRectGetMaxX(bubbleFrame) - kCCVoiceMargin - CGRectGetWidth(animationVoiceImageViewFrame);
                if (self.message.bubbleMessageType == CCBubbleMessageTypeReceiving) {
                    voiceImagePaddingX = CGRectGetMinX(bubbleFrame) + kCCVoiceMargin;
                }
                animationVoiceImageViewFrame.origin = CGPointMake(voiceImagePaddingX, CGRectGetMidY(bubbleFrame) - CGRectGetHeight(animationVoiceImageViewFrame) / 2.0); // 垂直居中
                self.animationVoiceImageView.frame = animationVoiceImageViewFrame;

                [self configureVoiceDurationLabelFrameWithBubbleFrame:bubbleFrame];
                [self configureVoiceUnreadDotImageViewFrameWithBubbleFrame:bubbleFrame];
            } else if (currentType == CCBubbleMessageMediaTypeEmotion) {
                CGRect emotionImageViewFrame = bubbleFrame;
                emotionImageViewFrame.size = [CCMessageBubbleView neededSizeForEmotion];
                self.emotionImageView.frame = emotionImageViewFrame;
            } else {
                //小表情与文字消息时设置气泡框

                CGFloat textX = -kCCArrowMarginWidth;
                if (self.message.bubbleMessageType == CCBubbleMessageTypeReceiving)
                    textX = kCCArrowMarginWidth;

                CGRect viewFrame = CGRectZero;
                viewFrame.size.width = CGRectGetWidth(bubbleFrame) - kCCLeftTextHorizontalBubblePadding - kCCRightTextHorizontalBubblePadding - kCCArrowMarginWidth;
                viewFrame.size.height = CGRectGetHeight(bubbleFrame) - kCCHaveBubbleMargin * 3;

                if (currentType == CCBubbleMessageMediaTypeText || currentType == CCBubbleMessageMediaTypeTeletext) {
                    self.displayTextView.frame = viewFrame;
                    self.displayTextView.center = CGPointMake(self.bubbleImageView.center.x + textX, self.bubbleImageView.center.y);
                }

                if (currentType == CCBubbleMessageMediaTypeSmallEmotion) {
                    self.emotionImageView.frame = viewFrame;
                    self.emotionImageView.center = CGPointMake(self.bubbleImageView.center.x + textX, self.bubbleImageView.center.y);
                }
            }

            break;
        }
        case CCBubbleMessageMediaTypePhoto:
        case CCBubbleMessageMediaTypeVideo:
        case CCBubbleMessageMediaTypeLocalPosition: {
            CGSize needPhotoSize = [CCMessageBubbleView neededSizeForPhoto:self.message.photo imageURL:self.message.originPhotoUrl];
            CGFloat paddingX = 0.0f;
            if (self.message.bubbleMessageType == CCBubbleMessageTypeSending) {
                paddingX = CGRectGetWidth(self.bounds) - needPhotoSize.width;
            }

            CGFloat marginY = kCCNoneBubblePhotoMargin;
            if (currentType == CCBubbleMessageMediaTypePhoto || currentType == CCBubbleMessageMediaTypeLocalPosition) {
                marginY = kCCHaveBubblePhotoMargin;
            }

            CGRect photoImageViewFrame = CGRectMake(paddingX, marginY, needPhotoSize.width, needPhotoSize.height);

            self.bubblePhotoImageView.frame = photoImageViewFrame;
            self.bubbleImageView.frame = photoImageViewFrame;


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
