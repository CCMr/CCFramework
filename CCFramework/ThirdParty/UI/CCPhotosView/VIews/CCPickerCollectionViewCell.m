//
//  CCPickerCollectionViewCell.m
//  CC
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

#import "CCPickerCollectionViewCell.h"
#import "UIButton+BUIButton.h"
#import "UIControl+BUIControl.h"
#import "config.h"

@interface CCPickerCollectionViewCell ()

@property(nonatomic, strong) UIImageView *imageView;


@property(nonatomic, strong) UIButton *checkBtn;

@property(nonatomic, strong) NSIndexPath *indexPath;

@end

@implementation CCPickerCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.tag = 9999;
        [self addSubview:_imageView];
        
        _checkBtn = [UIButton buttonWith];
        _checkBtn.frame = CGRectMake(_imageView.frame.size.width - 40, 0, 40, 40);
        [_checkBtn addTarget:self action:@selector(didCheckButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_checkBtn];
        
        _overImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 4, 20, 20)];
        [_checkBtn addSubview:_overImageView];
    }
    return self;
}


/**
 *  @author CC, 2015-12-23
 *  
 *  @brief  设置数据
 *
 *  @param asset     显示对象
 *  @param isOver    是否选中
 *  @param indexPath 数据下标
 */
- (void)setData:(CCPhoto *)asset
         IsOver:(BOOL)isOver
      IndexPath:(NSIndexPath *)indexPath
{
    self.indexPath = indexPath;
    
    _imageView.image = asset.thumbImage;
    
    _overImageView.image = CCResourceImage(isOver ? @"AssetsYES" : @"AssetsNO");
}

- (void)didCheckButton:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(didCollectionViewDidSelected:IndexPath:)]) {
        [self.delegate didCollectionViewDidSelected:self IndexPath:self.indexPath];
    }
}

@end
