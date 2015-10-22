//
//  CCHTTPRequest.h
//  Architecture
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

#pragma mark - HTTPRequest
/**
 *  @author CC, 2015-07-23
 *
 *  @brief  单列模式
 *
 *  @return 当前对象
 *
 *  @since 1.0
 */
+(id)sharedlnstance;

#pragma mark - 参数设置
/**
 *  @author CC, 2015-07-23
 *
 *  @brief  监测网络的可链接性
 *
 *  @param strUrl 检验网络地址
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
+ (BOOL) netWorkReachabilityWithURLString:(NSString *) strUrl;

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  设定固定请求参数
 *
 *  @param postData 请求参数
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSMutableDictionary *)fixedParameters:(NSDictionary *)postData;

/**
 *  @author CC, 2015-07-23
 *
 *  @brief 追加网络请求地址(必须继承该类实现该方法)
 *
 *  @param MethodName API地址
 *
 *  @return 返回服务器API地址
 */
- (NSString *)appendingServerURLWithString:(NSString *)MethodName;

/**
 *  @author CC, 2015-10-12
 *
 *  @brief  追加扩展网络请求地址(用于多个服务器地址)
 *
 *  @param MethodName API地址
 *
 *  @return 返回服务器API地址
 */
- (NSString *)appendingExpandServerURLWithString:(NSString *)MethodName;

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
- (NSString *)appendingServerURLWithString: (NSString *)serviceAddres
                                MethodName: (NSString *)methodName;

#pragma mark - 回调函数设置
/**
 *  @author CC, 2015-08-15
 *
 *  @brief  SET委托事件
 *
 *  @param requestOBJBlock 委托Block函数
 *  @param key             对应key
 *
 *  @since 1.0
 */
-(void)setRequestOBJBlock:(RequestBlock)requestOBJBlock
                      Key:(NSString *)key;
/**
 *  @author CC, 2015-08-15
 *
 *  @brief  GET委托事件
 *
 *  @param key 对应Key
 *
 *  @return 返回委托Block函数
 *
 *  @since 1.0
 */
- (RequestBlock)requestOBJBlock:(NSString *)key;

/**
 *  @author CC, 2015-10-12
 *
 *  @brief  SET委托
 *
 *  @param progressOBJBlock 委托Block函数
 *  @param key              对应Key
 */
- (void)setProgressOBJBlock: (ProgressBlock)progressOBJBlock
                        Key: (NSString *)key;

/**
 *  @author CC, 2015-08-15
 *
 *  @brief  GET委托事件
 *
 *  @param key 对应Key
 *
 *  @return 返回委托Block函数
 */
- (ProgressBlock)ProgressOBJBlock: (NSString *)key;

/**
 *  @author CC, 2015-08-15
 *
 *  @brief  SET委托事件
 *
 *  @param requestOBJBlock 委托Block函数
 *  @param key             对应key
 *
 *  @since 1.0
 */
-(void)setCompletionOBJBlock: (CompletionBlock)completionOBJBlock
                         Key: (NSString *)key;
/**
 *  @author CC, 2015-08-15
 *
 *  @brief  GET委托事件
 *
 *  @param key 对应Key
 *
 *  @return 返回委托Block函数
 *
 *  @since 1.0
 */
- (CompletionBlock)completionOBJBlock:(NSString *)key;

#pragma mark - 回调时间处理
/**
 *  @author CC, 2015-07-24
 *
 *  @brief  响音处理事件
 *
 *  @param responseData <#responseData description#>
 *
 *  @since 1.0
 */
- (void)responseProcessEvent:(id)responseData
                     BlockKey:(NSString *)key;

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  对ErrorCode进行处理
 *
 *  @param errorDic <#errorDic description#>
 *
 *  @since 1.0
 */
- (void)errorCodeWithDic:(id)errorDic
                 BlockKey:(NSString *)key;

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  对网路异常进行处理
 *
 *  @param error <#error description#>
 *
 *  @since 1.0
 */
- (void)netFailure: (NSError *)error
          BlockKey: (NSString *)key;

/**
 *  @author CC, 2015-10-22
 *
 *  @brief  请求完成后回调函数
 *
 *  @param completionData 返回数据
 *  @param userInfo       字典接收
 *  @param key            key
 */
- (void)completion: (id)completionData
          UserInfo: (id)userInfo
          BlockKey: (NSString *)key;

@end
