//
//  CCPhotoPickerController.m
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

#import "CCPhotoPickerController.h"
#import "CCPhotoCollectionController.h"
#import "CCPhotoManager.h"
#import "config.h"
#import "CCAlbumCell.h"

@implementation CCPhotoPickerController

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"

#pragma mark - CCPhotoPickerController Life Cycle

- (instancetype)initWithMaxCount:(NSUInteger)maxCount delegate:(id<CCPhotoPickerControllerDelegate>)delegate {
    CCAlbumListController *albumListC = [[CCAlbumListController alloc] init];
    if (self = [super initWithRootViewController:albumListC]) {
        _photoPickerDelegate = delegate;
        _maxCount = maxCount ? : NSUIntegerMax;
        _autoPushToPhotoCollection = YES;
        _pickingVideoEnable = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupNavigationBarAppearance];
    [self _setupUnAuthorizedTips];
}

/**
 *  重写viewWillAppear方法
 *  判断是否需要自动push到第一个相册专辑内
 *  @param animated 是否需要动画
 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.autoPushToPhotoCollection) {
        CCPhotoCollectionController *photoCollectionC = [[CCPhotoCollectionController alloc] initWithCollectionViewLayout:[CCPhotoCollectionController photoCollectionViewLayoutWithWidth:self.view.frame.size.width]];
        __weak typeof(*&self) wSelf = self;
        [[CCPhotoManager sharedManager] getAlbumsPickingVideoEnable:self.pickingVideoEnable completionBlock:^(NSArray<CCAlbumModel *> *albums) {
            __weak typeof(*&self) self = wSelf;
            photoCollectionC.album = [albums firstObject];
            [self pushViewController:photoCollectionC animated:NO];
        }];
    }
}

- (void)dealloc {
    NSLog(@"photo picker dealloc");
}

#pragma mark - CCPhotoPickerController Methods

/**
 *  call photoPickerDelegate & didFinishPickingPhotosBlock
 *
 *  @param assets 具体回传的资源
 */
- (void)didFinishPickingPhoto:(NSArray<CCAssetModel *> *)assets {
    NSMutableArray *images = [NSMutableArray array];
    [assets enumerateObjectsUsingBlock:^(CCAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [images addObject:obj.previewImage];
    }];
    if (self.photoPickerDelegate && [self.photoPickerDelegate respondsToSelector:@selector(photoPickerController:didFinishPickingPhotos:sourceAssets:)]) {
        [self.photoPickerDelegate photoPickerController:self didFinishPickingPhotos:images sourceAssets:assets];
    }
    self.didFinishPickingPhotosBlock ? self.didFinishPickingPhotosBlock(images,assets) : nil;
}

- (void)didFinishPickingVideo:(CCAssetModel *)asset {
    
    if (self.photoPickerDelegate && [self.photoPickerDelegate respondsToSelector:@selector(photoPickerController:didFinishPickingVideo:sourceAssets:)]) {
        [self.photoPickerDelegate photoPickerController:self didFinishPickingVideo:asset.previewImage sourceAssets:asset];
    }
    
    self.didFinishPickingVideoBlock ? self.didFinishPickingVideoBlock(asset.previewImage , asset) : nil;
}

- (void)didCancelPickingPhoto {
    if (self.photoPickerDelegate && [self.photoPickerDelegate respondsToSelector:@selector(photoPickerControllerDidCancel:)]) {
        [self.photoPickerDelegate photoPickerControllerDidCancel:self];
    }
    self.didCancelPickingBlock ? self.didCancelPickingBlock() : nil;
}

/**
 *  设置当用户未授权访问照片时提示
 */
- (void)_setupUnAuthorizedTips {
    if (![[CCPhotoManager sharedManager] hasAuthorized]) {
        UILabel *tipsLabel = [[UILabel alloc] init];
        tipsLabel.frame = CGRectMake(8, 64, self.view.frame.size.width - 16, 300);
        tipsLabel.textAlignment = NSTextAlignmentCenter;
        tipsLabel.numberOfLines = 0;
        tipsLabel.font = [UIFont systemFontOfSize:16];
        tipsLabel.textColor = [UIColor blackColor];
        tipsLabel.userInteractionEnabled = YES;
        NSString *appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"];
        if (!appName) appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleName"];
        tipsLabel.text = [NSString stringWithFormat:@"请在%@的\"设置-隐私-照片\"选项中，\r允许%@访问你的手机相册。",[UIDevice currentDevice].model,appName];
        [self.view addSubview:tipsLabel];
        
        //!!! bug 用户前往设置后,修改授权会导致app崩溃
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTipsTap)];
        [tipsLabel addGestureRecognizer:tap];
    }
}

/**
 *  处理当用户未授权访问相册时 tipsLabel的点击手势,暂时有bug
 */
- (void)_handleTipsTap {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

/**
 *  设置navigationBar的样式
 */
- (void)_setupNavigationBarAppearance {
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.translucent = YES;
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    if (iOS7Later) {
        self.navigationBar.barTintColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0) blue:(34/255.0) alpha:1.0];
        self.navigationBar.tintColor = [UIColor whiteColor];
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    UINavigationBar *navigationBar;
    UIBarButtonItem *barItem;
    if (iOS9Later) {
        barItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[CCPhotoPickerController class]]];
        navigationBar = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[CCPhotoPickerController class]]];
    } else {
        barItem = [UIBarButtonItem appearanceWhenContainedIn:[CCPhotoPickerController class], nil];
        navigationBar = [UINavigationBar appearanceWhenContainedIn:[CCPhotoPickerController class], nil];
    }
    [barItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0f],NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    [navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20.0f]}];
    [navigationBar setBarStyle:UIBarStyleBlackTranslucent];
}


@end

@implementation CCAlbumListController

#pragma mark - CCAlbumListController Life Cycle 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"照片";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(_handleCancelAction)];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.rowHeight = 70.0f;
    [self.tableView registerClass:[CCAlbumCell class] forCellReuseIdentifier:@"CCAlbumCell"];
    
    CCPhotoPickerController *imagePickerVC = (CCPhotoPickerController *)self.navigationController;
    __weak typeof(*&self) wSelf = self;
    [[CCPhotoManager sharedManager] getAlbumsPickingVideoEnable:imagePickerVC.pickingVideoEnable completionBlock:^(NSArray<CCAlbumModel *> *albums) {
        __weak typeof(*&self) self = wSelf;
        self.albums = [NSArray arrayWithArray:albums];
        [self.tableView reloadData];
    }];
    
}

#pragma mark - CCAlbumListController Methods

- (void)_handleCancelAction {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    CCPhotoPickerController *photoPickerVC = (CCPhotoPickerController *)self.navigationController;
    [photoPickerVC didCancelPickingPhoto];
    
}


#pragma mark - CCAlbumListController UITableViewDataSource && UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CCAlbumCell *albumCell = [tableView dequeueReusableCellWithIdentifier:@"CCAlbumCell"];
    [albumCell configCellWithItem:self.albums[indexPath.row]];
    return albumCell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CCPhotoCollectionController *photoCollectionC = [[CCPhotoCollectionController alloc] initWithCollectionViewLayout:[CCPhotoCollectionController photoCollectionViewLayoutWithWidth:self.view.frame.size.width]];
    photoCollectionC.album = self.albums[indexPath.row];
    [self.navigationController pushViewController:photoCollectionC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end


#pragma clang diagnostic pop

