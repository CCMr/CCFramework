//
//  NSManagedObject+Additions.m
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

#import "NSManagedObject+Additions.h"
#import "CoreDataManager.h"
#import "CoreDataMasterSlave+Manager.h"
#import "BaseManagedObject+Facade.h"
#import "NSManagedObjectContext+Additions.h"
#import <objc/runtime.h>

@implementation NSManagedObject (Additions)

#define DATE_ATTR_PREFIX @"dAtEaTtr:"
#warning "Change CLASS_PREFIX if it's not ABC"
#define CLASS_PREFIX @"ABC"

#pragma mark -
#pragma mark :. Extensions

+ (id)create:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
}

+ (id)create:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context
{
    id instance = [self create:context];
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [instance setValue:obj forKey:key];
    }];
    return instance;
}

+ (id)find:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context
{
    return [context fetchObjectForEntity:[self entityName] predicate:predicate];
}

+ (id)find:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context
{
    return [context fetchObjectForEntity:[self entityName] predicate:predicate sortDescriptors:sortDescriptors];
}

+ (NSArray *)all:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context
{
    return [context fetchObjectsForEntity:[self entityName] predicate:predicate];
}

+ (NSArray *)all:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context
{
    return [context fetchObjectsForEntity:[self entityName] predicate:predicate sortDescriptors:sortDescriptors];
}

+ (NSUInteger)count:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
    [request setPredicate:predicate];
    [request setEntity:entity];
    NSError *error = nil;
    return [context countForFetchRequest:request error:&error];
}

+ (NSString *)entityName
{
    return [NSString stringWithCString:object_getClassName(self) encoding:NSASCIIStringEncoding];
}

+ (NSError *)deleteAll:(NSManagedObjectContext *)context
{
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:[NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context]];
    [req setIncludesPropertyValues:NO]; //only fetch the managedObjectID

    NSError *error = nil;
    NSArray *objects = [context executeFetchRequest:req error:&error];
    //error handling goes here
    for (NSManagedObject *obj in objects) {
        [context deleteObject:obj];
    }
    NSError *saveError = nil;
    [context save:&saveError];
    return error;
}

//- (NSDictionary *)changedDictionary
//{
//
//    NSArray *attributes = self.entity.attributesByName.allKeys;
//    NSArray *relationships = self.entity.relationshipsByName.allKeys;
//    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[attributes count] + [relationships count] + 1];
//    [dict setObject:self.objectID forKey:@"objectID"];
//    //    [dict setObject:[[self class] description] forKey:@"class"];
//
//    for (NSString *attr in attributes) {
//        NSObject *value = [self valueForKey:attr];
//        if (value)
//            [dict setObject:value forKey:attr];
//    }
//
//    for (NSString *relationship in relationships) {
//        NSObject *value = [self valueForKey:relationship];
//
//        if ([value isKindOfClass:[NSSet class]]) {
//            // To-many relationship
//            // The core data set holds a collection of managed objects
//            NSSet *relatedObjects = (NSSet *)value;
//
//            NSMutableArray *dicSetArray = [NSMutableArray array];
//            for (NSManagedObject *relatedObject in relatedObjects) {
//                    [dicSetArray addObject:[relatedObject changedDictionary]];
//            }
//
//            [dict setObject:dicSetArray forKey:relationship];
//        } else if ([value isKindOfClass:[NSManagedObject class]]) {
//            // To-one relationship
//            NSManagedObject *relatedObject = (NSManagedObject *)value;
//            //表名与关联字段必须一样并且全部是小写表名与关联字段必须一样 全部转小写比较
//            if ([[relatedObject.entity.name lowercaseString] isEqualToString:relationship]) {
//                // Call toDictionary on the referenced object and put the result back into our dictionary.
//                [dict setObject:[relatedObject changedDictionary] forKey:relationship];
//            }
//        }
//    }
//
//    return dict;
//}

