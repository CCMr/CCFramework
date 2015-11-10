//
//  CCBlockTrace.h
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

#ifndef CCBlockTrace_h
#define CCBlockTrace_h

#import <CCFramework/CCResponseObject.h>

/**
 *  @author C C, 2015-11-08
 *
 *  @brief  HTTP返回处理结果
 *
 *  @param responseObject 响应数据
 *  @param error          错误消息
 */
typedef void (^CCRequestBacktrack)(id responseObject, NSError *error);

/**
 *  @author C C, 2015-11-07
 *
 *  @brief  响应回调
 *
 *  @param responseObject 响应数据
 *  @param error          错误信息
 */
typedef void (^RequestBacktrack)(CCResponseObject *responseObject, NSError *error);

/**
 *  @author CC, 2015-11-07
 *
 *  @brief  响应完成回调
 *
 *  @param responseData 响应数据
 *  @param userInfo     字典接收
 */
typedef void (^RequestCompletionBacktrack)(id responseObject, NSDictionary *userInfo);

/**
 *  @author C C, 2015-11-07
 *
 *  @brief  响应进度回调
 *
 *  @param bytesRead                读取的字节
 *  @param totalBytesRead           总字节数学
 *  @param totalBytesExpectedToRead 读取字节数
 */
typedef void (^RequestProgressBacktrack)(NSUInteger bytesRead, long long totalBytesRead,long long totalBytesExpectedToRead);

/**
 *  @author C C, 2015-11-08
 *
 *  @brief  响应下载回调
 *
 *  @param data  下载数据
 *  @param error 错误信息
 */
typedef void (^RequestDownloadBacktrack)(NSData *data, NSError *error);


/**
 *  @author C C, 2015-11-07
 *
 *  @brief  响应错误回调
 *
 *  @param errorCode 错误信息
 */
typedef void (^ErrorCodeBlock)(id error);

/**
 *  @author C C, 2015-11-07
 *
 *  @brief  响应故障回调
 *
 *  @param failure 故障信息
 */
typedef void (^FailureBlock)(id failure);

#endif /* CCBlockTrace_h */
