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


#pragma mark :. Show & hide
- (void)show;

- (void)show:(BOOL)animated;

- (void)hide;

- (void)hide:(BOOL)animated;

- (void)hide:(BOOL)animated
  afterDelay:(NSTimeInterval)delay;

@end
