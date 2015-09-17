/*
 *  CCPhoto.m
 *  CCPhoto
 *
 * Copyright (c) 2015 CC (http://www.ccskill.com)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import <QuartzCore/QuartzCore.h>
#import "CCPhoto.h"

@implementation CCPhoto

/**
 *  @author CC, 2015-06-04 18:06:15
 *
 *  @brief  用于查看相册时使用
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
-(UIImage *)image{
    if (_assets)
        return [UIImage imageWithCGImage:[[_assets defaultRepresentation] fullScreenImage] scale:1.0f orientation:UIImageOrientationUp];
    return _image;
}

/**
 *  @author CC, 2015-06-04 18:06:03
 *
 *  @brief  缩略图
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
-(UIImage *)thumbImage{
    return [UIImage imageWithCGImage:[_assets thumbnail]];
}

#pragma mark 截图
- (UIImage *)capture:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)setSrcImageView:(UIImageView *)srcImageView
{
    _srcImageView = srcImageView;
    _Placeholder = srcImageView.image;
    if (srcImageView.clipsToBounds)
        _capture = [self capture:srcImageView];
}

@end