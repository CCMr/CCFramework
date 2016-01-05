//
//  CCInfoBanner.h
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

@interface CCInfoBanner : UIView

#pragma mark :. 设置属性
/**
 *  @author CC, 2016-01-05
 *  
 *  @brief  设置标题
 *
 *  @param title 标题
 */
- (void)setTitle:(NSString *)title;

/**
 *  @author CC, 2016-01-05
 *  
 *  @brief  设置图标与标题
 *
 *  @param icon  图标
 *  @param title 标题
 */
- (void)setIconWithTile:(NSString *)icon
                  Title:(NSString *)title;

#pragma mark :. 静态调用
/**
 *  @author CC, 2016-12-30
 *  
 *  @brief  提示
 *
 *  @param text 标题
 */
+ (void)showWithText:(NSString *)text;

/**
 *  @author CC, 2016-12-30
 *  
 *  @brief  提示
 *
 *  @param title       标题
 *  @param detailsText 详细内容
 */
+ (void)showWithTitle:(NSString *)title
          DetailsText:(NSString *)detailsText;

/**
 *  @author CC, 2016-12-30
 *  
 *  @brief  提示图标
 *
 *  @param icon  图标
 *  @param title 标题
 */
+ (void)showWithIcon:(NSString *)icon
               Title:(NSString *)title;

/**
 *  @author CC, 2016-12-30
 *  
 *  @brief  提示图标
 *
 *  @param icon        图标
 *  @param title       标题
 *  @param detailsText 详细内容
 */
+ (void)showWithIcon:(NSString *)icon
               Title:(NSString *)title
         DetailsText:(NSString *)detailsText;

/**
 *  @author CC, 2016-12-30
 *  
 *  @brief  提示GIF图标
 *
 *  @param icon  图标
 *  @param title 标题
 */
+ (void)showWithIconGIF:(NSString *)icon
                  Title:(NSString *)title;

/**
 *  @author CC, 2016-12-30
 *  
 *  @brief  提示GIF图标
 *
 *  @param icon        图标
 *  @param title       标题
 *  @param detailsText 详细内容
 */
+ (void)showWithIconGIF:(NSString *)icon
                  Title:(NSString *)title
            DetailsText:(NSString *)detailsText;

/**
 *  @author CC, 2016-12-30
 *  
 *  @brief  提示加载
 *
 *  @param title           标题
 *  @param executingBlock  执行函数
 */
+ (void)showWithExecutingBlock:(NSString *)title
           whileExecutingBlock:(dispatch_block_t)executingBlock;

/**
 *  @author CC, 2016-12-30
 *  
 *  @brief  提示加载
 *
 *  @param title           标题
 *  @param executingBlock  执行函数
 *  @param completionBlock 完成函数
 */
+ (void)showWithExecutingBlock:(NSString *)title
           whileExecutingBlock:(dispatch_block_t)executingBlock
          whileCompletionBlock:(dispatch_block_t)completionBlock;

/**
 *  @author CC, 2016-12-30
 *  
 *  @brief  提示加载
 *
 *  @param title           标题
 *  @param detailsText     详细
 *  @param executingBlock  执行函数
 *  @param completionBlock 完成回调函数
 */
+ (void)showWithExecutingBlock:(NSString *)title
                   DetailsText:(NSString *)detailsText
           whileExecutingBlock:(dispatch_block_t)executingBlock
          whileCompletionBlock:(dispatch_block_t)completionBlock;

/**
 *  @author CC, 2016-01-05
 *  
 *  @brief  创建指示器视图
 */
+ (CCInfoBanner *)showWithIndicatorView;

#pragma mark :. Show & hide
- (void)show;

- (void)show:(BOOL)animated;

- (void)hide;

- (void)hide:(BOOL)animated;

- (void)hide:(BOOL)animated
  afterDelay:(NSTimeInterval)delay;

- (void)showAnimated:(BOOL)animated
 whileExecutingBlock:(dispatch_block_t)block;

- (void)showAnimated:(BOOL)animated
 whileExecutingBlock:(dispatch_block_t)block
     completionBlock:(void (^)())completion;

- (void)showAnimated:(BOOL)animated
 whileExecutingBlock:(dispatch_block_t)block
             onQueue:(dispatch_queue_t)queue;

- (void)showAnimated:(BOOL)animated
 whileExecutingBlock:(dispatch_block_t)block
             onQueue:(dispatch_queue_t)queue
     completionBlock:(void (^)())completion;

@end
