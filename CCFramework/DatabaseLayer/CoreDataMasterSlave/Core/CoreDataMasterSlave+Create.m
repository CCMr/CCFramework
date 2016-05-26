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

@implementation CoreDataMasterSlave (Create)

/**
 *  @author CC, 2015-07-24
 *
 *  @brief  数据库新增
 *
 *  @param tableName 表名
 *  @param dataDic   对象
 *
 *  @since 1.0
 */
+ (void)cc_insertCoreData:(NSString *)tableName
                  DataDic:(NSDictionary *)dataDic
{
    [self cc_insertCoreData:tableName
                    DataDic:dataDic
                 completion:nil];
}

/**
 *  @author CC, 2015-10-30
 *  
 *  @brief  数据库新增
 *
 *  @param tableName  表名
 *  @param dataDic    新增数据
 *  @param completion 完成回调函数
 */
+ (void)cc_insertCoreData:(NSString *)tableName
                  DataDic:(NSDictionary *)dataDic
               completion:(void (^)(NSError *error))completion
{
    [self cc_insertCoreData:tableName
                  DataArray:@[ dataDic ]
                 completion:completion];
}


/**
 *  @author C C, 2015-10-25
 *
 *  @brief  新增对个对象
 *
 *  @param tableName 表名
 *  @param dataArray 新增数据
 */
+ (void)cc_insertCoreData:(NSString *)tableName
                DataArray:(NSArray *)dataArray
{
    if (!dataArray.count) return;
    
    [self cc_insertCoreData:tableName
                  DataArray:dataArray
                 completion:nil];
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  新增对个对象
 *
 *  @param tableName  表名
 *  @param dataArray  新增数据
 *  @param completion 完成回调函数
 */
+ (void)cc_insertCoreData:(NSString *)tableName
                DataArray:(NSArray *)dataArray
               completion:(void (^)(NSError *error))completion
{
    if (!dataArray.count) return;
    
    [self cc_saveAndWaitWithContextError:^(NSManagedObjectContext *currentContext) {
        for (NSDictionary *mapping in dataArray){
            
            NSManagedObject *entity = [NSEntityDescription insertNewObjectForEntityForName:tableName inManagedObjectContext:currentContext];
            
            NSArray *attributes = [entity allAttributeNames];
            NSArray *relationships = [entity allRelationshipNames];
            
            [mapping.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
                id remoteValue = [mapping objectForKey:key];
                if (remoteValue) {
                    if ([attributes containsObject:key]) {
                        [entity mergeAttributeForKey:key withValue:remoteValue];
                    }else if ([relationships containsObject:key]){
                        [entity mergeRelationshipForKey:key
                                              withValue:remoteValue
                                                  IsAdd:YES];
                        
                    }
                }
            }];
        }
        
    } completion:completion];
}

/**
 *  @author CC, 2015-10-30
 *  
 *  @brief  新增对象并且返回
 *
 *  @param tableName 表名
 *  @param dataDic   新增数据
 *
 *  @return 返回当前对象
 */
+ (id)cc_insertCoreDataWithDic:(NSString *)tableName
                       DataDic:(NSDictionary *)dataDic
{
    return [self cc_insertCoreDataWithArray:tableName
                                  DataArray:@[ dataDic ]].lastObject;
}


/**
 *  @author CC, 2015-10-30
 *  
 *  @brief  新增对象并且返回当前对象(字典)
 *
 *  @param tableName 表名
 *  @param dataArray 新增数据
 *
 *  @return 返回对象集合
 */
+ (NSArray *)cc_insertCoreDataWithArray:(NSString *)tableName
                              DataArray:(NSArray *)dataArray
{
    __block NSMutableArray *objs = [NSMutableArray array];
    [dataArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        NSManagedObject *managedObject =[self objctWithData:tableName 
                                                       Data:obj 
                                                  inContext:self.saveCurrentContext];
        [objs addObject:[managedObject changedDictionary]];
    }];
    return objs;
}

/**
 *  @author CC, 16-05-25
 *  
 *  @brief   新增对象并且返回当前对象
 *
 *  @param tableName 表名
 *  @param dataArray 新增数据
 *
 *  @return 返回对象集合
 */
+ (NSArray *)cc_insertCoreDataWithArrayObject:(NSString *)tableName
                                    DataArray:(NSArray *)dataArray
{
    __block NSMutableArray *objs = [NSMutableArray array];
    [dataArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        
        NSManagedObject *managedObject = [self objctWithData:tableName 
                                                        Data:obj 
                                                   inContext:self.saveCurrentContext];
        
        [objs addObject:managedObject];
    }];
    return objs;
}

/**
 *  @author CC, 2015-11-30
 *  
 *  @brief  新增或更新数据
 *
 *  @param tableName  表名
 *  @param primaryKey 主键
 *  @param data       数据源
 *
 *  @return 返回新增或更新对象
 */
