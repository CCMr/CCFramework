//
//  CCCollectionViewHelper.m
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

#import "CCCollectionViewHelper.h"
#import "UIView+Method.h"
#import "UIViewController+Additions.h"
#import "CCProperty.h"
#import "UICollectionViewCell+Additions.h"
#import "UICollectionView+Additions.h"
#import "UICollectionReusableView+Additions.h"

@interface CCCollectionViewHelper () <UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic, strong) NSMutableArray<NSMutableArray *> *dataArray;
@property(nonatomic, strong) NSMutableArray<NSMutableArray *> *headerArray;
@property(nonatomic, strong) NSMutableArray<NSMutableArray *> *footerArray;

@property(nonatomic, copy) CCCollectionHelperHeaderView headerView;
@property(nonatomic, copy) CCCollectionHelperFooterView footerView;

@property(nonatomic, copy) CCCollectionHelperCellIdentifierBlock cellIdentifierBlock;
@property(nonatomic, copy) CCCollectionHelperHeaderIdentifierBlock headerIdentifierBlock;
@property(nonatomic, copy) CCCollectionHelperFooterIdentifierBlock footerIdentifierBlock;


@property(nonatomic, copy) CCCollectionHelperNumberOfItemsInSection numberOfItemsInSection;

@property(nonatomic, copy) CCCollectionHelperCellForItemAtIndexPath cellForItemAtIndexPath;
@property(nonatomic, copy) CCCollectionHelperHeaderForItemAtIndexPath headerForItemAtIndexPath;
@property(nonatomic, copy) CCCollectionHelperFooterForItemAtIndexPath footerForItemAtIndexPath;

@property(nonatomic, copy) CCCollectionHelperDidSelectItemAtIndexPath didSelectItemAtIndexPath;

@property(nonatomic, copy) CCCollectionHelperCurrentModelAtIndexPath currentModelAtIndexPath;
@property(nonatomic, copy) CCCollectionHelperCurrentHeaderModelAtIndexPath currentHeaderModelAtIndexPath;
@property(nonatomic, copy) CCCollectionHelperCurrentFooterModelAtIndexPath currentFooterModelAtIndexPath;

@property(nonatomic, copy) CCCollectionHelperCellItemMargin cellItemMargin;
@property(nonatomic, copy) CCCollectionHelperMinimumInteritemSpacingForSection minimumInteritemSpacingForSection;
@end

@implementation CCCollectionViewHelper

- (void)registerNibs:(NSArray<NSString *> *)cellNibNames
{
    if (cellNibNames.count > 0) {
        [cellNibNames enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if ([[self.cc_CellXIB objectAtIndex:idx] boolValue])
                [self.cc_CollectionView registerNib:[UINib nibWithNibName:obj bundle:nil] forCellWithReuseIdentifier:obj];
            else
                [self.cc_CollectionView registerClass:NSClassFromString(obj) forCellWithReuseIdentifier:obj];
        }];
        
        if (cellNibNames.count == 1)
            self.cellIdentifier = cellNibNames[0];
    }
}

-(void)registerNibHeaders:(NSArray<NSString *> *)cellNibNames
{
    if (cellNibNames) {
        [cellNibNames enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if ([[self.cc_CellHeaderXIB objectAtIndex:idx] boolValue])
                [self.cc_CollectionView registerNib:[UINib nibWithNibName:obj bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:obj];
            else
                [self.cc_CollectionView registerClass:NSClassFromString(obj) forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:obj];
        }];
        
        if (cellNibNames.count == 1) {
            self.headerIdentifier = cellNibNames[0];
        }
    }
}

-(void)registerNibFooters:(NSArray<NSString *> *)cellNibNames
{
    if (cellNibNames) {
        [cellNibNames enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if ([[self.cc_CellFooterXIB objectAtIndex:idx] boolValue])
                [self.cc_CollectionView registerNib:[UINib nibWithNibName:obj bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:obj];
            else
                [self.cc_CollectionView registerClass:NSClassFromString(obj) forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:obj];
        }];
        
        if (cellNibNames.count == 1)
            self.footerIdentifier = cellNibNames[0];
    }
}