- (NSDictionary *)toDictionaryWithTraversalHistory:(NSMutableSet *)traversalHistory
{
    NSArray *attributes = [[[self entity] attributesByName] allKeys];
    NSArray *relationships = [[[self entity] relationshipsByName] allKeys];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[attributes count] + [relationships count] + 1];

    NSMutableSet *localTraversalHistory = nil;
    if (traversalHistory == nil) {
        localTraversalHistory = [NSMutableSet setWithCapacity:[attributes count] + [relationships count] + 1];
    } else {
        localTraversalHistory = traversalHistory;
    }

    [localTraversalHistory addObject:self];
    //    [dict setObject:[[self class] description] forKey:@"class"];

    for (NSString *attr in attributes) {
        NSObject *value = [self valueForKey:attr];
        if (value)
            [dict setObject:value forKey:attr];
    }

    for (NSString *relationship in relationships) {
        NSObject *value = [self valueForKey:relationship];

        if ([value isKindOfClass:[NSSet class]]) {
            // To-many relationship
            // The core data set holds a collection of managed objects
            NSSet *relatedObjects = (NSSet *)value;
            // Our set holds a collection of dictionaries
            NSMutableArray *dictSet = [NSMutableArray arrayWithCapacity:[relatedObjects count]];
            for (NSManagedObject *relatedObject in relatedObjects) {
                if ([localTraversalHistory containsObject:relatedObject] == NO) {
                    [dictSet addObject:[relatedObject toDictionaryWithTraversalHistory:localTraversalHistory]];
                }
            }

            [dict setObject:[NSArray arrayWithArray:dictSet] forKey:relationship];
        } else if ([value isKindOfClass:[NSOrderedSet class]]) {
            // To-many relationship
            // The core data set holds an ordered collection of managed objects
            NSOrderedSet *relatedObjects = (NSOrderedSet *)value;
            // Our ordered set holds a collection of dictionaries
            NSMutableArray *dictSet = [NSMutableArray arrayWithCapacity:[relatedObjects count]];
            for (NSManagedObject *relatedObject in relatedObjects) {
                if ([localTraversalHistory containsObject:relatedObject] == NO) {
                    [dictSet addObject:[relatedObject toDictionaryWithTraversalHistory:localTraversalHistory]];
                }
            }

            [dict setObject:[NSOrderedSet orderedSetWithArray:dictSet] forKey:relationship];
        } else if ([value isKindOfClass:[NSManagedObject class]]) {
            // To-one relationship
            NSManagedObject *relatedObject = (NSManagedObject *)value;
            if ([localTraversalHistory containsObject:relatedObject] == NO) {
                // Call toDictionary on the referenced object and put the result back into our dictionary.
                [dict setObject:[relatedObject toDictionaryWithTraversalHistory:localTraversalHistory] forKey:relationship];
            }
        }
    }

    if (traversalHistory == nil)
        [localTraversalHistory removeAllObjects];

    return dict;
}

- (NSDictionary *)changedDictionary
{
    // Check to see there are any objects that should be skipped in the traversal.
    // This method can be optionally implemented by NSManagedObject subclasses.
    NSMutableSet *traversedObjects = nil;
    if ([self respondsToSelector:@selector(serializationObjectsToSkip)]) {
        traversedObjects = [self performSelector:@selector(serializationObjectsToSkip)];
    }
    return [self toDictionaryWithTraversalHistory:traversedObjects];
}

- (NSDictionary *)Dictionary
{
    NSArray *keys = [[[self entity] attributesByName] allKeys];
    NSDictionary *dict = [self dictionaryWithValuesForKeys:keys];
    return dict;
}

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  获取对象属性与属性类型
 *
 *  @param dict 字典对象
 */
- (void)populateFromDictionary:(NSDictionary *)dict
{
    NSManagedObjectContext *context = [self managedObjectContext];
    for (NSString *key in dict) {
        if ([key isEqualToString:@"class"])
            continue;

        NSObject *value = [dict objectForKey:key];
        if ([value isKindOfClass:[NSDictionary class]]) {
            // This is a to-one relationship
            NSManagedObject *relatedObject = [NSManagedObject createManagedObjectFromDictionary:(NSDictionary *)value inContext:context];

            [self setValue:relatedObject forKey:key];
        } else if ([value isKindOfClass:[NSSet class]]) {
            // This is a to-many relationship
            NSSet *relatedObjectDictionaries = (NSSet *)value;

            // Get a proxy set that represents the relationship, and add related objects to it.
            // (Note: this is provided by Core Data)
            NSMutableSet *relatedObjects = [self mutableSetValueForKey:key];

            for (NSDictionary *relatedObjectDict in relatedObjectDictionaries) {
                NSManagedObject *relatedObject = [NSManagedObject createManagedObjectFromDictionary:relatedObjectDict inContext:context];
                [relatedObjects addObject:relatedObject];
            }
        } else if (value != nil) {
            // This is an attribute
            [self setValue:value forKey:key];
        }
    }
}

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  字段转换对象
 *
 *  @param dict    字典
 *  @param context 管理对象
 *
 *  @return 返回对象
 */