+ (id)cc_insertOrUpdateWtihData:(NSString *)tableName
                     PrimaryKey:(NSString *)primaryKey
                       WithData:(NSDictionary *)data
{
    NSManagedObject *managedObject = [self cc_insertOrUpdateWtihData:tableName
                                                          PrimaryKey:primaryKey
                                                            WithData:data
                                                           inContext:self.currentContext];
    return [managedObject changedDictionary];
}

/**
 *  @author CC, 2015-11-30
 *  
 *  @brief  新增或更新数据
 *
 *  @param tableName  表名
 *  @param primaryKey 主键
 *  @param data       数据源
 *  @param context    管理对象
 *
 *  @return 返回新增或更新对象
 */
+ (id)cc_insertOrUpdateWtihData:(NSString *)tableName
                     PrimaryKey:(NSString *)primaryKey
                       WithData:(NSDictionary *)data
                      inContext:(NSManagedObjectContext *)context
{
    NSMutableArray *subPredicates = [NSMutableArray array];
    NSAttributeDescription *attributeDes = [[[NSEntityDescription entityForName:tableName inManagedObjectContext:context] attributesByName] objectForKey:primaryKey];
    id remoteValue = [data valueForKeyPath:primaryKey];
    if (attributeDes.attributeType == NSStringAttributeType) {
        remoteValue = [remoteValue description];
    } else {
        remoteValue = [NSNumber numberWithLongLong:[remoteValue longLongValue]];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", primaryKey, remoteValue];
    [subPredicates addObject:predicate];
    
    return [self objctWithData:tableName
                 SubPredicates:subPredicates
                          Data:data
                     inContext:context];
}

/**
 *  @author CC, 2015-11-30
 *  
 *  @brief  新增或更新数据
 *
 *  @param tableName  表名
 *  @param primaryKey 主键
 *  @param dataArray  数据集合
 *  @param context    管理对象
 *
 *  @return 返回新增或更新对象集
 */
+ (NSArray *)cc_insertOrUpdateWtihDataArray:(NSString *)tableName
                                 PrimaryKey:(NSString *)primaryKey
                              WithDataArray:(NSArray *)dataArray
{
    return [self cc_insertOrUpdateWtihDataArray:tableName
                                     PrimaryKey:primaryKey
                                  WithDataArray:dataArray
                                      inContext:self.saveCurrentContext];
}

/**
 *  @author CC, 2015-11-30
 *  
 *  @brief  新增或更新数据(字典)
 *
 *  @param tableName  表名
 *  @param primaryKey 主键
 *  @param dataArray  数据集合
 *  @param context    管理对象
 *
 *  @return 返回新增或更新对象集
 */
+ (NSArray *)cc_insertOrUpdateWtihDataArray:(NSString *)tableName
                                 PrimaryKey:(NSString *)primaryKey
                              WithDataArray:(NSArray *)dataArray
                                  inContext:(NSManagedObjectContext *)context
{
    __block NSMutableArray *array = [NSMutableArray array];
    [dataArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        
        NSManagedObject *managedObject = [self cc_insertOrUpdateWtihData:tableName 
                                                              PrimaryKey:primaryKey 
                                                                WithData:obj 
                                                               inContext:context];
        
        [array addObject:[managedObject changedDictionary]];
    }];
    return array;
}

/**
 *  @author CC, 16-05-25
 *  
 *  @brief  新增或更新数据(返回对象模型)
 *
 *  @param tableName  表名
 *  @param primaryKey 主键
 *  @param dataArray  数据集合
 *  @param context    管理对象
 *
 *  @return 返回新增或更新对象集
 */
+ (NSArray *)cc_insertOrUpdateWtihDataArrayObject:(NSString *)tableName
                                       PrimaryKey:(NSString *)primaryKey
                                    WithDataArray:(NSArray *)dataArray
                                        inContext:(NSManagedObjectContext *)context
{
    __block NSMutableArray *array = [NSMutableArray array];
    [dataArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        
        NSManagedObject *managedObject = [self cc_insertOrUpdateWtihData:tableName 
                                                              PrimaryKey:primaryKey 
                                                                WithData:obj 
                                                               inContext:context];
        
        [array addObject:managedObject];
    }];
    return array;
}


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
+ (id)objctWithData:(NSString *)tableName
               Data:(NSDictionary *)data
          inContext:(NSManagedObjectContext *)context
{
    __block NSManagedObject *entity = nil;
    @autoreleasepool
    {
        entity = [NSEntityDescription insertNewObjectForEntityForName:tableName inManagedObjectContext:context];
        
        NSArray *attributes = [entity allAttributeNames];
        NSArray *relationships = [entity allRelationshipNames];
        
        [data.allKeys enumerateObjectsUsingBlock:^(id _Nonnull key, NSUInteger idx, BOOL *_Nonnull stop) {
            id remoteValue = [data objectForKey:key];
            if (remoteValue) {
                if ([attributes containsObject:key]) {
                    [entity mergeAttributeForKey:key withValue:remoteValue];
                }else if ([relationships containsObject:key]){
                    [entity mergeRelationshipForKey:key
                                          withValue:remoteValue
                                              IsAdd:YES];
                    
                }
            }
        }];
    }
    return entity;
}

@end
