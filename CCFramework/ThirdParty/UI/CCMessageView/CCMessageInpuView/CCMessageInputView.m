//
//  CCMessageInputView.m
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

#import "CCMessageInputView.h"
#import <QuartzCore/QuartzCore.h>
#import "CCProperty.h"
#import "NSString+Additions.h"
#import "UIControl+Additions.h"

@interface CCMessageInputView () <CCMessageTextViewDelegate>

@property(nonatomic, weak, readwrite) UILabel *allowTalkLabel;

@property(nonatomic, weak, readwrite) CCMessageTextView *inputTextView;

@property(nonatomic, weak, readwrite) UIButton *voiceChangeButton;

@property(nonatomic, weak, readwrite) UIButton *multiMediaSendButton;

@property(nonatomic, weak, readwrite) UIButton *faceSendButton;

@property(nonatomic, weak, readwrite) UIButton *holdDownButton;

/**
 *  是否取消錄音
 */
@property(nonatomic, assign, readwrite) BOOL isCancelled;

/**
 *  是否正在錄音
 */
@property(nonatomic, assign, readwrite) BOOL isRecording;

/**
 *  在切换语音和文本消息的时候，需要保存原本已经输入的文本，这样达到一个好的UE
 */
@property(nonatomic, copy) NSString *inputedText;

/**
 *  输入框内的所有按钮，点击事件所触发的方法
 *
 *  @param sender 被点击的按钮对象
 */
- (void)messageStyleButtonClicked:(UIButton *)sender;

/**
 *  当录音按钮被按下所触发的事件，这时候是开始录音
 */
- (void)holdDownButtonTouchDown;

/**
 *  当手指在录音按钮范围之外离开屏幕所触发的事件，这时候是取消录音
 */
- (void)holdDownButtonTouchUpOutside;

/**
 *  当手指在录音按钮范围之内离开屏幕所触发的事件，这时候是完成录音
 */
- (void)holdDownButtonTouchUpInside;

/**
 *  当手指滑动到录音按钮的范围之外所触发的事件
 */
- (void)holdDownDragOutside;

/**
 *  当手指滑动到录音按钮的范围之内所触发的时间
 */
- (void)holdDownDragInside;

#pragma mark - layout subViews UI
/**
 *  根据正常显示和高亮状态创建一个按钮对象
 *
 *  @param image   正常显示图
 *  @param hlImage 高亮显示图
 *
 *  @return 返回按钮对象
 */
- (UIButton *)createButtonWithImage:(UIImage *)image HLImage:(UIImage *)hlImage;

/**
 *  根据输入框的样式类型配置输入框的样式和UI布局
 *
 *  @param style 输入框样式类型
 */
- (void)setupMessageInputViewBarWithStyle:(CCMessageInputViewStyle)style;

/**
 *  配置默认参数
 */
- (void)setup;

#pragma mark - Message input view
/**
 *  动态改变textView的高度
 *
 *  @param changeInHeight 动态的高度
 */
- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight;

@end

@implementation CCMessageInputView

#pragma mark - Action

- (void)messageStyleButtonClicked:(UIButton *)sender
{
    NSInteger index = sender.tag;
    switch (index) {
        case 0: {
            sender.selected = !sender.selected;
            if (sender.selected) {
                self.inputedText = self.inputTextView.text;
                self.inputTextView.text = @"";
                [self.inputTextView resignFirstResponder];
            } else {
                self.inputTextView.text = self.inputedText;
                self.inputedText = nil;
                [self.inputTextView becomeFirstResponder];
            }
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.holdDownButton.alpha = sender.selected;
                self.inputTextView.alpha = !sender.selected;
            } completion:^(BOOL finished){
                
            }];
            
            if ([self.delegate respondsToSelector:@selector(didChangeSendVoiceAction:)]) {
                [self.delegate didChangeSendVoiceAction:sender.selected];
            }
            
            break;
        }
        case 1:
        case 2: {
            sender.selected = !sender.selected;
            self.voiceChangeButton.selected = !sender.selected;
            
            if (!sender.selected) {
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.holdDownButton.alpha = sender.selected;
                    self.inputTextView.alpha = !sender.selected;
                } completion:^(BOOL finished){
                    
                }];
            } else {
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.holdDownButton.alpha = !sender.selected;
                    self.inputTextView.alpha = sender.selected;
                } completion:^(BOOL finished){
                    
                }];
            }
            
            if (index == 1) {
                if ([self.delegate respondsToSelector:@selector(didSendFaceAction:)]) {
                    [self.delegate didSendFaceAction:sender.selected];
                }
            } else {
                self.faceSendButton.selected = NO;
                if ([self.delegate respondsToSelector:@selector(didSelectedMultipleMediaAction)]) {
                    [self.delegate didSelectedMultipleMediaAction];
                }
            }
            
            break;
        }
        default:
            break;
    }
}

