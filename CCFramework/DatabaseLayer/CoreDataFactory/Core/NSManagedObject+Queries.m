//
//  NSManagedObject+Convenience.m
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
#import "BaseManagedObject.h"
#import "config.h"
#import "NSManagedObject+Additions.h"

@implementation NSManagedObject (Queries)

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  第一个对象
 *
 *  @return 返回第一个对象
 */
+ (id)cc_Anyone
{
    return [self cc_AnyoneWithPredicate:nil];
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  所有对象
 *
 *  @return 返回所有对象
 */
+ (NSArray *)cc_All
{
    return [self cc_AllWithPredicate:nil];
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  异步查询所有对象
 *
 *  @param handler 返回所有对象
 */
+ (void)cc_AllWithHandler: (void (^)(NSError *, NSArray *))handler
{
    NSFetchRequest *request = [self cc_AllRequest];
    NSManagedObjectContext *context = [self currentContext];
    __block NSError *error = nil;
    if (CURRENT_SYS_VERSION > 8.0) {
        [context performBlock:^{
            NSAsynchronousFetchRequest *asyncRequest = [[NSAsynchronousFetchRequest alloc] initWithFetchRequest:request completionBlock:^(NSAsynchronousFetchResult *result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (handler) {
                        handler(error,[result.finalResult copy]);
                    }
                });
            }];
            [context executeRequest:asyncRequest error:&error];
        }];
    }else{
        [context performBlock:^{
            NSArray *results = [context executeFetchRequest:request error:&error];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (handler) {
                    handler(error,results);
                }
            });
        }];
    }
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  属性查询对象
 *
 *  @param property 属性名
 *  @param value    属性值
 *
 *  @return 返回查询对象集
 */
