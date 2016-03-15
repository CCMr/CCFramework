//
//  BaseTableViewController.h
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


#import "BaseViewController.h"

@interface BaseTableViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource>

/**
 *  @author CC, 15-08-18
 *
 *  @brief  显示大量数据的控件
 */
@property(nonatomic, strong) UITableView *tableView;

/**
 *  @author CC, 15-08-18
 *
 *  @brief  初始化init的时候设置tableView的样式才有效
 */
@property(nonatomic, assign) UITableViewStyle tableViewStyle;

/**
 *  @author CC, 15-08-18
 *
 *  @brief  数组数据源
 */
@property(nonatomic, strong) NSMutableArray *ArrayDataSource;

/**
 *  @author CC, 15-08-18
 *
 *  @brief  去除iOS7新的功能api，tableView的分割线变成iOS6正常的样式
 */
- (void)configuraTableViewNormalSeparatorInset;

/**
 *  @author CC, 15-08-18
 *
 *  @brief   配置tableView右侧的index title 背景颜色，因为在iOS7有白色底色，iOS6没有
 *
 *  @param tableView 目标tableView
 */
- (void)configuraSectionIndexBackgroundColorWithTableView:(UITableView *)tableView;

/**
 *  @author CC, 15-08-18
 *
 *  @brief  加载本地或者网络数据源
 */
- (void)loadDataSource;

@end
