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
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "CCKeyValueStore.h"
#import "CCExtension.h"
#import "CCNSLog.h"
#import "CCHTTPUpDownLoad.h"

typedef NS_ENUM(NSUInteger, CCHTTPRequestStyle) {
    CCHTTPRequestStyleGET = 0,
    CCHTTPRequestStylePOST = 1,
    CCHTTPRequestStyleDELETE = 2,
    CCHTTPRequestStyleHEAD = 3,
    CCHTTPRequestStylePUT = 4,
    CCHTTPRequestStylePATCH = 5,
};

typedef NS_ENUM(NSInteger, CCHTTPRequestType) {
    /** 异步请求 */
    CCHTTPRequestTypeAsynchronous = 0,
    /** 同步请求 */
    CCHTTPRequestTypeSynchronize = 1,
};

@interface CCHTTPManager ()

@property(nonatomic, strong) AFHTTPRequestOperationManager *manager;

@property(nonatomic, strong) CCKeyValueStore *store;

@end

static NSString *const CCRequestCache = @"CCRequestCache.sqlite";
static NSString *const CCCacheTableName = @"CCCacheTable";

@implementation CCHTTPManager

- (CCKeyValueStore *)store
{
    if (!_store) {
        _store = [[CCKeyValueStore alloc] initDBWithName:CCRequestCache];
    }
    return _store;
}

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  单列模式
 */
+ (instancetype)defaultHttp
{
    static CCHTTPManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (instancetype)manager
{
    return [[self alloc] init];
}

- (instancetype)init
{
    if (self = [super init]) {
        [self initialization];
    }
    return self;
}

- (void)initialization
{
    self.manager = [AFHTTPRequestOperationManager manager];
    self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //使用AFNetworking，默认HTTPMethodsEncodingParametersInURI里面包含的只有`GET`, `HEAD`, 和 `DELETE` 将参数放入URL链接中
    // self.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", @"DELETE", nil];
    self.manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];
    self.manager.requestSerializer.timeoutInterval = 30;
    self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil];
    self.isRequestGZIP = YES;
}

/**
 *  @author CC, 16-03-10
 *
 *  @brief 设置超时时间
 *
 *  @param timeoutInterval 超时时间（秒）
 */
- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval
{
    _timeoutInterval = timeoutInterval;
    [self.manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    self.manager.requestSerializer.timeoutInterval = timeoutInterval;
    [self.manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
}

/**
 *  @author CC, 16-09-01
 *
 *  @brief 设置请求GZIP解压
 */
- (void)setIsRequestGZIP:(BOOL)isRequestGZIP
{
    _isRequestGZIP = isRequestGZIP;
    if (_isRequestGZIP) {
        [self.manager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
        [self.manager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
    }
}

/**
 *  @author CC, 16-03-11
 *
 *  @brief 设置传输字典
 *
 *  @param userInfo 字典
 */
+ (void)setUserInfo:(NSDictionary *)userInfo
{
    [CCHTTPManager defaultHttp].userInfo = userInfo;
}

/**
 *  @author CC, 16-03-10
 *
 *  @brief 设置请求ContentType
 *
 *  @param acceptableContentTypes ContentType
 */
- (void)setAcceptableContentTypes:(NSSet *)acceptableContentTypes
{
    _acceptableContentTypes = acceptableContentTypes;
    [self.manager.responseSerializer willChangeValueForKey:@"acceptableContentTypes"];
    self.manager.responseSerializer.acceptableContentTypes = acceptableContentTypes;
    [self.manager.responseSerializer didChangeValueForKey:@"acceptableContentTypes"];
}

- (id)requestOperationManager
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    if (self.timeoutInterval > 0)
        [manager.requestSerializer setTimeoutInterval:self.timeoutInterval];

    if (self.acceptableContentTypes)
        manager.responseSerializer.acceptableContentTypes = self.acceptableContentTypes;

    return manager;
}

/**
 *  @author CC, 16-03-10
 *
 *  @brief 清理缓存数据库
 */
+ (void)removeAllCaches
{
    [[CCHTTPManager defaultHttp].store clearTable:CCRequestCache];
}

+ (void)cancelAllOperations
{
    [[CCHTTPManager defaultHttp].manager.operationQueue cancelAllOperations];
}


/**
 *  @author CC, 2015-07-23
 *
 *  @brief  监测网络的可链接性
 *
 *  @param strUrl 检验网络地址
 *
 *  @return 返回网络是否可用
 */
+ (BOOL)netWorkReachabilityWithURLString:(NSString *)strUrl
{
    __block BOOL netState = NO;

    NSURL *baseURL = [NSURL URLWithString:strUrl];

    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];

    NSOperationQueue *operationQueue = manager.operationQueue;

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

/**
 *  @author CC, 16-01-28
 *
 *  @brief 时时网络状态（status 0: 无网络 1: 3G/4G 2:WiFi）
 *
 *  @param status 网络状态
 */
+ (void)netWorkReachability:(void (^)(NSInteger status))success
{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];

    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (success)
            success(status);
    }];
}