- (NSMutableArray *)dataSource
{
    NSMutableArray *array = [NSMutableArray array];
    if (self.dataArray.count > 1)
        array = self.dataArray;
    else
        array = self.dataArray.firstObject;
    
    return array;
}

#pragma mark --UICollectionViewDelegateFlowLayout
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    CGSize contentSize = self.titleHeaderSize;
    if (self.headerView){
        id curModel = [self currentHeaderModelAtIndexPath:indexPath];
        contentSize = self.headerView(collectionView,indexPath,curModel).LayoutSizeFittingSize;
    }else if (CGSizeEqualToSize(contentSize, CGSizeMake(0, 0))) {
        contentSize = [collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:indexPath].LayoutSizeFittingSize;
    }
    return contentSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section  
{  
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    CGSize contentSize = self.titleFooterSize;
    if (self.footerView) {
        id curModel = [self currentFooterModelAtIndexPath:indexPath];
        contentSize = self.footerView(collectionView,indexPath,curModel).LayoutSizeFittingSize;
    }else if (CGSizeEqualToSize(contentSize, CGSizeMake(0, 0))){
         contentSize = [collectionView supplementaryViewForElementKind:UICollectionElementKindSectionFooter atIndexPath:indexPath].LayoutSizeFittingSize;
    }
    return contentSize;  
}  

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize curSize = CGSizeMake(SCREEN_WIDTH, 0);
    if (self.cc_autoSizingCell) {
        id curModel = [self currentModelAtIndexPath:indexPath];
        NSString *curCellIdentifier = [self cellIdentifierForRowAtIndexPath:indexPath model:curModel];
        @weakify(self);
        curSize = [collectionView cc_heightForCellWithIdentifier:curCellIdentifier cacheByIndexPath:indexPath configuration:^(id cell) {
            @strongify(self);
            if (self.cellForItemAtIndexPath) {
                self.cellForItemAtIndexPath(cell, indexPath, curModel,NO);
            } else if ([cell respondsToSelector:@selector(cc_cellWillDisplayWithModel:indexPath:)]) {
                [cell cc_cellWillDisplayWithModel:curModel indexPath:indexPath];
            }
        }];
    }
    return curSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    if (self.cellItemMargin) {
        id curModel = [self currentSectionModel:section];
        self.cellItemMargin(collectionView,collectionViewLayout,section,curModel);
    }
    
    return edgeInsets;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    CGFloat minimum = 0;
    if (self.minimumInteritemSpacingForSection) {
        id curModel = [self currentSectionModel:section];
        minimum = self.minimumInteritemSpacingForSection(collectionView,collectionViewLayout,section,curModel);
    }
    return minimum;
}


