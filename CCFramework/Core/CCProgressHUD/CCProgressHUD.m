//
//  CCProgressHUD.m
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

#import "CCProgressHUD.h"
#import "MBProgressHUD.h"
#import "config.h"

@implementation CCProgressHUD

/**
 *  @author CC, 2016-12-29
 *  
 *  @brief  初始化弹出对象
 */
+ (MBProgressHUD *)initialization
{
    UIWindow *windowView = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud = (MBProgressHUD *)[windowView viewWithTag:999999];
    if (!hud) {
        hud = [MBProgressHUD showHUDAddedTo:windowView animated:YES];
        hud.removeFromSuperViewOnHide = YES;
        hud.dimBackground = NO;
        hud.tag = 999999;
    }
    
    return hud;
}

/**
 *  @author CC, 2016-12-29
 *  
 *  @brief  初始化弹窗消息类型
 */
+ (MBProgressHUD *)initializationMessages
{
    MBProgressHUD *hud = [self initialization];
    hud.mode = MBProgressHUDModeText;
    //    HUD.labelFont = Font19And17(systemFontOfSize, 15);
    hud.labelColor = [UIColor whiteColor];
    //    HUD.detailsLabelFont = Font19And17(systemFontOfSize, 15);
    hud.detailsLabelColor = [UIColor whiteColor];
    return hud;
}

/**
 *  @author CC, 2016-12-29
 *  
 *  @brief  提示消息
 *
 *  @param LabelText        标题内容
 *  @param detailsLabelText 详细内容
 */
+ (void)hudMessages:(NSString *)LabelText
   DetailsLabelText:(NSString *)detailsLabelText
{
    MBProgressHUD *hud = [self initializationMessages];
    hud.labelText = LabelText;
    hud.detailsLabelText = detailsLabelText;
    [hud show:YES];
    [hud hide:YES afterDelay:1.5];
}

/**
 *  @author CC, 2016-12-29
 *  
 *  @brief  底部提示
 *
 *  @param detailsLabelText 提示内容
 */
+ (void)hudToastMessage:(NSString *)detailsLabelText
{
    MBProgressHUD *hud = [self initializationMessages];
    hud.yOffset = (winsize.height - 64) / 2 - 20;
    hud.labelText = nil;
    hud.detailsLabelText = detailsLabelText;
    [hud show:YES];
    [hud hide:YES afterDelay:1.5];
}

/**
 *  @author CC, 2016-12-30
 *  
 *  @brief  提示
 *
 *  @param LabelText 标题
 *  @param animated  是否动画
 *  @param block     执行函数
 */
+ (void)showMessage:(NSString *)LabelText
           Animated:(BOOL)animated
whileExecutingBlock:(dispatch_block_t)block
{
    [self showMessage:LabelText
     DetailsLabelText:nil
             Animated:animated
  whileExecutingBlock:block];
}

/**
 *  @author CC, 2016-12-30
 *  
 *  @brief  提示
 *
 *  @param LabelText        标题
 *  @param detailsLabelText 详细内容
 *  @param animated         是否动画
 *  @param block            执行函数
 */
+ (void)showMessage:(NSString *)LabelText
   DetailsLabelText:(NSString *)detailsLabelText
           Animated:(BOOL)animated
whileExecutingBlock:(dispatch_block_t)block
{
    [self showMessage:LabelText
     DetailsLabelText:detailsLabelText
             Animated:animated
  whileExecutingBlock:block
      completionBlock:nil];
}

/**
 *  @author CC, 2016-12-30
 *  
 *  @brief  提示
 *
 *  @param LabelText        标题
 *  @param detailsLabelText 详细内容
 *  @param animated         是否动画
 *  @param block            执行函数
 *  @param completion       完成函数
 */
+ (void)showMessage:(NSString *)LabelText
   DetailsLabelText:(NSString *)detailsLabelText
           Animated:(BOOL)animated
whileExecutingBlock:(dispatch_block_t)block
    completionBlock:(void (^)())completion
{
    MBProgressHUD *hud = [self initializationMessages];
    hud.labelText = LabelText;
    hud.detailsLabelText = detailsLabelText;
    
    [hud showAnimated:animated
  whileExecutingBlock:block
      completionBlock:completion];
}


#pragma mark :. Show & hide
/**
 *  @author CC, 2016-12-29
 *  
 *  @brief  显弹窗
 *
 *  @param animated 动画
 */
+ (void)show:(BOOL)animated
{
    [[self initialization] show:animated];
}

/**
 *  @author CC, 2016-12-29
 *  
 *  @brief  隐藏弹窗
 *
 *  @param animated 动画
 */
+ (void)hide:(BOOL)animated
{
    [[self initialization] hide:animated];
}

/**
 *  @author CC, 2016-12-29
 *  
 *  @brief  隐藏弹窗
 *
 *  @param animated 动画
 *  @param delay    时长
 */
+ (void)hide:(BOOL)animated
  afterDelay:(NSTimeInterval)delay
{
    [self performSelector:@selector(hideDelayed:)
               withObject:[NSNumber numberWithBool:animated]
               afterDelay:delay];
}

+ (void)hideDelayed:(NSNumber *)animated
{
    [self hide:[animated boolValue]];
}

@end
