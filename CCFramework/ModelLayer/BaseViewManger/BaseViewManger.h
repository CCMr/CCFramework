//
//  BaseViewManger.h
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

#import <Foundation/Foundation.h>
#import "CCViewMangerProtocolDelegate.h"

#import "CCViewMangerProtocol.h"
#import "CCViewModelProtocol.h"
#import "CCViewProtocol.h"

@interface BaseViewManger : NSObject <CCViewMangerProtocolDelegate, CCViewMangerProtocol, CCViewModelProtocol, CCViewProtocol>

/**
 *  @author CC, 16-03-14
 *  
 *  @brief 用于传递数据的基模型
 */
@property(nonatomic, strong) NSObject *cc_model;

/**
 *  @author CC, 16-03-15
 *  
 *  @brief 将View响应事件传递到 ViewManger <-> ViewController <-> ViewModel
 */
@property(nonatomic, copy) EventHandle eventHandle;

/**
 *  @author CC, 16-04-16
 *  
 *  @brief 将View响应事件传递到 ViewManger <-> ViewController <-> ViewModel
 *         同步等待返回结果
 */
@property(nonatomic, copy) EventHandleReturn eventHandleReturn;

/**
 *  @author CC, 16-04-16
 *  
 *  @brief 将View响应事件传递到 ViewManger <-> ViewController <-> ViewModel
 *         异步回调
 */
@property(nonatomic, copy) EventHandleBlock eventHandelBlock;


/**
 *  @author CC, 2016-03-14
 *  
 *  @brief 初始化控件
 */
- (void)initControl;

/**
 *  @author CC, 2016-03-14
 *  
 *  @brief 初始化数据
 */
- (void)initWithData;

/**
 *  @author CC, 2016-03-14
 *  
 *  @brief 初始化加载数据
 */
- (void)initLoadData;

@end
