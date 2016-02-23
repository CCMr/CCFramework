//
//  CCAssetCell.m
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

#import "CCAssetCell.h"
#import "CCAssetModel.h"
#import "CCPhotoManager.h"
#import "config.h"
#import "UIView+Animations.h"

@interface CCAssetCell ()
@property(weak, nonatomic) UIImageView *photoImageView;
@property(weak, nonatomic) UIView *videoView;
@property(weak, nonatomic) UILabel *videoTimeLabel;
@property(weak, nonatomic) UIButton *photoStateButton;


@property(nonatomic, strong) UIView *tempView;
@property(nonatomic, weak) UIImageView *tempImageView;
@property(nonatomic, weak) UILabel *tempTipsLabel;

@property(nonatomic, assign) CGPoint startCenter;
@property(nonatomic, weak, readonly) UIView *keyWindow;

@end

@implementation CCAssetCell
@synthesize asset = _asset;

- (instancetype)init
{
    if (self = [super init]) {
        [self initialization];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialization];
    }
    return self;
}

- (void)initialization
{
    if (!_photoImageView) {
        UIImageView *photoImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        photoImageView.clipsToBounds = YES;
        [self addSubview:_photoImageView = photoImageView];
    }
    
    if (!_photoStateButton) {
        UIButton *photoStateButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds) - 27, 0, 27, 27)];
        [photoStateButton setBackgroundImage:CCResourceImage(@"photo_def_photoPickerVc") forState:UIControlStateNormal];
        [photoStateButton setImage:CCResourceImage(@"photo_sel_photoPickerVc") forState:UIControlStateSelected];
        [photoStateButton addTarget:self action:@selector(handleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_photoStateButton = photoStateButton];
    }
    if (!_videoView) {
        UIView *videoView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 18, self.bounds.size.width, 18)];
        videoView.backgroundColor = [UIColor blackColor];
        [self addSubview:_videoView = videoView];
        
        UIImageView *video_icon = [[UIImageView alloc] initWithFrame:CGRectMake(4, 0, 18, 18)];
        video_icon.image = CCResourceImage(@"VideoSendIcon");
        [videoView addSubview:video_icon];
        
        UILabel *videoTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(videoView.frame.size.width - 27, 0, 24, 18)];
        videoTimeLabel.backgroundColor = [UIColor clearColor];
        videoTimeLabel.textColor = [UIColor whiteColor];
        videoTimeLabel.font = [UIFont systemFontOfSize:12];
        [videoView addSubview:_videoTimeLabel = videoTimeLabel];
    }
}

#pragma mark - Methods

/// ========================================
/// @name   Public Methods
/// ========================================

/**
 *  CCPhotoCollectionController 中配置collectionView的cell
 *
 *  @param item 具体的AssetModel
 */
- (void)configCellWithItem:(CCAssetModel *_Nonnull)item
{
    _asset = item;
    self.photoStateButton.hidden = NO;
    switch (item.type) {
        case CCAssetTypeVideo:
        case CCAssetTypeAudio:
            self.photoStateButton.hidden = YES;
            self.videoView.hidden = NO;
            self.videoTimeLabel.text = item.timeLength;
            break;
        case CCAssetTypeLivePhoto:
        case CCAssetTypePhoto:
            self.videoView.hidden = YES;
            break;
    }
    self.photoStateButton.selected = item.selected;
    self.photoImageView.image = item.thumbnail;
}

/**
 *  CCPhotoPicker 中配置collectionView的cell
 *
 *  @param item 具体的AssetModel
 */
- (void)configPreviewCellWithItem:(CCAssetModel *_Nonnull)item
{
    _asset = item;
    switch (item.type) {
        case CCAssetTypeVideo:
        case CCAssetTypeAudio:
            self.videoView.hidden = NO;
            self.videoTimeLabel.text = item.timeLength;
            break;
        case CCAssetTypeLivePhoto:
        case CCAssetTypePhoto:
            self.videoView.hidden = YES;
            break;
    }
    self.photoStateButton.selected = item.selected;
    self.photoImageView.image = item.previewImage;
    
    
    UILongPressGestureRecognizer *longPressGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handleLongPress:)];
    longPressGes.numberOfTouchesRequired = 1;
    longPressGes.minimumPressDuration = .1f;
    [self.photoImageView addGestureRecognizer:longPressGes];
    self.photoImageView.userInteractionEnabled = YES;
}

