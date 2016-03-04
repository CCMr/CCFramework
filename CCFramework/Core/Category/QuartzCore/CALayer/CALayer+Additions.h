//
//  CALayer+Additions.h
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

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface CALayer (Additions)

@property(nonatomic, assign) UIColor *borderUIColor;

//setting background for UIView
@property(nonatomic, assign) UIColor *contentsUIImage;


#pragma nark -
#pragma mark :. Transition

/**
 *  @author CC, 15-09-02
 *
 *  @brief  动画类型
 */
typedef NS_ENUM(NSInteger, CCTransitionAnimType) {
    /** 水波 **/
    CCTransitionAnimTypeRippleEffect = 0,
    /** 吸走 **/
    CCTransitionAnimTypeSuckEffect,
    /** 翻开书本 **/
    CCTransitionAnimTypePageCurl,
    /** 正反翻转 **/
    CCTransitionAnimTypeOglFlip,
    /** 正方体 **/
    CCTransitionAnimTypeCube,
    /** push推开 **/
    CCTransitionAnimTypeReveal,
    /** 合上书本 **/
    CCTransitionAnimTypePageUnCurl,
    /** 随机 **/
    CCTransitionAnimTypeRamdom,
};

/**
 *  @author CC, 15-09-02
 *
 *  @brief  动画方向
 */
typedef NS_ENUM(NSInteger, CCTransitionSubtypes) {
    /** 从上 **/
    CCTransitionSubtypesFromTop = 0,
    /** 从左 **/
    CCTransitionSubtypesFromLeft,
    /** 从下 **/
    CCTransitionSubtypesFromBotoom,
    /** 从右 **/
    CCTransitionSubtypesFromRight,
    /** 随机 **/
    CCTransitionSubtypesFromRamdom,
};

/**
 *  @author CC, 15-09-02
 *
 *  @brief  动画曲线 */
typedef NS_ENUM(NSInteger, CCTransitionCurve) {
    /** 默认 **/
    CCTransitionCurveDefault,
    /** 缓进 **/
    CCTransitionCurveEaseIn,
    /** 缓出 **/
    CCTransitionCurveEaseOut,
    /** 缓进缓出 **/
    CCTransitionCurveEaseInEaseOut,
    /** 线性 **/
    CCTransitionCurveLinear,
    /** 随机 **/
    CCTransitionCurveRamdom,
};

/**
 *  @author CC, 15-09-02
 *
 *  @brief  转场动画
 *
 *  @param animType 转场动画类型
 *  @param subType  转动动画方向
 *  @param curve    转动动画曲线
 *  @param duration 转动动画时长
 */
- (CATransition *)transitionWithAnimType:(CCTransitionAnimType)animType
                                 subType:(CCTransitionSubtypes)subType
                                   curve:(CCTransitionCurve)curve
                                duration:(CGFloat)duration;

@end
