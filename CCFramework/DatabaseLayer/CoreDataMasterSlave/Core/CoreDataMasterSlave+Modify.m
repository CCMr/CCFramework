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

@implementation CoreDataMasterSlave (Modify)

/**
 *  @author 2015-10-25
 *
 *  @brief  批量修改属性值
 *
 *  @param tableName 表名
 *  @param key       字段名
 *  @param value     字段值
 */
-(void)batchUpdataCoredData: (NSString *)tableName
             ColumnKeyValue: (NSDictionary *)columnDic
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:tableName inManagedObjectContext:self.currentContext];
    
    // Initialize Batch Update Request
    NSBatchUpdateRequest *batchUpdateRequest = [[NSBatchUpdateRequest alloc] initWithEntity:entityDescription];
    
    // Configure Batch Update Request
    [batchUpdateRequest setResultType:NSUpdatedObjectIDsResultType];
    [batchUpdateRequest setPropertiesToUpdate:columnDic];
    
    // Execute Batch Request
    NSError *batchUpdateRequestError = nil;
    NSBatchUpdateResult *batchUpdateResult = (NSBatchUpdateResult *)[self.currentContext executeRequest:batchUpdateRequest error:&batchUpdateRequestError];
    
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
 *  @author CC, 2015-10-25
 *
 *  @brief  修改对象及子项
 *          操作方式 属性 条件 值（editDataArray 对象中获取Key值）
 *
 *  @param tableName      表名
 *  @param conditionKey   条件字段
 *  @param condition      条件
 *  @param conditionValue 条件值的Key
 *  @param editDataArray  编辑的对象
 */
- (void)updateCoreData: (NSString *)tableName
          ConditionKey: (NSString *)conditionKey
             Condition: (NSString *)condition
        ConditionValue: (NSString *)conditionValue
         EditDataArray: (NSArray *)editDataArray
{
    if (!editDataArray.count) return;
    
    [self updateCoreData: tableName
            ConditionKey: conditionKey
               Condition: condition
          ConditionValue: conditionKey
           EditDataArray: editDataArray
              completion: nil];
   
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  修改对象及子项
 *
 *  @param tableName      表名
 *  @param conditionKey   条件字段
 *  @param condition      条件
 *  @param conditionValue 条件值
 *  @param editDataArray  编辑属性
 *  @param completion     完成回调函数
 */
- (void)updateCoreData: (NSString *)tableName
          ConditionKey: (NSString *)conditionKey
             Condition: (NSString *)condition
        ConditionValue: (NSString *)conditionValue
         EditDataArray: (NSArray *)editDataArray
            completion: (void(^)(NSError *error))completion
{
    if (!editDataArray.count) return;
    
    [self saveContext:^(NSManagedObjectContext *currentContext) {
        for (NSDictionary *endtDic in editDataArray)
        {
            NSFetchRequest *fetchRequest = [self cc_AllRequest:tableName];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ %@ '%@'",conditionKey,condition,[endtDic objectForKey:conditionValue]]]];
            [fetchRequest setReturnsObjectsAsFaults:NO];
            
            NSError *error = nil;
            NSArray *datas = [currentContext executeFetchRequest:fetchRequest error:&error];
            if (!error && datas && [datas count]) {
                [datas enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    for (NSString *key in endtDic.allKeys)
                    {
                        if ([[endtDic objectForKey:key] isKindOfClass:[NSArray class]])
                        {
                            NSRelationshipDescription *relationship = [[[NSEntityDescription entityForName:tableName inManagedObjectContext:currentContext] relationshipsByName] objectForKey:key];
                            for (NSDictionary *childDic in [endtDic objectForKey:key])
                            {
                                [self updateCoreData: [[relationship destinationEntity] name]
                                         ConditionID: [childDic objectForKey:@"objectID"]
                                            EditData: childDic];
                            }
                        }else
                            [obj setValue:[endtDic objectForKey:key] forKey:key];
                    }
                }];
            }
        }
    } completion:completion];
}

/**
 *  @author CC, 2015-07-24
 *
 *  @brief  对整个对象修改
 *
 *  @param tableName 表名
 *  @param condition 查询条件
 *  @param editData  修改对象
 *
 *  @since 1.0
 */
