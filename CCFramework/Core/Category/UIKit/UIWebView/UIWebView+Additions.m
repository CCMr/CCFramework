//
//  WebView+Additions.m
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

#import "UIWebView+Additions.h"
#import "UIColor+Additions.h"

@interface UIWebView () <UIGestureRecognizerDelegate, UIWebViewDelegate, UIAlertViewDelegate>

@end

@implementation UIWebView (Additions)

/**
 *  @brief  读取一个网页地址
 *
 *  @param URLString 网页地址
 */
- (void)loadURL:(NSString *)URLString
{
    NSString *encodedUrl = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)URLString, NULL, NULL, kCFStringEncodingUTF8);
    NSURL *url = [NSURL URLWithString:encodedUrl];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [self loadRequest:req];
}
/**
 *  @brief  读取bundle中的webview
 *
 *  @param htmlName webview名称
 */
- (void)loadLocalHtml:(NSString *)htmlName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:htmlName ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self loadRequest:request];
}
/**
 *  @brief  清空cookie
 */
- (void)clearCookies
{
    NSHTTPCookieStorage *storage = NSHTTPCookieStorage.sharedHTTPCookieStorage;
    
    for (NSHTTPCookie *cookie in storage.cookies)
        [storage deleteCookie:cookie];
    
    [NSUserDefaults.standardUserDefaults synchronize];
}

/**
 *  @brief  获取网页meta信息
 *
 *  @return meta信息
 */
- (NSArray *)obtainMetaData
{
    NSString *string = [self stringByEvaluatingJavaScriptFromString:@""
                        "var json = '[';                                    "
                        "var a = document.getElementsByTagName('meta');     "
                        "for(var i=0;i<a.length;i++){                       "
                        "   json += '{';                                    "
                        "   var b = a[i].attributes;                        "
                        "   for(var j=0;j<b.length;j++){                    "
                        "       var name = b[j].name;                       "
                        "       var value = b[j].value;                     "
                        "                                                   "
                        "       json += '\"'+name+'\":';                    "
                        "       json += '\"'+value+'\"';                    "
                        "       if(b.length>j+1){                           "
                        "           json += ',';                            "
                        "       }                                           "
                        "   }                                               "
                        "   json += '}';                                    "
                        "   if(a.length>i+1){                               "
                        "       json += ',';                                "
                        "   }                                               "
                        "}                                                  "
                        "json += ']';                                       "];
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    id array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    if (array == nil) NSLog(@"An error occured in meta parser.");
    return array;
}

/**
 *  @brief  是否显示阴影
 *
 *  @param b 是否显示阴影
 */
- (void)setShadowViewHidden:(BOOL)b
{
    for (UIView *aView in [self subviews]) {
        if ([aView isKindOfClass:[UIScrollView class]]) {
            [(UIScrollView *)aView setShowsHorizontalScrollIndicator:NO];
            for (UIView *shadowView in aView.subviews) {
                if ([shadowView isKindOfClass:[UIImageView class]]) {
                    shadowView.hidden = b; //上下滚动出边界时的黑色的图片 也就是拖拽后的上下阴影
                }
            }
        }
    }
}

/**
 *  @brief  是否显示水平滑动指示器
 *
 *  @param b 是否显示水平滑动指示器
 */
- (void)setShowsHorizontalScrollIndicator:(BOOL)b
{
    for (UIView *aView in [self subviews]) {
        if ([aView isKindOfClass:[UIScrollView class]]) {
            [(UIScrollView *)aView setShowsHorizontalScrollIndicator:b];
        }
    }
}

/**
 *  @brief  是否显示垂直滑动指示器
 *
 *  @param b 是否显示垂直滑动指示器
 */
- (void)setShowsVerticalScrollIndicator:(BOOL)b
{
    for (UIView *aView in [self subviews]) {
        if ([aView isKindOfClass:[UIScrollView class]]) {
            [(UIScrollView *)aView setShowsVerticalScrollIndicator:b];
        }
    }
}

/**
 *  @brief  网页透明
 */
- (void)makeTransparent
{
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
}

/**
 *  @brief  网页透明移除阴影
 */
- (void)makeTransparentAndRemoveShadow
{
    [self makeTransparent];
    [self setShadowViewHidden:YES];
}

