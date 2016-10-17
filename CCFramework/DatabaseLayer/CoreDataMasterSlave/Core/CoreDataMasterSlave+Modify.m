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
#import "NSManagedObject+Additions.h"

@implementation CoreDataMasterSlave (Modify)

/**
 批量修改属性值
 
 @param tableName 表名
 @param columnDic 更新键值
 */
+ (void)cc_batchUpdataCoredData:(NSString *)tableName
                 ColumnKeyValue:(NSDictionary *)columnDic
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:tableName
                                                         inManagedObjectContext:self.currentContext];
    
    // Initialize Batch Update Request
    NSBatchUpdateRequest *batchUpdateRequest = [[NSBatchUpdateRequest alloc] initWithEntity:entityDescription];
    
    // Configure Batch Update Request
    [batchUpdateRequest setResultType:NSUpdatedObjectIDsResultType];
    [batchUpdateRequest setPropertiesToUpdate:columnDic];
    
    // Execute Batch Request
    NSError *batchUpdateRequestError = nil;
    NSBatchUpdateResult *batchUpdateResult = (NSBatchUpdateResult *)[self.currentContext executeRequest:batchUpdateRequest
                                                                                                  error:&batchUpdateRequestError];
    
    if (batchUpdateRequestError) {
        NSLog(@"%@, %@", batchUpdateRequestError, batchUpdateRequestError.localizedDescription);
    } else {
        // Extract Object IDs
        NSArray *objectIDs = batchUpdateResult.result;
        
        for (NSManagedObjectID *objectID in objectIDs) {
            // Turn Managed Objects into Faults
            NSManagedObject *managedObject = [self.currentContext objectWithID:objectID];
            
            if (managedObject) {
                [self.currentContext refreshObject:managedObject mergeChanges:NO];
            }
        }
    }
}


/**
 修改数据
 及其子对象数据
 
 @param tableName 表名
 @param condition 修改条件
 @param editData  编辑键值
 */
+(void)cc_updateCoreData:(NSString *)tableName 
               Condition:(NSPredicate *)condition 
                EditData:(NSDictionary *)editData
{
    [self cc_updateCoreData:tableName 
                  Condition:condition 
                   EditData:editData 
                 Completion:nil];
}


/**
 修改数据
 及其子对象数据
 
 @param tableName  表名
 @param condition  修改条件
 @param editData   编辑键值
 @param completion 完成回调
 */
+(void)cc_updateCoreData:(NSString *)tableName 
               Condition:(NSPredicate *)condition
                EditData:(NSDictionary *)editData 
              Completion:(void (^)(NSError *error))completion
{
    [self cc_saveContext:^(NSManagedObjectContext *currentContext) {
        NSFetchRequest *fetchRequest = [self cc_AllRequest:tableName];
        [fetchRequest setPredicate:condition];
        [fetchRequest setReturnsObjectsAsFaults:NO];
        
        NSError *error = nil;
        NSArray *datas = [currentContext executeFetchRequest:fetchRequest error:&error];
        if (!error && datas && [datas count]) {
            [datas enumerateObjectsUsingBlock:^(id entity, NSUInteger idx, BOOL *stop) {
                
                NSArray *attributes = [entity allAttributeNames];
                NSArray *relationships = [entity allRelationshipNames];
                
                [editData enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    id remoteValue = obj;
                    if (remoteValue) {
                        if ([attributes containsObject:key]) {
                            [entity mergeAttributeForKey:key
                                               withValue:remoteValue];
                            
                        }else if ([relationships containsObject:key]) {
                            [entity mergeRelationshipForKey:key
                                                  withValue:remoteValue
                                                      IsAdd:NO];
                        }
                    }
                }];
            }];
        }
    } completion:completion];
}

/**
 主键修改数据对象及子项
 
 @param tableName   表名
 @param conditionID 主键ID
 @param editData    编辑数据键值
 */
+ (void)cc_updateCoreData:(NSString *)tableName
              ConditionID:(NSManagedObjectID *)conditionID
                 EditData:(NSDictionary *)editData
{
    [self cc_updateCoreData:tableName
                ConditionID:conditionID
                   EditData:editData
                 Completion:nil];
}

/**
 主键修改数据对象及子项
 
 @param tableName   表名
 @param conditionID 主键ID
 @param editData    编辑数据键值
 @param completion  完成回调
 */
