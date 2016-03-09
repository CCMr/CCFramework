//
//  UICollectionViewCell+Additions.h
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

@interface UICollectionViewCell (Additions)

/**
 *  @brief  加载同类名的nib
 *
 *  @return nib
 */
+ (UINib *)nib;

/**
 *  登记UICollectionView的Cell
 *  1. nib读取    （优先）
 *  2. 文件名获取
 */
+ (void)registerCollect:(UICollectionView *)collectionView
        nibIdentifier:(NSString *)identifier;
/**
 *  配置UITableViewCell，设置UITableViewCell内容
 */
- (void)configure:(UICollectionViewCell *)collectionViewCell
        customObj:(id)obj
        indexPath:(NSIndexPath *)indexPath;
/**
 *  获取自定义对象的cell高度 (已集成UITableView+Additions，现在创建的cell自动计算高度)
 */
+ (CGFloat)obtainCellHeightWithCustomObj:(id)obj
                               indexPath:(NSIndexPath *)indexPath;

@end
