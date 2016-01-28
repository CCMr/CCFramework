//
//  BaseViewModel.m
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

#import "BaseViewModel.h"

@implementation BaseViewModel

#pragma mark - Public 函数

/**
 *  @author CC, 15-08-20
 *
 *  @brief  传入交互的Block块
 *
 *  @param returnBlock   完成响应回调
 *  @param errorBlock    错误响应函数
 *  @param faiilureBlock 超时或者请求失败响应函数
 *
 *  @since <#1.0#>
 */
- (void) responseWithBlock: (Completion) returnBlock
            WithErrorBlock: (ErrorCodeBlock) errorBlock
          WithFailureBlock: (FailureBlock)failureBlock
{
    self.returnBlock = [returnBlock copy];
    self.returnBlock = [returnBlock copy];
    self.errorBlock = [errorBlock copy];
    self.failureBlock = [failureBlock copy];
}

/**
 *  @author CC, 15-08-20
 *
 *  @brief  获取数据
 *
 *  @since 1.0
 */
- (void) fetchDataSource
{

}

@end
