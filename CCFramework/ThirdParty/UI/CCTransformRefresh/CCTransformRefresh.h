//
//  CCTransformRefresh.h
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

@interface CCTransformRefresh : UIView

#pragma mark - 父控件
@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, assign, readonly) UIEdgeInsets scrollViewOriginalInset;

+ (instancetype)Transformheader:(NSString *)traImage;

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
 *  开始刷新
 */
- (void)beginTransformRefreshing;
/**
 *  结束刷新
 */
- (void)endTransformRefreshing;


@end
