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
#import "UIView+CCKit.h"


#define defaultInterval .5 //默认时间间隔

@interface CCTableViewHelper ()

@property(nonatomic, strong) NSMutableArray<NSMutableArray *> *dataArray;

@property(nonatomic, strong) NSMutableArray *sectionIndexTitles;

@property(nonatomic, strong) UILocalizedIndexedCollation *theCollation;

@property(nonatomic, assign) NSTimeInterval timeInterval;

@property(nonatomic, assign) BOOL isIgnoreEvent;


/**
 *  @author CC, 16-07-23
 *
 *  @brief 头部搜索
 */
@property(nonatomic, strong) UISearchBar *searchBar;

@property(nonatomic, copy) CCTableHelperCellIdentifierBlock cellIdentifierBlock;
@property(nonatomic, copy) CCTableHelperDidSelectBlock didSelectBlock;
@property(nonatomic, copy) CCTableHelperDidDeSelectBlock didDeSelectBlock;
@property(nonatomic, copy) CCTableHelperDidMoveToRowBlock didMoveToRowBlock;
@property(nonatomic, copy) CCTableHelperDidWillDisplayBlock didWillDisplayBlock;

@property(nonatomic, copy) CCTableHelperDidEditingBlock didEditingBlock;
@property(nonatomic, copy) CCTableHelperDidEditTitleBlock didEditTileBlock;

@property(nonatomic, copy) CCTableHelperEditingStyle didEditingStyle;
@property(nonatomic, copy) CCTableHelperDidEditActionsBlock didEditActionsBlock;

@property(nonatomic, copy) CCScrollViewWillBeginDragging scrollViewBdBlock;
@property(nonatomic, copy) CCScrollViewDidScroll scrollViewddBlock;

@property(nonatomic, copy) CCTableHelperHeaderBlock headerBlock;
@property(nonatomic, copy) CCTableHelperTitleHeaderBlock headerTitleBlock;

@property(nonatomic, copy) CCTableHelperFooterBlock footerBlock;
@property(nonatomic, copy) CCTableHelperTitleFooterBlock footerTitleBlock;

@property(nonatomic, copy) CCTableHelperNumberRows numberRow;

@property(nonatomic, copy) CCTableHelperCellBlock cellViewEventsBlock;
@property(nonatomic, copy) CCTableHelperCurrentModelAtIndexPath currentModelAtIndexPath;
@property(nonatomic, copy) CCTableHelperScrollViewDidEndScrolling scrollViewDidEndScrolling;

@end

@implementation CCTableViewHelper

#pragma mark -
#pragma mark :. getset
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
            if ([[self.cc_CellXIB objectAtIndex:idx] boolValue])
                [self.cc_tableView registerNib:[UINib nibWithNibName:obj bundle:nil] forCellReuseIdentifier:obj];
            else
                [self.cc_tableView registerClass:NSClassFromString(obj) forCellReuseIdentifier:obj];
        }];
        if (cellNibNames.count == 1) {
            self.cellIdentifier = cellNibNames[0];
        }
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

- (NSArray *)sectionIndexTitles
{
    if (!_sectionIndexTitles) {
        NSMutableArray *sectionIndex = [NSMutableArray array];
        if (self.cc_tableView.tableHeaderView && [self.cc_tableView.tableHeaderView isKindOfClass:[UISearchBar class]]) {
            self.searchBar = (UISearchBar *)self.cc_tableView.tableHeaderView;
            [sectionIndex addObject:UITableViewIndexSearch];
        }
        
        [sectionIndex addObjectsFromArray:[UILocalizedIndexedCollation.currentCollation sectionIndexTitles]];
        _sectionIndexTitles = sectionIndex;
    }
    return _sectionIndexTitles;
}

- (UILocalizedIndexedCollation *)theCollation
{
    if (!_theCollation) {
        _theCollation = [UILocalizedIndexedCollation currentCollation];
    }
    return _theCollation;
}

#pragma mark -
#pragma mark :. Block事件
- (void)cellMultipleIdentifier:(CCTableHelperCellIdentifierBlock)cb
{
    self.cellIdentifierBlock = cb;
}

- (void)didSelect:(CCTableHelperDidSelectBlock)cb
{
    self.didSelectBlock = cb;
}

- (void)didDeSelect:(CCTableHelperDidDeSelectBlock)cb
{
    self.didDeSelectBlock = cb;
}

- (void)didEnditing:(CCTableHelperDidEditingBlock)cb
{
    self.didEditingBlock = cb;
}

- (void)didEnditTitle:(CCTableHelperDidEditTitleBlock)cb
{
    self.didEditTileBlock = cb;
}

