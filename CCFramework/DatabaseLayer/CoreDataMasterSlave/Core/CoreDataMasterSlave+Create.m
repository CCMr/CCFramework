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

@implementation CoreDataMasterSlave (Create)

/**
 *  @author CC, 2015-07-24
 *
 *  @brief  数据库新增
 *
 *  @param tableName 表明
 *  @param dataDic   对象
 *
 *  @since 1.0
 */
+ (void)cc_insertCoreData: (NSString *)tableName
                  DataDic: (NSDictionary *)dataDic
{
    [self cc_insertCoreData: tableName
                  DataArray: @[dataDic]];
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  新增对个对象
 *
 *  @param tableName 表名
 *  @param dataArray 新增数据
 */
+ (void)cc_insertCoreData: (NSString *)tableName
                DataArray: (NSArray *)dataArray
{
    if (!dataArray.count) return;

    [self cc_insertCoreData: tableName
                  DataArray: dataArray
                 completion: nil];
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
+ (void)cc_insertCoreData: (NSString *)tableName
                DataArray: (NSArray *)dataArray
               completion: (void(^)(NSError *error))completion
{
    if (!dataArray.count) return;

    [self saveContext:^(NSManagedObjectContext *currentContext) {
        for (NSDictionary *dic in dataArray)
        {
            NSManagedObject *entity = [NSEntityDescription insertNewObjectForEntityForName:tableName inManagedObjectContext:currentContext];
            for (NSString *key in dic.allKeys) {
                if ([[dic objectForKey:key] isKindOfClass:[NSArray class]]){
                    NSRelationshipDescription *relationship = [[[NSEntityDescription entityForName:tableName inManagedObjectContext:currentContext] relationshipsByName] objectForKey:key];

                    [self cc_recursiveCategory: entity
                                  Relationship: relationship
                               ForeignKeyValue: [dic objectForKey:relationship.inverseRelationship.name]
                                     DataArray: [dic objectForKey:key]
                        inManagedObjectContext: currentContext];
                }else{
                    [entity setValue:[dic objectForKey:key] forKey:key];
                }
            }
        }

    } completion:completion];
}

/**
 *  @author CC, 2015-10-25
 *
 *  @brief  递归关联对象新增
 *
 *  @param entity          上级对象
 *  @param relationship    子对象
 *  @param foreignKeyValue 子对象键
 *  @param dataArray       子对象值
 *  @param context         核心处理对象
 */
+ (void)cc_recursiveCategory: (NSManagedObject *)entity
                Relationship: (NSRelationshipDescription *)relationship
             ForeignKeyValue: (NSString *)foreignKeyValue
                   DataArray: (NSArray *)dataArray
      inManagedObjectContext: (NSManagedObjectContext *)context
{
    NSMutableSet *SonCategory = [NSMutableSet set];

    for (NSDictionary *dic in dataArray) {
        NSManagedObject *entitySon = [NSEntityDescription insertNewObjectForEntityForName:[[relationship destinationEntity] name] inManagedObjectContext:context];

        //有自定义关联外键
        if (foreignKeyValue)
            [entitySon setValue:foreignKeyValue forKey:relationship.name];//设置当前主键

        [entitySon setValue:entity forKey:relationship.inverseRelationship.name];

        for (NSString *key in dic.allKeys) {
            if ([[dic objectForKey:key] isKindOfClass:[NSArray class]])
            {
                NSRelationshipDescription *CategoryRelationship = [[[NSEntityDescription entityForName:[[relationship destinationEntity] name] inManagedObjectContext:context] relationshipsByName] objectForKey:key];

                [self cc_recursiveCategory: entitySon
                              Relationship: CategoryRelationship
                           ForeignKeyValue: [dic objectForKey:CategoryRelationship.inverseRelationship.name]
                                 DataArray: [dic objectForKey:key]
                    inManagedObjectContext: context];
            }else{
                [entitySon setValue:[dic objectForKey:key] forKey:key];
            }
        }
        [SonCategory addObject:entitySon];
    }
    [entity setValue:SonCategory forKey:relationship.name];
}


@end