- (void)updateCoreData: (NSString *)tableName
             Condition: (NSString *)condition
              EditData: (NSDictionary *)editData
{
    [self updateCoreData: tableName
               Condition: condition
                EditData: editData
              completion: nil];
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  修改对象及子项
 *
 *  @param tableName  表名
 *  @param condition  条件
 *  @param editData   编辑属性
 *  @param completion 完成回调函数
 */
- (void)updateCoreData: (NSString *)tableName
             Condition: (NSString *)condition
              EditData: (NSDictionary *)editData
            completion: (void(^)(NSError *error))completion
{
    [self saveContext:^(NSManagedObjectContext *currentContext) {
        
        NSFetchRequest *fetchRequest = [self cc_AllRequest:tableName];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:condition]];
        [fetchRequest setReturnsObjectsAsFaults:NO];
        
        NSError *error = nil;
        NSArray *datas = [currentContext executeFetchRequest:fetchRequest error:&error];
        if (!error && datas && [datas count]) {
            [datas enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                for (NSString *key in editData.allKeys) {
                    if ([[editData objectForKey:key] isKindOfClass:[NSArray class]]){
                        NSRelationshipDescription *relationship = [[[NSEntityDescription entityForName:tableName inManagedObjectContext:currentContext] relationshipsByName] objectForKey:key];
                        for (NSDictionary *childDic in [editData objectForKey:key])
                            [self updateCoreData:[[relationship destinationEntity] name] ConditionID:[childDic objectForKey:@"objectID"] EditData:childDic];
                    }else if ([[obj allKeys] containsObject:key])
                        [obj setValue:[editData objectForKey:key] forKey:key];
                }
            }];
        }
        
    } completion:completion];
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  修改对象属性
 *
 *  @param tableName      表名
 *  @param condition      条件
 *  @param attributeName  属性名
 *  @param attributeValue 属性值
 */
- (void)updateCoreData: (NSString *)tableName
             Condition: (NSString *)condition
         AttributeName: (NSString *)attributeName
        AttributeValue: (NSString *)attributeValue
{
    [self updateCoreData: tableName
               Condition: condition
           AttributeName: attributeName
          AttributeValue: attributeValue
              completion: nil];
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  修改对象属性
 *
 *  @param tableName      表名
 *  @param condition      条件
 *  @param attributeName  属性名
 *  @param attributeValue 属性值
 *  @param completion     完成回调函数
 */
- (void)updateCoreData: (NSString *)tableName
             Condition: (NSString *)condition
         AttributeName: (NSString *)attributeName
        AttributeValue: (NSString *)attributeValue
            completion: (void(^)(NSError *error))completion
{
    [self saveContext:^(NSManagedObjectContext *currentContext) {
        NSFetchRequest *fetchRequest = [self cc_AllRequest:tableName];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:condition]];
        NSError *error = nil;
        NSArray *datas = [currentContext executeFetchRequest:fetchRequest error:&error];
        if (!error && datas && [datas count]) {
            [datas enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [obj setValue:attributeValue forKey:attributeName];
            }];
        }
    } completion:completion];
}

/**
 *  @author CC, 2015-10-23
 *
 *  @brief  主键修改数据对象及子项
 *
 *  @param context     操作对象
 *  @param tableName   表名
 *  @param conditionID 主键ID
 *  @param editData    编辑的数据集
 */
- (void)updateCoreData: (NSString *)tableName
           ConditionID: (NSManagedObjectID *)conditionID
              EditData: (NSDictionary *)editData
{
    [self updateCoreData: tableName
             ConditionID: conditionID
                EditData: editData
              completion: nil];
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  主键ID修改对象及子项
 *
 *  @param tableName   表名
 *  @param conditionID 主键ID
 *  @param editData    编辑属性
 *  @param completion  完成回调函数
 */
- (void)updateCoreData: (NSString *)tableName
           ConditionID: (NSManagedObjectID *)conditionID
              EditData: (NSDictionary *)editData
            completion: (void(^)(NSError *error))completion
{
    [self saveContext:^(NSManagedObjectContext *currentContext) {
        
        NSFetchRequest *fetchRequest = [self cc_AllRequest:tableName];
        NSError *error = nil;
        NSArray *datas = [currentContext executeFetchRequest:fetchRequest error:&error];
        if (!error && datas && [datas count]) {
            [datas enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([((NSManagedObject *)obj).objectID isEqual:conditionID]) {
                    for (NSString *key in editData.allKeys) {
                        if ([[editData objectForKey:key] isKindOfClass:[NSArray class]]){
                            NSRelationshipDescription *relationship = [[[NSEntityDescription entityForName:tableName inManagedObjectContext:currentContext] relationshipsByName] objectForKey:key];
                            for (NSDictionary *childDic in [editData objectForKey:key]){
                                [self updateCoreData: [[relationship destinationEntity] name]
                                         ConditionID: [childDic objectForKey:@"objectID"]
                                            EditData: childDic];
                            }
                        }else if ([[obj allKeys] containsObject:key]){
                            if (![key isEqualToString:@"objectID"])
                                [obj setValue:[editData objectForKey:key] forKey:key];
                        }
                    }
                }
            }];
        }
        
    } completion:completion];
}


@end
