//
//  CCAssetModel.m
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

#import "CCAssetModel.h"
#import "CCPhotoManager.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface CCAssetModel ()


/** PHAsset or ALAsset */
@property (nonatomic, strong) _Nonnull id asset;
/** asset  类型 */
@property (nonatomic, assign) CCAssetType type;

/// ========================================
/// @name   视频,audio相关信息
/// ========================================

/** asset为Video时 video的时长 */
@property (nonatomic, copy) NSString *timeLength;


@end

@implementation CCAssetModel
@synthesize originImage = _originImage;
@synthesize thumbnail = _thumbnail;
@synthesize previewImage = _previewImage;
@synthesize imageOrientation = _imageOrientation;
@synthesize playerItem = _playerItem;
@synthesize playerItemInfo = _playerItemInfo;


#pragma mark - Methods



/// ========================================
/// @name   Class Methods
/// ========================================

/**
 *  根据asset,type获取CCAssetModel实例
 *
 *  @param asset 具体的Asset类型 PHAsset or ALAsset
 *  @param type  asset类型
 *
 *  @return CCAssetModel实例
 */
+ ( CCAssetModel  * _Nonnull )modelWithAsset:(_Nonnull id)asset type:(CCAssetType)type {
    return [self modelWithAsset:asset type:type timeLength:@""];
}

/**
 *  根据asset,type,timeLength获取CCAssetModel实例
 *
 *  @param asset      asset 非空
 *  @param type       asset 类型
 *  @param timeLength video时长
 *
 *  @return CCAssetModel实例
 */
+ ( CCAssetModel * _Nonnull )modelWithAsset:(_Nonnull id)asset type:(CCAssetType)type timeLength:(NSString * _Nullable )timeLength {
    CCAssetModel *model = [[CCAssetModel alloc] init];
    model.asset = asset;
    model.type = type;
    model.timeLength = timeLength;
    return model;
}

#pragma mark - Getters

- (UIImage *)originImage {
    if (_originImage) {
        return _originImage;
    }
    __block UIImage *resultImage;
    [[CCPhotoManager sharedManager] getOriginImageWithAsset:self.asset completionBlock:^(UIImage *image){
        resultImage = image;
    }];
    _originImage = resultImage;
    return resultImage;
}

- (UIImage *)thumbnail {
    if (_thumbnail) {
        return _thumbnail;
    }
    __block UIImage *resultImage;
    [[CCPhotoManager sharedManager] getThumbnailWithAsset:self.asset size:kCCThumbnailSize completionBlock:^(UIImage *image){
        resultImage = image;
    }];
    _thumbnail = resultImage;
    return _thumbnail;
}

- (UIImage *)previewImage {
    if (_previewImage) {
        return _previewImage;
    }
    __block UIImage *resultImage;
    [[CCPhotoManager sharedManager] getPreviewImageWithAsset:self.asset completionBlock:^(UIImage *image) {
        resultImage = image;
    }];
    _previewImage = resultImage;
    return _previewImage;
}

- (UIImageOrientation)imageOrientation {
    if (_imageOrientation) {
        return _imageOrientation;
    }
    __block UIImageOrientation resultOrientation;
    [[CCPhotoManager sharedManager] getImageOrientationWithAsset:self.asset completionBlock:^(UIImageOrientation imageOrientation) {
        resultOrientation = imageOrientation;
    }];
    _imageOrientation = resultOrientation;
    return _imageOrientation;
}

- (AVPlayerItem *)playerItem {
    if (_playerItem) {
        return _playerItem;
    }
    __block AVPlayerItem *resultItem;
    __block NSDictionary *resultItemInfo;
    [[CCPhotoManager sharedManager] getVideoInfoWithAsset:self.asset completionBlock:^(AVPlayerItem *playerItem, NSDictionary *playerItemInfo) {
        resultItem = playerItem;
        resultItemInfo = [playerItemInfo copy];
    }];
    _playerItem = resultItem;
    _playerItemInfo = resultItemInfo ? : _playerItemInfo;
    return _playerItem;
}


- (NSDictionary *)playerItemInfo {
    if (_playerItemInfo) {
        return _playerItemInfo;
    }
    __block AVPlayerItem *resultItem;
    __block NSDictionary *resultItemInfo;
    [[CCPhotoManager sharedManager] getVideoInfoWithAsset:self.asset completionBlock:^(AVPlayerItem *playerItem, NSDictionary *playerItemInfo) {
        resultItem = playerItem;
        resultItemInfo = [playerItemInfo copy];
    }];
    _playerItem = resultItem ? : _playerItem;
    _playerItemInfo = resultItemInfo;
    return _playerItemInfo;
}


- (NSString *)description {
    return [NSString stringWithFormat:@"\n-------CCAssetModel Desc Start-------\ntype : %d\nsuper :%@\n-------CCAssetModel Desc End-------",(int)self.type,[super description]];
}
@end
