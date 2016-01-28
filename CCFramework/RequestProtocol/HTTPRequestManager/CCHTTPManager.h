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
 *  @brief  超时时间间隔，以秒为单位创建的请求。默认的超时时间间隔为60秒。
 */
@property(nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 *  @author CC, 16-01-28
 *  
 *  @brief 设置数据传输格式
 */
@property(nonatomic, copy) NSSet *acceptableContentTypes;

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  单列模式
 *
 *  @return 当前对象
 */
+ (id)sharedlnstance;

/**
 *  @author CC, 16-01-28
 *  
 *  @brief 创建并返回一个‘CCHTTPManager’对象。
 */
+ (instancetype)manager;

/**
 *  @author CC, 16-01-28
 *  
 *  @brief 初始化请求对象
 */
- (id)requestOperationManager;

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  监测网络的可链接性
 *
 *  @param strUrl 检验网络地址
 *
 *  @return 返回网络是否可用
 */
- (BOOL)netWorkReachabilityWithURLString:(NSString *)strUrl;

/**
 *  @author CC, 16-01-28
 *  
 *  @brief 时时网络状态（status 0: 无网络 1: 3G/4G 2:WiFi）
 *
 *  @param status 网络状态
 */
- (void)netWorkReachability:(void (^)(NSInteger status))success;

/**
 *  @author CC, 16-01-28
 *  
 *  @brief 请求检查网络
 */
- (BOOL)requestBeforeCheckNetWork;

/**
 *  @author CC, 16-01-28
 *  
 *  @brief 处理响应对象
 *
 *  @param responseData 响应数据
 */
- (CCResponseObject *)dealwithResponseObject:(NSData *)responseData;

@end
