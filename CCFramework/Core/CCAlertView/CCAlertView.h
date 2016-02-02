//
//  CCAlertView.h
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

@interface CCAlertView : NSObject

/**
 *  @author CC, 16-02-02
 *  
 *  @brief 提醒框
 *
 *  @param message               消息内容
 *  @param buttonTitles          按钮
 *  @param onButtonTouchUpInside 回调事件
 */
+ (void)showWithMessage:(NSString *)message
   withButtonTitleArray:(NSArray *)buttonTitles
  OnButtonTouchUpInside:(void (^)(NSInteger buttonIndex))onButtonTouchUpInside;

/**
 *  @author CC, 16-02-02
 *  
 *  @brief 弹出提示消息
 *
 *  @param title                 消息标题
 *  @param message               消息内容
 *  @param buttonTitles          按钮
 *  @param onButtonTouchUpInside 回调事件
 */
+ (void)showWithMessage:(NSString *)title
            withMessage:(NSString *)message
   withButtonTitleArray:(NSArray *)buttonTitles
  OnButtonTouchUpInside:(void (^)(NSInteger buttonIndex))onButtonTouchUpInside;


/**
 *  @author CC, 2016-01-04
 *  
 *  @brief  弹出框
 *
 *  @param containerView 自定义视图对象
 *  @param isExternal    是否点击外部关闭
 */
+ (void)showWithContainerView:(UIView *)containerView
               withIsExternal:(BOOL)isExternal;

/**
 *  @author CC, 2016-01-04
 *  
 *  @brief  弹窗框
 *
 *  @param containerView         自定义对象视图
 *  @param buttonTitles          按钮名称集合
 *  @param onButtonTouchUpInside 按钮回调函数
 */
+ (void)showWithContainerView:(UIView *)containerView
         withButtonTitleArray:(NSArray *)buttonTitles
        OnButtonTouchUpInside:(void (^)(NSInteger buttonIndex))onButtonTouchUpInside;

@end
