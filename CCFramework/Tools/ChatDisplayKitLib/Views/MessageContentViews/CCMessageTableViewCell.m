//
//  CCMessageTableViewCell.m
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


#import "CCMessageTableViewCell.h"
#import "CCLanguage.h"
#import "NSDate+Additions.h"
#import "CCConfigurationHelper.h"
#import "CCMessageAvatarFactory.h"
//#import "UIView+Method.h"
#import "UIView+Frame.h"
#import "CCMessage.h"
#import "UIButton+Additions.h"
#import "UIButton+WebCache.h"
#import "MLLinkLabel.h"

static const CGFloat kCCLabelPadding = 10.0f;
static const CGFloat kCCTimeStampLabelHeight = 20.0f;

static const CGFloat kCCAvatarPaddingX = 10.0;
static const CGFloat kCCAvatarPaddingY = 8;

static const CGFloat kCCUserNameLabelHeight = 20;

@interface CCMessageTableViewCell () <CCMessageBubbleViewDelegate>

@property(nonatomic, weak, readwrite) CCMessageBubbleView *messageBubbleView;

@property(nonatomic, strong, readwrite) UILabel *userNameLabel;
@property(nonatomic, strong, readwrite) UILabel *userLabel;

@property(nonatomic, weak, readwrite) UIButton *avatarButton;

@property(nonatomic, weak, readwrite) CCBadgeView *timestampLabel;

@property(nonatomic, weak, readwrite) MLLinkLabel *noticeLabel;

@property(nonatomic, weak) UITableView *containingTableView;

/**
 *  @author CC, 2015-11-16
 *
 *  @brief  编辑选择
 */
@property(nonatomic, weak, readonly) UIImageView *selectedIndicator;

/**
 *  是否显示时间轴Label
 */
@property(nonatomic, assign) BOOL displayTimestamp;

/**
 *  1、是否显示Time Line的label
 *
 *  @param message 需要配置的目标消息Model
 */
- (void)configureTimestamp:(BOOL)displayTimestamp
                 atMessage:(id<CCMessageModel>)message;

/**
 *  2、配置头像
 *
 *  @param message 需要配置的目标消息Model
 */
- (void)configAvatarWithMessage:(id<CCMessageModel>)message;

/**
 *  3、配置需要显示什么消息内容，比如语音、文字、视频、图片
 *
 *  @param message 需要配置的目标消息Model
 */
- (void)configureMessageBubbleViewWithMessage:(id<CCMessageModel>)message;

/**
 *  头像按钮，点击事件
 *
 *  @param sender 头像按钮对象
 */
- (void)avatarButtonClicked:(UIButton *)sender;

/**
 *  统一一个方法隐藏MenuController，多处需要调用
 */
- (void)setupNormalMenuController;

/**
 *  点击Cell的手势处理方法，用于隐藏MenuController的
 *
 *  @param tapGestureRecognizer 点击手势对象
 */
- (void)tapGestureRecognizerHandle:(UITapGestureRecognizer *)tapGestureRecognizer;

/**
 *  长按Cell的手势处理方法，用于显示MenuController的
 *
 *  @param longPressGestureRecognizer 长按手势对象
 */
- (void)longPressGestureRecognizerHandle:(UILongPressGestureRecognizer *)longPressGestureRecognizer;

/**
 *  单击手势处理方法，用于点击多媒体消息触发方法，比如点击语音需要播放的回调、点击图片需要查看大图的回调
 *
 *  @param tapGestureRecognizer 点击手势对象
 */
- (void)sigleTapGestureRecognizerHandle:(UITapGestureRecognizer *)tapGestureRecognizer;

/**
 *  双击手势处理方法，用于双击文本消息，进行放大文本的回调
 *
 *  @param tapGestureRecognizer 双击手势对象
 */
- (void)doubleTapGestureRecognizerHandle:(UITapGestureRecognizer *)tapGestureRecognizer;

@end

@implementation CCMessageTableViewCell

- (void)avatarButtonClicked:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(didSelectedAvatarOnMessage:atIndexPath:)]) {
        [self.delegate didSelectedAvatarOnMessage:self.messageBubbleView.message
                                      atIndexPath:self.indexPath];
    }
}

#pragma mark - Copying Method

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    return [super becomeFirstResponder];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(copyed:) || action == @selector(transpond:) || action == @selector(favorites:) || action == @selector(withdraw:) || action == @selector(deletes:) || action == @selector(more:)) || action == @selector(memo:);
}

#pragma mark - Menu Actions

- (void)memo:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didSelectedMemo:atIndexPath:)]) {
        [self.delegate didSelectedMemo:self.messageBubbleView.message
                           atIndexPath:self.indexPath];
    }
}

