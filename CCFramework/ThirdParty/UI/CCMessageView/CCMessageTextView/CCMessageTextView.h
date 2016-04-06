//
//  CCMessageTextView.h
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

@protocol CCMessageTextViewDelegate <UITextViewDelegate>

@optional

/**
 *  @author CC, 2015-12-25
 *  
 *  @brief  删除表情
 */
- (void)didDeleteBackward;

@end

@interface CCMessageTextView : UITextView

@property(nonatomic, weak) id<CCMessageTextViewDelegate> cc_delegate;

/**
 *  @author CC, 2015-08-13
 *
 *  @brief  提示用户输入的标语
 *
 *  @since 1.0
 */
@property(nonatomic, copy) NSString *placeholder;

/**
 *  @author CC, 2015-08-13
 *
 *  @brief  标语文本的颜色
 *
 *  @since 1.0
 */
@property(nonatomic, strong) UIColor *placeholderTextColor;

/**
 *  @author CC, 2015-08-13
 *
 *  @brief  获取自身文档占据有多少航
 *
 *  @return 返回行数
 *
 *  @since 1.0
 */
- (NSUInteger)numberOfLinesOfText;

/**
 *  @author CC, 2015-08-13
 *
 *  @brief  获取每行的高度
 *
 *  @return iPhone或者iPad来获取每行文字的高度
 *
 *  @since 1.0
 */
+ (NSInteger)maxCharactersPerLine;

/**
 *  @author CC, 2015-08-13
 *
 *  @brief  获取某个文本占据自身适应宽带的行数
 *
 *  @param text 目标文本
 *
 *  @return 返回占据行数
 *
 *  @since 1.0
 */
+ (NSInteger)numberOfLinesForMessage:(NSString *)text;

@end
