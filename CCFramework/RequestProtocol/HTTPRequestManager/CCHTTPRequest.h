//
//  CCHTTPRequest.h
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
#import "CCHTTPManager.h"

@interface CCHTTPRequest : NSObject

/**
 *  @author C C, 2015-11-07
 *
 *  @brief  创建并返回一个'CCHTTPRequest'对象。
 *
 *  @return 返回'CCHTTPRequest'
 */
+ (instancetype)manager;

/**
 *  @author C C, 2015-11-07
 *
 *  @brief  初始化对象
 *
 *  @return 返回'CCHTTPRequest'
 */
- (instancetype)initWithBase;

#pragma mark - 参数设置
/**
 *  @author CC, 2015-07-23
 *
 *  @brief  监测网络的可链接性
 *
 *  @param strUrl 检验网络地址
 *
 *  @return 返回是否可以访问
 */
+ (BOOL)netWorkReachabilityWithURLString:(NSString*)strUrl;

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  设定固定请求参数
 *
 *  @param postData 请求参数
 *
 *  @return 返回请求参数
 */
- (NSMutableDictionary*)fixedParameters:(NSDictionary*)postData;

/**
 *  @author CC, 2015-07-23
 *
 *  @brief 追加网络请求地址(必须继承该类实现该方法)
 *
 *  @param MethodName API地址
 *
 *  @return 返回服务器API地址
 */
- (NSString*)appendingServerURLWithString:(NSString*)MethodName;

/**
 *  @author CC, 2015-10-12
 *
 *  @brief  追加扩展网络请求地址(用于多个服务器地址)
 *
 *  @param MethodName API地址
 *
 *  @return 返回服务器API地址
 */
- (NSString*)appendingExpandServerURLWithString:(NSString*)MethodName;

/**
 *  @author CC, 2015-10-12
 *
 *  @brief  拼接请求网络地址
 *
 *  @param serviceAddres 服务器地址
 *  @param methodName    API地址
 *
 *  @return 返回服务器API地址
 */
- (NSString*)appendingServerURLWithString:(NSString*)serviceAddres
                               MethodName:(NSString*)methodName;

#pragma mark - 回调函数设置
/**
 *  @author C C, 2015-11-07
 *
 *  @brief  设置响应回调
 *
 *  @param requestBacktrack 回调函数
 */
- (void)setRequestBacktrack:(CCRequestBacktrack)requestBacktrack;

/**
 *  @author C C, 2015-11-07
 *
 *  @brief  设置响应进度回调
 *
 *  @param requestProgressBacktrack 回调函数
 */
- (void)setRequestProgressBacktrack:(RequestProgressBacktrack)requestProgressBacktrack;

/**
 *  @author C C, 2015-11-07
 *
 *  @brief  设置响应完成回调
 *
 *  @param requestCompletionBacktrack 回调函数
 */
- (void)setRequestCompletionBacktrack:(RequestCompletionBacktrack)requestCompletionBacktrack;

#pragma mark - 回调时间处理
/**
 *  @author C C, 2015-11-07
 *
 *  @brief  响应处理函数
 *
 *  @param responseData 响应数据
 */
-(void)responseProcessEvent:(id)responseData;

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  响应处理错误函数
 *
 *  @param errorDic 错误信息
 */
- (void)errorProcessEvent:(id)error;

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  响应故障处理函数
 *
 *  @param error 故障信息
 */
- (void)netFailure:(id)error;

/**
 *  @author CC, 2015-10-22
 *
 *  @brief  响应完成处理函数
 *
 *  @param completionData 响应数据
 *  @param userInfo       字典接收
 */
- (void)completion:(id)completionData
      withUserInfo:(NSDictionary *)userInfo;

@end