/**
 *  @author CC, 2015-11-16
 *
 *  @brief  拷贝文案
 */
- (void)copyed:(id)sender
{
    [[UIPasteboard generalPasteboard] setString:self.messageBubbleView.displayTextView.text];
    [self resignFirstResponder];
}

/**
 *  @author CC, 2015-11-16
 *
 *  @brief  转发
 */
- (void)transpond:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didSelectedMenuTranspond:atIndexPath:)]) {
        CCMessage *message = (CCMessage *)self.messageBubbleView.message;
        if (message.messageMediaType == CCBubbleMessageMediaTypePhoto)
            message.photo = self.messageBubbleView.bubblePhotoImageView.image;
        
        [self.delegate didSelectedMenuTranspond:message
                                    atIndexPath:self.indexPath];
    }
}

/**
 *  @author CC, 2015-11-16
 *
 *  @brief  收藏
 */
- (void)favorites:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didSelectedMenuFavorites:atIndexPath:)])
        [self.delegate didSelectedMenuFavorites:self.messageBubbleView.message
                                    atIndexPath:self.indexPath];
}

/**
 *  @author CC, 2015-11-16
 *
 *  @brief  撤回
 */
- (void)withdraw:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didSelectedMenuWithdraw:atIndexPath:)])
        [self.delegate didSelectedMenuWithdraw:self.messageBubbleView.message
                                   atIndexPath:self.indexPath];
}

/**
 *  @author CC, 2015-11-16
 *
 *  @brief  删除
 */
- (void)deletes:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didSelectedMenuDeletes:atIndexPath:)])
        [self.delegate didSelectedMenuDeletes:self.messageBubbleView.message
                                  atIndexPath:self.indexPath];
}

/**
 *  @author CC, 2015-11-16
 *
 *  @brief  更多
 */
- (void)more:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didSelectedMenuMore:atIndexPath:)])
        [self.delegate didSelectedMenuMore:self.messageBubbleView.message
                               atIndexPath:self.indexPath];
}

#pragma mark - Setters

- (void)configureCellWithMessage:(id<CCMessageModel>)message
               displaysTimestamp:(BOOL)displayTimestamp
{
    // 1、是否显示Time Line的label
    [self configureTimestamp:displayTimestamp atMessage:message];
    
    // 2、配置头像
    [self configAvatarWithMessage:message];
    
    // 3、配置用户名
    [self configUserNameWithMessage:message];
    [self configUserLabelWithMessage:message];
    
    // 4、配置通知消息
    [self configureNoticeWihtMessage:message];
    
    // 5、配置需要显示什么消息内容，比如语音、文字、视频、图片
    [self configureMessageBubbleViewWithMessage:message];
}

- (void)configureTimestamp:(BOOL)displayTimestamp
                 atMessage:(id<CCMessageModel>)message
{
    self.displayTimestamp = displayTimestamp;
    self.timestampLabel.hidden = !self.displayTimestamp;
    if (displayTimestamp) {
        self.timestampLabel.text = [message.timestamp convertingDataFormat];
    }
}

- (void)configAvatarWithMessage:(id<CCMessageModel>)message
{
    UIImage *avatarPhoto = message.avatar;
    NSString *avatarURL = message.avatarUrl;
    
    if (avatarPhoto) {
        [self configAvatarWithPhoto:avatarPhoto];
        //        if (avatarURL) {
        //            [self configAvatarWithPhotoURLString:avatarURL];
        //        }
    } else if (avatarURL) {
        [self configAvatarWithPhotoURLString:avatarURL];
    } else {
        UIImage *avatarPhoto = [CCMessageAvatarFactory avatarImageNamed:[UIImage imageNamed:@"avator"]
                                                      messageAvatarType:CCMessageAvatarTypeSquare];
        [self configAvatarWithPhoto:avatarPhoto];
    }
    
    self.avatarButton.carryObjects = message;
}

- (void)configAvatarWithPhoto:(UIImage *)photo
{
    [self.avatarButton setImage:photo forState:UIControlStateNormal];
}

- (void)configAvatarWithPhotoURLString:(NSString *)photoURLString
{
    [self.avatarButton sd_setImageWithURL:[NSURL URLWithString:photoURLString]
                                 forState:UIControlStateNormal
                         placeholderImage:[UIImage imageNamed:@"avator"]];
}

- (void)configUserNameWithMessage:(id<CCMessageModel>)message
{
    self.userNameLabel.text = [message sender];
    if ([message senderAttribute]) {
        self.userNameLabel.attributedText = [message senderAttribute];
    }
}

- (void)configUserLabelWithMessage:(id<CCMessageModel>)message
{
    self.userLabel.backgroundColor = message.userLabelColor;
    self.userLabel.text = message.userLabel;
}

