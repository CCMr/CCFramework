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


#import "CCCoreData.h"
#import "config.h"
#import "NSManagedObject+CCManagedObject.h"

@implementation NSManagedObject (Modify)

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  修改所有对象属性值
 *
 *  @param propertyName 属性名
 *  @param value        修改值
 */
+ (void)cc_UpdateProperty: (NSString *)propertyName
                  toValue: (id)value
{
    [self cc_UpdateProperty:propertyName
                    toValue:value
                      where:nil];
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  修改条件对象属性值
 *
 *  @param propertyName 属性名
 *  @param value        修改值
 *  @param condition    条件
 */
+ (void)cc_UpdateProperty: (NSString *)propertyName
                  toValue: (id)value
                    where: (NSString *)condition
{
    [self cc_UpdateProperty:propertyName
                    toValue:value
                      where:condition
                 completion:nil];
}

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
+ (void)cc_UpdateProperty: (NSString *)propertyName
                  toValue: (id)value
                    where: (NSString *)condition
               completion: (void(^)(NSError *error))completion
{
    if(CURRENT_SYS_VERSION > 8.0){
        [self saveContext:^(NSManagedObjectContext *currentContext) {
            NSBatchUpdateRequest *batchRequest = [NSBatchUpdateRequest batchUpdateRequestWithEntityName:[self cc_EntityName]];
            batchRequest.propertiesToUpdate = @{propertyName:value};
            batchRequest.resultType = NSUpdatedObjectIDsResultType;
            batchRequest.affectedStores = [[currentContext persistentStoreCoordinator] persistentStores];
            if (condition) {
                batchRequest.predicate = [NSPredicate predicateWithFormat:condition];
            }
            
            NSError *requestError;
            NSBatchUpdateResult *result = (NSBatchUpdateResult *)[currentContext executeRequest:batchRequest error:&requestError];
            
            if ([[result result] respondsToSelector:@selector(count)]){
                if ([[result result] count] > 0){
                    for (NSManagedObjectID *objectID in [result result]){
                        NSError         *faultError = nil;
                        NSManagedObject *object     = [currentContext existingObjectWithID:objectID error:&faultError];
                        // Observers of this context will be notified to refresh this object.
                        // If it was deleted, well.... not so much.
                        [currentContext refreshObject:object mergeChanges:YES];
                    }
                } else {
                    // We got back nothing!
                }
            } else {
                // We got back something other than a collection
            }
        }];
    }else{
        [self cc_UpdateKeyPath: propertyName
                       toValue: value
                         where: condition];
    }
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  修改多属性
 *
 *  @param propertyKeyValue 属性与值
 *  @param condition        条件
 */
+ (void)cc_UpdateMultiProperty: (NSDictionary *)propertyKeyValue
                         where: (NSString *)condition
{
    [self cc_UpdateMultiProperty:propertyKeyValue
                           where:condition
                      completion:nil];
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  修改对属性
 *
 *  @param propertyKeyValue 属性与值
 *  @param condition        条件
 *  @param completion       完成回调函数
 */
+ (void)cc_UpdateMultiProperty: (NSDictionary *)propertyKeyValue
                         where: (NSString *)condition
                    completion: (void(^)(NSError *error))completion
{
    [self saveContext: ^(NSManagedObjectContext *currentContext) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self cc_EntityName]];
        if (condition) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:condition];
            fetchRequest.predicate = predicate;
        }
        
        __block NSError *error = nil;
        NSArray *allObjects = [currentContext executeFetchRequest:fetchRequest error:&error];
        if (allObjects) {
            [allObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                [propertyKeyValue.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull propertyObj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([[obj allKeys] containsObject:propertyObj]) { //待完善子项修改
                        [obj setObject:[propertyKeyValue objectForKey:propertyObj] forKey:propertyObj];
                    }
                }];
                
            }];
        }
    } completion:completion];
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  修改所有对象属性值
 *
 *  @param keyPath 属性名
 *  @param value   值
 */
+ (void)cc_UpdateKeyPath: (NSString *)keyPath
                 toValue: (id)value
{
    [self cc_UpdateKeyPath:keyPath
                   toValue:value
                     where:nil];
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  修改所有对象属性值
 *
 *  @param keyPath   属性名
 *  @param value     值
 *  @param condition 条件
 */
+ (void)cc_UpdateKeyPath: (NSString *)keyPath
                 toValue: (id)value
                   where: (NSString *)condition
{
    [self cc_UpdateKeyPath:keyPath
                   toValue:value
                     where:condition
                completion:nil];
}

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
+ (void)cc_UpdateKeyPath: (NSString *)keyPath
                 toValue: (id)value
                   where: (NSString *)condition
              completion: (void(^)(NSError *error))completion
{
    [self saveContext:^(NSManagedObjectContext *currentContext) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self cc_EntityName]];
        if (condition) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:condition];
            fetchRequest.predicate = predicate;
        }
        __block NSError *error = nil;
        NSArray *allObjects = [currentContext executeFetchRequest:fetchRequest error:&error];
        if (allObjects != nil) {
            [allObjects enumerateObjectsUsingBlock:^(NSManagedObject *obj, NSUInteger idx, BOOL *stop) {
                [obj setValue:value forKey:keyPath];
            }];
        }else{
            NSLog(@"%s fetch error is %@",__PRETTY_FUNCTION__,error);
        }
    } completion:completion];
}

@end
