//
//  CCPhotoPreviewController.m
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

#import "CCPhotoPreviewController.h"
#import "CCPhotoPickerController.h"
#import "CCAssetModel.h"
#import "CCBottomBar.h"
#import "CCPhotoPreviewCell.h"
#import "UIView+Animations.h"
#import "UIViewController+CCPhotoHUD.h"
#import "config.h"
#import "CCPhotoManager.h"

@interface CCPhotoPreviewController ()

@property(nonatomic, strong) UIView *topBar;
@property(nonatomic, weak) UIButton *stateButton;

@property(nonatomic, strong) CCBottomBar *bottomBar;

@end

@implementation CCPhotoPreviewController

static NSString *const kCCPhotoPreviewIdentifier = @"CCPhotoPreviewCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor blackColor];
    
    [self _setup];
    [self _setupCollectionView];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Methods

- (void)_setup
{
    [self.view addSubview:self.topBar];
    [self.view addSubview:self.bottomBar];
    [self _updateTopBarStatus];
    [self.bottomBar updateBottomBarWithAssets:self.selectedAssets];
}

- (void)_setupCollectionView
{
    [self.collectionView registerClass:[CCPhotoPreviewCell class] forCellWithReuseIdentifier:kCCPhotoPreviewIdentifier];
    self.collectionView.backgroundColor = [UIColor blackColor];
    self.collectionView.scrollsToTop = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.contentSize = CGSizeMake(self.view.frame.size.width * self.assets.count, self.view.frame.size.height);
    self.collectionView.pagingEnabled = YES;
}

- (void)_handleBackAction
{
    self.didFinishPreviewBlock ? self.didFinishPreviewBlock(self.selectedAssets) : nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleStateChangeAction
{
    if (self.stateButton.selected) {
        [self.selectedAssets removeObject:self.assets[self.currentIndex]];
        self.assets[self.currentIndex].selected = NO;
        self.assets[self.currentIndex].selectOriginEnable = NO;
        [self _updateTopBarStatus];
    } else {
        if (self.selectedAssets.count < self.maxCount) {
            self.assets[self.currentIndex].selected = YES;
            [self.selectedAssets addObject:self.assets[self.currentIndex]];
            [self _updateTopBarStatus];
            [UIView animationWithLayer:self.stateButton.layer type:CCAnimationTypeBigger];
        } else {
            //TODO 超过最大数量
            [self showAlertWithMessage:[NSString stringWithFormat:@"最多只能选择%zi张照片", self.maxCount]];
        }
    }
    [self.bottomBar updateBottomBarWithAssets:self.selectedAssets];
}

- (void)originalPhotototalSize
{
    if (!self.stateButton.selected) {
        if (self.selectedAssets.count < self.maxCount) {
            self.assets[self.currentIndex].selected = YES;
            [self.selectedAssets addObject:self.assets[self.currentIndex]];
            [self _updateTopBarStatus];
            [UIView animationWithLayer:self.stateButton.layer type:CCAnimationTypeBigger];
        } else {
            //TODO 超过最大数量
            [self showAlertWithMessage:[NSString stringWithFormat:@"最多只能选择%zi张照片", self.maxCount]];
        }
    }
    self.assets[self.currentIndex].selectOriginEnable = !self.assets[self.currentIndex].selectOriginEnable;
    [self.bottomBar updateBottomBarWithAssets:self.selectedAssets];
}

- (void)_updateTopBarStatus
{
    CCAssetModel *asset = self.assets[self.currentIndex];
    [self.bottomBar originalPhotototalSize:asset];
    self.stateButton.selected = asset.selected;
}

- (void)_setBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (!animated) {
        self.topBar.hidden = self.bottomBar.hidden = hidden;
        return;
    }
    [UIView animateWithDuration:.15 animations:^{
        self.topBar.alpha = self.bottomBar.alpha = hidden ? .0f : 1.0f;
    } completion:^(BOOL finished) {
        self.topBar.hidden = self.bottomBar.hidden = hidden;
        [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
    }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offSet = scrollView.contentOffset;
    self.currentIndex = offSet.x / self.view.frame.size.width;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self _updateTopBarStatus];
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
    CCPhotoPreviewCell *previewCell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCPhotoPreviewIdentifier forIndexPath:indexPath];
    [previewCell configCellWithItem:self.assets[indexPath.row]];
    __weak typeof(*&self) wSelf = self;
    [previewCell setSingleTapBlock:^{
        __weak typeof(*&self) self = wSelf;
        [self _setBarHidden:!self.topBar.hidden animated:YES];
    }];
    return previewCell;
}


#pragma mark - Getters

- (UIView *)topBar
{
    if (!_topBar) {
        
        CGFloat originY = iOS7Later ? 20 : 0;
        _topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, originY + 44)];
        _topBar.backgroundColor = [UIColor colorWithRed:34 / 255.0f green:34 / 255.0f blue:34 / 255.0f alpha:.7f];
        
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setImage:CCResourceImage(@"navi_back") forState:UIControlStateNormal];
        [backButton setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        [backButton sizeToFit];
        backButton.frame = CGRectMake(12, _topBar.frame.size.height / 2 - backButton.frame.size.height / 2 + originY / 2, backButton.frame.size.width, backButton.frame.size.height);
        [backButton addTarget:self action:@selector(_handleBackAction) forControlEvents:UIControlEventTouchUpInside];
        [_topBar addSubview:backButton];
        
        UIButton *stateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [stateButton setImage:CCResourceImage(@"photo_def_previewVc") forState:UIControlStateNormal];
        [stateButton setImage:CCResourceImage(@"photo_sel_photoPickerVc") forState:UIControlStateSelected];
        [stateButton setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        [stateButton sizeToFit];
        stateButton.frame = CGRectMake(_topBar.frame.size.width - 12 - stateButton.frame.size.width, _topBar.frame.size.height / 2 - stateButton.frame.size.height / 2 + originY / 2, stateButton.frame.size.width, stateButton.frame.size.height);
        
        [stateButton addTarget:self action:@selector(handleStateChangeAction) forControlEvents:UIControlEventTouchUpInside];
        [_topBar addSubview:self.stateButton = stateButton];
    }
    return _topBar;
}

- (CCBottomBar *)bottomBar
{
    if (!_bottomBar) {
        _bottomBar = [[CCBottomBar alloc] initWithBarType:CCPreviewBottomBar];
        _bottomBar.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
        [_bottomBar updateBottomBarWithAssets:self.selectedAssets];
        
        __weak typeof(*&self) wSelf = self;
        [_bottomBar setConfirmBlock:^{
            __weak typeof(*&self) self = wSelf;
            NSMutableArray *images = [NSMutableArray array];
            [self.selectedAssets enumerateObjectsUsingBlock:^(CCAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [images addObject:obj];
            }];
            self.didFinishPickingBlock ? self.didFinishPickingBlock(images,self.selectedAssets) : nil;
        }];
        
        _bottomBar.originalPhotototalSizeBlock = ^{
            [wSelf originalPhotototalSize];;
        };
    }
    return _bottomBar;
}

@end