- (void)configureNoticeWihtMessage:(id<CCMessageModel>)message
{
    if ([message noticeAttContent]) {
        NSMutableAttributedString *noticeAtt = [[NSMutableAttributedString alloc] initWithAttributedString:[message noticeAttContent]];
        [noticeAtt addAttribute:NSFontAttributeName value:self.noticeLabel.font range:NSMakeRange(0, noticeAtt.length)];
        [noticeAtt enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, noticeAtt.length) options:0 usingBlock:^(id _Nullable value, NSRange range, BOOL *_Nonnull stop) {
            if (value) {
                NSTextAttachment *att = value;
                CGRect bounds = att.bounds;
                bounds.origin.y = -3;
                bounds.size = att.image.size;
                att.bounds = bounds;
            }
        }];
        self.noticeLabel.attributedText = noticeAtt;
        //        [self.noticeLabel setAttributedTitle:noticeAtt forState:UIControlStateNormal];
    } else {
        self.noticeLabel.text = [NSString stringWithFormat:@" %@ ", [message noticeContent]];
        //        [self.noticeLabel setTitle:[NSString stringWithFormat:@" %@ ", [message noticeContent]] forState:UIControlStateNormal];
    }
}

- (void)configureMessageBubbleViewWithMessage:(id<CCMessageModel>)message
{
    CCBubbleMessageMediaType currentMediaType = message.messageMediaType;
    for (UIGestureRecognizer *gesTureRecognizer in self.messageBubbleView.bubbleImageView.gestureRecognizers) {
        [self.messageBubbleView.bubbleImageView removeGestureRecognizer:gesTureRecognizer];
    }
    for (UIGestureRecognizer *gesTureRecognizer in self.messageBubbleView.bubblePhotoImageView.gestureRecognizers) {
        [self.messageBubbleView.bubblePhotoImageView removeGestureRecognizer:gesTureRecognizer];
    }
    switch (currentMediaType) {
        case CCBubbleMessageMediaTypePhoto:
        case CCBubbleMessageMediaTypeVideo:
        case CCBubbleMessageMediaTypeLocalPosition: {
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sigleTapGestureRecognizerHandle:)];
            [self.messageBubbleView.bubblePhotoImageView addGestureRecognizer:tapGestureRecognizer];
            break;
        }
        case CCBubbleMessageMediaTypeTeletext: {
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sigleTapGestureRecognizerHandle:)];
            [self.messageBubbleView.bubbleImageView addGestureRecognizer:tapGestureRecognizer];
            break;
        }
        case CCBubbleMessageMediaTypeFile: {
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sigleTapGestureRecognizerHandle:)];
            [self.messageBubbleView.fileView addGestureRecognizer:tapGestureRecognizer];
            break;
        }
        case CCBubbleMessageMediaTypeRedPackage: {
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sigleTapGestureRecognizerHandle:)];
            [self.messageBubbleView.redPackageView addGestureRecognizer:tapGestureRecognizer];
            break;
        }
        case CCBubbleMessageMediaTypeText:
        case CCBubbleMessageMediaTypeVoice: {
            self.messageBubbleView.voiceDurationLabel.text = [NSString stringWithFormat:@"%@\'\'", message.voiceDuration];
        }
        case CCBubbleMessageMediaTypeEmotion: {
            UITapGestureRecognizer *tapGestureRecognizer;
            if (currentMediaType == CCBubbleMessageMediaTypeText) {
                tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureRecognizerHandle:)];
            } else {
                tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sigleTapGestureRecognizerHandle:)];
            }
            tapGestureRecognizer.numberOfTapsRequired = (currentMediaType == CCBubbleMessageMediaTypeText ? 2 : 1);
            [self.messageBubbleView.bubbleImageView addGestureRecognizer:tapGestureRecognizer];
            break;
        }
        case CCBubbleMessageMediaTypeGIF: {
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sigleTapGestureRecognizerHandle:)];
            [self.messageBubbleView.emotionImageView addGestureRecognizer:tapGestureRecognizer];
            break;
        }
        default:
            break;
    }
    
    [self.messageBubbleView configureCellWithMessage:message];
}

#pragma mark - Gestures

- (void)onClickOutsideLink:(UITapGestureRecognizer *)tapGestureRecognizer
{
    MLLinkLabel *lable = (MLLinkLabel *)tapGestureRecognizer.view;
    
    MLLink *link = [lable linkAtPoint:[tapGestureRecognizer locationInView:lable]];
    if (link) {
        if ([self.delegate respondsToSelector:@selector(didNoticeClick:)])
            [self.delegate didNoticeClick:link.linkValue];
    }
}

- (void)setupNormalMenuController
{
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if (menu.isMenuVisible) {
        [menu setMenuVisible:NO animated:YES];
    }
}

