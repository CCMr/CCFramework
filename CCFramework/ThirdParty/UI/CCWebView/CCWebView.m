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


@interface CCWebView ()<WKNavigationDelegate,WKUIDelegate,CCWebViewProgressDelegate,CCWebViewProgressDelegate,UIWebViewDelegate>

@property (nonatomic, strong) UIView *webView;

@property (nonatomic, strong) UILabel *originLable;

@property (nonatomic, strong) CCWebViewProgress *webViewProgress;

@property (nonatomic, strong) CCWebViewProgressView *progressView;

@end

@implementation CCWebView

-(instancetype)init
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

-(void)initView
{
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    backgroundView.backgroundColor = [UIColor colorWithRed:34/255.f green:37/255.f blue:36/255.f alpha:0.9];
    [self addSubview:backgroundView];

    _originLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(self.bounds), 20)];
    _originLable.backgroundColor = [UIColor clearColor];
    _originLable.textAlignment = NSTextAlignmentCenter;
    _originLable.textColor = [UIColor whiteColor];
    _originLable.font = [UIFont systemFontOfSize:12];
    _originLable.text = @"网页由 mp.kurrent.cn 提供";
    [backgroundView addSubview:_originLable];

    if (NSClassFromString(@"WKWebView"))
        self.webView = [self InitWKWebView];
     else
        self.webView = [self InitWebView];

    [self.webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self addSubview:self.webView];
}

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  初始化WKWebView
 *
 *  @return 返回WKWebView
 */
-(WKWebView *)InitWKWebView
{
    WKWebViewConfiguration* configuration = [[NSClassFromString(@"WKWebViewConfiguration") alloc] init];
    configuration.preferences = [NSClassFromString(@"WKPreferences") new];
    configuration.userContentController = [NSClassFromString(@"WKUserContentController") new];

    WKWebView *webView = [[NSClassFromString(@"WKWebView") alloc] initWithFrame:self.bounds configuration:configuration];
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    webView.allowsBackForwardNavigationGestures = YES;
    webView.scrollView.backgroundColor = [UIColor clearColor];

    [webView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];

    return webView;
}

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  初始化UIWebView
 *
 *  @return 返回UIWebView
 */
- (UIWebView *)InitWebView
{
    UIWebView* webView = [[UIWebView alloc] initWithFrame:self.bounds];
    webView.backgroundColor = [UIColor whiteColor];
    webView.opaque = NO;
    for (UIView *subview in [webView.scrollView subviews])
    {
        if ([subview isKindOfClass:[UIImageView class]])
        {
            ((UIImageView *) subview).image = nil;
            subview.backgroundColor = [UIColor clearColor];
        }
    }

    _webViewProgress = [[CCWebViewProgress alloc] init];
    webView.delegate = _webViewProgress;
    _webViewProgress.webViewProxyDelegate = self;
    _webViewProgress.progressDelegate = self;

    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];

    return webView;
}

/**
 *  @author CC, 2015-10-19
 *
 *  @brief  初始化进度条
 *
 *  @return 返回进度条
 */
-(CCWebViewProgressView *)progressView
{
    if (!_progressView) {
        if ([self.delegate respondsToSelector:@selector(webViewInitWithProgress)]) {
            UINavigationBar *navigationBar = [self.delegate webViewInitWithProgress];
            if (navigationBar) {
                CGFloat progressBarHeight = 2.f;
                CGRect navigaitonBarBounds = navigationBar.bounds;
                CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
                _progressView = [[CCWebViewProgressView alloc] initWithFrame:barFrame];
                _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
                [navigationBar addSubview:_progressView];
            }
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
- (void)loadRequest: (NSString *)baseURL
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[baseURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    if ([self.webView isKindOfClass:[UIWebView class]])
        [((UIWebView *)self.webView) loadRequest:request];
    else
       [((WKWebView *)self.webView) loadRequest:request];
}

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  观察
 *
 *  @param keyPath <#keyPath description#>
 *  @param object  <#object description#>
 *  @param change  <#change description#>
 *  @param context <#context description#>
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"estimatedProgress"]) {
         [self progressChanged:[change objectForKey:NSKeyValueChangeNewKey]];
    }else if([keyPath isEqualToString:@"title"]) {
        if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:Title:)])
            [self.delegate webViewDidFinishLoad:self Title:change[NSKeyValueChangeNewKey]];
    }
}

#pragma mark - CCWebViewProgressDelegate
-(void)webViewProgress:(CCWebViewProgress *)webViewProgress updateProgress:(float)progress{
    [_progressView setProgress:progress animated:YES];
    if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:Title:)])
        [self.delegate webViewDidFinishLoad:self Title:[((UIWebView *)self.webView) stringByEvaluatingJavaScriptFromString:@"document.title"]];
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

-(void)dealloc
{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
    [self.progressView removeFromSuperview];
}

@end
