//
//  CCHTTPUpDownLoad.h
//  CCFramework
//
//  Created by CC on 16/3/10.
//  Copyright © 2016年 CC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCHTTPManager.h"

@class AFHTTPRequestOperationManager;

@interface CCHTTPUpDownLoad : NSObject

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
       manager:(AFHTTPRequestOperationManager *)manager
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
