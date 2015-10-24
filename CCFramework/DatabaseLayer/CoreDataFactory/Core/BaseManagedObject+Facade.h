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

@interface BaseManagedObject (Facade)

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
+ (void)saveContext: (void(^)(NSManagedObjectContext *currentContext))saveContext;

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  保存数据
 *
 *  @param saveContext 线程管理对象
 *  @param completion  完成回调
 */
+ (void)saveContext: (void(^)(NSManagedObjectContext *currentContext))saveContext
         completion: (void(^)(NSError *error))completion;

@end

#pragma mark - Create
@interface NSManagedObject (Create)

+ (id)cc_New;

+ (id)cc_NewInContext: (NSManagedObjectContext *)context;

+ (id)cc_NewOrUpdateWithData: (NSDictionary *)data
                   inContext: (NSManagedObjectContext *)context;

+ (NSArray *)cc_NewOrUpdateWithArray: (NSArray *)dataAry
                           inContext: (NSManagedObjectContext *)context;

+ (id)objctWithData: (NSDictionary *)data
        primaryKeys: (NSSet *)primaryKeys
          inContext: (NSManagedObjectContext *)context;

@end

#pragma mark - Queries
@interface NSManagedObject (Queries)

/**
 *  find a local object
 *
 *  @return the anyone object
 */
+ (id)cc_Anyone;
/**
 *  sync find all objects
 *
 *  @return all local objects
 */
+ (NSArray *)cc_All;

/**
 *  async find all objects
 *
 *  @param handler finished handler block
 */
+ (void)cc_AllWithHandler: (void (^)(NSError *, NSArray *))handler;

/**
 *  sync find objects where property is equal to a specification value
 *
 *  @param property priperty name
 *  @param value    expect value
 *
 *  @return all objects fit in this condition
 */
+ (NSArray *)cc_WhereProperty: (NSString *)property;

/**
 *  sync find objects where property is equal to a specification value
 *
 *  @param property property name
 *  @param value    expect value
 *  @param handler  finished handler block
 */
+ (void)cc_WhereProperty: (NSString *)property
                 equalTo: (id)value
                 handler: (void (^)(NSError *, NSArray *))handler;

/**
 *  sync find objects where property is equal to a specification value
 *
 *  @param property priperty name
 *  @param value    expect value
 *
 *  @return an object fit in this condition
 */
+ (id)cc_FirstWhereProperty: (NSString *)property
                    equalTo: (id)value;

/**
 *  sync find objects where property is equal to a specification value and sorted using a keypath
 *
 *  @param property  property name
 *  @param value     expect value
 *  @param keyPath   keypath
 *  @param ascending ascending
 *
 *  @return objects fit in this condition
 */
+ (NSArray *)cc_WhereProperty:(NSString *)property
                      equalTo:(id)value
                sortedKeyPath:(NSString *)keyPath
                    ascending:(BOOL)ascending;

/**
 *  async find objects where property is equal to a specification value and sorted using a keypath
 *
 *  @param property property name
 *  @param value    expect value
 *  @param keyPath  keypath
 *  @param ascendng ascending
 *  @param handler  finished fetch block
 */
+ (void)cc_WhereProperty: (NSString *)property
                 equalTo: (id)value
           sortedKeyPath: (NSString *)keyPath
               ascending: (BOOL)ascending
                 handler: (void (^)(NSError *, NSArray *))handler;

/**
 *  find all objects fit this predicate
 *
 *  @param predicate a specification NSPredicate
 *
 *  @return all objects fit this predicate
 */
+ (NSArray *)cc_AllWithPredicate: (NSPredicate *)predicate;

/**
 *  find an object fit this predicate
 *
 *  @param predicate a specification NSPredicate
 *
 *  @return an objects fit this predicate
 */
+ (id)cc_AnyoneWithPredicate: (NSPredicate *)predicate;

/**
 *  sync find objects where property is equal to a specification value and sorted using a keypath
 *
 *  @param property  property name
 *  @param value     exect value
 *  @param keyPath   keypath
 *  @param ascending ascending
 *  @param batchSize  batchSize to fetch
 *  @param fetchLimit fetch limit
 *
 *  @return objects fit in this condition
 */
+ (NSArray *)cc_WhereProperty: (NSString *)property
                      equalTo: (id)value
                sortedKeyPath: (NSString *)keyPath
                    ascending: (BOOL)ascending
               fetchBatchSize: (NSUInteger)batchSize
                   fetchLimit: (NSUInteger)fetchLimit
                  fetchOffset: (NSUInteger)fetchOffset;

/**
 *  async find objects where property is equal to a specification value and sorted using a keypath
 *
 *  @param property  property name
 *  @param value     exect value
 *  @param keyPath   keypath
 *  @param ascending ascending
 *  @param batchSize  batchSize to fetch
 *  @param fetchLimit fetch limit
 *  @param handler    finished fetch handler block
 */
+ (void)cc_WhereProperty: (NSString *)property
                 equalTo: (id)value
           sortedKeyPath: (NSString *)keyPath
               ascending: (BOOL)ascending
          fetchBatchSize: (NSUInteger)batchSize
              fetchLimit: (NSUInteger)fetchLimit
             fetchOffset: (NSUInteger)fetchOffset
                 handler: (void (^)(NSError *, NSArray *))handler;

/**
 *  sync find objects with vargars paramaters
 *
 *  @param condition like [NSString stringWithFormat:]
 *
 *  @return objects fit this condition
 */
+ (NSArray *)cc_Where: (NSString *)condition, ...;

/**
 *  sync find objects with vargars paramaters
 *
 *  @param keyPath     sorted keyPath
 *  @param ascending   ascending
 *  @param condition   vargars paramaters conditons
 *
 *  @return objects fit this condition
 */
+ (NSArray *)cc_SortedKeyPath: (NSString *)keyPath
                    ascending: (BOOL)ascending
                    batchSize: (NSUInteger)batchSize
                        where: (NSString *)condition, ...;

/**
 *  sync find objects with vargars paramaters
 *
 *  @param keyPath     sorted keyPath
 *  @param ascending   ascending
 *  @param batchSize   perform fetch batch size
 *  @param fetchLimit  max count of objects one time to fetch
 *  @param fetchOffset fetch offset
 *  @param condition   vargars paramaters conditons
 *
 *  @return objects fit this condition
 */
+ (NSArray *)cc_SortedKeyPath: (NSString *)keyPath
                    ascending: (BOOL)ascending
               fetchBatchSize: (NSUInteger)batchSize
                   fetchLimit: (NSUInteger)fetchLimit
                  fetchOffset: (NSUInteger)fetchOffset
                        where: (NSString *)condition, ...;

/**
 *  fetch count of all objects
 *
 *  @return the entity's count
 */
+ (NSUInteger)cc_Count;

/**
 *  fetch count of all objects in this condition
 *
 *  @param condition filter condition
 *
 *  @return count of objects
 */
+ (NSUInteger)cc_CountWhere: (NSString *)condition, ...;

@end
