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
#import "Core.h"

@implementation CCHTTPManager

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  单列模式
 *
 *  @return 返回当前对象
 */
+ (id)sharedlnstance
{
    static CCHTTPManager *_sharedlnstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedlnstance = [[self alloc] init];
    });
    return _sharedlnstance;
}

+ (instancetype)manager
{
    return [[self alloc] init];
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
 *  @author CC, 2015-07-23
 *
 *  @brief  监测网络的可链接性
 *
 *  @param strUrl 检验网络地址
 *
 *  @return 返回网络是否可用
 */
- (BOOL)netWorkReachabilityWithURLString:(NSString *)strUrl
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
- (void)netWorkReachability:(void (^)(NSInteger status))success
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
- (BOOL)requestBeforeCheckNetWork
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

- (CCResponseObject *)dealwithResponseObject:(NSData *)responseData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;// 关闭网络指示器
    });
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
    
    CCResponseObject *entity = [[CCResponseObject alloc] initWithDict:dic];
    CCNSLogger(@"%@", [entity ChangedDictionary]);
    
    return entity;
}

- (id)dealwithError:(NSDictionary *)userInfo
              Error:(NSError *)error
      withErrorBooL:(BOOL *)errorBooL
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;// 关闭网络指示器
    });
    
    *errorBooL = NO;
    if (error.code >= 300 || error.code <= 311)
        *errorBooL = YES;
    
    id errors = error;
    if (userInfo) 
        errors =  @{@"userInfo":userInfo,@"error":error};
    
    return errors;
}

@end
