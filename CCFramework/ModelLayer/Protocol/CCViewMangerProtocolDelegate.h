//
//  CCViewMangerProtocolDelegate.h
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

#ifndef CCViewMangerProtocolDelegate_h
#define CCViewMangerProtocolDelegate_h
#import <UIKit/UIKit.h>

/**
 *  @author CC, 16-03-15
 *  
 *  @brief 传递事件回调
 *
 *  @param eventDic 传递参数
 *  @param info     描述信息，用于区分调用
 */
typedef id (^EventHandle)(NSDictionary *eventDic, NSString *info);

/**
 *  @author CC, 16-03-15
 *  
 *  @brief 传递事件回调
 *
 *  @param eventDic      传递参数
 *  @param info          描述信息，用于区分调用
 *  @param callbackBlock 回传Block
 */
typedef void (^EventHandleBlock)(NSDictionary *eventDic, NSString *info, dispatch_block_t callbackBlock);

@protocol CCViewMangerProtocolDelegate <NSObject>

@optional

/**
 *  @author CC, 16-03-14
 *  
 *  @brief 设置Controller的子视图的管理者为self
 *
 *  @param superView 一般指subView所在控制器的view
 */
- (void)cc_viewMangerWithSuperView:(UIView *)superView;

/**
 *  @author CC, 16-03-14
 *  
 *  @brief 需要重新布局subView时，更改subView的frame或者约束
 *
 *  @param updateBlock 更新布局完成的block
 */
- (void)cc_viewMangerWithLayoutSubViews:(void (^)())updateBlock;

/**
 *  @author CC, 16-03-14
 *  
 *  @brief 使子视图更新到最新的布局约束或者frame
 */
- (void)cc_viewMangerWithUpdateLayoutSubViews;

/**
 *  @author CC, 16-03-14
 *  
 *  @brief 设置添加subView的事件
 *
 *  @param subView 管理的subView
 *  @param info    附带信息，用于区分调用
 */
- (void)cc_viewMangerWithHandleOfSubView:(UIView *)subView
                                    info:(NSString *)info;

/**
 *  @author CC, 16-03-15
 *  
 *  @brief 将（model或数据源）数据传递到viewManger
 *
 *  @param modelDictBlock 数据结构
 */
- (void)cc_viewMangerWithModel:(NSDictionary * (^)())modelDictBlock;

/**
 *  @author CC, 16-03-15
 *  
 *  @brief 将View响应事件传递到 ViewManger <-> VC <-> ViewModel
 *
 *  @param eventHandleBlock 响应处理
 */
- (void)cc_viewMangerWithEventHandle:(EventHandle)eventHandleBlock;
- (void)cc_viewMangerWithEventHandleBlock:(EventHandleBlock)eventHandleBlock;

@end

#endif /* CCViewMangerProtocolDelegate_h */