- (void)didEditingStyle:(CCTableHelperEditingStyle)cb
{
    self.didEditingStyle = cb;
}

- (void)didEditActions:(CCTableHelperDidEditActionsBlock)cb
{
    self.didEditActionsBlock = cb;
}

- (void)didMoveToRowBlock:(CCTableHelperDidMoveToRowBlock)cb
{
    self.didMoveToRowBlock = cb;
}

- (void)cellWillDisplay:(CCTableHelperDidWillDisplayBlock)cb
{
    self.didWillDisplayBlock = cb;
}

- (void)ccScrollViewWillBeginDragging:(CCScrollViewWillBeginDragging)block
{
    self.scrollViewBdBlock = block;
}

- (void)headerView:(CCTableHelperHeaderBlock)cb
{
    self.headerBlock = cb;
}

- (void)headerTitle:(CCTableHelperTitleHeaderBlock)cb
{
    self.headerTitleBlock = cb;
}

- (void)footerView:(CCTableHelperFooterBlock)cb
{
    self.footerBlock = cb;
}

- (void)footerTitle:(CCTableHelperTitleFooterBlock)cb
{
    self.footerTitleBlock = cb;
}

- (void)numberOfRowsInSection:(CCTableHelperNumberRows)cb
{
    self.numberRow = cb;
}

- (void)cellViewEventBlock:(CCTableHelperCellBlock)cb
{
    self.cellViewEventsBlock = cb;
}

- (void)ccScrollViewDidScroll:(CCScrollViewDidScroll)block
{
    self.scrollViewddBlock = block;
}

- (void)currentModelIndexPath:(CCTableHelperCurrentModelAtIndexPath)cb
{
    self.currentModelAtIndexPath = cb;
}

- (void)scrollViewDidEndScrolling:(CCTableHelperScrollViewDidEndScrolling)cb
{
    self.scrollViewDidEndScrolling = cb;
}

#pragma mark -
#pragma mark :.TableView DataSource Delegate

#pragma mark :. TableView Gourps Count
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
        if (self.numberRow)
            curNumOfRows = self.numberRow(tableView, section, subDataAry);
        else
            curNumOfRows = subDataAry.count;
    }
    return curNumOfRows;
}

#pragma mark :. GourpsView
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = self.titleHeaderHeight;
    if (self.headerBlock) {
        
        UIView *headerView = self.headerBlock(tableView, section, [self currentSectionModel:section]);
        if (headerView)
            height = headerView.LayoutSizeFittingSize.height;
    }
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *hederView = nil;
    if (self.headerBlock) {
        hederView = self.headerBlock(tableView, section, [self currentSectionModel:section]);
    }
    return hederView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    if (self.headerTitleBlock)
        title = self.headerTitleBlock(tableView, section);
    
    return title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = self.titleFooterHeight;
    if (self.footerBlock) {
        UIView *footerView = self.footerBlock(tableView, section, [self currentSectionModel:section]);
        if (footerView)
            height = footerView.LayoutSizeFittingSize.height;
    }
    
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = nil;
    if (self.footerBlock) {
        footerView = self.footerBlock(tableView, section, [self currentSectionModel:section]);
    }
    return footerView;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *title = nil;
    if (self.footerTitleBlock)
        title = self.footerTitleBlock(tableView, section);
    
    return title;
}

#pragma mark :. 侧边
/**
 *  @author CC, 16-07-23
 *
 *  @brief 侧边栏字母
 */
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSArray *sectionArr = nil;
    if (self.isSection) {
        sectionArr = self.sectionIndexTitles;
    }
    return sectionArr;
}

/**
 *  @author CC, 16-07-23
 *
 *  @brief 侧边字母点击
 */
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSInteger indexs = self.sectionIndexTitles.count == [[_theCollation sectionTitles] count] ? index : index - 1;
    if ([title isEqualToString:@"{search}"]) {
        [tableView scrollRectToVisible:_searchBar.frame animated:NO];
        indexs = -1;
    }
    
    return indexs;
}