/**
 *  @author CC, 16-01-28
 *
 *  @brief 请求检查网络
 */
+ (BOOL)requestBeforeCheckNetWork
{
    struct sockaddr zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sa_len = sizeof(zeroAddress);
    zeroAddress.sa_family = AF_INET;
    SCNetworkReachabilityRef defaultRouteReachability =
    SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    BOOL didRetrieveFlags =
    SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    if (!didRetrieveFlags) {
        printf("Error. Count not recover network reachability flags\n");
        return NO;
    }
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    BOOL isNetworkEnable = (isReachable && !needsConnection) ? YES : NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = isNetworkEnable;/*  网络指示器的状态： 有网络 ： 开  没有网络： 关  */
    });
    return isNetworkEnable;
}

#pragma mark :. 请求异步

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
    failure:(requestFailureBlock)failure
{
    [CCHTTPManager requestHandler:CCHTTPRequestStyleGET
                      requestType:CCHTTPRequestTypeAsynchronous
                 RequestURLString:requestURLString
                    WithParameter:parameter
                      cachePolicy:CCHTTPReloadIgnoringLocalCacheData
                          success:success
                          failure:failure];
}

+ (void)GET:(NSString *)requestURLString
 parameters:(NSDictionary *)parameter
cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
    success:(requestSuccessBlock)success
    failure:(requestFailureBlock)failure
{
    [CCHTTPManager requestHandler:CCHTTPRequestStyleGET
                      requestType:CCHTTPRequestTypeAsynchronous
                 RequestURLString:requestURLString
                    WithParameter:parameter
                      cachePolicy:cachePolicy
                          success:success
                          failure:failure];
}

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
     failure:(requestFailureBlock)failure
{
    [CCHTTPManager requestHandler:CCHTTPRequestStylePOST
                      requestType:CCHTTPRequestTypeAsynchronous
                 RequestURLString:requestURLString
                    WithParameter:parameter
                      cachePolicy:CCHTTPReloadIgnoringLocalCacheData
                          success:success
                          failure:failure];
}

+ (void)POST:(NSString *)requestURLString
  parameters:(NSDictionary *)parameter
 cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
     success:(requestSuccessBlock)success
     failure:(requestFailureBlock)failure
{
    [CCHTTPManager requestHandler:CCHTTPRequestStylePOST
                      requestType:CCHTTPRequestTypeAsynchronous
                 RequestURLString:requestURLString
                    WithParameter:parameter
                      cachePolicy:cachePolicy
                          success:success
                          failure:failure];
}

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
       failure:(requestFailureBlock)failure
{
    [CCHTTPManager requestHandler:CCHTTPRequestStyleDELETE
                      requestType:CCHTTPRequestTypeAsynchronous
                 RequestURLString:requestURLString
                    WithParameter:parameter
                      cachePolicy:CCHTTPReloadIgnoringLocalCacheData
                          success:success
                          failure:failure];
}

+ (void)DELETE:(NSString *)requestURLString
    parameters:(NSDictionary *)parameter
   cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
       success:(requestSuccessBlock)success
       failure:(requestFailureBlock)failure
{
    [CCHTTPManager requestHandler:CCHTTPRequestStyleDELETE
                      requestType:CCHTTPRequestTypeAsynchronous
                 RequestURLString:requestURLString
                    WithParameter:parameter
                      cachePolicy:cachePolicy
                          success:success
                          failure:failure];
}

