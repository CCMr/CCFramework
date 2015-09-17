//
//  CCHTTPRequest.m
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

#import "CCHTTPRequest.h"
#import <objc/runtime.h>
#import "Config.h"

static CCHTTPRequest *_sharedlnstance = nil;
@implementation CCHTTPRequest

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  单列模式
 *
 *  @return 当前对象
 *
 *  @since 1.0
 */
+(id)sharedlnstance
{
    @synchronized(self){
        if (_sharedlnstance == nil) {
            _sharedlnstance = [[self alloc] init];
        }
    }
    return _sharedlnstance;
}

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  监测网络的可链接性
 *
 *  @param strUrl <#strUrl description#>
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
+ (BOOL) netWorkReachabilityWithURLString:(NSString *) strUrl
{
    return [CCHTTPManager netWorkReachabilityWithURLString:strUrl];
}

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
- (NSMutableDictionary *)fixedParameters:(NSDictionary *)postData
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:postData];

    return dic;
}

/**
 *  @author CC, 2015-07-23
 *
 *  @brief 拼接请求网络地址
 *
 *  @param MethodName api地址
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSString *)appendingServerURLWithString:(NSString *)MethodName
{
//    return [[NSString stringWithFormat:@"%@%@",ServiceAddress,MethodName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return @"";
}

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
-(void)setRequestOBJBlock:(RequestBlock)requestOBJBlock Key:(NSString *)key{
    objc_setAssociatedObject(self, (__bridge void*)key, requestOBJBlock, OBJC_ASSOCIATION_COPY);
}

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
-(RequestBlock)requestOBJBlock:(NSString *)key{
    return (RequestBlock)objc_getAssociatedObject(self,(__bridge void*)key);
}

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
                     BlokKey:(NSString *)key
{
    void (^responseProcessBlock)(id responseData,BOOL isError) = [self requestOBJBlock:key];
    if (responseProcessBlock) {
        NSDictionary *dic = responseData;
        if (![dic isKindOfClass:[NSDictionary class]]){
            NSData *datas = responseData;
            if ([datas isKindOfClass:[NSString class]])
                datas = [responseData dataUsingEncoding:NSUTF8StringEncoding];
            dic =  [NSJSONSerialization JSONObjectWithData:datas options:NSJSONReadingAllowFragments error:nil];
        }
        responseProcessBlock(dic,NO);
    }
}

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
                 BlokKey:(NSString *)key
{
    void (^errorCodeBlock)(id responseData,BOOL isError) = [self requestOBJBlock:key];
    if (errorCodeBlock) {
        errorCodeBlock(errorDic,YES);
    }
}

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  对网路异常进行处理
 *
 *  @param error <#error description#>
 *
 *  @since 1.0
 */
- (void)netFailure:(NSError *)error
           BlokKey:(NSString *)key
{
    void (^netFailureBlock)(id responseData,BOOL isError) = [self requestOBJBlock:key];
    if (netFailureBlock) {
        if (error.code == kCFURLErrorNotConnectedToInternet) {
            netFailureBlock(@"当前网络状况不佳，请检查网络设置",YES);
        }else if (error.code == kCFURLErrorTimedOut) {
            netFailureBlock(@"请求超时，请检查网络设置",YES);
        }else{
            netFailureBlock(@"请求服务器失败",YES);
        }
    }
}

@end