+ (void)cc_updateCoreData:(NSString *)tableName
              ConditionID:(NSManagedObjectID *)conditionID
                 EditData:(NSDictionary *)editData
               Completion:(void (^)(NSError *error))completion
{
    [self cc_saveAndWaitWithContextError:^(NSManagedObjectContext *currentContext) {
        
        NSFetchRequest *fetchRequest = [self cc_AllRequest:tableName];
        NSError *error = nil;
        NSArray *datas =
        [currentContext executeFetchRequest:fetchRequest error:&error];
        if (!error && datas && [datas count]) {
            [datas enumerateObjectsUsingBlock:^(id entity, NSUInteger idx, BOOL *stop) {
                if ([((NSManagedObject *)entity).objectID isEqual:conditionID]) {
                    
                    NSArray *attributes = [entity allAttributeNames];
                    NSArray *relationships = [entity allRelationshipNames];
                    
                    [editData enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                        id remoteValue = obj;
                        if (remoteValue) {
                            if ([attributes containsObject:key]) {
                                [entity mergeAttributeForKey:key
                                                   withValue:remoteValue];
                                
                            }else if ([relationships containsObject:key]) {
                                [entity mergeRelationshipForKey:key
                                                      withValue:remoteValue
                                                          IsAdd:NO];
                            }
                        }
                    }];
                }
            }];
        }
        
    } completion:completion];
}


/**
 更新或插入数据
 根据条件先查询符合条件就修改数据对象，不符合就插入数据
 
 @param tableName 表名
 @param predicate 条件
 @param data      更新键值
 */
+(void)cc_updateORInsertCoreData:(NSString *)tableName
                       Predicate:(NSPredicate *)predicate
                            Data:(NSDictionary *)data
{
    [self cc_updateORInsertCoreData:tableName 
                          Predicate:predicate 
                               Data:data 
                       CallbackData:nil];
}

/**
 更新或插入数据
 根据条件先查询符合条件就修改数据对象，不符合就插入数据
 
 @param tableName 表名
 @param predicate 条件
 @param data      更新键值
 @param completion 完成回调
 */
+(void)cc_updateORInsertCoreData:(NSString *)tableName
                       Predicate:(NSPredicate *)predicate
                            Data:(NSDictionary *)data
                      Completion:(void (^)(NSError *error))completion
{
    [self cc_updateORInsertCoreData:tableName 
                          Predicate:predicate 
                               Data:data 
                       CallbackData:nil 
                         Completion:completion];
}

/**
 更新或插入数据
 根据条件先查询符合条件就修改数据对象，不符合就插入数据
 
 @param tableName 表名
 @param predicate 条件
 @param data      更新键值
 @param callbackDataArr 回调执行后对象集合
 */
+(void)cc_updateORInsertCoreData:(NSString *)tableName
                       Predicate:(NSPredicate *)predicate
                            Data:(NSDictionary *)data
                    CallbackData:(void (^)(NSDictionary *data))callbackData
{
    [self cc_updateORInsertCoreData:tableName 
                          Predicate:predicate 
                               Data:data 
                       CallbackData:callbackData
                         Completion:nil];
}

/**
 更新或插入数据
 根据条件先查询符合条件就修改数据对象，不符合就插入数据
 
 @param tableName 表名
 @param predicate 条件
 @param data      更新键值
 @param callbackDataArr 回调执行后对象集合
 @param completion 完成回调
 */
+(void)cc_updateORInsertCoreData:(NSString *)tableName
                       Predicate:(NSPredicate *)predicate
                            Data:(NSDictionary *)data
                    CallbackData:(void (^)(NSDictionary *data))callbackData
                      Completion:(void (^)(NSError *error))completion
{
    [self cc_saveContext:^(NSManagedObjectContext *currentContext) {
        NSManagedObject *managedObject = [self objctWithData:tableName
                                               SubPredicates:@[ predicate ]
                                                        Data:data
                                                   inContext:currentContext];
        if (managedObject) {
            callbackData?callbackData([managedObject changedDictionary]):nil;
        }
    } completion:completion];
}


/**
 批量更新或新增数据
 
 @param tableName       表名
 @param predicateArr    条件
 @param dataArr         集合
 @param callbackDataArr 完成数据
 */
+(void)cc_updateORInsertCoreData:(NSString *)tableName
                    PredicateArr:(NSArray *)predicateArr
                         DataArr:(NSArray *)dataArr
                 CallbackDataArr:(void (^)(NSArray *dataArr))callbackDataArr
{
    [self cc_updateORInsertCoreData:tableName
                       PredicateArr:predicateArr
                            DataArr:dataArr 
                    CallbackDataArr:callbackDataArr
                         Completion:nil];
}


/**
 批量更新或新增数据
 
 @param tableName       表名
 @param predicateArr    条件
 @param dataArr         集合
 @param callbackDataArr 完成数据
 @param completion      完成回调
 */
