//
//  UIImage+BUIImage.h
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

@interface UIImage (BUIImage)

/**
 *  @author CC, 2015-07-22 16:07:57
 *
 *  @brief  算压缩比例
 *
 *  @param targetSize 压缩比例
 */
- (UIImage *)compression:(CGSize)targetSize;


/**
 *  @author CC, 2015-12-22
 *  
 *  @brief  动态图片压缩
 *
 *  @param sourceImage 原图片
 *
 *  @return 返回图片
 */
- (UIImage *)resetSizeOfImage;

/**
 *  @author CC, 2015-07-22 16:07:55
 *
 *  @brief  压缩返回数据图片
 *
 *  @param size    压缩图片大小
 *  @param percent 压缩比例
 */
- (UIImage *)compressionData:(CGSize)size
                     Percent:(float)percent;

/**
 *  @author CC, 2015-12-23
 *  
 *  @brief  动态图片压缩
 *
 *  @param sourceImage 原图
 *  @param maxSize     限定图片大小
 *
 *  @return 返回data数据
 */
- (NSData *)resetSizeOfImageDataWithMaxSize:(NSInteger)maxSize;

#pragma mark - 毛玻璃效果
/**
 *  @author CC, 2015-07-31
 *
 *  @brief  模糊背景
 *
 *  @param alpha                 透明度 0~1,  0为白,   1为深灰色
 *  @param radius                默认30,推荐值 3   半径值越大越模糊 ,值越小越清楚
 *  @param colorSaturationFactor 色彩饱和度(浓度)因子:  0是黑白灰, 9是浓彩色, 1是原色  默认1.8
 *                               “彩度”，英文是称Saturation，即饱和度。将无彩色的黑白灰定为0，最鲜艳定为9s，这样大致分成十阶段，让数值和人的感官直觉一致。
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (UIImage *)imageWithLightAlpha:(CGFloat)alpha
                          radius:(CGFloat)radius
           colorSaturationFactor:(CGFloat)colorSaturationFactor;

/**
 *  @author CC, 2015-07-31
 *
 *  @brief  随着模糊
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (UIImage *)imageWithBlur;

@end
