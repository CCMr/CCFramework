//
//  CCWebViewController.m
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

#import "CCWebViewController.h"
#import <WebKit/WebKit.h>
#import "CCWebViewProgress.h"
#import "CCWebViewProgressView.h"
#import "config.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "UIViewController+Additions.h"

typedef void (^ResponseBlock)(NSString *functionName, NSArray *arguments);

@interface CCWebViewController () <WKNavigationDelegate, WKUIDelegate, CCWebViewProgressDelegate, CCWebViewProgressDelegate, UIWebViewDelegate>

@property(nonatomic, strong) JSContext *webViewJSContext;

@property(nonatomic, strong) WKWebViewConfiguration *configuration;

@property(nonatomic, strong) UIWebView *webView;

@property(nonatomic, strong) WKWebView *webWKView;

@property(nonatomic, strong) UILabel *originLable;

@property(nonatomic, strong) UIView *backgroundView;

@property(nonatomic, strong) CCWebViewProgress *webViewProgress;

@property(nonatomic, strong) CCWebViewProgressView *progressView;

@property(nonatomic, copy) ResponseBlock responseBlock;

@property(nonatomic, copy) NSString *htmlString;

@property(nonatomic, copy) NSString *urlString;

@end

@implementation CCWebViewController

-(instancetype)init
{
    if (self = [super init]) {
        _isTitleFollowChange = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    
    [self initControl];
}

- (void)initControl
{
    [self.view addSubview:self.backgroundView];
    UIView *view;
    if (NSClassFromString(@"WKWebView"))
        view = self.webWKView;
    else
        view = self.webView;
    
    if (self.urlString)
        [self loadRequest];
    else if (self.htmlString)
        [self loadHTMLString];
    
    [self.view addSubview:view];
    
    typeof(self) __weak weakSelf = self;
    [self backButtonTouched:^(UIViewController *vc) {
        if (NSClassFromString(@"WKWebView")){
            if (weakSelf.webWKView.backForwardList.backList.count > 0) {
                [weakSelf.webWKView goBack];
            }else{
                [vc.navigationController popViewControllerAnimated:YES];
            }
        }else{
            if (weakSelf.webView.canGoBack) {
                [weakSelf.webView goBack];
            }else{
                [vc.navigationController popViewControllerAnimated:YES];
            }
        }
    }];
}

- (void)loadRequest
{
    NSURL *url = [NSURL URLWithString:[self.urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    self.originLable.text = [NSString stringWithFormat:@"网页由 %@ 提供", url.host];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    if (NSClassFromString(@"WKWebView"))
        [self.webWKView loadRequest:request];
    else
        [self.webView loadRequest:request];
}

- (void)loadHTMLString
{
    self.originLable.text = [NSString stringWithFormat:@"网页由 %@ 提供", AppName];
    if (NSClassFromString(@"WKWebView"))
        [self.webWKView loadHTMLString:self.htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
    else
        [self.webView loadHTMLString:self.htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
}

- (BOOL)isGoBack
{
    BOOL isBack = NO;
    if (NSClassFromString(@"WKWebView")) {
        if (self.webWKView.backForwardList.backList.count > 0)
            isBack = YES;
    } else {
        if (self.webView.canGoBack)
            isBack = YES;
    }
    return isBack;
}

- (BOOL)isGoForward
{
    BOOL isForward = NO;
    if (NSClassFromString(@"WKWebView")) {
        if (self.webWKView.backForwardList.forwardList.count > 0)
            isForward = YES;
    } else {
        if (self.webView.canGoForward)
            isForward = YES;
    }
    return isForward;
}

- (void)goBack
{
    if (NSClassFromString(@"WKWebView"))
        [self.webWKView goBack];
    else
        [self.webView goBack];
}

- (void)goForward
{
    if (NSClassFromString(@"WKWebView"))
        [self.webWKView goForward];
    else
        [self.webView goForward];
}

#pragma mark -
#pragma mark :. JSBlock

- (void)didCapture:(NSString *)functionName
     ResponseBlock:(void (^)(NSString *functionName, id arguments))block
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

- (void)didCaptures:(NSArray<NSString *> *)functionNames
      ResponseBlock:(void (^)(NSString *functionName, id arguments))block
{
    for (NSString *fName in functionNames)
        [self didCapture:fName ResponseBlock:block];
}

#pragma mark -
#pragma mark :. OCTransferJs
- (void)evaluateJavaScript:(NSString *)javaScriptString
         completionHandler:(void (^)(id response, NSError *error))completionHandler
{
    if (NSClassFromString(@"WKWebView")) {
        
        [self.webWKView evaluateJavaScript:javaScriptString completionHandler:^(id _Nullable response, NSError *_Nullable error) {
            completionHandler?completionHandler(response,error):nil;
        }];
    }
}

#pragma mark -
#pragma mark :. getset

- (UILabel *)originLable
{
    if (!_originLable) {
        
        _originLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(self.view.bounds), 20)];
        _originLable.backgroundColor = [UIColor clearColor];
        _originLable.textAlignment = NSTextAlignmentCenter;
        _originLable.textColor = [UIColor lightGrayColor];
        _originLable.font = [UIFont systemFontOfSize:12];
        _originLable.text = @"网页由 www.ccskill.com 提供";
    }
    return _originLable;
}

- (UIView *)backgroundView
{
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
        [_backgroundView addSubview:self.originLable];
    }
    return _backgroundView;
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
        _webWKView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:self.configuration];
        _webWKView.backgroundColor = [UIColor whiteColor];
        _webWKView.opaque = NO;
        _webWKView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
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
        _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
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
        CGFloat progressBarHeight = 2.f;
        CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
        CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
        _progressView = [[CCWebViewProgressView alloc] initWithFrame:barFrame];
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self.navigationController.navigationBar addSubview:_progressView];
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
    _urlString = baseURL;
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
    _htmlString = string;
}

