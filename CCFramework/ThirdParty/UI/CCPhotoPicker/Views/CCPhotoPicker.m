//
//  CCPhotoPicker.m
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

#import "CCPhotoPicker.h"
#import "CCAssetCell.h"

#import "CCPhotoPickerController.h"
#import "CCPhotoPreviewController.h"
#import "CCVideoPreviewController.h"
#import "CCPhotoManager.h"
#import "UIView+Animations.h"
#import "UIViewController+CCPhotoHUD.h"
#import "config.h"

#define kCCCamera 1
#define kCCPhotoLibrary 2
#define kCCCancel  999
#define kCCConfirm 998


@interface CCPhotoPicker   () <UICollectionViewDelegate,UICollectionViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,PHPhotoLibraryChangeObserver>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraButtonHConstarint;
@property (weak, nonatomic) IBOutlet UIView *cameraLineView;
@property (weak, nonatomic) IBOutlet UIButton *photoLibraryButton;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic, strong) CCAlbumModel *displayAlbum;
@property (nonatomic, copy) NSArray <CCAssetModel *>* assets;
@property (nonatomic, strong) NSMutableArray <CCAssetModel *> *selectedAssets;

@property (nonatomic, assign, readonly) CGFloat contentViewHeight;

@end

@implementation CCPhotoPicker

+ (instancetype)sharePhotoPicker {
    static id photoPicker;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        photoPicker = [[[self class] alloc] initWithMaxCount:9];
    });
    return photoPicker;
}

- (instancetype)initWithMaxCount:(NSUInteger)maxCount {
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"CCPhotoPicker" owner:nil options:nil];
    if ((self = (CCPhotoPicker *)[array firstObject])) {
        self.frame = [UIScreen mainScreen].bounds;
        [self _setup];
        self.maxCount = maxCount ? : self.maxCount;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"CCPhotoPicker dealloc");
}

#pragma mark - Methods

- (void)showAnimated:(BOOL)animated {
    [self.parentController.view addSubview:self];
    if (animated) {
        CGPoint fromPoint = CGPointMake(self.frame.size.width/2, self.contentViewHeight/2 + self.frame.size.height);
        CGPoint toPoint   = CGPointMake(self.frame.size.width/2, self.frame.size.height - self.contentViewHeight/2);
        CABasicAnimation *positionAnim = [UIView animationWithFromValue:[NSValue valueWithCGPoint:fromPoint] toValue:[NSValue valueWithCGPoint:toPoint] duration:.2f forKeypath:@"position"];
        [self.contentView.layer addAnimation:positionAnim forKey:nil];
    }
}

- (void)hideAnimated:(BOOL)animated {
    if (animated) {
        CGPoint fromPoint   = CGPointMake(self.frame.size.width/2, self.frame.size.height - self.contentViewHeight/2);
        CGPoint toPoint = CGPointMake(self.frame.size.width/2, self.contentViewHeight/2 + self.frame.size.height);
        CABasicAnimation *positionAnim = [UIView animationWithFromValue:[NSValue valueWithCGPoint:fromPoint] toValue:[NSValue valueWithCGPoint:toPoint] duration:.2f forKeypath:@"position"];
        positionAnim.delegate = self;
        [self.contentView.layer addAnimation:positionAnim forKey:nil];
    }else {
        [self removeFromSuperview];
    }
}

- (void)showPhotoPickerwithController:(UIViewController *)controller animated:(BOOL)animated {
    [self.selectedAssets removeAllObjects];
    [self.assets makeObjectsPerformSelector:@selector(setSelected:) withObject:@(NO)];
    [self _updatePhotoLibraryButton];
    [self.collectionView setContentOffset:CGPointZero];
    [self.collectionView reloadData];
    self.hidden = NO;
    self.parentController = controller;
    self.assets ? nil : [self _loadAssets];
    [self showAnimated:animated];
}

