//
//  WebView+Additions.h
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

@interface UIWebView (Additions)

/**
 *  @brief  读取一个网页地址
 *
 *  @param URLString 网页地址
 */
- (void)loadURL:(NSString *)URLString;
/**
 *  @brief  读取bundle中的webview
 *
 *  @param htmlName webview名称
 */
- (void)loadLocalHtml:(NSString *)htmlName;
/**
 *  @brief  清空cookie
 */
- (void)clearCookies;

/**
 *  @brief  获取网页meta信息
 *
 *  @return meta信息
 */
- (NSArray *)obtainMetaData;

/**
 *  @brief  是否显示阴影
 *
 *  @param b 是否显示阴影
 */
- (void)setShadowViewHidden:(BOOL)b;

/**
 *  @brief  是否显示水平滑动指示器
 *
 *  @param b 是否显示水平滑动指示器
 */
- (void)setShowsHorizontalScrollIndicator:(BOOL)b;

/**
 *  @brief  是否显示垂直滑动指示器
 *
 *  @param b 是否显示垂直滑动指示器
 */
- (void)setShowsVerticalScrollIndicator:(BOOL)b;


/**
 *  @brief  网页透明
 */
- (void)makeTransparent;

/**
 *  @brief  网页透明移除+阴影
 */
- (void)makeTransparentAndRemoveShadow;

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 滑动手势
 */
- (void)useSwipeGesture;

#pragma mark -
#pragma mark :. JavaScriptAlert

- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame;

- (BOOL)webView:(UIWebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame;

#pragma mark -
#pragma mark :. Block

/**
 Set TRUE_END_REPORT to YES to get notified only when the page has *fully* loaded, and not when every single element loads. (still not fully tested). When this is set to NO, it will work exactly like the UIWebViewDelegate. (Default behavior)
 */
#define TRUE_END_REPORT NO

/**
 Load a request and get notified when a web page is loaded successfully or fails to load
 
 @param request NSURLRequest to load
 @param loadedBlock Callback block called when loading is done
 @param failureBlock Callback block called when loading
 
 @return The generated UIWebView
 */
+ (UIWebView *)loadRequest:(NSURLRequest *)request
                    loaded:(void (^)(UIWebView *webView))loadedBlock
                    failed:(void (^)(UIWebView *webView, NSError *error))failureBlock;

/**
 Load a request and get notified when a web page is loaded successfully, fails to load, or started to load. Also, set whether or not a certain page should be loaded.
 
 @param request NSURLRequest to load
 @param loadedBlock Callback block called when loading is done
 @param failureBlock Callback block called when loading
 @param loadStartedBlock Callback block called when loading started
 @param shouldLoadBlock Callback block determining whether or not a specific page should be loaded.
 
 @return The generated UIWebView
 */
+ (UIWebView *)loadRequest:(NSURLRequest *)request
                    loaded:(void (^)(UIWebView *webView))loadedBlock
                    failed:(void (^)(UIWebView *webView, NSError *error))failureBlock
               loadStarted:(void (^)(UIWebView *webView))loadStartedBlock
                shouldLoad:(BOOL (^)(UIWebView *webView, NSURLRequest *request, UIWebViewNavigationType navigationType))shouldLoadBlock;

/**
 Load a HTML string and get notified when the web page is loaded successfully or failed to load.
 
 @param htmlString NSString containing HTML which should be loaded
 @param loadedBlock Callback block called when loading is done
 @param failureBlock Callback block called when loading
 
 @return The generated UIWebView
 */
+ (UIWebView *)loadHTMLString:(NSString *)htmlString
                       loaded:(void (^)(UIWebView *webView))loadedBlock
                       failed:(void (^)(UIWebView *webView, NSError *error))failureBlock;

/**
 Load a HTML string and get notified when the web page is loaded successfully, failed to load or started to load.
 Also set whether or not a certain page should be loaded.
 
 @param htmlString NSString containing HTML which should be loaded.
 @param loadedBlock Callback block called when loading is done
 @param failureBlock Callback block called when loading
 @param loadStartedBlock Callback block called when loading started
 @param shouldLoadBlock Callback block determining whether or not a specific page should be loaded.
 
 @return The generated UIWebView
 */
+ (UIWebView *)loadHTMLString:(NSString *)htmlString
                       loaded:(void (^)(UIWebView *))loadedBlock
                       failed:(void (^)(UIWebView *, NSError *))failureBlock
                  loadStarted:(void (^)(UIWebView *webView))loadStartedBlock
                   shouldLoad:(BOOL (^)(UIWebView *webView, NSURLRequest *request, UIWebViewNavigationType navigationType))shouldLoadBlock;

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
              height:(NSInteger)height;

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
                   y:(NSInteger)y;

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
                 uicolor:(UIColor *)color;

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
- (void)strokeRectOnCanvas:(NSString *)canvasId
                         x:(NSInteger)x
                         y:(NSInteger)y
                     width:(NSInteger)width
                    height:(NSInteger)height
                   uicolor:(UIColor *)color
                 lineWidth:(NSInteger)lineWidth;

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
                   height:(NSInteger)height;

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
            uicolor:(UIColor *)color;

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
           lineWidth:(NSInteger)lineWidth;

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
            lineWidth:(NSInteger)lineWidth;

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
                  lineWidth:(NSInteger)lineWidth;

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
               dh:(NSInteger)dh;

#pragma mark -
#pragma mark :. JavaScript

#pragma mark--- 获取网页中的数据

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 获取某个标签的结点个数
 *
 *  @param tag <#tag description#>
 *
 */
- (int)nodeCountOfTag:(NSString *)tag;

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 获取当前页面URL
 */
- (NSString *)getCurrentURL;

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 获取标题
 */
- (NSString *)getTitle;

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 获取图片
 */
- (NSArray *)getImgs;

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 获取当前页面所有链接
 */
- (NSArray *)getOnClicks;

#pragma mark --- 改变网页样式和行为

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 为所有图片添加点击事件(网页中有些图片添加无效)
 */
- (void)addClickEventOnImg;

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 改变所有图像的宽度
 *
 *  @param size 数值
 */
- (void)setImgWidth:(int)size;

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 改变所有图像的高度
 *
 *  @param size 数值
 */
- (void)setImgHeight:(int)size;

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 改变指定标签的字体颜色
 *
 *  @param color   颜色
 *  @param tagName tag名字
 */
- (void) setFontColor:(UIColor *)color
              withTag:(NSString *)tagName;

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 改变指定标签的字体大小
 *
 *  @param size    数值
 *  @param tagName tag名字
 */
- (void) setFontSize:(int)size 
             withTag:(NSString *)tagName;

@end