+ (void)HEAD:(NSString *)requestURLString
  parameters:(NSDictionary *)parameter
 cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
     success:(requestSuccessBlock)success
     failure:(requestFailureBlock)failure
{
    [CCHTTPManager requestHandler:CCHTTPRequestStyleHEAD
                      requestType:CCHTTPRequestTypeAsynchronous
                 RequestURLString:requestURLString
                    WithParameter:parameter
                      cachePolicy:cachePolicy
                          success:success
                          failure:failure];
}

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
    failure:(requestFailureBlock)failure
{
    [CCHTTPManager requestHandler:CCHTTPRequestStylePUT
                      requestType:CCHTTPRequestTypeAsynchronous
                 RequestURLString:requestURLString
                    WithParameter:parameter
                      cachePolicy:CCHTTPReloadIgnoringLocalCacheData
                          success:success
                          failure:failure];
}

+ (void)PUT:(NSString *)requestURLString
 parameters:(NSDictionary *)parameter
cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
    success:(requestSuccessBlock)success
    failure:(requestFailureBlock)failure
{
    [CCHTTPManager requestHandler:CCHTTPRequestStylePUT
                      requestType:CCHTTPRequestTypeAsynchronous
                 RequestURLString:requestURLString
                    WithParameter:parameter
                      cachePolicy:cachePolicy
                          success:success
                          failure:failure];
}

+ (void)PATCH:(NSString *)requestURLString
   parameters:(NSDictionary *)parameter
  cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
      success:(requestSuccessBlock)success
      failure:(requestFailureBlock)failure
{
    [CCHTTPManager requestHandler:CCHTTPRequestStylePATCH
                      requestType:CCHTTPRequestTypeAsynchronous
                 RequestURLString:requestURLString
                    WithParameter:parameter
                      cachePolicy:cachePolicy
                          success:success
                          failure:failure];
}

#pragma mark :. 请求Synchronize
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
+ (void)syncGET:(NSString *)requestURLString
     parameters:(NSDictionary *)parameter
        success:(requestSuccessBlock)success
        failure:(requestFailureBlock)failure
{
    [CCHTTPManager requestHandler:CCHTTPRequestStyleGET
                      requestType:CCHTTPRequestTypeSynchronize
                 RequestURLString:requestURLString
                    WithParameter:parameter
                      cachePolicy:CCHTTPReloadIgnoringLocalCacheData
                          success:success
                          failure:failure];
}

+ (void)syncGET:(NSString *)requestURLString
     parameters:(NSDictionary *)parameter
    cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
        success:(requestSuccessBlock)success
        failure:(requestFailureBlock)failure
{
    [CCHTTPManager requestHandler:CCHTTPRequestStyleGET
                      requestType:CCHTTPRequestTypeSynchronize
                 RequestURLString:requestURLString
                    WithParameter:parameter
                      cachePolicy:cachePolicy
                          success:success
                          failure:failure];
}

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
+ (void)syncPOST:(NSString *)requestURLString
      parameters:(NSDictionary *)parameter
         success:(requestSuccessBlock)success
         failure:(requestFailureBlock)failure
{
    [CCHTTPManager requestHandler:CCHTTPRequestStylePOST
                      requestType:CCHTTPRequestTypeSynchronize
                 RequestURLString:requestURLString
                    WithParameter:parameter
                      cachePolicy:CCHTTPReloadIgnoringLocalCacheData
                          success:success
                          failure:failure];
}

+ (void)syncPOST:(NSString *)requestURLString
      parameters:(NSDictionary *)parameter
     cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
         success:(requestSuccessBlock)success
         failure:(requestFailureBlock)failure
{
    [CCHTTPManager requestHandler:CCHTTPRequestStylePOST
                      requestType:CCHTTPRequestTypeSynchronize
                 RequestURLString:requestURLString
                    WithParameter:parameter
                      cachePolicy:cachePolicy
                          success:success
                          failure:failure];
}

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
+ (void)syncDELETE:(NSString *)requestURLString
        parameters:(NSDictionary *)parameter
           success:(requestSuccessBlock)success
           failure:(requestFailureBlock)failure
{
    [CCHTTPManager requestHandler:CCHTTPRequestStyleDELETE
                      requestType:CCHTTPRequestTypeSynchronize
                 RequestURLString:requestURLString
                    WithParameter:parameter
                      cachePolicy:CCHTTPReloadIgnoringLocalCacheData
                          success:success
                          failure:failure];
}

