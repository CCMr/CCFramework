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

@implementation CCHTTPRequest


#pragma mark - 参数设置

/**
 *  @author CC, 2016-3-10
 *
 *  @brief  设定固定请求参数
 *
 *  @param postData 请求参数
 */
+ (NSMutableDictionary *)fixedParameters:(NSDictionary *)postData
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:postData];
    return dic;
}

/**
 *  @author CC, 2016-3-10
 *
 *  @brief 追加网络请求地址
 *
 *  @param MethodName API地址
 */
+ (NSString *)appendingServerURLWithString:(NSString *)MethodName
{
    MethodName = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                       (__bridge CFStringRef)MethodName,
                                                                                       CFSTR("!*'();@&+$,%#[]"),
                                                                                       NULL,
                                                                                       CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return MethodName;
}

/**
 *  @author CC, 2016-3-10
 *
 *  @brief  追加扩展网络请求地址
 *
 *  @param MethodName API地址
 */
+ (NSString *)appendingExpandServerURLWithString:(NSString *)MethodName
{
    MethodName = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                       (__bridge CFStringRef)MethodName,
                                                                                       NULL,
                                                                                       CFSTR("!*'();@&+$,%#[]"),
                                                                                       CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return MethodName;
}

/**
 *  @author CC, 2016-3-10
 *
 *  @brief  拼接请求网络地址
 *
 *  @param serviceAddres 服务器地址
 *  @param methodName    API地址
 */
