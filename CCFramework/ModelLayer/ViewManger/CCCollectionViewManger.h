//
//  CCCollectionViewManger.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  选中UICollectionViewCell的Block
 */
typedef void (^didSelectCellBlock)(NSIndexPath *indexPath, id item);
/**
 *  设置UICollectionViewCell大小的Block
 */
typedef CGSize (^cellItemSize)();
/**
 *  设置UICollectionViewCell间隔Margin的Block
 */
typedef UIEdgeInsets (^cellItemMargin)();

@class BaseViewModel;
@interface CCCollectionViewManger : NSObject

/** collectionViewCell 重用标识符 */
@property(nonatomic, copy) NSString *cellIdentifier;

/** collectionView布局方式 */
@property(nonatomic, strong) UICollectionViewLayout *collectionViewLayout;

/** 选中cell */
@property(nonatomic, copy) didSelectCellBlock didSelectCellBlock;

/** cell的Size */
@property(nonatomic, copy) cellItemSize cellItemSize;

/** cell的Margin */
@property(nonatomic, copy) cellItemMargin cellItemMargin;

/** collectionView的ViewModel */
@property(nonatomic, strong) BaseViewModel *viewModel;


/**
 *  设置UICollectionViewCell大小
 */
- (void)ItemSize:(cellItemSize)cellItemSize;

/**
 *  设置UICollectionViewCell间隔Margin
 */
- (void)itemInset:(cellItemMargin)cellItemMargin;

/**
 *  初始化方法
 */
- (id)initWithViewModel:(BaseViewModel *)viewModel
         CellIdentifier:(NSString *)aCellIdentifier
   CollectionViewLayout:(UICollectionViewLayout *)collectionViewLayout
      CellItemSizeBlock:(cellItemSize)cellItemSize
    CellItemMarginBlock:(cellItemMargin)cellItemMargin
         DidSelectBlock:(didSelectCellBlock)didselectBlock;

/**
 *  设置CollectionView的Datasource和Delegate为self
 */
- (void)handleCollectionViewDatasourceAndDelegate:(UICollectionView *)collectionView;

/**
 *  获取CollectionView中Item所在的indexPath
 */
- (id)itemAtIndexPath:(NSIndexPath *)indexPath ;

@end
