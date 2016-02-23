//
//  CCBottomToolBar.m
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

#import "CCBottomBar.h"
#import "CCAssetModel.h"
#import "CCPhotoManager.h"
#import "UIView+Animations.h"
#import "config.h"

@interface CCBottomBar ()

@property(weak, nonatomic) UIButton *previewButton;
@property(weak, nonatomic) UIButton *originalPhotoButton;
@property(weak, nonatomic) UILabel *originalPhotoLable;
@property(weak, nonatomic) UIButton *confirmButton;
@property(weak, nonatomic) UIImageView *numberImageView;
@property(weak, nonatomic) UILabel *numberLabel;
@property(weak, nonatomic) UIView *lineView;

@property(nonatomic, assign) BOOL selectOriginEnable;


@end

@implementation CCBottomBar
@synthesize barType = _barType;
@synthesize selectOriginEnable = _selectOriginEnable;
@synthesize totalSize = _totalSize;

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
    if (!_previewButton) {
        UIButton *previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        previewButton.frame = CGRectMake(10, 3, 44, 44);
        previewButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [previewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //        [previewButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [self addSubview:_previewButton = previewButton];
    }
    
    if (!_originalPhotoButton) {
        UIButton *originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        originalPhotoButton.frame = CGRectMake(5, 0, 120, 44);
        originalPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 0);
        originalPhotoButton.contentEdgeInsets = UIEdgeInsetsMake(0, -50, 0, 0);
        originalPhotoButton.backgroundColor = [UIColor clearColor];
        [originalPhotoButton addTarget:self action:@selector(originalPhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
        originalPhotoButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [originalPhotoButton setTitle:@"原图" forState:UIControlStateNormal];
        [originalPhotoButton setTitle:@"原图" forState:UIControlStateSelected];
        [originalPhotoButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [originalPhotoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [originalPhotoButton setImage:CCResourceImage(@"preview_original_def") forState:UIControlStateNormal];
        [originalPhotoButton setImage:CCResourceImage(@"photo_original_sel") forState:UIControlStateSelected];
        originalPhotoButton.hidden = YES;
        [self addSubview:_originalPhotoButton = originalPhotoButton];
    }
    if (!_originalPhotoLable) {
        UILabel *originalPhotoLable = [[UILabel alloc] init];
        originalPhotoLable.frame = CGRectMake(70, 0, 70, 44);
        originalPhotoLable.textAlignment = NSTextAlignmentLeft;
        originalPhotoLable.font = [UIFont systemFontOfSize:13];
        originalPhotoLable.textColor = [UIColor whiteColor];
        originalPhotoLable.backgroundColor = [UIColor clearColor];
        originalPhotoLable.hidden = YES;
        [self addSubview:_originalPhotoLable = originalPhotoLable];
    }
    if (!_confirmButton) {
        UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        confirmButton.frame = CGRectMake(winsize.width - 66, 0, 44, 44);
        confirmButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [self addSubview:_confirmButton = confirmButton];
    }
    if (!_numberImageView) {
        UIImageView *numberImageView = [[UIImageView alloc] initWithImage:CCResourceImage(@"photo_number_icon")];
        numberImageView.backgroundColor = [UIColor clearColor];
        numberImageView.frame = CGRectMake(winsize.width - 66 - 24, 9, 26, 26);
        numberImageView.hidden = YES;
        [self addSubview:_numberImageView = numberImageView];
    }
    
    if (!_numberLabel) {
        UILabel *numberLable = [[UILabel alloc] initWithFrame:_numberImageView.frame];
        numberLable.font = [UIFont systemFontOfSize:16];
        numberLable.textColor = [UIColor whiteColor];
        numberLable.textAlignment = NSTextAlignmentCenter;
        numberLable.backgroundColor = [UIColor clearColor];
        [self addSubview:_numberLabel = numberLable];
    }
}

- (void)previewButtonClick
{
    self.previewBlock ? self.previewBlock() : nil;
}

#pragma mark - Life Cycle

- (instancetype)initWithBarType:(CCBottomBarType)barType
{
    CCBottomBar *bottomBar = [[CCBottomBar alloc] init];
    bottomBar ? [bottomBar _setupWithType:barType] : nil;
    return bottomBar;
}

#pragma mark - Methods

- (void)updateBottomBarWithAssets:(NSArray *)assets
{
    _totalSize = .0f;
    
    self.numberLabel.text = [NSString stringWithFormat:@"%zi", assets.count];
    
    self.numberImageView.hidden = self.numberLabel.hidden = assets.count <= 0;
    self.confirmButton.enabled = assets.count >= 1;
    
    self.previewButton.enabled = assets.count >= 1;
    self.confirmButton.alpha = .5f;
    self.previewButton.alpha = .5f;
    if (self.previewButton.enabled) {
        self.confirmButton.alpha = 1;
        self.previewButton.alpha = 1;
    }
    
    [UIView animationWithLayer:self.numberImageView.layer type:CCAnimationTypeSmaller];
}

- (void)originalPhotototalSize:(id)asset
{
    if (self.selectOriginEnable) {
        __weak typeof(*&self) wSelf = self;
        [[CCPhotoManager sharedManager] getAssetSizeWithAsset:((CCAssetModel *)asset).asset completionBlock:^(CGFloat size) {
            __weak typeof(*&self) self = wSelf;
            _totalSize = size;
            [self _updateSizeLabel];
        }];
    }
}

- (void)_setupWithType:(CCBottomBarType)barType
{
    _barType = barType;
    
    self.lineView.hidden = barType == CCPreviewBottomBar;
    
    UIColor *color = [UIColor colorWithRed:247 / 255.0f green:247 / 255.0f blue:247 / 255.0 alpha:1.0f];
    BOOL hidden = NO;
    if (barType == CCPreviewBottomBar || barType == CCVideoPreviewBottomBar) {
        color = [UIColor colorWithRed:34 / 255.0f green:34 / 255.0f blue:34 / 255.0f alpha:.7f];
        hidden = YES;
    }
    self.backgroundColor = color;
    self.lineView.backgroundColor = [UIColor colorWithRed:223 / 255.0f green:223 / 255.0f blue:223 / 255.0f alpha:1.f];
    
    //config previewButton
    self.previewButton.hidden = hidden;
    [self.previewButton setTitle:@"预览" forState:UIControlStateNormal];
    [self.previewButton setTitle:@"预览" forState:UIControlStateDisabled];
    self.previewButton.alpha = .5f;
    [self.previewButton addTarget:self action:@selector(previewButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    hidden = NO;
    if (barType == CCCollectionBottomBar || barType == CCVideoPreviewBottomBar)
        hidden = YES;
    
    self.originalPhotoButton.hidden = hidden;
    self.originalPhotoLable.hidden = self.originalPhotoButton.hidden;
    
    //config number
    self.numberImageView.hidden = self.numberLabel.hidden = YES;
    self.numberImageView.image = CCResourceImage(@"photo_number_icon");
    self.numberLabel.textColor = [UIColor whiteColor];
    
    //config confirmButton
    self.confirmButton.enabled = NO;
    [self.confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    [self.confirmButton setTitle:@"确定" forState:UIControlStateDisabled];
    [self.confirmButton setTitleColor:[UIColor colorWithRed:(83 / 255.0)green:(179 / 255.0)blue:(17 / 255.0)alpha:1.0f] forState:UIControlStateNormal];
    //    [self.confirmButton setTitleColor:[UIColor colorWithRed:(83 / 255.0)green:(179 / 255.0)blue:(17 / 255.0)alpha:.5f] forState:UIControlStateDisabled];
    self.confirmButton.alpha = .5f;
    [self.confirmButton addTarget:self action:@selector(handleConfirmAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)handleConfirmAction
{
    self.confirmBlock ? self.confirmBlock() : nil;
}

- (void)originalPhotoButtonClick
{
    self.selectOriginEnable = !self.selectOriginEnable;
    _originalPhotoButton.selected = !_originalPhotoButton.isSelected;
    _originalPhotoLable.hidden = !_originalPhotoButton.isSelected;
    if (self.selectOriginEnable)
        self.originalPhotototalSizeBlock ? self.originalPhotototalSizeBlock() : nil;
}

- (void)_updateSizeLabel
{
    if (self.selectOriginEnable) {
        self.originalPhotoLable.text = [NSString stringWithFormat:@"(%@)", [self _bytesStringFromDataLength:self.totalSize]];
        self.originalPhotoLable.textColor = self.barType == CCCollectionBottomBar ? [UIColor blackColor] : [UIColor whiteColor];
    }
}

#pragma mark - Getters

- (NSString *)_bytesStringFromDataLength:(CGFloat)dataLength
{
    NSString *bytes;
    if (dataLength >= 0.1 * (1024 * 1024)) {
        bytes = [NSString stringWithFormat:@"%0.1fM", dataLength / 1024 / 1024.0];
    } else if (dataLength >= 1024) {
        bytes = [NSString stringWithFormat:@"%0.0fK", dataLength / 1024.0];
    } else if (dataLength == .0f) {
        bytes = @"";
    } else {
        bytes = [NSString stringWithFormat:@"%zdB", dataLength];
    }
    return bytes;
}


@end