+ (NSManagedObject *)createManagedObjectFromDictionary:(NSDictionary *)dict
                                             inContext:(NSManagedObjectContext *)context
{
    NSString *class = [dict objectForKey:@"class"];

    NSManagedObject *newObject = (NSManagedObject *)[NSEntityDescription insertNewObjectForEntityForName:class inManagedObjectContext:context];
    [newObject populateFromDictionary:dict];

    return newObject;
}

#pragma mark -
#pragma mark :. CCManagedObject

NSString *const CoreDataCurrentThreadContext = @"CoreData_CurrentThread_Context";

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  默认私有管理对象
 *
 *  @return 返回私有管理对象
 */
+ (NSManagedObjectContext *)defaultPrivateContext
{
    return [CoreDataManager sharedlnstance].privateContext;
}

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  默认主管理对象
 *
 *  @return 返回主管理对象
 */
+ (NSManagedObjectContext *)defaultMainContext
{
    return [CoreDataManager sharedlnstance].mainContext;
}

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  当前管理对象
 *
 *  @return 返回当前管理对象
 */
+ (NSManagedObjectContext *)currentContext
{
    if ([NSThread isMainThread])
        return [self defaultMainContext];

    NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
    NSManagedObjectContext *context = [threadDict objectForKey:CoreDataCurrentThreadContext];

    if (!context) {
        context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [context setParentContext:[self defaultPrivateContext]];
        [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        context.undoManager = nil;
        [threadDict setObject:context forKey:CoreDataCurrentThreadContext];
    }

    return context;
}

#pragma mark -
#pragma mark :. FetchRequest

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  获取对象名称
 *
 *  @return 返回对象名称
 */
+ (NSString *)cc_EntityName
{
    return NSStringFromClass(self);
}

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  请求所有
 *
 *  @return 返回请求条件对象
 */
+ (NSFetchRequest *)cc_AllRequest
{
    return [self cc_RequestWithFetchLimit:0
                                batchSize:0];
}

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  单条请求
 *
 *  @return 返回请求条件对象
 */
+ (NSFetchRequest *)cc_AnyoneRequest
{
    return [self cc_RequestWithFetchLimit:1
                                batchSize:1];
}

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  分页请求
 *
 *  @param limit     页数
 *  @param batchSize 页码
 *
 *  @return 返回请求条件对象
 */
+ (NSFetchRequest *)cc_RequestWithFetchLimit:(NSUInteger)limit
                                   batchSize:(NSUInteger)batchSize
{
    return [self cc_RequestWithFetchLimit:limit batchSize:batchSize fetchOffset:0];
}

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  请求条件
 *
 *  @param limit       页数
 *  @param batchSize   页码
 *  @param fetchOffset 集合数
 *
 *  @return 返回请求条件对象
 */
+ (NSFetchRequest *)cc_RequestWithFetchLimit:(NSUInteger)limit
                                   batchSize:(NSUInteger)batchSize
                                 fetchOffset:(NSUInteger)fetchOffset
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self cc_EntityName]];
    fetchRequest.fetchLimit = limit;
    fetchRequest.fetchBatchSize = batchSize;
    fetchRequest.fetchOffset = fetchOffset;
    return fetchRequest;
}

#pragma mark -
#pragma mark :. Mapping

/**
 *  @author CC, 2015-10-29
 *
 *  @brief  属性合并
 *
 *  @param attributeName 属性名
 *  @param value         值
 */
