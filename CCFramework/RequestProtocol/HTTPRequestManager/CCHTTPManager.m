//
//  HTTPRequestManager.m
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
#import <objc/runtime.h>
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "NSDate+BNSDate.h"

static CCHTTPManager* _sharedlnstance = nil;
@implementation CCHTTPManager

/**
 *  @author CC, 15-08-19
 *
 *  @brief  SET委托事件
 *
 *  @param progressBlock 委托Block函数
 *  @param key           对应key
 *
 *  @since 1.0
 */
- (void)setProgressBlock:(ProgressBlock)progressBlock
                     Key:(NSString*)key
{
    objc_setAssociatedObject(self, (__bridge void*)key, progressBlock, OBJC_ASSOCIATION_COPY);
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
- (ProgressBlock)progressBlock:(NSString*)key
{
    return (ProgressBlock)objc_getAssociatedObject(self, (__bridge void*)key);
}

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  单列模式
 *
 *  @return 返回当前对象
 *
 *  @since 1.0
 */
+ (id)sharedlnstance
{
    @synchronized(self)
    {
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
+ (BOOL)netWorkReachabilityWithURLString:(NSString*)strUrl
{
    __block BOOL netState = NO;

    NSURL* baseURL = [NSURL URLWithString:strUrl];

    AFHTTPRequestOperationManager* manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];

    NSOperationQueue* operationQueue = manager.operationQueue;

    [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
        case AFNetworkReachabilityStatusReachableViaWWAN:
        case AFNetworkReachabilityStatusReachableViaWiFi:
            [operationQueue setSuspended:NO];
            netState = YES;
            break;
        case AFNetworkReachabilityStatusNotReachable:
            netState = NO;
        default:
            [operationQueue setSuspended:YES];
            break;
        }
    }];

    [manager.reachabilityManager startMonitoring];

    return netState;
}

#pragma mark - error分类
/**
 *  @author CC, 2015-10-27
 *
 *  @brief  错误分析
 *
 *  @param code 错误代码
 *
 *  @return 返回是否是故障
 */
- (BOOL)errorAnalysis:(NSInteger)code
{
    BOOL Isfailure = YES;
    if (code >= 300 || code <= 311)
        Isfailure = NO;

    return Isfailure;
}

#pragma mark - 请求方式

#pragma mark - GET请求方式
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
- (void)NetRequestGETWithRequestURL:(NSString*)requestURLString
                      WithParameter:(NSDictionary*)parameter
               WithReturnValeuBlock:(RequestComplete)block
                 WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                   WithFailureBlock:(FailureBlock)failureBlock
{
    [self NetRequestGETWithRequestURL:requestURLString
                        WithParameter:parameter
                         WithUserInfo:nil
                 WithReturnValeuBlock:block
                   WithErrorCodeBlock:errorBlock
                     WithFailureBlock:failureBlock
                       WithCompletion:nil];
}

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
- (void)NetRequestGETWithRequestURL:(NSString*)requestURLString
                      WithParameter:(NSDictionary*)parameter
                       WithUserInfo:(NSDictionary*)userInfo
               WithReturnValeuBlock:(RequestComplete)block
                 WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                   WithFailureBlock:(FailureBlock)failureBlock
                     WithCompletion:(CompletionCallback)completionBlock
{

    AFHTTPRequestOperationManager* manager = [[AFHTTPRequestOperationManager alloc] init];

    AFHTTPRequestOperation* requestOperation = [manager GET:requestURLString
        parameters:parameter
        success:^(AFHTTPRequestOperation* operation, id responseObject) {
            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"%@", dic);
            block(dic);

            if (operation.userInfo && completionBlock)
                completionBlock(dic, operation.userInfo);

        }
        failure:^(AFHTTPRequestOperation* operation, NSError* error) {
            [self errorAnalysis:error.code] ? failureBlock(error) : errorBlock(error);
        }];

    if (_userInfo || userInfo)
        requestOperation.userInfo = userInfo ? userInfo : _userInfo;

    requestOperation.responseSerializer = [AFHTTPResponseSerializer serializer];

    [requestOperation start];
}

