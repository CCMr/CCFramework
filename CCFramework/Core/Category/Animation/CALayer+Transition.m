//
//  CALayer+Transition.m
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

#import "CALayer+Transition.h"

@implementation CALayer (Transition)

/**
 *  @author CC, 15-09-02
 *
 *  @brief  转场动画
 *
 *  @param animType 转场动画类型
 *  @param subType  转动动画方向
 *  @param curve    转动动画曲线
 *  @param duration 转动动画时长
 *
 *  @return 转场动画实例
 *
 *  @since 1.0
 */
- (CATransition *)transitionWithAnimType: (CCTransitionAnimType)animType
                                subType: (CCTransitionSubtypes)subType
                                  curve: (CCTransitionCurve)curve
                               duration:(CGFloat)duration
{

    NSString *key = @"transition";

    if([self animationForKey:key]!=nil){
        [self removeAnimationForKey:key];
    }

    CATransition *transition=[CATransition animation];

    //动画时长
    transition.duration=duration;

    //动画类型
    transition.type = [self animaTypeWithTransitionType:animType];

    //动画方向
    transition.subtype = [self animaSubtype:subType];

    //缓动函数
    transition.timingFunction=[CAMediaTimingFunction functionWithName:[self curve:curve]];

    //完成动画删除
    transition.removedOnCompletion = YES;

    [self addAnimation:transition forKey:key];

    return transition;
}

/**
 *  @author CC, 15-09-02
 *
 *  @brief  返回动画曲线
 *
 *  @param curve 转动动画曲线
 *
 *  @return <#return value description#>
 *
 *  @since <#1.0#>
 */
- (NSString *)curve: (CCTransitionCurve)curve
{
    //曲线数组
    NSArray *funcNames=@[kCAMediaTimingFunctionDefault,kCAMediaTimingFunctionEaseIn,kCAMediaTimingFunctionEaseInEaseOut,kCAMediaTimingFunctionEaseOut,kCAMediaTimingFunctionLinear];

    return [self objFromArray:funcNames index:curve isRamdom:(CCTransitionCurveRamdom == curve)];
}

/**
 *  @author CC, 15-09-02
 *
 *  @brief  返回动画方向
 *
 *  @param subType 转动动画方向
 *
 *  @return <#return value description#>
 *
 *  @since <#1.0#>
 */
- (NSString *)animaSubtype: (CCTransitionSubtypes)subType
{

    //设置转场动画的方向
    NSArray *subtypes = @[kCATransitionFromTop,kCATransitionFromLeft,kCATransitionFromBottom,kCATransitionFromRight];

    return [self objFromArray:subtypes index:subType isRamdom:(CCTransitionSubtypesFromRamdom == subType)];
}

/**
 *  @author CC, 15-09-02
 *
 *  @brief  返回动画类型
 *
 *  @param type 转场动画类型
 *
 *  @return <#return value description#>
 *
 *  @since <#1.0#>
 */
- (NSString *)animaTypeWithTransitionType: (CCTransitionAnimType)type
{
    //设置转场动画的类型
    NSArray *animArray = @[@"rippleEffect",@"suckEffect",@"pageCurl",@"oglFlip",@"cube",@"reveal",@"pageUnCurl",@"push"];

    return [self objFromArray:animArray index:type isRamdom:(CCTransitionAnimTypeRamdom == type)];
}

/**
 *  @author CC, 15-09-02
 *
 *  @brief  统一从数据返回对象
 *
 *  @param array    <#array description#>
 *  @param index    <#index description#>
 *  @param isRamdom <#isRamdom description#>
 *
 *  @return <#return value description#>
 *
 *  @since <#1.0#>
 */
- (id)objFromArray: (NSArray *)array
             index: (NSUInteger)index
          isRamdom: (BOOL)isRamdom
{
    NSUInteger count = array.count;
    NSUInteger i = isRamdom?arc4random_uniform((u_int32_t)count) : index;
    return array[i];
}

@end
