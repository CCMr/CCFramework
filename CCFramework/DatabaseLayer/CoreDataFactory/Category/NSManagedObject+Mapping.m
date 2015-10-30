//
//  NSManagedObject+Mapping.m
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

#import "NSManagedObject+Mapping.h"
#import "BaseManagedObject+Facade.h"
#import "CoreDataMasterSlave+Manager.h"
#import "CoreDataMasterSlave.h"

@implementation NSManagedObject (Mapping)

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
        
        if ([desClassName isEqualToString:@"NSManagedObject"])
            destinationObjs = [CoreDataMasterSlave cc_insertCoreDataWithArray:relationshipDes.destinationEntity.name DataArray:value];
        else
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

#pragma mark - private methods

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

#pragma mark - transform methods

NSDate *dateFromString(NSString *value)
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssz"];
    
    NSDate *parsedDate = [formatter dateFromString:value];
    
    return parsedDate;
}

NSNumber *numberFromString(NSString *value)
{
    return [NSNumber numberWithDouble:[value doubleValue]];
}


@end
