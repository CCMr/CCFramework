//
//  CCSecurityStrategy.m
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

#import "CCSecurityStrategy.h"
#import <UIKit/UIKit.h>
#import "UIImage+Additions.h"
#import "Config.h"

#define screenScale ([UIScreen mainScreen].scale)
#define CCeffectTag 99999

@implementation CCSecurityStrategy

/**
 *  @author CC, 2015-07-31
 *
 *  @brief  添加模糊效果
 *
 *  @since 1.0
 */
+ (void)addBlurEffect
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    imageView.tag = CCeffectTag;
    imageView.image = [self blurImage];
    [[[UIApplication sharedApplication] keyWindow] addSubview:imageView];
}

/**
 *  @author CC, 2015-07-31
 *
 *  @brief  删除模糊效果
 *
 *  @since 1.0
 */
+ (void)removeBlurEffect
{
    NSArray *subViews = [[UIApplication sharedApplication] keyWindow].subviews;
    for (id object in subViews) {
        if ([[object class] isSubclassOfClass:[UIImageView class]]) {
            UIImageView *imageView = (UIImageView *)object;
            if(imageView.tag == CCeffectTag)
            {
                [UIView animateWithDuration:0.2 animations:^{
                    imageView.alpha = 0;
                    [imageView removeFromSuperview];
                }];
                
            }
        }
    }
}

/**
 *  @author CC, 2015-07-31
 *
 *  @brief  毛玻璃效果
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
+(UIImage *)blurImage
{
    UIImage *image = [[self screenShot] imageWithBlur];
    return image;
}

/**
 *  @author CC, 2015-07-31
 *
 *  @brief  幕截屏
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
+(UIImage *)screenShot
{
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(winsize.width * screenScale, winsize.height * screenScale), YES, 0);
    //设置截屏大小
    [[[[UIApplication sharedApplication] keyWindow] layer] renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    CGImageRef imageRef = viewImage.CGImage;
    CGRect rect = CGRectMake(0, 0, winsize.width * screenScale,winsize.height * screenScale);

    UIImage *sendImage = [[UIImage alloc] initWithCGImage:CGImageCreateWithImageInRect(imageRef, rect)];
    
    return sendImage;
}



@end