+ (void)syncDELETE:(NSString *)requestURLString
        parameters:(NSDictionary *)parameter
       cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
           success:(requestSuccessBlock)success
           failure:(requestFailureBlock)failure
{
    [CCHTTPManager requestHandler:CCHTTPRequestStyleDELETE
                      requestType:CCHTTPRequestTypeSynchronize
                 RequestURLString:requestURLString
                    WithParameter:parameter
                      cachePolicy:cachePolicy
                          success:success
                          failure:failure];
}

+ (void)syncHEAD:(NSString *)requestURLString
      parameters:(NSDictionary *)parameter
     cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
         success:(requestSuccessBlock)success
         failure:(requestFailureBlock)failure
{
    [CCHTTPManager requestHandler:CCHTTPRequestStyleHEAD
                      requestType:CCHTTPRequestTypeSynchronize
                 RequestURLString:requestURLString
                    WithParameter:parameter
                      cachePolicy:cachePolicy
                          success:success
                          failure:failure];
}

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
+ (void)syncPUT:(NSString *)requestURLString
     parameters:(NSDictionary *)parameter
        success:(requestSuccessBlock)success
        failure:(requestFailureBlock)failure
{
    [CCHTTPManager requestHandler:CCHTTPRequestStylePUT
                      requestType:CCHTTPRequestTypeSynchronize
                 RequestURLString:requestURLString
                    WithParameter:parameter
                      cachePolicy:CCHTTPReloadIgnoringLocalCacheData
                          success:success
                          failure:failure];
}

+ (void)syncPUT:(NSString *)requestURLString
     parameters:(NSDictionary *)parameter
    cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
        success:(requestSuccessBlock)success
        failure:(requestFailureBlock)failure
{
    [CCHTTPManager requestHandler:CCHTTPRequestStylePUT
                      requestType:CCHTTPRequestTypeSynchronize
                 RequestURLString:requestURLString
                    WithParameter:parameter
                      cachePolicy:cachePolicy
                          success:success
                          failure:failure];
}

+ (void)syncPATCH:(NSString *)requestURLString
       parameters:(NSDictionary *)parameter
      cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
          success:(requestSuccessBlock)success
          failure:(requestFailureBlock)failure
{
    [CCHTTPManager requestHandler:CCHTTPRequestStylePATCH
                      requestType:CCHTTPRequestTypeSynchronize
                 RequestURLString:requestURLString
                    WithParameter:parameter
                      cachePolicy:cachePolicy
                          success:success
                          failure:failure];
}

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
       failure:(requestFailureBlock)failure
{
    [CCHTTPUpDownLoad Upload:requestURLString parameters:parameter manager:[CCHTTPManager defaultHttp].manager fileConfig:fileConfig success:^(CCResponseObject *responseObject) {
        if (success)
            success(nil);
    } failure:^(id response, NSError *error) {
        if (failure)
            failure(response,[self failureError:error]);
    }];
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
    [CCHTTPUpDownLoad Upload:requestURLString filePath:filePath progress:progress success:^(CCResponseObject *responseObject) {
        success([self requestResultsHandler:nil UserInfo:nil]);
    } failure:^(id response, NSError *error) {
        if (failure)
            failure(response,[self failureError:error]);
    }];
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
    [CCHTTPUpDownLoad Download:requestURLString fileName:fileName downloadProgressBlock:downloadProgressBlock success:^(NSData *data, NSError *error) {
        success(data,nil);
    } failure:^(id response, NSError *error) {
        if (failure)
            failure(response,[self failureError:error]);
    }];
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
    [CCHTTPUpDownLoad Download:requestURLString success:success];
}

#pragma mark :. 请求处理

