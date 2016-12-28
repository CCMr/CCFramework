//
//  UIImage+Additions.h
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

@interface UIImage (Additions)

#pragma mark -
#pragma mark :. Additions
- (UIImage *)applyLightEffect;
- (UIImage *)applyExtraLightEffect;
- (UIImage *)applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;

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
- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius
                       tintColor:(UIColor *)tintColor
           saturationDeltaFactor:(CGFloat)saturationDeltaFactor
                       maskImage:(UIImage *)maskImage;


/**
 *  压缩上传图片到指定字节
 *
 *  @param image     压缩的图片
 *  @param maxLength 压缩后最大字节大小
 *
 *  @return 压缩后图片的二进制
 */
+ (NSData *)compressImage:(UIImage *)image
              toMaxLength:(NSInteger)maxLength
                 maxWidth:(NSInteger)maxWidth;

/**
 *  获得指定size的图片
 *
 *  @param image   原始图片
 *  @param newSize 指定的size
 *
 *  @return 调整后的图片
 */
+ (UIImage *)resizeImage:(UIImage *)image
             withNewSize:(CGSize)newSize;

/**
 *  通过指定图片最长边，获得等比例的图片size
 *
 *  @param image       原始图片
 *  @param imageLength 图片允许的最长宽度（高度）
 *
 *  @return 获得等比例的size
 */
+ (CGSize)scaleImage:(UIImage *)image
          withLength:(CGFloat)imageLength;

///对指定图片进行拉伸
+ (UIImage *)resizableImage:(NSString *)name;


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

- (UIImage *)imageCroppedToRect:(CGRect)rect;
- (UIImage *)imageScaledToSize:(CGSize)size;
- (UIImage *)imageScaledToFitSize:(CGSize)size;
- (UIImage *)imageScaledToFillSize:(CGSize)size;
- (UIImage *)imageCroppedAndScaledToSize:(CGSize)size
                             contentMode:(UIViewContentMode)contentMode
                                padToFit:(BOOL)padToFit;

- (UIImage *)reflectedImageWithScale:(CGFloat)scale;
- (UIImage *)imageWithReflectionWithScale:(CGFloat)scale gap:(CGFloat)gap alpha:(CGFloat)alpha;
- (UIImage *)imageWithShadowColor:(UIColor *)color offset:(CGSize)offset blur:(CGFloat)blur;
- (UIImage *)imageWithCornerRadius:(CGFloat)radius;
- (UIImage *)imageWithAlpha:(CGFloat)alpha;
- (UIImage *)imageWithMask:(UIImage *)maskImage;

- (UIImage *)maskImageFromImageAlpha;

#pragma mark -
#pragma mark :. 微信群组图标
+ (UIImage *)groupIcon:(NSArray *)array;
+ (UIImage *)groupIcon:(NSArray *)array
               bgColor:(UIColor *)bgColor;

#pragma mark :. QQ群组图标

#pragma mark :. 识别二维码

/**
 解析二维码
 */
- (NSString *)analysisQRCode;

#pragma mark :. 毛玻璃效果
/**
 *  @author CC, 2015-07-31
 *
 *  @brief  随着模糊
 */
- (UIImage *)imageWithBlur;

#pragma mark -
#pragma mark :. CCRounded

- (UIImage *)createRoundedWithRadius:(CGFloat)radius;


#pragma mark -
#pragma mark :. Data

/**
 *  @author CC, 15-08-27
 *
 *  @brief  Image转data
 *
 *  @return 返回ImageData
 */
- (NSData *)data;

/**
 *  @author CC, 15-08-27
 *
 *  @brief  Image转base64位字符串
 *
 *  @return 返回Image字符串
 */
- (NSString *)base64;

/**
 *  @author CC, 15-08-27
 *
 *  @brief  Image压缩转base64位字符串
 *
 *  @param targetSize 压缩图片大小
 */
- (NSString *)base64:(CGSize)targetSize;

/**
 *  @author CC, 15-08-27
 *
 *  @brief  Image压缩转base64位字符串
 *
 *  @param size    压缩图片大小
 *  @param percent 压缩比例
 */
- (NSString *)baset64:(CGSize)size
              Percent:(float)percent;

#pragma mark -
#pragma mark :. Utility

+ (UIImage *)fastImageWithData:(NSData *)data;
+ (UIImage *)fastImageWithContentsOfFile:(NSString *)path;

/**
 读取document下图片
 结构本地路/文件路径
 
 @param path document路径
 */
+ (UIImage *)documentFolderWithContentsOfFile:(NSString *)path;

#pragma mark -
#pragma mark :. Alpha

/**
 *  @brief  是否有alpha通道
 *
 *  @return 是否有alpha通道
 */
- (BOOL)hasAlpha;
/**
 *  @brief  如果没有alpha通道 增加alpha通道
 *
 *  @return 如果没有alpha通道 增加alpha通道
 */
- (UIImage *)imageWithAlpha;
/**
 *  @brief  增加透明边框
 *
 *  @param borderSize 边框尺寸
 *
 *  @return 增加透明边框后的图片
 */