- (void)tapGestureRecognizerHandle:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self updateMenuControllerVisiable];
    
    if (self.isSelected)
        [self deselectCell];
    else if (self.shouldHighlight) // UITableView refuses selection if highlight is also refused.
        [self selectCell];
}

- (void)updateMenuControllerVisiable
{
    [self setupNormalMenuController];
}

- (void)longPressGestureRecognizerHandle:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    if (longPressGestureRecognizer.state != UIGestureRecognizerStateBegan ||
        ![self becomeFirstResponder] ||
        ((UITableView *)self.superview.superview).isEditing ||
        self.messageBubbleView.message.messageMediaType == CCBubbleMessageMediaTypeNotice)
        return;
    
    if ([self.delegate respondsToSelector:@selector(didSelectedPress:)])
        [self.delegate didSelectedPress:YES];
    
    NSArray *popMenuAry = @[ CCLocalization(@"复制"),
                             CCLocalization(@"转发"),
                             CCLocalization(@"备忘录"),
                             //CCLocalization(@"撤回"),
                             CCLocalization(@"删除"),
                             CCLocalization(@"更多") ];
    if ([self.messageBubbleView.message messageMediaType] == CCBubbleMessageMediaTypeVoice) {
        popMenuAry = @[ CCLocalization(@"备忘录"),
                        CCLocalization(@"复制"),
                        CCLocalization(@"删除"),
                        CCLocalization(@"更多") ];
    } else if ([self.messageBubbleView.message messageMediaType] == CCBubbleMessageMediaTypeFile) {
        popMenuAry = @[ CCLocalization(@"备忘录"),
                        CCLocalization(@"删除"),
                        CCLocalization(@"更多") ];
    }
    
    NSMutableArray *menuItems = [[NSMutableArray alloc] init];
    
    for (NSString *title in popMenuAry) {
        SEL action = nil;
        if ([title isEqualToString:@"复制"]) {
            if ([self.messageBubbleView.message messageMediaType] == CCBubbleMessageMediaTypeText)
                action = @selector(copyed:);
        } else if ([title isEqualToString:@"转发"]) {
            action = @selector(transpond:);
        } else if ([title isEqualToString:@"收藏"]) {
            action = @selector(favorites:);
        } else if ([title isEqualToString:@"撤回"]) {
            action = @selector(withdraw:);
        } else if ([title isEqualToString:@"删除"]) {
            action = @selector(deletes:);
        } else if ([title isEqualToString:@"更多"]) {
            action = @selector(more:);
        } else if ([title isEqualToString:@"备忘录"]) {
            action = @selector(memo:);
        }
        
        if (action) {
            UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:title action:action];
            if (item) {
                [menuItems addObject:item];
            }
        }
    }
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:menuItems];
    
    CGRect targetRect = [self convertRect:[self.messageBubbleView bubbleFrame]
                                 fromView:self.messageBubbleView];
    
    [menu setTargetRect:CGRectInset(targetRect, 0.0f, 4.0f) inView:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMenuWillShowNotification:)
                                                 name:UIMenuControllerWillShowMenuNotification
                                               object:nil];
    [menu setMenuVisible:YES animated:YES];
}

- (void)sigleTapGestureRecognizerHandle:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self setupNormalMenuController];
        if ([self.delegate respondsToSelector:@selector(multiMediaMessageDidSelectedOnMessage:atIndexPath:onMessageTableViewCell:)]) {
            [self.delegate multiMediaMessageDidSelectedOnMessage:self.messageBubbleView.message
                                                     atIndexPath:self.indexPath
                                          onMessageTableViewCell:self];
        }
    }
}

- (void)doubleTapGestureRecognizerHandle:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(didDoubleSelectedOnTextMessage:Message:atIndexPath:)]) {
            [self.delegate didDoubleSelectedOnTextMessage:self
                                                  Message:self.messageBubbleView.message
                                              atIndexPath:self.indexPath];
        }
    }
}

- (void)buttonlongPressGestureRecognizerHandle:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    if (longPressGestureRecognizer.state != UIGestureRecognizerStateBegan || ![self becomeFirstResponder] || ((UITableView *)self.superview.superview).isEditing)
        return;
    
    if ([self.delegate respondsToSelector:@selector(didPressAvatar:)]) {
        [self.delegate didPressAvatar:longPressGestureRecognizer.view.carryObjects];
    }
}

#pragma mark - Notifications

- (void)handleMenuWillHideNotification:(NSNotification *)notification
{
    if ([self.delegate respondsToSelector:@selector(didSelectedPress:)])
        [self.delegate didSelectedPress:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillHideMenuNotification
                                                  object:nil];
}

