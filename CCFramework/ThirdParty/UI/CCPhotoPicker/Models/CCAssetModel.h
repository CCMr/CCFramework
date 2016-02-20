//
//  CCAssetModel.h
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


typedef enum : NSUInteger {
    CCAssetTypePhoto = 0,
    CCAssetTypeLivePhoto,
    CCAssetTypeVideo,
    CCAssetTypeAudio,
} CCAssetType;

@class AVPlayerItem;
@interface CCAssetModel : NSObject

/** PHAsset or ALAsset */
@property (nonatomic, strong, readonly, nonnull) id asset;
/** asset  类型 */
@property (nonatomic, assign, readonly) CCAssetType type;

/// ========================================
/// @name   图片相关信息
/// ========================================

/** 获取照片asset对应的原图 */
@property (nonatomic, strong, readonly, nullable) UIImage * originImage;
/** 获取照片asset对应的缩略图, 默认缩略图大小 80x80 */
@property (nonatomic, strong, readonly, getter=thumbnail, nullable) UIImage *thumbnail;
/** 获取照片asset的预览图,默认大小 [UIScreen mainScreen].bounds.size */
@property (nonatomic, strong, readonly, nullable) UIImage * previewImage;
/** 获取照片的方向 */
@property (nonatomic, assign, readonly) UIImageOrientation imageOrientation;

/// ========================================
/// @name   视频,audio相关信息
/// ========================================

/** asset为Video时 video的时长 */
@property (nonatomic, copy,   readonly, nullable) NSString * timeLength;
/** 视频的播放item */
@property (nonatomic, strong, readonly, nullable) AVPlayerItem * playerItem;
/** 视频播放item的信息 */
@property (nonatomic, copy,   readonly, nullable) NSDictionary * playerItemInfo;


/** 是否被选中  默认NO */
@property (nonatomic, assign) BOOL selected;


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
+ ( CCAssetModel  * _Nonnull )modelWithAsset:(_Nonnull id)asset type:(CCAssetType)type;

/**
 *  根据asset,type,timeLength获取CCAssetModel实例
 *
 *  @param asset      asset 非空
 *  @param type       asset 类型
 *  @param timeLength video时长
 *
 *  @return CCAssetModel实例
 */
+ ( CCAssetModel * _Nonnull )modelWithAsset:(_Nonnull id)asset type:(CCAssetType)type timeLength:(NSString * _Nullable )timeLength;

@end