- (void)holdDownButtonTouchDown
{
    self.isCancelled = NO;
    self.isRecording = NO;
    if ([self.delegate respondsToSelector:@selector(prepareRecordingVoiceActionWithCompletion:)]) {
        typeof(self) __weak weakSelf = self;
        //這邊回調 return 的 YES, 或 NO, 可以讓底層知道該次錄音是否成功, 進而處理無用的 record 對象
        [self.delegate prepareRecordingVoiceActionWithCompletion:^BOOL {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            //這邊要判斷回調回來的時候, 使用者是不是已經早就鬆開手了
            if (strongSelf && !strongSelf.isCancelled) {
                strongSelf.isRecording = YES;
                [strongSelf.delegate didStartRecordingVoiceAction];
                return YES;
            } else {
                return NO;
            }
        }];
    }
}

- (void)holdDownButtonTouchUpOutside
{
    //如果已經開始錄音了, 才需要做取消的動作, 否則只要切換 isCancelled, 不讓錄音開始.
    if (self.isRecording) {
        if ([self.delegate respondsToSelector:@selector(didCancelRecordingVoiceAction)]) {
            [self.delegate didCancelRecordingVoiceAction];
        }
    } else {
        self.isCancelled = YES;
    }
}

- (void)holdDownButtonTouchUpInside
{
    //如果已經開始錄音了, 才需要做結束的動作, 否則只要切換 isCancelled, 不讓錄音開始.
    if (self.isRecording) {
        if ([self.delegate respondsToSelector:@selector(didFinishRecoingVoiceAction)]) {
            [self.delegate didFinishRecoingVoiceAction];
        }
    } else {
        self.isCancelled = YES;
    }
}

- (void)holdDownDragOutside
{
    //如果已經開始錄音了, 才需要做拖曳出去的動作, 否則只要切換 isCancelled, 不讓錄音開始.
    if (self.isRecording) {
        if ([self.delegate respondsToSelector:@selector(didDragOutsideAction)]) {
            [self.delegate didDragOutsideAction];
        }
    } else {
        self.isCancelled = YES;
    }
}

- (void)holdDownDragInside
{
    //如果已經開始錄音了, 才需要做拖曳回來的動作, 否則只要切換 isCancelled, 不讓錄音開始.
    if (self.isRecording) {
        if ([self.delegate respondsToSelector:@selector(didDragInsideAction)]) {
            [self.delegate didDragInsideAction];
        }
    } else {
        self.isCancelled = YES;
    }
}

#pragma mark - layout subViews UI

- (UIButton *)createButtonWithImage:(UIImage *)image HLImage:(UIImage *)hlImage
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [CCMessageInputView textViewLineHeight], [CCMessageInputView textViewLineHeight])];
    if (image)
        [button setBackgroundImage:image forState:UIControlStateNormal];
    if (hlImage)
        [button setBackgroundImage:hlImage forState:UIControlStateHighlighted];
    
    return button;
}

