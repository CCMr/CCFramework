//
//  CCPickerCollectionViewCell.h
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

#import <UIKit/UIKit.h>
#import "CCPhoto.h"

typedef void (^callBackBlock)(id obj);

@class CCPickerCollectionViewCell;

@protocol CCPickerCollectionViewCellDelegate <NSObject>

/**
 *  @author CC, 2015-12-23
 *  
 *  @brief  选中事件
 *
 *  @param pickerCollectionView 当前视图
 *  @param indexPath            下标
 */
- (void)didCollectionViewDidSelected:(CCPickerCollectionViewCell *)pickerCollectionView
                           IndexPath:(NSIndexPath *)indexPath;

@end

@interface CCPickerCollectionViewCell : UICollectionViewCell

@property(nonatomic, weak) id<CCPickerCollectionViewCellDelegate> delegate;

@property(nonatomic, strong) UIImageView *overImageView;

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
      IndexPath:(NSIndexPath *)indexPath;

@end
