//
//  ResponseEntity.h
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

#import "BaseEntity.h"

@interface CCResponseObject : BaseEntity

/**
 *  @author CC, 2015-12-15
 *  
 *  @brief  传递键值
 */
@property(nonatomic, copy) NSDictionary *userInfo;

/**
 *  @author C C, 2015-11-07
 *
 *  @brief  响应消息
 */
@property(nonatomic, copy) NSString *message;
/**
 *  @author C C, 2015-11-07
 *
 *  @brief  响应状态
 */
@property(nonatomic, assign) BOOL success;

/**
 *  @author C C, 2015-11-08
 *
 *  @brief  请求状态
 */
@property(nonatomic, assign) BOOL status;

/**
 *  @author C C, 2015-11-07
 *
 *  @brief  响应数据
 */
@property(nonatomic, copy) NSString *data;


#pragma mark -_- 汇信
@property(nonatomic, assign) BOOL code;

@property(nonatomic, copy) id bodyMessage;

@end