#pragma mark --UICollectionViewDelegate && UICollectionViewDataSourse

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger curNumOfSections = self.dataArray.count;
    return curNumOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger curNumOfRows = 0;
    if (self.dataArray.count > section) {
        NSMutableArray *subDataAry = self.dataArray[section];
        if (self.numberOfItemsInSection)
            curNumOfRows = self.numberOfItemsInSection(collectionView, section, subDataAry);
        else
            curNumOfRows = subDataAry.count;
    }
    return curNumOfRows;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView;
    if (kind == UICollectionElementKindSectionHeader) {
        id curModel = [self currentHeaderModelAtIndexPath:indexPath];
        if (self.headerView)
            reusableView = self.headerView(collectionView,indexPath,curModel);
        else{
            NSString *curCellIdentifier = [self headerIdentifierForRowAtIndexPath:indexPath model:curModel];
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:curCellIdentifier forIndexPath:indexPath];
        }
        
        if (self.headerForItemAtIndexPath) {
            self.headerForItemAtIndexPath(reusableView, indexPath, curModel, YES);
        } else if ([reusableView respondsToSelector:@selector(cc_cellWillDisplayWithModel:indexPath:)]) {
            [reusableView cc_cellWillDisplayWithModel:curModel indexPath:indexPath];
        }
    }else if (kind == UICollectionElementKindSectionFooter){
        id curModel = [self currentFooterModelAtIndexPath:indexPath];
        if (self.footerView) 
            reusableView = self.footerView(collectionView,indexPath,curModel);
        else{
            NSString *curCellIdentifier = [self footerIdentifierForRowAtIndexPath:indexPath model:curModel];
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:curCellIdentifier forIndexPath:indexPath];
        }
        
        if (self.footerForItemAtIndexPath) {
            self.footerForItemAtIndexPath(reusableView, indexPath, curModel, YES);
        } else if ([reusableView respondsToSelector:@selector(cc_cellWillDisplayWithModel:indexPath:)]) {
            [reusableView cc_cellWillDisplayWithModel:curModel indexPath:indexPath];
        }
    }
    return reusableView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *curCell = nil;
    id curModel = [self currentModelAtIndexPath:indexPath];
    NSString *curCellIdentifier = [self cellIdentifierForRowAtIndexPath:indexPath model:curModel];
    curCell = [collectionView dequeueReusableCellWithReuseIdentifier:curCellIdentifier forIndexPath:indexPath];
    CCAssert(curCell, @"cell is nil Identifier ⤭ %@ ⤪", curCellIdentifier);
    
    if (self.cellForItemAtIndexPath) {
        self.cellForItemAtIndexPath(curCell, indexPath, curModel, YES);
    } else if ([curCell respondsToSelector:@selector(cc_cellWillDisplayWithModel:indexPath:)]) {
        [curCell cc_cellWillDisplayWithModel:curModel indexPath:indexPath];
    }
    
    return curCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.cc_indexPath = indexPath;
    if (self.didSelectItemAtIndexPath) {
        id curModel = [self currentModelAtIndexPath:indexPath];
        self.didSelectItemAtIndexPath(collectionView, indexPath, curModel);
    }
}

#pragma mark -
#pragma mark :. Handler

- (NSString *)cellIdentifierForRowAtIndexPath:(NSIndexPath *)cIndexPath model:(id)cModel
{
    NSString *curCellIdentifier = nil;
    if (self.cellIdentifierBlock) {
        curCellIdentifier = self.cellIdentifierBlock(cIndexPath, cModel);
    } else {
        curCellIdentifier = self.cellIdentifier;
    }
    return curCellIdentifier;
}

- (id)currentSectionModel:(NSInteger)section
{
    id currentModel = nil;
    NSArray *arr = [self.dataArray objectAtIndex:section];
    if (arr.count)
        currentModel = [arr objectAtIndex:0];
    
    return currentModel;
}

- (id)currentModel
{
    return [self currentModelAtIndexPath:self.cc_indexPath];
}

- (id)currentModelAtIndexPath:(NSIndexPath *)cIndexPath
{
    if (self.currentModelAtIndexPath) {
        return self.currentModelAtIndexPath(self.dataArray, cIndexPath);
    } else if (self.dataArray.count > cIndexPath.section) {
        NSMutableArray *subDataAry = self.dataArray[cIndexPath.section];
        if (subDataAry.count > cIndexPath.row) {
            id curModel = subDataAry[cIndexPath.row];
            return curModel;
        }
    }
    return nil;
}

#pragma mark :. Group
- (void)cc_reloadGroupDataAry:(NSArray *)newDataAry
{
    self.dataArray = nil;
    for (NSInteger i = 0; i < newDataAry.count; i++)
        [self cc_makeUpDataAryForSection:i];
    
    for (int idx = 0; idx < self.dataArray.count; idx++) {
        NSMutableArray *subAry = self.dataArray[idx];
        if (subAry.count) [subAry removeAllObjects];
        id data = [newDataAry objectAtIndex:idx];
        if ([data isKindOfClass:[NSArray class]]) {
            [subAry addObjectsFromArray:data];
        } else {
            [subAry addObject:data];
        }
    }
    [self.cc_CollectionView reloadData];
}

