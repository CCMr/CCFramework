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

/**
 *  @author CC, 16-03-10
 *  
 *  @brief 请求响应结果
 */
typedef void (^responseBlock)(id responseObj, NSError *error);

@interface CCHTTPRequest : NSObject

/**
 *  @author CC, 2016-3-10
 *
 *  @brief  设定固定请求参数
 *
 *  @param postData 请求参数
 */
+ (NSMutableDictionary *)fixedParameters:(NSDictionary *)postData;

/**
 *  @author CC, 2016-3-10
 *
 *  @brief 追加网络请求地址
 *
 *  @param MethodName API地址
 */
+ (NSString *)appendingServerURLWithString:(NSString *)MethodName;

/**
 *  @author CC, 2016-3-10
 *
 *  @brief  追加扩展网络请求地址
 *
 *  @param MethodName API地址
 */
+ (NSString *)appendingExpandServerURLWithString:(NSString *)MethodName;

/**
 *  @author CC, 2016-3-10
 *
 *  @brief  拼接请求网络地址
 *
 *  @param serviceAddres 服务器地址
 *  @param methodName    API地址
 */
+ (NSString *)appendingServerURLWithString:(NSString *)serviceAddres
                                MethodName:(NSString *)methodName;


#pragma mark :. 网络请求并解析
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
    failure:(requestFailureBlock)failure;

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
     failure:(requestFailureBlock)failure;

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
       failure:(requestFailureBlock)failure;

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
     failure:(requestFailureBlock)failure;

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
    failure:(requestFailureBlock)failure;

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
      failure:(requestFailureBlock)failure;


/**
 *  @author CC, 16-03-10
 *  
 *  @brief 数组、字典转模型，提供给子类的接口
 *
 *  @param responseObject 响应结果
 *  @param modelClass     模型对象
 */
+ (id)modelTransformationWithResponseObj:(CCResponseObject *)responseObject 
                              modelClass:(Class)modelClass;

@end