- (void)handleMenuWillShowNotification:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillShowMenuNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMenuWillHideNotification:)
                                                 name:UIMenuControllerWillHideMenuNotification
                                               object:nil];
}

#pragma mark - Getters

- (CCBubbleMessageType)bubbleMessageType
{
    return self.messageBubbleView.message.bubbleMessageType;
}

+ (CGFloat)calculateCellHeightWithMessage:(id<CCMessageModel>)message
                        displaysTimestamp:(BOOL)displayTimestamp
{
    // 第一，是否有时间戳的显示
    CGFloat timestampHeight = displayTimestamp ? (kCCTimeStampLabelHeight + kCCLabelPadding * 2) : 0;
    
    CGFloat height = timestampHeight;
    if ([message messageMediaType] == CCBubbleMessageMediaTypeNotice) {
        height += [self noticeMessageHeight:message].height + kCCLabelPadding * 2;
    } else {
        // 第二，是否又是名字显示
        CGFloat userNameHheight = message.shouldShowUserName ? (kCCTimeStampLabelHeight + 5) : 0;
        
        CGFloat userInfoNeedHeight = timestampHeight + kCCAvatarImageSize + kCCAvatarPaddingY;
        
        CGFloat bubbleMessageHeight = [CCMessageBubbleView calculateCellHeightWithMessage:message] + timestampHeight + userNameHheight;
        
        height = MAX(bubbleMessageHeight, userInfoNeedHeight) + kCCAvatarPaddingY * 2;
    }
    return height;
}

+ (CGSize)noticeMessageHeight:(id<CCMessageModel>)message
{
    UIFont *systemFont = [UIFont systemFontOfSize:10.0f];
    CGSize textSize = CGSizeMake(winsize.width - 20, CGFLOAT_MAX); // rough accessory size
    CGSize sizeWithFont;
    NSString *text = [NSString stringWithFormat:@" %@ ", [message noticeContent]];
    if ([message noticeAttContent])
        text = [NSString stringWithFormat:@" %@ ", [[message noticeAttContent] string]];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] <= 6.0) {
        sizeWithFont = [text sizeWithFont:systemFont constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    } else {
        sizeWithFont = [text boundingRectWithSize:textSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : systemFont } context:nil].size;
    }
    
    sizeWithFont.height += 10;
    sizeWithFont.width += 5;
    
    return sizeWithFont;
}

#pragma mark - Life cycle

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.accessoryView = nil;
    
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizerHandle:)];
    [recognizer setMinimumPressDuration:0.4f];
    [self addGestureRecognizer:recognizer];
    
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerHandle:)];
    [self addGestureRecognizer:tapGestureRecognizer];
}

