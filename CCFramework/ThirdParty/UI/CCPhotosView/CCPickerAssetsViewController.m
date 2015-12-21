//
//  CCPickerAssetsViewController.m
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

#import "CCPickerAssetsViewController.h"
#import "CCPickerCollectionView.h"
#import "CCPickerCollectionViewCell.h"
#import "CCPickerDatas.h"
#import "CCPhotoBrowser.h"
#import "UIButton+BUIButton.h"
#import "UIControl+BUIControl.h"
#import "Config.h"

#define HW ((winsize.width - 20 - 30) / 4)

@interface CCPickerAssetsViewController () <CCPhotoBrowserDelegate, CCPickerCollectionViewDelegate>

@property(nonatomic, strong) UIView *toolbarView;
@property(nonatomic, strong) UIButton *previewBtn;
@property(nonatomic, strong) UIButton *sendBtn;
@property(nonatomic, strong) UILabel *sendCountLabel;

@property(nonatomic, assign) BOOL IsPreview;

@property(nonatomic, strong) CCPickerCollectionView *collectionView;
// 记录选中的assets
@property(nonatomic, strong) NSMutableArray *selectAssets;

@property(nonatomic, strong) NSMutableArray *BrowseArray;

@end

@implementation CCPickerAssetsViewController

- (void)setAssetsGroup:(CCPickerGroup *)assetsGroup
{
    if (!assetsGroup.groupName.length) return;
    
    _assetsGroup = assetsGroup;
    
    NSString *GroupName = assetsGroup.groupName;
    if ([GroupName isEqualToString:@"Saved Photos"])
        GroupName = @"存储的照片";
    else if ([GroupName isEqualToString:@"Camera Roll"])
        GroupName = @"相机胶卷";
    self.title = GroupName;
    
    self.view.backgroundColor = [UIColor whiteColor];
    // 获取Assets
    [self InitLoadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self InitNavigation];
    [self InitControl];
}

#pragma mark - 初始化导航栏
- (void)InitNavigation
{
    UIButton *NavRightBtn = [UIButton buttonWith];
    [self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] init] initWithCustomView:NavRightBtn]];
    
    [NavRightBtn setTitle:@"取消" forState:UIControlStateNormal];
    [NavRightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    @weakify(self);
    [NavRightBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark - 初始化页面控件
- (void)InitControl
{
    _toolbarView = [[UIView alloc] initWithFrame:CGRectMake(0, winsize.height - 54, winsize.width, 50)];
    [self.view addSubview:_toolbarView];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winsize.width, .5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [_toolbarView addSubview:line];
    
    
    _previewBtn = [UIButton buttonWithTitle:@"预览"];
    [_previewBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_previewBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    _previewBtn.enabled = NO;
    _previewBtn.alpha = .5;
    _previewBtn.frame = CGRectMake(10, 5, 50, 40);
    UIImageView *images = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    [_previewBtn addSubview:images];
    @weakify(self);
    [_previewBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        @strongify(self);
        _IsPreview = YES;
        NSMutableArray *array = [NSMutableArray array];
        [self.collectionView.selectAsstes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CCPhoto *photo = obj;
            photo.srcImageView = images;
            photo.IsIndex = YES;
            photo.selectd = [self.collectionView.selectAsstes containsObject:obj] ? YES : NO;
            photo.asssetIndex = [[self.collectionView.selectsIndexPath objectAtIndex:idx] integerValue];
            [array addObject:photo];
        }];
        
        CCPhotoBrowser *browser = [[CCPhotoBrowser alloc] initWithNavigationBar];
        browser.photos = array;
        browser.currentPhotoIndex = 0;
        browser.delegate = self;
        [browser show];
    }];
    [_toolbarView addSubview:_previewBtn];
    
    _sendCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(winsize.width - 80, 13, 25, 25)];
    _sendCountLabel.backgroundColor = cc_ColorRGBA(0, 204, 51, 1);
    _sendCountLabel.layer.cornerRadius = 13;
    _sendCountLabel.layer.masksToBounds = YES;
    _sendCountLabel.textColor = [UIColor whiteColor];
    _sendCountLabel.textAlignment = NSTextAlignmentCenter;
    _sendCountLabel.hidden = YES;
    [_toolbarView addSubview:_sendCountLabel];
    
    _sendBtn = [UIButton buttonWithTitle:@"确定"];
    [_sendBtn setTitleColor:cc_ColorRGBA(0, 204, 51, 1) forState:UIControlStateNormal];
    [_sendBtn setTitleColor:cc_ColorRGBA(0, 204, 51, 1) forState:UIControlStateHighlighted];
    _sendBtn.frame = CGRectMake(winsize.width - 60, 5, 50, 40);
    _sendBtn.enabled = NO;
    _sendBtn.alpha = .5;
    [_sendBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        @strongify(self);
        [self Complete];
    }];
    [_toolbarView addSubview:_sendBtn];
}