/// ========================================
/// @name   Private Methods
/// ========================================

- (void)_handleLongPress:(UILongPressGestureRecognizer *)longPressGes
{
    if (longPressGes.state == UIGestureRecognizerStateBegan) {
        //开始手势,显示tempView,隐藏tipsLabel,photoImageView,photoStateButton
        self.tempView.hidden = NO;
        self.tempTipsLabel.hidden = YES;
        
        //记录其实center
        self.startCenter = [self.photoImageView convertPoint:self.photoImageView.center toView:self.keyWindow];
        CGRect startFrame = [self.photoImageView convertRect:self.photoImageView.frame toView:self.keyWindow];
        [self.tempView setFrame:startFrame];
        [self.tempImageView setFrame:CGRectMake(0, 0, startFrame.size.width, startFrame.size.height)];
        self.tempImageView.image = self.photoImageView.image;
        self.tempTipsLabel.center = CGPointMake(self.tempView.frame.size.width / 2, 12);
        [self.keyWindow addSubview:self.tempView];
        
        self.photoImageView.hidden = YES;
        self.photoStateButton.hidden = YES;
    } else if (longPressGes.state == UIGestureRecognizerStateChanged) {
        self.tempView.center = CGPointMake(self.tempView.center.x, MIN([longPressGes locationInView:self.keyWindow].y, self.startCenter.y));
        if (CGRectContainsPoint([self.superview convertRect:self.superview.frame toView:self.keyWindow], self.tempView.center)) {
            self.tempTipsLabel.hidden = YES;
        } else {
            self.tempTipsLabel.hidden = NO;
        }
    } else {
        if (!self.tempTipsLabel.hidden) {
            self.tempView.hidden = YES;
            self.photoImageView.hidden = NO;
            self.photoStateButton.hidden = NO;
            self.didSendAsset ? self.didSendAsset(self.asset, self.tempView.frame) : nil;
        } else {
            [UIView animateWithDuration:.2 animations:^{
                self.tempView.center = self.startCenter;
            } completion:^(BOOL finished) {
                self.startCenter = CGPointZero;
                [self.tempView removeFromSuperview];
                self.photoImageView.hidden = NO;
                self.photoStateButton.hidden = NO;
            }];
        }
    }
}

/**
 *  处理stateButton的点击动作
 *
 *  @param sender button
 */
- (void)handleButtonAction:(UIButton *)sender
{
    BOOL originState = sender.selected;
    self.photoStateButton.selected = self.willChangeSelectedStateBlock ? self.willChangeSelectedStateBlock(self.asset) : NO;
    if (self.photoStateButton.selected) {
        [UIView animationWithLayer:self.photoStateButton.layer type:CCAnimationTypeBigger];
    }
    if (originState != self.photoStateButton.selected) {
        self.didChangeSelectedStateBlock ? self.didChangeSelectedStateBlock(self.photoStateButton.selected, self.asset) : nil;
    }
}

#pragma mark - Getter

- (UIView *)keyWindow
{
    return [[UIApplication sharedApplication] keyWindow];
}

- (UIView *)tempView
{
    if (!_tempView) {
        _tempView = [[UIView alloc] init];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [_tempView addSubview:self.tempImageView = imageView];
        
        UILabel *tipsLabel = [[UILabel alloc] init];
        [tipsLabel setText:@"松开选择"];
        tipsLabel.font = [UIFont systemFontOfSize:10.0f];
        tipsLabel.backgroundColor = [UIColor darkGrayColor];
        tipsLabel.textColor = [UIColor whiteColor];
        tipsLabel.textAlignment = NSTextAlignmentCenter;
        tipsLabel.hidden = YES;
        tipsLabel.layer.cornerRadius = 10.0f;
        tipsLabel.layer.masksToBounds = YES;
        tipsLabel.frame = CGRectMake(0, 4, 55, 20);
        [_tempView addSubview:self.tempTipsLabel = tipsLabel];
    }
    return _tempView;
}

@end