- (void)useSwipeGesture
{
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [swipeRight setNumberOfTouchesRequired:2];
    [swipeRight setDelegate:self];
    [self addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeLeft setNumberOfTouchesRequired:2];
    [swipeLeft setDelegate:self];
    [self addGestureRecognizer:swipeLeft];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] init];
    [pan setMaximumNumberOfTouches:2];
    [pan setMinimumNumberOfTouches:2];
    [self addGestureRecognizer:pan];
    
    [pan requireGestureRecognizerToFail:swipeLeft];
    [pan requireGestureRecognizerToFail:swipeRight];
}

- (void)swipeRight:(UISwipeGestureRecognizer *)recognizer
{
    if ([recognizer numberOfTouches] == 2 && [self canGoBack]) [self goBack];
}

- (void)swipeLeft:(UISwipeGestureRecognizer *)recognizer
{
    if ([recognizer numberOfTouches] == 2 && [self canGoForward]) [self goForward];
}


#pragma mark -
#pragma mark :. JavaScriptAlert

static BOOL diagStat = NO;

- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame
{
    UIAlertView *dialogue = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [dialogue show];
}

- (BOOL)webView:(UIWebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame
{
    UIAlertView *dialogue = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Okay", @"Okay") otherButtonTitles:NSLocalizedString(@"Cancel", @"Cancel"), nil];
    [dialogue show];
    while (dialogue.hidden == NO && dialogue.superview != nil) {
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01f]];
    }
    
    return diagStat;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        diagStat = YES;
    } else if (buttonIndex == 1) {
        diagStat = NO;
    }
}


#pragma mark -
#pragma mark :. Block

static void (^__loadedBlock)(UIWebView *webView);
static void (^__failureBlock)(UIWebView *webView, NSError *error);
static void (^__loadStartedBlock)(UIWebView *webView);
static BOOL (^__shouldLoadBlock)(UIWebView *webView, NSURLRequest *request, UIWebViewNavigationType navigationType);

static uint __loadedWebItems;

+ (UIWebView *)loadRequest:(NSURLRequest *)request
                    loaded:(void (^)(UIWebView *webView))loadedBlock
                    failed:(void (^)(UIWebView *webView, NSError *error))failureBlock
{
    
    return [self loadRequest:request loaded:loadedBlock failed:failureBlock loadStarted:nil shouldLoad:nil];
}

+ (UIWebView *)loadHTMLString:(NSString *)htmlString
                       loaded:(void (^)(UIWebView *webView))loadedBlock
                       failed:(void (^)(UIWebView *webView, NSError *error))failureBlock
{
    
    return [self loadHTMLString:htmlString loaded:loadedBlock failed:failureBlock loadStarted:nil shouldLoad:nil];
}

+ (UIWebView *)loadHTMLString:(NSString *)htmlString
                       loaded:(void (^)(UIWebView *))loadedBlock
                       failed:(void (^)(UIWebView *, NSError *))failureBlock
                  loadStarted:(void (^)(UIWebView *webView))loadStartedBlock
                   shouldLoad:(BOOL (^)(UIWebView *webView, NSURLRequest *request, UIWebViewNavigationType navigationType))shouldLoadBlock
{
    __loadedWebItems = 0;
    __loadedBlock = loadedBlock;
    __failureBlock = failureBlock;
    __loadStartedBlock = loadStartedBlock;
    __shouldLoadBlock = shouldLoadBlock;
    
    UIWebView *webView = [[UIWebView alloc] init];
    webView.delegate = (id)[self class];
    [webView loadHTMLString:htmlString baseURL:nil];
    
    return webView;
}

+ (UIWebView *)loadRequest:(NSURLRequest *)request
                    loaded:(void (^)(UIWebView *webView))loadedBlock
                    failed:(void (^)(UIWebView *webView, NSError *error))failureBlock
               loadStarted:(void (^)(UIWebView *webView))loadStartedBlock
                shouldLoad:(BOOL (^)(UIWebView *webView, NSURLRequest *request, UIWebViewNavigationType navigationType))shouldLoadBlock
{
    __loadedWebItems = 0;
    
    __loadedBlock = loadedBlock;
    __failureBlock = failureBlock;
    __loadStartedBlock = loadStartedBlock;
    __shouldLoadBlock = shouldLoadBlock;
    
    UIWebView *webView = [[UIWebView alloc] init];
    webView.delegate = (id)[self class];
    
    [webView loadRequest:request];
    
    return webView;
}