+ (NSArray *)cc_WhereProperty: (NSString *)property
                      equalTo: (id)value
{
    return [self cc_WhereProperty: property
                          equalTo: value
                    sortedKeyPath: nil
                        ascending: NO];
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  属性查询对象
 *
 *  @param property 属性名
 *  @param value    属性值
 *  @param handler  完成回调函数
 */
+ (void)cc_WhereProperty: (NSString *)property
                 equalTo: (id)value
                 handler: (void (^)(NSError *, NSArray *))handler
{
    return [self cc_WhereProperty: property
                          equalTo: value
                    sortedKeyPath: nil
                        ascending: NO
                          handler: handler];
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  同步属性查询
 *
 *  @param property 属性名
 *  @param value    属性值
 *
 *  @return 返回查询对象
 */
+ (id)cc_FirstWhereProperty: (NSString *)property
                    equalTo: (id)value
{
    NSFetchRequest *request = [self cc_RequestWithFetchLimit:1
                                                   batchSize:1];

    [request setPredicate:[NSPredicate predicateWithFormat:@"%K == %@",property,value]];
    NSManagedObjectContext *context = [self currentContext];
    __block id obj = nil;
    [context performBlockAndWait:^{
        NSArray *objs = [context executeFetchRequest:request error:nil];
        if (objs.count > 0) {
            obj = objs[0];
        }
    }];
    return obj;
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  同步属性值查询
 *
 *  @param property  属性名
 *  @param value     属性值
 *  @param keyPath   排序字段
 *  @param ascending 是否升序
 *
 *  @return 返回查询结果集
 */
+ (NSArray *)cc_WhereProperty:(NSString *)property
                      equalTo:(id)value
                sortedKeyPath:(NSString *)keyPath
                    ascending:(BOOL)ascending
{
    return [self cc_WhereProperty:property
                          equalTo:value
                    sortedKeyPath:keyPath
                        ascending:ascending
                   fetchBatchSize:0
                       fetchLimit:0
                      fetchOffset:0];
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  异步属性值查询
 *
 *  @param property  属性名
 *  @param value     属性值
 *  @param keyPath   排序字段
 *  @param ascending 是否升序
 *  @param handler   完成回调函数
 */
+ (void)cc_WhereProperty: (NSString *)property
                 equalTo: (id)value
           sortedKeyPath: (NSString *)keyPath
               ascending: (BOOL)ascending
                 handler: (void (^)(NSError *, NSArray *))handler
{
    return [self cc_WhereProperty: property
                          equalTo: value
                    sortedKeyPath: keyPath
                        ascending: ascending
                   fetchBatchSize: 0
                       fetchLimit: 0
                      fetchOffset: 0
                          handler: handler];
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  查找所有符合条件对象
 *
 *  @param predicate 条件对象
 *
 *  @return 返回查询结果集
 */
+ (NSArray *)cc_AllWithPredicate: (NSPredicate *)predicate
{
    NSFetchRequest *request = [self cc_AllRequest];
    if (predicate != nil) {
        [request setPredicate:predicate];
    }
    NSManagedObjectContext *context = [self currentContext];
    __block NSArray *objs = nil;
    [context performBlockAndWait:^{
        NSError *error = nil;
        objs = [context executeFetchRequest:request error:&error];
    }];
    return objs;

}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  查找所有符合条件对象
 *
 *  @param predicate 条件对象
 *
 *  @return 返回查询结果集
 */
+ (id)cc_AnyoneWithPredicate: (NSPredicate *)predicate
{
    NSFetchRequest *request = [self cc_AnyoneRequest];
    if (predicate != nil) {
        [request setPredicate:predicate];
    }
    NSManagedObjectContext *context = [self currentContext];
    __block id obj = nil;
    [context performBlockAndWait:^{
        NSError *error = nil;
        obj = [[context executeFetchRequest:request error:&error] lastObject];
    }];
    return obj;
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  同步属性分页查询
 *
 *  @param property    属性名
 *  @param value       属性值
 *  @param keyPath     排序字段
 *  @param ascending   是否升序
 *  @param batchSize   页码
 *  @param fetchLimit  页数
 *  @param fetchOffset <#fetchOffset description#>
 *
 *  @return 返回查询结果集
 */
+ (NSArray *)cc_WhereProperty: (NSString *)property
                      equalTo: (id)value
                sortedKeyPath: (NSString *)keyPath
                    ascending: (BOOL)ascending
               fetchBatchSize: (NSUInteger)batchSize
                   fetchLimit: (NSUInteger)fetchLimit
                  fetchOffset: (NSUInteger)fetchOffset
{
    return [self cc_SortedKeyPath:keyPath
                        ascending:ascending
                   fetchBatchSize:batchSize
                       fetchLimit:fetchLimit
                      fetchOffset:fetchOffset
                            where:@"%K == %@",property,value];
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  分页查询
 *
 *  @param tableName   表名
 *  @param keyPath     排序字段
 *  @param ascending   是否升序
 *  @param batchSize   加载筛选数据数
 *  @param fetchLimit  限定查询结果数据量
 *  @param fetchOffset 游标偏移量，从游标开始读取数据
 *  @param handler     完成回调函数
 */
+ (void)cc_WhereProperty: (NSString *)property
                 equalTo: (id)value
           sortedKeyPath: (NSString *)keyPath
               ascending: (BOOL)ascending
          fetchBatchSize: (NSUInteger)batchSize
              fetchLimit: (NSUInteger)fetchLimit
             fetchOffset: (NSUInteger)fetchOffset
                 handler: (void (^)(NSError *, NSArray *))handler
{
    NSFetchRequest *request = [self cc_RequestWithFetchLimit:fetchLimit
                                                   batchSize:batchSize
                                                 fetchOffset:fetchOffset];

    [request setPredicate:[NSPredicate predicateWithFormat:@"%K == %@",property,value]];
    if (keyPath != nil) {
        NSSortDescriptor *sorted = [NSSortDescriptor sortDescriptorWithKey:keyPath ascending:ascending];
        [request setSortDescriptors:@[sorted]];
    }
    NSManagedObjectContext *context = [self currentContext];
    [context performBlock:^{
        NSError *error = nil;
        NSArray *objs = [context executeFetchRequest:request error:&error];
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(error,objs);
            });
        }
    }];
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  同步查询对象
 *
 *  @param condition 条件
 *
 *  @return 返回查询结果集
 */
+ (NSArray *)cc_Where: (NSString *)condition, ...
{
    NSFetchRequest *request = [self cc_AllRequest];
    if (condition != nil) {
        va_list arguments;
        va_start(arguments, condition);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:condition arguments:arguments];
        va_end(arguments);
        [request setPredicate:predicate];
    }
    NSManagedObjectContext *context = [self currentContext];
    __block NSArray *objs = nil;
    [context performBlockAndWait:^{
        NSError *error = nil;
        objs = [context executeFetchRequest:request error:&error];
    }];
    return objs;
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  同步查询对象
 *
 *  @param keyPath   排序字段
 *  @param ascending 是否升序
 *  @param batchSize 页码
 *  @param condition 条件
 *
 *  @return 返回查询结果集
 */
+ (NSArray *)cc_SortedKeyPath: (NSString *)keyPath
                    ascending: (BOOL)ascending
                    batchSize: (NSUInteger)batchSize
                        where: (NSString *)condition, ...
{
    NSFetchRequest *request = [self cc_RequestWithFetchLimit:0
                                                   batchSize:batchSize];
    if (condition != nil) {
        va_list arguments;
        va_start(arguments, condition);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:condition arguments:arguments];
        va_end(arguments);
        [request setPredicate:predicate];
    }
    if (keyPath != nil) {
        NSSortDescriptor *sorted = [NSSortDescriptor sortDescriptorWithKey:keyPath ascending:ascending];
        [request setSortDescriptors:@[sorted]];
    }
    NSManagedObjectContext *context = [self currentContext];
    __block NSArray *objs = nil;
    [context performBlockAndWait:^{
        NSError *error = nil;
        objs = [context executeFetchRequest:request error:&error];
    }];
    return objs;
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  同步查询对象
 *
 *  @param keyPath     排序字段
 *  @param ascending   是否升序
 *  @param batchSize   页码
 *  @param fetchLimit  页数
 *  @param fetchOffset <#fetchOffset description#>
 *  @param condition   条件
 *
 *  @return 返回查询结果集
 */
+ (NSArray *)cc_SortedKeyPath: (NSString *)keyPath
                    ascending: (BOOL)ascending
               fetchBatchSize: (NSUInteger)batchSize
                   fetchLimit: (NSUInteger)fetchLimit
                  fetchOffset: (NSUInteger)fetchOffset
                        where: (NSString *)condition, ...
{
    NSFetchRequest *request = [self cc_RequestWithFetchLimit:fetchLimit
                                                   batchSize:batchSize
                                                 fetchOffset:fetchOffset];
    if (condition != nil) {
        va_list arguments;
        va_start(arguments, condition);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:condition arguments:arguments];
        va_end(arguments);
        [request setPredicate:predicate];
    }
    if (keyPath != nil) {
        NSSortDescriptor *sorted = [NSSortDescriptor sortDescriptorWithKey:keyPath ascending:ascending];
        [request setSortDescriptors:@[sorted]];
    }
    NSManagedObjectContext *context = [self currentContext];
    __block NSArray *objs = nil;
    [context performBlockAndWait:^{
        NSError *error = nil;
        objs = [context executeFetchRequest:request error:&error];
    }];
    return objs;
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  查询所有对象数量
 *
 *  @return 返回结果集数量
 */
+ (NSUInteger)cc_Count
{
    return [self cc_CountWhere:nil];
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  条件查询对象数量
 *
 *  @param condition 条件
 *
 *  @return 返回结果集数量
 */
+ (NSUInteger)cc_CountWhere: (NSString *)condition, ...
{
    NSManagedObjectContext *manageObjectContext = [self currentContext];
    __block NSInteger count = 0;

    NSFetchRequest *request = [self cc_AllRequest];
    request.resultType = NSCountResultType;
    [request setIncludesSubentities:NO]; //Omit subentities. Default is YES (i.e. include subentities)

    if (condition)
    {
        va_list arguments;
        va_start(arguments, condition);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:condition arguments:arguments];
        va_end(arguments);
        [request setPredicate:predicate];
        request.predicate = predicate;
    }

    [manageObjectContext performBlockAndWait:^{
        NSError *err;
        count = [manageObjectContext countForFetchRequest:request error:&err];
    }];

    return count;
}

@end
