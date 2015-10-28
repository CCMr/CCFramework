//
//  CoreDataMasterSlave+Manager.m
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

#import "CoreDataMasterSlave+Manager.h"
#import "CoreDataMasterSlave+Convenience.h"
#import "NSManagedObject+Additional.h"

@implementation CoreDataMasterSlave (Queries)

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  查询表所有数据量
 *
 *  @param tableName 表名
 *
 *  @return 返回数量
 */
+ (NSUInteger)cc_count:(NSString *)tableName {
    return [self cc_countWhere:tableName WhereCondition:nil];
}

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  查询数据量
 *
 *  @param tableName 表名
 *  @param condition 条件
 *
 *  @return 返回数量
 */
+ (NSUInteger)cc_countWhere:(NSString *)tableName
             WhereCondition:(NSString *)condition, ... {
    NSFetchRequest *fetchRequest = [self cc_AllRequest:tableName];
    fetchRequest.resultType = NSCountResultType;
    [fetchRequest setIncludesSubentities:NO];
    if (condition) {
        va_list arguments;
        va_start(arguments, condition);
        NSPredicate *predicate =
        [NSPredicate predicateWithFormat:condition arguments:arguments];
        va_end(arguments);
        [fetchRequest setPredicate:predicate];
        fetchRequest.predicate = predicate;
    }
    
    return [self executeQueriesCount:fetchRequest];
}

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  查询所有数据
 *
 *  @param tableName 表名
 *
 *  @return 返回结果集
 */
+ (NSArray *)cc_selectCoreData:(NSString *)tableName {
    return [self cc_selectCoreData:tableName Condition:nil];
}

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  查询数据
 *
 *  @param tableName 表名
 *  @param condition 条件
 *
 *  @return 返回结果集
 */
+ (NSArray *)cc_selectCoreData:(NSString *)tableName
                     Condition:(NSString *)condition {
    NSFetchRequest *fetchRequest = [self cc_AllRequest:tableName];
    if (condition)
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:condition]];
    
    return [self ConversionData:[self executeQueriesContext:fetchRequest]];
}

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  查询数据
 *
 *  @param tableName 表名
 *  @param condition 条件
 *  @param handler   完成回调函数
 */
+ (void)cc_selectCoreData:(NSString *)tableName
                Condition:(NSString *)condition
                  Handler:(void (^)(NSError *error,
                                    NSArray *requestResults))handler {
    NSFetchRequest *fetchRequest = [self cc_AllRequest:tableName];
    if (condition)
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:condition]];
    
    [self executeQueriesContext:fetchRequest Handler:handler];
}

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  查询所有数据并且排序
 *
 *  @param tableName 表名
 *  @param key       排序字段
 *  @param ascending 是否升序
 *
 *  @return 返回结果集
 */
+ (NSArray *)cc_selectCoreData:(NSString *)tableName
                   sortWithKey:(NSString *)key
                     ascending:(BOOL)ascending {
    return [self cc_selectCoreData:tableName
                       sortWithKey:key
                         ascending:ascending
                         Condition:nil];
}

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  查询数据并排序
 *
 *  @param tableName 表名
 *  @param key       排序字段
 *  @param ascending 是否升序
 *  @param condition 条件
 *
 *  @return 返回结果集
 */
+ (NSArray *)cc_selectCoreData:(NSString *)tableName
                   sortWithKey:(NSString *)key
                     ascending:(BOOL)ascending
                     Condition:(NSString *)condition {
    return [self cc_selectCoreData:tableName
                       sortWithKey:key
                         ascending:ascending
                        fetchLimit:0
                       fetchOffset:0
                         Condition:0];
}

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  查询分页
 *
 *  @param tableName   表名
 *  @param pageSize    页数
 *  @param currentPage 页码
 *
 *  @return 返回结果集
 */