- (void)setupMessageInputViewBarWithStyle:(CCMessageInputViewStyle)style
{
    // 配置输入工具条的样式和布局
    
    // 需要显示按钮的总宽度，包括间隔在内
    CGFloat allButtonWidth = 0.0;
    
    // 水平间隔
    CGFloat horizontalPadding = 8;
    
    // 垂直间隔
    CGFloat verticalPadding = 5;
    
    // 输入框
    CGFloat textViewLeftMargin = ((style == CCMessageInputViewStyleFlat) ? 6.0 : 4.0);
    
    // 每个按钮统一使用的frame变量
    CGRect buttonFrame;
    
    // 按钮对象消息
    UIButton *button;
    
    // 允许发送语音
    if (self.allowsSendVoice) {
        
        button = [self createButtonWithImage:[UIImage imageNamed:@"voice"] HLImage:[UIImage imageNamed:@"voice_HL"]];
        [button addTarget:self action:@selector(messageStyleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 0;
        [button setBackgroundImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateSelected];
        buttonFrame = button.frame;
        buttonFrame.origin = CGPointMake(horizontalPadding, verticalPadding);
        button.frame = buttonFrame;
        [self addSubview:button];
        allButtonWidth += CGRectGetMaxX(buttonFrame);
        textViewLeftMargin += CGRectGetMaxX(buttonFrame);
        
        self.voiceChangeButton = button;
    }
    
    // 允许发送多媒体消息，为什么不是先放表情按钮呢？因为布局的需要！
    if (self.allowsSendMultiMedia) {
        button = [self createButtonWithImage:[UIImage imageNamed:@"multiMedia"] HLImage:[UIImage imageNamed:@"multiMedia_HL"]];
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [button addTarget:self action:@selector(messageStyleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 2;
        buttonFrame = button.frame;
        buttonFrame.origin = CGPointMake(CGRectGetWidth(self.bounds) - horizontalPadding - CGRectGetWidth(buttonFrame), verticalPadding);
        button.frame = buttonFrame;
        [self addSubview:button];
        allButtonWidth += CGRectGetWidth(buttonFrame) + horizontalPadding * 2.5;
        
        self.multiMediaSendButton = button;
    }
    
    // 允许发送表情
    if (self.allowsSendFace) {
        button = [self createButtonWithImage:[UIImage imageNamed:@"face"] HLImage:[UIImage imageNamed:@"face_HL"]];
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [button setBackgroundImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(messageStyleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 1;
        buttonFrame = button.frame;
        horizontalPadding = horizontalPadding / 2;
        if (self.allowsSendMultiMedia) {
            buttonFrame.origin = CGPointMake(CGRectGetMinX(self.multiMediaSendButton.frame) - CGRectGetWidth(buttonFrame) - horizontalPadding, verticalPadding);
            allButtonWidth += CGRectGetWidth(buttonFrame) + horizontalPadding * 1.5;
        } else {
            buttonFrame.origin = CGPointMake(CGRectGetWidth(self.bounds) - horizontalPadding - CGRectGetWidth(buttonFrame), verticalPadding);
            allButtonWidth += CGRectGetWidth(buttonFrame) + horizontalPadding * 2.5;
        }
        button.frame = buttonFrame;
        [self addSubview:button];
        
        self.faceSendButton = button;
    }
    
    // 输入框的高度和宽度
    CGFloat width = CGRectGetWidth(self.bounds) - (allButtonWidth ? allButtonWidth : (textViewLeftMargin * 2));
    CGFloat height = [CCMessageInputView textViewLineHeight];
    
    // 初始化输入框
    CCMessageTextView *textView = [[CCMessageTextView alloc] initWithFrame:CGRectZero];
    
    // 这个是仿微信的一个细节体验
    textView.returnKeyType = UIReturnKeySend;
    textView.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
    textView.placeholderTextColor = [UIColor lightGrayColor];
    textView.textColor = [UIColor blackColor];
    
    //    textView.placeholder = NSLocalizedStringFromTable(@"发送消息", @"MessageDisplayKitString", nil);
    textView.delegate = self;
    
    [self addSubview:textView];
    _inputTextView = textView;
    
    
    // 配置不同iOS SDK版本的样式
    switch (style) {
        case CCMessageInputViewStyleFlat: {
            _inputTextView.frame = CGRectMake(textViewLeftMargin, 4.5f, width, height);
            _inputTextView.backgroundColor = [UIColor whiteColor];
            _inputTextView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
            _inputTextView.layer.borderWidth = 0.65f;
            _inputTextView.layer.cornerRadius = 6.0f;
            UIImage *image = [[UIImage imageNamed:@"input-bar-flat"] resizableImageWithCapInsets:UIEdgeInsetsMake(2.0f, 0.0f, 2.0f, 0.0f)
                                                                                    resizingMode:UIImageResizingModeTile];
            self.image = image;
            //            self.backgroundColor = cc_ColorRGB(247, 247, 247);
            break;
        }
        default:
            break;
    }
    
    if (!_allowTalkLabel) {
        UILabel *allowTalkLabel = [[UILabel alloc] initWithFrame:_inputTextView.frame];
        allowTalkLabel.backgroundColor = [UIColor whiteColor];
        allowTalkLabel.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
        allowTalkLabel.layer.borderWidth = 0.65f;
        allowTalkLabel.layer.cornerRadius = 6.0f;
        allowTalkLabel.textAlignment = NSTextAlignmentCenter;
        allowTalkLabel.textColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
        allowTalkLabel.text = @"禁言中";
        allowTalkLabel.hidden = YES;
        [self addSubview:allowTalkLabel];
        [self bringSubviewToFront:allowTalkLabel];
        _allowTalkLabel = allowTalkLabel;
    }
    
    // 如果是可以发送语音的，那就需要一个按钮录音的按钮，事件可以在外部添加
    if (self.allowsSendVoice) {
        
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(9, 9, 9, 9);
        button = [self createButtonWithImage:cc_Stretch_Image([UIImage imageNamed:@"VoiceBtn_Black"], edgeInsets) HLImage:cc_Stretch_Image([UIImage imageNamed:@"VoiceBtn_BlackHL"], edgeInsets)];
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [button setTitle:NSLocalizedStringFromTable(@"按住说话", @"MessageDisplayKitString", nil) forState:UIControlStateNormal];
        [button setTitle:NSLocalizedStringFromTable(@"松开结束", @"MessageDisplayKitString", nil) forState:UIControlStateHighlighted];
        buttonFrame = CGRectMake(textViewLeftMargin - 5, 0, width + 10, self.frame.size.height);
        button.frame = buttonFrame;
        button.alpha = self.voiceChangeButton.selected;
        [button addTarget:self action:@selector(holdDownButtonTouchDown) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(holdDownButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
        [button addTarget:self action:@selector(holdDownButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(holdDownDragOutside) forControlEvents:UIControlEventTouchDragExit];
        [button addTarget:self action:@selector(holdDownDragInside) forControlEvents:UIControlEventTouchDragEnter];
        button.isIgnore = YES;
        [self addSubview:button];
        self.holdDownButton = button;
    }
}

#pragma mark - Life cycle

- (void)setup
{
    // 配置自适应
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.opaque = YES;
    // 由于继承UIImageView，所以需要这个属性设置
    self.userInteractionEnabled = YES;
    
    // 默认设置
    _allowsSendVoice = YES;
    _allowsSendFace = YES;
    _allowsSendMultiMedia = YES;
    
    _messageInputViewStyle = CCMessageInputViewStyleFlat;
}

- (void)awakeFromNib
{
    [self setup];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)dealloc
{
    self.inputedText = nil;
    _inputTextView.delegate = nil;
    _inputTextView = nil;
    
    _voiceChangeButton = nil;
    _multiMediaSendButton = nil;
    _faceSendButton = nil;
    _holdDownButton = nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    // 当别的地方需要add的时候，就会调用这里
    if (newSuperview) {
        [self setupMessageInputViewBarWithStyle:self.messageInputViewStyle];
    }
}

- (void)setAllowTalk:(BOOL)allowTalk
{
    _allowTalk = allowTalk;
    self.voiceChangeButton.enabled = !_allowTalk;
    self.multiMediaSendButton.enabled = !_allowTalk;
    self.faceSendButton.enabled = !_allowTalk;
    self.holdDownButton.enabled = !_allowTalk;
    self.inputTextView.editable = !_allowTalk;
    self.allowTalkLabel.hidden = !_allowTalk;
}

#pragma mark - Message input view

- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight
{
    // 动态改变自身的高度和输入框的高度
    CGRect prevFrame = self.inputTextView.frame;
    
    NSUInteger numLines = MAX([self.inputTextView numberOfLinesOfText],
                              [self.inputTextView.text numberOfLines]);
    
    self.inputTextView.frame = CGRectMake(prevFrame.origin.x,
                                          prevFrame.origin.y,
                                          prevFrame.size.width,
                                          prevFrame.size.height + changeInHeight);
    
    
    self.inputTextView.contentInset = UIEdgeInsetsMake((numLines >= 6 ? 4.0f : 0.0f),
                                                       0.0f,
                                                       (numLines >= 6 ? 4.0f : 0.0f),
                                                       0.0f);
    
    // from iOS 7, the content size will be accurate only if the scrolling is enabled.
    self.inputTextView.scrollEnabled = YES;
    
    if (numLines >= 6) {
        CGPoint bottomOffset = CGPointMake(0.0f, self.inputTextView.contentSize.height - self.inputTextView.bounds.size.height);
        [self.inputTextView setContentOffset:bottomOffset animated:YES];
        [self.inputTextView scrollRangeToVisible:NSMakeRange(self.inputTextView.text.length - 2, 1)];
    }
}

+ (CGFloat)textViewLineHeight
{
    return 36.0f; // for fontSize 16.0f
}

+ (CGFloat)maxLines
{
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 3.0f : 8.0f;
}

+ (CGFloat)maxHeight
{
    return ([CCMessageInputView maxLines] + 1.0f) * [CCMessageInputView textViewLineHeight];
}

#pragma mark - Text view delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(inputTextViewWillBeginEditing:)]) {
        [self.delegate inputTextViewWillBeginEditing:self.inputTextView];
    }
    self.faceSendButton.selected = NO;
    self.voiceChangeButton.selected = NO;
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [textView becomeFirstResponder];
    if ([self.delegate respondsToSelector:@selector(inputTextViewDidBeginEditing:)]) {
        [self.delegate inputTextViewDidBeginEditing:self.inputTextView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(didSendTextAction:)]) {
            [self.delegate didSendTextAction:textView.text];
        }
        return NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(inputTextViewDidChangeText:)])
        [self.delegate inputTextViewDidChangeText:self.inputTextView];
    
    return YES;
}

/**
 *  @author CC, 2015-12-25
 *
 *  @brief  删除表情
 */
-(void)didDeleteBackward
{
    if ([self.delegate respondsToSelector:@selector(didTextDeleteBackward)]) {
        [self.delegate didTextDeleteBackward];
    }
}

@end
