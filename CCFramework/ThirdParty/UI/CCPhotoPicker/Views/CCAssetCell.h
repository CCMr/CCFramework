//
//  CCAssetCell.h
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
@interface CCAssetCell : UICollectionViewCell

/**
 *  按钮点击后的回调
 *  返回按钮的状态是否会被更改
 */
@property (nonatomic, copy, nullable)   BOOL(^willChangeSelectedStateBlock)(CCAssetModel * _Nonnull asset);

/**
 *  当按钮selected状态改变后,回调
 */
@property (nonatomic, copy, nullable)   void(^didChangeSelectedStateBlock)(BOOL selected, CCAssetModel * _Nonnull asset);

@property (nonatomic, copy, nullable)   void(^didSendAsset)(CCAssetModel * _Nonnull asset, CGRect frame);


/**
 *  具体的资源model
 */
@property (nonatomic, strong, readonly, nonnull) CCAssetModel *asset;

/**
 *  CCPhotoCollectionController 中配置collectionView的cell
 *
 *  @param item 具体的AssetModel
 */
- (void)configCellWithItem:(CCAssetModel * _Nonnull )item;

/**
 *  CCPhotoPicker 中配置collectionView的cell
 *
 *  @param item 具体的AssetModel
 */
- (void)configPreviewCellWithItem:(CCAssetModel * _Nonnull )item;

@end
