//
//  HTTPRequestManager.h
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

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Config.h"
#import "CCResponseObject.h"

typedef NS_ENUM(NSUInteger, CCHTTPRequestCachePolicy) {
    /** 不作任何处理，只请求数据 */
    CCHTTPReturnDefault = 0,
    /** 有缓存就先返回缓存，同步请求数据 */
    CCHTTPReturnCacheDataThenLoad,
    /** 忽略缓存，重新请求 */
    CCHTTPReloadIgnoringLocalCacheData,
    /** 有缓存就用缓存，没有缓存就重新请求(用于数据不变时) */
    CCHTTPReturnCacheDataElseLoad,
    /** 有缓存就用缓存，没有缓存就不发请求，当做请求出错处理（用于离线模式）*/
    CCHTTPReturnCacheDataDontLoad
};

/**
 *  @author CC, 16-03-10
 *  
 *  @brief 请求成功Block
 */
typedef void (^requestSuccessBlock)(CCResponseObject *responseObject);

/**
 *  @author CC, 16-03-10
 *  
 *  @brief 请求失败Block
 */
typedef void (^requestFailureBlock)(NSError *error);

/**
 *  @author CC, 16-03-10
 *  
 *  @brief 请求进度Block
 */
typedef void (^requestProgressBlock)(NSProgress *progress);

/**
 *  @author C C, 16-03-10
 *
 *  @brief  请求响应结果
 *
 *  @param data  下载数据
 *  @param error 错误信息
 */
typedef void (^requestDownloadBacktrack)(NSData *data, NSError *error);

/**
 *  @author CC, 16-03-10
 *  
 *  @brief 请求下载文件回调
 *
 *  @param response 响应结果
 *  @param error    错误信息
 */
typedef void (^requestDownloadsuccess)(id response, NSError *error);

@class HttpFileConfig;

@interface CCHTTPManager : NSObject

/**
 *  @author CC, 2015-10-22
 *
 *  @brief   用户信息字典接收机
 */
@property(nonatomic, strong) NSDictionary *userInfo;

/**
 *  @author CC, 2015-11-25
 *  
 *  @brief  超时时间间隔，以秒为单位创建的请求。默认的超时时间间隔为30秒。
 */
