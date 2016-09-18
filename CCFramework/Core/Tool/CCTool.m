//
//  CCTool.m
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
#import "CCTool.h"
#import "CCVoiceCommonHelper.h"

@implementation CCTool

/**
 *  @author CC, 2015-12-02
 *
 *  @brief  获取音频时长
 *
 *  @param recordPath 音频名称
 */
+ (NSString *)obtainVoiceDuration:(NSString *)recordPath
{
    NSString *recordDuration;
    NSError *error = nil;
    NSString *path = [CCVoiceCommonHelper getPathByFileName:recordPath ofType:@"wav"];
    AVAudioPlayer *play = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
    if (error) {
        recordDuration = @"";
    } else {
        recordDuration = [NSString stringWithFormat:@"%.1f", play.duration];
    }
    return recordDuration;
}

/**
 *  @author CC, 2015-12-04
 *
 *  @brief  等比尺寸
 *
 *  @param image 图片
 *  @param size  大小
 */
+ (CGRect)neededSizeForPhoto:(UIImage *)image
                        Size:(CGSize)size
{
    CGFloat width = CGImageGetWidth(image.CGImage);
    CGFloat height = CGImageGetHeight(image.CGImage);

    float verticalRadio = size.height * 1.0 / height;
    float horizontalRadio = size.width * 1.0 / width;

    float radio = 1;
    if (verticalRadio > 1 && horizontalRadio > 1) {
        radio = verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio;
    } else {
        radio = verticalRadio > horizontalRadio ? verticalRadio : horizontalRadio;
    }

    width = width * radio;
    height = height * radio;

    int xPos = (size.width - width) / 2;
    int yPos = (size.height - height) / 2;

    return CGRectMake(xPos, yPos, width, height);
}

/**
 *  @author CC, 16-09-14
 *
 *  @brief 等比缩放大小
 *
 *  @param photoSize 图片大小
 *  @param size      规定大小
 */
+ (CGSize)neededSizeForSize:(CGSize)photoSize
                       Size:(CGSize)size
{
    float verticalRadio = size.height * 1.0 / photoSize.height;
    float horizontalRadio = size.width * 1.0 / photoSize.width;

    float radio = 1;
    if (verticalRadio > 1 && horizontalRadio > 1) {
        radio = verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio;
    } else {
        radio = verticalRadio > horizontalRadio ? verticalRadio : horizontalRadio;
    }

    return CGSizeMake(photoSize.width * radio, photoSize.height * radio);
}

/**
 *  @author CC, 2015-12-04
 *
 *  @brief  等比修改图片
 *
 *  @param image 图片
 *  @param size  等比尺寸
 */
+ (UIImage *)scale:(UIImage *)image
              Size:(CGSize)size
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);

    // 绘制改变大小的图片
    [image drawInRect:[self neededSizeForPhoto:image Size:size]];

    // 从当前context中创建一个改变大小后的图片
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();

    // 使当前的context出堆栈
    UIGraphicsEndImageContext();

    // 返回新的改变大小后的图片
    return scaledImage;
}

@end