#pragma mark - 初始化数据
- (void)InitLoadData
{
    if (!self.BrowseArray)
        self.BrowseArray = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;
    [[CCPickerDatas defaultPicker] getGroupPhotosWithGroup:self.assetsGroup Finished:^(NSArray *assets) {
        [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CCPhoto *photo = [[CCPhoto alloc] init];
            photo.assets = obj;
            [weakSelf.BrowseArray addObject:photo];
        }];
        weakSelf.collectionView.dataArray = weakSelf.BrowseArray;
    }];
}

#pragma mark collectionView
/**
 *  @author CC, 2015-06-04 20:06:36
 *
 *  @brief  初始化显示页面
 */
- (CCPickerCollectionView *)collectionView
{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(HW, HW);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 4;
        
        CCPickerCollectionView *collectionView = [[CCPickerCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [collectionView registerClass:[CCPickerCollectionViewCell class] forCellWithReuseIdentifier:@"CCPickerCollectionViewCell"];
        collectionView.contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
        collectionView.collectionViewDelegate = self;
        [self.view insertSubview:_collectionView = collectionView belowSubview:_toolbarView];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(collectionView);
        
        NSString *widthVfl = @"H:|-0-[collectionView]-0-|";
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthVfl options:0 metrics:nil views:views]];
        
        NSString *heightVfl = @"V:|-0-[collectionView]-50-|";
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightVfl options:0 metrics:nil views:views]];
    }
    return _collectionView;
}

/**
 *  @author CC, 2015-06-04 19:06:52
 *
 *  @brief  图片选中记录
 */
- (void)pickerCollectionViewDidSelected:(CCPickerCollectionView *)pickerCollectionView
{
    [self Judge:pickerCollectionView.selectAsstes.count];
}

/**
 *  @author CC, 2015-06-04 19:06:22
 *
 *  @brief  改变页面记录
 *
 *  @param count <#count description#>
 *
 *  @since 1.0
 */
- (void)Judge:(NSInteger)count
{
    _sendCountLabel.hidden = !count;
    _sendCountLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
    _previewBtn.enabled = !_sendCountLabel.hidden;
    _previewBtn.alpha = _previewBtn.enabled ? 1 : .5;
    _sendBtn.enabled = !_sendCountLabel.hidden;
    _sendBtn.alpha = _sendBtn.enabled ? 1 : .5;
}

/**
 *  @author CC, 2015-06-04 19:06:41
 *
 *  @brief  图片预览委托
 *
 *  @param pickerCollectionView <#pickerCollectionView description#>
 *  @param index                <#index description#>
 *
 *  @since 1.0
 */
- (void)pickerCollectionviewDidPreview:(CCPickerCollectionView *)pickerCollectionView
                                 Index:(NSInteger)index
{
    [self.BrowseArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CCPhoto *photo = obj;
        photo.srcImageView = pickerCollectionView.selectImageView;
        photo.selectd = [self.collectionView.selectAsstes containsObject:obj] ? YES : NO;
        [self.BrowseArray replaceObjectAtIndex:idx withObject:photo];
    }];
    
    CCPhotoBrowser *browser = [[CCPhotoBrowser alloc] initWithNavigationBar];
    browser.photos = self.BrowseArray;
    browser.currentPhotoIndex = index;
    browser.delegate = self;
    [browser show];
}

#pragma mark - CCPhotBrowser
/**
 *  @author CC, 2015-06-04 19:06:02
 *
 *  @brief  预览页面选中与取消委托
 *
 *  @param index <#index description#>
 *
 *  @since 1.0
 */
- (void)didSelectd:(NSUInteger)index
{
    BOOL bol = [self.collectionView.selectsIndexPath containsObject:@(index)];
    if (bol) {
        [self.collectionView.selectsIndexPath removeObject:@(index)];
        [self.collectionView.selectAsstes removeObject:self.collectionView.dataArray[index]];
    } else {
        [self.collectionView.selectsIndexPath addObject:@(index)];
        [self.collectionView.selectAsstes addObject:self.collectionView.dataArray[index]];
    }
    [self Judge:self.collectionView.selectAsstes.count];
    [self.collectionView reloadData];
}

/**
 *  @author CC, 2015-06-04 19:06:29
 *
 *  @brief  预览页面完成委托
 *
 *  @param index <#index description#>
 *
 *  @since 1.0
 */
- (void)didComplete:(NSUInteger)index
{
    if (![self.collectionView.selectsIndexPath containsObject:@(index)]) {
        [self.collectionView.selectsIndexPath addObject:@(index)];
        [self.collectionView.selectAsstes addObject:self.collectionView.dataArray[index]];
    }
    
    [self Complete];
}

/**
 *  @author CC, 2015-06-04 19:06:35
 *
 *  @brief  完成图片选择
 *
 *  @since 1.0
 */
- (void)Complete
{
    NSMutableArray *SelectImageArray = [NSMutableArray array];
    [self.collectionView.selectAsstes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CCPhoto *photo = obj;
        [SelectImageArray addObject:photo.image];
    }];
    cc_NoticePost(@"CC_PICKER_TAKE_DONE", SelectImageArray);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
