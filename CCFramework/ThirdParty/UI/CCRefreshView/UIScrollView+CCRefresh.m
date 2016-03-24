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

#import "UIScrollView+CCRefresh.h"
#import "CCRefreshHeaderView.h"
#import "CCRefreshFooterView.h"
#import <objc/runtime.h>

#import "CCTransformRefresh.h"

@interface UIScrollView ()
@property(weak, nonatomic) CCRefreshHeaderView *header;
@property(weak, nonatomic) CCRefreshFooterView *footer;

/**
 *  @author CC, 16-03-18
 *  
 *  @brief 旋转刷新
 */
@property(nonatomic, weak) CCTransformRefresh *transformHeader;

@end


@implementation UIScrollView (CCRefresh)

#pragma mark - 运行时相关
static char CCRefreshHeaderViewKey;
static char CCRefreshFooterViewKey;

static char CCTransformRefreshKey;

- (void)setHeader:(CCRefreshHeaderView *)header
{
    [self willChangeValueForKey:@"CCRefreshHeaderViewKey"];
    objc_setAssociatedObject(self, &CCRefreshHeaderViewKey,
                             header,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"CCRefreshHeaderViewKey"];
}

- (CCRefreshHeaderView *)header
{
    return objc_getAssociatedObject(self, &CCRefreshHeaderViewKey);
}

- (void)setFooter:(CCRefreshFooterView *)footer
{
    [self willChangeValueForKey:@"CCRefreshFooterViewKey"];
    objc_setAssociatedObject(self, &CCRefreshFooterViewKey, footer, OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"CCRefreshFooterViewKey"];
}

- (CCRefreshFooterView *)footer
{
    return objc_getAssociatedObject(self, &CCRefreshFooterViewKey);
}

- (CCTransformRefresh *)transformHeader
{
    return objc_getAssociatedObject(self, &CCTransformRefreshKey);
}

- (void)setTransformHeader:(CCTransformRefresh *)transformHeader
{
    [self willChangeValueForKey:@"CCTransformRefreshKey"];
    objc_setAssociatedObject(self, &CCTransformRefreshKey, transformHeader, OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"CCTransformRefreshKey"];
}

#pragma mark :. 下拉旋转刷新
- (void)addTransformRefresh:(NSString *)trasImageName
                   Callback:(void (^)())callback
{
    if (!self.transformHeader) {
        CCTransformRefresh *transformHeader = [CCTransformRefresh Transformheader:trasImageName];
        transformHeader.scrollView = self;
        [self.superview addSubview:transformHeader];
        self.transformHeader = transformHeader;
    }
    self.transformHeader.beginRefreshingCallback = callback;
}

- (void)startTransform
{
    [self.transformHeader beginTransformRefreshing];
}

- (void)endTransform
{
    [self.transformHeader endTransformRefreshing];
}


#pragma mark - 下拉刷新
/**
 *  添加一个下拉刷新头部控件
 *
 *  @param callback 回调
 */
- (void)addHeaderWithCallback:(void (^)())callback
{
    [self addHeaderWithCallback:callback dateKey:nil];
}

- (void)addHeaderWithCallback:(void (^)())callback dateKey:(NSString *)dateKey
{
    // 1.创建新的header
    if (!self.header) {
        CCRefreshHeaderView *header = [CCRefreshHeaderView header];
        [self addSubview:header];
        self.header = header;
    }
    
    // 2.设置block回调
    self.header.beginRefreshingCallback = callback;
    
    // 3.设置存储刷新时间的key
    self.header.dateKey = dateKey;
}

/**
 *  添加一个下拉刷新头部控件
 *
 *  @param target 目标
 *  @param action 回调方法
 */
- (void)addHeaderWithTarget:(id)target
                     action:(SEL)action
{
    [self addHeaderWithTarget:target
                       action:action
                      dateKey:nil];
}

- (void)addHeaderWithTargetIndicatorView:(id)target
                                  action:(SEL)action
{
    [self addHeaderWithTarget:target
                       action:action
                      dateKey:nil
                        Style:CCRefreshViewStyleIndicatorView];
}

- (void)addHeaderWithTarget:(id)target
                     action:(SEL)action
                    dateKey:(NSString *)dateKey
{
    [self addHeaderWithTarget:target action:action
                      dateKey:dateKey
                        Style:CCRefreshViewStyleDefault];
}

