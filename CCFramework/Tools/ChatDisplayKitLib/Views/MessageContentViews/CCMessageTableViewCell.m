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
#import "UIView+Method.h"

static const CGFloat kCCLabelPadding = 3.0f;
static const CGFloat kCCTimeStampLabelHeight = 20.0f;

static const CGFloat kCCAvatarPaddingX = 8.0;
static const CGFloat kCCAvatarPaddingY = 5;

static const CGFloat kCCUserNameLabelHeight = 20;

@interface CCMessageTableViewCell () <CCMessageBubbleViewDelegate>

@property(nonatomic, weak, readwrite) CCMessageBubbleView *messageBubbleView;

@property(nonatomic, weak, readwrite) UIButton *avatarButton;

@property(nonatomic, weak, readwrite) UILabel *userNameLabel;

@property(nonatomic, weak, readwrite) CCBadgeView *timestampLabel;

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
    return (action == @selector(copyed:) || action == @selector(transpond:) || action == @selector(favorites:) || action == @selector(withdraw:) || action == @selector(deletes:) || action == @selector(more:));
}

#pragma mark - Menu Actions
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
    if ([self.delegate respondsToSelector:@selector(didSelectedMenuTranspond:atIndexPath:)])
        [self.delegate didSelectedMenuTranspond:self.messageBubbleView.message
                                    atIndexPath:self.indexPath];
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
    
    // 4、配置需要显示什么消息内容，比如语音、文字、视频、图片
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
        if (avatarURL) {
            [self configAvatarWithPhotoURLString:avatarURL];
        }
    } else if (avatarURL) {
        [self configAvatarWithPhotoURLString:avatarURL];
    } else {
        UIImage *avatarPhoto = [CCMessageAvatarFactory avatarImageNamed:[UIImage imageNamed:@"avatar"]
                                                      messageAvatarType:CCMessageAvatarTypeSquare];
        [self configAvatarWithPhoto:avatarPhoto];
    }
}

- (void)configAvatarWithPhoto:(UIImage *)photo
{
    [self.avatarButton setImage:photo forState:UIControlStateNormal];
}

- (void)configAvatarWithPhotoURLString:(NSString *)photoURLString
{
    self.avatarButton.messageAvatarType = CCMessageAvatarTypeSquare;
    [self.avatarButton setImageWithURL:[NSURL URLWithString:photoURLString]
                            placeholer:[UIImage imageNamed:@"avatar"]];
}

- (void)configUserNameWithMessage:(id<CCMessageModel>)message
{
    self.userNameLabel.text = [message sender];
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
        default:
            break;
    }
    [self.messageBubbleView configureCellWithMessage:message];
}

