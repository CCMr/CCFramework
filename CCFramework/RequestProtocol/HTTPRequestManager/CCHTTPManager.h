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

#import <Foundation/Foundation.h>
#import "Config.h"
#import "EnumConfig.h"

@interface CCHTTPManager : NSObject

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
- (void) NetRequestGETWithRequestURL: (NSString *) requestURLString
                       WithParameter: (NSDictionary *) parameter
                WithReturnValeuBlock: (RequestComplete) block
                  WithErrorCodeBlock: (ErrorCodeBlock) errorBlock
                    WithFailureBlock: (FailureBlock) failureBlock;


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
- (void) NetRequestPOSTWithRequestURL: (NSString *) requestURLString
                        WithParameter: (NSDictionary *) parameter
                 WithReturnValeuBlock: (RequestComplete) block
                   WithErrorCodeBlock: (ErrorCodeBlock) errorBlock
                     WithFailureBlock: (FailureBlock) failureBlock;


#pragma mark - 上传下载
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
- (void) NetRequestDownloadWithRequestURL: (NSString *) requestURLString
                       WithUploadFileName: (NSString *) fileName
                     WithReturnValeuBlock: (RequestComplete) block
                       WithErrorCodeBlock: (ErrorCodeBlock) errorBlock
                        WithProgressBlock: (ProgressBlock) progressBlock;

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
- (void) NetRequestUploadFormWithRequestURL: (NSString *) requestURLString
                         WithUploadFilePath: (NSString *) filePath
                                   FileType: (CCUploadFormFileType)fileType
                       WithReturnValeuBlock: (RequestComplete) block
                         WithErrorCodeBlock: (ErrorCodeBlock) errorBlock
                          WithProgressBlock: (ProgressBlock) progressBlock;

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
- (void) NetRequestUploadFormWithRequestURL: (NSString *) requestURLString
                         WithUploadFilePath: (NSString *) filePath
                       WithReturnValeuBlock: (RequestComplete) block
                         WithErrorCodeBlock: (ErrorCodeBlock) errorBlock
                          WithProgressBlock: (NSProgress * __autoreleasing *) progressBlock;

@end
