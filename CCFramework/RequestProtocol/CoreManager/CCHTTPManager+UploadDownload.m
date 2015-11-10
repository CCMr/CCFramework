//
//  CCHTTPManager+UploadDownload.m
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
#import "CCHTTPManager+Addition.h"
#import "AFNetworking.h"
#import "NSDate+BNSDate.h"
#import "CCResponseObject.h"

@implementation CCHTTPManager (UploadDownload)

/**
 *  @author CC, 15-08-19
 *
 *  @brief  下载文件
 *
 *  @param requestURLString 请求文件地址
 *  @param block            完成回调
 *  @param errorBlock       请求失败回调
 *  @param progressBlock    下载进度回调
 *
 *  @since <#1.0#>
 */
+ (void)NetRequestDownloadWithRequestURL:(NSString *)requestURLString
                      WithUploadFileName:(NSString *)fileName
                    WithReturnValeuBlock:(RequestDownloadBacktrack)blockTrack
                      WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                       WithProgressBlock:(RequestProgressBacktrack)progressBlock
{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //检查本地文件是否已存在
    NSString *fileNamePath = [NSString
                              stringWithFormat:@"%@/%@", @"用户名", [self filePath:fileName]];
    
    if ([fileManager fileExistsAtPath:fileNamePath]) {
        NSData *data = [NSData dataWithContentsOfFile:fileNamePath];
        blockTrack(data,nil);
    } else {
        
        //获取缓存的长度
        long long cacheLength = [self cacheFileWithPath:fileNamePath];
        
        //获取请求
        NSMutableURLRequest *request =
        [self requestWithUrl:requestURLString Range:cacheLength];
        
        AFHTTPRequestOperation *requestOperation =
        [[AFHTTPRequestOperation alloc] initWithRequest:request];
        requestOperation.userInfo = @{ @"filePath" : fileNamePath };
        
        [requestOperation
         setOutputStream:[NSOutputStream outputStreamToFileAtPath:fileNamePath append:NO]];
						  
        //处理流
        [self readCacheToOutStreamWithPath:requestOperation Path:fileNamePath];
        [requestOperation addObserver:^(NSString *keyPath, id object, NSDictionary *change, void *context) {
            AFHTTPRequestOperation *requestOperation = object;
            //暂停状态
            if ([keyPath isEqualToString:@"isPaused"] && [[change objectForKey:@"new"] intValue] == 1) {
                //缓存路径
//                NSString* cachePath = [requestOperation.userInfo objectForKey:@"filePath"];
                
//                long long cacheLength = [[self class] cacheFileWithPath:cachePath];
                //暂停读取data 从文件中获取到NSNumber
//                long long cacheLength = [[requestOperation.outputStream propertyForKey:NSStreamFileCurrentOffsetKey] unsignedLongLongValue];
                [requestOperation setValue:@"0" forKey:@"totalBytesRead"];
                
                //重组进度block
                [requestOperation setDownloadProgressBlock:progressBlock];
            }
        } forKeyPath:@"isPaused" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        
        [requestOperation setDownloadProgressBlock:progressBlock];
        
        //获取成功回调块
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            blockTrack(operation.responseData,nil);
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            errorBlock(error);
        }];
        [requestOperation start];
    }
}

/**
 *  @author CC, 15-08-19
 *
 *  @brief  上传文件(表单方式提交)
 *
 *  @param requestURLString     上传文件服务器地址
 *  @param fileName             上传文件路径
 *  @param fileType             上传文件类型
 *  @param serviceReceivingName 服务器接收名称
 *  @param block                完成回调
 *  @param errorBlock           错误回调
 *  @param progressBlock        进度回调
 *
 *  @since 1.0
 */
+ (void)NetRequestUploadFormWithRequestURL:(NSString *)requestURLString
                        WithUploadFilePath:(NSString *)filePath
                                  FileType:(CCUploadFormFileType)fileType
                      ServiceReceivingName:(NSString *)serviceReceivingName
                      WithReturnValeuBlock:(RequestBacktrack)blockTrack
                        WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                         WithProgressBlock:(RequestProgressBacktrack)progressBlock
{
    [self NetRequestUploadFormWithRequestURL:requestURLString
                         WithUploadFileImage:[UIImage imageWithContentsOfFile:filePath]
                                    FileType:fileType
                        ServiceReceivingName:serviceReceivingName
                        WithReturnValeuBlock:blockTrack
                          WithErrorCodeBlock:errorBlock
                           WithProgressBlock:progressBlock];
}

/**
 *  @author CC, 2015-10-12
 *
 *  @brief  上传文件(表单方式提交)
 *
 *  @param requestURLString     上传文件服务器地址
 *  @param fileImage            上传文件
 *  @param fileType             上传文件类型
 *  @param serviceReceivingName 服务器接收名称
 *  @param block                完成回调
 *  @param errorBlock           错误回调
 *  @param progressBlock        进度回调
 */