#pragma mark :. delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.paddedSeparator) {
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            [cell setPreservesSuperviewLayoutMargins:NO];
        }
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;
    if (self.didEditingStyle)
        style = self.didEditingStyle(tableView, indexPath, [self currentModelAtIndexPath:indexPath]);
    else if (self.didEditActionsBlock)
        style = UITableViewCellEditingStyleDelete;
    
    return style;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.didEditingBlock)
        self.didEditingBlock(tableView, editingStyle, indexPath, [self currentModelAtIndexPath:indexPath]);
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = nil;
    if (self.didEditTileBlock)
        title = self.didEditTileBlock(tableView, indexPath, [self currentModelAtIndexPath:indexPath]);
    
    return title;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *ary = [NSArray array];
    if (self.didEditActionsBlock)
        ary = self.didEditActionsBlock(tableView, indexPath, [self currentModelAtIndexPath:indexPath]);
    
    return ary;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat curHeight = 0;
    if (tableView.cc_autoSizingCell) {
        id curModel = [self currentModelAtIndexPath:indexPath];
        NSString *curCellIdentifier = [self cellIdentifierForRowAtIndexPath:indexPath model:curModel];
        @weakify(self);
        curHeight = [tableView cc_heightForCellWithIdentifier:curCellIdentifier cacheByIndexPath:indexPath configuration:^(id cell) {
            @strongify(self);
            if (self.didWillDisplayBlock) {
                self.didWillDisplayBlock(cell, indexPath, curModel,NO);
            } else if ([cell respondsToSelector:@selector(cc_cellWillDisplayWithModel:indexPath:)]) {
                [cell cc_cellWillDisplayWithModel:curModel indexPath:indexPath];
            }
        }];
    } else {
        curHeight = tableView.rowHeight;
    }
    return curHeight;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.isCanMoveRow;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (self.didMoveToRowBlock) {
        id sourceModel = [self currentModelAtIndexPath:sourceIndexPath];
        id destinationModel = [self currentModelAtIndexPath:destinationIndexPath];
        self.didMoveToRowBlock(tableView, sourceIndexPath, sourceModel, destinationIndexPath, destinationModel);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *curCell = nil;
    id curModel = [self currentModelAtIndexPath:indexPath];
    NSString *curCellIdentifier = [self cellIdentifierForRowAtIndexPath:indexPath model:curModel];
    curCell = [tableView dequeueReusableCellWithIdentifier:curCellIdentifier forIndexPath:indexPath];
    CCAssert(curCell, @"cell is nil Identifier ⤭ %@ ⤪", curCellIdentifier);
    
    if (self.didWillDisplayBlock) {
        self.didWillDisplayBlock(curCell, indexPath, curModel, YES);
    } else if ([curCell respondsToSelector:@selector(cc_cellWillDisplayWithModel:indexPath:)]) {
        [curCell cc_cellWillDisplayWithModel:curModel indexPath:indexPath];
    }
    
    if (self.cellDelegate)
        curCell.viewDelegate = self.cellDelegate;
    
    if (self.cellViewEventsBlock)
        curCell.viewEventsBlock = self.cellViewEventsBlock;
    
    return curCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.cc_indexPath = indexPath;
    
    if (self.isAntiHurry) {
        self.timeInterval = self.timeInterval == 0 ? defaultInterval : self.timeInterval;
        if (self.isIgnoreEvent) {
            return;
        } else if (self.timeInterval > 0) {
            [self performSelector:@selector(resetState) withObject:nil afterDelay:self.timeInterval];
        }
        
        self.isIgnoreEvent = YES;
    }
    if (self.didSelectBlock) {
        id curModel = [self currentModelAtIndexPath:indexPath];
        self.didSelectBlock(tableView, indexPath, curModel);
    }
}

- (void)resetState
{
    self.isIgnoreEvent = NO;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.cc_indexPath = indexPath;
    if (self.didDeSelectBlock) {
        id curModel = [self currentModelAtIndexPath:indexPath];
        self.didDeSelectBlock(tableView, indexPath, curModel);
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.scrollViewBdBlock)
        self.scrollViewBdBlock(scrollView);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.scrollViewddBlock)
        self.scrollViewddBlock(scrollView);
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollViewDidEndScrollingAnimation:) object:scrollView];
    [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:scrollView afterDelay:0.5];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollViewDidEndScrollingAnimation:) object:scrollView];
    if (self.scrollViewDidEndScrolling && scrollView)
        self.scrollViewDidEndScrolling(scrollView);
}

#pragma mark :. handle

//section 头部,为了IOS6的美化
- (UIView *)tableViewSectionView:(UITableView *)tableView section:(NSInteger)section
{
    UIView *customHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.cc_tableView.bounds), self.titleHeaderHeight)];
    customHeaderView.backgroundColor = [UIColor colorWithRed:0.926 green:0.920 blue:0.956 alpha:1.000];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 0, CGRectGetWidth(customHeaderView.bounds) - 15.0f, self.titleHeaderHeight)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    headerLabel.textColor = [UIColor darkGrayColor];
    [customHeaderView addSubview:headerLabel];
    
    if (self.isSection) {
        BOOL showSection = NO;
        showSection = [tableView numberOfRowsInSection:section] != 0;
        headerLabel.text = (showSection) ? (self.sectionIndexTitles.count == [[_theCollation sectionTitles] count] ? [_sectionIndexTitles objectAtIndex:section] : [_sectionIndexTitles objectAtIndex:section + 1]) : nil;
    }
    return customHeaderView;
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
    [self.cc_tableView reloadData];
}

