//
//  CCDebugHttpViewController.m
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

#import "CCDebugHttpViewController.h"
#import "CCDebugTool.h"
#import "CCDebugHttpDetailViewController.h"
#import "CCDebugHttpDataSource.h"

@interface CCDebugHttpViewController () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, weak) UITableView *httpViewTableView;
@property(nonatomic, strong) NSArray *dataArray;

@end

@implementation CCDebugHttpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initControl];
    [self initLoadData];
}

- (void)initNavigation
{
    self.title = @"HTTP";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(dismissViewController)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStyleDone target:self action:@selector(clearAction)];
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initControl
{
    UITableView *httpViewTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    httpViewTableView.backgroundColor = [UIColor clearColor];
    httpViewTableView.delegate = self;
    httpViewTableView.dataSource = self;
    httpViewTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    httpViewTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.httpViewTableView = httpViewTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:kCCNotifyKeyReloadHttp object:nil];
}

- (void)clearAction
{
    [[CCDebugHttpDataSource manager] clear];
    self.dataArray = nil;
    [self.httpViewTableView reloadData];
}

- (void)initLoadData
{
    self.dataArray = [[[CCDebugHttpDataSource manager] httpArray] copy];
    [self.httpViewTableView reloadData];
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifer = @"httpcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifer];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = [CCDebugTool manager].mainColor;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:19];
    }
    
    CCDebugHttpModel *model = [self.dataArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = model.url.host;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", model.method, model.totalDuration];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CCDebugHttpDetailViewController *viewController = [[CCDebugHttpDetailViewController alloc] init];
    viewController.hidesBottomBarWhenPushed = YES;
    viewController.detail = [self.dataArray objectAtIndex:indexPath.row];
    [self pushNewViewController:viewController];
}

@end