+ (void)NetRequestUploadFormWithRequestURL:(NSString *)requestURLString
                       WithUploadFileImage:(UIImage *)fileImage
                                  FileType:(CCUploadFormFileType)fileType
                      ServiceReceivingName:(NSString *)serviceReceivingName
                      WithReturnValeuBlock:(RequestBacktrack)blockTrack
                        WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                         WithProgressBlock:(RequestProgressBacktrack)progressBlock
{
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperationManager manager] POST:requestURLString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSData *postData;
        NSString *postFileType;
        NSString *postFileName;
        NSString *postFileNameType;
        switch (fileType) {
            case CCUploadFormFileTypeImageJpeg:
                postData = UIImageJPEGRepresentation(fileImage, 1);
                postFileType = @"image/jpeg";
                postFileNameType = @"jpeg";
                break;
                
            case CCUploadFormFileTypeImagePNG:
                postData = UIImagePNGRepresentation(fileImage);
                postFileType = @"image/png";
                postFileNameType = @"png";
                break;
                
            default:
                break;
        }
        //上传图片保存名称与类型
        postFileName = [NSString stringWithFormat:@"%@.%@", [[NSDate date] toStringFormat:@"yyyyMMddHHmmssSSS"], postFileNameType];
        
        // 上传图片，以文件流的格式
        [formData appendPartWithFileData:postData
                                    name:serviceReceivingName
                                fileName:postFileName
                                mimeType:postFileType];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        blockTrack(responseObject,nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        errorBlock(error);
    }];
    
    [requestOperation start];
}

/**
 *  @author CC, 15-08-19
 *
 *  @brief  上传文件
 *
 *  @param requestURLString 上传文件服务器地址
 *  @param fileName         上传文件径路
 *  @param block            完成回调
 *  @param errorBlock       错误回调
 *  @param progressBlock    进度回调
 *
 *  @since 1.0
 */
+ (void)NetRequestUploadFormWithRequestURL:(NSString *)requestURLString
                        WithUploadFilePath:(NSString *)filePath
                      WithReturnValeuBlock:(RequestBacktrack)blockTrack
                        WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                         WithProgressBlock:
(NSProgress *__autoreleasing *)progressBlock
{
    AFURLSessionManager *sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    //添加请求接口
    NSURLRequest *request =
    [NSURLRequest requestWithURL:[NSURL URLWithString:requestURLString]];
    
    //添加上传的文件
    NSURL *postFilePath = [NSURL fileURLWithPath:filePath];
    
    //发送上传请求
    NSURLSessionUploadTask *uploadTask = [sessionManager uploadTaskWithRequest:request fromFile:postFilePath progress:progressBlock completionHandler:^(NSURLResponse *response, id responseObject,
                                                                                                                                                        NSError *error) {
        if (error) { //请求失败
            errorBlock(error);
        } else { //请求成功
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            
            CCNSLogger(@"%@", dic);
            
            CCResponseObject *entity = [[CCResponseObject alloc] initWithDict:dic];
            blockTrack(entity,nil);
            
            blockTrack(responseObject,nil);
        }
    }];
    
    //开始上传
    [uploadTask resume];
}

/**
 *  @author CC, 15-08-19
 *
 *  @brief  获取文件保存路径
 *
 *  @param fileName 文件名
 *
 *  @return 返回文件路径
 *
 *  @since 1.0
 */
+ (NSString *)filePath:(NSString *)fileName
{
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cachePaths objectAtIndex:0];
    return [cachePath stringByAppendingPathComponent:fileName];
}

/**
 *  @author CC, 15-08-19
 *
 *  @brief  获取本地缓存的字节
 *
 *  @param path 本地缓存路径
 *
 *  @return 缓存字节数
 *
 *  @since 1.0
 */
+ (long long)cacheFileWithPath:(NSString *)path
{
    NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:path];
    NSData *contentData = [fh readDataToEndOfFile];
    return contentData ? contentData.length : 0;
}

/**
 *  @author CC, 15-08-19
 *
 *  @brief  获取请求
 *
 *  @param url    <#url description#>
 *  @param length <#length description#>
 *
 *  @return <#return value description#>
 *
 *  @since <#1.0#>
 */
+ (NSMutableURLRequest *)requestWithUrl:(id)url Range:(long long)length
{
    NSURL *requestUrl = [url isKindOfClass:[NSURL class]] ? url : [NSURL URLWithString:url];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestUrl
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:5 * 60];
    
    if (length)
        [request setValue:[NSString stringWithFormat:@"bytes=%lld-", length]
       forHTTPHeaderField:@"Range"];
    
    //    NSLog(@"request.head = %@",request.allHTTPHeaderFields);
    
    return request;
}

/**
 *  @author CC, 15-08-19
 *
 *  @brief  读取本地缓存入流
 *
 *  @param path 缓存路径
 *
 *  @since 1.0
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