- (void)mergeAttributeForKey:(NSString *)attributeName
                   withValue:(id)value
{
    NSAttributeDescription *attributeDes = [self attributeDescriptionForAttribute:attributeName];

    if (value != [NSNull null]) {
        switch (attributeDes.attributeType) {
            case NSDecimalAttributeType:
            case NSInteger16AttributeType:
            case NSInteger32AttributeType:
            case NSInteger64AttributeType:
            case NSDoubleAttributeType:
            case NSFloatAttributeType:
                [self setValue:numberFromString([value description]) forKey:attributeName];
                break;
            case NSBooleanAttributeType:
                [self setValue:[NSNumber numberWithBool:[value boolValue]] forKey:attributeName];
                break;
            case NSDateAttributeType: {
                id setvalue = value;

                if ([value isKindOfClass:[NSString class]])
                    setvalue = dateFromString(value);

                [self setValue:setvalue forKey:attributeName];
                break;
            }
            case NSObjectIDAttributeType:
                [self setValue:value forKey:attributeName];
                break;
            case NSBinaryDataAttributeType:
                if ([value isKindOfClass:[UIImage class]]) {
                    NSData *datas;
                    if (UIImagePNGRepresentation(value))
                        datas = UIImagePNGRepresentation(value);
                    else
                        datas = UIImageJPEGRepresentation(value, 1.0f);
                    value = datas;
                }

                [self setValue:value forKey:attributeName];
                break;
            case NSStringAttributeType:
                [self setValue:[value description] forKey:attributeName];
                break;
            case NSTransformableAttributeType:
            case NSUndefinedAttributeType:
                [self setValue:value forKey:attributeName];
                break;
            default:
                break;
        }
    }
}

/**
 *  @author CC, 16-05-20
 *
 *  @brief  判断当前数据数据是否匹配
 *
 *  @param attributeName 属性名
 *  @param value         属性值
 */
- (BOOL)compareKeyValue:(NSString *)attributeName
              withValue:(id)value
{
    NSAttributeDescription *attributeDes = [self attributeDescriptionForAttribute:attributeName];

    BOOL compareBol = NO;
    if (value != [NSNull null]) {
        switch (attributeDes.attributeType) {
            case NSDecimalAttributeType:
            case NSInteger16AttributeType:
            case NSInteger32AttributeType:
            case NSInteger64AttributeType:
            case NSDoubleAttributeType:
            case NSFloatAttributeType: {
                if (numberFromString([value description]) == [self valueForKey:attributeName])
                    compareBol = YES;
            } break;
            case NSBooleanAttributeType:
                if ([NSNumber numberWithBool:[value boolValue]] == [[self valueForKey:attributeName] integerValue])
                    compareBol = YES;
                break;
            case NSDateAttributeType: {
                id setvalue = value;

                if ([value isKindOfClass:[NSString class]])
                    setvalue = dateFromString(value);

                if ([setvalue isEqualToDate:[self valueForKey:attributeName]])
                    compareBol = YES;

                break;
            }
            case NSObjectIDAttributeType:
            case NSBinaryDataAttributeType:
                if ([value isEqualToData:[self valueForKey:attributeName]])
                    compareBol = YES;
                break;
            case NSStringAttributeType:
                if ([[value description] isEqualToString:[self valueForKey:attributeName]])
                    compareBol = YES;
                break;
            case NSTransformableAttributeType:
            case NSUndefinedAttributeType:
                break;
            default:
                break;
        }
    }
    return compareBol;
}

/**
 *  @author CC, 2015-10-29
 *
 *  @brief  关系合并
 *
 *  @param relationshipName 关系对象名
 *  @param value            值
 *  @param isAdd            是否添加对象
 */
