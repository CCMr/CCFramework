//
//  CCPhotoManager.h
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
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "CCAlbumModel.h"
#import "CCAssetModel.h"

#define kCCMargin 4
#define kCCThumbnailWidth ([UIScreen mainScreen].bounds.size.width - 2 * kCCMargin - 4) / 4 - kCCMargin
#define kCCThumbnailSize CGSizeMake(kCCThumbnailWidth, kCCThumbnailWidth)

@interface CCPhotoManager : NSObject

@property(nonatomic, strong, readonly) PHCachingImageManager *_Nullable cachingImageManager;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@property(nonatomic, strong, readonly) ALAssetsLibrary *_Nullable assetLibrary;
#pragma clang diagnostic pop


+ (instancetype _Nonnull)sharedManager;

#pragma mark - Methods

/**
 *  判断用户是否打开了图片授权
 *
 *  @return YES or NO
 */
- (BOOL)hasAuthorized;

/// ========================================
/// @name   获取Album相册相关方法
/// ========================================

/**
 *  获取所有的相册
 *
 *  @param pickingVideoEnable 是否允许选择视频
 *  @param completionBlock    回调block
 */
- (void)getAlbumsPickingVideoEnable:(BOOL)pickingVideoEnable
                    completionBlock:(void (^_Nonnull)(NSArray<CCAlbumModel *> *_Nullable albums))completionBlock;


/**
 *  获取相册中的所有图片,视频
 *
 *  @param result             对应相册  PHFetchResult or ALAssetsGroup<ALAsset>
 *  @param pickingVideoEnable 是否允许选择视频
 *  @param completionBlock    回调block
 */
- (void)getAssetsFromResult:(id _Nonnull)result
         pickingVideoEnable:(BOOL)pickingVideoEnable
            completionBlock:(void (^_Nonnull)(NSArray<CCAssetModel *> *_Nullable assets))completionBlock;

/// ========================================
/// @name   获取Asset对应信息相关方法
/// ========================================

/**
 *  根据提供的asset 获取原图图片
 *  使用异步获取asset的原图图片
 *  @param asset           具体资源 <PHAsset or ALAsset>
 *  @param completionBlock 回到block
 */
- (void)getOriginImageWithAsset:(id _Nonnull)asset
                completionBlock:(void (^_Nonnull)(UIImage *_Nullable image))completionBlock;

/**
 *  根据提供的asset获取缩略图
 *  使用同步方法获取
 *  @param asset           具体的asset资源 PHAsset or ALAsset
 *  @param size            缩略图大小
 *  @param completionBlock 回调block
 */
- (void)getThumbnailWithAsset:(id _Nonnull)asset
                         size:(CGSize)size
              completionBlock:(void (^_Nonnull)(UIImage *_Nullable image))completionBlock;

/**
 *  根据asset 获取屏幕预览图
 *
 *  @param asset           提供的asset资源 PHAsset or ALAsset
 *  @param completionBlock 回调block
 */
- (void)getPreviewImageWithAsset:(id _Nonnull)asset
                 completionBlock:(void (^_Nonnull)(UIImage *_Nullable image))completionBlock;

/**
 *  根据asset 获取图片的方向
 *
 *  @param asset           PHAsset or ALAsset
 *  @param completionBlock 回调block
 */
- (void)getImageOrientationWithAsset:(id _Nonnull)asset
                     completionBlock:(void (^_Nonnull)(UIImageOrientation imageOrientation))completionBlock;
/**
 *  根据asset获取图片的大小信息
 *
 *  @param asset           PHAsset or ALAsset
 *  @param completionBlock 回调block
 */
- (void)getAssetSizeWithAsset:(id _Nonnull)asset completionBlock:(void (^_Nonnull)(CGFloat size))completionBlock;

/**
 *  根据asset获取Video信息
 *
 *  @param asset           PHAsset or ALAsset
 *  @param completionBlock 回调block
 */
- (void)getVideoInfoWithAsset:(id _Nonnull)asset
              completionBlock:(void (^_Nonnull)(AVPlayerItem *_Nullable playerItem, NSDictionary *_Nullable playetItemInfo))completionBlock;

@end