- (void)_setup {
    
    self.maxPreviewCount = 20;
    self.maxCount = MIN(self.maxPreviewCount, NSUIntegerMax);
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - self.contentViewHeight);
    cancelButton.tag = kCCCancel;
    [cancelButton addTarget:self action:@selector(_handleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelButton];
    
    iOS8Later ? [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self] : nil;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.cameraButtonHConstarint.constant = 40;
        self.cameraButton.hidden = NO;
        self.cameraLineView.hidden = NO;
    }else {
        self.cameraButton.hidden = YES;
        self.cameraLineView.hidden = YES;
        self.cameraButtonHConstarint.constant = 0;
    }
        
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 4;
    layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);

    [self.collectionView registerClass:[CCAssetCell class] forCellWithReuseIdentifier:@"CCAssetCell"];
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    self.selectedAssets = [NSMutableArray array];
    
    self.assets ? nil : [self _loadAssets];
}

- (void)_loadAssets {
    
    __weak typeof(*&self) wSelf = self;
    self.loadingView.hidden = NO;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[CCPhotoManager sharedManager] getAlbumsPickingVideoEnable:YES completionBlock:^(NSArray<CCAlbumModel *> *albums) {
            if (albums && [albums firstObject]) {
                self.displayAlbum = [albums firstObject];
                [[CCPhotoManager sharedManager] getAssetsFromResult:[[albums firstObject] fetchResult] pickingVideoEnable:YES completionBlock:^(NSArray<CCAssetModel *> *assets) {
                    __weak typeof(*&self) self = wSelf;
                    NSMutableArray *tempAssets = [NSMutableArray array];
                    [assets enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(CCAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        __weak typeof(*&self) self = wSelf;
                        [tempAssets addObject:obj];
                        *stop = ( tempAssets.count > self.maxPreviewCount);
                    }];
                    self.assets = [NSArray arrayWithArray:tempAssets];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        __weak typeof(*&self) self = wSelf;
                        self.loadingView.hidden = YES;
                        [self.collectionView reloadData];
                    });
                }];
            }
        }];
    });
    
}

- (IBAction)_handleButtonAction:(UIButton *)sender {
    switch (sender.tag) {
        case kCCCancel:
            [self hideAnimated:YES];
            break;
        case kCCConfirm:
        {
            if (self.selectedAssets.count == 1 && [self.selectedAssets firstObject].type == CCAssetTypeVideo) {
                self.didFinishPickingVideoBlock ? self.didFinishPickingVideoBlock([self.selectedAssets firstObject].previewImage,[self.selectedAssets firstObject]) : nil;
            }else {
                NSMutableArray *images = [NSMutableArray array];
                [self.selectedAssets enumerateObjectsUsingBlock:^(CCAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [images addObject:obj.previewImage];
                }];
                self.didFinishPickingPhotosBlock ? self.didFinishPickingPhotosBlock(images,self.selectedAssets) : nil;
            }
            [self hideAnimated:YES];
        }
            
            break;
        case kCCCamera:
        {
            [self _showImageCameraController];
        }
            break;
        case kCCPhotoLibrary:
        {
            [self _showPhotoPickerController];
        }
            break;
        default:
            break;
    }
}

