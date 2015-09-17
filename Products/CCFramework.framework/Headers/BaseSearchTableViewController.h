//
//  BaseSearchTableViewController.h
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


#import "BaseTableViewController.h"

@interface BaseSearchTableViewController : BaseTableViewController

/**
 *  @author CC, 15-08-21
 *
 *  @brief  搜索结果数据源
 *
 *  @since <#1.0#>
 */
@property (nonatomic, strong) NSMutableArray *filteredDataSource;

/**
 *  @author CC, 15-08-21
 *
 *  @brief  判断TableView是否为搜索控制器的TableView
 *
 *  @param tableView 被判断的目标TableView对象
 *
 *  @return 返回是否为预想结果
 *
 *  @since <#1.0#>
 */
- (BOOL)enableForSearchTableView:(UITableView *)tableView;

/**
 *  @author CC, 15-08-21
 *
 *  @brief  获取搜索框的文本
 *
 *  @return 返回文本对象
 *
 *  @since 1.0
 */
- (NSString *)getSearchBarText;

/**
 *  @author CC, 15-08-21
 *
 *  @brief  查找搜索框目前文本是否为搜索目标文本
 *
 *  @param searchText 搜索框的文本
 *  @param scope      搜索范围
 *
 *  @since 1.0
 */
- (void)filterContentForSearchText: (NSString *)searchText
                             scope: (NSString *)scope;

/**
 *  @author CC, 15-09-10
 *
 *  @brief  添加索引
 *
 *  @param title 索引标题
 *  @param index 插入下标
 *
 *  @since 1.0
 */
- (void)insetSectionIndexTitles: (NSString *)title
                          Index: (int)index;

@end
