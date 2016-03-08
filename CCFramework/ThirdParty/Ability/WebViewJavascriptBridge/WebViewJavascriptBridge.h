//
//  WebViewJavascriptBridge.h
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

/*
 //初始化
 _bridge = [WebViewJavascriptBridge bridgeForWebView:webView];
 
 [_bridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
    NSLog(@"testObjcCallback called: %@", data);
    responseCallback(@"Response from testObjcCallback");
 }];
 
 [_bridge callHandler:@"testJavascriptHandler" data:@{ @"foo":@"before ready" }];
 
 id data = @{ @"greetingFromObjC": @"Hi there, JS!" };
 [_bridge callHandler:@"testJavascriptHandler" data:data responseCallback:^(id response) {
    NSLog(@"testJavascriptHandler responded: %@", response);
 }];
 
 
 */

#import <Foundation/Foundation.h>
#import "WebViewJavascriptBridgeBase.h"

#if defined __MAC_OS_X_VERSION_MAX_ALLOWED
#import <WebKit/WebKit.h>
#define WVJB_PLATFORM_OSX
#define WVJB_WEBVIEW_TYPE WebView
#define WVJB_WEBVIEW_DELEGATE_TYPE NSObject<WebViewJavascriptBridgeBaseDelegate>
#define WVJB_WEBVIEW_DELEGATE_INTERFACE NSObject<WebViewJavascriptBridgeBaseDelegate, WebPolicyDelegate>
#elif defined __IPHONE_OS_VERSION_MAX_ALLOWED
#import <UIKit/UIWebView.h>
#define WVJB_PLATFORM_IOS
#define WVJB_WEBVIEW_TYPE UIWebView
#define WVJB_WEBVIEW_DELEGATE_TYPE NSObject<UIWebViewDelegate>
#define WVJB_WEBVIEW_DELEGATE_INTERFACE NSObject<UIWebViewDelegate, WebViewJavascriptBridgeBaseDelegate>
#endif

@interface WebViewJavascriptBridge : WVJB_WEBVIEW_DELEGATE_INTERFACE

+ (instancetype)bridgeForWebView:(WVJB_WEBVIEW_TYPE *)webView;
+ (void)enableLogging;
+ (void)setLogMaxLength:(int)length;

- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler)handler;
- (void)callHandler:(NSString *)handlerName;
- (void)callHandler:(NSString *)handlerName data:(id)data;
- (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback;
- (void)setWebViewDelegate:(WVJB_WEBVIEW_DELEGATE_TYPE *)webViewDelegate;
@end
