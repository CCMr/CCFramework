//
//  CCPickerCollectionView.m
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

#define MAX_COUNT 9 // 选择图片最大数默认是9

#import "CCPickerCollectionView.h"
#import "CCPickerCollectionViewCell.h"
#import "CCPhoto.h"
#import "config.h"

static NSString *const _cellIdentifier = @"CCPickerCollectionViewCell";

@interface CCPickerCollectionView () <UICollectionViewDataSource, UICollectionViewDelegate, CCPickerCollectionViewCellDelegate>

// 判断是否是第一次加载
@property(nonatomic, assign, getter=isFirstLoadding) BOOL firstLoadding;

@end


@implementation CCPickerCollectionView

#pragma mark -getter
- (NSMutableArray *)selectsIndexPath
{
    if (!_selectsIndexPath) {
        _selectsIndexPath = [NSMutableArray array];
    }
    return _selectsIndexPath;
}

#pragma mark -setter
- (void)setDataArray:(NSArray *)dataArray
{
    _dataArray = dataArray;
    
    [self reloadData];
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        self.backgroundColor = [UIColor clearColor];
        self.dataSource = self;
        self.delegate = self;
        _selectAsstes = [NSMutableArray array];
    }
    return self;
}

#pragma mark -<UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CCPickerCollectionViewCell *Cell = [collectionView dequeueReusableCellWithReuseIdentifier:_cellIdentifier forIndexPath:indexPath];
    Cell.delegate = self;
    
    [Cell setData:self.dataArray[indexPath.row]
           IsOver:([self.selectsIndexPath containsObject:@(indexPath.row)])
        IndexPath:indexPath];
    
    return Cell;
}

- (void)didCollectionViewDidSelected:(CCPickerCollectionViewCell *)pickerCollectionView IndexPath:(NSIndexPath *)indexPath
{
    CCPhoto *photo = self.dataArray[indexPath.row];
    BOOL bol = [self.selectsIndexPath containsObject:@(indexPath.row)];
    if (bol) {
        [self.selectsIndexPath removeObject:@(indexPath.row)];
        [self.selectAsstes removeObject:photo];
    } else {
        NSUInteger minCount = (self.minCount > MAX_COUNT || self.minCount < 1) ? MAX_COUNT : self.minCount;
        
        if (self.selectsIndexPath.count >= minCount) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:[NSString stringWithFormat:@"最多只能选择%zd张图片", minCount] delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
            [alertView show];
            return;
        }
        
        [self.selectsIndexPath addObject:@(indexPath.row)];
        [self.selectAsstes addObject:photo];
    }
    pickerCollectionView.overImageView.image = [self.selectsIndexPath containsObject:@(indexPath.row)] ? CCResourceImage(@"AssetsYES") : CCResourceImage(@"AssetsNO");
    
    CAKeyframeAnimation *scaoleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaoleAnimation.duration = 0.25;
    scaoleAnimation.autoreverses = YES;
    scaoleAnimation.values = @[ [NSNumber numberWithFloat:1.0], [NSNumber numberWithFloat:1.2], [NSNumber numberWithFloat:1.0] ];
    scaoleAnimation.fillMode = kCAFillModeForwards;
    
    [pickerCollectionView.overImageView.layer removeAllAnimations];
    [pickerCollectionView.overImageView.layer addAnimation:scaoleAnimation forKey:@"transform.rotate"];
    
    if ([self.collectionViewDelegate respondsToSelector:@selector(pickerCollectionViewDidSelected:)])
        [self.collectionViewDelegate pickerCollectionViewDidSelected:self];
}

#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CCPickerCollectionViewCell *cell = (CCPickerCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    self.selectImageView = (UIImageView *)[cell viewWithTag:9999];
    if ([self.collectionViewDelegate respondsToSelector:@selector(pickerCollectionviewDidPreview:Index:)]) {
        [self.collectionViewDelegate pickerCollectionviewDidPreview:self Index:indexPath.row];
    }
}

- (void)layoutSubviews
{
    
    [super layoutSubviews];
    
    // 时间置顶的话
    if (!self.firstLoadding && self.contentSize.height > [[UIScreen mainScreen] bounds].size.height) {
        // 滚动到最底部（最新的）
        [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.dataArray.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
        // 展示图片数
        self.contentOffset = CGPointMake(self.contentOffset.x, self.contentOffset.y + 10);
        self.firstLoadding = YES;
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