@property(nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 *  @author CC, 16-01-28
 *  
 *  @brief 设置请求ContentType
 */
@property(nonatomic, copy) NSSet *acceptableContentTypes;

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  单列模式
 */
+ (instancetype)defaultHttp;

/**
 *  @author CC, 16-01-28
 *  
 *  @brief 创建并返回一个‘CCHTTPManager’对象。
 */
+ (instancetype)manager;

/**
 *  @author CC, 16-03-11
 *  
 *  @brief 设置传输字典
 *
 *  @param userInfo 字典
 */
+ (void)setUserInfo:(NSDictionary *)userInfo;

/**
 *  @author CC, 16-01-28
 *  
 *  @brief 初始化请求对象
 */
-
(id)requestOperationManager;

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  监测网络的可链接性
 *
 *  @param strUrl 检验网络地址
 *
 *  @return 返回网络是否可用
 */
+ (BOOL)netWorkReachabilityWithURLString:(NSString *)strUrl;

/**
 *  @author CC, 16-01-28
 *  
 *  @brief 时时网络状态（status 0: 无网络 1: 3G/4G 2:WiFi）
 *
 *  @param status 网络状态
 */
+ (void)netWorkReachability:(void (^)(NSInteger status))success;

/**
 *  @author CC, 16-01-28
 *  
 *  @brief 请求检查网络
 */
+ (BOOL)requestBeforeCheckNetWork;

#pragma mark :. 请求

/**
 *  @author CC, 16-03-10
 *  
 *  @brief GET请求 
 *         默认 CCHTTPReloadIgnoringLocalCacheData的缓存方式
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param success          成功处理回调
 *  @param failure          故障处理回调
 */
+ (void)GET:(NSString *)requestURLString
 parameters:(NSDictionary *)parameter
    success:(requestSuccessBlock)success
    failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-03-10
 *  
 *  @brief GET请求
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param cachePolicy      缓存类型
 *  @param success          成功处理回调
 *  @param failure          故障处理回调
 */
+ (void)GET:(NSString *)requestURLString
 parameters:(NSDictionary *)parameter
cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
    success:(requestSuccessBlock)success
    failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-03-10
 *  
 *  @brief POST请求
 *         默认 CCHTTPReloadIgnoringLocalCacheData的缓存方式
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param success          成功处理回调
 *  @param failure          故障处理回调
 */
+ (void)POST:(NSString *)requestURLString
  parameters:(NSDictionary *)parameter
     success:(requestSuccessBlock)success
     failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-03-10
 *  
 *  @brief POST请求
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param cachePolicy      缓存类型
 *  @param success          成功处理回调
 *  @param failure          故障处理回调
 */
+ (void)POST:(NSString *)requestURLString
  parameters:(NSDictionary *)parameter
 cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
     success:(requestSuccessBlock)success
     failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-03-10
 *  
 *  @brief DELETE请求
 *         默认 CCHTTPReloadIgnoringLocalCacheData的缓存方式
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param success          成功处理回调
 *  @param failure          故障处理回调
 */
+ (void)DELETE:(NSString *)requestURLString
    parameters:(NSDictionary *)parameter
       success:(requestSuccessBlock)success
       failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-03-10
 *  
 *  @brief DELETE请求
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param cachePolicy      缓存类型
 *  @param success          成功处理回调
 *  @param failure          故障处理回调
 */
+ (void)DELETE:(NSString *)requestURLString
    parameters:(NSDictionary *)parameter
   cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
       success:(requestSuccessBlock)success
       failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-03-10
 *  
 *  @brief HEAD请求
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param cachePolicy      缓存类型
 *  @param success          成功处理回调
 *  @param failure          故障处理回调
 */
+ (void)HEAD:(NSString *)requestURLString
  parameters:(NSDictionary *)parameter
 cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
     success:(requestSuccessBlock)success
     failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-03-10
 *  
 *  @brief PUT请求
 *         默认 CCHTTPReloadIgnoringLocalCacheData的缓存方式
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param success          成功处理回调
 *  @param failure          故障处理回调
 */
+ (void)PUT:(NSString *)requestURLString
 parameters:(NSDictionary *)parameter
    success:(requestSuccessBlock)success
    failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-03-10
 *  
 *  @brief PUT请求
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param cachePolicy      缓存类型
 *  @param success          成功处理回调
 *  @param failure          故障处理回调
 */
+ (void)PUT:(NSString *)requestURLString
 parameters:(NSDictionary *)parameter
cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
    success:(requestSuccessBlock)success
    failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-03-10
 *  
 *  @brief PATCH请求
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param cachePolicy      缓存类型
 *  @param success          成功处理回调
 *  @param failure          故障处理回调
 */
+ (void)PATCH:(NSString *)requestURLString
   parameters:(NSDictionary *)parameter
  cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
      success:(requestSuccessBlock)success
      failure:(requestFailureBlock)failure;

#pragma mark :. 上下传文件

/**
 *  @author CC, 16-03-10
 *  
 *  @brief 上传文件(表单提交)
 *
 *  @param requestURLString 请求地址
 *  @param parameter        发送阐述
 *  @param fileConfig       文件对象
 *  @param success          完成回调
 *  @param failure          故障回调
 */
+ (void)Upload:(NSString *)requestURLString
    parameters:(NSDictionary *)parameter
    fileConfig:(HttpFileConfig *)fileConfig
       success:(requestSuccessBlock)success
       failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-03-10
 *  
 *  @brief 上传文件（流）
 *
 *  @param requestURLString 请求地址
 *  @param filePath         文件地址
 *  @param progress         进度
 *  @param success          完成回调
 *  @param failure          故障回调
 */
+ (void)Upload:(NSString *)requestURLString
      filePath:(NSString *)filePath
      progress:(NSProgress *__autoreleasing *)progress
       success:(requestSuccessBlock)success
       failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-03-10
 *  
 *  @brief 下载文件
 *
 *  @param requestURLString      请求地址
 *  @param fileName              文件名
 *  @param downloadProgressBlock 进度回调
 *  @param success               完成回调
 *  @param failure               故障回调
 */
+ (void)Download:(NSString *)requestURLString
        fileName:(NSString *)fileName
downloadProgressBlock:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))downloadProgressBlock
         success:(requestDownloadBacktrack)success
         failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-03-10
 *  
 *  @brief 下载文件缓存
 *
 *  @param requestURLString 请求地址
 *  @param success          完成回调
 */
+ (void)Download:(NSString *)requestURLString
         success:(requestDownloadsuccess)success;

@end