+(void)cc_updateORInsertCoreData:(NSString *)tableName
                    PredicateArr:(NSArray *)predicateArr
                         DataArr:(NSArray *)dataArr
                 CallbackDataArr:(void (^)(NSArray *dataArr))callbackDataArr
                      Completion:(void (^)(NSError *error))completion
{
    [self cc_saveContext:^(NSManagedObjectContext *currentContext) {
        NSMutableArray *dataArray = [NSMutableArray array];
        for (NSInteger idx = 0; idx <dataArr.count; idx++) {
            
            NSPredicate *predicate = [predicateArr objectAtIndex:idx];
            NSDictionary *data = [dataArr objectAtIndex:idx];
            NSManagedObject *managedObject = [self objctWithData:tableName
                                                   SubPredicates:@[ predicate ]
                                                            Data:data
                                                       inContext:currentContext];
            if (managedObject)
                [dataArray addObject:[managedObject changedDictionary]];
        }
        callbackDataArr?callbackDataArr(dataArray):nil;
    } completion:completion];
}

/**
 更新或插入数据
 根据主键与主键值
 
 @param tableName    表名
 @param primaryKey   主键
 @param primaryValue 主键值
 @param data         更新数据
 */
+ (void)cc_updateORInsertCoreData:(NSString *)tableName
                       PrimaryKey:(NSString *)primaryKey
                          DataArr:(NSArray *)dataArr
{
    [self cc_updateORInsertCoreData:tableName
                         PrimaryKey:primaryKey
                            DataArr:dataArr Completion:nil];
}


/**
 更新或插入数据
 根据主键与主键值
 
 @param tableName    表名
 @param primaryKey   主键
 @param primaryValue 主键值
 @param data         更新数据
 @param completion   完成回调
 */
+ (void)cc_updateORInsertCoreData:(NSString *)tableName
                       PrimaryKey:(NSString *)primaryKey
                          DataArr:(NSArray *)dataArr
                       Completion:(void (^)(NSError *error))completion
{
    [self cc_updateORInsertCoreData:tableName 
                         PrimaryKey:primaryKey
                            DataArr:dataArr 
                    CallbackDataArr:nil 
                         Completion:completion];
}


/**
 更新或插入数据
 根据主键与主键值
 
 @param tableName       表名
 @param primaryKey      主键
 @param dataArr         对象集合
 @param callbackDataArr 回调执行后对象集合
 */
+ (void)cc_updateORInsertCoreData:(NSString *)tableName
                       PrimaryKey:(NSString *)primaryKey
                          DataArr:(NSArray *)dataArr
                  CallbackDataArr:(void (^)(NSArray *dataArr))callbackDataArr
{
    [self cc_updateORInsertCoreData:tableName 
                         PrimaryKey:primaryKey 
                            DataArr:dataArr 
                    CallbackDataArr:callbackDataArr
                         Completion:nil];
}


/**
 更新或插入数据
 根据主键与主键值
 
 @param tableName       表名
 @param primaryKey      主键
 @param dataArr         对象集合
 @param callbackDataArr 回调执行后对象集合
 @param completion      完成回调
 */
+ (void)cc_updateORInsertCoreData:(NSString *)tableName
                       PrimaryKey:(NSString *)primaryKey
                          DataArr:(NSArray *)dataArr
                  CallbackDataArr:(void (^)(NSArray *dataArr))callbackDataArr
                       Completion:(void (^)(NSError *error))completion
{
    [self cc_saveContext:^(NSManagedObjectContext *currentContext) {
        NSMutableArray *dataArray = [NSMutableArray array];
        for (NSDictionary *data in dataArr) {
            NSManagedObject *managedObject = [self objctWithData:tableName
                                                     PrimaryKeys:primaryKey
                                                            Data:data
                                                       inContext:currentContext];
            
            if (managedObject)
                [dataArray addObject:[managedObject changedDictionary]];
        }
        callbackDataArr?callbackDataArr(dataArray):nil;
    } completion:completion];
}

/**
 更新或插入数据
 根据主键与主键值
 
 @param tableName    表名
 @param primaryKey   主键
 @param primaryValue 主键值
 @param data         更新数据
 */
+ (void)cc_updateORInsertCoreData:(NSString *)tableName
                       PrimaryKey:(NSString *)primaryKey
                             Data:(NSDictionary *)data
{
    [self cc_updateORInsertCoreData:tableName 
                         PrimaryKey:primaryKey 
                               Data:data
                       CallbackData:nil];
}

/**
 更新或插入数据
 根据主键与主键值
 
 @param tableName    表名
 @param primaryKey   主键
 @param primaryValue 主键值
 @param data         更新数据
 @param Completion   完成回调
 */
