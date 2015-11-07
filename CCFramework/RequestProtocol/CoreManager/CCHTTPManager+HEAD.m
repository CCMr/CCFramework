//
//  CCHTTPManager+HEAD.m
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

@implementation CCHTTPManager (HEAD)

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
+ (void)NetRequestHEADWithRequestURL:(NSString *)requestURLString
                       WithParameter:(NSDictionary *)parameter
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
+ (void)NetRequestHEADWithRequestURL:(NSString *)requestURLString
                       WithParameter:(NSDictionary *)parameter
                        WithUserInfo:(NSDictionary *)userInfo
                WithReturnValeuBlock:(RequestComplete)block
                  WithErrorCodeBlock:(ErrorCodeBlock)errorBlock
                    WithFailureBlock:(FailureBlock)failureBlock
                      WithCompletion:(CompletionCallback)completionBlock
{
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperationManager manager] HEAD:requestURLString parameters:parameter success:^(AFHTTPRequestOperation *operation) {
        if (operation.userInfo && completionBlock)
            completionBlock(nil, operation.userInfo);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        errorAnalysis(error.code)? failureBlock(error) : errorBlock(error);
    }];
    
    if (userInfo)
        requestOperation.userInfo = userInfo;
    
    requestOperation.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [requestOperation start];
}


@end
