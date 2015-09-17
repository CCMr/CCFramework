//
//  SmoothViewController.h
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
#import "Config.h"

@interface SmoothViewController : UIViewController

/**
 *  @author CC, 15-08-21
 *
 *  @brief  引导页图片
 *
 *  @since 1.0
 */
@property (nonatomic, strong) NSArray *images;

/**
 *  @author CC, 15-09-11
 *
 *  @brief  完成事件回调
 *
 *  @since 1.0
 */
@property (nonatomic, copy) Completion didSelectedEnter;

/**
 *  @author CC, 15-09-11
 *
 *  @brief  完成按钮背景图片
 *
 *  @since 1.0
 */
@property (nonatomic, strong) NSString *enterBackgroundImage;

/**
 *  @author CC, 15-09-11
 *
 *  @brief  完成按钮大小
 *
 *  @since 1.0
 */
@property (nonatomic, assign) CGSize enterSzie;

/**
 *  @author CC, 15-08-17
 *
 *  @brief  初始化控件
 *
 *  @param bgNames    背景图片数组
 *
 *  @return 返回当前控件
 *
 *  @since 1.0
 */
- (id) initWithCoverImageNames: (NSArray *)bgNames;

/**
 *  @author CC, 15-08-17
 *
 *  @brief  完成回调
 *
 *  @param enterBlock 返回回调block
 *
 *  @since 1.0
 */
- (void) didSelectedEnter:(Completion)enterBlock;

/**
 *  @author CC, 15-08-21
 *
 *  @brief  是否显示
 *
 *  @return return value description
 *
 *  @since <#1.0#>
 */
+ (BOOL) canShowNewFeature;

@end
