//
//  UILabel+Additions.h
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
#import <CoreText/CoreText.h>

@interface UILabel (Additions)

#pragma mark -
#pragma mark :. Additions
/**
 *  @author CC, 15-09-25
 *
 *  @brief  设置CellLabel背景颜色
 *
 *  @param color 颜色值
 */
- (void)cellLabelSetColor:(UIColor *)color;

#pragma mark -
#pragma mark :. AutomaticWriting

typedef NS_ENUM(NSInteger, UILabelCCBlinkingMode) {
    UILabelCCBlinkingModeNone,
    UILabelCCBlinkingModeUntilFinish,
    UILabelCCBlinkingModeUntilFinishKeeping,
    UILabelCCBlinkingModeWhenFinish,
    UILabelCCBlinkingModeWhenFinishShowing,
    UILabelCCBlinkingModeAlways
};


@property(strong, nonatomic) NSOperationQueue *automaticWritingOperationQueue;
@property(assign, nonatomic) UIEdgeInsets edgeInsets;

- (void)setTextWithAutomaticWritingAnimation:(NSString *)text;

- (void)setText:(NSString *)text automaticWritingAnimationWithBlinkingMode:(UILabelCCBlinkingMode)blinkingMode;

- (void)setText:(NSString *)text automaticWritingAnimationWithDuration:(NSTimeInterval)duration;

- (void)setText:(NSString *)text automaticWritingAnimationWithDuration:(NSTimeInterval)duration blinkingMode:(UILabelCCBlinkingMode)blinkingMode;

- (void)setText:(NSString *)text automaticWritingAnimationWithDuration:(NSTimeInterval)duration blinkingMode:(UILabelCCBlinkingMode)blinkingMode blinkingCharacter:(unichar)blinkingCharacter;

- (void)setText:(NSString *)text automaticWritingAnimationWithDuration:(NSTimeInterval)duration blinkingMode:(UILabelCCBlinkingMode)blinkingMode blinkingCharacter:(unichar)blinkingCharacter completion:(void (^)(void))completion;

#pragma mark -
#pragma mark :. CCAdjustableLabel

// General method. If minSize is set to CGSizeZero then
// it is ignored
// =====================================================
- (void)adjustLabelToMaximumSize:(CGSize)maxSize
                     minimumSize:(CGSize)minSize
                 minimumFontSize:(CGFloat)minFontSize;

// Adjust label using only the maximum size and the
// font size as constraints
// =====================================================
- (void)adjustLabelToMaximumSize:(CGSize)maxSize
                 minimumFontSize:(CGFloat)minFontSize;

// Adjust the size of the label using only the font
// size as a constraint (the maximum size will be
// calculated automatically based on the screen size)
// =====================================================
- (void)adjustLabelSizeWithMinimumFontSize:(CGFloat)minFontSize;

// Adjust label without any constraints (the maximum
// size will be calculated automatically based on the
// screen size)
// =====================================================
- (void)adjustLabel;

#pragma mark -
#pragma mark :. SuggestSize

- (CGSize)suggestedSizeForWidth:(CGFloat)width;
- (CGSize)suggestSizeForAttributedString:(NSAttributedString *)string width:(CGFloat)width;
- (CGSize)suggestSizeForString:(NSString *)string width:(CGFloat)width;


#pragma mark -
#pragma mark :. AutoSize

/**
 * 垂直方向固定获取动态宽度的UILabel的方法
 *
 * @return 原始UILabel修改过的Rect的UILabel(起始位置相同)
 */
- (UILabel *)resizeLabelHorizontal;

/**
 *  水平方向固定获取动态宽度的UILabel的方法
 *
 *  @return 原始UILabel修改过的Rect的UILabel(起始位置相同)
 */
- (UILabel *)resizeLabelVertical;

/**
 *  垂直方向固定获取动态宽度的UILabel的方法
 *
 *  @param minimumWidth minimum width
 *
 *  @return 原始UILabel修改过的Rect的UILabel(起始位置相同)
 */
- (UILabel *)resizeLabelHorizontal:(CGFloat)minimumWidth;

/**
 *  水平方向固定获取动态宽度的UILabel的方法
 *
 *  @param minimumHeigh minimum height
 *
 *  @return 原始UILabel修改过的Rect的UILabel(起始位置相同)
 */
- (UILabel *)resizeLabelVertical:(CGFloat)minimumHeigh;

#pragma mark -
#pragma mark :. 图文混排

/**
 *  @author CC, 16-05-27
 *  
 *  @brief  图文混排
 *
 *  @param text         文本内容
 *  @param replaceAry   替换标签
 *  @param teletextPath 图片地址
 *  @param teletextSize 图片大小 
 *                      命名规则 @[@{ @"width" : 20, @"height" : 20}]
 */
- (void)coreTeletext:(NSString *)text
          ReplaceAry:(NSArray<NSString *> *)replaceAry
        TeletextPath:(NSArray<NSString *> *)teletextPath
        teletextSize:(NSArray<NSDictionary *> *)teletextSize;

@end
