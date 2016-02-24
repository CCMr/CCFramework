//
//  CCPhotoPreviewViewLayout.m
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

#import "CCPhotoPreviewViewLayout.h"
#import "config.h"

#define ACTIVE_DISTANCE 200

@implementation CCPhotoPreviewViewLayout

- (instancetype)init
{
    if (self = [super init]) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.itemSize = CGSizeMake(winsize.width, winsize.height);
        self.minimumInteritemSpacing = 0;
        self.minimumLineSpacing = 0;
    }
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds
{
    return YES;
}

//最大旋转角度
#define rotate 35.0 * M_PI / 180.0
//返回一个rect位置下所有cell的位置数组
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    //得到所有的UICollectionViewLayoutAttributes
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    
    for (UICollectionViewLayoutAttributes *attributes in array) {
        //cell中心离collectionview中心的位移
        //CGRectGetMidX表示得到一个frame中心点的X坐标
        CGFloat distance = CGRectGetMidX(visibleRect) - attributes.center.x;
        //CGRectIntersectsRect 判断两个矩形是否相交
        //这里判断当前这个cell在不在rect矩形里
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            CGFloat normalizedDistance = distance / ACTIVE_DISTANCE;
            //ABS 绝对值
            //如果位移小于一个过程所需的位移
            if (ABS(distance) < ACTIVE_DISTANCE) {
                //normalizedDistance 当前位移比上完成一个过程所需位移 得到不完全过程的旋转角度
                CGFloat zoom = rotate * normalizedDistance;
                CATransform3D transfrom = CATransform3DIdentity;
                transfrom.m34 = 1.0 / 600;
                transfrom = CATransform3DRotate(transfrom, -zoom, 0.0f, 1.0f, 0.0f);
                attributes.transform3D = transfrom;
                attributes.zIndex = 1;
            } else {
                CATransform3D transfrom = CATransform3DIdentity;
                transfrom.m34 = 1.0 / 600;
                
                if (distance > 0) { //向右滑
                    transfrom = CATransform3DRotate(transfrom, -rotate, 0.0f, 1.0f, 0.0f);
                } else { //向左滑
                    transfrom = CATransform3DRotate(transfrom, rotate, 0.0f, 1.0f, 0.0f);
                }
                
                attributes.transform3D = transfrom;
                attributes.zIndex = 1;
            }
        }
    }
    return array;
}

//类似于scrollview的scrollViewWillEndDragging
//proposedContentOffset是没有对齐到网格时本来应该停下的位置
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGFloat offsetAdjustment = MAXFLOAT;
    //CGRectGetWidth: 返回矩形的宽度
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
    //当前rect
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    
    NSArray *array = [super layoutAttributesForElementsInRect:targetRect];
    //对当前屏幕中的UICollectionViewLayoutAttributes逐个与屏幕中心进行比较，找出最接近中心的一个
    for (UICollectionViewLayoutAttributes *layoutAttributes in array) {
        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment))//与中心的位移差
            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
    }
    //返回修改后停下的位置
    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}

@end
