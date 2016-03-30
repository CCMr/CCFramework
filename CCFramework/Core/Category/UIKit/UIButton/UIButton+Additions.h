//
//  UIButton+Additions.h
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

@interface UIButton (Additions)

/**
 *  @author C C, 2015-10-01
 *
 *  @brief  设置标题普通与高亮
 *
 *  @param title 标题
 */
- (void)setTitle:(NSString *)title;

/**
 *  @author C C, 2015-10-01
 *
 *  @brief  设置标题文字颜色普通与高亮
 *
 *  @param color 标题颜色
 */
- (void)setTitleColor:(UIColor *)color;

/**
 *  @author C C, 2015-10-02
 *
 *  @brief  设置文本字体
 *
 *  @param font 字体
 */
- (void)setFont:(UIFont *)font;

/**
 *  @author C C, 2015-10-03
 *
 *  @brief  设置上图下文的图片与颜色
 *
 *  @param image 图片
 *  @param color 文字颜色
 */
- (void)setButtonUpImageNextTilte:(NSString *)image
                       TitleColor:(UIColor *)color;

/**
 *  @author CC, 2015-12-09
 *  
 *  @brief  设置按钮图片
 *
 *  @param imagePath 图片路径
 */
- (void)setImage:(NSString *)imagePath;



/**
 *  @author CC, 2015-07-16
 *
 *  @brief  创建按钮
 *
 *  @since 1.0
 */
+ (id)buttonWith;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  标题
 *
 *  @param title 标题
 *
 *  @since 1.0
 */
+ (id)buttonWithTitle:(NSString *)title;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  点击不会改变
 *
 *  @param title 标题
 *  @param image 背景图片
 *  @param color 字体颜色
 *
 *  @since 1.0
 */
+ (id)buttonClickDoesNotChange:(NSString *)title
               BackgroundImage:(NSString *)image
                    TitleColor:(UIColor *)color;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  设置标题与背景
 *
 *  @param title 标题
 *  @param image 背景图片
 *
 *  @since 1.0
 */
+ (id)buttonWithTitleBackgroundImage:(NSString *)title
                     BackgroundImage:(NSString *)image;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  设置背景图与长按背景图片
 *
 *  @param sImage 背景图片
 *  @param image 长按背景图片
 *
 *  @since 1.0
 */
+ (id)buttonWithFinishedSelectedImage:(NSString *)FinishedSelectedImage
          withFinishedUnselectedImage:(NSString *)FinishedUnselectedImage;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  设置标题与背景
 *
 *  @param title 标题
 *  @param sImage 背景图片
 *  @param image 长按背景图片
 *
 *  @since 1.0
 */
+ (id)buttonWithImageStr:(NSString *)title
           FinishedImage:(NSString *)FinishedImage
     WithFinishedUnImage:(NSString *)FinishedUnImage;

/**
 *  @author CC, 2015-12-22
 *  
 *  @brief  设置标题与背景
 *
 *  @param title           标题
 *  @param FinishedImage   背景图片
 *  @param FinishedUnImage 长按背景图片
 *
 *  @return 返回按钮
 */
+ (id)buttonWithImage:(NSString *)title
        FinishedImage:(UIImage *)FinishedImage
  WithFinishedUnImage:(UIImage *)FinishedUnImage;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  设置背景图片
 *
 *  @param image 背景图片
 *
 *  @since 1.0
 */
+ (id)buttonWithBackgroundImage:(NSString *)image;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  设置背景图片与位置
 *
 *  @param image 背景图片
 *  @param frame 按钮位置 *
 *  @since 1.0
 */
+ (id)buttonWithBackgroundImageFrame:(NSString *)image
                               Frame:(CGRect)frame;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  设置背景图片与位置
 *
 *  @param LeftImage 左图片
 *  @param image 背景图片
 *  @param frame 按钮位置
 *
 *  @since 1.0
 */
+ (id)buttonWithImageTitle:(NSString *)LeftImage
                     Title:(NSString *)title
                     Frame:(CGRect)frame;

/**
 *  @author C C, 2015-12-01
 *
 *  @brief  右图左文
 *
 *  @param rightImage 右图
 *  @param title      标题
 *  @param frame      尺寸
 */
+ (id)buttonLeftTitleWithImage:(NSString *)rightImage
                         Title:(NSString *)title
                         Frame:(CGRect)frame;

