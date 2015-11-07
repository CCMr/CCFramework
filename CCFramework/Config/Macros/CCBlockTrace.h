//
//  CCBlockTrace.h
//  CCFramework
//
//  Created by CC on 15/11/7.
//  Copyright © 2015年 CC. All rights reserved.
//

#ifndef CCBlockTrace_h
#define CCBlockTrace_h

/**
 *  @author C C, 2015-11-07
 *
 *  @brief  响应回调
 *
 *  @param responseObject 响应数据
 *  @param error          错误信息
 */
typedef void (^RequestBacktrack)(id responseObject, NSError *error);

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