- (void)cc_addGroupDataAry:(NSArray *)newDataAry
{
    [self.dataArray addObject:[NSMutableArray arrayWithArray:newDataAry]];
    [self.cc_CollectionView reloadData];
}

- (void)cc_insertGroupDataAry:(NSArray *)newDataAry
                   forSection:(NSInteger)cSection
{
    [self.dataArray insertObject:[NSMutableArray arrayWithArray:newDataAry] atIndex:cSection == -1 ? 0 : cSection];
    [self.cc_CollectionView reloadData];
}

- (void)cc_insertMultiplGroupDataAry:(NSArray *)newDataAry
                          forSection:(NSInteger)cSection
{
    NSMutableArray *idxArray = [NSMutableArray array];
    if (cSection < 0) {
        for (NSInteger i = 0; i < newDataAry.count; i++) {
            [self.dataArray insertObject:[NSMutableArray array] atIndex:0];
            [idxArray addObject:@(i)];
        }
    } else {
        for (NSInteger i = 0; i < newDataAry.count; i++) {
            [self.dataArray insertObject:[NSMutableArray array] atIndex:cSection + i];
            [idxArray addObject:@(cSection + i)];
        }
    }
    
    for (NSInteger i = 0; i < idxArray.count; i++) {
        NSInteger idx = [[idxArray objectAtIndex:i] integerValue];
        NSMutableArray *subAry = self.dataArray[idx];
        if (subAry.count) [subAry removeAllObjects];
        id data = [newDataAry objectAtIndex:i];
        if ([data isKindOfClass:[NSArray class]]) {
            [subAry addObjectsFromArray:data];
        } else {
            [subAry addObject:data];
        }
    }
    [self.cc_CollectionView reloadData];
}

#pragma mark :.

- (void)cc_resetDataAry:(NSArray *)newDataAry
{
    [self cc_resetDataAry:newDataAry forSection:0];
}

- (void)cc_resetDataAry:(NSArray *)newDataAry forSection:(NSInteger)cSection
{
    [self cc_makeUpDataAryForSection:cSection];
    NSMutableArray *subAry = self.dataArray[cSection];
    if (subAry.count) [subAry removeAllObjects];
    if (newDataAry.count) {
        [subAry addObjectsFromArray:newDataAry];
    }
    [self.cc_CollectionView reloadData];
}

- (void)cc_reloadDataAry:(NSArray *)newDataAry
{
    [self cc_reloadDataAry:newDataAry forSection:0];
}

- (void)cc_reloadDataAry:(NSArray *)newDataAry forSection:(NSInteger)cSection
{
    if (newDataAry.count == 0) return;
    
    NSIndexSet *curIndexSet = [self cc_makeUpDataAryForSection:cSection];
    NSMutableArray *subAry = self.dataArray[cSection];
    if (subAry.count) [subAry removeAllObjects];
    [subAry addObjectsFromArray:newDataAry];
    
    if (curIndexSet) {
        [self.cc_CollectionView insertSections:curIndexSet];
    } else {
        [self.cc_CollectionView reloadSections:[NSIndexSet indexSetWithIndex:cSection]];
    }
}

- (void)cc_addDataAry:(NSArray *)newDataAry
{
    [self cc_addDataAry:newDataAry forSection:0];
}

- (void)cc_addDataAry:(NSArray *)newDataAry forSection:(NSInteger)cSection
{
    if (newDataAry.count == 0) return;
    
    NSIndexSet *curIndexSet = [self cc_makeUpDataAryForSection:cSection];
    NSMutableArray *subAry;
    if (cSection < 0) {
        subAry = self.dataArray[0];
    } else
        subAry = self.dataArray[cSection];
    
    if (curIndexSet) {
        [subAry addObjectsFromArray:newDataAry];
        [self.cc_CollectionView insertSections:curIndexSet];
    } else {
        __block NSMutableArray *curIndexPaths = [NSMutableArray arrayWithCapacity:newDataAry.count];
        [newDataAry enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [curIndexPaths addObject:[NSIndexPath indexPathForRow:subAry.count+idx inSection:cSection]];
        }];
        [subAry addObjectsFromArray:newDataAry];
        [self.cc_CollectionView insertItemsAtIndexPaths:curIndexPaths];
    }
}