- (UIImage *)transparentBorderImage:(NSUInteger)borderSize;

/**
 *  @brief  裁切含透明图片为最小大小
 *
 *  @return 裁切后的图片
 */
- (UIImage *)trimmedBetterSize;

#pragma mark -
#pragma mark :. GIF

/*
 UIImage *animation = [UIImage animatedImageWithAnimatedGIFData:theData];
 
 I interpret `theData` as a GIF.  I create an animated `UIImage` using the source images in the GIF.
 
 The GIF stores a separate duration for each frame, in units of centiseconds (hundredths of a second).  However, a `UIImage` only has a single, total `duration` property, which is a floating-point number.
 
 To handle this mismatch, I add each source image (from the GIF) to `animation` a varying number of times to match the ratios between the frame durations in the GIF.
 
 For example, suppose the GIF contains three frames.  Frame 0 has duration 3.  Frame 1 has duration 9.  Frame 2 has duration 15.  I divide each duration by the greatest common denominator of all the durations, which is 3, and add each frame the resulting number of times.  Thus `animation` will contain frame 0 3/3 = 1 time, then frame 1 9/3 = 3 times, then frame 2 15/3 = 5 times.  I set `animation.duration` to (3+9+15)/100 = 0.27 seconds.
 */
+ (UIImage *)animatedImageWithAnimatedGIFData:(NSData *)theData;

/*
 UIImage *image = [UIImage animatedImageWithAnimatedGIFURL:theURL];
 
 I interpret the contents of `theURL` as a GIF.  I create an animated `UIImage` using the source images in the GIF.
 
 I operate exactly like `+[UIImage animatedImageWithAnimatedGIFData:]`, except that I read the data from `theURL`.  If `theURL` is not a `file:` URL, you probably want to call me on a background thread or GCD queue to avoid blocking the main thread.
 */
+ (UIImage *)animatedImageWithAnimatedGIFURL:(NSURL *)theURL;

+ (UIImage *)cc_animatedGIFNamed:(NSString *)name;

+ (UIImage *)cc_animatedGIFWithData:(NSData *)data;

- (UIImage *)cc_animatedImageByScalingAndCroppingToSize:(CGSize)size;

#pragma mark -
#pragma mark :. BetterFace

typedef NS_ENUM(NSUInteger, CCAccuracy) {
    kCCAccuracyLow = 0,
    kCCAccuracyHigh,
};

- (UIImage *)betterFaceImageForSize:(CGSize)size
                           accuracy:(CCAccuracy)accurary;

#pragma mark -
#pragma mark :. Capture

/**
 *  @brief  截图指定view成图片
 *
 *  @param view 一个view
 *
 *  @return 图片
 */
+ (UIImage *)captureWithView:(UIView *)view;

///截图（未测试是否可行）
+ (UIImage *)getImageWithSize:(CGRect)myImageRect
                    FromImage:(UIImage *)bigImage;

/**
 *  @author Jakey
 *
 *  @brief  截图一个view中所有视图 包括旋转缩放效果
 *
 *  @param aView    指定的view
 *  @param maxWidth 宽的大小 0为view默认大小
 *
 *  @return 截图
 */
+ (UIImage *)screenshotWithView:(UIView *)aView
                     limitWidth:(CGFloat)maxWidth;


#pragma mark -
#pragma mark :. Color

/**
 *  @brief  根据颜色生成纯色图片
 *
 *  @param color 颜色
 *
 *  @return 纯色图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

/**
 *  @brief  取图片某一点的颜色
 *
 *  @param point 某一点
 *
 *  @return 颜色
 */
- (UIColor *)colorAtPoint:(CGPoint)point;

//more accurate method ,colorAtPixel 1x1 pixel
/**
 *  @brief  取某一像素的颜色
 *
 *  @param point 一像素
 *
 *  @return 颜色
 */
- (UIColor *)colorAtPixel:(CGPoint)point;

/**
 *  @brief  返回该图片是否有透明度通道
 *
 *  @return 是否有透明度通道
 */
- (BOOL)hasAlphaChannel;

/**
 *  @brief  获得灰度图
 *
 *  @param sourceImage 图片
 *
 *  @return 获得灰度图片
 */
+ (UIImage *)covertToGrayImageFromImage:(UIImage *)sourceImage;


#pragma mark -
#pragma mark :. FileName

/**
 *  @brief  根据bundle中的文件名读取图片
 *
 *  @param name 图片名
 *
 *  @return 无缓存的图片
 */
+ (UIImage *)imageWithFileName:(NSString *)name;


#pragma mark -
#pragma mark :. Merge

/**
 *  @brief  合并两个图片
 *
 *  @param firstImage  一个图片
 *  @param secondImage 二个图片
 *
 *  @return 合并后图片
 */
+ (UIImage *)mergeImage:(UIImage *)firstImage
              withImage:(UIImage *)secondImage;

#pragma mark -
#pragma mark :. Orientation

/**
 *  @brief  修正图片的方向
 *
 *  @param srcImg 图片
 *
 *  @return 修正方向后的图片
 */
