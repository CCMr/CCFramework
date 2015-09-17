//
//  CCSlideShadowAnimation.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CCSlideShadowAnimation : NSObject

@property (weak, nonatomic) UIView *animatedView;

@property (strong, nonatomic) UIColor *shadowBackgroundColor;
@property (strong, nonatomic) UIColor *shadowForegroundColor;
@property (assign, nonatomic) CGFloat shadowWidth;
@property (assign, nonatomic) CGFloat repeatCount;
/**
 *  @author CC, 15-08-20
 *
 *  @brief  动画速度（数值越小越快）
 *
 *  @since 1.0
 */
@property (assign, nonatomic) NSTimeInterval duration;

/**
 *  @author CC, 15-08-20
 *
 *  @brief  启动函数
 *
 *  @since <#1.0#>
 */
- (void)start;

/**
 *  @author CC, 15-08-20
 *
 *  @brief  停止函数
 *
 *  @since <#1.0#>
 */
- (void)stop;

@end
