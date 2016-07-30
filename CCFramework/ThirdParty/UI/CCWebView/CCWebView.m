//
//  CCWebView.m
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

#import "CCWebView.h"
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "CCWebViewProgress.h"
#import "CCWebViewProgressView.h"
#import "config.h"
#import <JavaScriptCore/JavaScriptCore.h>

typedef void (^ResponseBlock)(NSString *functionName, NSArray *arguments);

@interface CCWebView () <WKNavigationDelegate, WKUIDelegate, CCWebViewProgressDelegate, CCWebViewProgressDelegate, UIWebViewDelegate>

@property(nonatomic, strong) JSContext *webViewJSContext;

@property(nonatomic, strong) WKWebViewConfiguration *configuration;

@property(nonatomic, strong) UIWebView *webView;

@property(nonatomic, strong) WKWebView *webWKView;

@property(nonatomic, strong) UILabel *originLable;

@property(nonatomic, strong) UIView *backgroundView;

@property(nonatomic, strong) CCWebViewProgress *webViewProgress;

@property(nonatomic, strong) CCWebViewProgressView *progressView;

@property(nonatomic, copy) ResponseBlock responseBlock;

@end

@implementation CCWebView

- (instancetype)init
{
    if (self = [super init]) {
        [self initView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

- (void)initView
{
    _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:_backgroundView];

    _originLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(self.bounds), 20)];
    _originLable.backgroundColor = [UIColor clearColor];
    _originLable.textAlignment = NSTextAlignmentCenter;
    _originLable.textColor = [UIColor whiteColor];
    _originLable.font = [UIFont systemFontOfSize:12];
    _originLable.text = @"网页由 www.ccskill.com 提供";
    [_backgroundView addSubview:_originLable];

    UIView *view;
    if (NSClassFromString(@"WKWebView"))
        view = self.webWKView;
    else
        view = self.webView;

    [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self addSubview:view];
}

- (WKWebViewConfiguration *)configuration
{
    if (!_configuration) {
        _configuration = [[WKWebViewConfiguration alloc] init];
        _configuration.preferences = [[WKPreferences alloc] init];
        _configuration.preferences.minimumFontSize = 10;
        _configuration.preferences.javaScriptEnabled = YES;
        _configuration.preferences.javaScriptCanOpenWindowsAutomatically = NO;
        _configuration.processPool = [[WKProcessPool alloc] init];
        _configuration.userContentController = [[WKUserContentController alloc] init];
    }
    return _configuration;
}

