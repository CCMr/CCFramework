//
//  CCTableViewManger.h
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

typedef CGFloat (^heightForRowAtIndexPath)(NSIndexPath *indexPath, id item);

typedef void (^didSelectRowAtIndexPath)(NSIndexPath *indexPath, id item);

typedef UITableViewCell * (^cellForRowAtIndexPath)(NSIndexPath *indexPath);

@class BaseViewModel;

@interface CCTableViewManger : NSObject

/**
 *  @author CC, 16-03-09
 *  
 *  @brief cell的可重用标识符
 */
@property(nonatomic, copy) NSString *cellIdentifier;

/**
 *  @author CC, 16-03-09
 *  
 *  @brief 获取行高(默认自适应高度)
 */
@property(nonatomic, copy) heightForRowAtIndexPath heightForRowBlock;

/**
 *  @author CC, 16-03-09
 *  
 *  @brief 选中行
 */
@property(nonatomic, copy) didSelectRowAtIndexPath didSelectCellBlock;

/**
 *  @author CC, 16-03-09
 *  
 *  @brief 创建Cell回调函数（一般用于多种Cell显示，需要实现该函数）
 */
@property(nonatomic, copy) cellForRowAtIndexPath cellForRowBlock;

/**
 *  @author CC, 16-03-09
 *  
 *  @brief TableView的ViewModel
 */
@property(nonatomic, strong) BaseViewModel *viewModel;

/**
 *  @author CC, 16-03-09
 *  
 *  @brief 处理UITableView数据源与委托
 *
 *  @param tableView UItableView
 */
- (void)handleTableViewDatasourceAndDelegate:(UITableView *)tableView;

/**
 *  @author CC, 16-03-09
 *  
 *  @brief 初始化
 *
 *  @param viewModel          逻辑Model
 *  @param cellIdentifier     Cell重用标示符
 *  @param didSelectCellBlock Cell选中回调
 */
- (instancetype)initWithViewModel:(BaseViewModel *)viewModel
                   CellIdentifier:(NSString *)cellIdentifier
               DidSelectCellBlock:(didSelectRowAtIndexPath)didSelectCellBlock;

/**
 *  @author CC, 16-03-09
 *  
 *  @brief 初始化
 *
 *  @param viewModel          逻辑Model
 *  @param cellIdentifier     Cell重用标示符
 *  @param heightForRowBlock  Cell行高回调
 *  @param didSelectCellBlock Cell选中回调
 */
- (instancetype)initWithViewModel:(BaseViewModel *)viewModel
                   CellIdentifier:(NSString *)cellIdentifier
                HeightForRowBlock:(heightForRowAtIndexPath)heightForRowBlock
               DidSelectCellBlock:(didSelectRowAtIndexPath)didSelectCellBlock;

/**
 *  @author CC, 16-03-09
 *  
 *  @brief 初始化
 *
 *  @param viewModel          逻辑Model
 *  @param heightForRowBlock  Cell行高回调
 *  @param didSelectCellBlock Cell选中回调
 *  @param cellForRowBlock    创建Cell回调
 */
- (instancetype)initWithViewModel:(BaseViewModel *)viewModel
                HeightForRowBlock:(heightForRowAtIndexPath)heightForRowBlock
               DidSelectCellBlock:(didSelectRowAtIndexPath)didSelectCellBlock
                  CellForRowBlock:(cellForRowAtIndexPath)cellForRowBlock;

@end
