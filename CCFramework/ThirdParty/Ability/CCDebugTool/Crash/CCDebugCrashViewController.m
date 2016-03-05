//
//  CCDebugCrashViewController.m
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

#import "CCDebugCrashViewController.h"
#import "CCDebugContentViewController.h"
#import "CCDebugTool.h"
#import "CCDebugCrashHelper.h"

@interface CCDebugCrashViewController () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, weak) UITableView *crashTableView;
@property(nonatomic, strong) NSArray *dataArray;

@end

@implementation CCDebugCrashViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initControl];
}

- (void)initNavigation
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(dismissViewController)];
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initControl
{
    
    self.dataArray = [[CCDebugCrashHelper manager] obtainCrashLogs];
    
    UITableView *crashTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    crashTableView.backgroundColor = [UIColor clearColor];
    crashTableView.delegate = self;
    crashTableView.dataSource = self;
    crashTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    crashTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_crashTableView = crashTableView];
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
    static NSString *identifer = @"crashcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifer];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [CCDebugTool manager].mainColor;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:19];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    }
    
    NSDictionary *dic = [self.dataArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [dic objectForKey:@"ErrDate"];
    cell.detailTextLabel.text = [dic objectForKey:@"type"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CCDebugContentViewController *viewController = [[CCDebugContentViewController alloc] init];
    viewController.title = @"Crash日志";
    viewController.hidesBottomBarWhenPushed = YES;
    viewController.content = [[self.dataArray objectAtIndex:indexPath.row] objectForKey:@"ErrMsg"];
    [self pushNewViewController:viewController];
}

@end
