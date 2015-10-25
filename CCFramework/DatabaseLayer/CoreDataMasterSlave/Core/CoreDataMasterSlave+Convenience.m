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

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  请求所有
 *
 *  @return 返回请求条件对象
 */
- (NSFetchRequest *)cc_AllRequest: (NSString *)tableName
{
    return [self cc_Request: tableName
                 FetchLimit: 0
                  batchSize: 0];
}

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  单条请求
 *
 *  @return 返回请求条件对象
 */
- (NSFetchRequest *)cc_AnyoneRequest: (NSString *)tableName
{
    return [self cc_Request: tableName
                 FetchLimit: 1
                  batchSize: 1];
}

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
- (NSFetchRequest *)cc_Request:(NSString *)tableName
                    FetchLimit: (NSUInteger)limit
                     batchSize: (NSUInteger)batchSize
{
    return [self cc_Request: tableName
                 FetchLimit: limit
                  batchSize: batchSize
                fetchOffset: 0];
}

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
- (NSFetchRequest *)cc_Request: (NSString *)tableName
                    FetchLimit: (NSUInteger)limit
                     batchSize: (NSUInteger)batchSize
                   fetchOffset: (NSUInteger)fetchOffset
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:tableName];
    fetchRequest.fetchLimit = limit;
    fetchRequest.fetchBatchSize = batchSize;
    fetchRequest.fetchOffset = fetchOffset;
    return fetchRequest;
}



/**
 *  @author CC, 2015-10-24
 *
 *  @brief  保存数据
 *
 *  @param saveContext 线程管理对象
 */
- (void)saveContext: (void (^)(NSManagedObjectContext *))saveContext
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
- (void)saveContext: (void(^)(NSManagedObjectContext *currentContext))saveContext
         completion: (void(^)(NSError *error))completion
{
    [self saveWithContext: self.currentContext
         SaveContextBlock: saveContext
               completion: completion];
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  保存对象
 *
 *  @param saveContext 线程管理对象
 *  @param completion  完成回调函数
 */
- (void)saveWithContext: (NSManagedObjectContext *)saveContext
             completion: (void(^)(NSError *error))completion
{
    [self saveWithContext: saveContext
         SaveContextBlock: nil
               completion: completion];
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
- (void)saveWithContext: (NSManagedObjectContext *)saveContext
       SaveContextBlock: (void(^)(NSManagedObjectContext *currentContext))saveContextBlock
             completion: (void(^)(NSError *error))completion
{
    __block BOOL success = YES;
    __block NSError *error = nil;
    
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