#pragma mark -
#pragma mark :.

- (void)jumpPage:(NSString *)baseURL
{
    if ([baseURL rangeOfString:@"http://"].location == NSNotFound)
        baseURL = [NSString stringWithFormat:@"http://%@", baseURL];
    
    NSURL *url = [NSURL URLWithString:[baseURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    self.originLable.text = [NSString stringWithFormat:@"网页由 %@ 提供", url.host];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    if (NSClassFromString(@"WKWebView"))
        [self.webWKView loadRequest:request];
    else
        [self.webView loadRequest:request];
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
        
        if (self.isTitleFollowChange) {
            NSString *changeTitle = change[NSKeyValueChangeNewKey];
            if (![self.title isEqualToString:changeTitle]) {
                self.title = changeTitle;
                [self observeTitle:self.title];
            }
        }
    }
}

#pragma mark - CCWebViewProgressDelegate
- (void)webViewProgress:(CCWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    _backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.8];
    if (self.isTitleFollowChange) {
        NSString *changeTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        if (![self.title isEqualToString:changeTitle]) {
            self.title = changeTitle;
            [self observeTitle:self.title];
        }
    }
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
    if (newValue.floatValue == 1) {
        self.progressView.progress = 0;
        self.webWKView.backgroundColor = [UIColor clearColor];
        [UIView animateWithDuration:.02 animations:^{
            self.progressView.alpha = 0;
        }];
    } else if (self.progressView.alpha == 0) {
        [UIView animateWithDuration:.02 animations:^{
            self.progressView.alpha = 1;
        }];
    }
}

- (void)observeTitle:(NSString *)title
{
}

#pragma mark -
#pragma mark :. WKWebViewDelegate

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
}

// 创建新的webview
// 可以指定配置对象、导航动作对象、window特性
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    return webView;
}

// webview关闭时回调
- (void)webViewDidClose:(WKWebView *)webView {}

// 调用JS的alert()方法
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    completionHandler();
}

// 调用JS的confirm()方法
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {}

// 调用JS的prompt()方法
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *__nullable result))completionHandler {}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    self.responseBlock ? self.responseBlock(message.name, message.body) : nil;
}

- (void)dealloc
{
    if (NSClassFromString(@"WKWebView")) {
        _webWKView.UIDelegate = nil;
        _webWKView.navigationDelegate = nil;
        [_webWKView removeObserver:self forKeyPath:@"estimatedProgress"];
        [_webWKView removeObserver:self forKeyPath:@"title"];
    } else {
        [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
        [_webView removeObserver:self forKeyPath:@"title"];
    }
    [_progressView removeFromSuperview];
}

@end