+ (void)requestHandler:(CCHTTPRequestStyle)requestStyle
           requestType:(CCHTTPRequestType)requestType
      RequestURLString:(NSString *)requestURLString
         WithParameter:(NSDictionary *)parameter
           cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
               success:(requestSuccessBlock)successHandler
               failure:(requestFailureBlock)failureHandler
{
    //默认直接请求
    if (cachePolicy == CCHTTPReturnDefault) {
        if (requestType == CCHTTPRequestTypeAsynchronous) {
            [CCHTTPManager requestMethod:requestStyle
                        RequestURLString:requestURLString
                           WithParameter:parameter
                             cachePolicy:cachePolicy
                                 success:successHandler
                                 failure:failureHandler];
        } else if (requestType == CCHTTPRequestTypeSynchronize) {
            [CCHTTPManager syncRequestMethod:requestStyle
                            RequestURLString:requestURLString
                               WithParameter:parameter
                                 cachePolicy:cachePolicy
                                     success:successHandler
                                     failure:failureHandler];
        }
        return;
    }

    NSString *cacheKey = requestURLString;
    if (parameter) {
        if (![NSJSONSerialization isValidJSONObject:parameter]) return;
        NSData *data = [NSJSONSerialization dataWithJSONObject:parameter options:NSJSONWritingPrettyPrinted error:nil];
        NSString *paramStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        cacheKey = [requestURLString stringByAppendingString:paramStr];
    }

    CCKeyValueItem *item = [[CCHTTPManager defaultHttp].store getYTKKeyValueItemById:cacheKey fromTable:CCCacheTableName];
    id object = item.itemObject;

    switch (cachePolicy) {
        case CCHTTPReturnCacheDataThenLoad: { // 先返回缓存，同时请求
            if (object)
                successHandler(object);
            break;
        }
        case CCHTTPReloadIgnoringLocalCacheData: // 忽略本地缓存直接请求
            // 不做处理，直接请求
            break;
        case CCHTTPReturnCacheDataElseLoad: { // 有缓存就返回缓存，没有就请求
            if (object) {			       // 有缓存
                successHandler(object);
                return;
            }
            break;
        }
        case CCHTTPReturnCacheDataDontLoad: { // 有缓存就返回缓存,从不请求（用于没有网络）
            if (object)			       // 有缓存
                successHandler(object);
            return; // 退出从不请求

            break;
        }

        default: {
            break;
        }
    }

    if (requestType == CCHTTPRequestTypeAsynchronous) {

        [CCHTTPManager requestMethod:requestStyle
                    RequestURLString:requestURLString
                       WithParameter:parameter
                         cachePolicy:cachePolicy
                             success:successHandler
                             failure:failureHandler];

    } else if (requestType == CCHTTPRequestTypeSynchronize) {

        [CCHTTPManager syncRequestMethod:requestStyle
                        RequestURLString:requestURLString
                           WithParameter:parameter
                             cachePolicy:cachePolicy
                                 success:successHandler
                                 failure:failureHandler];
    }
}

#pragma mark :. 异步
/**
 *  @author CC, 16-03-10
 *
 *  @brief 请求处理
 *
 *  @param requestType      请求类型
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param cachePolicy      缓存类型
 *  @param successHandler   完成回调
 *  @param failureHandler   故障回调
 */
