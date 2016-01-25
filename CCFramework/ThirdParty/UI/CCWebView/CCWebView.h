//
//  CCWebView.h
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

@class CCWebView;

@protocol CCWebViewDelegate <NSObject>

@optional

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  加载网页标题
 *
 *  @param webView 当前视图
 *  @param title   标示
 */
- (void)webViewDidFinishLoad:(CCWebView *)webView Title:(NSString *)title;

@end

@interface CCWebView : UIView

@property(nonatomic, weak) id<CCWebViewDelegate> delegate;

@property(nonatomic, assign) UINavigationBar *webViewInitWithProgress;

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  显示网页地址
 *
 *  @param baseURL 网页地址
 */
- (void)loadRequest:(NSString *)baseURL;

/**
 *  @author CC, 2016-01-25
 *  
 *  @brief 加载HTML页面
 *
 *  @param string HTML文件或者字符串
 */
- (void)loadHTMLString:(NSString *)string;

@end