- (void)cc_insertData:(id)cModel AtIndex:(NSIndexPath *)cIndexPath;
{
    
    NSIndexSet *curIndexSet = [self cc_makeUpDataAryForSection:cIndexPath.section];
    NSMutableArray *subAry = self.dataArray[cIndexPath.section];
    if (subAry.count < cIndexPath.row) return;
    [subAry insertObject:cModel atIndex:cIndexPath.row];
    if (curIndexSet) {
        [self.cc_CollectionView insertSections:curIndexSet];
    } else {
        [subAry insertObject:cModel atIndex:cIndexPath.row];
        [self.cc_CollectionView insertItemsAtIndexPaths:@[ cIndexPath ]];
    }
}

- (void)cc_deleteDataAtIndex:(NSIndexPath *)cIndexPath
{
    
    if (self.dataArray.count <= cIndexPath.section) return;
    NSMutableArray *subAry = self.dataArray[cIndexPath.section];
    if (subAry.count <= cIndexPath.row) return;
    
    [subAry removeObjectAtIndex:cIndexPath.row];
    [self.cc_CollectionView insertItemsAtIndexPaths:@[ cIndexPath ]];
}

- (void)cc_replaceDataAtIndex:(id)model
                    IndexPath:(NSIndexPath *)cIndexPath
{
    if (self.dataArray.count > cIndexPath.section) {
        NSMutableArray *subDataAry = self.dataArray[cIndexPath.section];
        if (subDataAry.count > cIndexPath.row) {
            [subDataAry replaceObjectAtIndex:cIndexPath.row withObject:model];
            [self.cc_CollectionView reloadData];
        }
    }
}

- (NSIndexSet *)cc_makeUpDataAryForSection:(NSInteger)cSection
{
    NSMutableIndexSet *curIndexSet = nil;
    if (self.dataArray.count <= cSection) {
        curIndexSet = [NSMutableIndexSet indexSet];
        for (NSInteger idx = 0; idx < (cSection - self.dataArray.count + 1); idx++) {
            NSMutableArray *subAry = [NSMutableArray array];
            if (cSection < 0) {
                [self.dataArray insertObject:subAry atIndex:0];
                [curIndexSet addIndex:0];
                break;
            } else {
                [self.dataArray addObject:subAry];
                [curIndexSet addIndex:cSection - idx];
            }
        }
    }
    return curIndexSet;
}


