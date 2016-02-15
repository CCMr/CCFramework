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
#import "CCResponseObject.h"

@interface CCHTTPRequest ()

/**
 *  @author C C, 2015-11-07
 *
 *  @brief  请求相应处理回调
 */
@property(nonatomic, copy) CCRequestBacktrack requestBacktrack;

/**
 *  @author C C, 2015-11-07
 *
 *  @brief  请求响应完成回调
 */
@property(nonatomic, copy) RequestCompletionBacktrack requestCompletionBacktrack;

/**
 *  @author C C, 2015-11-07
 *
 *  @brief  请求响应进度回调
 */
@property(nonatomic, copy) RequestProgressBacktrack requestProgressBacktrack;

@end

@implementation CCHTTPRequest

/**
 *  @author C C, 2015-11-07
 *
 *  @brief  创建并返回一个'CCHTTPRequest'对象。
 *
 *  @return 返回'CCHTTPRequest'
 */
+ (instancetype)manager
{
    return [[self alloc] initWithBase];
}

- (instancetype)init
{
    return [self initWithBase];
}

/**
 *  @author C C, 2015-11-07
 *
 *  @brief  初始化对象
 *
 *  @return 返回'CCHTTPRequest'
 */
- (instancetype)initWithBase
{
    if (self = [super init]) {
    }
    return self;
}

#pragma mark - 参数设置
/**
 *  @author CC, 2015-07-23
 *
 *  @brief  设定固定请求参数
 *
 *  @param postData 请求参数
 *
 *  @return 返回请求参数
 */
- (NSMutableDictionary *)fixedParameters:(NSDictionary *)postData
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:postData];
    
    [dic enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
        if ([obj isKindOfClass:[NSArray class]]) {
            NSError *error = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:&error];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            if (jsonString && !error)
                [dic setObject:jsonString forKey:key];
        }
    }];
    
    return dic;
}

/**
 *  @author CC, 2015-07-23
 *
 *  @brief 追加网络请求地址
 *
 *  @param MethodName API地址
 *
 *  @return 返回服务器API地址
 */
- (NSString *)appendingServerURLWithString:(NSString *)MethodName
{
    MethodName = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                       (__bridge CFStringRef)MethodName,
                                                                                       CFSTR("!*'();@&+$,%#[]"),
                                                                                       NULL,
                                                                                       CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return MethodName;
}

/**
 *  @author CC, 2015-10-12
 *
 *  @brief  追加扩展网络请求地址
 *
 *  @param MethodName API地址
 *
 *  @return 返回服务器API地址
 */
