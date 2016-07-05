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

@implementation CoreDataMasterSlave (Removed)

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  删除所有对象
 */
+ (void)cc_RemovedAll:(NSString *)tableName
{
    [self cc_RemovedAll:tableName
             completion:nil];
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  删除所有对象
 *
 *  @param completion 完成回调函数
 */
+ (void)cc_RemovedAll:(NSString *)tableName
           completion:(void (^)(NSError *error))completion
{
    [self cc_saveAndWaitWithContextError:^(NSManagedObjectContext *currentContext) {
        NSFetchRequest *request = [self cc_AllRequest:tableName];
        [request setReturnsObjectsAsFaults:YES];
        [request setIncludesPropertyValues:NO];
        
        NSError *error = nil;
        NSArray *objsToDelete = [currentContext executeFetchRequest:request error:&error];
        [objsToDelete enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [currentContext deleteObject:obj];
        }];
    } completion:completion];
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  删除对象
 *
 *  @param conditionID 对象ID
 */
+ (void)cc_RemovedManagedObjectID:(NSString *)tableName
                  ManagedObjectID:(NSManagedObjectID *)conditionID
{
    [self cc_RemovedManagedObjectID:tableName
                    ManagedObjectID:conditionID
                         completion:nil];
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  删除对象
 *
 *  @param conditionID 对象ID
 *  @param completion  完成回调函数
 */
+ (void)cc_RemovedManagedObjectID:(NSString *)tableName
                  ManagedObjectID:(NSManagedObjectID *)conditionID
                       completion:(void (^)(NSError *error))completion
{
    [self cc_RemovedManagedObjectIds:tableName
                     ManagedObjectId:@[ conditionID ]
                          completion:completion];
}

/**
 *  @author CC, 2015-11-16
 *  
 *  @brief  删除对象
 *
 *  @param tableName     表名
 *  @param arrayObjectID 集合对象ObjectID
 */
+ (void)cc_RemovedManagedObjectIds:(NSString *)tableName
                   ManagedObjectId:(NSArray *)arrayObjectID
{
    [self cc_RemovedManagedObjectIds:tableName
                     ManagedObjectId:arrayObjectID
                          completion:nil];
}

/**
 *  @author CC, 2015-11-16
 *  
 *  @brief  删除对象
 *
 *  @param tableName     表名
 *  @param arrayObjectID 集合对象ObjectID
 *  @param completion    完成回调
 */
+ (void)cc_RemovedManagedObjectIds:(NSString *)tableName
                   ManagedObjectId:(NSArray *)arrayObjectID
                        completion:(void (^)(NSError *error))completion
{
    [self cc_saveAndWaitWithContextError:^(NSManagedObjectContext *currentContext) {
        NSFetchRequest *request = [self cc_AllRequest:tableName];
        [request setReturnsObjectsAsFaults:YES];
        [request setIncludesPropertyValues:NO];
        
        NSError *error = nil;
        NSArray *objsToDelete = [currentContext executeFetchRequest:request error:&error];
        
        [arrayObjectID enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id pd = [objsToDelete filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"objectID = %@",obj]];
            if (pd){
                [pd enumerateObjectsUsingBlock:^(id  _Nonnull Pdobj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [currentContext deleteObject:Pdobj];
                }];
            }
        }];
    } completion:completion];
}

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  条件删除数据
 *
 *  @param tableName 表名
 *  @param condition 条件
 */
+ (void)cc_RemovedWithCondition:(NSString *)tableName
                      Condition:(NSPredicate *)condition
{
    [self cc_RemovedWithCondition:tableName
                        Condition:condition
                       Completion:nil];
}

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  条件删除数据
 *
 *  @param tableName 表名
 *  @param condition 条件
 */
