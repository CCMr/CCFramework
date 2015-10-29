//
//  NSManagedObject+Mapping.h
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

@interface NSManagedObject (Mapping)

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
