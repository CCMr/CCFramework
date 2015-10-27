//
//  CoreDataMasterSlave+Convenience.m
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

#import "CoreDataMasterSlave+Convenience.h"

@implementation CoreDataMasterSlave (Convenience)

#pragma mark + 查询条件
/**
 *  @author CC, 2015-10-24
 *
 *  @brief  请求所有
 *
 *  @return 返回请求条件对象
 */
+ (NSFetchRequest*)cc_AllRequest:(NSString*)tableName
{
    return [self cc_Request:tableName
                 FetchLimit:0
                  batchSize:0];
}

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  单条请求
 *
 *  @return 返回请求条件对象
 */
+ (NSFetchRequest*)cc_AnyoneRequest:(NSString*)tableName
{
    return [self cc_Request:tableName
                 FetchLimit:1
                  batchSize:1];
}

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  分页请求
 *
 *  @param limit     限定查询结果数据量
 *  @param batchSize 加载筛选数据数
 *
 *  @return 返回请求条件对象
 */
+ (NSFetchRequest*)cc_Request:(NSString*)tableName
                   FetchLimit:(NSUInteger)limit
                    batchSize:(NSUInteger)batchSize
{
    return [self cc_Request:tableName
                 FetchLimit:limit
                  batchSize:batchSize
                fetchOffset:0];
}

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  请求条件
 *
 *  @param limit       限定查询结果数据量
 *  @param batchSize   加载筛选数据数
 *  @param fetchOffset 游标偏移量，从游标开始读取数据
 *
 *  @return 返回请求条件对象
 */
+ (NSFetchRequest*)cc_Request:(NSString*)tableName
                   FetchLimit:(NSUInteger)limit
                    batchSize:(NSUInteger)batchSize
                  fetchOffset:(NSUInteger)fetchOffset
{
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:tableName];
    fetchRequest.fetchLimit = limit;
    fetchRequest.fetchBatchSize = batchSize;
    fetchRequest.fetchOffset = fetchOffset;
    return fetchRequest;
}

#pragma mark + 查询

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  查询数量
 *
 *  @param request 查询条件
 *
 *  @return 返回数量
 */
+ (NSInteger)executeQueriesCount:(NSFetchRequest*)request
{
    __block NSInteger count = 0;
    void (^Handler)(NSError* error, NSInteger requestCount) = ^(NSError* error, NSInteger requestCount) {
        count = requestCount;
    };

    [self executeQueriesCount:request
                      Handler:Handler];

    return count;
}

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  查询数量
 *
 *  @param request 查询条件
 *  @param handler 完成回调函数
 */
+ (void)executeQueriesCount:(NSFetchRequest*)request
                    Handler:(void (^)(NSError* error, NSInteger requestCount))handler
{
    [self executeQueriesCount:self.currentContext
                 FetchRequest:request
                      Handler:handler];
}

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  查询数量
 *
 *  @param queriesContext 管理对象
 *  @param request        查询条件
 *  @param handler        完成回调函数
 */
+ (void)executeQueriesCount:(NSManagedObjectContext*)queriesContext
               FetchRequest:(NSFetchRequest*)request
                    Handler:(void (^)(NSError* error, NSInteger requestCount))handler
{
    [queriesContext performBlockAndWait:^{
        NSError* error = nil;
        NSInteger count = [queriesContext countForFetchRequest:request error:&error];

        if (handler) {
            handler(error, count);
        }
    }];
}

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  查询数据
 *
 *  @param request 查询条件
 *
 *  @return 返回结果集
 */
+ (NSArray*)executeQueriesContext:(NSFetchRequest*)request
{
    __block NSArray* objs = nil;

    void (^Handler)(NSError* error, NSArray* requestResults) = ^(NSError* error, NSArray* requestResults) {
        objs = requestResults;
    };

    [self executeQueriesContext:request
                        Handler:Handler];

    return objs;
}

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  查询数据
 *
 *  @param request 查询条件
 *  @param handler 完成回调函数
 */
+ (void)executeQueriesContext:(NSFetchRequest*)request
                      Handler:(void (^)(NSError* error, NSArray* requestResults))handler
{
    [self executeQueriesContext:self.currentContext
                   FetchRequest:request
                        Handler:handler];
}

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  查询数据
 *
 *  @param queriesContext 管理对象
 *  @param request        查询条件
 *  @param handler        完成回调函数
 */
+ (void)executeQueriesContext:(NSManagedObjectContext*)queriesContext
                 FetchRequest:(NSFetchRequest*)request
                      Handler:(void (^)(NSError* error, NSArray*))handler
{
    [queriesContext performBlock:^{
        NSError* error = nil;
        NSArray* objs = [queriesContext executeFetchRequest:request error:&error];

        if (handler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(error, objs);
            });
        }
    }];
}

#pragma mark + 保存数据

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  保存数据
 *
 *  @param saveContext 线程管理对象
 */
+ (void)saveContext:(void (^)(NSManagedObjectContext* currentContext))saveContext
{
    [self saveContext:saveContext
           completion:nil];
}

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  保存数据
 *
 *  @param saveContext 线程管理对象
 *  @param completion  完成回调函数
 */
+ (void)saveContext:(void (^)(NSManagedObjectContext* currentContext))saveContext
         completion:(void (^)(NSError* error))completion
{
    [self saveWithContext:self.currentContext
         SaveContextBlock:saveContext
               completion:completion];
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  保存对象
 *
 *  @param saveContext 线程管理对象
 *  @param completion  完成回调函数
 */
+ (void)saveWithContext:(NSManagedObjectContext*)saveContext
             completion:(void (^)(NSError* error))completion
{
    [self saveWithContext:saveContext
         SaveContextBlock:nil
               completion:completion];
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  保存对象
 *
 *  @param saveContext 管理对象
 *  @param block       回调执行函数
 *  @param completion  完成回调函数
 */
+ (void)saveWithContext:(NSManagedObjectContext*)saveContext
       SaveContextBlock:(void (^)(NSManagedObjectContext* currentContext))saveContextBlock
             completion:(void (^)(NSError* error))completion
{
    __block BOOL success = YES;
    __block NSError* error = nil;

    [saveContext performBlock:^{

        if (saveContextBlock)
            saveContextBlock(saveContext);

        success = [saveContext save:&error];

        if (error == nil) {
            [saveContext.parentContext performBlockAndWait:^{
                [saveContext.parentContext save:&error];
            }];
        }

        if (completion) {
            completion(error);
        }
    }];
}

@end
