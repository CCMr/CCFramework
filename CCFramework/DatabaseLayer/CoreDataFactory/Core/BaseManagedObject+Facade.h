//
//  BaseManagedObject+Facade.h
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

#import "BaseManagedObject.h"

@interface NSManagedObject (Facade)

@end

#pragma mark - Convenience
@interface NSManagedObject (Convenience)

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  保存数据
 *
 *  @param saveContext 线程管理对象
 */
+ (void)saveContext:(void (^)(NSManagedObjectContext *currentContext))saveContext;

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  保存数据
 *
 *  @param saveContext 线程管理对象
 *  @param completion  完成回调
 */
+ (void)saveContext:(void (^)(NSManagedObjectContext *currentContext))saveContext
         completion:(void (^)(NSError *error))completion;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  保存对象
 *
 *  @param saveContext 线程管理对象
 *  @param completion  完成回调函数
 */
+ (void)saveWithContext:(NSManagedObjectContext *)saveContext
             completion:(void (^)(NSError *error))completion;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  保存对象
 *
 *  @param saveContext 管理对象
 *  @param block       回调执行函数
 *  @param completion  完成回调函数
 */
+ (void)saveWithContext:(NSManagedObjectContext *)saveContext
       SaveContextBlock:(void (^)(NSManagedObjectContext *currentContext))saveContextBlock
             completion:(void (^)(NSError *error))completion;

@end

#pragma mark - Create 新增对象
@interface NSManagedObject (Create)

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  创建新对象
 *
 *  @return 返回新对象
 */
+ (id)cc_New;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  根据管理对象创建新对象
 *
 *  @param context 管理对象
 *
 *  @return 返回新对象
 */
+ (id)cc_NewInContext:(NSManagedObjectContext *)context;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  创建单个对象
 *
 *  @param data    对象数据
 *  @param context 管理对象
 *
 *  @return 返回创建单个对象
 */
+ (id)cc_NewOrUpdateWithData:(NSDictionary *)data
                   inContext:(NSManagedObjectContext *)context;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  创建多个对象
 *
 *  @param dataAry 对象集
 *  @param context 管理对象
 *
 *  @return 返回创建对象集
 */
+ (NSArray *)cc_NewOrUpdateWithArray:(NSArray *)dataAry
                           inContext:(NSManagedObjectContext *)context;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  新增对象及子对象
 *
 *  @param data        对象数据
 *  @param primaryKeys 主键
 *  @param context     管理对象
 *
 *  @return 返回新增对象
 */
+ (id)objctWithData:(NSDictionary *)data
        primaryKeys:(NSSet *)primaryKeys
          inContext:(NSManagedObjectContext *)context;

@end

#pragma mark - Removed 删除对象
@interface NSManagedObject (Removed)

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  删除所有对象
 */
+ (void)cc_RemovedAll;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  删除所有对象
 *
 *  @param completion 完成回调函数
 */
+ (void)cc_RemovedAll:(void (^)(NSError *error))completion;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  根据管理对象删除所有对象
 *
 *  @param context 管理对象
 */
+ (void)cc_RemovedAllInContext:(NSManagedObjectContext *)context;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  根据管理对象删除所有对象
 *
 *  @param context    管理对象
 *  @param completion 完成回调函数
 */
+ (void)cc_RemovedAllInContext:(NSManagedObjectContext *)context
                    completion:(void (^)(NSError *error))completion;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  删除所所有对象
 *
 *  @param context    管理对象
 *  @param completion 完成回调函数
 */
+ (void)cc_RemovedAllWithContext:(NSManagedObjectContext *)context
                      completion:(void (^)(NSError *error))completion;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  删除对象
 *
 *  @param conditionID 对象ID
 */
+ (void)cc_RemovedManagedObjectID:(NSManagedObjectID *)conditionID;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  删除对象
 *
 *  @param conditionID 对象ID
 *  @param completion  完成回调函数
 */
+ (void)cc_RemovedManagedObjectID:(NSManagedObjectID *)conditionID
                       completion:(void (^)(NSError *error))completion;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  删除对象
 *
 *  @param propertyName 属性名
 *  @param value        属性值
 */
+ (void)cc_RemovedProperty:(NSString *)propertyName
                   toValue:(id)value;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  多属性删除
 *
 *  @param propertyKeyValues 属性名与值
 */
+ (void)cc_RemovedMultiProperty:(NSDictionary *)propertyKeyValues;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  多属性删除
 *
 *  @param propertyKeyValues 属性名与值
 *  @param completion        完成回调函数
 */
+ (void)cc_RemovedMultiProperty:(NSDictionary *)propertyKeyValues
                     completion:(void (^)(NSError *error))completion;

@end

#pragma mark - Modify 修改对象
@interface NSManagedObject (Modify)

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  修改所有对象属性值
 *
 *  @param propertyName 属性名
 *  @param value        修改值
 */
+ (void)cc_UpdateProperty:(NSString *)propertyName
                  toValue:(id)value;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  修改条件对象属性值
 *
 *  @param propertyName 属性名
 *  @param value        修改值
 *  @param condition    条件
 */