- (NSString *)appendingExpandServerURLWithString:(NSString *)MethodName
{
    MethodName = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                       (__bridge CFStringRef)MethodName,
                                                                                       NULL,
                                                                                       CFSTR("!*'();@&+$,%#[]"),
                                                                                       CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return MethodName;
}

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
- (NSString *)appendingServerURLWithString:(NSString *)serviceAddres
                                MethodName:(NSString *)methodName
{
    return [[NSString stringWithFormat:@"%@%@", serviceAddres, methodName]
            stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - 回调函数设置
/**
 *  @author C C, 2015-11-07
 *
 *  @brief  相应处理函数
 *
 *  @param responseData 响应数据
 */
- (void)setRequestBacktrack:(CCRequestBacktrack)requestBacktrack
{
    self->_requestBacktrack = [requestBacktrack copy];
}

/**
 *  @author C C, 2015-11-07
 *
 *  @brief  设置响应进度回调
 *
 *  @param requestProgressBacktrack 回调函数
 */
- (void)setRequestProgressBacktrack:(RequestProgressBacktrack)requestProgressBacktrack
{
    self->_requestProgressBacktrack = [requestProgressBacktrack copy];
}

/**
 *  @author C C, 2015-11-07
 *
 *  @brief  设置响应完成回调
 *
 *  @param requestCompletionBacktrack 回调函数
 */
- (void)setRequestCompletionBacktrack:(RequestCompletionBacktrack)requestCompletionBacktrack
{
    self->_requestCompletionBacktrack = [requestCompletionBacktrack copy];
}
#pragma mark - 回调事件处理
/**
 *  @author C C, 2015-11-07
 *
 *  @brief  响应处理函数
 *
 *  @param responseData 响应数据
 */
- (void)responseProcessEvent:(id)responseData
{
    if (_requestBacktrack) {
        _requestBacktrack(responseData, nil);
    }
}

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  对ErrorCode进行处理
 *
 *  @param errorDic 错误消息
 */
- (void)errorProcessEvent:(id)error
{
    [self errorProcessEvent:nil
                      Error:error];
}

/**
 *  @author CC, 2016-01-21
 *  
 *  @brief 对ErrorCode进行处理
 *
 *  @param responseData 回调响应数据
 *  @param error        错误消息
 */
- (void)errorProcessEvent:(id)responseData
                    Error:(id)error
{
    if (_requestBacktrack) {
        NSString *errorStr = error ?: @"";
        NSInteger code = 0;
        if ([error isKindOfClass:[NSError class]]) {
            code = ((NSError *)error).code;
            errorStr = [self httpErrorAnalysis:((NSError *)error).code];
        }
        _requestBacktrack(responseData, [NSError errorWithDomain:errorStr code:code userInfo:nil]);
    }
}

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  对网路异常进行处理
 *
 *  @param error 错误消息
 */
- (void)netFailure:(id)error
{
    [self netFailure:nil
               Error:error];
}

/**
 *  @author CC, 2016-02-15
 *
 *  @brief  对网路异常进行处理
 *
 *  @param error 错误消息
 */
- (void)netFailure:(id)responseData
             Error:(id)error
{
    if (_requestBacktrack) {
        NSString *errorStr = error ?: @"";
        NSInteger code = 0;
        if ([error isKindOfClass:[NSError class]]) {
            code = ((NSError *)error).code;
            errorStr = [self httpErrorAnalysis:code];
        } else if ([error isKindOfClass:[NSDictionary class]]) {
            responseData = [error objectForKey:@"userInfo"];
            NSError *Error = [error objectForKey:@"error"];
            code = Error.code;
            errorStr = [self httpErrorAnalysis:code];
        }
        _requestBacktrack(responseData, [NSError errorWithDomain:errorStr code:code userInfo:nil]);
    }
}

/**
 *  @author CC, 2015-10-22
 *
 *  @brief  请求完成后回调函数
 *
 *  @param completionData 返回数据
 *  @param userInfo       字典接收
 */
- (void)completion:(id)completionData
      withUserInfo:(NSDictionary *)userInfo
{
    if (_requestCompletionBacktrack) {
        _requestCompletionBacktrack(completionData, userInfo);
    }
}

/**
 *  @author CC, 2015-11-07
 *  
 *  @brief  错误消息处理
 *
 *  @param code 错误代码
 *
 *  @return 返回错误信息
 */
- (NSString *)httpErrorAnalysis:(NSInteger)code
{
    NSString *errorContent = @"请求服务器失败";
    
    NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
    //错误模块
    [errorInfo setObject:@"HTTP 认证类型不支持" forKey:@(kCFErrorHTTPAuthenticationTypeUnsupported)];
    [errorInfo setObject:@"HTTP 错误凭证" forKey:@(kCFErrorHTTPBadCredentials)];
    [errorInfo setObject:@"HTTP 连接丢失" forKey:@(kCFErrorHTTPConnectionLost)];
    [errorInfo setObject:@"HTTP 解析失败" forKey:@(kCFErrorHTTPParseFailure)];
    [errorInfo setObject:@"HTTP 重定向检测到循环" forKey:@(kCFErrorHTTPRedirectionLoopDetected)];
    [errorInfo setObject:@"HTTP 错误的URL" forKey:@(kCFErrorHTTPBadURL)];
    [errorInfo setObject:@"HTTP 代理服务器连接失败" forKey:@(kCFErrorHTTPProxyConnectionFailure)];
    [errorInfo setObject:@"HTTP 错误代理凭据" forKey:@(kCFErrorHTTPBadProxyCredentials)];
    [errorInfo setObject:@"PAC 文件错误" forKey:@(kCFErrorPACFileError)];
    [errorInfo setObject:@"PAC 文件验证错误" forKey:@(kCFErrorPACFileAuth)];
    [errorInfo setObject:@"HTTPS 代理连接失败" forKey:@(kCFErrorHTTPSProxyConnectionFailure)];
    [errorInfo setObject:@"流错误 HTTPS 代理失败意外响应连接方法" forKey:@(kCFStreamErrorHTTPSProxyFailureUnexpectedResponseToCONNECTMethod)];
    
    //故障模块
    [errorInfo setObject:@"请求故障! 会话由另一个进程使用" forKey:@(kCFURLErrorBackgroundSessionInUseByAnotherProcess)];
    [errorInfo setObject:@"请求故障! 会话被中断" forKey:@(kCFURLErrorBackgroundSessionWasDisconnected)];
    [errorInfo setObject:@"请求故障! 未知错误" forKey:@(kCFURLErrorUnknown)];
    [errorInfo setObject:@"请求故障! 请求被取消" forKey:@(kCFURLErrorCancelled)];
    [errorInfo setObject:@"请求故障! 错误的请求地址" forKey:@(kCFURLErrorBadURL)];
    [errorInfo setObject:@"请求故障! 链接超时! 请检查网络设置" forKey:@(kCFURLErrorTimedOut)];
    [errorInfo setObject:@"请求故障! 不支持的网址" forKey:@(kCFURLErrorUnsupportedURL)];
    [errorInfo setObject:@"请求故障! 无法找到主机" forKey:@(kCFURLErrorCannotFindHost)];
    [errorInfo setObject:@"请求故障! 无法连接到主机" forKey:@(kCFURLErrorCannotConnectToHost)];
    [errorInfo setObject:@"请求故障! 网络连接丢失" forKey:@(kCFURLErrorNetworkConnectionLost)];
    [errorInfo setObject:@"请求故障! DNS查找失败" forKey:@(kCFURLErrorDNSLookupFailed)];
    [errorInfo setObject:@"请求故障! HTTP重定向过多" forKey:@(kCFURLErrorHTTPTooManyRedirects)];
    [errorInfo setObject:@"请求故障! 资源不可用" forKey:@(kCFURLErrorResourceUnavailable)];
    [errorInfo setObject:@"请求故障! 当前网络状况不佳! 请检查网络设置" forKey:@(kCFURLErrorNotConnectedToInternet)];
    [errorInfo setObject:@"请求故障! 不存在的重定向位置" forKey:@(kCFURLErrorRedirectToNonExistentLocation)];
    [errorInfo setObject:@"请求故障! 服务器无响应" forKey:@(kCFURLErrorBadServerResponse)];
    [errorInfo setObject:@"请求故障! 用户取消认证" forKey:@(kCFURLErrorUserCancelledAuthentication)];
    [errorInfo setObject:@"请求故障! 用户需要进行身份验证" forKey:@(kCFURLErrorUserAuthenticationRequired)];
    [errorInfo setObject:@"请求故障! 请求资源零字节" forKey:@(kCFURLErrorZeroByteResource)];
    [errorInfo setObject:@"请求故障! 不能解码原始数据" forKey:@(kCFURLErrorCannotDecodeRawData)];
    [errorInfo setObject:@"请求故障! 不能解码的内容数据" forKey:@(kCFURLErrorCannotDecodeContentData)];
    [errorInfo setObject:@"请求故障! 无法解析响应" forKey:@(kCFURLErrorCannotParseResponse)];
    [errorInfo setObject:@"请求故障! 国际漫游关闭" forKey:@(kCFURLErrorInternationalRoamingOff)];
    [errorInfo setObject:@"请求故障! 呼叫中活动" forKey:@(kCFURLErrorCallIsActive)];
    [errorInfo setObject:@"请求故障! 数据不允许" forKey:@(kCFURLErrorDataNotAllowed)];
    [errorInfo setObject:@"请求故障! 请求体流溢出" forKey:@(kCFURLErrorRequestBodyStreamExhausted)];
    [errorInfo setObject:@"请求故障! 应用传输安全要求安全连接" forKey:@(kCFURLErrorAppTransportSecurityRequiresSecureConnection)];
    [errorInfo setObject:@"请求故障! 文件不存在" forKey:@(kCFURLErrorFileDoesNotExist)];
    [errorInfo setObject:@"请求故障! FileIs目录" forKey:@(kCFURLErrorFileIsDirectory)];
    [errorInfo setObject:@"请求故障! 没有权限读取文件" forKey:@(kCFURLErrorNoPermissionsToReadFile)];
    [errorInfo setObject:@"请求故障! 数据长度超过最大值" forKey:@(kCFURLErrorDataLengthExceedsMaximum)];
    
    if ([errorInfo.allKeys containsObject:@(code)])
        errorContent = [errorInfo objectForKey:@(code)];
    
    return errorContent;
}

@end
