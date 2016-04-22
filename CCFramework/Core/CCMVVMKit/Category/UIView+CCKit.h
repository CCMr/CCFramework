//
//  UIView+CCKit.h
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
#import "CCViewProtocol.h"
#import "CCViewMangerProtocol.h"
#import "CCViewModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^ViewEventsBlock)(NSString *info, NSDictionary *eventDic);

@interface UIView (CCKit)

/**
 *  viewDelegate 传递事件
 */
@property(nullable, nonatomic, weak) id<CCViewProtocol> viewDelegate;

/**
 *  block 传递事件
 */
@property(nonatomic, copy) ViewEventsBlock viewEventsBlock;

/**
 *  将view中的事件交由viewManger处理
 */
- (void)cc_viewWithViewManger:(id<CCViewProtocol>)viewManger;

/**
 *  根据model配置UIView，设置UIView内容
 */
- (void)cc_configureViewWithModel:(id)model;

/**
 *  根据viewModel配置UIView，设置UIView内容
 */
- (void)cc_configureViewWithViewModel:(id<CCViewModelProtocol>)viewModel;

@end

NS_ASSUME_NONNULL_END