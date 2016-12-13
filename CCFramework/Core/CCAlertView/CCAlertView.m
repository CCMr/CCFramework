//
//  CCAlertView.m
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

#import "CCAlertView.h"
#import "CustomIOSAlertView.h"
#import "config.h"
#import "UIView+Frame.h"
#import "NSString+Additions.h"

@implementation CCAlertView

/**
 *  @author CC, 2016-01-04
 *  
 *  @brief  初始化弹出对象
 */
+ (CustomIOSAlertView *)alertView
{
     CustomIOSAlertView *alertView =  (CustomIOSAlertView *)[[[[UIApplication sharedApplication] windows] firstObject] viewWithTag:66666];
    if (!alertView) {
        alertView = [[CustomIOSAlertView alloc] init];
        alertView.containerView.backgroundColor = [UIColor whiteColor];
        alertView.parentView.backgroundColor = [UIColor whiteColor];
        alertView.dialogView.backgroundColor = [UIColor whiteColor];
        [alertView setButtonTitles:@[]];
        [alertView setUseMotionEffects:YES];
    }
    
    return alertView;
}

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
  OnButtonTouchUpInside:(void (^)(NSInteger buttonIndex))onButtonTouchUpInside
{
    NSMutableArray *buttons = [NSMutableArray array];
    for (id button in buttonTitles) {
        if ([button isKindOfClass:[NSString class]]) {
            CCAlertModel *alertModel = [[CCAlertModel alloc] init];
            alertModel.Title = button;
            alertModel.TitleColor = [UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f];
            [buttons addObject:alertModel];
        }else{
            [buttons addObject:button];
        }
    }
    
    [self showWithMessage:nil
              withMessage:message
     withButtonTitleArray:buttons
    OnButtonTouchUpInside:onButtonTouchUpInside];
}

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
  OnButtonTouchUpInside:(void (^)(NSInteger buttonIndex))onButtonTouchUpInside
{
    CGFloat heigth = 20;
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 224, 0)];
    
    if (title && ![title isEqualToString:@""]) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, containerView.width - 20, 20)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:18];
        titleLabel.text = title;
        [containerView addSubview:titleLabel];
        heigth = titleLabel.bottom + 10;
    }
    
    if (message && ![message isEqualToString:@""]) {
        CGFloat h = [message calculateTextWidthWidth:containerView.width Font:[UIFont systemFontOfSize:15]].height;
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, heigth, containerView.width - 20, h)];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont systemFontOfSize:15];
        messageLabel.text = message;
        [containerView addSubview:messageLabel];
        
        heigth = messageLabel.bottom + 20;
    }
    
    containerView.frame = CGRectMake(0, 0, 224, heigth);
    
    NSMutableArray *buttons = [NSMutableArray array];
    for (id button in buttonTitles) {
        if ([button isKindOfClass:[NSString class]]) {
            CCAlertModel *alertModel = [[CCAlertModel alloc] init];
            alertModel.Title = button;
            alertModel.TitleColor = [UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f];
            [buttons addObject:alertModel];
        }else{
            [buttons addObject:button];
        }
    }

    
    [self showWithContainerView:containerView
           withButtonTitleArray:buttons
          OnButtonTouchUpInside:^(UIView *containerView, NSInteger buttonIndex) {
              onButtonTouchUpInside?onButtonTouchUpInside(buttonIndex):nil;
          }];
}

+ (void)showWithContainerView:(UIView *)containerView
                withIsPackage:(BOOL)isPackage
               withIsExternal:(BOOL)isExternal
{
    cc_View_SingleFillet(containerView, UIRectCornerTopLeft | UIRectCornerTopRight, 5);
    
    CustomIOSAlertView *alertView = [self alertView];
    alertView.containerView = containerView;
    alertView.IsExternal = isExternal;
    alertView.isPackage = isPackage;
    [alertView show];
}

/**
 *  @author CC, 2016-01-04
 *  
 *  @brief  弹出框
 *
 *  @param containerView 自定义视图对象
 *  @param isExternal    是否点击外部关闭
 */
+ (void)showWithContainerView:(UIView *)containerView
               withIsExternal:(BOOL)isExternal
{
    [self showWithContainerView:containerView 
                  withIsPackage:YES 
                 withIsExternal:isExternal];
}

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
        OnButtonTouchUpInside:(void (^)(UIView *containerView, NSInteger buttonIndex))onButtonTouchUpInside
{
    CustomIOSAlertView *alertView = [self alertView];
    [alertView setContainerView:containerView];
    
    NSMutableArray *buttons = [NSMutableArray array];
    for (id button in buttonTitles) {
        if ([button isKindOfClass:[NSString class]]) {
            CCAlertModel *alertModel = [[CCAlertModel alloc] init];
            alertModel.Title = button;
            alertModel.TitleColor = [UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f];
            [buttons addObject:alertModel];
        }else{
            [buttons addObject:button];
        }
    }
    
    [alertView setButtonTitles:buttons];
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        if (onButtonTouchUpInside)
            onButtonTouchUpInside(alertView.containerView,buttonIndex);
        [alertView close];
    }];
    [alertView show];
}

/**
 隐藏弹窗
 
 @param animated 动画
 */
+ (void)close
{
    [[self alertView] close];
}

/**
 隐藏弹窗
 
 @param animated 动画
 @param delay 时长
 */
+ (void)close:(NSTimeInterval)delay
{
    [self performSelector:@selector(hideDelayed:)
               withObject:nil
               afterDelay:delay];
}

+ (void)hideDelayed
{
    [self close];
}

@end
