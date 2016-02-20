//
//  CCPhotoCollectionController.m
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

#import "CCPhotoCollectionController.h"
#import "CCPhotoPickerController.h"
#import "CCPhotoPreviewController.h"
#import "CCVideoPreviewController.h"
#import "CCAssetModel.h"
#import "CCPhotoManager.h"
#import "CCAssetCell.h"
#import "CCBottomBar.h"
#import "UIViewController+CCPhotoHUD.h"

@interface CCPhotoCollectionController ()

/** 底部状态栏 */
@property(nonatomic, weak) CCBottomBar *bottomBar;

/** 相册内所有的资源 */
@property(nonatomic, copy) NSArray<CCAssetModel *> *assets;
/** 选择的所有资源 */
@property(nonatomic, strong) NSMutableArray *selectedAssets;

/** 第一次进入时,自动滚动到底部 */
@property(nonatomic, assign) BOOL autoScrollToBottom;

@end

@implementation CCPhotoCollectionController

static NSString *const kCCAssetCellIdentifier = @"CCAssetCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    
    
    self.navigationItem.title = self.album.name;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(_handleCancelAction)];
    
    self.autoScrollToBottom = YES;
    self.selectedAssets = [NSMutableArray array];
    
    // 初始化collectionView的一些属性
    [self _setupCollectionView];
    
    //从相册中获取所有的资源model
    __weak typeof(*&self) wSelf = self;
    [[CCPhotoManager sharedManager] getAssetsFromResult:self.album.fetchResult pickingVideoEnable:[(CCPhotoPickerController *)self.navigationController pickingVideoEnable] completionBlock:^(NSArray<CCAssetModel *> *assets) {
        __weak typeof(*&self) self = wSelf;
        self.assets = [NSArray arrayWithArray:assets];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            __weak typeof(*&self) self = wSelf;
            [self.assets enumerateObjectsUsingBlock:^(CCAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj thumbnail];
            }];
        });
        [self.collectionView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.autoScrollToBottom ? [self.collectionView setContentOffset:CGPointMake(0, (self.assets.count / 4) * kCCThumbnailWidth)] : nil;
    self.autoScrollToBottom = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"photo collection dealloc ");
}

#pragma mark - Methods

- (void)_setupCollectionView
{
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.alwaysBounceHorizontal = NO;
    self.collectionView.contentInset = UIEdgeInsetsMake(4, 4, 44, 4);
    self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset;
    self.collectionView.contentSize = CGSizeMake(self.view.frame.size.width, ((self.assets.count + 3) / 4) * self.view.frame.size.width);
    [self.collectionView registerClass:[CCAssetCell class] forCellWithReuseIdentifier:kCCAssetCellIdentifier];
    
    CCBottomBar *bottomBar = [[CCBottomBar alloc] initWithBarType:CCCollectionBottomBar];
    bottomBar.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
    __weak typeof(*&self) wSelf = self;
    [bottomBar setConfirmBlock:^{
        __weak typeof(*&self) self = wSelf;
        [(CCPhotoPickerController *)self.navigationController didFinishPickingPhoto:self.selectedAssets];
    }];
    [self.view addSubview:self.bottomBar = bottomBar];
}

- (void)_handleCancelAction
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    CCPhotoPickerController *photoPickerVC = (CCPhotoPickerController *)self.navigationController;
    [photoPickerVC didCancelPickingPhoto];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CCAssetCell *assetCell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCAssetCellIdentifier forIndexPath:indexPath];
    [assetCell configCellWithItem:self.assets[indexPath.row]];
    __weak typeof(*&self) wSelf = self;
    
    // 设置assetCell willChangeBlock
    [assetCell setWillChangeSelectedStateBlock:^BOOL(CCAssetModel *asset) {
        __weak typeof(*&self) self = wSelf;
        if (!asset.selected) {
            CCPhotoPickerController *photoPickerC = (CCPhotoPickerController *)self.navigationController;
            if (asset.type == CCAssetTypeVideo && self.selectedAssets.count > 0) {
                NSLog(@"同时选择视频和图片,视频将作为图片发送");
                [self showAlertWithMessage:@"同时选择视频和图片,视频将作为图片发送"];
                return YES;
            }else if (self.selectedAssets.count >= photoPickerC.maxCount) {
                [self showAlertWithMessage:[NSString stringWithFormat:@"最多只能选择%zi张照片",photoPickerC.maxCount]];
                return NO;
            }
            return YES;
        }else {
            return NO;
        }
    }];
    
    // 设置assetCell didChangeBlock
    [assetCell setDidChangeSelectedStateBlock:^(BOOL selected, CCAssetModel *asset) {
        __weak typeof(*&self) self = wSelf;
        if (selected) {
            [self.selectedAssets containsObject:asset] ? nil : [self.selectedAssets addObject:asset];
            asset.selected = YES;
        }else {
            [self.selectedAssets containsObject:asset] ? [self.selectedAssets removeObject:asset] : nil;
            asset.selected = NO;
        }
        [self.bottomBar updateBottomBarWithAssets:self.selectedAssets];
    }];
    
    return assetCell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CCAssetModel *assetModel = self.assets[indexPath.row];
    if (assetModel.type == CCAssetTypeVideo) {
        CCVideoPreviewController *videoPreviewC = [[CCVideoPreviewController alloc] init];
        videoPreviewC.selectedVideoEnable = self.selectedAssets.count == 0;
        videoPreviewC.asset = assetModel;
        __weak typeof(*&self) wSelf = self;
        [videoPreviewC setDidFinishPickingVideo:^(UIImage *coverImage, CCAssetModel *asset) {
            __weak typeof(*&self) self = wSelf;
            [(CCPhotoPickerController *)self.navigationController didFinishPickingVideo:asset];
        }];
        [self.navigationController pushViewController:videoPreviewC animated:YES];
    } else {
        CCPhotoPreviewController *previewC = [[CCPhotoPreviewController alloc] initWithCollectionViewLayout:[CCPhotoPreviewController photoPreviewViewLayoutWithSize:[UIScreen mainScreen].bounds.size]];
        previewC.assets = self.assets;
        previewC.selectedAssets = [NSMutableArray arrayWithArray:self.selectedAssets];
        previewC.currentIndex = indexPath.row;
        previewC.maxCount = [(CCPhotoPickerController *)self.navigationController maxCount];
        __weak typeof(*&self) wSelf = self;
        [previewC setDidFinishPreviewBlock:^(NSArray<CCAssetModel *> *selectedAssets) {
            __weak typeof(*&self) self = wSelf;
            self.selectedAssets = [NSMutableArray arrayWithArray:selectedAssets];
            [self.bottomBar updateBottomBarWithAssets:self.selectedAssets];
            [self.collectionView reloadData];
        }];
        
        [previewC setDidFinishPickingBlock:^(NSArray<UIImage *> *images, NSArray<CCAssetModel *> *selectedAssets) {
            __weak typeof(*&self) self = wSelf;
            [(CCPhotoPickerController *)self.navigationController didFinishPickingPhoto:selectedAssets];
        }];
        
        [self.navigationController pushViewController:previewC animated:YES];
    }
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}


#pragma mark - Getters

+ (UICollectionViewLayout *)photoCollectionViewLayoutWithWidth:(CGFloat)width
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat margin = kCCMargin;
    layout.itemSize = kCCThumbnailSize;
    layout.minimumInteritemSpacing = margin;
    layout.minimumLineSpacing = margin;
    return layout;
}

@end