+ (NSString *)appendingServerURLWithString:(NSString *)serviceAddres
                                MethodName:(NSString *)methodName
{
    return [[NSString stringWithFormat:@"%@%@", serviceAddres, methodName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark -
#pragma mark :. 网络请求并解析

static id dataObj;

/**
 *  @author CC, 16-03-10
 *  
 *  @brief GET请求
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param modelClass       模型Class
 *  @param cachePolicy      缓存类型
 *  @param response         请求响应结果
 *  @param failure          故障处理回调
 */
+ (void)GET:(NSString *)requestURLString
 parameters:(NSDictionary *)parameter
 modelClass:(Class)modelClass
cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
   response:(responseBlock)response
    failure:(requestFailureBlock)failure
{
    [CCHTTPManager GET:requestURLString parameters:parameter cachePolicy:cachePolicy success:^(CCResponseObject *responseObject) {
        
        dataObj = [self modelTransformationWithResponseObj:responseObject
                                                modelClass:modelClass];
        
        if ([dataObj isKindOfClass:modelClass]) {
            if (response)
                response(dataObj,nil);
        }else{
            if (failure)
                failure([NSError errorWithDomain:dataObj code:0 userInfo:@{@"NSDebugDescription":@"解析对象错误"}]);
        }
    } failure:failure];
}

/**
 *  @author CC, 16-03-10
 *  
 *  @brief POST请求
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param modelClass       模型Class
 *  @param cachePolicy      缓存类型
 *  @param response         请求响应结果
 *  @param failure          故障处理回调
 */
+ (void)POST:(NSString *)requestURLString
  parameters:(NSDictionary *)parameter
  modelClass:(Class)modelClass
 cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
    response:(responseBlock)response
     failure:(requestFailureBlock)failure
{
    [CCHTTPManager POST:requestURLString parameters:parameter cachePolicy:cachePolicy success:^(CCResponseObject *responseObject) {
        dataObj = [self modelTransformationWithResponseObj:responseObject
                                                modelClass:modelClass];
        
        if ([dataObj isKindOfClass:modelClass]) {
            if (response)
                response(dataObj,nil);
        }else{
            if (failure)
                failure([NSError errorWithDomain:dataObj code:0 userInfo:@{@"NSDebugDescription":@"解析对象错误"}]);
        }
    } failure:failure];
}

/**
 *  @author CC, 16-03-10
 *  
 *  @brief DELETE请求
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param modelClass       模型Class
 *  @param cachePolicy      缓存类型
 *  @param response         请求响应结果
 *  @param failure          故障处理回调
 */
+ (void)DELETE:(NSString *)requestURLString
    parameters:(NSDictionary *)parameter
    modelClass:(Class)modelClass
   cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
      response:(responseBlock)response
       failure:(requestFailureBlock)failure
{
    [CCHTTPManager DELETE:requestURLString parameters:parameter cachePolicy:cachePolicy success:^(CCResponseObject *responseObject) {
        dataObj = [self modelTransformationWithResponseObj:responseObject
                                                modelClass:modelClass];
        
        if ([dataObj isKindOfClass:modelClass]) {
            if (response)
                response(dataObj,nil);
        }else{
            if (failure)
                failure([NSError errorWithDomain:dataObj code:0 userInfo:@{@"NSDebugDescription":@"解析对象错误"}]);
        }
    } failure:failure];
}

/**
 *  @author CC, 16-03-10
 *  
 *  @brief HEAD请求
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param modelClass       模型Class
 *  @param cachePolicy      缓存类型
 *  @param response         请求响应结果
 *  @param failure          故障处理回调
 */
+ (void)HEAD:(NSString *)requestURLString
  parameters:(NSDictionary *)parameter
  modelClass:(Class)modelClass
 cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
    response:(responseBlock)response
     failure:(requestFailureBlock)failure
{
    [CCHTTPManager HEAD:requestURLString parameters:parameter cachePolicy:cachePolicy success:^(CCResponseObject *responseObject) {
        if (response)
            response(responseObject,nil);
    } failure:failure];
}

/**
 *  @author CC, 16-03-10
 *  
 *  @brief PUT请求
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param modelClass       模型Class
 *  @param cachePolicy      缓存类型
 *  @param response         请求响应结果
 *  @param failure          故障处理回调
 */
+ (void)PUT:(NSString *)requestURLString
 parameters:(NSDictionary *)parameter
 modelClass:(Class)modelClass
cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
   response:(responseBlock)response
    failure:(requestFailureBlock)failure
{
    
    [CCHTTPManager PUT:requestURLString parameters:parameter cachePolicy:cachePolicy success:^(CCResponseObject *responseObject) {
        dataObj = [self modelTransformationWithResponseObj:responseObject
                                                modelClass:modelClass];
        
        if ([dataObj isKindOfClass:modelClass]) {
            if (response)
                response(dataObj,nil);
        }else{
            if (failure)
                failure([NSError errorWithDomain:dataObj code:0 userInfo:@{@"NSDebugDescription":@"解析对象错误"}]);
        }
    } failure:failure];
}

/**
 *  @author CC, 16-03-10
 *  
 *  @brief PATCH请求
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param modelClass       模型Class
 *  @param cachePolicy      缓存类型
 *  @param response         请求响应结果
 *  @param failure          故障处理回调
 */
+ (void)PATCH:(NSString *)requestURLString
   parameters:(NSDictionary *)parameter
   modelClass:(Class)modelClass
  cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
     response:(responseBlock)response
      failure:(requestFailureBlock)failure
{
    [CCHTTPManager PATCH:requestURLString parameters:parameter cachePolicy:cachePolicy success:^(CCResponseObject *responseObject) {
        dataObj = [self modelTransformationWithResponseObj:responseObject
                                                modelClass:modelClass];
        
        if ([dataObj isKindOfClass:modelClass]) {
            if (response)
                response(dataObj,nil);
        }else{
            if (failure)
                failure([NSError errorWithDomain:dataObj code:0 userInfo:@{@"NSDebugDescription":@"解析对象错误"}]);
        }
    } failure:failure];
}

#pragma mark -
#pragma mark :. 网络请求解析处理

/**
 数组、字典转化为模型
 */
+ (id)modelTransformationWithResponseObj:(CCResponseObject *)responseObject modelClass:(Class)modelClass
{
    return nil;
}

/**
 *  @author CC, 16-04-06
 *  
 *  @brief GET请求处理
 *
 *  @param api           API地址
 *  @param parameter     发送参数
 *  @param responseBlock 回调函数
 */
+ (void)handleGET:(NSString *)api
       parameters:(NSDictionary *)parameter
    responseBlock:(CCRequestBacktrack)responseBlock
{
}

/**
 *  @author CC, 16-04-06
 *  
 *  @brief POST请求处理
 *
 *  @param api           API地址
 *  @param parameter     发送参数
 *  @param responseBlock 回调函数
 */
+ (void)handlePOST:(NSString *)api
        parameters:(NSDictionary *)parameter
     responseBlock:(CCRequestBacktrack)responseBlock
{
}

/**
 *  @author CC, 16-04-06
 *  
 *  @brief ELETE请求处理
 *
 *  @param api           API地址
 *  @param parameter     发送参数
 *  @param responseBlock 回调函数
 */
+ (void)handleDELETE:(NSString *)api
          parameters:(NSDictionary *)parameter
       responseBlock:(CCRequestBacktrack)responseBlock
{
}

/**
 *  @author CC, 16-04-06
 *  
 *  @brief HEAD请求处理
 *
 *  @param api           API地址
 *  @param parameter     发送参数
 *  @param responseBlock 回调函数
 */
+ (void)handleHEAD:(NSString *)api
        parameters:(NSDictionary *)parameter
     responseBlock:(CCRequestBacktrack)responseBlock
{
    
}

/**
 *  @author CC, 16-04-06
 *  
 *  @brief PUT请求处理
 *
 *  @param api           API地址
 *  @param parameter     发送参数
 *  @param responseBlock 回调函数
 */
+ (void)handlePUT:(NSString *)api
       parameters:(NSDictionary *)parameter
    responseBlock:(CCRequestBacktrack)responseBlock
{
    
}

/**
 *  @author CC, 16-04-06
 *  
 *  @brief PATCH请求处理
 *
 *  @param api           API地址
 *  @param parameter     发送参数
 *  @param responseBlock 回调函数
 */
+ (void)handlePATCH:(NSString *)api
         parameters:(NSDictionary *)parameter
      responseBlock:(CCRequestBacktrack)responseBlock
{
    
}

@end
