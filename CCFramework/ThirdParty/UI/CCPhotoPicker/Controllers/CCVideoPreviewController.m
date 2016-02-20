//
//  CCVideoPreviewController.m
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

#import "CCVideoPreviewController.h"
#import "CCPhotoPickerController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "CCBottomBar.h"
#import "CCAssetModel.h"
#import "CCPhotoManager.h"
#import "UIView+Animations.h"
#import "config.h"

@interface CCVideoPreviewController ()

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, weak)   UIButton *playButton;
@property (nonatomic, weak)   CCBottomBar *bottomBar;
@property (nonatomic, strong) UIView *topBar;

@property (nonatomic, strong) UIImage *coverImage;


@end

@implementation CCVideoPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.title = @"视频预览";
    [self _setupPlayer];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)dealloc {
    NSLog(@"video preview dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController ? [self.navigationController setNavigationBarHidden:YES] : nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController ? [self.navigationController setNavigationBarHidden:NO] : nil;
}

#pragma mark - Methods


/**
 *  初始化player
 *  1.获取asset对应的AVPlayerItem
 *  2.初始化AVPlayer
 *  3.添加AVPlayerLayer
 *  4.chu
 */
- (void)_setupPlayer {
    
    __weak typeof(*&self) wSelf = self;
    
    [[CCPhotoManager sharedManager] getPreviewImageWithAsset:self.asset.asset completionBlock:^(UIImage *image) {
        __weak typeof(*&self) self = wSelf;
        self.coverImage = image;
    }];
    
    [[CCPhotoManager sharedManager] getVideoInfoWithAsset:self.asset.asset completionBlock:^(AVPlayerItem *playerItem, NSDictionary *playetItemInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __weak typeof(*&self) self = wSelf;
            self.player = [AVPlayer playerWithPlayerItem:playerItem];
            AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
            playerLayer.frame = self.view.bounds;
            [self.view.layer addSublayer:playerLayer];
            [self _setupPlayButton];
            [self _setupBottomBar];
            [self.view addSubview:self.topBar];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_pausePlayer) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        });
    }];
    
}

- (void)_setupPlayButton {
    UIButton *playButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    playButton.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64 - 44);
    [playButton setImage:[UIImage imageNamed:@"video_preview_play_normal"] forState:UIControlStateNormal];
    [playButton setImage:[UIImage imageNamed:@"video_preview_play_highlight"] forState:UIControlStateHighlighted];
    [playButton addTarget:self action:@selector(_handlePlayAciton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playButton = playButton];
}

- (void)_setupBottomBar {
    CCBottomBar *bottomBar = [[CCBottomBar alloc] initWithBarType:CCPreviewBottomBar];
    [bottomBar setFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
    __weak typeof(*&self) wSelf = self;
    self.selectedVideoEnable ? [bottomBar setConfirmBlock:^{
        __weak typeof(*&self) self = wSelf;
        self.didFinishPickingVideo ? self.didFinishPickingVideo(self.asset.previewImage , self.asset) : nil;
    }] : nil;
    [bottomBar updateBottomBarWithAssets:self.selectedVideoEnable ? @[self.asset] : @[]];
    [self.view addSubview:self.bottomBar = bottomBar];
}

- (void)_handlePlayAciton {
    CMTime currentTime = self.player.currentItem.currentTime;
    CMTime durationTime = self.player.currentItem.duration;
    if (self.player.rate == 0.0f) {
        [self.playButton setImage:nil forState:UIControlStateNormal];
        if (currentTime.value == durationTime.value) [self.player.currentItem seekToTime:CMTimeMake(0, 1)];
        [self.player play];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [UIView animateWithDuration:.2 animations:^{
            [self.bottomBar setFrame:CGRectMake(0, self.view.frame.size.height, self.bottomBar.frame.size.width, self.bottomBar.frame.size.height)];
            [self.topBar setFrame:CGRectMake(0, -self.topBar.frame.size.height, self.topBar.frame.size.width, self.topBar.frame.size.height)];
        }];
    } else {
        [self _pausePlayer];
    }
}

- (void)_pausePlayer {
    [self.playButton setImage:[UIImage imageNamed:@"video_preview_play_normal"] forState:UIControlStateNormal];
    [self.player pause];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [UIView animateWithDuration:.2 animations:^{
        [self.bottomBar setFrame:CGRectMake(0, self.view.frame.size.height-self.bottomBar.frame.size.height, self.bottomBar.frame.size.width, self.bottomBar.frame.size.height)];
        [self.topBar setFrame:CGRectMake(0, 0, self.topBar.frame.size.width, self.topBar.frame.size.height)];
    }];
}

- (void)_handleBackAction {
    self.navigationController ? [self.navigationController popViewControllerAnimated:YES] : [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Getters

- (UIView *)topBar {
    if (!_topBar) {
        
        CGFloat originY = iOS7Later ? 20 : 0;
        _topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, originY + 44)];
        _topBar.backgroundColor = [UIColor colorWithRed:34/255.0f green:34/255.0f blue:34/255.0f alpha:.7f];
        
        UILabel *label = [[UILabel alloc] init];
        [label setAttributedText:[[NSAttributedString alloc] initWithString:@"视频预览" attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20.0f],NSForegroundColorAttributeName:[UIColor whiteColor]}]];
        [label sizeToFit];
        label.center = _topBar.center;
        [_topBar addSubview:label];
        
        UIButton *backButton  = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
        [backButton setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        [backButton sizeToFit];
        backButton.frame = CGRectMake(12, _topBar.frame.size.height/2 - backButton.frame.size.height/2 + originY/2, backButton.frame.size.width, backButton.frame.size.height);
        [backButton addTarget:self action:@selector(_handleBackAction) forControlEvents:UIControlEventTouchUpInside];
        [_topBar addSubview:backButton];
        
    }
    return _topBar;
}


@end