+ (UIImage *)fixOrientation:(UIImage *)srcImg;
- (UIImage *)normalizedImage;
/**
 *  @brief  旋转图片
 *
 *  @param degrees 角度
 *
 *  @return 旋转后图片
 */
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

/**
 *  @brief  旋转图片
 *
 *  @param degrees 弧度
 *
 *  @return 旋转后图片
 */
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;

- (UIImage *)rotateByAngle:(CGFloat)angleInRadians;

/**
 *  @brief  垂直翻转
 *
 *  @return  翻转后的图片
 */
- (UIImage *)flipVertical;
/**
 *  @brief  水平翻转
 *
 *  @return 翻转后的图片
 */
- (UIImage *)flipHorizontal;

/**
 *  @brief  角度转弧度
 *
 *  @param degrees 角度
 *
 *  @return 弧度
 */
+ (CGFloat)degreesToRadians:(CGFloat)degrees;
/**
 *  @brief  弧度转角度
 *
 *  @param radians 弧度
 *
 *  @return 角度
 */
+ (CGFloat)radiansToDegrees:(CGFloat)radians;

// Convolution Oprations
- (UIImage *)gaussianBlur;
- (UIImage *)edgeDetection;
- (UIImage *)emboss;
- (UIImage *)sharpen;
- (UIImage *)unsharpen;

// Geometric Operations
- (UIImage *)rotateInRadians:(float)radians;

// Morphological Operations
- (UIImage *)dilate;
- (UIImage *)erode;
- (UIImage *)dilateWithIterations:(int)iterations;
- (UIImage *)erodeWithIterations:(int)iterations;
- (UIImage *)gradientWithIterations:(int)iterations;
- (UIImage *)tophatWithIterations:(int)iterations;
- (UIImage *)blackhatWithIterations:(int)iterations;

// Histogram Operations
- (UIImage *)equalization;

- (UIImage *)imageBlendedWithImage:(UIImage *)overlayImage
                         blendMode:(CGBlendMode)blendMode
                             alpha:(CGFloat)alpha;

#pragma mark -
#pragma mark :. RemoteSize

/**
 *  @brief 获取远程图片的大小
 *
 *  @param imgURL     图片url
 *  @param completion 完成回调
 */
+ (void)requestSizeNoHeader:(NSURL *)imgURL
                 completion:(void (^)(NSURL *imgURL, CGSize size))completion;

/**
 *  @brief  从header中获取远程图片的大小 (服务器必须支持)
 *
 *  @param imgURL     图片url
 *  @param completion 完成回调
 */
+ (void)requestSizeWithHeader:(NSURL *)imgURL
                   completion:(void (^)(NSURL *imgURL, CGSize size))completion;


#pragma mark -
#pragma mark :. ResizePrivateMethods

- (UIImage *)croppedImage:(CGRect)bounds;
- (UIImage *)thumbnailImage:(NSInteger)thumbnailSize
          transparentBorder:(NSUInteger)borderSize
               cornerRadius:(NSUInteger)cornerRadius
       interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;

#pragma mark -
#pragma mark :. RoundedCorner

- (UIImage *)roundedCornerImage:(NSInteger)cornerSize
                     borderSize:(NSInteger)borderSize;

#pragma mark -
#pragma mark :. Vector

/**
 Create a UIImage from an icon font.
 @param font The icon font.
 @param iconNamed The name of the icon in the font.
 @param tintColor The tint color to use for the icon. Defaults to black.
 @param clipToBounds If YES the image will be clipped to the pixel bounds of the icon.
 @param fontSize The font size to draw the icon at.
 @return The resulting image.
 */
+ (UIImage *)iconWithFont:(UIFont *)font named:(NSString *)iconNamed
            withTintColor:(UIColor *)tintColor
             clipToBounds:(BOOL)clipToBounds
                  forSize:(CGFloat)fontSize;

/**
 Create a UIImage from a PDF icon.
 @param pdfNamed The name of the PDF file in the application's resources directory.
 @param height The height of the resulting image, the width will be based on the aspect ratio of the PDF.
 @return The resulting image.
 */
+ (UIImage *)imageWithPDFNamed:(NSString *)pdfNamed
                     forHeight:(CGFloat)height;

/**
 Create a UIImage from a PDF icon.
 @param pdfNamed The name of the PDF file in the application's resources directory.
 @param tintColor The tint color to use for the icon. If nil no tint color will be used.
 @param height The height of the resulting image, the width will be based on the aspect ratio of the PDF.
 @return The resulting image.
 */
+ (UIImage *)imageWithPDFNamed:(NSString *)pdfNamed
                 withTintColor:(UIColor *)tintColor
                     forHeight:(CGFloat)height;

/**
 Create a UIImage from a PDF icon.
 @param pdfFile The path of the PDF file.
 @param tintColor The tint color to use for the icon. If nil no tint color will be used.
 @param maxSize The maximum size the resulting image can be. The image will maintain it's aspect ratio and may not encumpas the full size.
 @return The resulting image.
 */
+ (UIImage *)imageWithPDFFile:(NSString *)pdfFile
                withTintColor:(UIColor *)tintColor
                      forSize:(CGSize)size;

@end