+ (NSArray *)cc_selectCoreData:(NSString *)tableName
                    fetchLimit:(NSInteger)pageSize
                   fetchOffset:(NSInteger)currentPage {
    return [self cc_selectCoreData:tableName
                        fetchLimit:pageSize
                       fetchOffset:currentPage
                         Condition:nil];
}

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  查询分页
 *
 *  @param tableName   表名
 *  @param pageSize    页数
 *  @param currentPage 页码
 *  @param condition   查询条件
 *
 *  @return 返回结果集
 */
+ (NSArray *)cc_selectCoreData:(NSString *)tableName
                    fetchLimit:(NSInteger)pageSize
                   fetchOffset:(NSInteger)currentPage
                     Condition:(NSString *)condition {
    return [self cc_selectCoreData:tableName
                       sortWithKey:nil
                         ascending:NO
                        fetchLimit:pageSize
                       fetchOffset:currentPage
                         Condition:condition];
}

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  查询排序分页
 *
 *  @param tableName   表名
 *  @param key         排序字段
 *  @param ascending   是否升序
 *  @param pageSize    页数
 *  @param currentPage 页码
 *  @param condition   查询条件
 *
 *  @return 返回结果集
 */
+ (NSArray *)cc_selectCoreData:(NSString *)tableName
                   sortWithKey:(NSString *)key
                     ascending:(BOOL)ascending
                    fetchLimit:(NSInteger)pageSize
                   fetchOffset:(NSInteger)currentPage
                     Condition:(NSString *)condition {
    
    NSFetchRequest *fetchRequest = [self cc_Request:tableName
                                         FetchLimit:pageSize
                                          batchSize:0
                                        fetchOffset:currentPage];
    
    if (condition)
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:condition]];
    
    if (key) {
        NSSortDescriptor *sorted =
        [NSSortDescriptor sortDescriptorWithKey:key ascending:ascending];
        [fetchRequest setSortDescriptors:@[ sorted ]];
    }
    
    return [self ConversionData:[self executeQueriesContext:fetchRequest]];
}

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  属性查询
 *
 *  @param tableName 表名
 *  @param property  条件属性
 *  @param value     属性值
 *
 *  @return 返回查询结果集
 */
+ (NSArray *)cc_whereProperty:(NSString *)tableName
                 PropertyName:(NSString *)property
                      equalTo:(id)value {
    return [self cc_whereProperty:tableName
                     PropertyName:property
                          equalTo:value
                    sortedKeyPath:nil
                        ascending:NO];
}

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  属性查询排序
 *
 *  @param tableName 表名
 *  @param property  条件属性
 *  @param value     属性值
 *  @param keyPath   排序字段
 *  @param ascending 是否升序
 *
 *  @return 返回查询结果集
 */
+ (NSArray *)cc_whereProperty:(NSString *)tableName
                 PropertyName:(NSString *)property
                      equalTo:(id)value
                sortedKeyPath:(NSString *)keyPath
                    ascending:(BOOL)ascending {
    return [self cc_whereProperty:tableName
                     PropertyName:property
                          equalTo:value
                    sortedKeyPath:keyPath
                        ascending:ascending
                   fetchBatchSize:0
                       fetchLimit:0
                      fetchOffset:0];
}

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  分页查询
 *
 *  @param tableName   表名
 *  @param property    条件属性
 *  @param value       属性值
 *  @param keyPath     排序字段
 *  @param ascending   是否升序
 *  @param batchSize   加载筛选数据数
 *  @param fetchLimit  限定查询结果数据量
 *  @param fetchOffset 游标偏移量，从游标开始读取数据
 *
 *  @return 返回查询结果集
 */
+ (NSArray *)cc_whereProperty:(NSString *)tableName
                 PropertyName:(NSString *)property
                      equalTo:(id)value
                sortedKeyPath:(NSString *)keyPath
                    ascending:(BOOL)ascending
               fetchBatchSize:(NSUInteger)batchSize
                   fetchLimit:(NSUInteger)fetchLimit
                  fetchOffset:(NSUInteger)fetchOffset {
    return [self cc_sortedKeyPath:tableName
                          KeyPath:keyPath
                        ascending:ascending
                   fetchBatchSize:batchSize
                       fetchLimit:fetchLimit
                      fetchOffset:fetchOffset
                            where:@"%K == %@", property, value];
}

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  分页查询
 *
 *  @param tableName   表名
 *  @param keyPath     排序字段
 *  @param ascending   是否升序
 *  @param batchSize   加载筛选数据数
 *  @param fetchLimit  限定查询结果数据量
 *  @param fetchOffset 游标偏移量，从游标开始读取数据
 *  @param condition   条件
 *
 *  @return 返回查询结果集
 */
