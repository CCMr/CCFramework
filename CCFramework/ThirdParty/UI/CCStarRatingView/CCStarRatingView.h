//
//  CCStarRatingView.h
//  CCFramework
//
// Copyright (c) 2016 CC ( http://www.ccskill.com )
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

@class CCStarRatingView;

@protocol CCStarRatingViewDeleage <NSObject>

@optional

/**
 *  @author CC, 2016-01-11
 *  
 *  @brief 返回分值
 *
 *  @param starRationView 当前视图
 *  @param scroe          分值
 */
- (void)didStarRatingView:(CCStarRatingView *)starRationView
                    Score:(float)scroe;

@end

@interface CCStarRatingView : UIView

/**
 *  @author CC, 2016-01-11
 *  
 *  @brief 初始化
 *
 *  @param frame            位置
 *  @param starRatingNumber 评分星数
 */
- (instancetype)initWithFrame:(CGRect)frame
             StarRatingNumber:(NSInteger)starRatingNumber;

/**
 *  @author CC, 2016-01-11
 *  
 *  @brief 星级数
 */
@property(nonatomic, assign) NSInteger StarRatingNumber;

/**
 *  @author CC, 2016-01-11
 *  
 *  @brief 最大分值数
 */
@property(nonatomic, assign) NSInteger maxNumber;

/**
 *  @author CC, 2016-01-11
 *  
 *  @brief 星星背景
 */
@property(nonatomic, copy) NSString *starBackgroundImageName;

/**
 *  @author CC, 2016-01-11
 *  
 *  @brief 打分星星
 */
@property(nonatomic, copy) NSString *starForegroundImageName;

@property(nonatomic, weak) id<CCStarRatingViewDeleage> delegate;

/**
 *  @author CC, 2016-01-11
 *  
 *  @brief 评分回调
 *
 *  @param block 回调函数
 */
- (void)didStarRatingView:(void (^)(CCStarRatingView *starRationView, float scroe))block;

/**
 *  @author CC, 2016-01-11
 *  
 *  @brief 设置评分
 *
 *  @param score     评分
 *  @param animation 动画
 */
- (void)setScore:(float)score
       Animation:(bool)animation;

/**
 *  @author CC, 2016-01-11
 *  
 *  @brief 设置评分
 *
 *  @param score      评分
 *  @param animate    动画
 *  @param completion 完成回调
 */
- (void)setScore:(float)score
       Animation:(bool)animation
      Completion:(void (^)(bool finished))completion;

@end