/**
 *  @author CC, 2016-01-09
 *  
 *  @brief 左文右图
 *
 *  @param rightImage 右图
 *  @param title      标题
 *  @param frame      位置
 */
+ (id)buttonWithLeftTitleImage:(UIImage *)rightImage
                         Title:(NSString *)title
                         Frame:(CGRect)frame;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  设置背景图片与位置
 *
 *  @param image 上图片
 *  @param title 标题
 *  @param frame 按钮位置
 *
 *  @since 1.0
 */
+ (id)buttonWithUpImageNextTilte:(NSString *)image
                           Title:(NSString *)title
                           Frame:(CGRect)frame;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  圆角按钮
 *
 *  @param title 标题
 *  @param frame 按钮位置
 *
 *  @since 1.0
 */
+ (id)buttonWithFillet:(NSString *)title
                 Frame:(CGRect)frame;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  圆角按钮
 *
 *  @param image 背景图片
 *  @param title 标题
 *  @param frame 按钮位置
 *
 *  @since 1.0
 */
+ (id)buttonWithFillet:(NSString *)image
                 Title:(NSString *)title
                 Frame:(CGRect)frame;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  圆角按钮
 *
 *  @param title 标题
 *  @param frame 按钮位置
 *  @param color 标题字体颜色
 *  @param mode 标题显示位置
 *
 *  @since 1.0
 */
+ (id)buttonWithFillet:(NSString *)title
                 Frame:(CGRect)frame
            TitleColor:(UIColor *)color
                 Moode:(UIControlContentHorizontalAlignment)mode;

#pragma mark -
#pragma mark :. CountDown

/**
 *  @author CC, 16-03-02
 *  
 *  @brief 倒计时按钮
 *
 *  @param timeout    倒计时长
 *  @param title      标题
 *  @param waitTittle 设置界面的按钮显示 根据自己需求设置
 */
- (void)startTime:(NSInteger)timeout
            title:(NSString *)title
       waitTittle:(NSString *)waitTittle;

#pragma mark -
#pragma mark :. Indicator
/**
 This method will show the activity indicator in place of the button text.
 */
- (void)showIndicator;

/**
 This method will remove the indicator and put thebutton text back in place.
 */
- (void)hideIndicator;

#pragma mark -
#pragma mark :. MiddleAligning

/**
 @param spacing The middle spacing between imageView and titleLabel.
 @discussion The middle aligning method for imageView and titleLabel.
 */
- (void)middleAlignButtonWithSpacing:(CGFloat)spacing;

#pragma mark -
#pragma mark :. Submitting

/**
 *  @author foxsofter, 15-04-02 15:04:59
 *
 *  @brief  按钮点击后，禁用按钮并在按钮上显示ActivityIndicator，以及title
 *
 *  @param title 按钮上显示的文字
 */
- (void)beginSubmitting:(NSString *)title;

/**
 *  @author foxsofter, 15-04-02 15:04:13
 *
 *  @brief  按钮点击后，恢复按钮点击前的状态
 */
- (void)endSubmitting;

/**
 *  @author foxsofter, 15-04-02 15:04:17
 *
 *  @brief  按钮是否正在提交中
 */
@property(nonatomic, readonly, getter=isSubmitting) NSNumber *submitting;


#pragma mark -
#pragma mark :. TouchAreaInsets

/**
 *  @brief  设置按钮额外热区
 */
@property(nonatomic, assign) UIEdgeInsets touchAreaInsets;

#pragma mark -
#pragma mark :. WebCache

/**
 * Get the current image URL.
 */
- (NSURL *)sd_currentImageURL;

/**
 * Get the image URL for a control state.
 * 
 * @param state Which state you want to know the URL for. The values are described in UIControlState.
 */
- (NSURL *)sd_imageURLForState:(UIControlState)state;

/**
 * Set the imageView `image` with an `url`.
 *
 * The download is asynchronous and cached.
 *
 * @param url   The url for the image.
 * @param state The state that uses the specified title. The values are described in UIControlState.
 */
- (void)sd_setImageWithURL:(NSURL *)url forState:(UIControlState)state;

/**
 * Set the imageView `image` with an `url` and a placeholder.
 *
 * The download is asynchronous and cached.
 *
 * @param url         The url for the image.
 * @param state       The state that uses the specified title. The values are described in UIControlState.
 * @param placeholder The image to be set initially, until the image request finishes.
 * @see sd_setImageWithURL:placeholderImage:options:
 */
