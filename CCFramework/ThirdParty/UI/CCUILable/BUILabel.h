//
//  BUILabel.h
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
#import <QuartzCore/QuartzCore.h>

@interface BUILabel : UILabel

/**
 *  @author CC, 2015-07-31
 *
 *  @brief  是否改变文字
 *
 *  @since 1.0
 */
@property (nonatomic) BOOL strikeThroughEnabled;

/**
 *  @author CC, 2015-07-31
 *
 *  @brief  横线显示文字
 *
 *  @param strikeThroughEnabled 是否
 *
 *  @since 1.0
 */
- (void)setStrikeThroughEnabled:(BOOL)strikeThroughEnabled;

/**
 *  @author C C, 2015-10-11
 *
 *  @brief  设置文本位置
 *
 *  @param Alignment 位置
 */
- (void)setAlignmentCenter: (NSTextAlignment)Alignment;

/**
 *  @author C C, 2015-10-11
 *
 *  @brief  设置某段字的颜色
 *
 *  @param color    文字颜色
 *  @param location 开始位置
 *  @param length   结束位置
 */
- (void)setColor: (UIColor *)color
       fromIndex: (NSInteger)location
          length: (NSInteger)length;

/**
 *  @author C C, 2015-10-11
 *
 *  @brief  设置某段字的字体
 *
 *  @param font     文字字体
 *  @param location 开始位置
 *  @param length   结束位置
 */
- (void)setFont: (UIFont *)font
      fromIndex: (NSInteger)location
         length: (NSInteger)length;

/**
 *  @author C C, 2015-10-11
 *
 *  @brief  设置某段字的风格
 *
 *  @param style    文字风格
 *  @param location 开始位置
 *  @param length   结束位置
 */
- (void)setStyle: (CTUnderlineStyle)style
       fromIndex: (NSInteger)location
          length: (NSInteger)length;

/**
 *  @author CC, 2015-06-05 14:06:12
 *
 *  @brief  设置下划线
 *
 *  @param location 开始位置
 *  @param length   结束位置
 *
 *  @since 1.0
 */
- (void)setUnderline: (NSInteger)location
              length: (NSInteger)length;

@end
