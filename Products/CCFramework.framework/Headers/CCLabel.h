//
//  CCLabel.h
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

typedef NS_ENUM(NSUInteger, CCVerticalAlignment){
    /**Align text to the top edge of label.*/
    CCVerticalAlignmentTop,
    /**Align text to rhe middle of label.*/
    CCVerticalAlignmentCenter,
    /**Align text to the bottom edge of label.*/
    CCVerticalAlignmentBottom,
};

@interface CCLabel : UILabel

/**
 *  @author CC, 2015-07-31
 *
 *  @brief  插图从标签到文本的边缘。
 *
 *  @since 1.0
 */
@property (nonatomic, assign) UIEdgeInsets edgeInsets;

/**
 *  @author CC, 2015-07-31
 *
 *  @brief  Vertical text alignment mode.
 *
 *  @since 1.0
 */
@property (nonatomic, assign) CCVerticalAlignment verticalAlignment;

/**
 *  @author CC, 2015-07-31
 *
 *  @brief  计算任意文本给定宽度的高度。
 *
 *  @param width 鉴于宽度文本块来计算高度。
 *  @param text  文字高度计算。可以的NSString或NSAttributedString。
 *  @param font  字体为给定的文本。只有当使用文字是NSString类的。
 *
 *  @return 给定文本的宽度给予高度。
 *
 *  @since 1.0
 */
+ (CGFloat)heightForWidth:(CGFloat)width text:(id)text font:(UIFont *)font;

/**
 *  @author CC, 2015-07-31
 *
 *  @brief  初始化并返回与指定的矩形框边缘和插图新分配的标签对象。
 *
 *  @param frame      该框架矩形的标签，以点为单位。
 *  @param edgeInsets 几何填充为标签视图中的文本，以点为单位。
 *
 *  @return 一个初始化的视图对象，或零如果无法创建的对象。
 *
 *  @since 1.0
 */
- (instancetype)initWithFrame:(CGRect)frame edgeInsets:(UIEdgeInsets)edgeInsets NS_DESIGNATED_INITIALIZER;

/**
 *  @author CC, 2015-07-31
 *
 *  @brief  计算接收器的`frame`矩形的当前文本和给定的宽度高度。
 *
 *  @param width 宽度reciiver`frame`矩形来计算高度，在分。
 *
 *  @return 在点来计算的高度。
 *
 *  @since 1.0
 */
- (CGFloat)heightForWidth:(CGFloat)width;

/**
 *  @author CC, 2015-07-31
 *
 *  @brief  计算接收器的`frame`矩形的当前文本和给定的宽度和改变`frame`的大小此值的高度。
 *
 *  @param width 宽度reciiver`frame`矩形来计算高度，在分。
 *
 *  @return 在点来计算的高度。
 *
 *  @since 1.0
 */
- (CGFloat)heightAdjustedForWidth:(CGFloat)width;


@end
