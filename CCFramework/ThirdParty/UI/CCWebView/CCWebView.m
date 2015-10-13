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

@interface CCWebView ()<WKNavigationDelegate,WKUIDelegate>

@property (nonatomic, strong) UIView *webView;

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
    webView.backgroundColor = [UIColor whiteColor];
    webView.opaque = NO;

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
    CCWebViewProgress *webViewProgress = [[CCWebViewProgress alloc] init];
    webViewProgress.webViewProxyDelegate = webView.delegate;


    return webView;
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
        if ([self.delegate respondsToSelector:@selector(webViewProgress:updateProgress:)])
            [self.delegate webViewProgress:self updateProgress:[change[NSKeyValueChangeNewKey] floatValue]];
    }
    else if([keyPath isEqualToString:@"title"]) {
        if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:Title:)])
            [self.delegate webViewDidFinishLoad:self Title:change[NSKeyValueChangeNewKey]];
    }
}

-(void)dealloc
{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
}

@end
