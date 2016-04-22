//
//  BaseViewModel.h
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
#import "CCHTTPRequest.h"
#import "Config.h"
#import "CCMessage.h"
#import "SETextView.h"
#import "CCViewModelProtocolDelegate.h"

#import "CCViewModelProtocol.h"
#import "CCViewMangerProtocol.h"

typedef void (^failureBlock)(NSString *failure);

@interface BaseViewModel : NSObject <CCViewModelProtocolDelegate, CCViewModelProtocol, CCViewMangerProtocol>

/**
 *  @author CC, 2015-10-22
 *
 *  @brief  请求成功回调函数
 */
@property(nonatomic, copy) Completion returnBlock;

/**
 *  @author CC, 2015-10-22
 *
 *  @brief  请求故障回调函数
 */
@property(nonatomic, copy) failureBlock failure;

/**
 *  @author CC, 15-08-20
 *
 *  @brief  传入交互的Block块
 *
 *  @param returnBlock   完成响应回调
 *  @param faiilure      故障信息
 */
- (void)responseWithBlock:(Completion)returnBlock
                  failure:(failureBlock)failure;

/**
 *  @author CC, 15-08-20
 *
 *  @brief  获取数据
 *
 *  @since 1.0
 */
- (void)fetchDataSource;

/**
 *  @author CC, 16-03-09
 *  
 *  @brief 分析图片
 *
 *  @param sendMessage 消息体
 */
- (SETextView *)analysisTeletext:(CCMessage *)sendMessage;

/**
 *  @author CC, 16-03-09
 *  
 *  @brief  懒加载存放请求到的数据数组
 */
@property(nonatomic, strong) NSMutableArray *cc_dataArray;


@end