#pragma mark - Gestures

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
    if (longPressGestureRecognizer.state != UIGestureRecognizerStateBegan || ![self becomeFirstResponder])
        return;
    
    NSArray *popMenuAry = [[CCConfigurationHelper appearance] popMenuTitles];
    NSMutableArray *menuItems = [[NSMutableArray alloc] init];
    for (int i = 0; i < popMenuAry.count; i++) {
        NSString *title = popMenuAry[i];
        SEL action = nil;
        switch (i) {
            case 0: {
                if ([self.messageBubbleView.message messageMediaType] == CCBubbleMessageMediaTypeText) {
                    action = @selector(copyed:);
                }
                break;
            }
            case 1: {
                action = @selector(transpond:);
                break;
            }
            case 2: {
                action = @selector(favorites:);
                break;
            }
            case 3: {
                action = @selector(withdraw:);
                break;
            }
            case 4: {
                action = @selector(deletes:);
                break;
            }
            case 5: {
                action = @selector(more:);
                break;
            }
            default:
                break;
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

#pragma mark - Notifications

- (void)handleMenuWillHideNotification:(NSNotification *)notification
{
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
    
    CGFloat userInfoNeedHeight = kCCAvatarPaddingY + kCCAvatarImageSize + (message.shouldShowUserName ? kCCUserNameLabelHeight : 0) + kCCAvatarPaddingY + timestampHeight;
    
    CGFloat bubbleMessageHeight = [CCMessageBubbleView calculateCellHeightWithMessage:message] + timestampHeight;
    
    return MAX(bubbleMessageHeight, userInfoNeedHeight);
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
            timestampLabel.badgeColor = [UIColor colorWithWhite:0.734 alpha:1.000];
            timestampLabel.textColor = [UIColor whiteColor];
            timestampLabel.font = [UIFont systemFontOfSize:10.0f];
            timestampLabel.center = CGPointMake(CGRectGetWidth([[UIScreen mainScreen] bounds]) / 2.0, timestampLabel.center.y);
            [self.contentView addSubview:timestampLabel];
            [self.contentView bringSubviewToFront:timestampLabel];
            _timestampLabel = timestampLabel;
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
            [avatarButton setImage:[CCMessageAvatarFactory avatarImageNamed:[UIImage imageNamed:@"avatar"] messageAvatarType:CCMessageAvatarTypeCircle] forState:UIControlStateNormal];
            [avatarButton addTarget:self action:@selector(avatarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:avatarButton];
            self.avatarButton = avatarButton;
        }
        
        if (message.shouldShowUserName) {
            // 3、配置用户名
            UILabel *userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.avatarButton.bounds) + 20, kCCUserNameLabelHeight)];
            userNameLabel.textAlignment = NSTextAlignmentCenter;
            userNameLabel.backgroundColor = [UIColor clearColor];
            userNameLabel.font = [UIFont systemFontOfSize:12];
            userNameLabel.textColor = [UIColor colorWithRed:0.140 green:0.635 blue:0.969 alpha:1.000];
            [self.contentView addSubview:userNameLabel];
            self.userNameLabel = userNameLabel;
        }
        
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
    
    // 布局头像
    CGFloat layoutOriginY = kCCAvatarPaddingY + (self.displayTimestamp ? kCCTimeStampLabelHeight : 0);
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
    
    if (self.messageBubbleView.message.shouldShowUserName) {
        // 布局用户名
        self.userNameLabel.center = CGPointMake(CGRectGetMidX(avatarButtonFrame), CGRectGetMaxY(avatarButtonFrame) + CGRectGetMidY(self.userNameLabel.bounds));
    }
    
    // 布局消息内容的View
    CGFloat bubbleX = 0.0f;
    CGFloat offsetX = 0.0f;
    if ([self bubbleMessageType] == CCBubbleMessageTypeReceiving) {
        bubbleX = kCCAvatarImageSize + kCCAvatarPaddingX * 2;
    } else {
        offsetX = kCCAvatarImageSize + kCCAvatarPaddingX * 2;
    }
    CGFloat timeStampLabelNeedHeight = (self.displayTimestamp ? (kCCTimeStampLabelHeight + kCCLabelPadding) : 0);
    
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

- (void)dealloc
{
    _avatarButton = nil;
    _timestampLabel = nil;
    _messageBubbleView = nil;
    self.indexPath = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - TableViewCell

- (void)prepareForReuse
{
    // 这里做清除工作
    [super prepareForReuse];
    self.messageBubbleView.displayTextView.text = nil;
    self.messageBubbleView.displayTextView.attributedText = nil;
    self.messageBubbleView.bubbleImageView.image = nil;
    self.messageBubbleView.emotionImageView.animatedImage = nil;
    self.messageBubbleView.animationVoiceImageView.image = nil;
    self.messageBubbleView.voiceDurationLabel.text = nil;
    self.messageBubbleView.bubblePhotoImageView.messagePhoto = nil;
    self.messageBubbleView.geolocationsLabel.text = nil;
    
    self.userNameLabel.text = nil;
    [self.avatarButton setImage:nil forState:UIControlStateNormal];
    self.timestampLabel.text = nil;
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