#pragma mark - POST请求方式
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
- (void)NetRequestPOSTWithRequestURL:(NSString*)requestURLString
                       WithParameter:(NSDictionary*)parameter
                WithReturnValeuBlock:(RequestComplete)block
                  WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                    WithFailureBlock:(FailureBlock)failureBlock
{
    [self NetRequestPOSTWithRequestURL:requestURLString
                         WithParameter:parameter
                          WithUserInfo:nil
                  WithReturnValeuBlock:block
                    WithErrorCodeBlock:errorBlock
                      WithFailureBlock:failureBlock
                        WithCompletion:nil];
}

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
- (void)NetRequestPOSTWithRequestURL:(NSString*)requestURLString
                       WithParameter:(NSDictionary*)parameter
                        WithUserInfo:(NSDictionary*)userInfo
                WithReturnValeuBlock:(RequestComplete)block
                  WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                    WithFailureBlock:(FailureBlock)failureBlock
                      WithCompletion:(CompletionCallback)completionBlock
{
    AFHTTPRequestOperationManager* manager = [[AFHTTPRequestOperationManager alloc] init];
    AFHTTPRequestOperation* requestOperation = [manager POST:requestURLString
        parameters:parameter
        success:^(AFHTTPRequestOperation* operation, id responseObject) {
            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"%@", dic);
            block(dic);

            if (operation.userInfo && completionBlock)
                completionBlock(dic, operation.userInfo);

        }
        failure:^(AFHTTPRequestOperation* operation, NSError* error) {
            [self errorAnalysis:error.code] ? failureBlock(error) : errorBlock(error);
        }];

    if (_userInfo || userInfo)
        requestOperation.userInfo = userInfo ? userInfo : _userInfo;

    requestOperation.responseSerializer = [AFHTTPResponseSerializer serializer];

    [requestOperation start];
}

#pragma mark DELETE请求方式
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
- (void)NetRequestDELETEWithRequestURL:(NSString*)requestURLString
                         WithParameter:(NSDictionary*)parameter
                  WithReturnValeuBlock:(RequestComplete)block
                    WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                      WithFailureBlock:(FailureBlock)failureBlock
{
    [self NetRequestDELETEWithRequestURL:requestURLString
                           WithParameter:parameter
                            WithUserInfo:nil
                    WithReturnValeuBlock:block
                      WithErrorCodeBlock:errorBlock
                        WithFailureBlock:failureBlock
                          WithCompletion:nil];
}

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
- (void)NetRequestDELETEWithRequestURL:(NSString*)requestURLString
                         WithParameter:(NSDictionary*)parameter
                          WithUserInfo:(NSDictionary*)userInfo
                  WithReturnValeuBlock:(RequestComplete)block
                    WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                      WithFailureBlock:(FailureBlock)failureBlock
                        WithCompletion:(CompletionCallback)completionBlock
{
    AFHTTPRequestOperationManager* manager = [[AFHTTPRequestOperationManager alloc] init];
    AFHTTPRequestOperation* requestOperation = [manager DELETE:requestURLString
        parameters:parameter
        success:^(AFHTTPRequestOperation* operation, id responseObject) {
            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"%@", dic);
            block(dic);

            if (operation.userInfo && completionBlock)
                completionBlock(dic, operation.userInfo);

        }
        failure:^(AFHTTPRequestOperation* operation, NSError* error) {
            [self errorAnalysis:error.code] ? failureBlock(error) : errorBlock(error);
        }];

    if (_userInfo || userInfo)
        requestOperation.userInfo = userInfo ? userInfo : _userInfo;

    requestOperation.responseSerializer = [AFHTTPResponseSerializer serializer];

    [requestOperation start];
}

