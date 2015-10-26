//
//  CCRadarPointView.h
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

@class CCRadarPointView;

/**
 *  @author CC, 15-09-30
 *
 *  @brief  委托
 */
@protocol CCRadarPointViewDelegate <NSObject>

@optional

/**
 *  @author CC, 15-09-30
 *
 *  @brief  点击
 *
 *  @param radarPointView <#radarPointView description#>
 */
- (void)didSeletcdRadarPointView:(CCRadarPointView *)radarPointView;

@end

@interface CCRadarPointView : UIView

/**
 *  @author CC, 15-09-30
 *
 *  @brief  头像地址
 */
@property (nonatomic, assign) NSString *avater;

/**
 *  @author CC, 15-09-30
 *
 *  @brief  角度
 */
@property (nonatomic, assign) CGFloat pointAngle;

/**
 *  @author CC, 15-09-30
 *
 *  @brief  距离终点的距离
 */
@property (nonatomic, assign) CGFloat pointRadius;

/**
 *  @author CC, 15-09-30
 *
 *  @brief  半径
 */
@property (nonatomic, assign) CGFloat radius;

/**
 *  @author CC, 15-09-30
 *
 *  @brief  中间个人头像的半径
 */
@property (nonatomic, assign) CGFloat imageRadius;

@property (nonatomic, weak) id<CCRadarPointViewDelegate> delegate;

@end
