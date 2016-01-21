//
//  CCRefreshBaseView.h
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

@class CCRefreshBaseView;

#pragma mark - 控件的刷新状态
typedef enum {
    CCRefreshStatePulling = 1,    // 松开就可以进行刷新的状态
    CCRefreshStateNormal = 2,     // 普通状态
    CCRefreshStateRefreshing = 3, // 正在刷新中的状态
    CCRefreshStateWillRefreshing = 4
} CCRefreshState;

#pragma mark - 控件的类型
typedef enum {
    CCRefreshViewTypeHeader = -1, // 头部控件
    CCRefreshViewTypeFooter = 1   // 尾部控件
} CCRefreshViewType;

#pragma mark - 控件显示样式
typedef enum {
    CCRefreshViewStyleDefault = 0,
    CCRefreshViewStyleIndicatorView = 1,
} CCRefreshViewStyle;

/**
 类的声明
 */
@interface CCRefreshBaseView : UIView

#pragma mark - 父控件
@property(nonatomic, weak, readonly) UIScrollView *scrollView;
@property(nonatomic, assign, readonly) UIEdgeInsets scrollViewOriginalInset;

#pragma mark - 内部的控件
@property(nonatomic, weak, readonly) UILabel *statusLabel;
@property(nonatomic, weak, readonly) UIImageView *arrowImage;
@property(nonatomic, weak, readonly) UIActivityIndicatorView *activityView;

#pragma mark - 回调
/**
 *  开始进入刷新状态的监听器
 */
@property(weak, nonatomic) id beginRefreshingTaget;
/**
 *  开始进入刷新状态的监听方法
 */
@property(assign, nonatomic) SEL beginRefreshingAction;
/**
 *  开始进入刷新状态就会调用
 */
@property(nonatomic, copy) void (^beginRefreshingCallback)();

#pragma mark - 刷新相关
/**
 *  是否正在刷新
 */
@property(nonatomic, readonly, getter=isRefreshing) BOOL refreshing;
/**
 *  开始刷新
 */
- (void)beginRefreshing;
/**
 *  结束刷新
 */
- (void)endRefreshing;

#pragma mark - 交给子类去实现 和 调用
@property (assign, nonatomic) CCRefreshState state;

@property (nonatomic, assign) CCRefreshViewStyle style;

/**
 *  文字
 */
@property (copy, nonatomic) NSString *pullToRefreshText;
@property (copy, nonatomic) NSString *releaseToRefreshText;
@property (copy, nonatomic) NSString *refreshingText;
@end