- (void)sd_setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder;

/**
 * Set the imageView `image` with an `url`, placeholder and custom options.
 *
 * The download is asynchronous and cached.
 *
 * @param url         The url for the image.
 * @param state       The state that uses the specified title. The values are described in UIControlState.
 * @param placeholder The image to be set initially, until the image request finishes.
 * @param options     The options to use when downloading the image. @see SDWebImageOptions for the possible values.
 */
- (void)sd_setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options;

/**
 * Set the imageView `image` with an `url`.
 *
 * The download is asynchronous and cached.
 *
 * @param url            The url for the image.
 * @param state          The state that uses the specified title. The values are described in UIControlState.
 * @param completedBlock A block called when operation has been completed. This block has no return value
 *                       and takes the requested UIImage as first parameter. In case of error the image parameter
 *                       is nil and the second parameter may contain an NSError. The third parameter is a Boolean
 *                       indicating if the image was retrieved from the local cache or from the network.
 *                       The fourth parameter is the original image url.
 */
- (void)sd_setImageWithURL:(NSURL *)url forState:(UIControlState)state completed:(SDWebImageCompletionBlock)completedBlock;

/**
 * Set the imageView `image` with an `url`, placeholder.
 *
 * The download is asynchronous and cached.
 *
 * @param url            The url for the image.
 * @param state          The state that uses the specified title. The values are described in UIControlState.
 * @param placeholder    The image to be set initially, until the image request finishes.
 * @param completedBlock A block called when operation has been completed. This block has no return value
 *                       and takes the requested UIImage as first parameter. In case of error the image parameter
 *                       is nil and the second parameter may contain an NSError. The third parameter is a Boolean
 *                       indicating if the image was retrieved from the local cache or from the network.
 *                       The fourth parameter is the original image url.
 */
- (void)sd_setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock;

/**
 * Set the imageView `image` with an `url`, placeholder and custom options.
 *
 * The download is asynchronous and cached.
 *
 * @param url            The url for the image.
 * @param state          The state that uses the specified title. The values are described in UIControlState.
 * @param placeholder    The image to be set initially, until the image request finishes.
 * @param options        The options to use when downloading the image. @see SDWebImageOptions for the possible values.
 * @param completedBlock A block called when operation has been completed. This block has no return value
 *                       and takes the requested UIImage as first parameter. In case of error the image parameter
 *                       is nil and the second parameter may contain an NSError. The third parameter is a Boolean
 *                       indicating if the image was retrieved from the local cache or from the network.
 *                       The fourth parameter is the original image url.
 */
- (void)sd_setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock;

/**
 * Set the backgroundImageView `image` with an `url`.
 *
 * The download is asynchronous and cached.
 *
 * @param url   The url for the image.
 * @param state The state that uses the specified title. The values are described in UIControlState.
 */
- (void)sd_setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state;

/**
 * Set the backgroundImageView `image` with an `url` and a placeholder.
 *
 * The download is asynchronous and cached.
 *
 * @param url         The url for the image.
 * @param state       The state that uses the specified title. The values are described in UIControlState.
 * @param placeholder The image to be set initially, until the image request finishes.
 * @see sd_setImageWithURL:placeholderImage:options:
 */
- (void)sd_setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder;

/**
 * Set the backgroundImageView `image` with an `url`, placeholder and custom options.
 *
 * The download is asynchronous and cached.
 *
 * @param url         The url for the image.
 * @param state       The state that uses the specified title. The values are described in UIControlState.
 * @param placeholder The image to be set initially, until the image request finishes.
 * @param options     The options to use when downloading the image. @see SDWebImageOptions for the possible values.
 */
- (void)sd_setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options;

/**
 * Set the backgroundImageView `image` with an `url`.
 *
 * The download is asynchronous and cached.
 *
 * @param url            The url for the image.
 * @param state          The state that uses the specified title. The values are described in UIControlState.
 * @param completedBlock A block called when operation has been completed. This block has no return value
 *                       and takes the requested UIImage as first parameter. In case of error the image parameter
 *                       is nil and the second parameter may contain an NSError. The third parameter is a Boolean
 *                       indicating if the image was retrieved from the local cache or from the network.
 *                       The fourth parameter is the original image url.
 */
