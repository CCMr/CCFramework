//
//  CCTableViewManger.m
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

#import "CCTableViewManger.h"
#import "BaseViewModel.h"
#import "UITableViewCell+Additions.h"
#import "UITableView+Additions.h"
#import "CCProgressHUD.h"

@interface CCTableViewManger () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation CCTableViewManger

- (instancetype)initWithViewModel:(BaseViewModel *)viewModel
                   CellIdentifier:(NSString *)cellIdentifier
               DidSelectCellBlock:(didSelectRowAtIndexPath)didSelectCellBlock
{
    return [self initWithViewModel:viewModel
                    CellIdentifier:cellIdentifier
                 HeightForRowBlock:nil
                DidSelectCellBlock:didSelectCellBlock];
}

- (instancetype)initWithViewModel:(BaseViewModel *)viewModel
                   CellIdentifier:(NSString *)cellIdentifier
                HeightForRowBlock:(heightForRowAtIndexPath)heightForRowBlock
               DidSelectCellBlock:(didSelectRowAtIndexPath)didSelectCellBlock
{
    if (self = [super init]) {
        self.viewModel = viewModel;
        self.cellIdentifier = cellIdentifier;
        self.heightForRowBlock = heightForRowBlock;
        self.didSelectCellBlock = didSelectCellBlock;
    }
    return self;
}


- (instancetype)initWithViewModel:(BaseViewModel *)viewModel
                HeightForRowBlock:(heightForRowAtIndexPath)heightForRowBlock
               DidSelectCellBlock:(didSelectRowAtIndexPath)didSelectCellBlock
                  CellForRowBlock:(cellForRowAtIndexPath)cellForRowBlock
{
    if (self = [super init]) {
        self.viewModel = viewModel;
        self.heightForRowBlock = heightForRowBlock;
        self.didSelectCellBlock = didSelectCellBlock;
        self.cellForRowBlock = cellForRowBlock;
    }
    return self;
}


- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.viewModel.cc_dataArray[indexPath.row];
}

/**
 *  @author CC, 16-03-09
 *  
 *  @brief 处理UITableView数据源与委托
 *
 *  @param tableView UItableView
 */
- (void)handleTableViewDatasourceAndDelegate:(UITableView *)tableView
{
    tableView.delegate = self;
    tableView.dataSource = self;
    
    if (!self.cellForRowBlock && self.cellIdentifier)
        [UITableViewCell registerTable:tableView nibIdentifier:self.cellIdentifier];
    
    if (self.viewModel) {
        __weak typeof(tableView) weakTable = tableView;
        [self.viewModel cc_viewModelWithDataSuccessHandler:^(BOOL isSuccess, NSString *info){
            if (isSuccess)
                [weakTable reloadData];
            else
                [CCProgressHUD hudMessages:nil DetailsLabelText:info];

        }];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.viewModel cc_viewModelWithNumberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self itemAtIndexPath:indexPath];
    
    UITableViewCell *Cell = nil;
    if (self.cellForRowBlock) {
        Cell = self.cellForRowBlock(indexPath);
    } else
        Cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    [Cell configure:Cell customObj:item indexPath:indexPath];
    return Cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self itemAtIndexPath:indexPath];
    
    CGFloat height;
    if (self.heightForRowBlock) {
        height = self.heightForRowBlock(indexPath, item);
    } else {
        __weak typeof(self) weakSelf = self;
        height = [tableView cc_heightForCellWithIdentifier:weakSelf.cellIdentifier cacheByIndexPath:indexPath configuration:^(UITableViewCell *cell) {
            [cell configure:cell customObj:item indexPath:indexPath];
        }];
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id item = [self itemAtIndexPath:indexPath];
    self.didSelectCellBlock(indexPath, item);
}


@end