+ (void)requestMethod:(CCHTTPRequestStyle)requestStyle
     RequestURLString:(NSString *)requestURLString
        WithParameter:(NSDictionary *)parameter
          cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
              success:(requestSuccessBlock)successHandler
              failure:(requestFailureBlock)failureHandler
{
    if (![self requestBeforeCheckNetWork]) {
        failureHandler([CCHTTPManager defaultHttp].userInfo, [NSError errorWithDomain:@"Error. Count not recover network reachability flags" code:kCFURLErrorNotConnectedToInternet userInfo:nil]);
        return;
    }

    AFHTTPRequestOperation *requestOperation;
    switch (requestStyle) {
        case CCHTTPRequestStyleGET: {
            requestOperation = [[CCHTTPManager defaultHttp].manager GET:requestURLString parameters:parameter success:^(AFHTTPRequestOperation *_Nonnull operation, id _Nonnull responseObject) {
                if (successHandler){
                    if (cachePolicy != CCHTTPReturnDefault)
                        [self requestCache:requestURLString CacheData:responseObject];

                    successHandler([self requestResultsHandler:responseObject UserInfo:operation.userInfo]);
                }
            } failure:^(AFHTTPRequestOperation *_Nonnull operation, NSError *_Nonnull error) {
                if (failureHandler)
                    failureHandler(operation.userInfo,[self failureError:error]);
            }];

            if ([CCHTTPManager defaultHttp].userInfo)
                requestOperation.userInfo = [[CCHTTPManager defaultHttp].userInfo copy];

            break;
        }
        case CCHTTPRequestStylePOST: {
            requestOperation = [[CCHTTPManager defaultHttp].manager POST:requestURLString parameters:parameter success:^(AFHTTPRequestOperation *_Nonnull operation, id _Nonnull responseObject) {
                if (successHandler){
                    if (cachePolicy != CCHTTPReturnDefault)
                        [self requestCache:requestURLString CacheData:responseObject];

                    successHandler([self requestResultsHandler:responseObject UserInfo:operation.userInfo]);
                }
            } failure:^(AFHTTPRequestOperation *_Nonnull operation, NSError *_Nonnull error) {
                if (failureHandler)
                    failureHandler(operation.userInfo,[self failureError:error]);
            }];

            if ([CCHTTPManager defaultHttp].userInfo)
                requestOperation.userInfo = [[CCHTTPManager defaultHttp].userInfo copy];

            break;
        }
        case CCHTTPRequestStyleDELETE: {
            requestOperation = [[CCHTTPManager defaultHttp].manager DELETE:requestURLString parameters:parameter success:^(AFHTTPRequestOperation *_Nonnull operation, id _Nonnull responseObject) {
                if (successHandler){
                    if (cachePolicy != CCHTTPReturnDefault)
                        [self requestCache:requestURLString CacheData:responseObject];

                    successHandler([self requestResultsHandler:responseObject UserInfo:operation.userInfo]);
                }
            } failure:^(AFHTTPRequestOperation *_Nonnull operation, NSError *_Nonnull error) {
                if (failureHandler)
                    failureHandler(operation.userInfo,[self failureError:error]);
            }];

            if ([CCHTTPManager defaultHttp].userInfo)
                requestOperation.userInfo = [[CCHTTPManager defaultHttp].userInfo copy];

            break;
        }
        case CCHTTPRequestStyleHEAD: {
            requestOperation = [[CCHTTPManager defaultHttp].manager HEAD:requestURLString parameters:parameter success:^(AFHTTPRequestOperation *_Nonnull operation) {
                if (successHandler){
                    CCResponseObject *entity= [[CCResponseObject alloc] init];
                    entity.userInfo = operation.userInfo;
                    successHandler(entity);
                }
            } failure:^(AFHTTPRequestOperation *_Nonnull operation, NSError *_Nonnull error) {
                if (failureHandler)
                    failureHandler(operation.userInfo,[self failureError:error]);
            }];

            if ([CCHTTPManager defaultHttp].userInfo)
                requestOperation.userInfo = [[CCHTTPManager defaultHttp].userInfo copy];

            break;
        }
        case CCHTTPRequestStylePUT: {
            requestOperation = [[CCHTTPManager defaultHttp].manager PUT:requestURLString parameters:parameter success:^(AFHTTPRequestOperation *_Nonnull operation, id _Nonnull responseObject) {
                if (successHandler){
                    if (cachePolicy != CCHTTPReturnDefault)
                        [self requestCache:requestURLString CacheData:responseObject];

                    successHandler([self requestResultsHandler:responseObject UserInfo:operation.userInfo]);
                }

            } failure:^(AFHTTPRequestOperation *_Nonnull operation, NSError *_Nonnull error) {
                if (failureHandler)
                    failureHandler(operation.userInfo,[self failureError:error]);
            }];

            if ([CCHTTPManager defaultHttp].userInfo)
                requestOperation.userInfo = [[CCHTTPManager defaultHttp].userInfo copy];


            break;
        }
        case CCHTTPRequestStylePATCH: {
            requestOperation = [[CCHTTPManager defaultHttp].manager PATCH:requestURLString parameters:parameter success:^(AFHTTPRequestOperation *_Nonnull operation, id _Nonnull responseObject) {
                if (successHandler){
                    if (cachePolicy != CCHTTPReturnDefault)
                        [self requestCache:requestURLString CacheData:responseObject];

                    successHandler([self requestResultsHandler:responseObject UserInfo:operation.userInfo]);
                }

            } failure:^(AFHTTPRequestOperation *_Nonnull operation, NSError *_Nonnull error) {
                if (failureHandler)
                    failureHandler(operation.userInfo,[self failureError:error]);
            }];

            if ([CCHTTPManager defaultHttp].userInfo)
                requestOperation.userInfo = [[CCHTTPManager defaultHttp].userInfo copy];

            break;
        }
    }

    [requestOperation start];
}

