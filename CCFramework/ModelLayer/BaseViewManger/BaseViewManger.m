//
//  BaseViewManger.m
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

#import "BaseViewManger.h"

@implementation BaseViewManger

/**
 *  @author CC, 2016-03-14
 *  
 *  @brief 初始化控件
 */
- (void)initControl
{
}

/**
 *  @author CC, 2016-03-14
 *  
 *  @brief 初始化数据
 */
- (void)initWithData
{
}

/**
 *  @author CC, 2016-03-14
 *  
 *  @brief 初始化加载数据
 */
- (void)initLoadData
{
}

/**
 *  @author CC, 16-03-16
 *  
 *  @brief 将viewManger事件传递到ViewModel
 *
 *  @param eventHandle 响应处理回调
 */
- (void)cc_viewMangerWithEventHandle:(EventHandle)eventHandle
{
    self.eventHandle = eventHandle;
}

/**
 *  @author CC, 16-03-15
 *  
 *  @brief 将viewManger事件传递到ViewModel并带返回参数
 *
 *  @param eventHandleBlock 响应处理回调
 */
- (void)cc_viewMangerWithEventHandleReturn:(EventHandleReturn)eventHandleReturn
{
    self.eventHandleReturn = eventHandleReturn;
}

/**
 *  @author CC, 16-03-15
 *  
 *  @brief 将viewManger事件传递到ViewModel并回传Block
 *
 *  @param eventHandleBlock 数据结构
 */
- (void)cc_viewMangerWithEventHandleBlock:(EventHandleBlock)eventHandleBlock
{
    self.eventHandelBlock = eventHandleBlock;
}

@end
