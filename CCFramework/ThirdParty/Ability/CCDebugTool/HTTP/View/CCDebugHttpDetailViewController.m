//
//  CCDebugHttpDetailViewController.m
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

#import "CCDebugHttpDetailViewController.h"
#import "CCDebugContentViewController.h"
#import "CCDebugTool.h"

#define detailTitles @[ @"Request Url", @"Method", @"Status Code", @"Mime Type", @"Start Time", @"Total Duration", @"Request Body", @"Response Body" ]

@interface CCDebugHttpDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) UITableView *httpDetailtableView;
@property(nonatomic, strong) NSArray *dataArray;

@end

@implementation CCDebugHttpDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"详情";
    [self initControl];
}

- (void)initControl
{
    self.httpDetailtableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.httpDetailtableView.backgroundColor = [UIColor clearColor];
    self.httpDetailtableView.delegate = self;
    self.httpDetailtableView.dataSource = self;
    self.httpDetailtableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.httpDetailtableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.httpDetailtableView];
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return detailTitles.count;
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
    static NSString *identifer = @"httpDetailIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifer];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [CCDebugTool manager].mainColor;
    }
    
    NSString *value = @"";
    if (indexPath.row == 0) {
        value = self.detail.url.absoluteString;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.row == 1) {
        value = self.detail.method;
    } else if (indexPath.row == 2) {
        value = self.detail.statusCode;
    } else if (indexPath.row == 3) {
        value = self.detail.mineType;
    } else if (indexPath.row == 4) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        value = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.detail.startTime.doubleValue]];
    } else if (indexPath.row == 5) {
        value = self.detail.totalDuration;
    } else if (indexPath.row == 6) {
        if (self.detail.requestBody.length > 0) {
            value = @"Tap to view";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            value = @"Empty";
        }
    } else if (indexPath.row == 7) {
        if (self.detail.responseBody.length > 0) {
            value = @"Tap to view";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            value = @"Empty";
        }
    }
    
    cell.textLabel.text = [detailTitles objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:19];
    
    cell.detailTextLabel.text = value;
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CCDebugContentViewController *vc = [[CCDebugContentViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    if (indexPath.row == 0) {
        vc.content = self.detail.url.absoluteString;
        vc.title = @"接口地址";
    } else if (indexPath.row == 6 && self.detail.requestBody.length > 0) {
        vc.content = self.detail.requestBody;
        vc.title = @"请求数据";
    } else if (indexPath.row == 7 && self.detail.responseBody.length > 0) {
        vc.content = self.detail.responseBody;
        vc.title = @"返回数据";
    } else {
        return;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

@end
