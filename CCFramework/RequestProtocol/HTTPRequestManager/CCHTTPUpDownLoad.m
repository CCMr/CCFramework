//
//  CCHTTPUpDownLoad.m
//  CCFramework
//
//  Created by CC on 16/3/10.
//  Copyright © 2016年 CC. All rights reserved.
//

#import "CCHTTPUpDownLoad.h"
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "NSString+Additions.h"
#import "HttpFileConfig.h"

@implementation CCHTTPUpDownLoad

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
       failure:(requestFailureBlock)failure
{
    if (![CCHTTPManager requestBeforeCheckNetWork]) {
        failure([NSError errorWithDomain:@"Error. Count not recover network reachability flags" code:kCFURLErrorNotConnectedToInternet userInfo:nil]);
        return;
    }
    
    AFHTTPRequestOperation *requestOperation = [manager POST:requestURLString parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
        [formData appendPartWithFileData:fileConfig.fileData name:fileConfig.name fileName:fileConfig.fileName mimeType:fileConfig.mimeType];
    } success:^(AFHTTPRequestOperation *_Nonnull operation, id _Nonnull responseObject) {
        if (success)
            success(nil);
    } failure:^(AFHTTPRequestOperation *_Nonnull operation, NSError *_Nonnull error) {
        if (failure)
            failure(error);
    }];
    [requestOperation start];
}

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
       failure:(requestFailureBlock)failure
{
    if (![CCHTTPManager requestBeforeCheckNetWork]) {
        failure([NSError errorWithDomain:@"Error. Count not recover network reachability flags" code:kCFURLErrorNotConnectedToInternet userInfo:nil]);
        return;
    }
    
    AFURLSessionManager *sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestURLString]];
    NSURL *postFilePath = [NSURL fileURLWithPath:filePath];
    
    NSURLSessionUploadTask *uploadTask = [sessionManager uploadTaskWithRequest:request fromFile:postFilePath progress:progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error)
            failure(error);
        else
            success(responseObject);
    }];
    
    [uploadTask resume];
}

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
         failure:(requestFailureBlock)failure
{
    if (![CCHTTPManager requestBeforeCheckNetWork]) {
        failure([NSError errorWithDomain:@"Error. Count not recover network reachability flags" code:kCFURLErrorNotConnectedToInternet userInfo:nil]);
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fileNamePath = [self filePath:fileName];
    
    if ([fileManager fileExistsAtPath:fileNamePath]) {
        success([NSData dataWithContentsOfFile:fileNamePath], nil);
    } else {
        //获取缓存的长度
        long long cacheLength = [self cacheFileWithPath:fileNamePath];
        //获取请求
        NSMutableURLRequest *request = [self requestWithUrl:requestURLString Range:cacheLength];
        
        AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        requestOperation.userInfo = @{ @"filePath" : fileNamePath };
        
        [requestOperation setOutputStream:[NSOutputStream outputStreamToFileAtPath:fileNamePath append:NO]];
        
        //处理流
        [self readCacheToOutStreamWithPath:requestOperation Path:fileNamePath];
        [requestOperation addObserver:^(NSString *keyPath, id object, NSDictionary *change, void *context) {
            AFHTTPRequestOperation *requestOperation = object;
            //暂停状态
            if ([keyPath isEqualToString:@"isPaused"] && [[change objectForKey:@"new"] intValue] == 1) {
                //缓存路径
                NSString* cachePath = [requestOperation.userInfo objectForKey:@"filePath"];
                
                long long cacheLength = [self cacheFileWithPath:cachePath];
                [requestOperation setValue:@(cacheLength) forKey:@"totalBytesRead"];
                
                //重组进度block
                [requestOperation setDownloadProgressBlock:downloadProgressBlock];
            }
        } forKeyPath:@"isPaused"
                              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                              context:nil];
        
        [requestOperation setDownloadProgressBlock:downloadProgressBlock];
        
        //获取成功回调块
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            success(operation.responseData,nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (failure)
                failure(error);
        }];
        [requestOperation start];
    }
}

/**
 *  @author CC, 16-03-10
 *  
 *  @brief 下载文件缓存
 *
 *  @param requestURLString 请求地址
 *  @param success          完成回调
 */
+ (void)Download:(NSString *)requestURLString
         success:(requestDownloadsuccess)success
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestURLString]];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory 
                                                                              inDomain:NSUserDomainMask 
                                                                     appropriateForURL:nil 
                                                                                create:NO 
                                                                                 error:nil];
        
        NSString *expand = [[response suggestedFilename] componentsSeparatedByString:@"."].lastObject;
        NSURL *downloadURL = [documentsDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",[NSString UUID],expand]];
        
        return downloadURL;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        success(filePath.path,error);
    }];
    [downloadTask resume];
}

/**
 *  @author CC, 16-03-10
 *  
 *  @brief 缓存路径
 *
 *  @param fileName 缓存文件名
 */
+ (NSString *)filePath:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *audioDir = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Download"];
    BOOL isDir = YES;
    if ([[NSFileManager defaultManager] fileExistsAtPath:audioDir isDirectory:&isDir] == NO) {
        BOOL isSuccess = [[NSFileManager defaultManager] createDirectoryAtPath:audioDir withIntermediateDirectories:YES attributes:nil error:nil];
        if (!isSuccess) {
            NSLog(@"创建Download目录失败T_T");
        }
    }
    return [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"Download"] stringByAppendingPathComponent:fileName];
}

/**
 *  @author CC, 16-03-10
 *  
 *  @brief 获取本地缓存字节
 *
 *  @param path 缓存路径
 */
+ (long long)cacheFileWithPath:(NSString *)path
{
    NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:path];
    NSData *contentData = [fh readDataToEndOfFile];
    return contentData ? contentData.length : 0;
}

/**
 *  @author CC, 16-03-10
 *  
 *  @brief 获取请求
 *
 *  @param url    路径地址
 *  @param length 读取位置
 */
+ (NSMutableURLRequest *)requestWithUrl:(id)url Range:(long long)length
{
    NSURL *requestUrl = [url isKindOfClass:[NSURL class]] ? url : [NSURL URLWithString:url];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestUrl
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:5 * 60];
    
    if (length)
        [request setValue:[NSString stringWithFormat:@"bytes=%lld-", length] forHTTPHeaderField:@"Range"];
    
    return request;
}

/**
 *  @author CC, 16-03-10
 *  
 *  @brief 读取本地缓存入流
 *
 *  @param requestOperation requestOperation
 *  @param path             缓存路径
 */
+ (void)readCacheToOutStreamWithPath:(AFHTTPRequestOperation *)requestOperation
                                Path:(NSString *)path
{
    NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:path];
    NSData *currentData = [fh readDataToEndOfFile];
    
    if (currentData.length) {
        //打开流，写入data ， 未打卡查看 streamCode = NSStreamStatusNotOpen
        [requestOperation.outputStream open];
        
        NSInteger bytesWritten;
        NSInteger bytesWrittenSoFar;
        
        NSInteger dataLength = [currentData length];
        const uint8_t *dataBytes = [currentData bytes];
        
        bytesWrittenSoFar = 0;
        do {
            bytesWritten = [requestOperation.outputStream
                            write:&dataBytes[bytesWrittenSoFar]
                            maxLength:dataLength - bytesWrittenSoFar];
            assert(bytesWritten != 0);
            if (bytesWritten == -1) {
                break;
            } else {
                bytesWrittenSoFar += bytesWritten;
            }
        } while (bytesWrittenSoFar != dataLength);
    }
}

@end