#pragma mark HEAD请求方式
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
- (void)NetRequestHEADWithRequestURL:(NSString*)requestURLString
                       WithParameter:(NSDictionary*)parameter
                WithReturnValeuBlock:(RequestComplete)block
                  WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                    WithFailureBlock:(FailureBlock)failureBlock
{
    [self NetRequestHEADWithRequestURL:requestURLString
                         WithParameter:parameter
                          WithUserInfo:nil
                  WithReturnValeuBlock:block
                    WithErrorCodeBlock:errorBlock
                      WithFailureBlock:failureBlock
                        WithCompletion:nil];
}

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
- (void)NetRequestHEADWithRequestURL:(NSString*)requestURLString
                       WithParameter:(NSDictionary*)parameter
                        WithUserInfo:(NSDictionary*)userInfo
                WithReturnValeuBlock:(RequestComplete)block
                  WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                    WithFailureBlock:(FailureBlock)failureBlock
                      WithCompletion:(CompletionCallback)completionBlock
{
    AFHTTPRequestOperationManager* manager = [[AFHTTPRequestOperationManager alloc] init];
    AFHTTPRequestOperation* requestOperation = [manager HEAD:requestURLString
        parameters:parameter
        success:^(AFHTTPRequestOperation* operation) {

            if (operation.userInfo && completionBlock)
                completionBlock(nil, operation.userInfo);

        }
        failure:^(AFHTTPRequestOperation* operation, NSError* error) {
            [self errorAnalysis:error.code] ? failureBlock(error) : errorBlock(error);
        }];

    if (_userInfo || userInfo)
        requestOperation.userInfo = userInfo ? userInfo : _userInfo;

    requestOperation.responseSerializer = [AFHTTPResponseSerializer serializer];

    [requestOperation start];
}

#pragma mark PUT请求方式
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
- (void)NetRequestPUTWithRequestURL:(NSString*)requestURLString
                      WithParameter:(NSDictionary*)parameter
               WithReturnValeuBlock:(RequestComplete)block
                 WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                   WithFailureBlock:(FailureBlock)failureBlock
{
    [self NetRequestPUTWithRequestURL:requestURLString
                        WithParameter:parameter
                         WithUserInfo:nil
                 WithReturnValeuBlock:block
                   WithErrorCodeBlock:errorBlock
                     WithFailureBlock:failureBlock
                       WithCompletion:nil];
}

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
- (void)NetRequestPUTWithRequestURL:(NSString*)requestURLString
                      WithParameter:(NSDictionary*)parameter
                       WithUserInfo:(NSDictionary*)userInfo
               WithReturnValeuBlock:(RequestComplete)block
                 WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                   WithFailureBlock:(FailureBlock)failureBlock
                     WithCompletion:(CompletionCallback)completionBlock
{
    AFHTTPRequestOperationManager* manager = [[AFHTTPRequestOperationManager alloc] init];
    AFHTTPRequestOperation* requestOperation = [manager PUT:requestURLString
        parameters:parameter
        success:^(AFHTTPRequestOperation* operation, id responseObject) {
            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"%@", dic);
            block(dic);

            if (operation.userInfo && completionBlock)
                completionBlock(dic, operation.userInfo);

        }
        failure:^(AFHTTPRequestOperation* operation, NSError* error) {
            [self errorAnalysis:error.code] ? failureBlock(error) : errorBlock(error);
        }];

    if (_userInfo || userInfo)
        requestOperation.userInfo = userInfo ? userInfo : _userInfo;

    requestOperation.responseSerializer = [AFHTTPResponseSerializer serializer];

    [requestOperation start];
}

