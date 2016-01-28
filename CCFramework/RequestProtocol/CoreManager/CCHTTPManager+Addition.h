//
//  CCHTTPManager+Addition.h
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

#import "CCHTTPManager.h"
#import "CCNSLog.h"

#define errorAnalysis(code) (code >= 300 || code <= 311) ? YES : NO

/**
 *  @author C C, 15-08-18
 *
 *  @brief  上传文件类型
 *
 *  @since 1.0
 */
typedef NS_ENUM(NSInteger, CCUploadFormFileType) {
    /** 图片Jpeg */
    CCUploadFormFileTypeImageJpeg,
    /** 图片PNG */
    CCUploadFormFileTypeImagePNG,
};


@interface CCHTTPManager (Addition)

@end

#pragma mark - GET请求方式
@interface CCHTTPManager (GET)

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  GET请求方式
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param block            完成回调
 *  @param errorBlock       请求失败回调
 *  @param failureBlock     网络错误回调
 *
 *  @since 1.0
 */
- (void)NetRequestGETWithRequestURL:(NSString *)requestURLString
                      WithParameter:(NSDictionary *)parameter
               WithReturnValeuBlock:(RequestBacktrack)blockTrack
                 WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                   WithFailureBlock:(FailureBlock)failureBlock;

/**
 *  @author CC, 2015-12-15
 *  
 *  @brief  GET请求方式
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param userInfo         字典接收
 *  @param block            完成回调
 *  @param errorBlock       请求失败回调
 *  @param failureBlock     网络错误回调
 */
- (void)NetRequestGETWithRequestURL:(NSString *)requestURLString
                      WithParameter:(NSDictionary *)parameter 
                       WithUserInfo:(NSDictionary *)userInfo
               WithReturnValeuBlock:(RequestBacktrack)blockTrack
                 WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                   WithFailureBlock:(FailureBlock)failureBlock;

/**
 *  @author CC, 2015-10-22
 *
 *  @brief  GET请求方式
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param userInfo         字典接收
 *  @param block            完成回调
 *  @param errorBlock       请求失败回调
 *  @param failureBlock     网络错误回调
 *  @param completionBlock  请求完成回调函数
 */
- (void)NetRequestGETWithRequestURL:(NSString *)requestURLString
                      WithParameter:(NSDictionary *)parameter
                       WithUserInfo:(NSDictionary *)userInfo
               WithReturnValeuBlock:(RequestBacktrack)blockTrack
                 WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                   WithFailureBlock:(FailureBlock)failureBlock
                     WithCompletion:(RequestCompletionBacktrack)completionBlock;

@end

#pragma mark - POST请求方式
@interface CCHTTPManager (PSOT)

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  POST请求方式
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param block            完成回调
 *  @param errorBlock       请求失败回调
 *  @param failureBlock     网络错误回调
 *
 *  @since 1.0
 */
- (void)NetRequestPOSTWithRequestURL:(NSString *)requestURLString
                       WithParameter:(NSDictionary *)parameter
                WithReturnValeuBlock:(RequestBacktrack)blockTrack
                  WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                    WithFailureBlock:(FailureBlock)failureBlock;

/**
 *  @author CC, 2015-12-15
 *  
 *  @brief  POST请求方式
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param userInfo         字典接收
 *  @param blockTrack       完成回调
 *  @param errorBlock       请求失败回调
 *  @param failureBlock     网络错误回调
 */
- (void)NetRequestPOSTWithRequestURL:(NSString *)requestURLString
                       WithParameter:(NSDictionary *)parameter
                        WithUserInfo:(NSDictionary *)userInfo
                WithReturnValeuBlock:(RequestBacktrack)blockTrack
                  WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                    WithFailureBlock:(FailureBlock)failureBlock;

/**
 *  @author CC, 2015-10-22
 *
 *  @brief  POST请求方式
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param userInfo         字典接收
 *  @param block            请求失败回调
 *  @param errorBlock       请求失败回调
 *  @param failureBlock     网络错误回调
 *  @param completionBlock  请求完成回调函数
 */
- (void)NetRequestPOSTWithRequestURL:(NSString *)requestURLString
                       WithParameter:(NSDictionary *)parameter
                        WithUserInfo:(NSDictionary *)userInfo
                WithReturnValeuBlock:(RequestBacktrack)blockTrack
                  WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                    WithFailureBlock:(FailureBlock)failureBlock
                      WithCompletion:(RequestCompletionBacktrack)completionBlock;

@end

#pragma mark - DELETE请求方式
@interface CCHTTPManager (DELETE)

/**
 *  @author CC, 2015-10-08
 *
 *  @brief  DELETE请求方式
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param block            完成回调
 *  @param errorBlock       请求失败回调
 *  @param failureBlock     网络错误回调
 */
