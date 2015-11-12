//
//  CCRefreshConst.m
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

const CGFloat CCRefreshViewHeight = 64.0;
const CGFloat CCRefreshFastAnimationDuration = 0.25;
const CGFloat CCRefreshSlowAnimationDuration = 0.4;

NSString *const CCRefreshFooterPullToRefresh = @"上拉可以加载更多数据";
NSString *const CCRefreshFooterReleaseToRefresh = @"松开立即加载更多数据";
NSString *const CCRefreshFooterRefreshing = @"正在加载数据...";

NSString *const CCRefreshHeaderPullToRefresh = @"下拉可以刷新";
NSString *const CCRefreshHeaderReleaseToRefresh = @"松开立即刷新";
NSString *const CCRefreshHeaderRefreshing = @"正在刷新...";
NSString *const CCRefreshHeaderTimeKey = @"CCRefreshHeaderView";

NSString *const CCRefreshContentOffset = @"contentOffset";
NSString *const CCRefreshContentSize = @"contentSize";