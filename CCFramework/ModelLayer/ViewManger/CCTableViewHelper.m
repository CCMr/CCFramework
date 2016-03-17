//
//  CCTableViewHelper.m
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

#import "CCTableViewHelper.h"
#import "UIView+Method.h"
#import "UITableView+Additions.h"
#import "UIViewController+Additions.h"
#import "CCProperty.h"
#import "UITableViewCell+Additions.h"

@interface CCTableViewHelper ()

@property(nonatomic, strong) NSMutableArray<NSMutableArray *> *dataArray;
@property(nonatomic, copy) CCTableHelperCellIdentifierBlock cellIdentifierBlock;
@property(nonatomic, copy) CCTableHelperDidSelectBlock didSelectBlock;

@end

@implementation CCTableViewHelper

- (NSString *)cellIdentifier
{
    if (_cellIdentifier == nil) {
        NSString *curVCIdentifier = self.cc_tableView.cc_vc.cc_identifier;
        if (curVCIdentifier) {
            NSString *curCellIdentifier = cc_Format(@"CC%@Cell", curVCIdentifier);
            _cellIdentifier = curCellIdentifier;
        }
    }
    return _cellIdentifier;
}

- (void)registerNibs:(NSArray<NSString *> *)cellNibNames
{
    if (cellNibNames.count > 0) {
        [cellNibNames enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            UINib *nib = [UINib nibWithNibName:obj bundle:nil];
            if (nib)
                [self.cc_tableView registerNib:nib forCellReuseIdentifier:obj];
            else
                [self.cc_tableView registerClass:NSClassFromString(obj) forCellReuseIdentifier:obj];
        }];
        if (cellNibNames.count == 1) {
            self.cellIdentifier = cellNibNames[0];
        }
    }
}

- (void)cellMultipleIdentifier:(CCTableHelperCellIdentifierBlock)cb
{
    self.cellIdentifierBlock = cb;
}

- (void)didSelect:(CCTableHelperDidSelectBlock)cb
{
    self.didSelectBlock = cb;
}

#pragma mark :. TableView DataSource Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger curNumOfSections = self.dataArray.count;
    return curNumOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger curNumOfRows = 0;
    if (self.dataArray.count > section) {
        NSMutableArray *subDataAry = self.dataArray[section];
        curNumOfRows = subDataAry.count;
    }
    return curNumOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *curCell = nil;
    id curModel = [self currentModelAtIndexPath:indexPath];
    NSString *curCellIdentifier = [self cellIdentifierForRowAtIndexPath:indexPath model:curModel];
    curCell = [tableView dequeueReusableCellWithIdentifier:curCellIdentifier forIndexPath:indexPath];
    CCAssert(curCell, @"cell is nil Identifier ⤭ %@ ⤪", curCellIdentifier);
    
    if ([curCell respondsToSelector:@selector(cc_cellWillDisplayWithModel:indexPath:)]) {
        [curCell cc_cellWillDisplayWithModel:curModel indexPath:indexPath];
    }
    return curCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat curHeight = 0;
    if (tableView.cc_autoSizingCell) {
        id curModel = [self currentModelAtIndexPath:indexPath];
        NSString *curCellIdentifier = [self cellIdentifierForRowAtIndexPath:indexPath model:curModel];
        curHeight = [tableView cc_heightForCellWithIdentifier:curCellIdentifier cacheByIndexPath:indexPath configuration:^(id cell) {
            if ([cell respondsToSelector:@selector(cc_cellWillDisplayWithModel:indexPath:)]) {
                [cell cc_cellWillDisplayWithModel:curModel indexPath:indexPath];
            }
        }];
    } else {
        curHeight = tableView.rowHeight;
    }
    return curHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.cc_indexPath = indexPath;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.didSelectBlock) {
        id curModel = [self currentModelAtIndexPath:indexPath];
        self.didSelectBlock(indexPath, curModel);
    }
}

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

- (id)currentModel
{
    return [self currentModelAtIndexPath:self.cc_indexPath];
}

- (id)currentModelAtIndexPath:(NSIndexPath *)cIndexPath
{
    if (self.dataArray.count > cIndexPath.section) {
        NSMutableArray *subDataAry = self.dataArray[cIndexPath.section];
        if (subDataAry.count > cIndexPath.row) {
            id curModel = subDataAry[cIndexPath.row];
            return curModel;
        }
    }
    return nil;
}

- (void)cc_resetDataAry:(NSArray *)newDataAry
{
    [self cc_resetDataAry:newDataAry forSection:0];
}