- (WKWebView *)webWKView
{
    if (!_webWKView) {
        _webWKView = [[WKWebView alloc] initWithFrame:self.bounds configuration:self.configuration];
        _webWKView.UIDelegate = self;
        _webWKView.navigationDelegate = self;
        _webWKView.allowsBackForwardNavigationGestures = YES;
        _webWKView.scrollView.backgroundColor = [UIColor clearColor];

        [_webWKView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_webWKView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        [_webWKView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _webWKView;
}

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  初始化UIWebView
 *
 *  @return 返回UIWebView
 */
- (UIWebView *)webView
{
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:self.bounds];
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.opaque = NO;
        for (UIView *subview in [_webView.scrollView subviews]) {
            if ([subview isKindOfClass:[UIImageView class]]) {
                ((UIImageView *)subview).image = nil;
                subview.backgroundColor = [UIColor clearColor];
            }
        }

        _webViewProgress = [[CCWebViewProgress alloc] init];
        _webView.delegate = _webViewProgress;
        _webViewProgress.webViewProxyDelegate = self;
        _webViewProgress.progressDelegate = self;

        [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        self.webViewJSContext = [_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    }
    return _webView;
}

/**
 *  @author CC, 2015-10-19
 *
 *  @brief  初始化进度条
 *
 *  @return 返回进度条
 */
- (CCWebViewProgressView *)progressView
{
    if (!_progressView) {
        if (_webViewInitWithProgress) {
            CGFloat progressBarHeight = 2.f;
            CGRect navigaitonBarBounds = _webViewInitWithProgress.bounds;
            CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
            _progressView = [[CCWebViewProgressView alloc] initWithFrame:barFrame];
            _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
            [_webViewInitWithProgress addSubview:_progressView];
        }
    }
    return _progressView;
}

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  加载页面
 *
 *  @param baseURL 网页地址
 */
- (void)loadRequest:(NSString *)baseURL
{
    if ([baseURL rangeOfString:@"http://"].location == NSNotFound)
        baseURL = [NSString stringWithFormat:@"http://%@", baseURL];

    NSURL *url = [NSURL URLWithString:[baseURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    _originLable.text = [NSString stringWithFormat:@"网页由 %@ 提供", url.host];

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    if (NSClassFromString(@"WKWebView"))
        [self.webWKView loadRequest:request];
    else
        [self.webView loadRequest:request];
}

/**
 *  @author CC, 2016-01-25
 *
 *  @brief 加载HTML页面
 *
 *  @param string HTML文件或者字符串
 */
- (void)loadHTMLString:(NSString *)string
{
    _originLable.text = [NSString stringWithFormat:@"网页由 %@ 提供", AppName];
    if (NSClassFromString(@"WKWebView"))
        [self.webWKView loadHTMLString:string baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
    else
        [self.webView loadHTMLString:string baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
}

#pragma mark -
#pragma mark :. UIWebViewDelegate

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  观察
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        [self progressChanged:[change objectForKey:NSKeyValueChangeNewKey]];
    } else if ([keyPath isEqualToString:@"title"]) {
        _backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.8];
        if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:Title:)])
            [self.delegate webViewDidFinishLoad:self Title:change[NSKeyValueChangeNewKey]];
    }
}

#pragma mark - CCWebViewProgressDelegate
- (void)webViewProgress:(CCWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    _backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.8];
    if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:Title:)])
        [self.delegate webViewDidFinishLoad:self Title:[((UIWebView *)self.webView)stringByEvaluatingJavaScriptFromString:@"document.title"]];
}

/**
 *  @author CC, 2015-10-19
 *
 *  @brief  设置进度条
 *
 *  @param newValue 进度百分比
 */
- (void)progressChanged:(NSNumber *)newValue
{
    if (!self.progressView) return;

    self.progressView.progress = newValue.floatValue;
    if (self.progressView.progress == 1) {
        self.progressView.progress = 0;
        [UIView animateWithDuration:.02 animations:^{
            self.progressView.alpha = 0;
        }];
    } else if (self.progressView.alpha == 0) {
        [UIView animateWithDuration:.02 animations:^{
            self.progressView.alpha = 1;
        }];
    }
}

- (void)dealloc
{
    if (NSClassFromString(@"WKWebView")) {
        [self.webWKView removeObserver:self forKeyPath:@"estimatedProgress"];
        [self.webWKView removeObserver:self forKeyPath:@"title"];
    } else {
        [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
        [self.webView removeObserver:self forKeyPath:@"title"];
        [self.progressView removeFromSuperview];
    }
}

#pragma mark -
#pragma mark :. WKWebViewDelegate

// 创建新的webview
// 可以指定配置对象、导航动作对象、window特性
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    return webView;
}

// webview关闭时回调
- (void)webViewDidClose:(WKWebView *)webView
{
}

// 调用JS的alert()方法
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    completionHandler();
}

// 调用JS的confirm()方法
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
{
}

// 调用JS的prompt()方法
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *__nullable result))completionHandler
{
}

- (void)evaluateJavaScript:(NSString *)javaScriptString
         completionHandler:(void (^)(id, NSError *))completionHandler
{
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    self.responseBlock ? self.responseBlock(message.name, message.body) : nil;
}

#pragma mark -
#pragma mark :. JSBlock

- (void)didCapture:(NSString *)functionName ResponseBlock:(void (^)(NSString *functionName, id arguments))block
{
    if (NSClassFromString(@"WKWebView")) {
        self.responseBlock = block;
        [self.configuration.userContentController addScriptMessageHandler:self name:functionName];

    } else {
        self.webViewJSContext[functionName] = ^() {
            block?block(functionName,[JSContext currentArguments]):nil;
        };
    }
}

- (void)didCaptures:(NSArray<NSString *> *)functionNames ResponseBlock:(void (^)(NSString *functionName, id arguments))block
{
    for (NSString *fName in functionNames)
        [self didCapture:fName ResponseBlock:block];
}


@end
