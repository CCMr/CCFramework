//
//  BaseTableViewController.m
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
#import "CCFoundationCommon.h"
#import "Config.h"

@interface BaseTableViewController ()

/**
 *  @author CC, 15-08-18
 *
 *  @brief  判断tableView是否支持iOS7的api方法
 *
 *  @return 返回预想结果
 *
 *  @since <#1.0#>
 */
- (BOOL)validateSeparatorInset;

@end

@implementation BaseTableViewController

#pragma mark - Publish Method

- (void)configuraTableViewNormalSeparatorInset
{
    if ([self validateSeparatorInset]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
}

- (void)configuraSectionIndexBackgroundColorWithTableView:(UITableView *)tableView
{
    if ([tableView respondsToSelector:@selector(setSectionIndexBackgroundColor:)]) {
        tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    }
}

- (void)loadDataSource
{
    // subClasse
}

#pragma mark - Propertys

- (UITableView *)tableView
{
    if (!_tableView) {
        CGRect tableViewFrame = self.view.bounds;
        tableViewFrame.size.height -= (self.navigationController.viewControllers.count > 1 ? 0 : (CGRectGetHeight(self.tabBarController.tabBar.bounds))) + [CCFoundationCommon getAdapterHeight];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, winsize.width, winsize.height - 64 - (self.hidesBottomBarWhenPushed ? 0 : 50)) style:self.tableViewStyle];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        if (![self validateSeparatorInset]) {
            if (self.tableViewStyle == UITableViewStyleGrouped) {
                UIView *backgroundView = [[UIView alloc] initWithFrame:_tableView.bounds];
                backgroundView.backgroundColor = _tableView.backgroundColor;
                _tableView.backgroundView = backgroundView;
            }
        }
    }
    return _tableView;
}

- (NSMutableArray *)ArrayDataSource
{
    if (!_ArrayDataSource) {
        _ArrayDataSource = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return _ArrayDataSource;
}

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)dealloc
{
    self.ArrayDataSource = nil;
    self.tableView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Helper Method

- (BOOL)validateSeparatorInset
{
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        return YES;
    }
    return NO;
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.ArrayDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // in subClass
    return nil;
}


@end
