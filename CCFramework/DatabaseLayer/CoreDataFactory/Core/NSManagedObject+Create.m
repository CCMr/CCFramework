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

#import "BaseManagedObject.h"
#import "NSManagedObject+CCManagedObject.h"
#import "NSManagedObject+FetchRequest.h"
#import "NSManagedObject+Mapping.h"
#import "BaseManagedObject+Facade.h"

@implementation NSManagedObject (Create)

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  创建新对象
 *
 *  @return 返回新对象
 */
+ (id)cc_New
{
    NSManagedObjectContext *manageContext = [self defaultPrivateContext];
    return [NSEntityDescription insertNewObjectForEntityForName:[self cc_EntityName] inManagedObjectContext:manageContext];
}

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  根据管理对象创建新对象
 *
 *  @param context 管理对象
 *
 *  @return 返回新对象
 */
+ (id)cc_NewInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self cc_EntityName] inManagedObjectContext:context];
}

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
                   inContext:(NSManagedObjectContext *)context
{
    if (data) {
        return [[self cc_NewOrUpdateWithArray:@[ data ] inContext:context] lastObject];
    }
    return nil;
}

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
                           inContext:(NSManagedObjectContext *)context
{
    NSMutableArray *objs = [NSMutableArray array];
    NSSet *primarryKey = nil;
    if ([self respondsToSelector:@selector(uniquedPropertyKeys)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        primarryKey = [self performSelector:@selector(uniquedPropertyKeys)];
#pragma clang diagnostic pop
    }
    
    for (NSDictionary *d in dataAry) {
        [objs addObject:[self objctWithData:d
                                primaryKeys:primarryKey
                                  inContext:context]];
    }
    return objs;
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
+ (id)objctWithData:(NSDictionary *)data
        primaryKeys:(NSSet *)primaryKeys
          inContext:(NSManagedObjectContext *)context
{
    __block NSManagedObject *entity = nil;
    @autoreleasepool
    {
        if (!primaryKeys || primaryKeys.count == 0) {
            entity = [self cc_NewInContext:context];
        } else {
            //create a compumd predicate
            NSString *entityName = [self cc_EntityName];
            NSMutableArray *subPredicates = [NSMutableArray array];
            for (NSString *primaryKey in primaryKeys) {
                
                NSAttributeDescription *attributeDes = [[[NSEntityDescription entityForName:entityName inManagedObjectContext:context] attributesByName] objectForKey:primaryKey];
                
                id remoteValue = [data valueForKeyPath:primaryKey];
                
                if (attributeDes.attributeType == NSStringAttributeType) {
                    remoteValue = [remoteValue description];
                } else {
                    remoteValue = [NSNumber numberWithLongLong:[remoteValue longLongValue]];
                }
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", primaryKey, remoteValue];
                [subPredicates addObject:predicate];
            }
            
            NSCompoundPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
            
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self cc_EntityName]];
            fetchRequest.fetchLimit = 1;
            fetchRequest.resultType = NSManagedObjectIDResultType;
            [fetchRequest setPredicate:compoundPredicate];
            
            NSManagedObjectID *objectID = [[context executeFetchRequest:fetchRequest error:nil] firstObject];
            if (objectID) {
                entity = [context existingObjectWithID:objectID error:nil];
            } else {
                entity = [self cc_NewInContext:context];
            }
        }
        
        NSArray *attributes = [entity allAttributeNames];
        NSArray *relationships = [entity allRelationshipNames];
        
        [data enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
            
            id remoteValue = obj;
            if (remoteValue != nil) {
                
                NSString *methodName = [NSString stringWithFormat:@"%@Transformer:",key];
                SEL selector = NSSelectorFromString(methodName);
                if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    id value = [self performSelector:selector withObject:remoteValue];
#pragma clang diagnostic pop
                    
                    if (value != nil) {
                        [entity setValue:value forKey:key];
                    }
                    
                }else{
                    if ([attributes containsObject:key]) {
                        [entity mergeAttributeForKey:key
                                           withValue:remoteValue];
                        
                    }else if ([relationships containsObject:key]){
                        [entity mergeRelationshipForKey:key
                                              withValue:remoteValue
                                                  IsAdd:YES];
                    }
                }
            }
        }];
    }
    return entity;
}

@end