- (void)NetRequestDELETEWithRequestURL:(NSString *)requestURLString
                         WithParameter:(NSDictionary *)parameter
                  WithReturnValeuBlock:(RequestBacktrack)blockTrack
                    WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                      WithFailureBlock:(FailureBlock)failureBlock;

/**
 *  @author CC, 2015-12-15
 *  
 *  @brief  DELETE请求方式
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param userInfo         字典接收
 *  @param block            完成回调
 *  @param errorBlock       请求失败回调
 *  @param failureBlock     网络错误回调
 */
- (void)NetRequestDELETEWithRequestURL:(NSString *)requestURLString
                         WithParameter:(NSDictionary *)parameter 
                          WithUserInfo:(NSDictionary *)userInfo
                  WithReturnValeuBlock:(RequestBacktrack)blockTrack
                    WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                      WithFailureBlock:(FailureBlock)failureBlock;

/**
 *  @author CC, 2015-10-22
 *
 *  @brief  DELETE请求方式
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param userInfo         字典接收
 *  @param block            完成回调
 *  @param errorBlock       请求失败回调
 *  @param failureBlock     网络错误回调
 *  @param completionBlock  请求完成回调函数
 */
- (void)NetRequestDELETEWithRequestURL:(NSString *)requestURLString
                         WithParameter:(NSDictionary *)parameter
                          WithUserInfo:(NSDictionary *)userInfo
                  WithReturnValeuBlock:(RequestBacktrack)blockTrack
                    WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                      WithFailureBlock:(FailureBlock)failureBlock
                        WithCompletion:(RequestCompletionBacktrack)completionBlock;

@end


#pragma mark - HEAD请求方式
@interface CCHTTPManager (HEAD)

/**
 *  @author CC, 2015-10-08
 *
 *  @brief  HEAD请求方式
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param block            完成回调
 *  @param errorBlock       请求失败回调
 *  @param failureBlock     网络错误回调
 */
- (void)NetRequestHEADWithRequestURL:(NSString *)requestURLString
                       WithParameter:(NSDictionary *)parameter
                WithReturnValeuBlock:(RequestBacktrack)blockTrack
                  WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                    WithFailureBlock:(FailureBlock)failureBlock;

/**
 *  @author CC, 2015-12-15
 *  
 *  @brief  HEAD请求方式
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param userInfo         字典接收
 *  @param block            完成回调
 *  @param errorBlock       请求失败回调
 *  @param failureBlock     网络错误回调
 */
- (void)NetRequestHEADWithRequestURL:(NSString *)requestURLString
                       WithParameter:(NSDictionary *)parameter
                        WithUserInfo:(NSDictionary *)userInfo
                WithReturnValeuBlock:(RequestBacktrack)blockTrack
                  WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                    WithFailureBlock:(FailureBlock)failureBlock;

/**
 *  @author CC, 2015-10-22
 *
 *  @brief  HEAD请求方式
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param userInfo         字典接收
 *  @param block            完成回调
 *  @param errorBlock       请求失败回调
 *  @param failureBlock     网络错误回调
 *  @param completionBlock  请求完成回调函数
 */
- (void)NetRequestHEADWithRequestURL:(NSString *)requestURLString
                       WithParameter:(NSDictionary *)parameter
                        WithUserInfo:(NSDictionary *)userInfo
                WithReturnValeuBlock:(RequestBacktrack)blockTrack
                  WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                    WithFailureBlock:(FailureBlock)failureBlock
                      WithCompletion:(RequestCompletionBacktrack)completionBlock;

@end


#pragma mark - PUT请求方式
@interface CCHTTPManager (PUT)

/**
 *  @author CC, 2015-10-08
 *
 *  @brief  PUT请求方式
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param block            完成回调
 *  @param errorBlock       请求失败回调
 *  @param failureBlock     网络错误回调
 */
- (void)NetRequestPUTWithRequestURL:(NSString *)requestURLString
                      WithParameter:(NSDictionary *)parameter
               WithReturnValeuBlock:(RequestBacktrack)blockTrack
                 WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                   WithFailureBlock:(FailureBlock)failureBlock;

/**
 *  @author CC, 2015-12-15
 *  
 *  @brief  PUT请求方式
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param userInfo         字典接收
 *  @param block            完成回调
 *  @param errorBlock       请求失败回调
 *  @param failureBlock     网络错误回调
 */
- (void)NetRequestPUTWithRequestURL:(NSString *)requestURLString
                      WithParameter:(NSDictionary *)parameter 
                       WithUserInfo:(NSDictionary *)userInfo
               WithReturnValeuBlock:(RequestBacktrack)blockTrack
                 WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                   WithFailureBlock:(FailureBlock)failureBlock;

/**
 *  @author CC, 2015-10-22
 *
 *  @brief  PUT请求方式
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param userInfo         字典接收
 *  @param block            完成回调
 *  @param errorBlock       请求失败回调
 *  @param failureBlock     网络错误回调
 *  @param completionBlock  请求完成回调函数
 */