- (NSMutableArray<NSMutableArray *> *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

#pragma mark -
#pragma mark :. Header

- (void)cc_reloadGroupHeaderArr:(NSArray *)newDataAry
{
    self.headerArray = nil;
    for (NSInteger i = 0; i < newDataAry.count; i++)
        [self cc_makeUpHeaderArrForSection:i];
    
    for (int idx = 0; idx < self.headerArray.count; idx++) {
        NSMutableArray *subAry = self.headerArray[idx];
        if (subAry.count) [subAry removeAllObjects];
        id data = [newDataAry objectAtIndex:idx];
        if ([data isKindOfClass:[NSArray class]]) {
            [subAry addObjectsFromArray:data];
        } else {
            [subAry addObject:data];
        }
    }
    [self.cc_CollectionView reloadData];
}

- (void)cc_addGroupHeaderArr:(NSArray *)newDataAry
{
    [self.headerArray addObject:[NSMutableArray arrayWithArray:newDataAry]];
    [self.cc_CollectionView reloadData];
}

- (void)cc_insertGroupHeaderArr:(NSArray *)newDataAry
                   forSection:(NSInteger)cSection
{
    [self.headerArray insertObject:[NSMutableArray arrayWithArray:newDataAry] atIndex:cSection == -1 ? 0 : cSection];
    [self.cc_CollectionView reloadData];
}

- (void)cc_insertMultiplGroupHeaderArr:(NSArray *)newDataAry
                          forSection:(NSInteger)cSection
{
    NSMutableArray *idxArray = [NSMutableArray array];
    if (cSection < 0) {
        for (NSInteger i = 0; i < newDataAry.count; i++) {
            [self.headerArray insertObject:[NSMutableArray array] atIndex:0];
            [idxArray addObject:@(i)];
        }
    } else {
        for (NSInteger i = 0; i < newDataAry.count; i++) {
            [self.headerArray insertObject:[NSMutableArray array] atIndex:cSection + i];
            [idxArray addObject:@(cSection + i)];
        }
    }
    
    for (NSInteger i = 0; i < idxArray.count; i++) {
        NSInteger idx = [[idxArray objectAtIndex:i] integerValue];
        NSMutableArray *subAry = self.headerArray[idx];
        if (subAry.count) [subAry removeAllObjects];
        id data = [newDataAry objectAtIndex:i];
        if ([data isKindOfClass:[NSArray class]]) {
            [subAry addObjectsFromArray:data];
        } else {
            [subAry addObject:data];
        }
    }
    [self.cc_CollectionView reloadData];
}

- (void)cc_resetHeaderArr:(NSArray *)newDataAry
{
    [self cc_resetHeaderArr:newDataAry forSection:0];
}

- (void)cc_resetHeaderArr:(NSArray *)newDataAry forSection:(NSInteger)cSection
{
    [self cc_makeUpHeaderArrForSection:cSection];
    NSMutableArray *subAry = self.headerArray[cSection];
    if (subAry.count) [subAry removeAllObjects];
    if (newDataAry.count) {
        [subAry addObjectsFromArray:newDataAry];
    }
    [self.cc_CollectionView reloadData];
}

-(NSString *)headerIdentifierForRowAtIndexPath:(NSIndexPath *)cIndexPath model:(id)cModel
{
    NSString *curCellIdentifier = nil;
    if (self.headerIdentifierBlock) {
        curCellIdentifier = self.headerIdentifierBlock(cIndexPath, cModel);
    } else {
        curCellIdentifier = self.cellIdentifier;
    }
    return curCellIdentifier;
}

- (id)currentHeaderModelAtIndexPath:(NSIndexPath *)cIndexPath
{
    if (self.currentHeaderModelAtIndexPath) {
        return self.currentHeaderModelAtIndexPath(self.headerArray, cIndexPath);
    } else if (self.headerArray.count > cIndexPath.section) {
        NSMutableArray *subDataAry = self.headerArray[cIndexPath.section];
        if (subDataAry.count > cIndexPath.row) {
            id curModel = subDataAry[cIndexPath.row];
            return curModel;
        }
    }
    return nil;
}

- (NSIndexSet *)cc_makeUpHeaderArrForSection:(NSInteger)cSection
{
    NSMutableIndexSet *curIndexSet = nil;
    if (self.headerArray.count <= cSection) {
        curIndexSet = [NSMutableIndexSet indexSet];
        for (NSInteger idx = 0; idx < (cSection - self.headerArray.count + 1); idx++) {
            NSMutableArray *subAry = [NSMutableArray array];
            if (cSection < 0) {
                [self.headerArray insertObject:subAry atIndex:0];
                [curIndexSet addIndex:0];
                break;
            } else {
                [self.headerArray addObject:subAry];
                [curIndexSet addIndex:cSection - idx];
            }
        }
    }
    return curIndexSet;
}

-(NSMutableArray<NSMutableArray *> *)headerArray
{
    if (!_headerArray) {
        _headerArray = [NSMutableArray new];
    }
    return _headerArray;
}

#pragma mark -
#pragma mark :. Footer

- (void)cc_reloadGroupFooterArr:(NSArray *)newDataAry
{
    self.footerArray = nil;
    for (NSInteger i = 0; i < newDataAry.count; i++)
        [self cc_makeUpFooterArrForSection:i];
    
    for (int idx = 0; idx < self.footerArray.count; idx++) {
        NSMutableArray *subAry = self.footerArray[idx];
        if (subAry.count) [subAry removeAllObjects];
        id data = [newDataAry objectAtIndex:idx];
        if ([data isKindOfClass:[NSArray class]]) {
            [subAry addObjectsFromArray:data];
        } else {
            [subAry addObject:data];
        }
    }
    [self.cc_CollectionView reloadData];
}

- (void)cc_addGroupFooterArr:(NSArray *)newDataAry
{
    [self.footerArray addObject:[NSMutableArray arrayWithArray:newDataAry]];
    [self.cc_CollectionView reloadData];
}

- (void)cc_insertGroupFooterArr:(NSArray *)newDataAry
                     forSection:(NSInteger)cSection
{
    [self.footerArray insertObject:[NSMutableArray arrayWithArray:newDataAry] atIndex:cSection == -1 ? 0 : cSection];
    [self.cc_CollectionView reloadData];
}

- (void)cc_insertMultiplGroupFooterArr:(NSArray *)newDataAry
                            forSection:(NSInteger)cSection
{
    NSMutableArray *idxArray = [NSMutableArray array];
    if (cSection < 0) {
        for (NSInteger i = 0; i < newDataAry.count; i++) {
            [self.footerArray insertObject:[NSMutableArray array] atIndex:0];
            [idxArray addObject:@(i)];
        }
    } else {
        for (NSInteger i = 0; i < newDataAry.count; i++) {
            [self.footerArray insertObject:[NSMutableArray array] atIndex:cSection + i];
            [idxArray addObject:@(cSection + i)];
        }
    }
    
    for (NSInteger i = 0; i < idxArray.count; i++) {
        NSInteger idx = [[idxArray objectAtIndex:i] integerValue];
        NSMutableArray *subAry = self.footerArray[idx];
        if (subAry.count) [subAry removeAllObjects];
        id data = [newDataAry objectAtIndex:i];
        if ([data isKindOfClass:[NSArray class]]) {
            [subAry addObjectsFromArray:data];
        } else {
            [subAry addObject:data];
        }
    }
    [self.cc_CollectionView reloadData];
}

- (void)cc_resetFooterArr:(NSArray *)newDataAry
{
    [self cc_resetFooterArr:newDataAry forSection:0];
}

- (void)cc_resetFooterArr:(NSArray *)newDataAry forSection:(NSInteger)cSection
{
    [self cc_makeUpFooterArrForSection:cSection];
    NSMutableArray *subAry = self.footerArray[cSection];
    if (subAry.count) [subAry removeAllObjects];
    if (newDataAry.count) {
        [subAry addObjectsFromArray:newDataAry];
    }
    [self.cc_CollectionView reloadData];
}

-(NSString *)footerIdentifierForRowAtIndexPath:(NSIndexPath *)cIndexPath model:(id)cModel
{
    NSString *curCellIdentifier = nil;
    if (self.footerIdentifierBlock) {
        curCellIdentifier = self.footerIdentifierBlock(cIndexPath, cModel);
    } else {
        curCellIdentifier = self.cellIdentifier;
    }
    return curCellIdentifier;
}

- (id)currentFooterModelAtIndexPath:(NSIndexPath *)cIndexPath
{
    if (self.currentFooterModelAtIndexPath) {
        return self.currentFooterModelAtIndexPath(self.footerArray, cIndexPath);
    } else if (self.footerArray.count > cIndexPath.section) {
        NSMutableArray *subDataAry = self.footerArray[cIndexPath.section];
        if (subDataAry.count > cIndexPath.row) {
            id curModel = subDataAry[cIndexPath.row];
            return curModel;
        }
    }
    return nil;
}

- (NSIndexSet *)cc_makeUpFooterArrForSection:(NSInteger)cSection
{
    NSMutableIndexSet *curIndexSet = nil;
    if (self.footerArray.count <= cSection) {
        curIndexSet = [NSMutableIndexSet indexSet];
        for (NSInteger idx = 0; idx < (cSection - self.footerArray.count + 1); idx++) {
            NSMutableArray *subAry = [NSMutableArray array];
            if (cSection < 0) {
                [self.footerArray insertObject:subAry atIndex:0];
                [curIndexSet addIndex:0];
                break;
            } else {
                [self.footerArray addObject:subAry];
                [curIndexSet addIndex:cSection - idx];
            }
        }
    }
    return curIndexSet;
}


-(NSMutableArray<NSMutableArray *> *)footerArray
{
    if (!_footerArray) {
        _footerArray = [NSMutableArray new];
    }
    return _footerArray;
}

#pragma mark -
#pragma mark :. getset

- (NSString *)cellIdentifier
{
    if (_cellIdentifier == nil) {
        NSString *curVCIdentifier = self.cc_CollectionView.viewController.cc_identifier;
        if (curVCIdentifier) {
            NSString *curCellIdentifier = cc_Format(@"CC%@Cell", curVCIdentifier);
            _cellIdentifier = curCellIdentifier;
        }
    }
    return _cellIdentifier;
}

-(NSString *)headerIdentifier
{
    if (_headerIdentifier == nil) {
        NSString *curVCIdentifier = self.cc_CollectionView.viewController.cc_identifier;
        if (curVCIdentifier) {
            NSString *curCellIdentifier = cc_Format(@"CC%@Header", curVCIdentifier);
            _headerIdentifier = curCellIdentifier;
        }
    }
    return _headerIdentifier;
}

-(NSString *)footerIdentifier
{
    if (_footerIdentifier == nil) {
        NSString *curVCIdentifier = self.cc_CollectionView.viewController.cc_identifier;
        if (curVCIdentifier) {
            NSString *curCellIdentifier = cc_Format(@"CC%@Header", curVCIdentifier);
            _footerIdentifier = curCellIdentifier;
        }
    }
    return _footerIdentifier;
}

- (void)cellMultipleIdentifier:(CCCollectionHelperCellIdentifierBlock)block
{
    self.cellIdentifierBlock = block;
}

-(void)headerMultipleIdentifier:(CCCollectionHelperHeaderIdentifierBlock)block
{
    self.headerIdentifierBlock = block;
}

-(void)footerMultipleIdentifier:(CCCollectionHelperFooterIdentifierBlock)block
{
    self.footerIdentifierBlock = block;
}

-(void)currentModelIndexPath:(CCCollectionHelperCurrentModelAtIndexPath)block
{
    self.currentModelAtIndexPath = block;
}

-(void)didNumberOfItemsInSection:(CCCollectionHelperNumberOfItemsInSection)block
{
    self.numberOfItemsInSection = block;
}

-(void)didHeaderView:(CCCollectionHelperHeaderView)block
{
    self.headerView = block;
}

-(void)didFooterView:(CCCollectionHelperFooterView)block
{
    self.footerView = block;
}

-(void)didCellForItemAtIndexPath:(CCCollectionHelperCellForItemAtIndexPath)block
{
    self.cellForItemAtIndexPath = block;
}

-(void)didHeaderForItemAtIndexPah:(CCCollectionHelperHeaderForItemAtIndexPath)block
{
    self.headerForItemAtIndexPath = block;
}

-(void)didFooterForItemAtIndexPah:(CCCollectionHelperFooterForItemAtIndexPath)block
{
    self.footerForItemAtIndexPath = block;
}

-(void)didSelectItemAtIndexPath:(CCCollectionHelperDidSelectItemAtIndexPath)block
{
    self.didSelectItemAtIndexPath = block;
}

-(void)didCellItemMargin:(CCCollectionHelperCellItemMargin)block
{
    self.cellItemMargin = block;
}

-(void)didMinimumInteritemSpacingForSection:(CCCollectionHelperMinimumInteritemSpacingForSection)blcok
{
    self.minimumInteritemSpacingForSection = blcok;
}

@end
