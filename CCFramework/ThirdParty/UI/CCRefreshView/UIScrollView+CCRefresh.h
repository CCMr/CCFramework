//
//  UIScrollView+CCRefresh.h
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

/**
 CC友情提示：
 1. 添加头部控件的方法
 [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
 或者
 [self.tableView addHeaderWithCallback:^{ }];

 2. 添加尾部控件的方法
 [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
 或者
 [self.tableView addFooterWithCallback:^{ }];

 3. 可以在CCRefreshConst.h和CCRefreshConst.m文件中自定义显示的文字内容和文字颜色

 4. 本框架兼容iOS6\iOS7，iPhone\iPad横竖屏

 5.自动进入刷新状态
 1> [self.tableView headerBeginRefreshing];
 2> [self.tableView footerBeginRefreshing];

 6.结束刷新
 1> [self.tableView headerEndRefreshing];
 2> [self.tableView footerEndRefreshing];
 */

#import <UIKit/UIKit.h>

@interface UIScrollView (CCRefresh)

#pragma mark :. 下拉旋转刷新
- (void)addTransformRefresh:(NSString *)trasImageName
                   Callback:(void (^)())callback;

/**
 *  @author CC, 16-03-18
 *
 *  @brief 开始刷新
 */
- (void)startTransform;

/**
 *  @author CC, 16-03-18
 *
 *  @brief 结束刷新
 */
- (void)endTransform;

#pragma mark - 下拉刷新
/**
 *  添加一个下拉刷新头部控件
 *
 *  @param callback 回调
 */
- (void)addHeaderWithCallback:(void (^)())callback;

/**
 *  @author CC, 16-08-26
 *
 *  @brief 单独居中指示器
 *
 *  @param target 目标
 *  @param action 回调方法
 */
- (void)addHeaderWithIndicator:(id)target
                        action:(SEL)action;

/**
 *  @author CC, 16-08-18
 *
 *  @brief 添加一个下拉新头部控件
 *
 *  @param image    图片
 *  @param callback 回调
 */
- (void)addHeaderWithImageCallback:(UIImage *)image
                          Callback:(void (^)())callback;

/**
 *  添加一个下拉刷新头部控件
 *
 *  @param callback 回调
 *  @param dateKey 刷新时间保存的key值
 */
- (void)addHeaderWithCallback:(void (^)())callback dateKey:(NSString *)dateKey;

/**
 *  添加一个下拉刷新头部控件
 *
 *  @param target 目标
 *  @param action 回调方法
 */
- (void)addHeaderWithTarget:(id)target action:(SEL)action;

- (void)addHeaderWithTargetIndicatorView:(id)target
                                  action:(SEL)action;

/**
 *  添加一个下拉刷新头部控件
 *
 *  @param target 目标
 *  @param action 回调方法
 *  @param dateKey 刷新时间保存的key值
 */
- (void)addHeaderWithTarget:(id)target action:(SEL)action dateKey:(NSString *)dateKey;

/**
 *  移除下拉刷新头部控件
 */
- (void)removeHeader;

/**
 *  主动让下拉刷新头部控件进入刷新状态
 */
- (void)headerBeginRefreshing;

/**
 *  让下拉刷新头部控件停止刷新状态
 */
- (void)headerEndRefreshing;

/**
 *  下拉刷新头部控件的可见性
 */
@property(nonatomic, assign, getter=isHeaderHidden) BOOL headerHidden;

/**
 *  是否正在下拉刷新
 */
@property(nonatomic, assign, readonly, getter=isHeaderRefreshing) BOOL headerRefreshing;

#pragma mark - 上拉刷新
/**
 *  添加一个上拉刷新尾部控件
 *
 *  @param callback 回调
 */
- (void)addFooterWithCallback:(void (^)())callback;

/**
 *  添加一个上拉刷新尾部控件
 *
 *  @param target 目标
 *  @param action 回调方法
 */
- (void)addFooterWithTarget:(id)target action:(SEL)action;

/**
 *  移除上拉刷新尾部控件
 */
- (void)removeFooter;

/**
 *  主动让上拉刷新尾部控件进入刷新状态
 */
- (void)footerBeginRefreshing;

/**
 *  让上拉刷新尾部控件停止刷新状态
 */
- (void)footerEndRefreshing;

/**
 *  @author C C, 2015-11-12
 *
 *  @brief  停止上下拉刷新
 */
- (void)EndRefreshing;

/**
 *  上拉刷新头部控件的可见性
 */
@property(nonatomic, assign, getter=isFooterHidden) BOOL footerHidden;

/**
 *  是否正在上拉刷新
 */
@property(nonatomic, assign, readonly, getter=isFooterRefreshing) BOOL footerRefreshing;

/**
 *  设置尾部控件的文字
 */
@property(copy, nonatomic) NSString *footerPullToRefreshText;     // 默认:@"上拉可以加载更多数据"
@property (copy, nonatomic) NSString *footerReleaseToRefreshText; // 默认:@"松开立即加载更多数据"
@property (copy, nonatomic) NSString *footerRefreshingText; // 默认:@"正在加载数据..."

/**
 *  设置头部控件的文字
 */
@property (copy, nonatomic) NSString *headerPullToRefreshText; // 默认:@"下拉可以刷新"
@property (copy, nonatomic) NSString *headerReleaseToRefreshText; // 默认:@"松开立即刷新"
@property (copy, nonatomic) NSString *headerRefreshingText; // 默认:@"正在刷新...."
@end
