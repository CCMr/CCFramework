//
//  CCProperty.h
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

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "CCPropertyType.h"
#import "CCPropertyKey.h"

/**
 *  @author CC, 16-02-16
 *  
 *  @brief 包装一个成员
 */
@interface CCProperty : NSObject

/**
 *  @author CC, 16-02-16
 *  
 *  @brief 成员属性
 */
@property(nonatomic, assign) objc_property_t property;

/**
 *  @author CC, 16-02-16
 *  
 *  @brief 成员属性的名字
 */
@property(nonatomic, readonly) NSString *name;

/** 成员属性的类型 */
@property(nonatomic, readonly) CCPropertyType *type;

/**
 *  @author CC, 16-02-16
 *  
 *  @brief 成员属性来源于哪个类（可能是父类）
 */
@property(nonatomic, assign) Class srcClass;

/**
 *  @author CC, 16-02-16
 *  
 *  @brief 设置最原始的key
 *         同一个成员属性 - 父类和子类的行为可能不一致（originKey、propertyKeys、objectClassInArray
 *
 *  @param originKey <#originKey description#>
 *  @param c         <#c description#>
 */
- (void)setOriginKey:(id)originKey forClass:(Class)c;

/**
 *  @author CC, 16-02-16
 *  
 *  @brief 对应着字典中的多级key（里面存放的数组，数组里面都是CCPropertyKey对象）
 *
 *  @param c <#c description#>
 */
- (NSArray *)propertyKeysForClass:(Class)c;

/**
 *  @author CC, 16-02-16
 *  
 *  @brief 模型数组中的模型类型
 *
 *  @param objectClass <#objectClass description#>
 *  @param c           <#c description#>
 */
- (void)setObjectClassInArray:(Class)objectClass
                     forClass:(Class)c;

/**
 *  @author CC, 16-02-16
 *  
 *  @brief 同一个成员变量 - 父类和子类的行为可能不一致（key、keys、objectClassInArray）
 *
 *  @param c <#c description#>
 *
 *  @return <#return value description#>
 */
- (Class)objectClassInArrayForClass:(Class)c;

/**
 *  @author CC, 16-02-16
 *  
 *  @brief 设置object的成员变量值
 *
 *  @param value  <#value description#>
 *  @param object <#object description#>
 */
- (void)setValue:(id)value
       forObject:(id)object;

/**
 *  @author CC, 16-02-16
 *  
 *  @brief 得到object的成员属性值
 *
 *  @param object <#object description#>
 */
- (id)valueForObject:(id)object;

/**
 *  @author CC, 16-02-16
 *  
 *  @brief 初始化
 *
 *  @param property <#property description#>
 */
+ (instancetype)cachedPropertyWithProperty:(objc_property_t)property;

@end