- (void)cc_resetDataAry:(NSArray *)newDataAry forSection:(NSUInteger)cSection
{
    cc_MainQueue(
                 [self cc_makeUpDataAryForSection:cSection];
                 NSMutableArray *subAry = self.dataArray[cSection];
                 if (subAry.count)[subAry removeAllObjects];
                 if (newDataAry.count) {
                     [subAry addObjectsFromArray:newDataAry];
                 }
                 [self.cc_tableView reloadData];)
}


- (void)cc_reloadDataAry:(NSArray *)newDataAry
{
    [self cc_reloadDataAry:newDataAry forSection:0];
}

- (void)cc_reloadDataAry:(NSArray *)newDataAry forSection:(NSUInteger)cSection
{
    if (newDataAry.count == 0) return;
    cc_MainQueue(
                 NSIndexSet *curIndexSet = [self cc_makeUpDataAryForSection:cSection];
                 NSMutableArray *subAry = self.dataArray[cSection];
                 if (subAry.count)[subAry removeAllObjects];
                 [subAry addObjectsFromArray:newDataAry];
                 
                 [self.cc_tableView beginUpdates];
                 if (curIndexSet) {
                     [self.cc_tableView insertSections:curIndexSet withRowAnimation:UITableViewRowAnimationAutomatic];
                 } else {
                     [self.cc_tableView reloadSections:[NSIndexSet indexSetWithIndex:cSection] withRowAnimation:UITableViewRowAnimationNone];
                 }
                 [self.cc_tableView endUpdates];)
}

- (void)cc_addDataAry:(NSArray *)newDataAry
{
    [self cc_addDataAry:newDataAry forSection:0];
}

- (void)cc_addDataAry:(NSArray *)newDataAry forSection:(NSUInteger)cSection
{
    if (newDataAry.count == 0) return;
    cc_MainQueue(
                 NSIndexSet *curIndexSet = [self cc_makeUpDataAryForSection:cSection];
                 NSMutableArray *subAry = self.dataArray[cSection];
                 if (curIndexSet) {
                     [subAry addObjectsFromArray:newDataAry];
                     [self.cc_tableView beginUpdates];
                     [self.cc_tableView insertSections:curIndexSet withRowAnimation:UITableViewRowAnimationAutomatic];
                     [self.cc_tableView endUpdates];
                 } else {
                     __block NSMutableArray *curIndexPaths = [NSMutableArray arrayWithCapacity:newDataAry.count];
                     [newDataAry enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                         [curIndexPaths addObject:[NSIndexPath indexPathForRow:subAry.count+idx inSection:cSection]];
                     }];
                     [subAry addObjectsFromArray:newDataAry];
                     [self.cc_tableView beginUpdates];
                     [self.cc_tableView insertRowsAtIndexPaths:curIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                     [self.cc_tableView endUpdates];
                 })
}

- (void)cc_insertData:(id)cModel AtIndex:(NSIndexPath *)cIndexPath;
{
    cc_MainQueue(
                 NSIndexSet *curIndexSet = [self cc_makeUpDataAryForSection:cIndexPath.section];
                 NSMutableArray *subAry = self.dataArray[cIndexPath.section];
                 if (subAry.count < cIndexPath.row) return;
                 [subAry insertObject:cModel atIndex:cIndexPath.row];
                 if (curIndexSet) {
                     [self.cc_tableView beginUpdates];
                     [self.cc_tableView insertSections:curIndexSet withRowAnimation:UITableViewRowAnimationAutomatic];
                     [self.cc_tableView endUpdates];
                 } else {
                     [subAry insertObject:cModel atIndex:cIndexPath.row];
                     [self.cc_tableView beginUpdates];
                     [self.cc_tableView insertRowsAtIndexPaths:@[cIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                     [self.cc_tableView endUpdates];
                 })
}

- (void)cc_deleteDataAtIndex:(NSIndexPath *)cIndexPath
{
    cc_MainQueue(
                 if (self.dataArray.count <= cIndexPath.section) return;
                 NSMutableArray *subAry = self.dataArray[cIndexPath.section];
                 if (subAry.count <= cIndexPath.row) return;
                 
                 [subAry removeObjectAtIndex:cIndexPath.row];
                 [self.cc_tableView beginUpdates];
                 [self.cc_tableView deleteRowsAtIndexPaths:@[ cIndexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
                 [self.cc_tableView endUpdates];)
}

- (NSIndexSet *)cc_makeUpDataAryForSection:(NSInteger)cSection
{
    NSMutableIndexSet *curIndexSet = nil;
    if (self.dataArray.count <= cSection) {
        curIndexSet = [NSMutableIndexSet indexSet];
        for (NSInteger idx = 0; idx < (cSection - self.dataArray.count + 1); idx++) {
            NSMutableArray *subAry = [NSMutableArray array];
            [self.dataArray addObject:subAry];
            [curIndexSet addIndex:cSection - idx];
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


@end
