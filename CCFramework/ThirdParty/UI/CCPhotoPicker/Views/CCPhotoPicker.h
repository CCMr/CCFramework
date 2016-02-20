//
//  CCPhotoPicker.h
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

@class CCAssetModel;
@interface CCPhotoPicker : UIView


/** 最大选择数量 默认0 不限制  使用sharePhotoPicker 则为9*/
@property (nonatomic, assign) NSUInteger maxCount;
/** 最大预览图数量 默认20 */
@property (nonatomic, assign) NSUInteger maxPreviewCount;
/** 是否可以选择视频 默认YES */
@property (nonatomic, assign) BOOL pickingVideoEnable;

/** parentController,用来显示其他controller */
@property (nonatomic, weak, nullable)   UIViewController *parentController;

/** 用户选择完照片的回调 images<previewImage>  assets<PHAsset or ALAsset>*/
@property (nonatomic, copy, nullable)   void(^didFinishPickingPhotosBlock)(NSArray<UIImage *> * _Nullable images, NSArray<CCAssetModel *>* _Nullable assets);

/** 用户选择完视频的回调 coverImage:视频的封面,asset 视频资源地址 */
@property (nonatomic, copy, nullable)   void(^didFinishPickingVideoBlock)(UIImage * _Nullable coverImage, CCAssetModel * _Nullable asset);

+ (instancetype _Nonnull )sharePhotoPicker;
- (instancetype _Nullable )initWithMaxCount:(NSUInteger)maxCount;

- (void)showPhotoPickerwithController:(UIViewController * _Nonnull )controller animated:(BOOL)animated;

@end

