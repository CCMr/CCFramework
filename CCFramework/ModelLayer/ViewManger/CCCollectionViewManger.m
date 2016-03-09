//
//  CCCollectionViewManger.m
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

#import "CCCollectionViewManger.h"
#import "BaseViewModel.h"
#import "UICollectionViewCell+Additions.h"

@interface CCCollectionViewManger () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@end

@implementation CCCollectionViewManger

- (id)initWithViewModel:(BaseViewModel *)viewModel
         CellIdentifier:(NSString *)aCellIdentifier
   CollectionViewLayout:(UICollectionViewLayout *)collectionViewLayout
      CellItemSizeBlock:(cellItemSize)cellItemSize
    CellItemMarginBlock:(cellItemMargin)cellItemMargin
         DidSelectBlock:(didSelectCellBlock)didselectBlock
{
    self = [super init];
    if (self) {
        self.viewModel = viewModel;
        self.cellIdentifier = aCellIdentifier;
        self.collectionViewLayout = collectionViewLayout == nil ? [[UICollectionViewFlowLayout alloc] init] : collectionViewLayout;
        self.cellItemSize = cellItemSize;
        self.cellItemMargin = cellItemMargin;
        self.didSelectCellBlock = didselectBlock;
    }
    
    return self;
}

- (void)ItemSize:(cellItemSize)cellItemSize
{
    self.cellItemSize = cellItemSize;
}

- (void)itemInset:(cellItemMargin)cellItemMargin
{
    self.cellItemMargin = cellItemMargin;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.viewModel.cc_dataArray[indexPath.item];
}

- (void)handleCollectionViewDatasourceAndDelegate:(UICollectionView *)collectionView
{
    collectionView.collectionViewLayout = self.collectionViewLayout;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    
    if (self.viewModel) {
        __weak typeof(collectionView) weakCollectiionView = collectionView;
        [self.viewModel cc_viewModelWithGetDataSuccessHandler:^{
            [weakCollectiionView reloadData];
        }];
    }
}

#pragma mark--UICollectionViewDelegateFlowLayout

//定义每个Item 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellItemSize();
}

// 定义每个UICollectionView 的 margin
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return self.cellItemMargin();
}

// 定义每个UICollectionView 纵向的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

#pragma mark-- UICollectionViewDelegate && UICollectionViewDataSourse
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.viewModel cc_viewModelWithNumberOfItemsInSection:section];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self itemAtIndexPath:indexPath];
    
    [UICollectionViewCell registerCollect:collectionView nibIdentifier:self.cellIdentifier];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    [cell configure:cell customObj:item indexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self itemAtIndexPath:indexPath];
    self.didSelectCellBlock(indexPath, item);
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


@end