#pragma mark :. 同步
+ (void)syncRequestMethod:(CCHTTPRequestStyle)requestStyle
         RequestURLString:(NSString *)requestURLString
            WithParameter:(NSDictionary *)parameter
              cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
                  success:(requestSuccessBlock)successHandler
                  failure:(requestFailureBlock)failureHandler
{

    if (![self requestBeforeCheckNetWork]) {
        failureHandler([CCHTTPManager defaultHttp].userInfo, [NSError errorWithDomain:@"Error. Count not recover network reachability flags" code:kCFURLErrorNotConnectedToInternet userInfo:nil]);
        return;
    }

    NSDictionary *userInfo = [[CCHTTPManager defaultHttp].userInfo copy];

    AFHTTPRequestOperation *requestOperation;
    NSError *error = nil;
    switch (requestStyle) {
        case CCHTTPRequestStyleGET:
            requestOperation = [[CCHTTPManager defaultHttp].manager syncGET:requestURLString parameters:parameter operation:nil error:&error];
            break;
        case CCHTTPRequestStylePOST:
            requestOperation = [[CCHTTPManager defaultHttp].manager syncPOST:requestURLString parameters:parameter operation:nil error:&error];
            break;
        case CCHTTPRequestStyleDELETE:
            requestOperation = [[CCHTTPManager defaultHttp].manager syncDELETE:requestURLString parameters:parameter operation:nil error:&error];
            break;
        case CCHTTPRequestStyleHEAD:
            requestOperation = [[CCHTTPManager defaultHttp].manager syncHEAD:requestURLString parameters:parameter operation:nil error:&error];
            break;
        case CCHTTPRequestStylePUT:
            requestOperation = [[CCHTTPManager defaultHttp].manager syncPUT:requestURLString parameters:parameter operation:nil error:&error];
            break;
        case CCHTTPRequestStylePATCH:
            requestOperation = [[CCHTTPManager defaultHttp].manager syncPATCH:requestURLString parameters:parameter operation:nil error:&error];
            break;
    }


    if (!error) {
        if (successHandler) {
            if (cachePolicy != CCHTTPReturnDefault)
                [self requestCache:requestURLString CacheData:requestOperation.responseObject];

            successHandler([self requestResultsHandler:requestOperation.responseObject UserInfo:userInfo]);
        }
    } else {
        if (failureHandler)
            failureHandler(userInfo, [self failureError:error]);
    }
}

#pragma mark :. 响应处理

/**
 *  @author CC, 16-03-10
 *
 *  @brief 响应结果处理
 *
 *  @param results     响应结果
 *  @param cachePolicy 缓存类型
 */
+ (CCResponseObject *)requestResultsHandler:(NSDictionary *)results UserInfo:(NSDictionary *)userInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;// 关闭网络指示器
    });

    [CCHTTPManager defaultHttp].userInfo = nil;

    CCResponseObject *entity = nil;
    if (results) {
        //        NSDictionary *resultsDic = [NSJSONSerialization JSONObjectWithData:results options:NSJSONReadingAllowFragments error:nil];

        entity = [CCResponseObject cc_objectWithKeyValues:results];

        if (userInfo)
            entity.userInfo = userInfo;

        CCNSLogger(@"%@", [entity cc_keyValues]);
    } else {
        entity = [[CCResponseObject alloc] init];
        if (userInfo)
            entity.userInfo = userInfo;
    }

    return entity;
}

/**
 *  @author CC, 16-03-10
 *
 *  @brief 故障异常处理
 *
 *  @param error 异常信息
 */
+ (NSError *)failureError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;// 关闭网络指示器
    });

    return [self httpErrorAnalysis:error];
}

/**
 *  @author CC, 16-03-10
 *
 *  @brief 请求缓存处理
 *
 *  @param cachekey  缓存Key
 *  @param cacheData 缓存数据
 */
+ (void)requestCache:(NSString *)cachekey
           CacheData:(id)cacheData
{
    if (cacheData) {
        [[CCHTTPManager defaultHttp].store putObject:cacheData
                                              withId:cachekey
                                           intoTable:CCCacheTableName];
    }
}

#pragma mark :. 错误处理
/**
 *  @author CC, 2016-3-10
 *
 *  @brief  错误消息处理
 *
 *  @param code 错误代码
 */
+ (NSError *)httpErrorAnalysis:(NSError *)error
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

    if ([errorInfo.allKeys containsObject:@(error.code)])
        errorContent = [errorInfo objectForKey:@(error.code)];

    return [NSError errorWithDomain:errorContent code:error.code userInfo:error.userInfo];
}


@end