- (void)cc_reloadGroupDataAry:(NSArray *)newDataAry
                   forSection:(NSInteger)cSection
{
    if (newDataAry.count == 0) return;
    
    NSMutableArray *subAry = self.dataArray[cSection];
    if (subAry.count) [subAry removeAllObjects];
    [subAry addObjectsFromArray:newDataAry];
    
    [self.cc_tableView beginUpdates];
    [self.cc_tableView reloadSections:[NSIndexSet indexSetWithIndex:cSection] withRowAnimation:UITableViewRowAnimationNone];
    [self.cc_tableView endUpdates];
}

- (void)cc_addGroupDataAry:(NSArray *)newDataAry
{
    [self.dataArray addObject:[NSMutableArray arrayWithArray:newDataAry]];
    [self.cc_tableView reloadData];
}

- (void)cc_insertGroupDataAry:(NSArray *)newDataAry
                   forSection:(NSInteger)cSection
{
    [self.dataArray insertObject:[NSMutableArray arrayWithArray:newDataAry] atIndex:cSection == -1 ? 0 : cSection];
    [self.cc_tableView reloadData];
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
    [self.cc_tableView reloadData];
}

- (void)cc_deleteGroupData:(NSInteger)cSection
{
    NSMutableArray *subAry = self.dataArray[cSection];
    if (subAry.count) [subAry removeAllObjects];
    
    [self.cc_tableView beginUpdates];
    [self.cc_tableView deleteSections:[NSIndexSet indexSetWithIndex:cSection] withRowAnimation:UITableViewRowAnimationNone];
    [self.cc_tableView endUpdates];
}

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
    [self.cc_tableView reloadData];
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
    
    [self.cc_tableView beginUpdates];
    if (curIndexSet) {
        [self.cc_tableView insertSections:curIndexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self.cc_tableView reloadSections:[NSIndexSet indexSetWithIndex:cSection] withRowAnimation:UITableViewRowAnimationNone];
    }
    [self.cc_tableView endUpdates];
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
        [self.cc_tableView beginUpdates];
        [self.cc_tableView insertSections:curIndexSet withRowAnimation:UITableViewRowAnimationNone];
        [self.cc_tableView endUpdates];
    } else {
        __block NSMutableArray *curIndexPaths = [NSMutableArray arrayWithCapacity:newDataAry.count];
        [newDataAry enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [curIndexPaths addObject:[NSIndexPath indexPathForRow:subAry.count+idx inSection:cSection]];
        }];
        [subAry addObjectsFromArray:newDataAry];
        [self.cc_tableView beginUpdates];
        [self.cc_tableView insertRowsAtIndexPaths:curIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.cc_tableView endUpdates];
    }
}

- (void)cc_insertData:(id)cModel AtIndex:(NSIndexPath *)cIndexPath;
{
    
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
        [self.cc_tableView insertRowsAtIndexPaths:@[ cIndexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.cc_tableView endUpdates];
    }
}

- (void)cc_deleteDataAtIndex:(NSIndexPath *)cIndexPath
{
    [self cc_deleteDataAtIndexs:@[ cIndexPath ]];
}

- (void)cc_deleteDataAtIndexs:(NSArray *)indexPaths
{
    NSMutableArray *delArray = [NSMutableArray array];
    for (NSArray *arr in self.dataArray) {
        NSMutableArray *sectionArray = [NSMutableArray array];
        [sectionArray addObjectsFromArray:arr];
        [delArray addObject:sectionArray];
    }
    
    for (NSIndexPath *indexPath in indexPaths) {
        if (self.dataArray.count <= indexPath.section) continue;
        NSMutableArray *subAry = self.dataArray[indexPath.section];
        if (subAry.count <= indexPath.row) continue;
        
        [[delArray objectAtIndex:indexPath.section] removeObject:[subAry objectAtIndex:indexPath.row]];
    }
    self.dataArray = delArray;
    
    [self.cc_tableView beginUpdates];
    [self.cc_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.cc_tableView endUpdates];
}

- (void)cc_replaceDataAtIndex:(id)model
                    IndexPath:(NSIndexPath *)cIndexPath
{
    if (self.dataArray.count > cIndexPath.section) {
        NSMutableArray *subDataAry = self.dataArray[cIndexPath.section];
        if (subDataAry.count > cIndexPath.row) {
            [subDataAry replaceObjectAtIndex:cIndexPath.row withObject:model];
            [self.cc_tableView reloadRowsAtIndexPaths:@[ cIndexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
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


@end
