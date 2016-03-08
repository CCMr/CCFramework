//
//  WKWebViewJavascriptBridge.m
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

#import "WKWebViewJavascriptBridge.h"

#if defined(supportsWKWebKit)

@implementation WKWebViewJavascriptBridge {
    WKWebView *_webView;
    id<WKNavigationDelegate> _webViewDelegate;
    long _uniqueId;
    WebViewJavascriptBridgeBase *_base;
}

/* API
 *****/

+ (void)enableLogging
{
    [WebViewJavascriptBridgeBase enableLogging];
}

+ (instancetype)bridgeForWebView:(WKWebView *)webView
{
    WKWebViewJavascriptBridge *bridge = [[self alloc] init];
    [bridge _setupInstance:webView];
    [bridge reset];
    return bridge;
}

- (void)send:(id)data
{
    [self send:data responseCallback:nil];
}

- (void)send:(id)data responseCallback:(WVJBResponseCallback)responseCallback
{
    [_base sendData:data responseCallback:responseCallback handlerName:nil];
}

- (void)callHandler:(NSString *)handlerName
{
    [self callHandler:handlerName data:nil responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data
{
    [self callHandler:handlerName data:data responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback
{
    [_base sendData:data responseCallback:responseCallback handlerName:handlerName];
}

- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler)handler
{
    _base.messageHandlers[handlerName] = [handler copy];
}

- (void)reset
{
    [_base reset];
}

- (void)setWebViewDelegate:(id<WKNavigationDelegate>)webViewDelegate
{
    _webViewDelegate = webViewDelegate;
}

/* Internals
 ***********/

- (void)dealloc
{
    _base = nil;
    _webView = nil;
    _webViewDelegate = nil;
    _webView.navigationDelegate = nil;
}


/* WKWebView Specific Internals
 ******************************/

- (void)_setupInstance:(WKWebView *)webView
{
    _webView = webView;
    _webView.navigationDelegate = self;
    _base = [[WebViewJavascriptBridgeBase alloc] init];
    _base.delegate = self;
}


- (void)WKFlushMessageQueue
{
    [_webView evaluateJavaScript:[_base webViewJavascriptFetchQueyCommand] completionHandler:^(NSString *result, NSError *error) {
        if (error != nil) {
            NSLog(@"WebViewJavascriptBridge: WARNING: Error when trying to fetch data from WKWebView: %@", error);
        }
        [_base flushMessageQueue:result];
    }];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    if (webView != _webView) {
        return;
    }
    
    __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didFinishNavigation:)]) {
        [strongDelegate webView:webView didFinishNavigation:navigation];
    }
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if (webView != _webView) {
        return;
    }
    NSURL *url = navigationAction.request.URL;
    __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
    
    if ([_base isCorrectProcotocolScheme:url]) {
        if ([_base isBridgeLoadedURL:url]) {
            [_base injectJavascriptFile];
        } else if ([_base isQueueMessageURL:url]) {
            [self WKFlushMessageQueue];
        } else {
            [_base logUnkownMessage:url];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)]) {
        [_webViewDelegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    if (webView != _webView) {
        return;
    }
    
    __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didStartProvisionalNavigation:)]) {
        [strongDelegate webView:webView didStartProvisionalNavigation:navigation];
    }
}


- (void)webView:(WKWebView *)webView
didFailNavigation:(WKNavigation *)navigation
      withError:(NSError *)error
{
    if (webView != _webView) {
        return;
    }
    
    __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didFailNavigation:withError:)]) {
        [strongDelegate webView:webView didFailNavigation:navigation withError:error];
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if (webView != _webView) {
        return;
    }
    
    __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didFailProvisionalNavigation:withError:)]) {
        [strongDelegate webView:webView didFailProvisionalNavigation:navigation withError:error];
    }
}

- (NSString *)_evaluateJavascript:(NSString *)javascriptCommand
{
    [_webView evaluateJavaScript:javascriptCommand completionHandler:nil];
    return NULL;
}


@end


#endif