+ (void)cc_UpdateProperty:(NSString *)propertyName
                  toValue:(id)value
                    where:(NSString *)condition;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  修改条件对象属性值
 *
 *  @param propertyName 属性名
 *  @param value        修改值
 *  @param condition    条件
 *  @param completion   完成回调函数
 */
+ (void)cc_UpdateProperty:(NSString *)propertyName
                  toValue:(id)value
                    where:(NSString *)condition
               completion:(void (^)(NSError *error))completion;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  修改多属性
 *
 *  @param propertyKeyValue 属性与值
 *  @param condition        条件
 */
+ (void)cc_UpdateMultiProperty:(NSDictionary *)propertyKeyValue
                         where:(NSString *)condition;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  修改对属性
 *
 *  @param propertyKeyValue 属性与值
 *  @param condition        条件
 *  @param completion       完成回调函数
 */
+ (void)cc_UpdateMultiProperty:(NSDictionary *)propertyKeyValue
                         where:(NSString *)condition
                    completion:(void (^)(NSError *error))completion;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  修改所有对象属性值
 *
 *  @param keyPath 属性名
 *  @param value   值
 */
+ (void)cc_UpdateKeyPath:(NSString *)keyPath
                 toValue:(id)value;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  修改所有对象属性值
 *
 *  @param keyPath   属性名
 *  @param value     值
 *  @param condition 条件
 */
+ (void)cc_UpdateKeyPath:(NSString *)keyPath
                 toValue:(id)value
                   where:(NSString *)condition;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  修改所有对象属性
 *
 *  @param keyPath    属性名
 *  @param value      值
 *  @param condition  条件
 *  @param completion 完成回调函数
 */
+ (void)cc_UpdateKeyPath:(NSString *)keyPath
                 toValue:(id)value
                   where:(NSString *)condition
              completion:(void (^)(NSError *error))completion;
@end

#pragma mark - Queries 查询对象
@interface NSManagedObject (Queries)

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  第一个对象
 *
 *  @return 返回第一个对象
 */
+ (id)cc_Anyone;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  所有对象
 *
 *  @return 返回所有对象
 */
+ (NSArray *)cc_All;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  异步查询所有对象
 *
 *  @param handler 返回所有对象
 */
+ (void)cc_AllWithHandler:(void (^)(NSError *, NSArray *))handler;

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
+ (NSArray *)cc_WhereProperty:(NSString *)property
                      equalTo:(id)value;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  属性查询对象
 *
 *  @param property 属性名
 *  @param value    属性值
 *  @param handler  完成回调函数
 */
+ (void)cc_WhereProperty:(NSString *)property
                 equalTo:(id)value
                 handler:(void (^)(NSError *, NSArray *))handler;

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
+ (id)cc_FirstWhereProperty:(NSString *)property
                    equalTo:(id)value;

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
                    ascending:(BOOL)ascending;

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
+ (void)cc_WhereProperty:(NSString *)property
                 equalTo:(id)value
           sortedKeyPath:(NSString *)keyPath
               ascending:(BOOL)ascending
                 handler:(void (^)(NSError *, NSArray *))handler;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  查找所有符合条件对象
 *
 *  @param predicate 条件对象
 *
 *  @return 返回查询结果集
 */
+ (NSArray *)cc_AllWithPredicate:(NSPredicate *)predicate;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  查找所有符合条件对象
 *
 *  @param predicate 条件对象
 *
 *  @return 返回查询结果集
 */
+ (id)cc_AnyoneWithPredicate:(NSPredicate *)predicate;

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
+ (NSArray *)cc_WhereProperty:(NSString *)property
                      equalTo:(id)value
                sortedKeyPath:(NSString *)keyPath
                    ascending:(BOOL)ascending
               fetchBatchSize:(NSUInteger)batchSize
                   fetchLimit:(NSUInteger)fetchLimit
                  fetchOffset:(NSUInteger)fetchOffset;

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
 *  @param handler     完成回调函数
 */
+ (void)cc_WhereProperty:(NSString *)property
                 equalTo:(id)value
           sortedKeyPath:(NSString *)keyPath
               ascending:(BOOL)ascending
          fetchBatchSize:(NSUInteger)batchSize
              fetchLimit:(NSUInteger)fetchLimit
             fetchOffset:(NSUInteger)fetchOffset
                 handler:(void (^)(NSError *, NSArray *))handler;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  同步查询对象
 *
 *  @param condition 条件
 *
 *  @return 返回查询结果集
 */
+ (NSArray *)cc_Where: (NSString *)condition, ...;

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
                        where: (NSString *)condition, ...;

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
                        where: (NSString *)condition, ...;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  查询所有对象数量
 *
 *  @return 返回结果集数量
 */
+ (NSUInteger)cc_Count;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  条件查询对象数量
 *
 *  @param condition 条件
 *
 *  @return 返回结果集数量
 */
+ (NSUInteger)cc_CountWhere: (NSString *)condition, ...;

@end
