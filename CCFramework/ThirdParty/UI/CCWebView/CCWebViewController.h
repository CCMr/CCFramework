//
//  CCWebViewController.h
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

@interface CCWebViewController : UIViewController

@property(nonatomic, assign) UINavigationBar *webViewInitWithProgress;

/**
 是否显示来源背景 (默认显示)
 */
@property(nonatomic, assign) BOOL isSource;

/**
 *  @author C C, 2016-10-05
 *  
 *  @brief  标题是否跟随变化（默认 YES）
 */
@property(nonatomic, assign) BOOL isTitleFollowChange;

/**
 是否允许左右划手势导航，默认允许
 */
@property(nonatomic, assign) BOOL allowsBackForwardNavigationGestures;

/**
 是否允许滚动, 默认允许
 */
@property(nonatomic, assign) BOOL isScrollEnabled;

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

/**
 *  @author CC, 16-09-23
 *
 *  @brief 跳转页面
 *
 *  @param baseURL URL地址
 */
- (void)jumpPage:(NSString *)baseURL;

- (BOOL)isGoBack;
- (BOOL)isGoForward;

/**
 *  @author CC, 16-09-23
 *
 *  @brief 页面后退
 */
- (void)goBack;
/**
 *  @author CC, 16-09-23
 *
 *  @brief 页面前进
 */
- (void)goForward;

/**
 *  @author CC, 16-07-30
 *
 *  @brief JS捕获
 *
 *  @param functionName JS函数名
 *  @param block        回调事件
 */
- (void)didCapture:(NSString *)functionName
     ResponseBlock:(void (^)(NSString *functionName, id arguments))block;

/**
 *  @author CC, 16-07-30
 *
 *  @brief 多个JS捕获
 *
 *  @param functionName JS函数名
 *  @param block        回调事件
 */
- (void)didCaptures:(NSArray<NSString *> *)functionNames
      ResponseBlock:(void (^)(NSString *functionName, id arguments))block;

/**
 *  @author CC, 16-09-23
 *
 *  @brief OC调用Js
 *
 *  @param javaScriptString  JS函数名
 *  @param completionHandler 回调事件
 */
- (void)evaluateJavaScript:(NSString *)javaScriptString
         completionHandler:(void (^)(id response, NSError *error))completionHandler;

/**
 *  @author CC, 16-09-22
 *
 *  @brief 观察标题
 *
 *  @param title 标题
 */
-(void)observeTitle:(NSString *)title;

@end
