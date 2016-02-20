//
//  CCPhotoPreviewController.h
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
@interface CCPhotoPreviewController : UICollectionViewController

/** 所有的图片资源 */
@property (nonatomic, copy)   NSArray<CCAssetModel *> *assets;
/** 选择的图片资源 */
@property (nonatomic, strong) NSMutableArray<CCAssetModel *> *selectedAssets;

/** 当用户更改了选择的图片,点击返回时,回调此block */
@property (nonatomic, copy)   void(^didFinishPreviewBlock)( NSArray<CCAssetModel *> *selectedAssets);

/** 用户点击底部bottom按钮后 回调 */
@property (nonatomic, copy)   void (^didFinishPickingBlock)(NSArray<UIImage *> *images ,NSArray<CCAssetModel *> *assets);


/** 当前显示的asset index */
@property (nonatomic, assign) NSUInteger currentIndex;
/** 最大选择数量 */
@property (nonatomic, assign) NSUInteger maxCount;


+ (UICollectionViewLayout *)photoPreviewViewLayoutWithSize:(CGSize)size;

@end