- (void)_updatePhotoLibraryButton {
    if (self.selectedAssets.count == 0) {
        self.photoLibraryButton.tag = kCCPhotoLibrary;
        [self.photoLibraryButton setTitle:[NSString stringWithFormat:@"相册"] forState:UIControlStateNormal];
        [self.photoLibraryButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    }else {
        self.photoLibraryButton.tag = kCCConfirm;
        [self.photoLibraryButton setTitle:[NSString stringWithFormat:@"确定(%d)",(int)self.selectedAssets.count] forState:UIControlStateNormal];
        [self.photoLibraryButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
}

- (void)_showPhotoPickerController {
    CCPhotoPickerController *photoPickerController = [[CCPhotoPickerController alloc] initWithMaxCount:self.maxCount delegate:nil];
    __weak typeof(*&self) wSelf = self;
    [photoPickerController setDidFinishPickingPhotosBlock:^(NSArray<UIImage *> *images, NSArray<CCAssetModel *> *assets) {
        __weak typeof(*&self) self = wSelf;
        self.didFinishPickingPhotosBlock ?self.didFinishPickingPhotosBlock(images,assets) : nil;
        [self.parentController dismissViewControllerAnimated:YES completion:nil];
        [self hideAnimated:YES];
    }];
    [photoPickerController setDidFinishPickingVideoBlock:^(UIImage *coverImage, id asset) {
        __weak typeof(*&self) self = wSelf;
        self.didFinishPickingVideoBlock ? self.didFinishPickingVideoBlock(coverImage,asset) : nil;
        [self.parentController dismissViewControllerAnimated:YES completion:nil];
        [self hideAnimated:YES];
    }];
    [self.parentController presentViewController:photoPickerController animated:YES completion:nil];
}

- (void)_showImageCameraController {
    UIImagePickerController *imagePickerC = [[UIImagePickerController alloc] init];
    imagePickerC.delegate = self;
    imagePickerC.allowsEditing = NO;
    imagePickerC.videoQuality = UIImagePickerControllerQualityTypeLow;
    imagePickerC.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self.parentController presentViewController:imagePickerC animated:YES completion:nil];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assets.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CCAssetCell *assetCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CCAssetCell" forIndexPath:indexPath];
    assetCell.backgroundColor = [UIColor lightGrayColor];
    [assetCell configPreviewCellWithItem:self.assets[indexPath.row]];
    
    __weak typeof(*&self) wSelf = self;
    // 设置assetCell willChangeBlock
    [assetCell setWillChangeSelectedStateBlock:^BOOL(CCAssetModel *asset) {
        if (!asset.selected) {
            __weak typeof(*&self) self = wSelf;
            if (asset.type == CCAssetTypeVideo) {
                if ([self.selectedAssets firstObject] && [self.selectedAssets firstObject].type != CCAssetTypeVideo) {
                    [self.parentController showAlertWithMessage:@"不能同时选择照片和视频"];
                }else if ([self.selectedAssets firstObject]){
                    [self.parentController showAlertWithMessage:@"一次只能发送1个视频"];
                }else {
                    return YES;
                }
                return NO;
            }else if (self.selectedAssets.count > self.maxCount){
                [self.parentController showAlertWithMessage:[NSString stringWithFormat:@"一次最多只能选择%d张图片",(int)self.maxCount]];
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
        [self _updatePhotoLibraryButton];
    }];
    
    [assetCell setDidSendAsset:^(CCAssetModel *asset, CGRect frame) {
        if (asset.type == CCAssetTypePhoto) {
            self.didFinishPickingPhotosBlock ? self.didFinishPickingPhotosBlock(@[asset.previewImage],@[asset]) : nil;
        }else {
            self.didFinishPickingVideoBlock ? self.didFinishPickingVideoBlock(asset.previewImage , asset) : nil;
        }
    }];
    
    return assetCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CCAssetModel *asset = self.assets[indexPath.row];
    CGSize size = asset.previewImage.size;
    CGFloat scale = (size.width - 10)/size.height;
    return CGSizeMake(scale * (self.collectionView.frame.size.height),self.collectionView.frame.size.height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CCAssetModel *assetModel = self.assets[indexPath.row];
    if (assetModel.type == CCAssetTypeVideo) {
        CCVideoPreviewController *videoPreviewC = [[CCVideoPreviewController alloc] init];
        videoPreviewC.selectedVideoEnable = self.selectedAssets.count == 0;
        videoPreviewC.asset = assetModel;
        __weak typeof(*&self) wSelf = self;
        [videoPreviewC setDidFinishPickingVideo:^(UIImage *coverImage, CCAssetModel *asset) {
            __weak typeof(*&self) self = wSelf;
            self.didFinishPickingVideoBlock ? self.didFinishPickingVideoBlock(coverImage,asset) : nil;
            [self hideAnimated:NO];
            [self.parentController dismissViewControllerAnimated:YES completion:nil];
        }];
        [self.parentController presentViewController:videoPreviewC animated:YES completion:nil];
    }else {
        CCPhotoPreviewController *previewC = [[CCPhotoPreviewController alloc] initWithCollectionViewLayout:[CCPhotoPreviewController photoPreviewViewLayoutWithSize:[UIScreen mainScreen].bounds.size]];
        previewC.assets = self.assets;
        previewC.maxCount = self.maxCount;
        previewC.selectedAssets = [NSMutableArray arrayWithArray:self.selectedAssets];
        previewC.currentIndex = indexPath.row;
        __weak typeof(*&self) wSelf = self;
        [previewC setDidFinishPreviewBlock:^(NSArray<CCAssetModel *> *selectedAssets) {
            __weak typeof(*&self) self = wSelf;
            self.selectedAssets = [NSMutableArray arrayWithArray:selectedAssets];
            [self _updatePhotoLibraryButton];
            [self.collectionView reloadData];
            [self.parentController dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [previewC setDidFinishPickingBlock:^(NSArray<UIImage *> *images, NSArray<CCAssetModel *> *assets) {
            __weak typeof(*&self) self = wSelf;
            [self.selectedAssets removeAllObjects];
            self.didFinishPickingPhotosBlock ? self.didFinishPickingPhotosBlock(images,assets) : nil;
            [self hideAnimated:NO];
            [self.parentController dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [self.parentController presentViewController:previewC animated:YES completion:nil];
    }
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    self.hidden = YES;
    [self removeFromSuperview];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.parentController dismissViewControllerAnimated:YES completion:nil];
    [self hideAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {

    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.didFinishPickingPhotosBlock ? self.didFinishPickingPhotosBlock(@[image], nil) : nil;
    [self.parentController dismissViewControllerAnimated:YES completion:nil];
    [self hideAnimated:YES];
    
}

#pragma mark - PHPhotoLibraryChangeObserver


- (void)photoLibraryDidChange:(PHChange *)changeInfo {
    __weak typeof(*&self) wSelf = self;
    // Photos may call this method on a background queue;
    // switch to the main queue to update the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        // Check for changes to the list of assets (insertions, deletions, moves, or updates).
        PHFetchResultChangeDetails *collectionChanges = [changeInfo changeDetailsForFetchResult:self.displayAlbum.fetchResult];
        if (collectionChanges) {
            // Get the new fetch result for future change tracking.
            CCAlbumModel *changeAlbumModel = [CCAlbumModel albumWithResult:collectionChanges.fetchResultAfterChanges name:@"afterChange"];
            self.displayAlbum = changeAlbumModel;
            if (collectionChanges.hasIncrementalChanges)  {
                [[CCPhotoManager sharedManager] getAssetsFromResult:self.displayAlbum.fetchResult pickingVideoEnable:YES completionBlock:^(NSArray<CCAssetModel *> *assets) {
                    __weak typeof(*&self) self = wSelf;
                    NSMutableArray *tempAssets = [NSMutableArray array];
                    [assets enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(CCAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        __weak typeof(*&self) self = wSelf;
                        [tempAssets addObject:obj];
                        *stop = ( tempAssets.count > self.maxPreviewCount);
                    }];
                    self.assets = [NSArray arrayWithArray:tempAssets];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        __weak typeof(*&self) self = wSelf;
                        [self.collectionView reloadData];
                    });
                }];
            } else {
                // Detailed change information is not available;
                // repopulate the UI from the current fetch result.
                [self.collectionView reloadData];
            }
        }
    });
}

- (NSArray <NSIndexPath *> *)_indexPathsFromIndexSet:(NSIndexSet *)indexSet {
    NSMutableArray *indexPaths = [NSMutableArray array];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:self.displayAlbum.count - idx inSection:0]];
    }];
    return indexPaths;
}
#pragma mark - Getters

- (CGFloat)contentViewHeight {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return 41 * 3 + 160 + 8;
    }else {
        return 41 * 2  + 160 + 8;
    }
}

@end
