//
//  CCPhotoPickerController.h
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

/**
 *  只有在用户点击了cancel后才会主动dismiss掉
 */


#import <UIKit/UIKit.h>

@class CCAssetModel;
@protocol CCPhotoPickerControllerDelegate;
@interface CCPhotoPickerController : UINavigationController

#pragma mark - Properties

/** 是否允许选择视频 默认YES*/
@property (nonatomic, assign) BOOL pickingVideoEnable;
/** 是否自动push到相册页面 默认YES*/
@property (nonatomic, assign) BOOL autoPushToPhotoCollection;
/** 每次最多可以选择带图片数量 默认9*/
@property (nonatomic, assign) NSUInteger maxCount;

/** delegate 回调 */
@property (nonatomic, weak , nullable)   id<CCPhotoPickerControllerDelegate> photoPickerDelegate;

/** 用户选择完照片的回调 images<previewImage>  assets<CCAssetModel>*/
@property (nonatomic, copy, nullable)   void(^didFinishPickingPhotosBlock)(NSArray<UIImage *> * _Nullable images, NSArray<CCAssetModel *>* _Nullable assets);

/** 用户选择完视频的回调 coverImage:视频的封面,asset 视频资源地址 */
@property (nonatomic, copy, nullable)   void(^didFinishPickingVideoBlock)(UIImage  * _Nullable coverImage, CCAssetModel * _Nullable asset);

/** 用户点击取消的block 回调 */
@property (nonatomic, copy, nullable)   void(^didCancelPickingBlock)();


#pragma mark - Life Cycle

/**
 *  初始化CCPhotoPickerController
 *
 *  @param maxCount 最大选择数量 0则不限制
 *  @param delegate 使用delegate 回调
 *
 *  @return CCPhotoPickerController实例 或者 nil
 */
- (instancetype _Nonnull )initWithMaxCount:(NSUInteger)maxCount delegate:(_Nullable id<CCPhotoPickerControllerDelegate>)delegate NS_DESIGNATED_INITIALIZER;

#pragma mark - Methods

/**
 *  call photoPickerDelegate & didFinishPickingPhotosBlock
 *  
 *  @param assets 具体回传的资源
 */
- (void)didFinishPickingPhoto:(NSArray<CCAssetModel *> * _Nullable)assets;
/**
 *  call photoPickerDelegate  & didFinishPickingVideoBlock
 *
 *  @param asset 具体选择的视频资源
 */
- (void)didFinishPickingVideo:(CCAssetModel * _Nullable )asset;

/**
 *  call photoPickerDelegate & didCancelPickingPhotosBlock
 */
- (void)didCancelPickingPhoto;


@end


@protocol CCPhotoPickerControllerDelegate <NSObject>

@optional

/**
 *  photoPickerController 点击确定后 代理回调
 *
 *  @param picker 具体的pickerController
 *  @param photos 选择的照片 -- 预览图
 *  @param assets 选择的原图数组  NSArray<PHAsset *>  or NSArray<ALAsset *> or nil
 */
- (void)photoPickerController:(CCPhotoPickerController * _Nonnull)picker didFinishPickingPhotos:(NSArray<UIImage *> * _Nullable)photos sourceAssets:(NSArray<CCAssetModel *> * _Nullable)assets;

/**
 *  photoPickerController 点击取消后回调
 *
 *  @param picker 具体的pickerController
 */
- (void)photoPickerControllerDidCancel:(CCPhotoPickerController * _Nonnull)picker;

/**
 *  photoPickerController选择一个视频后的回调
 *
 *  @param picker     具体的photoPickerController
 *  @param coverImage 视频的预览图
 *  @param asset      视频的具体资源
 */
- (void)photoPickerController:(CCPhotoPickerController * _Nonnull)picker didFinishPickingVideo:(UIImage * _Nullable)coverImage sourceAssets:(CCAssetModel * _Nullable)asset;

@end


@interface CCAlbumListController : UITableViewController

@property (nonatomic, copy, nullable)   NSArray *albums;

@end