- (instancetype)initWithMessage:(id<CCMessageModel>)message
              displaysTimestamp:(BOOL)displayTimestamp
                reuseIdentifier:(NSString *)cellIdentifier
{
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    if (self) {
        // 如果初始化成功，那就根据Message类型进行初始化控件，比如配置头像，配置发送和接收的样式
        if (!_selectedIndicator) {
            UIImageView *selectedIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(-30, 10, 30, 30)];
            selectedIndicator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
            [self.contentView addSubview:selectedIndicator];
            _selectedIndicator = selectedIndicator;
        }
        
        // 1、是否显示Time Line的label
        if (!_timestampLabel) {
            CCBadgeView *timestampLabel = [[CCBadgeView alloc] initWithFrame:CGRectMake(0, kCCLabelPadding, winsize.width, kCCTimeStampLabelHeight)];
            timestampLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
            timestampLabel.badgeColor = cc_ColorRGB(202, 202, 202); //[UIColor colorWithWhite:0.734 alpha:1.000];
            timestampLabel.textColor = [UIColor whiteColor];	//cc_ColorRGB(51, 58, 79); //
            timestampLabel.font = [UIFont systemFontOfSize:10.0f];
            timestampLabel.center = CGPointMake(CGRectGetWidth([[UIScreen mainScreen] bounds]) / 2.0, timestampLabel.center.y);
            [self.contentView addSubview:timestampLabel];
            [self.contentView bringSubviewToFront:timestampLabel];
            _timestampLabel = timestampLabel;
        }
        
        // 通知消息类型
        if (!_noticeLabel) {
            MLLinkLabel *noticeLabel = [[MLLinkLabel alloc] initWithFrame:CGRectMake(10, kCCLabelPadding, winsize.width - 20, kCCTimeStampLabelHeight)];
            noticeLabel.textAlignment = NSTextAlignmentCenter;
            noticeLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
            noticeLabel.backgroundColor = cc_ColorRGB(202, 202, 202);
            noticeLabel.font = [UIFont systemFontOfSize:10.0f];
            noticeLabel.textColor = [UIColor whiteColor];
            noticeLabel.numberOfLines = 0;
            noticeLabel.adjustsFontSizeToFitWidth = NO;
            noticeLabel.textInsets = UIEdgeInsetsZero;
            noticeLabel.dataDetectorTypes = MLDataDetectorTypeAll;
            noticeLabel.allowLineBreakInsideLinks = NO;
            noticeLabel.linkTextAttributes = nil;
            noticeLabel.activeLinkTextAttributes = nil;
            noticeLabel.lineHeightMultiple = 1.1f;
            noticeLabel.linkTextAttributes = @{NSForegroundColorAttributeName : cc_ColorRGB(246, 131, 34)};
            cc_View_Border_Radius(noticeLabel, 4, 0.5, cc_ColorRGB(202, 202, 202));
            [noticeLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickOutsideLink:)]];
            [self.contentView addSubview:noticeLabel];
            [self.contentView bringSubviewToFront:noticeLabel];
            _noticeLabel = noticeLabel;
        }
        
        // 2、配置头像
        CGRect avatarButtonFrame;
        switch (message.bubbleMessageType) {
            case CCBubbleMessageTypeReceiving:
                avatarButtonFrame = CGRectMake(kCCAvatarPaddingX,
                                               kCCAvatarPaddingY + (self.displayTimestamp ? (kCCTimeStampLabelHeight + kCCLabelPadding * 2) : 0),
                                               kCCAvatarImageSize,
                                               kCCAvatarImageSize);
                break;
            case CCBubbleMessageTypeSending:
                avatarButtonFrame = CGRectMake(CGRectGetWidth(self.bounds) - kCCAvatarImageSize - kCCAvatarPaddingX,
                                               kCCAvatarPaddingY + (self.displayTimestamp ? (kCCTimeStampLabelHeight + kCCLabelPadding * 2) : 0),
                                               kCCAvatarImageSize,
                                               kCCAvatarImageSize);
                break;
            default:
                break;
        }
        
        if (!_avatarButton) {
            UIButton *avatarButton = [[UIButton alloc] initWithFrame:avatarButtonFrame];
            [avatarButton setImage:[CCMessageAvatarFactory avatarImageNamed:[UIImage imageNamed:@"avator"] messageAvatarType:CCMessageAvatarTypeCircle] forState:UIControlStateNormal];
            [avatarButton addTarget:self action:@selector(avatarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            avatarButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
            //            avatarButton.layer.cornerRadius = 5;
            //            avatarButton.layer.masksToBounds = YES;
            avatarButton.layer.borderWidth = 1;
            avatarButton.layer.borderColor = [cc_ColorRGB(238, 238, 241) CGColor];
            avatarButton.backgroundColor = [UIColor whiteColor];
            [self.contentView addSubview:avatarButton];
            self.avatarButton = avatarButton;
            
            
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(buttonlongPressGestureRecognizerHandle:)];
            longPress.minimumPressDuration = 0.4; //定义按的时间
            [avatarButton addGestureRecognizer:longPress];
        }
        
        if (!_userLabel) {
            UILabel *userLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.avatarButton.bounds) + 20, kCCUserNameLabelHeight)];
            userLabel.font = [UIFont systemFontOfSize:12];
            userLabel.textColor = [UIColor whiteColor];
            userLabel.hidden = YES;
            userLabel.layer.masksToBounds = YES;
            userLabel.layer.cornerRadius = 3;
            [self.contentView addSubview:userLabel];
            self.userLabel = userLabel;
        }
        
        if (!_userNameLabel) {
            // 3、配置用户名
            UILabel *userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.avatarButton.bounds) + 20, kCCUserNameLabelHeight)];
            //            userNameLabel.textAlignment = NSTextAlignmentCenter;
            userNameLabel.backgroundColor = [UIColor clearColor];
            userNameLabel.font = [UIFont systemFontOfSize:12];
            userNameLabel.textColor = cc_ColorRGB(84, 90, 100);
            userNameLabel.hidden = YES;
            [self.contentView addSubview:userNameLabel];
            self.userNameLabel = userNameLabel;
        }
        if (message.shouldShowUserLabel)
            self.userLabel.hidden = YES;
        
        if (message.shouldShowUserName)
            self.userNameLabel.hidden = YES;
        
        // 4、配置需要显示什么消息内容，比如语音、文字、视频、图片
        if (!_messageBubbleView) {
            // bubble container
            CCMessageBubbleView *messageBubbleView = [[CCMessageBubbleView alloc] initWithFrame:CGRectZero message:message];
            messageBubbleView.delegate = self;
            [self.contentView addSubview:messageBubbleView];
            [self.contentView sendSubviewToBack:messageBubbleView];
            self.messageBubbleView = messageBubbleView;
        }
    }
    return self;
}

