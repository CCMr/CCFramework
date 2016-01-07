//
//  UIImage+BUIImage.m
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

#import "UIImage+BUIImage.h"
#import <Accelerate/Accelerate.h>

@implementation UIImage (BUIImage)

/**
 *  @author CC, 2015-07-22 16:07:57
 *
 *  @brief  算压缩比例
 *
 *  @param targetSize 压缩比例
 */
- (UIImage *)compression:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor > heightFactor)
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        else if (widthFactor < heightFactor)
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if (newImage == nil)
        NSLog(@"could not scale image");
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
}

/**
 *  @author CC, 2015-12-22
 *  
 *  @brief  动态图片压缩
 *
 *  @param sourceImage 原图片
 *
 *  @return 返回图片
 */
- (UIImage *)resetSizeOfImage
{
    //先调整分辨率
    CGSize newSize = CGSizeMake(self.size.width, self.size.height);
    
    CGFloat tempHeight = newSize.height / 1024;
    CGFloat tempWidth = newSize.width / 1024;
    
    if (tempWidth > 1.0 && tempWidth > tempHeight) {
        newSize = CGSizeMake(self.size.width / tempWidth, self.size.height / tempWidth);
    } else if (tempHeight > 1.0 && tempWidth < tempHeight) {
        newSize = CGSizeMake(self.size.width / tempHeight, self.size.height / tempHeight);
    }
    
    return [self compression:CGSizeMake(newSize.width, newSize.height)];
}

/**
 *  @author CC, 2015-07-22 16:07:55
 *
 *  @brief  压缩返回数据图片
 *
 *  @param size    压缩图片大小
 *  @param percent 压缩比例
 */
- (UIImage *)compressionData:(CGSize)size
                     Percent:(float)percent
{
    UIImage *images = self;
    images = [images compression:size];
    UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *ImageData = UIImagePNGRepresentation(thumbImage);
    if (percent > 0)
        ImageData = UIImageJPEGRepresentation(thumbImage, percent);
    
    return [UIImage imageWithData:ImageData];
}

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
- (NSData *)resetSizeOfImageDataWithMaxSize:(NSInteger)maxSize
{
    //调整大小
    NSData *imageData = UIImageJPEGRepresentation(self, 1.0);
    NSUInteger sizeOrigin = [imageData length];
    NSUInteger sizeOriginKB = sizeOrigin / 1024;
    
    if (sizeOriginKB > maxSize) {
        float kMaxSize = maxSize;
        float kSizeOriginKB = (float)sizeOriginKB;
        float scale = sqrtf(kMaxSize / kSizeOriginKB);
        
        CGSize sizeImage = [self size];
        CGFloat widthSmall = sizeImage.width * scale;
        CGFloat heighSmall = sizeImage.height * scale;
        CGSize sizeImageSmall = CGSizeMake(widthSmall, heighSmall);
        
        UIImage *compressionImage = [self compression:sizeImageSmall];
        imageData = UIImageJPEGRepresentation(compressionImage, 1.0);
    };
    
    return imageData;
}

#pragma mark - 模糊效果
/**
 *  @author CC, 2015-07-31
 *
 *  @brief  随着模糊
 */
- (UIImage *)imageWithBlur
{
    return [self imageWithLightAlpha:0.1
                              radius:15
               colorSaturationFactor:1];
}

/**
 *  @author CC, 2015-07-31
 *
 *  @brief  模糊背景
 *
 *  @param alpha                 透明度 0~1,  0为白,   1为深灰色
 *  @param radius                默认30,推荐值 3   半径值越大越模糊 ,值越小越清楚
 *  @param colorSaturationFactor 色彩饱和度(浓度)因子:  0是黑白灰, 9是浓彩色, 1是原色  默认1.8
 *                               “彩度”，英文是称Saturation，即饱和度。将无彩色的黑白灰定为0，最鲜艳定为9s，这样大致分成十阶段，让数值和人的感官直觉一致。
 */
- (UIImage *)imageWithLightAlpha:(CGFloat)alpha
                          radius:(CGFloat)radius
           colorSaturationFactor:(CGFloat)colorSaturationFactor
{
    UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:alpha];
    
    return [self imageBluredWithRadius:radius
                             tintColor:tintColor
                 saturationDeltaFactor:colorSaturationFactor
                             maskImage:nil];
}

/**
 *  @author CC, 2015-07-31
 *
 *  @brief  内部方法,核心代码,封装了毛玻璃效果 参数:半径,颜色,色彩饱和度
 *
 *  @param blurRadius            默认30,推荐值 3   半径值越大越模糊 ,值越小越清楚
 *  @param tintColor             <#tintColor description#>
 *  @param saturationDeltaFactor 色彩饱和度(浓度)因子:  0是黑白灰, 9是浓彩色, 1是原色  默认1.8
 *                               “彩度”，英文是称Saturation，即饱和度。将无彩色的黑白灰定为0，最鲜艳定为9s，这样大致分成十阶段，让数值和人的感官直觉一致。
 *  @param maskImage             <#maskImage description#>
 
 */
- (UIImage *)imageBluredWithRadius:(CGFloat)blurRadius
                         tintColor:(UIColor *)tintColor
             saturationDeltaFactor:(CGFloat)saturationDeltaFactor
                         maskImage:(UIImage *)maskImage
{
    
    CGRect imageRect = {CGPointZero, self.size};
    UIImage *effectImage = self;
    
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    if (hasBlur || hasSaturationChange) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -self.size.height);
        CGContextDrawImage(effectInContext, imageRect, self.CGImage);
        
        vImage_Buffer effectInBuffer;
        effectInBuffer.data = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        
        if (hasBlur) {
            CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
            uint32_t radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1; // force radius to be odd so that the three box-blur methodology works.
            }
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
        }
        BOOL effectImageBuffersAreSwapped = NO;
        if (hasSaturationChange) {
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s, 0.0722 - 0.0722 * s, 0.0722 - 0.0722 * s, 0,
                0.7152 - 0.7152 * s, 0.7152 + 0.2848 * s, 0.7152 - 0.7152 * s, 0,
                0.2126 - 0.2126 * s, 0.2126 - 0.2126 * s, 0.2126 + 0.7873 * s, 0,
                0, 0, 0, 1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix) / sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            if (hasBlur) {
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
            } else {
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        if (!effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // 开启上下文 用于输出图像
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.size.height);
    
    // 开始画底图
    CGContextDrawImage(outputContext, imageRect, self.CGImage);
    
    // 开始画模糊效果
    if (hasBlur) {
        CGContextSaveGState(outputContext);
        if (maskImage) {
            CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
        }
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    
    // 添加颜色渲染
    if (tintColor) {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    
    // 输出成品,并关闭上下文
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}


@end
