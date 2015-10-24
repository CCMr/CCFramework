//
//  NSManagedObject+FetchRequest.h
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

#import <CoreData/CoreData.h>

@interface NSManagedObject (FetchRequest)

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  获取对象名称
 *
 *  @return 返回对象名称
 */
+ (NSString *)cc_EntityName;

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  请求所有
 *
 *  @return 返回请求条件对象
 */
+ (NSFetchRequest *)cc_AllRequest;

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  单条请求
 *
 *  @return 返回请求条件对象
 */
+ (NSFetchRequest *)cc_AnyoneRequest;

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  分页请求
 *
 *  @param limit     页数
 *  @param batchSize 页码
 *
 *  @return 返回请求条件对象
 */
+ (NSFetchRequest *)cc_RequestWithFetchLimit: (NSUInteger)limit
                                   batchSize: (NSUInteger)batchSize;

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  请求条件
 *
 *  @param limit       页数
 *  @param batchSize   页码
 *  @param fetchOffset 集合数
 *
 *  @return 返回请求条件对象
 */
+ (NSFetchRequest *)cc_RequestWithFetchLimit: (NSUInteger)limit
                                   batchSize: (NSUInteger)batchSize
                                 fetchOffset: (NSUInteger)fetchOffset;

@end