+ (void)cc_updateORInsertCoreData:(NSString *)tableName
                       PrimaryKey:(NSString *)primaryKey
                             Data:(NSDictionary *)data
                       Completion:(void (^)(NSError *error))completion
{
    [self cc_updateORInsertCoreData:tableName 
                         PrimaryKey:primaryKey 
                               Data:data
                       CallbackData:nil
                         Completion:completion];
}

/**
 更新或插入数据
 根据主键与主键值
 
 @param tableName    表名
 @param primaryKey   主键
 @param data         数据对象
 @param callbackData 回调执行后对象
 */
+ (void)cc_updateORInsertCoreData:(NSString *)tableName
                       PrimaryKey:(NSString *)primaryKey
                             Data:(NSDictionary *)data
                     CallbackData:(void (^)(NSDictionary *data))callbackData
{
    [self cc_updateORInsertCoreData:tableName 
                         PrimaryKey:primaryKey 
                               Data:data
                       CallbackData:callbackData
                         Completion:nil];
}

/**
 更新或插入数据
 根据主键与主键值
 
 @param tableName    表名
 @param primaryKey   主键
 @param primaryValue 主键值
 @param data         更新数据
 @param callbackData 回调执行后对象
 @param completion   完成回调
 */
+ (void)cc_updateORInsertCoreData:(NSString *)tableName
                       PrimaryKey:(NSString *)primaryKey
                             Data:(NSDictionary *)data
                     CallbackData:(void (^)(NSDictionary *data))callbackData
                       Completion:(void (^)(NSError *error))completion
{
    [self cc_saveContext:^(NSManagedObjectContext *currentContext) {
        NSManagedObject *managedObject = [self objctWithData:tableName
                                                 PrimaryKeys:primaryKey
                                                        Data:data
                                                   inContext:currentContext];
        if (managedObject) {
            callbackData?callbackData([managedObject changedDictionary]):nil;
        }
    } completion:completion];
}


/**
 *  @author CC, 2015-11-05
 *
 *  @brief  更新或新增数据
 *
 *  @param tableName   表名
 *  @param primaryKeys 主键
 *  @param data        数据源
 *  @param context     管理对象
 *
 *  @return 返回更新或创建
 */
+ (id)objctWithData:(NSString *)tableName
        PrimaryKeys:(NSString *)primaryKeys
               Data:(NSDictionary *)data
          inContext:(NSManagedObjectContext *)context
{
    
    NSMutableArray *subPredicates = [NSMutableArray array];
    NSAttributeDescription *attributeDes = [[[NSEntityDescription entityForName:tableName inManagedObjectContext:context] attributesByName] objectForKey:primaryKeys];
    id remoteValue = [data valueForKeyPath:primaryKeys];
    if (attributeDes.attributeType == NSStringAttributeType) {
        remoteValue = [remoteValue description];
    } else {
        remoteValue = [NSNumber numberWithLongLong:[remoteValue longLongValue]];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", primaryKeys, remoteValue];
    [subPredicates addObject:predicate];
    
    return [self objctWithData:tableName
                 SubPredicates:subPredicates
                          Data:data
                     inContext:context];
}

/**
 *  @author CC, 2015-11-23
 *
 *  @brief  更新或新增数据
 *
 *  @param tableName     表名
 *  @param subPredicates 条件
 *  @param data          数据源
 *  @param context       管理对象
 *
 *  @return 返回更新或创建
 */
+ (id)objctWithData:(NSString *)tableName
      SubPredicates:(NSArray *)subPredicates
               Data:(NSDictionary *)data
          inContext:(NSManagedObjectContext *)context
{
    __block NSManagedObject *entity = nil;
    @autoreleasepool
    {
        NSCompoundPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:tableName];
        fetchRequest.fetchLimit = 1;
        fetchRequest.resultType = NSManagedObjectIDResultType;
        [fetchRequest setPredicate:compoundPredicate];
        
        NSManagedObjectID *objectID = [[context executeFetchRequest:fetchRequest error:nil] firstObject];
        BOOL IsAdd;
        if (objectID) {
            IsAdd = NO;
            entity = [context existingObjectWithID:objectID
                                             error:nil];
        } else {
            entity = [NSEntityDescription insertNewObjectForEntityForName:tableName
                                                   inManagedObjectContext:context];
            IsAdd = YES;
        }
        
        NSArray *attributes = [entity allAttributeNames];
        NSArray *relationships = [entity allRelationshipNames];
        
        [data enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
            id remoteValue = obj;
            if (remoteValue) {
                if ([attributes containsObject:key]) {
                    [entity mergeAttributeForKey:key
                                       withValue:remoteValue];
                    
                }else if ([relationships containsObject:key]) {
                    [entity mergeRelationshipForKey:key
                                          withValue:remoteValue
                                              IsAdd:IsAdd];
                }
            }
        }];
    }
    return entity;
}

@end