- (void)addHeaderWithTarget:(id)target
                     action:(SEL)action
                    dateKey:(NSString *)dateKey
                      Style:(CCRefreshViewStyle)style
{
    // 1.创建新的header
    if (!self.header) {
        CCRefreshHeaderView *header = [CCRefreshHeaderView header];
        header.style = style;
        [self addSubview:header];
        self.header = header;
    }
    
    // 2.设置目标和回调方法
    self.header.beginRefreshingTaget = target;
    self.header.beginRefreshingAction = action;
    
    // 3.设置存储刷新时间的key
    self.header.dateKey = dateKey;
}

/**
 *  移除下拉刷新头部控件
 */
- (void)removeHeader
{
    [self.header removeFromSuperview];
    self.header = nil;
}

/**
 *  主动让下拉刷新头部控件进入刷新状态
 */
- (void)headerBeginRefreshing
{
    [self.header beginRefreshing];
}

/**
 *  让下拉刷新头部控件停止刷新状态
 */
- (void)headerEndRefreshing
{
    [self.header endRefreshing];
}

/**
 *  下拉刷新头部控件的可见性
 */
- (void)setHeaderHidden:(BOOL)hidden
{
    self.header.hidden = hidden;
}

- (BOOL)isHeaderHidden
{
    return self.header.isHidden;
}

- (BOOL)isHeaderRefreshing
{
    return self.header.isRefreshing;
}

#pragma mark - 上拉刷新
/**
 *  添加一个上拉刷新尾部控件
 *
 *  @param callback 回调
 */
- (void)addFooterWithCallback:(void (^)())callback
{
    // 1.创建新的footer
    if (!self.footer) {
        CCRefreshFooterView *footer = [CCRefreshFooterView footer];
        [self addSubview:footer];
        self.footer = footer;
    }
    
    // 2.设置block回调
    self.footer.beginRefreshingCallback = callback;
}

/**
 *  添加一个上拉刷新尾部控件
 *
 *  @param target 目标
 *  @param action 回调方法
 */
- (void)addFooterWithTarget:(id)target action:(SEL)action
{
    // 1.创建新的footer
    if (!self.footer) {
        CCRefreshFooterView *footer = [CCRefreshFooterView footer];
        [self addSubview:footer];
        self.footer = footer;
    }
    
    // 2.设置目标和回调方法
    self.footer.beginRefreshingTaget = target;
    self.footer.beginRefreshingAction = action;
}

/**
 *  移除上拉刷新尾部控件
 */
- (void)removeFooter
{
    [self.footer removeFromSuperview];
    self.footer = nil;
}

/**
 *  主动让上拉刷新尾部控件进入刷新状态
 */
- (void)footerBeginRefreshing
{
    [self.footer beginRefreshing];
}

/**
 *  让上拉刷新尾部控件停止刷新状态
 */
- (void)footerEndRefreshing
{
    [self.footer endRefreshing];
}


- (void)EndRefreshing
{
    [self.header endRefreshing];
    [self.footer endRefreshing];
}

/**
 *  下拉刷新头部控件的可见性
 */
- (void)setFooterHidden:(BOOL)hidden
{
    self.footer.hidden = hidden;
}

- (BOOL)isFooterHidden
{
    return self.footer.isHidden;
}

- (BOOL)isFooterRefreshing
{
    return self.footer.isRefreshing;
}

/**
 *  文字
 */
- (void)setFooterPullToRefreshText:(NSString *)footerPullToRefreshText
{
    self.footer.pullToRefreshText = footerPullToRefreshText;
}

- (NSString *)footerPullToRefreshText
{
    return self.footer.pullToRefreshText;
}

- (void)setFooterReleaseToRefreshText:(NSString *)footerReleaseToRefreshText
{
    self.footer.releaseToRefreshText = footerReleaseToRefreshText;
}

- (NSString *)footerReleaseToRefreshText
{
    return self.footer.releaseToRefreshText;
}

- (void)setFooterRefreshingText:(NSString *)footerRefreshingText
{
    self.footer.refreshingText = footerRefreshingText;
}

- (NSString *)footerRefreshingText
{
    return self.footer.refreshingText;
}

- (void)setHeaderPullToRefreshText:(NSString *)headerPullToRefreshText
{
    self.header.pullToRefreshText = headerPullToRefreshText;
}

- (NSString *)headerPullToRefreshText
{
    return self.header.pullToRefreshText;
}

- (void)setHeaderReleaseToRefreshText:(NSString *)headerReleaseToRefreshText
{
    self.header.releaseToRefreshText = headerReleaseToRefreshText;
}

- (NSString *)headerReleaseToRefreshText
{
    return self.header.releaseToRefreshText;
}

- (void)setHeaderRefreshingText:(NSString *)headerRefreshingText
{
    self.header.refreshingText = headerRefreshingText;
}

- (NSString *)headerRefreshingText
{
    return self.header.refreshingText;
}


@end
