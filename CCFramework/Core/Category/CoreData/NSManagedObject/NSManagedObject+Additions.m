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

- (NSDictionary *)changedDictionary
{
    unsigned int count;
    
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        id obj = [self valueForKey:name];
        if (obj) {
            
            if (![[obj class] isSubclassOfClass:[NSData class]]) {
                if ([[obj class] isSubclassOfClass:[NSManagedObject class]]) {
                    
                    NSArray *relationships = [[obj entity] relationshipsWithDestinationEntity:[self entity]];
                    if ([relationships count] > 0) {
                        NSString *relName = [[relationships objectAtIndex:0] name];
                        
                        NSDictionary *namedRelationships = [[obj entity] relationshipsByName];
                        BOOL isParent = [[[(NSRelationshipDescription *)[namedRelationships objectForKey:relName] destinationEntity] name] isEqualToString:NSStringFromClass([self class])];
                        if (!isParent)
                            [dictionary setObject:[(NSManagedObject *)obj changedDictionary] forKey:name];
                    } else {
                        [dictionary setObject:[(NSManagedObject *)obj changedDictionary] forKey:name];
                    }
                } else if ([[obj class] isSubclassOfClass:[NSSet class]]) {
                    if ([obj count] > 0) {
                        NSArray *array = [(NSSet *)obj allObjects];
                        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:[array count]];
                        for (id o in array)
                            [mutableArray addObject:[(NSManagedObject *)o changedDictionary]];
                        
                        [dictionary setObject:[NSArray arrayWithArray:mutableArray] forKey:name];
                    }
                } else if ([[obj class] isSubclassOfClass:[NSDate class]]) {
                    [dictionary setObject:[obj description] forKey:name];
                } else {
                    [dictionary setObject:obj forKey:name];
                }
            }
        }
    }
    free(properties);
    
    return dictionary;
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
            NSManagedObject *relatedObject =
            [NSManagedObject createManagedObjectFromDictionary:(NSDictionary *)value inContext:context];
            
            [self setValue:relatedObject forKey:key];
        } else if ([value isKindOfClass:[NSSet class]]) {
            // This is a to-many relationship
            NSSet *relatedObjectDictionaries = (NSSet *)value;
            
            // Get a proxy set that represents the relationship, and add related objects to it.
            // (Note: this is provided by Core Data)
            NSMutableSet *relatedObjects = [self mutableSetValueForKey:key];
            
            for (NSDictionary *relatedObjectDict in relatedObjectDictionaries) {
                NSManagedObject *relatedObject =
                [NSManagedObject createManagedObjectFromDictionary:relatedObjectDict inContext:context];
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
            case NSBinaryDataAttributeType:
                [self setValue:value forKey:attributeName];
                break;
            case NSStringAttributeType:
                [self setValue:[value description] forKey:attributeName];
                break;
            case NSTransformableAttributeType:
            case NSUndefinedAttributeType:
                break;
            default:
                break;
        }
    }
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
                destinationObjs = [CoreDataMasterSlave cc_insertOrUpdateWtihDataArray:relationshipDes.destinationEntity.name
                                                                           PrimaryKey:primaryKey
                                                                        WithDataArray:value
                                                                            inContext:self.managedObjectContext];
            } else {
                destinationObjs = [CoreDataMasterSlave cc_insertCoreDataWithArray:relationshipDes.destinationEntity.name
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
        
        if ([desClassName isEqualToString:@"NSManagedObject"])
            destinationObjs = [CoreDataMasterSlave cc_insertCoreDataWithDic:relationshipDes.destinationEntity.name DataDic:value];
        else
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
    //    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    //    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    
    NSDate *parsedDate = [formatter dateFromString:value];
    
    return parsedDate;
}

NSNumber *numberFromString(NSString *value)
{
    return [NSNumber numberWithDouble:[value integerValue]];
}

@end