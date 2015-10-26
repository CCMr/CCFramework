//
//  NSManagedObject+Additional.m
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

#import "NSManagedObject+Additional.h"
#import <objc/runtime.h>

static char NSMANAGEDOBJECT_TRAVERSED_KEY;

@implementation NSManagedObject (Additional)

-(void)setTraversed: (BOOL)traversed
{
    objc_setAssociatedObject(self, &NSMANAGEDOBJECT_TRAVERSED_KEY, @(traversed), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)traversed
{
    return (BOOL)objc_getAssociatedObject(self, &NSMANAGEDOBJECT_TRAVERSED_KEY);
}

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  转换字典对象
 *
 *  @return 返回字典对象
 */
- (NSDictionary*)changedDictionary
{
    self.traversed = YES;

    NSArray* attributes = [[[self entity] attributesByName] allKeys];
    NSArray* relationships = [[[self entity] relationshipsByName] allKeys];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:[attributes count] + [relationships count] + 1];
    [dict setObject:self.objectID forKey:@"objectID"];
    //    [dict setObject:[[self class] description] forKey:@"class"];

    for (NSString* attr in attributes) {
        NSObject* value = [self valueForKey:attr];
        if (value)
            [dict setObject:value forKey:attr];
    }

    for (NSString* relationship in relationships) {
        NSObject* value = [self valueForKey:relationship];

        if ([value isKindOfClass:[NSSet class]]) {
            // To-many relationship
            // The core data set holds a collection of managed objects
            NSSet *relatedObjects = (NSSet *) value;

            NSMutableArray *dicSetArray = [NSMutableArray array];
            for (NSManagedObject* relatedObject in relatedObjects) {
                //                if (!relatedObject.traversed)
                [dicSetArray addObject:[relatedObject changedDictionary]];
            }
            [dict setObject:dicSetArray forKey:relationship];
            /*
             // Our set holds a collection of dictionaries
             NSMutableSet* dictSet = [NSMutableSet setWithCapacity:[relatedObjects count]];
             for (NSManagedObject* relatedObject in relatedObjects) {
             if (!relatedObject.traversed)
             [dictSet addObject:[relatedObject toDictionary]];
             }
             [dict setObject:dictSet forKey:relationship];
             */
        }else if ([value isKindOfClass:[NSManagedObject class]]) {
            // To-one relationship
            NSManagedObject *relatedObject = (NSManagedObject *) value;
            if (!relatedObject.traversed) {
                // Call toDictionary on the referenced object and put the result back into our dictionary.
                [dict setObject:[relatedObject changedDictionary] forKey:relationship];
            }
        }
    }

    return dict;
}

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  获取对象属性与属性类型
 *
 *  @param dict 字典对象
 */
- (void)populateFromDictionary: (NSDictionary*)dict
{
    NSManagedObjectContext* context = [self managedObjectContext];
    for (NSString* key in dict) {
        if ([key isEqualToString:@"class"])
            continue;

        NSObject* value = [dict objectForKey:key];
        if ([value isKindOfClass:[NSDictionary class]]) {
            // This is a to-one relationship
            NSManagedObject * relatedObject =
            [NSManagedObject createManagedObjectFromDictionary:(NSDictionary*)value inContext:context];

            [self setValue:relatedObject forKey:key];
        }else if ([value isKindOfClass:[NSSet class]]) {
            // This is a to-many relationship
            NSSet* relatedObjectDictionaries = (NSSet*) value;

            // Get a proxy set that represents the relationship, and add related objects to it.
            // (Note: this is provided by Core Data)
            NSMutableSet* relatedObjects = [self mutableSetValueForKey:key];

            for (NSDictionary* relatedObjectDict in relatedObjectDictionaries) {
                NSManagedObject *relatedObject =
                [NSManagedObject createManagedObjectFromDictionary:relatedObjectDict inContext:context];
                [relatedObjects addObject:relatedObject];
            }
        }else if (value != nil) {
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
+ (NSManagedObject *)createManagedObjectFromDictionary: (NSDictionary*)dict
                                             inContext: (NSManagedObjectContext*)context
{
    NSString *class = [dict objectForKey:@"class"];

    NSManagedObject *newObject = (NSManagedObject *)[NSEntityDescription insertNewObjectForEntityForName:class inManagedObjectContext:context];
    [newObject populateFromDictionary:dict];

    return newObject;
}

@end