+ (NSArray *)cc_sortedKeyPath:(NSString *)tableName
                      KeyPath:(NSString *)keyPath
                    ascending:(BOOL)ascending
               fetchBatchSize:(NSUInteger)batchSize
                   fetchLimit:(NSUInteger)fetchLimit
                  fetchOffset:(NSUInteger)fetchOffset
                        where:(NSString *)condition, ... {
    NSFetchRequest *fetchRequest = [self cc_Request:tableName
                                         FetchLimit:fetchLimit
                                          batchSize:batchSize
                                        fetchOffset:fetchOffset];
    
    if (condition != nil) {
        va_list arguments;
        va_start(arguments, condition);
        NSPredicate *predicate =
        [NSPredicate predicateWithFormat:condition arguments:arguments];
        va_end(arguments);
        [fetchRequest setPredicate:predicate];
    }
    
    if (keyPath != nil) {
        NSSortDescriptor *sorted =
        [NSSortDescriptor sortDescriptorWithKey:keyPath ascending:ascending];
        [fetchRequest setSortDescriptors:@[ sorted ]];
    }
    
    return [self ConversionData:[self executeQueriesContext:fetchRequest]];
}

/**
 *  @author CC, 2015-10-28
 *
 *  @brief  转换数据
 *
 *  @param data 数据集合
 *
 *  @return 返回转换后的数据集合
 */
+ (NSArray *)ConversionData:(NSArray *)data {
    __block NSMutableArray *array = [NSMutableArray array];
    [data enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx,
                                       BOOL *_Nonnull stop) {
        NSManagedObject *managedObject = obj;
        [array addObject:[managedObject changedDictionary]];
    }];
    return array;
}

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  递归查询关联子项
 *
 *  @param entity 递归对象
 *
 *  @return 返回对象
 */
+ (NSDictionary *)cc_recursiveChildren:(NSManagedObject *)entity {
    NSMutableDictionary *dic = [[entity changedDictionary] mutableCopy];
    for (NSString *key in dic.allKeys) {
        if ([[dic objectForKey:key] isKindOfClass:[NSArray class]]) {
            NSMutableArray *array = [[dic objectForKey:key] mutableCopy];
            NSRelationshipDescription *relationship =
            [[entity.entity relationshipsByName] objectForKey:key];
            id values = [dic objectForKey:relationship.inverseRelationship.name];
            //自定义关联外键使用
            if (values) {
                NSArray *dataArray = [self
                                      cc_selectCoreData:relationship.destinationEntity.name
                                      Condition:[NSString
                                                 stringWithFormat:
                                                 @"%@ = '%@'", relationship.name,
                                                 [dic objectForKey:relationship
                                                  .inverseRelationship
                                                  .name]]];
                
                //清理关联查询出来的数据
                if (dataArray.count > 0)
                    [array removeAllObjects];
                
                [dataArray
                 enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                     NSDictionary *childrenDic = obj;
                     if ([childrenDic isKindOfClass:[NSManagedObject class]])
                         childrenDic = [self cc_recursiveChildren:obj];
                     [array addObject:childrenDic];
                 }];
                array = [[[NSSet setWithArray:array] allObjects] mutableCopy];
                [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    if ([obj1 objectForKey:@"objectID"] > [obj2 objectForKey:@"objectID"])
                        return NSOrderedAscending;
                    if ([obj1 objectForKey:@"objectID"] < [obj2 objectForKey:@"objectID"])
                        return NSOrderedDescending;
                    return NSOrderedSame;
                }];
            }
            
            [dic setObject:array forKey:key];
        }
    }
    return dic;
}

@end