- (void)sd_setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state completed:(SDWebImageCompletionBlock)completedBlock;

/**
 * Set the backgroundImageView `image` with an `url`, placeholder.
 *
 * The download is asynchronous and cached.
 *
 * @param url            The url for the image.
 * @param state          The state that uses the specified title. The values are described in UIControlState.
 * @param placeholder    The image to be set initially, until the image request finishes.
 * @param completedBlock A block called when operation has been completed. This block has no return value
 *                       and takes the requested UIImage as first parameter. In case of error the image parameter
 *                       is nil and the second parameter may contain an NSError. The third parameter is a Boolean
 *                       indicating if the image was retrieved from the local cache or from the network.
 *                       The fourth parameter is the original image url.
 */
- (void)sd_setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock;

/**
 * Set the backgroundImageView `image` with an `url`, placeholder and custom options.
 *
 * The download is asynchronous and cached.
 *
 * @param url            The url for the image.
 * @param placeholder    The image to be set initially, until the image request finishes.
 * @param options        The options to use when downloading the image. @see SDWebImageOptions for the possible values.
 * @param completedBlock A block called when operation has been completed. This block has no return value
 *                       and takes the requested UIImage as first parameter. In case of error the image parameter
 *                       is nil and the second parameter may contain an NSError. The third parameter is a Boolean
 *                       indicating if the image was retrieved from the local cache or from the network.
 *                       The fourth parameter is the original image url.
 */
- (void)sd_setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock;

/**
 * Cancel the current image download
 */
- (void)sd_cancelImageLoadForState:(UIControlState)state;

/**
 * Cancel the current backgroundImage download
 */
- (void)sd_cancelBackgroundImageLoadForState:(UIControlState)state;

@end

#pragma mark - WebCacheDeprecated
@interface UIButton (WebCacheDeprecated)

- (NSURL *)currentImageURL __deprecated_msg("Use `sd_currentImageURL`");
- (NSURL *)imageURLForState:(UIControlState)state __deprecated_msg("Use `sd_imageURLForState:`");

- (void)setImageWithURL:(NSURL *)url forState:(UIControlState)state __deprecated_msg("Method deprecated. Use `sd_setImageWithURL:forState:`");
- (void)setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder __deprecated_msg("Method deprecated. Use `sd_setImageWithURL:forState:placeholderImage:`");
- (void)setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options __deprecated_msg("Method deprecated. Use `sd_setImageWithURL:forState:placeholderImage:options:`");

- (void)setImageWithURL:(NSURL *)url forState:(UIControlState)state completed:(SDWebImageCompletedBlock)completedBlock __deprecated_msg("Method deprecated. Use `sd_setImageWithURL:forState:completed:`");
- (void)setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletedBlock)completedBlock __deprecated_msg("Method deprecated. Use `sd_setImageWithURL:forState:placeholderImage:completed:`");
- (void)setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletedBlock)completedBlock __deprecated_msg("Method deprecated. Use `sd_setImageWithURL:forState:placeholderImage:options:completed:`");

- (void)setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state __deprecated_msg("Method deprecated. Use `sd_setBackgroundImageWithURL:forState:`");
- (void)setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder __deprecated_msg("Method deprecated. Use `sd_setBackgroundImageWithURL:forState:placeholderImage:`");
- (void)setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options __deprecated_msg("Method deprecated. Use `sd_setBackgroundImageWithURL:forState:placeholderImage:options:`");

- (void)setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state completed:(SDWebImageCompletedBlock)completedBlock __deprecated_msg("Method deprecated. Use `sd_setBackgroundImageWithURL:forState:completed:`");
- (void)setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletedBlock)completedBlock __deprecated_msg("Method deprecated. Use `sd_setBackgroundImageWithURL:forState:placeholderImage:completed:`");
- (void)setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletedBlock)completedBlock __deprecated_msg("Method deprecated. Use `sd_setBackgroundImageWithURL:forState:placeholderImage:options:completed:`");

- (void)cancelCurrentImageLoad __deprecated_msg("Use `sd_cancelImageLoadForState:`");
- (void)cancelBackgroundImageLoadForState:(UIControlState)state __deprecated_msg("Use `sd_cancelBackgroundImageLoadForState:`");

@end
