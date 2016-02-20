/*
 *  CCPhoto.m
 *  CCFramework
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
#import <ImageIO/ImageIO.h>
#import "UIImage+BUIImage.h"

@implementation CCPhoto

/**
 *  @author CC, 2015-06-04 18:06:15
 *
 *  @brief  用于查看相册时使用
 */
- (UIImage *)image
{
    if (_assets && !_image)
        _image = [UIImage imageWithCGImage:[[self.assets defaultRepresentation] fullScreenImage]];
    return _image;
}

/**
 *  @author CC, 2015-06-04 18:06:03
 *
 *  @brief  缩略图
 */
- (UIImage *)thumbImage
{
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

/**
 *  @author CC, 2015-11-26
 *  
 *  @brief  压缩图片
 *
 *  @param size 最大像素大小
 */
- (UIImage *)compressionWithMaxPixelSize:(NSUInteger)size
{
    return [self thumbnailForAsset:_assets
                      maxPixelSize:size];
}

// Helper methods for thumbnailForAsset:maxPixelSize:
static size_t getAssetBytesCallback(void *info, void *buffer, off_t position, size_t count)
{
    ALAssetRepresentation *rep = (__bridge id)info;
    
    NSError *error = nil;
    size_t countRead = [rep getBytes:(uint8_t *)buffer fromOffset:position length:count error:&error];
    
    if (countRead == 0 && error) {
        // We have no way of passing this info back to the caller, so we log it, at least.
        NSLog(@"thumbnailForAsset:maxPixelSize: got an error reading an asset: %@", error);
    }
    
    return countRead;
}

static void releaseAssetCallback(void *info)
{
    // The info here is an ALAssetRepresentation which we CFRetain in thumbnailForAsset:maxPixelSize:.
    // This release balances that retain.
    CFRelease(info);
}

- (NSInteger)sourceSize:(CGImageSourceRef)source
{
    CGSize imageSize = CGSizeZero;
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCGImageSourceShouldCache];
    NSDictionary *properties = (__bridge_transfer NSDictionary *)CGImageSourceCopyPropertiesAtIndex(source, 0, (__bridge CFDictionaryRef)options);
    if (properties) {
        NSNumber *width = [properties objectForKey:(NSString *)kCGImagePropertyPixelWidth];
        NSNumber *height = [properties objectForKey:(NSString *)kCGImagePropertyPixelHeight];
        if ((width != nil) && (height != nil))
            imageSize = CGSizeMake(width.floatValue, height.floatValue);
    }
    return MAX(imageSize.width, imageSize.height) / 1.5;
}

// Returns a UIImage for the given asset, with size length at most the passed size.
// The resulting UIImage will be already rotated to UIImageOrientationUp, so its CGImageRef
// can be used directly without additional rotation handling.
// This is done synchronously, so you should call this method on a background queue/thread.
- (UIImage *)thumbnailForAsset:(ALAsset *)asset
                  maxPixelSize:(NSUInteger)size
{
    NSParameterAssert(asset != nil);
    //    NSParameterAssert(size > 0);
    
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    
    CGDataProviderDirectCallbacks callbacks = {
        .version = 0,
        .getBytePointer = NULL,
        .releaseBytePointer = NULL,
        .getBytesAtPosition = getAssetBytesCallback,
        .releaseInfo = releaseAssetCallback,
    };
    
    CGDataProviderRef provider = CGDataProviderCreateDirect((void *)CFBridgingRetain(rep), [rep size], &callbacks);
    CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, NULL);
    
    if (!size)
        size = [self sourceSize:source];
    
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef) @{
                                                                                                      (NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                                                                                      (NSString *)
                                                                                                      kCGImageSourceThumbnailMaxPixelSize : @(size),
                                                                                                      (NSString *)
                                                                                                      kCGImageSourceCreateThumbnailWithTransform : @YES,
                                                                                                      });
    CFRelease(source);
    CFRelease(provider);
    
    if (!imageRef) {
        return nil;
    }
    
    UIImage *toReturn = [UIImage imageWithCGImage:imageRef];
    
    CFRelease(imageRef);
    
    return toReturn;
}

@end