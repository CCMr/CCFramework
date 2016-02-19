//
//  CCPickerGroupViewController.m
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

#import "CCPickerGroupViewController.h"
#import "CCPickerAssetsViewController.h"
#import "CCPickerDatas.h"
#import "UIControl+BUIControl.h"
#import "UIButton+BUIButton.h"

@interface CCPickerGroupViewController () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) CCPickerAssetsViewController *assetsVc;

@property(nonatomic, weak) UITableView *pickrTableView;
@property(nonatomic, strong) NSArray *Groups;

@end

@implementation CCPickerGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initNavigation];
    [self initControl];
    [self initLoadData];
}

- (void)initNavigation
{
    self.title = @"照片";
    UIButton *NavRightBtn = [UIButton buttonWith];
    [self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] init] initWithCustomView:NavRightBtn]];
    
    [NavRightBtn setTitle:@"取消" forState:UIControlStateNormal];
    [NavRightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [NavRightBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)initControl
{
    UITableView *pickrTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 5, winsize.width, winsize.height - 70) style:UITableViewStylePlain];
    pickrTableView.delegate = self;
    //    pickrTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:pickrTableView];
    [self setExtraCellLineHidden:pickrTableView];
    self.pickrTableView = pickrTableView;
}

- (void)initLoadData
{
    CCPickerDatas *datas = [CCPickerDatas defaultPicker];
    __weak typeof(self) weakSelf = self;
    [datas getAllGroupWithPhotos:^(NSArray *groups) {
        self.Groups = groups;
        if (self.IsPush)
            [self jump2StatusVc];
        weakSelf.pickrTableView.dataSource = self;
        [weakSelf.pickrTableView reloadData];
    }];
}

- (CCPickerAssetsViewController *)assetsVc
{
    if (!_assetsVc) {
        _assetsVc = [[CCPickerAssetsViewController alloc] init];
        _assetsVc.minCount = self.minCount;
    }
    return _assetsVc;
}

- (void)setMinCount:(NSInteger)minCount
{
    _minCount = minCount;
    self.assetsVc.minCount = minCount;
}

#pragma mark 跳转到控制器里面的内容
- (void)jump2StatusVc
{
    // 如果是相册
    CCPickerGroup *gp = nil;
    for (CCPickerGroup *group in self.Groups) {
        if ([group.groupName isEqualToString:@"Camera Roll"] || [group.groupName isEqualToString:@"相机胶卷"]) {
            gp = group;
            break;
        }
    }
    
    if (!gp) return;
    
    self.assetsVc.assetsGroup = gp;
    self.assetsVc.minCount = self.minCount;
    [self.navigationController pushViewController:self.assetsVc animated:NO];
}

- (void)setDelegate:(id<CCPickerDelegate>)delegate
{
    _delegate = delegate;
    self.assetsVc.delegate = delegate;
}

- (void)setExtraCellLineHidden:(UITableView *)tableView
{
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:v];
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.Groups.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCPickerGroup *group = self.Groups[indexPath.row];
    CCPickerAssetsViewController *viewController = [[CCPickerAssetsViewController alloc] init];
    viewController.assetsGroup = group;
    viewController.minCount = self.minCount;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PhotosCell";
    UITableViewCell *Cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!Cell) {
        Cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        Cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        Cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    CCPickerGroup *agroup = self.Groups[indexPath.row];
    Cell.imageView.image = agroup.thumbImage;
    
    NSString *GroupName = agroup.groupName;
    if ([GroupName isEqualToString:@"Saved Photos"])
        GroupName = @"存储的照片";
    else if ([GroupName isEqualToString:@"Camera Roll"])
        GroupName = @"相机胶卷";
    Cell.textLabel.text = GroupName;
    Cell.detailTextLabel.text = [NSString stringWithFormat:@"(%ld)", (long)agroup.assetsCount];
    Cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    return Cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
