//
//  CCMessageInputView.h
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
#import "CCMessageTextView.h"

typedef NS_ENUM(NSInteger, CCMessageInputViewStyle) {
    // 分两种,一种是iOS6样式的，一种是iOS7样式的
    CCMessageInputViewStyleQuasiphysical,
    CCMessageInputViewStyleFlat
};

@protocol CCMessageInputViewDelegate <NSObject>

@required

/**
 *  @author CC, 2015-08-13
 *
 *  @brief  输入框刚好开始编辑
 *
 *  @param messageInputTextView 输入框对象
 *
 *  @since 1.0
 */
- (void)inputTextViewDidBeginEditing:(CCMessageTextView *)messageInputTextView;

/**
 *  @author CC, 2015-08-13
 *
 *  @brief  输入框将要开始编辑
 *
 *  @param messageInputTextView 输入框对象
 *
 *  @since 1.0
 */
- (void)inputTextViewWillBeginEditing:(CCMessageTextView *)messageInputTextView;


@optional

/**
 *  @author CC, 16-08-04
 *
 *  @brief 输入框输入文字
 *
 *  @param messageInputTextView 输入框对象
 */
- (void)inputTextViewDidChangeText:(CCMessageTextView *)messageInputTextView;

/**
 *  @author CC, 2015-12-25
 *
 *  @brief  输入文本删除回调
 */
- (void)didTextDeleteBackward;

/**
 *  @author CC, 2015-08-13
 *
 *  @brief  在发送文本和语音之间发送改变时，会触发这个回调函数
 *
 *  @param changed 是否改为发送语音状态
 *
 *  @since 1.0
 */
- (void)didChangeSendVoiceAction:(BOOL)changed;

/**
 *  @author CC, 2015-08-13
 *
 *  @brief  发送文本消息，包括系统的表情
 *
 *  @param text 目标文本消息
 *
 *  @since 1.0
 */
- (void)didSendTextAction:(NSString *)text;

/**
 *  @author CC, 2015-08-13
 *
 *  @brief  点击+号按钮Action
 *
 *  @since 1.0
 */
- (void)didSelectedMultipleMediaAction:(BOOL)sendFace;

/**
 *  @author CC, 2015-08-13
 *
 *  @brief  按下录音按钮 "准备" 录音
 *
 *  @param completion <#completion description#>
 *
 *  @since 1.0
 */
- (void)prepareRecordingVoiceActionWithCompletion:(BOOL (^)(void))completion;

/**
 *  @author CC, 2015-08-13
 *
 *  @brief  开始录音
 *
 *  @since 1.0
 */
- (void)didStartRecordingVoiceAction;

/**
 *  @author CC, 2015-08-13
 *
 *  @brief  手指向上滑动取消录音
 *
 *  @since 1.0
 */
- (void)didCancelRecordingVoiceAction;

/**
 *  @author CC, 2015-08-13
 *
 *  @brief  松开手指完成录音
 *
 *  @since 1.0
 */
- (void)didFinishRecoingVoiceAction;

/**
 *  @author CC, 2015-08-13
 *
 *  @brief  当手指离开按钮的范围内时，主要为了通知外部的HUD
 *
 *  @since 1.0
 */
- (void)didDragOutsideAction;

/**
 *  @author CC, 2015-08-13
 *
 *  @brief  当手指再次进入按钮的范围内时，主要也是为了通知外部的HUD
 *
 *  @since 1.0
 */
- (void)didDragInsideAction;

/**
 *  @author CC, 2015-08-13
 *
 *  @brief  发送第三方表情
 *
 *  @param sendFace 目标表情的本地路径
 *
 *  @since 1.0
 */
- (void)didSendFaceAction:(BOOL)sendFace;

-(void)didTextDidChange:(UITextView *)textView;

@end

@interface CCMessageInputView : UIImageView

@property(nonatomic, weak) id<CCMessageInputViewDelegate> delegate;

/**
 *  @author CC, 2015-08-13
 *
 *  @brief  用于输入文本消息的输入框
 *
 *  @since 1.0
 */
@property(nonatomic, weak, readonly) CCMessageTextView *inputTextView;

/**
 *  @author CC, 2015-08-13
 *
 *  @brief  当前输入工具条的样式
 *
 *  @since 1.0
 */
@property(nonatomic, assign) CCMessageInputViewStyle messageInputViewStyle; // default is CCMessageInputViewStyleFlat

/**
 *  @author CC, 2015-08-13
 *
 *  @brief  是否允许发送语音
 *
 *  @since 1.0
 */
@property(nonatomic, assign) BOOL allowsSendVoice; // default is YES

/**
 *  @author CC, 2015-08-13
 *
 *  @brief  是否允许发送多媒体
 *
 *  @since 1.0
 */
@property(nonatomic, assign) BOOL allowsSendMultiMedia; // default is YES

/**
 *  @author CC, 2015-08-13
 *
 *  @brief  是否支持发送表情
 *
 *  @since 1.0
 */
@property(nonatomic, assign) BOOL allowsSendFace; // default is YES

/**
 *  @author C C, 2016-10-04
 *  
 *  @brief  是否禁言
 */
@property(nonatomic, assign) BOOL allowTalk; // default is NO

/**
 *  @author CC, 2015-08-13
 *
 *  @brief  切换文本和语音的按钮
 *
 *  @since 1.0
 */
@property(nonatomic, weak, readonly) UIButton *voiceChangeButton;

/**
 *  @author CC, 2015-08-13
 *
 *  @brief  +号按钮
 *
 *  @since 1.0
 */
@property(nonatomic, weak, readonly) UIButton *multiMediaSendButton;

/**
 *  @author CC, 2015-08-13
 *
 *  @brief  第三方表情按钮
 *
 *  @since 1.0
 */
@property(nonatomic, weak, readonly) UIButton *faceSendButton;

/**
 *  @author CC, 2015-08-13
 *
 *  @brief  语音录制按钮
 *
 *  @since 1.0
 */
@property(nonatomic, weak, readonly) UIButton *holdDownButton;

#pragma mark - Message input view

/**
 *  @author CC, 2015-08-13
 *
 *  @brief  动态改变高度
 *
 *  @param changeInHeight 目标变化的高度
 *
 *  @since 1.0
 */
- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight;

/**
 *  @author CC, 2015-08-13
 *
 *  @brief  获取输入框内容字体行高
 *
 *  @return 返回行高
 *
 *  @since 1.0
 */
+ (CGFloat)textViewLineHeight;

/**
 *  @author CC, 2015-08-13
 *
 *  @brief  获取最大行数
 *
 *  @return 返回最大行数
 *
 *  @since 1.0
 */
+ (CGFloat)maxLines;

/**
 *  获取根据最大行数和每行高度计算出来的最大显示高度
 *
 *  @return 返回最大显示高度
 */
+ (CGFloat)maxHeight;

@end