#pragma mark - CCMessageBubbleViewDelegate

/**
 *  @author CC, 15-09-15
 *
 *  @brief  未发送成功消息重新发送
 *
 *  @since 1.0
 */
- (void)didSendNotSuccessfulCallback
{
    if ([self.delegate respondsToSelector:@selector(didSelectedSendNotSuccessfulCallback:atIndexPath:)])
        [self.delegate didSelectedSendNotSuccessfulCallback:self.messageBubbleView.message atIndexPath:self.indexPath];
}

- (void)didMessageLinkClick:(NSString *)linkStr
{
    if ([self.delegate respondsToSelector:@selector(didMessageLinkClick:)]) {
        [self.delegate didMessageLinkClick:linkStr];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [self setup];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ([self.messageBubbleView.message messageMediaType] == CCBubbleMessageMediaTypeNotice) {
        self.avatarButton.hidden = YES;
        self.userNameLabel.hidden = YES;
        self.userLabel.hidden = YES;
        self.messageBubbleView.hidden = YES;
        self.noticeLabel.hidden = NO;
        
        CGFloat layoutOriginY = (self.displayTimestamp ? kCCTimeStampLabelHeight + kCCLabelPadding * 2 : 0);
        CGRect noticeContentFram = self.noticeLabel.frame;
        noticeContentFram.origin.y = layoutOriginY;
        noticeContentFram.size = [CCMessageTableViewCell noticeMessageHeight:self.messageBubbleView.message];
        self.noticeLabel.frame = noticeContentFram;
        self.noticeLabel.centerX = self.contentView.centerX;
        self.selectedIndicator.hidden = YES;
    } else {
        self.noticeLabel.hidden = YES;
        self.avatarButton.hidden = NO;
        self.messageBubbleView.hidden = NO;
        self.selectedIndicator.hidden = NO;
        // 布局头像
        CGFloat layoutOriginY = (self.displayTimestamp ? kCCTimeStampLabelHeight + kCCLabelPadding * 2 : 0);
        CGRect avatarButtonFrame = self.avatarButton.frame;
        avatarButtonFrame.origin.y = layoutOriginY;
        avatarButtonFrame.origin.x = kCCAvatarPaddingX;
        if ([self bubbleMessageType] != CCBubbleMessageTypeReceiving) {
            CGFloat x = (CGRectGetWidth(self.bounds) - kCCAvatarPaddingX - kCCAvatarImageSize);
            if (self.editing)
                x -= kCCAvatarImageSize;
            avatarButtonFrame.origin.x = x;
        }
        self.avatarButton.frame = avatarButtonFrame;
        
        // 布局消息内容的View
        CGFloat bubbleX = 0.0f;
        CGFloat offsetX = 0.0f;
        if ([self bubbleMessageType] == CCBubbleMessageTypeReceiving)
            bubbleX = kCCAvatarImageSize + kCCAvatarPaddingX * 2;
        else
            offsetX = kCCAvatarImageSize + kCCAvatarPaddingX * 2;
        
        CGFloat timeStampLabelNeedHeight = layoutOriginY;
        
        if (self.messageBubbleView.message.shouldShowUserLabel) {
            self.userLabel.hidden = NO;
            [self.userLabel sizeToFit];
            // 布局标签
            CGRect userLabelFrame = self.userLabel.frame;
            userLabelFrame.origin.y = timeStampLabelNeedHeight;
            userLabelFrame.origin.x = avatarButtonFrame.origin.x + avatarButtonFrame.size.width + kCCAvatarPaddingX;
            if (self.bubbleMessageType != CCBubbleMessageTypeReceiving) {
                userLabelFrame.origin.x = avatarButtonFrame.origin.x - userLabelFrame.size.width - kCCAvatarPaddingX;
            }
            self.userLabel.frame = userLabelFrame;
        }
        
        if (self.messageBubbleView.message.shouldShowUserName) {
            self.userNameLabel.hidden = NO;
            [self.userNameLabel sizeToFit];
            
            CGFloat x = avatarButtonFrame.origin.x + avatarButtonFrame.size.width + kCCAvatarPaddingX;
            if (self.messageBubbleView.message.shouldShowUserLabel)
                x = self.userLabel.right + 5;
            
            // 布局用户名
            CGRect userNameFrame = self.userNameLabel.frame;
            userNameFrame.origin.y = timeStampLabelNeedHeight;
            userNameFrame.origin.x = x;
            if (self.bubbleMessageType != CCBubbleMessageTypeReceiving) {
                userNameFrame.origin.x = avatarButtonFrame.origin.x - userNameFrame.size.width - kCCAvatarPaddingX;
                if (self.messageBubbleView.message.shouldShowUserLabel)
                    userNameFrame.origin.x = self.userLabel.left - userNameFrame.size.width - 5;
            }
            
            CGFloat userNameWidth = userNameFrame.size.width;
            if ((userNameWidth + userNameFrame.origin.x) > self.contentView.width) {
                userNameWidth = self.contentView.width - userNameFrame.origin.x;
            }
            userNameFrame.size.width = userNameWidth;
            
            self.userNameLabel.frame = userNameFrame;
            
            timeStampLabelNeedHeight += userNameFrame.size.height + 5;
        }
        
        
        CGRect bubbleMessageViewFrame = CGRectMake(bubbleX,
                                                   timeStampLabelNeedHeight,
                                                   CGRectGetWidth(self.contentView.bounds) - bubbleX - offsetX,
                                                   CGRectGetHeight(self.contentView.bounds) - timeStampLabelNeedHeight);
        self.messageBubbleView.frame = bubbleMessageViewFrame;
        
        self.messageBubbleView.userInteractionEnabled = YES;
        UITableView *edit = (UITableView *)self.superview.superview;
        if (edit.editing)
            self.messageBubbleView.userInteractionEnabled = NO;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        if (self.messageBubbleView.message.selected)
            [self.selectedIndicator setImage:CCResourceImage(@"AssetsYES")];
        else
            [self.selectedIndicator setImage:CCResourceImage(@"AssetsNO")];
        
        [UIView commitAnimations];
    }
}

- (void)dealloc
{
    _avatarButton = nil;
    _userNameLabel = nil;
    _timestampLabel = nil;
    _messageBubbleView = nil;
    _noticeLabel = nil;
    self.indexPath = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - TableViewCell

- (void)prepareForReuse
{
    // 这里做清除工作
    [super prepareForReuse];
    //    self.messageBubbleView.displayTextView.text = nil;
    //    self.messageBubbleView.displayTextView.attributedText = nil;
    self.messageBubbleView.bubbleImageView.image = nil;
    self.messageBubbleView.emotionImageView.animatedImage = nil;
    self.messageBubbleView.animationVoiceImageView.image = nil;
    self.messageBubbleView.voiceDurationLabel.text = nil;
    self.messageBubbleView.bubblePhotoImageView.image = nil;
    self.messageBubbleView.geolocationsLabel.text = nil;
    
    self.userNameLabel.text = nil;
    [self.avatarButton setImage:nil forState:UIControlStateNormal];
    self.timestampLabel.text = nil;
    self.noticeLabel.text = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark -_- 手势冲突

- (void)didMoveToSuperview
{
    self.containingTableView = nil;
    UIView *view = self.superview;
    
    do {
        if ([view isKindOfClass:[UITableView class]]) {
            self.containingTableView = (UITableView *)view;
            break;
        }
    } while ((view = view.superview));
}

- (void)selectCell
{
    
    NSIndexPath *cellIndexPath = [self.containingTableView indexPathForCell:self];
    
    if ([self.containingTableView.delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]) {
        cellIndexPath = [self.containingTableView.delegate tableView:self.containingTableView
                                            willSelectRowAtIndexPath:cellIndexPath];
    }
    
    if (cellIndexPath) {
        [self.containingTableView selectRowAtIndexPath:cellIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        
        if ([self.containingTableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
            [self.containingTableView.delegate tableView:self.containingTableView
                                 didSelectRowAtIndexPath:cellIndexPath];
        }
    }
}

- (void)deselectCell
{
    NSIndexPath *cellIndexPath = [self.containingTableView indexPathForCell:self];
    
    if ([self.containingTableView.delegate respondsToSelector:@selector(tableView:willDeselectRowAtIndexPath:)]) {
        cellIndexPath = [self.containingTableView.delegate
                         tableView:self.containingTableView
                         willDeselectRowAtIndexPath:cellIndexPath];
    }
    
    if (cellIndexPath) {
        [self.containingTableView deselectRowAtIndexPath:cellIndexPath animated:NO];
        
        if ([self.containingTableView.delegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)])
        {
            [self.containingTableView.delegate tableView:self.containingTableView
                               didDeselectRowAtIndexPath:cellIndexPath];
        }
    }
}

- (BOOL)shouldHighlight
{
    BOOL shouldHighlight = YES;
    
    if ([self.containingTableView.delegate respondsToSelector:@selector(tableView:shouldHighlightRowAtIndexPath:)])
    {
        NSIndexPath *cellIndexPath = [self.containingTableView indexPathForCell:self];
        
        shouldHighlight = [self.containingTableView.delegate tableView:self.containingTableView
                                         shouldHighlightRowAtIndexPath:cellIndexPath];
    }
    
    return shouldHighlight;
}

@end