- (void)mergeRelationshipForKey:(NSString *)relationshipName
                      withValue:(id)value
                          IsAdd:(BOOL)isAdd
{
    if ([value isEqual:[NSNull null]]) return;

    NSRelationshipDescription *relationshipDes = [self relationshipDescriptionForRelationship:relationshipName];
    NSString *desClassName = relationshipDes.destinationEntity.managedObjectClassName;

    if (relationshipDes.isToMany) {
        NSArray *destinationObjs;

        if ([desClassName isEqualToString:@"NSManagedObject"]) {
            NSString *primaryKey = [relationshipDes.destinationEntity.userInfo objectForKey:@"PrimaryKey"];
            if (primaryKey) {
                destinationObjs = [CoreDataMasterSlave cc_insertOrUpdateWtihDataArrayObject:relationshipDes.destinationEntity.name
                                                                                 PrimaryKey:primaryKey
                                                                              WithDataArray:value
                                                                                  inContext:self.managedObjectContext];
            } else {
                destinationObjs = [CoreDataMasterSlave cc_insertCoreDataWithArrayObject:relationshipDes.destinationEntity.name
                                                                              DataArray:value];
            }
        } else
            destinationObjs = [NSClassFromString(desClassName) cc_NewOrUpdateWithArray:value inContext:self.managedObjectContext];

        if (destinationObjs != nil && destinationObjs.count > 0) {
            if (isAdd) { //添加数据
                if (relationshipDes.isOrdered) {
                    NSMutableOrderedSet *localOrderedSet = [self mutableOrderedSetValueForKey:relationshipName];
                    [localOrderedSet addObjectsFromArray:destinationObjs];
                    [self setValue:localOrderedSet forKey:relationshipName];
                } else {
                    NSMutableSet *localSet = [self mutableSetValueForKey:relationshipName];
                    [localSet addObjectsFromArray:destinationObjs];
                    if (localSet.count < destinationObjs.count) {
                        [self setValue:[[NSMutableSet alloc] initWithArray:destinationObjs] forKey:relationshipName];
                    } else
                        [self setValue:localSet forKey:relationshipName];
                }
            } else {
                if (relationshipDes.isOrdered) {
                    NSMutableOrderedSet *localOrderedSet = [self mutableOrderedSetValueForKey:relationshipName];
                    [localOrderedSet removeAllObjects];
                    [localOrderedSet addObjectsFromArray:destinationObjs];
                    [self setValue:localOrderedSet forKey:relationshipName];
                } else {
                    [self setValue:[NSSet setWithArray:destinationObjs] forKey:relationshipName];
                }
            }
        }
    } else {
        id destinationObjs;

        if ([desClassName isEqualToString:@"NSManagedObject"]) {
            NSString *primaryKey = [relationshipDes.destinationEntity.userInfo objectForKey:@"PrimaryKey"];
            if (primaryKey) {
                destinationObjs = [CoreDataMasterSlave cc_insertOrUpdateWtihData:relationshipDes.destinationEntity.name
                                                                      PrimaryKey:primaryKey
                                                                        WithData:value
                                                                       inContext:self.managedObjectContext];
            } else {
                destinationObjs = [CoreDataMasterSlave cc_insertCoreDataWithObject:relationshipDes.destinationEntity.name
                                                                           DataDic:value];
            }
        } else
            destinationObjs = [NSClassFromString(desClassName) cc_NewOrUpdateWithData:value inContext:self.managedObjectContext];

        [self setValue:destinationObjs forKey:relationshipName];
    }
}

#pragma mark--- private methods

/**
 *  @author CC, 2015-10-29
 *
 *  @brief  对象属性
 *
 *  @return 返回对象所有属性
 */
- (NSArray *)allAttributeNames
{
    return self.entity.attributesByName.allKeys;
}

/**
 *  @author CC, 2015-10-29
 *
 *  @brief  对象关系
 *
 *  @return 返回对象所有关系集合
 */
- (NSArray *)allRelationshipNames
{
    return self.entity.relationshipsByName.allKeys;
}

- (NSAttributeDescription *)attributeDescriptionForAttribute:(NSString *)attributeName
{
    return [self.entity.attributesByName objectForKey:attributeName];
}

- (NSRelationshipDescription *)relationshipDescriptionForRelationship:(NSString *)relationshipName
{
    return [self.entity.relationshipsByName objectForKey:relationshipName];
}

#pragma mark--- transform methods

NSDate *dateFromString(NSString *value)
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if ([value rangeOfString:@"T"].location != NSNotFound) {
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    }else{
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [formatter setLocale:[NSLocale currentLocale]];
    }

    NSDate *parsedDate = [formatter dateFromString:value];

    return parsedDate;
}

NSNumber *numberFromString(NSString *value)
{
    return [NSNumber numberWithDouble:[value integerValue]];
}

@end
