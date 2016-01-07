//
//  CCPickerCollectionView.h
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

#import <UIKit/UIKit.h>

@class CCPickerCollectionView;
@protocol CCPickerCollectionViewDelegate <NSObject>

/**
 *  @author CC, 2015-06-01 20:06:22
 *
 *  @brief  选择相片就会调用
 *
 *  @param pickerCollectionView <#pickerCollectionView description#>
 *
 *  @since 1.0
 */
-(void)pickerCollectionViewDidSelected:(CCPickerCollectionView *)pickerCollectionView;

/**
 *  @author CC, 2015-06-01 20:06:05
 *
 *  @brief  预览图片
 *
 *  @param pickerCollectionView <#pickerCollectionView description#>
 *  @param index                <#index description#>
 *
 *  @since 1.0
 */
-(void)pickerCollectionviewDidPreview:(CCPickerCollectionView *)pickerCollectionView Index:(NSInteger)index;


@end


@interface CCPickerCollectionView : UICollectionView

// 保存所有的数据
@property (nonatomic, strong) NSArray *dataArray;
// 保存选中的图片
@property (nonatomic, strong) NSMutableArray *selectAsstes;
//选中图片
@property (nonatomic, assign) UIImageView *selectImageView;
// delegate
@property (nonatomic, weak) id <CCPickerCollectionViewDelegate> collectionViewDelegate;
// 限制最大数
@property (nonatomic, assign) NSInteger minCount;

// 选中的索引值，为了防止重用
@property (nonatomic, strong) NSMutableArray *selectsIndexPath;
// 记录选中的值
@property (assign,nonatomic) BOOL isRecoderSelectPicker;

@end
