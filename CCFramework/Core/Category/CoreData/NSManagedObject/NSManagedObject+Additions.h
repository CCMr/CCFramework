//
//  NSManagedObject+Additions.h
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

#import <CoreData/CoreData.h>

@interface NSManagedObject (Extensions)

#pragma mark -
#pragma mark :. Extensions

+ (id)create:(NSManagedObjectContext *)context;
+ (id)create:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;
+ (id)find:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;
+ (id)find:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context;
+ (NSArray *)all:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;
+ (NSArray *)all:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context;
+ (NSUInteger)count:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)contex;
+ (NSString *)entityName;
+ (NSError *)deleteAll:(NSManagedObjectContext *)context;

- (NSDictionary *)changedDictionary;

- (NSDictionary *)Dictionary;

+ (NSManagedObject *)createManagedObjectFromDictionary:(NSDictionary *)dict
                                             inContext:(NSManagedObjectContext *)context;

#pragma mark -
#pragma mark :. CCManagedObject

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  默认私有管理对象
 *
 *  @return 返回私有管理对象
 */
+ (NSManagedObjectContext *)defaultPrivateContext;

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  默认主管理对象
 *
 *  @return 返回主管理对象
 */
+ (NSManagedObjectContext *)defaultMainContext;

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  当前管理对象
 *
 *  @return 返回当前管理对象
 */
+ (NSManagedObjectContext *)currentContext;

#pragma mark -
#pragma mark :. FetchRequest

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  获取对象名称
 *
 *  @return 返回对象名称
 */
+ (NSString *)cc_EntityName;

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  请求所有
 *
 *  @return 返回请求条件对象
 */
+ (NSFetchRequest *)cc_AllRequest;

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  单条请求
 *
 *  @return 返回请求条件对象
 */
+ (NSFetchRequest *)cc_AnyoneRequest;

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
                                   batchSize:(NSUInteger)batchSize;

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
                                 fetchOffset:(NSUInteger)fetchOffset;

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
                   withValue:(id)value;

/**
 *  @author CC, 16-05-20
 *
 *  @brief  判断当前数据数据是否匹配
 *
 *  @param attributeName 属性名
 *  @param value         属性值
 */
- (BOOL)compareKeyValue:(NSString *)attributeName
              withValue:(id)value;

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
                          IsAdd:(BOOL)isAdd;

/**
 *  @author CC, 2015-10-29
 *
 *  @brief  对象属性
 *
 *  @return 返回对象所有属性
 */
- (NSArray *)allAttributeNames;

/**
 *  @author CC, 2015-10-29
 *
 *  @brief  对象关系
 *
 *  @return 返回对象所有关系集合
 */
- (NSArray *)allRelationshipNames;

- (NSAttributeDescription *)attributeDescriptionForAttribute:(NSString *)attributeName;
- (NSRelationshipDescription *)relationshipDescriptionForRelationship:(NSString *)relationshipName;

@end