#pragma mark PATCH请求方式
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
- (void)NetRequestPATCHWithRequestURL:(NSString*)requestURLString
                        WithParameter:(NSDictionary*)parameter
                 WithReturnValeuBlock:(RequestComplete)block
                   WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                     WithFailureBlock:(FailureBlock)failureBlock
{
    [self NetRequestPATCHWithRequestURL:requestURLString
                          WithParameter:parameter
                           WithUserInfo:nil
                   WithReturnValeuBlock:block
                     WithErrorCodeBlock:errorBlock
                       WithFailureBlock:failureBlock
                         WithCompletion:nil];
}

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
- (void)NetRequestPATCHWithRequestURL:(NSString*)requestURLString
                        WithParameter:(NSDictionary*)parameter
                         WithUserInfo:(NSDictionary*)userInfo
                 WithReturnValeuBlock:(RequestComplete)block
                   WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                     WithFailureBlock:(FailureBlock)failureBlock
                       WithCompletion:(CompletionCallback)completionBlock
{
    AFHTTPRequestOperationManager* manager = [[AFHTTPRequestOperationManager alloc] init];
    AFHTTPRequestOperation* requestOperation = [manager PATCH:requestURLString
        parameters:parameter
        success:^(AFHTTPRequestOperation* operation, id responseObject) {
            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"%@", dic);
            block(dic);

            if (operation.userInfo && completionBlock)
                completionBlock(dic, operation.userInfo);

        }
        failure:^(AFHTTPRequestOperation* operation, NSError* error) {
            [self errorAnalysis:error.code] ? failureBlock(error) : errorBlock(error);
        }];

    if (_userInfo || userInfo)
        requestOperation.userInfo = userInfo ? userInfo : _userInfo;

    requestOperation.responseSerializer = [AFHTTPResponseSerializer serializer];

    [requestOperation start];
}

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
- (void)NetRequestDownloadWithRequestURL:(NSString*)requestURLString
                      WithUploadFileName:(NSString*)fileName
                    WithReturnValeuBlock:(RequestComplete)block
                      WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                       WithProgressBlock:(ProgressBlock)progressBlock
{

    NSFileManager* fileManager = [NSFileManager defaultManager];

    //检查本地文件是否已存在
    NSString* fileNamePath = [NSString stringWithFormat:@"%@/%@", @"用户名", [self filePath:fileName]];

    if ([fileManager fileExistsAtPath:fileNamePath]) {
        NSData* data = [NSData dataWithContentsOfFile:fileNamePath];
        block(data);
    }
    else {

        //获取缓存的长度
        long long cacheLength = [self cacheFileWithPath:fileNamePath];

        //获取请求
        NSMutableURLRequest* request = [self requestWithUrl:requestURLString Range:cacheLength];

        AFHTTPRequestOperation* requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        requestOperation.userInfo = @{ @"filePath" : fileNamePath };

        [requestOperation setOutputStream:[NSOutputStream outputStreamToFileAtPath:fileNamePath append:NO]];

        //处理流
        [self readCacheToOutStreamWithPath:requestOperation Path:fileNamePath];
        [requestOperation addObserver:self forKeyPath:@"isPaused" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];

        //获取进度块
        [self setProgressBlock:progressBlock Key:fileName];

        [requestOperation setDownloadProgressBlock:progressBlock];

        [requestOperation setDownloadProgressBlock:[self NewProgressBlockWithCacheLength:requestOperation CachLength:cacheLength CachePath:fileNamePath]];

        //获取成功回调块
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* operation, id responseObject) {
            block(operation.responseData);
        } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
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
- (void)NetRequestUploadFormWithRequestURL:(NSString*)requestURLString
                        WithUploadFilePath:(NSString*)filePath
                                  FileType:(CCUploadFormFileType)fileType
                      ServiceReceivingName:(NSString*)serviceReceivingName
                      WithReturnValeuBlock:(RequestComplete)block
                        WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                         WithProgressBlock:(ProgressBlock)progressBlock
{
    [self NetRequestUploadFormWithRequestURL:requestURLString WithUploadFileImage:[UIImage imageWithContentsOfFile:filePath] FileType:fileType ServiceReceivingName:serviceReceivingName WithReturnValeuBlock:block WithErrorCodeBlock:errorBlock WithProgressBlock:progressBlock];
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
- (void)NetRequestUploadFormWithRequestURL:(NSString*)requestURLString
                       WithUploadFileImage:(UIImage*)fileImage
                                  FileType:(CCUploadFormFileType)fileType
                      ServiceReceivingName:(NSString*)serviceReceivingName
                      WithReturnValeuBlock:(RequestComplete)block
                        WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                         WithProgressBlock:(ProgressBlock)progressBlock
{
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation* requestOperation = [manager POST:requestURLString
        parameters:nil
        constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            NSData* postData;
            NSString* postFileType;
            NSString* postFileName;
            NSString* postFileNameType;
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
            [formData appendPartWithFileData:postData name:serviceReceivingName fileName:postFileName mimeType:postFileType];
        }
        success:^(AFHTTPRequestOperation* operation, id responseObject) {
            block(responseObject);
        }
        failure:^(AFHTTPRequestOperation* operation, NSError* error) {
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
- (void)NetRequestUploadFormWithRequestURL:(NSString*)requestURLString
                        WithUploadFilePath:(NSString*)filePath
                      WithReturnValeuBlock:(RequestComplete)block
                        WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                         WithProgressBlock:(NSProgress* __autoreleasing*)progressBlock
{
    AFURLSessionManager* sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    //添加请求接口
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestURLString]];

    //添加上传的文件
    NSURL* postFilePath = [NSURL fileURLWithPath:filePath];

    //发送上传请求
    NSURLSessionUploadTask* uploadTask = [sessionManager uploadTaskWithRequest:request
                                                                      fromFile:postFilePath
                                                                      progress:progressBlock
                                                             completionHandler:^(NSURLResponse* response, id responseObject, NSError* error) {
                                                                 if (error) { //请求失败
                                                                     errorBlock(error);
                                                                 }
                                                                 else { //请求成功
                                                                     block(responseObject);
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
- (NSString*)filePath:(NSString*)fileName
{
    NSArray* cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cachePath = [cachePaths objectAtIndex:0];
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
- (long long)cacheFileWithPath:(NSString*)path
{
    NSFileHandle* fh = [NSFileHandle fileHandleForReadingAtPath:path];
    NSData* contentData = [fh readDataToEndOfFile];
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
- (NSMutableURLRequest*)requestWithUrl:(id)url
                                 Range:(long long)length
{
    NSURL* requestUrl = [url isKindOfClass:[NSURL class]] ? url : [NSURL URLWithString:url];

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:requestUrl
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:5 * 60];

    if (length)
        [request setValue:[NSString stringWithFormat:@"bytes=%lld-", length] forHTTPHeaderField:@"Range"];

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
- (void)readCacheToOutStreamWithPath:(AFHTTPRequestOperation*)requestOperation
                                Path:(NSString*)path
{
    NSFileHandle* fh = [NSFileHandle fileHandleForReadingAtPath:path];
    NSData* currentData = [fh readDataToEndOfFile];

    if (currentData.length) {
        //打开流，写入data ， 未打卡查看 streamCode = NSStreamStatusNotOpen
        [requestOperation.outputStream open];

        NSInteger bytesWritten;
        NSInteger bytesWrittenSoFar;

        NSInteger dataLength = [currentData length];
        const uint8_t* dataBytes = [currentData bytes];

        bytesWrittenSoFar = 0;
        do {
            bytesWritten = [requestOperation.outputStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
            assert(bytesWritten != 0);
            if (bytesWritten == -1) {
                break;
            }
            else {
                bytesWrittenSoFar += bytesWritten;
            }
        } while (bytesWrittenSoFar != dataLength);
    }
}

/**
 *  @author CC, 15-08-19
 *
 *  @brief  重组进度块
 *
 *  @param requestOperation 请求对象
 *  @param cachLength       缓存字节长度
 *  @param fileNamePath     缓存文件路径
 *
 *  @return 返回重组对象回调
 *
 *  @since 1.0
 */
- (ProgressBlock)NewProgressBlockWithCacheLength:(AFHTTPRequestOperation*)requestOperation
                                      CachLength:(long long)cachLength
                                       CachePath:(NSString*)fileNamePath
{
    WEAKSELF
    void (^newProgressBlock)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) = ^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        NSData* data = [NSData dataWithContentsOfFile:fileNamePath];
        [requestOperation setValue:data forKey:@"responseData"];

        void (^progressBlock)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) = [weakSelf progressBlock:fileNamePath];
        if (progressBlock)
            progressBlock(bytesRead, totalBytesRead + cachLength, totalBytesExpectedToRead + cachLength);
    };

    return newProgressBlock;
}

/**
 *  @author CC, 15-08-19
 *
 *  @brief  监听暂停
 *
 *  @param keyPath Key判定状态
 *  @param object  请求对象
 *  @param change  <#change description#>
 *  @param context <#context description#>
 *
 *  @since 1.0
 */
- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    AFHTTPRequestOperation* requestOperation = object;
    //暂停状态
    if ([keyPath isEqualToString:@"isPaused"] && [[change objectForKey:@"new"] intValue] == 1) {
        //缓存路径
        NSString* cachePath = [requestOperation.userInfo objectForKey:@"filePath"];

        long long cacheLength = [[self class] cacheFileWithPath:cachePath];
        //暂停读取data 从文件中获取到NSNumber
        cacheLength = [[requestOperation.outputStream propertyForKey:NSStreamFileCurrentOffsetKey] unsignedLongLongValue];
        [requestOperation setValue:@"0" forKey:@"totalBytesRead"];

        //重组进度block
        [requestOperation setDownloadProgressBlock:[self NewProgressBlockWithCacheLength:requestOperation CachLength:cacheLength CachePath:cachePath]];
    }
}

@end