+ (void)cc_RemovedWithCondition:(NSString *)tableName
                      Condition:(NSPredicate *)condition
                     Completion:(void (^)(NSError *error))completion
{
    [self cc_saveAndWaitWithContextError:^(NSManagedObjectContext *currentContext) {
        
        NSFetchRequest *fetchRequest = [self cc_AllRequest:tableName];
        if (condition)
            [fetchRequest setPredicate:condition];
        
        __block NSError *error = nil;
        NSArray *allObjects = [currentContext executeFetchRequest:fetchRequest error:&error];
        [allObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [currentContext deleteObject:obj];
        }];
    } completion:completion];
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  删除对象
 *
 *  @param propertyName 属性名
 *  @param value        属性值
 */
+ (void)cc_RemovedProperty:(NSString *)tableName
              PropertyName:(NSString *)propertyName
                   toValue:(id)value
{
    [self cc_RemovedMultiProperty:tableName
                    MultiProperty:@{propertyName : value}];
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  多属性删除
 *
 *  @param propertyKeyValues 属性名与值
 */
+ (void)cc_RemovedMultiProperty:(NSString *)tableName
                  MultiProperty:(NSDictionary *)propertyKeyValues
{
    [self cc_RemovedMultiProperty:tableName
                    MultiProperty:propertyKeyValues
                       completion:nil];
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  多属性删除
 *
 *  @param propertyKeyValues 属性名与值
 *  @param completion        完成回调函数
 */
+ (void)cc_RemovedMultiProperty:(NSString *)tableName
                  MultiProperty:(NSDictionary *)propertyKeyValues
                     completion:(void (^)(NSError *error))completion
{
    [self cc_saveAndWaitWithContextError:^(NSManagedObjectContext *currentContext) {
        
        NSFetchRequest *fetchRequest = [self cc_AllRequest:tableName];
        if (propertyKeyValues) {
            NSMutableString *conditions = [NSMutableString string];
            for (NSString *key in propertyKeyValues.allKeys)
                [conditions appendFormat:@"%@ = %@ AND ",key,[propertyKeyValues objectForKey:key]];
            
            NSString *condition = [conditions substringToIndex:conditions.length + 4];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:condition];
            fetchRequest.predicate = predicate;
        }
        
        __block NSError *error = nil;
        NSArray *allObjects = [currentContext executeFetchRequest:fetchRequest error:&error];
        [allObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [currentContext deleteObject:obj];
        }];
        
    } completion:completion];
}

/**
 *  @author CC, 16-05-20
 *  
 *  @brief  删除多条数据(根据key与value)
 *
 *  @param tableName          表名
 *  @param conditionKeyValues 属性名与值
 */
+ (void)cc_RemovedMultipleCondition:(NSString *)tableName
                     MultiCondition:(NSArray *)conditionKeyValues
{
    [self cc_RemovedMultipleCondition:tableName
                       MultiCondition:conditionKeyValues
                           completion:nil];
}

/**
 *  @author CC, 16-05-20
 *  
 *  @brief  删除多条数据(根据key与value)
 *
 *  @param tableName          表名
 *  @param conditionKeyValues 属性名与值
 *  @param completion         完成回调函数
 */
+ (void)cc_RemovedMultipleCondition:(NSString *)tableName
                     MultiCondition:(NSArray *)conditionKeyValues
                         completion:(void (^)(NSError *error))completion
{
    [self cc_saveAndWaitWithContextError:^(NSManagedObjectContext *currentContext) {
        NSFetchRequest *fetchRequest = [self cc_AllRequest:tableName];
        
        __block NSError *error = nil;
        NSArray *allObjects = [currentContext executeFetchRequest:fetchRequest error:&error];
        [allObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [conditionKeyValues enumerateObjectsUsingBlock:^(id  _Nonnull dobj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                NSDictionary *dic = dobj;
                __block NSInteger bolCount = 0;
                [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
                    if ([obj compareKeyValue:key withValue:value])
                        bolCount++;
                }];
                
                if (dic.allKeys.count == bolCount)
                    [currentContext deleteObject:obj];   
            }];
            
            
        }];
        
    } completion:completion];
}

@end