#pragma mark--- Private Static delegate
+ (void)webViewDidFinishLoad:(UIWebView *)webView
{
    __loadedWebItems--;
    
    if (__loadedBlock && (!TRUE_END_REPORT || __loadedWebItems == 0)) {
        __loadedWebItems = 0;
        __loadedBlock(webView);
    }
}

+ (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    __loadedWebItems--;
    
    if (__failureBlock)
        __failureBlock(webView, error);
}

+ (void)webViewDidStartLoad:(UIWebView *)webView
{
    __loadedWebItems++;
    
    if (__loadStartedBlock && (!TRUE_END_REPORT || __loadedWebItems > 0))
        __loadStartedBlock(webView);
}

+ (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (__shouldLoadBlock)
        return __shouldLoadBlock(webView, request, navigationType);
    
    return YES;
}


#pragma mark -
#pragma mark :. Canvas

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 创建一个指定大小的透明画布
 *
 *  @param canvasId 画布ID
 *  @param width    宽
 *  @param height   高
 */
- (void)createCanvas:(NSString *)canvasId
               width:(NSInteger)width
              height:(NSInteger)height
{
    NSString *jsString = [NSString stringWithFormat:
                          @"var canvas = document.createElement('canvas');"
                          "canvas.id = %@; canvas.width = %ld; canvas.height = %ld;"
                          "document.body.appendChild(canvas);"
                          "var g = canvas.getContext('2d');"
                          "g.strokeRect(%ld,%ld,%ld,%ld);",
                          canvasId, (long)width, (long)height, 0L, 0L, (long)width, (long)height];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 在指定位置创建一个指定大小的透明画布
 *
 *  @param canvasId 画布ID
 *  @param width    宽
 *  @param height   高
 *  @param x        左边距离
 *  @param y        顶部距离
 */
- (void)createCanvas:(NSString *)canvasId
               width:(NSInteger)width
              height:(NSInteger)height
                   x:(NSInteger)x
                   y:(NSInteger)y
{
    //[self createCanvas:canvasId width:width height:height];
    NSString *jsString = [NSString stringWithFormat:
                          @"var canvas = document.createElement('canvas');"
                          "canvas.id = %@; canvas.width = %ld; canvas.height = %ld;"
                          "canvas.style.position = 'absolute';"
                          "canvas.style.top = '%ld';"
                          "canvas.style.left = '%ld';"
                          "document.body.appendChild(canvas);"
                          "var g = canvas.getContext('2d');"
                          "g.strokeRect(%ld,%ld,%ld,%ld);",
                          canvasId, (long)width, (long)height, (long)y, (long)x, 0L, 0L, (long)width, (long)height];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 绘制矩形填充 context.fillRect(x,y,width,height)
 *
 *  @param canvasId 画布ID
 *  @param x        左边距离
 *  @param y        顶部距离
 *  @param width    宽
 *  @param height   高
 *  @param color    背景颜色
 */
- (void)fillRectOnCanvas:(NSString *)canvasId
                       x:(NSInteger)x
                       y:(NSInteger)y
                   width:(NSInteger)width
                  height:(NSInteger)height
                 uicolor:(UIColor *)color
{
    NSString *jsString = [NSString stringWithFormat:
                          @"var canvas = document.getElementById('%@');"
                          "var context = canvas.getContext('2d');"
                          "context.fillStyle = '%@';"
                          "context.fillRect(%ld,%ld,%ld,%ld);",
                          canvasId, [color canvasColorString], (long)x, (long)y, (long)width, (long)height];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 绘制矩形边框 strokeRect(x,y,width,height)
 *
 *  @param canvasId  画布ID
 *  @param x         左边距离
 *  @param y         顶部距离
 *  @param width     宽
 *  @param height    高
 *  @param color     背景颜色
 *  @param lineWidth 线宽
 */
- (void)strokeRectOnCanvas:(NSString *)canvasId x:(NSInteger)x y:(NSInteger)y width:(NSInteger)width height:(NSInteger)height uicolor:(UIColor *)color lineWidth:(NSInteger)lineWidth
{
    NSString *jsString = [NSString stringWithFormat:
                          @"var canvas = document.getElementById('%@');"
                          "var context = canvas.getContext('2d');"
                          "context.strokeStyle = '%@';"
                          "context.lineWidth = '%ld';"
                          "context.strokeRect(%ld,%ld,%ld,%ld);",
                          canvasId, [color canvasColorString], (long)lineWidth, (long)x, (long)y, (long)width, (long)height];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 清除矩形区域 context.clearRect(x,y,width,height)
 *
 *  @param canvasId 画布ID
 *  @param x        左边距离
 *  @param y        顶部距离
 *  @param width    宽
 *  @param height   高
 */
- (void)clearRectOnCanvas:(NSString *)canvasId
                        x:(NSInteger)x
                        y:(NSInteger)y
                    width:(NSInteger)width
                   height:(NSInteger)height
{
    NSString *jsString = [NSString stringWithFormat:
                          @"var canvas = document.getElementById('%@');"
                          "var context = canvas.getContext('2d');"
                          "context.clearRect(%ld,%ld,%ld,%ld);",
                          canvasId, (long)x, (long)y, (long)width, (long)height];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 绘制圆弧填充 context.arc(x, y, radius, starAngle,endAngle, anticlockwise)
 *
 *  @param canvasId      画布ID
 *  @param x             左边距离
 *  @param y             顶部距离
 *  @param r             圆角值
 *  @param startAngle    起始角
 *  @param endAngle      结束角
 *  @param anticlockwise 逆时针
 *  @param color         背景颜色
 */
- (void)arcOnCanvas:(NSString *)canvasId
            centerX:(NSInteger)x
            centerY:(NSInteger)y
             radius:(NSInteger)r
         startAngle:(float)startAngle
           endAngle:(float)endAngle
      anticlockwise:(BOOL)anticlockwise
            uicolor:(UIColor *)color
{
    NSString *jsString = [NSString stringWithFormat:
                          @"var canvas = document.getElementById('%@');"
                          "var context = canvas.getContext('2d');"
                          "context.beginPath();"
                          "context.arc(%ld,%ld,%ld,%f,%f,%@);"
                          "context.closePath();"
                          "context.fillStyle = '%@';"
                          "context.fill();",
                          canvasId, (long)x, (long)y, (long)r, startAngle, endAngle, anticlockwise ? @"true" : @"false", [color canvasColorString]];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 绘制一条线段 context.moveTo(x,y) context.lineTo(x,y)
 *
 *  @param canvasId  画布ID
 *  @param x1        开始左边距离
 *  @param y1        开始顶部距离
 *  @param x2        结束左边距离
 *  @param y2        结束顶部距离
 *  @param color     颜色
 *  @param lineWidth 线宽
 */
- (void)lineOnCanvas:(NSString *)canvasId
                  x1:(NSInteger)x1
                  y1:(NSInteger)y1
                  x2:(NSInteger)x2
                  y2:(NSInteger)y2
             uicolor:(UIColor *)color
           lineWidth:(NSInteger)lineWidth
{
    NSString *jsString = [NSString stringWithFormat:
                          @"var canvas = document.getElementById('%@');"
                          "var context = canvas.getContext('2d');"
                          "context.beginPath();"
                          "context.moveTo(%ld,%ld);"
                          "context.lineTo(%ld,%ld);"
                          "context.closePath();"
                          "context.strokeStyle = '%@';"
                          "context.lineWidth = %ld;"
                          "context.stroke();",
                          canvasId, (long)x1, (long)y1, (long)x2, (long)y2, [color canvasColorString], (long)lineWidth];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 绘制一条折线
 *
 *  @param canvasId  画布ID
 *  @param points    曲线数据值
 *  @param color     颜色
 *  @param lineWidth 线宽
 */
- (void)linesOnCanvas:(NSString *)canvasId
               points:(NSArray *)points
             unicolor:(UIColor *)color
            lineWidth:(NSInteger)lineWidth
{
    NSString *jsString = [NSString stringWithFormat:
                          @"var canvas = document.getElementById('%@');"
                          "var context = canvas.getContext('2d');"
                          "context.beginPath();",
                          canvasId];
    for (int i = 0; i < [points count] / 2; i++) {
        jsString = [jsString stringByAppendingFormat:@"context.lineTo(%@,%@);",
                    points[i * 2], points[i * 2 + 1]];
    }
    jsString = [jsString stringByAppendingFormat:@""
                "context.strokeStyle = '%@';"
                "context.lineWidth = %ld;"
                "context.stroke();",
                [color canvasColorString], (long)lineWidth];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 绘制贝塞尔曲线 context.bezierCurveTo(cp1x,cp1y,cp2x,cp2y,x,y)
 *
 *  @param canvasId  画布ID
 *  @param x1        开始左边距离
 *  @param y1        开始顶部距离
 *  @param cp1x      曲线第一个点左边距离
 *  @param cp1y      曲线第一个点顶部距离
 *  @param cp2x      曲线第二个点左边距离
 *  @param cp2y      曲线第er个点顶部距离
 *  @param x2        结束左边距离
 *  @param y2        结束顶部距离
 *  @param color     颜色
 *  @param lineWidth 线宽
 */
- (void)bezierCurveOnCanvas:(NSString *)canvasId
                         x1:(NSInteger)x1
                         y1:(NSInteger)y1
                       cp1x:(NSInteger)cp1x
                       cp1y:(NSInteger)cp1y
                       cp2x:(NSInteger)cp2x
                       cp2y:(NSInteger)cp2y
                         x2:(NSInteger)x2
                         y2:(NSInteger)y2
                   unicolor:(UIColor *)color
                  lineWidth:(NSInteger)lineWidth
{
    NSString *jsString = [NSString stringWithFormat:
                          @"var canvas = document.getElementById('%@');"
                          "var context = canvas.getContext('2d');"
                          "context.beginPath();"
                          "context.moveTo(%ld,%ld);"
                          "context.bezierCurveTo(%ld,%ld,%ld,%ld,%ld,%ld);"
                          "context.strokeStyle = '%@';"
                          "context.lineWidth = %ld;"
                          "context.stroke();",
                          canvasId, (long)x1, (long)y1, (long)cp1x, (long)cp1y, (long)cp2x, (long)cp2y, (long)x2, (long)y2, [color canvasColorString], (long)lineWidth];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 显示图像的一部分 context.drawImage(image,sx,sy,sw,sh,dx,dy,dw,dh)
 *
 *  @param src      规定要使用的图像、画布或视频。
 *  @param canvasId 画布ID
 *  @param sx       可选。开始剪切的 x 坐标位置。
 *  @param sy       可选。开始剪切的 y 坐标位置。
 *  @param sw       可选。被剪切图像的宽度。
 *  @param sh       可选。被剪切图像的高度。
 *  @param dx       在画布上放置图像的 x 坐标位置。
 *  @param dy       在画布上放置图像的 y 坐标位置。
 *  @param dw       可选。要使用的图像的宽度。（伸展或缩小图像）
 *  @param dh       可选。要使用的图像的高度。（伸展或缩小图像）
 */
- (void)drawImage:(NSString *)src
         onCanvas:(NSString *)canvasId
               sx:(NSInteger)sx
               sy:(NSInteger)sy
               sw:(NSInteger)sw
               sh:(NSInteger)sh
               dx:(NSInteger)dx
               dy:(NSInteger)dy
               dw:(NSInteger)dw
               dh:(NSInteger)dh
{
    NSString *jsString = [NSString stringWithFormat:
                          @"var image = new Image();"
                          "image.src = '%@';"
                          "var canvas = document.getElementById('%@');"
                          "var context = canvas.getContext('2d');"
                          "context.drawImage(image,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld)",
                          src, canvasId, (long)sx, (long)sy, (long)sw, (long)sh, (long)dx, (long)dy, (long)dw, (long)dh];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}


#pragma mark -
#pragma mark :. JavaScript
#pragma mark--- 获取网页中的数据

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 获取某个标签的结点个数
 *
 *  @param tag tag
 */
- (int)nodeCountOfTag:(NSString *)tag
{
    NSString *jsString = [NSString stringWithFormat:@"document.getElementsByTagName('%@').length", tag];
    int len = [[self stringByEvaluatingJavaScriptFromString:jsString] intValue];
    return len;
}

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 获取当前页面URL
 */
- (NSString *)getCurrentURL
{
    return [self stringByEvaluatingJavaScriptFromString:@"document.location.href"];
}

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 获取标题
 */
- (NSString *)getTitle
{
    return [self stringByEvaluatingJavaScriptFromString:@"document.title"];
}

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 获取所有图片链接
 */
- (NSArray *)getImgs
{
    NSMutableArray *arrImgURL = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self nodeCountOfTag:@"img"]; i++) {
        NSString *jsString = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].src", i];
        [arrImgURL addObject:[self stringByEvaluatingJavaScriptFromString:jsString]];
    }
    return arrImgURL;
}

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 获取当前页面所有点击链接
 */
- (NSArray *)getOnClicks
{
    NSMutableArray *arrOnClicks = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self nodeCountOfTag:@"a"]; i++) {
        NSString *jsString = [NSString stringWithFormat:@"document.getElementsByTagName('a')[%d].getAttribute('onclick')", i];
        NSString *clickString = [self stringByEvaluatingJavaScriptFromString:jsString];
        NSLog(@"%@", clickString);
        [arrOnClicks addObject:clickString];
    }
    return arrOnClicks;
}

#pragma mark--- 改变网页样式和行为

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 改变背景颜色
 *
 *  @param color 颜色
 */
- (void)setBackgroundColor:(UIColor *)color
{
    NSString *jsString = [NSString stringWithFormat:@"document.body.style.backgroundColor = '%@'", [color webColorString]];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 为所有图片添加点击事件(网页中有些图片添加无效,需要协议方法配合截取)
 */
- (void)addClickEventOnImg
{
    for (int i = 0; i < [self nodeCountOfTag:@"img"]; i++) {
        //利用重定向获取img.src，为区分，给url添加'img:'前缀
        NSString *jsString = [NSString stringWithFormat:
                              @"document.getElementsByTagName('img')[%d].onclick = \
                              function() { document.location.href = 'img' + this.src; }",
                              i];
        [self stringByEvaluatingJavaScriptFromString:jsString];
    }
}

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 改变所有图像的宽度
 *
 *  @param size 数值
 */
- (void)setImgWidth:(int)size
{
    for (int i = 0; i < [self nodeCountOfTag:@"img"]; i++) {
        NSString *jsString = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].width = '%d'", i, size];
        [self stringByEvaluatingJavaScriptFromString:jsString];
        jsString = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].style.width = '%dpx'", i, size];
        [self stringByEvaluatingJavaScriptFromString:jsString];
    }
}

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 改变所有图像的高度
 *
 *  @param size 数值
 */
- (void)setImgHeight:(int)size
{
    for (int i = 0; i < [self nodeCountOfTag:@"img"]; i++) {
        NSString *jsString = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].height = '%d'", i, size];
        [self stringByEvaluatingJavaScriptFromString:jsString];
        jsString = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].style.height = '%dpx'", i, size];
        [self stringByEvaluatingJavaScriptFromString:jsString];
    }
}

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 改变指定标签的字体颜色
 *
 *  @param color   颜色
 *  @param tagName tag名字
 */
- (void)setFontColor:(UIColor *)color withTag:(NSString *)tagName
{
    NSString *jsString = [NSString stringWithFormat:
                          @"var nodes = document.getElementsByTagName('%@'); \
                          for(var i=0;i<nodes.length;i++){\
                          nodes[i].style.color = '%@';}",
                          tagName, [color webColorString]];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 改变指定标签的字体大小
 *
 *  @param size    数值
 *  @param tagName tag名字
 */
- (void)setFontSize:(int)size withTag:(NSString *)tagName
{
    NSString *jsString = [NSString stringWithFormat:
                          @"var nodes = document.getElementsByTagName('%@'); \
                          for(var i=0;i<nodes.length;i++){\
                          nodes[i].style.fontSize = '%dpx';}",
                          tagName, size];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}

@end
