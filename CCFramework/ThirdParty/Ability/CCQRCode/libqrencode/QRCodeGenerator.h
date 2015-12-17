//
// QR Code Generator - generates UIImage from NSString
//
// Copyright (C) 2012 http://moqod.com Andrew Kopanev <andrew@moqod.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
// PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
// FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//
// 自定义枚举
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef enum {
    QRPointRect = 0,
    QRPointRound
} QRPointType;

typedef enum {
    QRPositionNormal = 0,
    QRPositionRound
} QRPositionType;

@interface QRCodeGenerator : NSObject

/**
 *  @author C C, 2015-12-17
 *  
 *  @brief  二维码生成
 *
 *  @param string 地址
 *  @param size   大小
 *
 *  @return 返回二维码
 */

+ (UIImage *)qrImageForString:(NSString *)string
                    imageSize:(CGFloat)size;

/**
 *  @author C C, 2015-12-17
 *  
 *  @brief  二维码生成
 *
 *  @param string 地址
 *  @param size   大小
 *  @param topimg 居中图片
 *
 *  @return 返回二维码
 */
+ (UIImage *)qrImageForString:(NSString *)string
                    imageSize:(CGFloat)size
                       Topimg:(UIImage *)topimg;

+ (UIImage *)qrImageForString:(NSString *)string
                    imageSize:(CGFloat)size
                withPointType:(QRPointType)pointType
             withPositionType:(QRPositionType)positionType
                    withColor:(UIColor *)color;
/**
 *  @author C C, 2015-12-17
 *  
 *  @brief  二维码生成
 *
 *  @param string 地址
 *  @param size   大小
 *  @param topimg 中间图片
 *  @param color  颜色
 *
 *  @return 返回验证码图片
 */
+ (UIImage *)qrImageForString:(NSString *)string
                    imageSize:(CGFloat)size
                       Topimg:(UIImage *)topimg
                    withColor:(UIColor *)color;

@end
