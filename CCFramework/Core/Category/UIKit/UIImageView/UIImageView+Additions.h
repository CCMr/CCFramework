//
//  UIImageView+Additions.h
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
#import "SDWebImageCompat.h"
#import "SDWebImageManager.h"

typedef void(^CCImageCompletionBlock)(UIImage *image, NSError *error, NSURL *imageURL);

@interface UIImageView (Additions)

#pragma mark -
#pragma mark :. Additions
/**
 *  @brief  根据bundle中的图片名创建imageview
 *
 *  @param imageName bundle中的图片名
 *
 *  @return imageview
 */
+ (id)imageViewWithImageNamed:(NSString *)imageName;

/**
 *  @brief  根据frame创建imageview
 *
 *  @param frame imageview frame
 *
 *  @return imageview
 */
+ (id)imageViewWithFrame:(CGRect)frame;

+ (id)imageViewWithStretchableImage:(NSString *)imageName
                              Frame:(CGRect)frame;
/**
 *  @brief  创建imageview动画
 *
 *  @param imageArray 图片名称数组
 *  @param duration   动画时间
 *
 *  @return imageview
 */
+ (id)imageViewWithImageArray:(NSArray *)imageArray
                     duration:(NSTimeInterval)duration;
- (void)setImageWithStretchableImage:(NSString *)imageName;


// 画水印
// 图片水印
- (void)setImage:(UIImage *)image
   withWaterMark:(UIImage *)mark
          inRect:(CGRect)rect;
// 文字水印
- (void)setImage:(UIImage *)image
withStringWaterMark:(NSString *)markString
          inRect:(CGRect)rect
           color:(UIColor *)color
            font:(UIFont *)font;

- (void)setImage:(UIImage *)image
withStringWaterMark:(NSString *)markString
         atPoint:(CGPoint)point
           color:(UIColor *)color
            font:(UIFont *)font;

/**
 *  @author C C, 2015-10-14
 *
 *  @brief  网络异步请求
 *
 *  @param url         请求地址
 *  @param placeholder 默认图片
 */
- (void)setImageWithURL:(NSString *)url
            placeholder:(UIImage *)placeholder;

+ (void)LoadImageWithURL:(NSString *)url
                Complete:(void (^)(UIImage *images))block;

#pragma mark -
#pragma mark :. BetterFace

@property(nonatomic) BOOL needsBetterFace;
@property(nonatomic) BOOL fast;

void hack_uiimageview_bf();
- (void)setBetterFaceImage:(UIImage *)image;

#pragma mark -
#pragma mark :. FaceAwareFill

//Ask the image to perform an "Aspect Fill" but centering the image to the detected faces
//Not the simple center of the image
- (void)faceAwareFill;

#pragma mark -
#pragma mark :. GeometryConversion

- (CGPoint)convertPointFromImage:(CGPoint)imagePoint;
- (CGRect)convertRectFromImage:(CGRect)imageRect;

- (CGPoint)convertPointFromView:(CGPoint)viewPoint;
- (CGRect)convertRectFromView:(CGRect)viewRect;

#pragma mark -
#pragma mark :. Letters

/**
 Sets the image property of the view based on initial text. A random background color is automatically generated.

 @param string The string used to generate the initials. This should be a user's full name if available
 */
- (void)setImageWithString:(NSString *)string;

/**
 Sets the image property of the view based on initial text and a specified background color.

 @param string The string used to generate the initials. This should be a user's full name if available
 @param color (optional) This optional paramter sets the background of the image. If not provided, a random color will be generated
 */

- (void)setImageWithString:(NSString *)string
                     color:(UIColor *)color;

/**
 Sets the image property of the view based on initial text, a specified background color, and a circular clipping

 @param string The string used to generate the initials. This should be a user's full name if available
 @param color (optional) This optional paramter sets the background of the image. If not provided, a random color will be generated
 @param isCircular This boolean will determine if the image view will be clipped to a circular shape
 */
- (void)setImageWithString:(NSString *)string
                     color:(UIColor *)color
                  circular:(BOOL)isCircular;

/**
 Sets the image property of the view based on initial text, a specified background color, a custom font, and a circular clipping

 @param string The string used to generate the initials. This should be a user's full name if available
 @param color (optional) This optional paramter sets the background of the image. If not provided, a random color will be generated
 @param isCircular This boolean will determine if the image view will be clipped to a circular shape
 @param fontName This will use a custom font attribute. If not provided, it will default to system font
 */
- (void)setImageWithString:(NSString *)string
                     color:(UIColor *)color
                  circular:(BOOL)isCircular
                  fontName:(NSString *)fontName;

/**
 Sets the image property of the view based on initial text, a specified background color, custom text attributes, and a circular clipping

 @param string The string used to generate the initials. This should be a user's full name if available
 @param color (optional) This optional paramter sets the background of the image. If not provided, a random color will be generated
 @param isCircular This boolean will determine if the image view will be clipped to a circular shape
 @param textAttributes This dictionary allows you to specify font, text color, shadow properties, etc., for the letters text, using the keys found in NSAttributedString.h
 */
- (void)setImageWithString:(NSString *)string
                     color:(UIColor *)color
                  circular:(BOOL)isCircular
            textAttributes:(NSDictionary *)textAttributes;


#pragma mark -
#pragma mark :. Reflect

/**
 *  @brief  倒影
 */
- (void)reflect;

#pragma mark - 2G/3G/4G点击加载图片、WIFI自动加载

/**
 *  @author CC, 16-08-23
 *
 *  @brief 加载完成后 给图片设置的contentMode
 */
@property UIViewContentMode loadedViewContentMode;

/**
 *  @author CC, 16-08-23
 *
 *  @brief 图片点击事件  不用再手动添加UITapGestureRecognizer
 */
@property(nonatomic, copy) void (^onTouchTapBlock)(UIImageView *imageView);

/**
 *  @author CC, 16-08-23
 *
 *  @brief 网络判断加载图片
 *
 *  @param url         图片请求网址
 *  @param placeholder 默认图片
 */
- (void)cc_setImageWithURL:(NSURL *)url
          placeholderImage:(UIImage *)placeholder;

/**
 *  @author CC, 16-08-23
 *
 *  @brief 网络判断加载图片
 *
 *  @param url              图片请求网址
 *  @param placeholder      默认图片
 *  @param errorPlaceholder 错误图片
 */
- (void)cc_setImageWithURL:(NSURL *)url
          placeholderImage:(UIImage *)placeholder
     ErrorPlaceholderImage:(UIImage *)errorPlaceholder;

/**
 *  @author CC, 16-08-23
 *
 *  @brief 网络判断加载图片
 *
 *  @param urlString   图片地址
 *  @param placeholder 默认图片
 */
- (void)cc_setImageWithURLStr:(NSString *)urlString
             placeholderImage:(UIImage *)placeholder;

- (void)cc_setImageWithURLStr:(NSURL *)url
             placeholderImage:(UIImage *)placeholder 
              completionBlock:(CCImageCompletionBlock)block;

/**
 *  @author CC, 16-08-23
 *
 *  @brief 网络判断加载图片
 *
 *  @param urlString        图片地址
 *  @param placeholder      默认图片
 *  @param errorPlaceholder 错图图片
 */
- (void)cc_setImageWithURLStr:(NSString *)urlString
             placeholderImage:(UIImage *)placeholder
        ErrorPlaceholderImage:(UIImage *)errorPlaceholder;

@end