- (void)NetRequestPUTWithRequestURL:(NSString *)requestURLString
                      WithParameter:(NSDictionary *)parameter
                       WithUserInfo:(NSDictionary *)userInfo
               WithReturnValeuBlock:(RequestBacktrack)blockTrack
                 WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                   WithFailureBlock:(FailureBlock)failureBlock
                     WithCompletion:(RequestCompletionBacktrack)completionBlock;

@end

#pragma mark - PATCH请求方式
@interface CCHTTPManager (PATCH)

/**
 *  @author CC, 2015-10-08
 *
 *  @brief  PATCH请求方式
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param block            完成回调
 *  @param errorBlock       请求失败回调
 *  @param failureBlock     网络错误回调
 */
- (void)NetRequestPATCHWithRequestURL:(NSString *)requestURLString
                        WithParameter:(NSDictionary *)parameter
                 WithReturnValeuBlock:(RequestBacktrack)blockTrack
                   WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                     WithFailureBlock:(FailureBlock)failureBlock;

/**
 *  @author CC, 2015-12-15
 *  
 *  @brief  PATCH请求方式
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param userInfo         字典接收
 *  @param block            完成回调
 *  @param errorBlock       请求失败回调
 *  @param failureBlock     网络错误回调
 */
- (void)NetRequestPATCHWithRequestURL:(NSString *)requestURLString
                        WithParameter:(NSDictionary *)parameter
                         WithUserInfo:(NSDictionary *)userInfo
                 WithReturnValeuBlock:(RequestBacktrack)blockTrack
                   WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                     WithFailureBlock:(FailureBlock)failureBlock;

/**
 *  @author CC, 2015-10-22
 *
 *  @brief  PATCH请求方式
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param userInfo         字典接收
 *  @param block            完成回调
 *  @param errorBlock       请求失败回调
 *  @param failureBlock     网络错误回调
 *  @param completionBlock  请求完成回调函数
 */
- (void)NetRequestPATCHWithRequestURL:(NSString *)requestURLString
                        WithParameter:(NSDictionary *)parameter
                         WithUserInfo:(NSDictionary *)userInfo
                 WithReturnValeuBlock:(RequestBacktrack)blockTrack
                   WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                     WithFailureBlock:(FailureBlock)failureBlock
                       WithCompletion:(RequestCompletionBacktrack)completionBlock;


@end

#pragma mark - 上传下载
@interface CCHTTPManager (UploadDownload)

/**
 *  @author CC, 2015-12-02
 *  
 *  @brief  下载文件缓存
 *
 *  @param requestURLString 下载路径
 *  @param blockTrack       完成回调
 */
- (void)NetRequestDownloadWithRequestURL:(NSString *)requestURLString
                    WithRequestBacktrack:(CCRequestBacktrack)blockTrack;

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
- (void)NetRequestDownloadWithRequestURL:(NSString *)requestURLString
                      WithUploadFileName:(NSString *)fileName
                    WithReturnValeuBlock:(RequestDownloadBacktrack)blockTrack
                      WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                       WithProgressBlock:(RequestProgressBacktrack)progressBlock;

/**
 *  @author CC, 15-08-19
 *
 *  @brief  上传文件(表单方式提交)
 *
 *  @param requestURLString 上传文件服务器地址
 *  @param fileName         上传文件路径
 *  @param fileType         上传文件类型
 *  @param block            完成回调
 *  @param errorBlock       错误回调
 *  @param progressBlock    进度回调
 *
 *  @since 1.0
 */
- (void)NetRequestUploadFormWithRequestURL:(NSString *)requestURLString
                        WithUploadFilePath:(NSString *)filePath
                                  FileType:(CCUploadFormFileType)fileType
                      ServiceReceivingName:(NSString *)serviceReceivingName
                      WithReturnValeuBlock:(RequestBacktrack)blockTrack
                        WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                         WithProgressBlock:(RequestProgressBacktrack)progressBlock;

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
- (void)NetRequestUploadFormWithRequestURL:(NSString*)requestURLString
                       WithUploadFileImage:(UIImage*)fileImage
                                  FileType:(CCUploadFormFileType)fileType
                      ServiceReceivingName:(NSString*)serviceReceivingName
                      WithReturnValeuBlock:(RequestBacktrack)blockTrack
                        WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                         WithProgressBlock:(RequestProgressBacktrack)progressBlock;

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
- (void)NetRequestUploadFormWithRequestURL:(NSString*)requestURLString
                        WithUploadFilePath:(NSString*)filePath
                      WithReturnValeuBlock:(RequestBacktrack)blockTrack
                        WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                         WithProgressBlock:(NSProgress* __autoreleasing*)progressBlock;


@end
