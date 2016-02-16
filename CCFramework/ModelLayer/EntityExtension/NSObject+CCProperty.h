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
#import "CCExtensionConst.h"

@class CCProperty;

/**
 *  遍历成员变量用的block
 *
 *  @param property 成员的包装对象
 *  @param stop   YES代表停止遍历，NO代表继续遍历
 */
typedef void (^CCPropertiesEnumeration)(CCProperty *property, BOOL *stop);

/** 将属性名换为其他key去字典中取值 */
typedef NSDictionary * (^CCReplacedKeyFromPropertyName)();
typedef NSString * (^CCReplacedKeyFromPropertyName121)(NSString *propertyName);
/** 数组中需要转换的模型类 */
typedef NSDictionary * (^CCObjectClassInArray)();
/** 用于过滤字典中的值 */
typedef id (^CCNewValueFromOldValue)(id object, id oldValue, CCProperty *property);

/**
 * 成员属性相关的扩展
 */
@interface NSObject (CCProperty)
#pragma mark - 遍历
/**
 *  遍历所有的成员
 */
+ (void)cc_enumerateProperties:(CCPropertiesEnumeration)enumeration;

#pragma mark - 新值配置
/**
 *  用于过滤字典中的值
 *
 *  @param newValueFormOldValue 用于过滤字典中的值
 */
+ (void)cc_setupNewValueFromOldValue:(CCNewValueFromOldValue)newValueFormOldValue;
+ (id)cc_getNewValueFromObject:(__unsafe_unretained id)object oldValue:(__unsafe_unretained id)oldValue property:(__unsafe_unretained CCProperty *)property;

#pragma mark - key配置
/**
 *  将属性名换为其他key去字典中取值
 *
 *  @param replacedKeyFromPropertyName 将属性名换为其他key去字典中取值
 */
+ (void)cc_setupReplacedKeyFromPropertyName:(CCReplacedKeyFromPropertyName)replacedKeyFromPropertyName;
/**
 *  将属性名换为其他key去字典中取值
 *
 *  @param replacedKeyFromPropertyName121 将属性名换为其他key去字典中取值
 */
+ (void)cc_setupReplacedKeyFromPropertyName121:(CCReplacedKeyFromPropertyName121)replacedKeyFromPropertyName121;

#pragma mark - array model class配置
/**
 *  数组中需要转换的模型类
 *
 *  @param objectClassInArray          数组中需要转换的模型类
 */
+ (void)cc_setupObjectClassInArray:(CCObjectClassInArray)objectClassInArray;
@end

@interface NSObject (CCPropertyDeprecated_v_2_5_16)
+ (void)enumerateProperties:(CCPropertiesEnumeration)enumeration CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
+ (void)setupNewValueFromOldValue:(CCNewValueFromOldValue)newValueFormOldValue CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
+ (id)getNewValueFromObject:(__unsafe_unretained id)object oldValue:(__unsafe_unretained id)oldValue property:(__unsafe_unretained CCProperty *)property CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
+ (void)setupReplacedKeyFromPropertyName:(CCReplacedKeyFromPropertyName)replacedKeyFromPropertyName CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
+ (void)setupReplacedKeyFromPropertyName121:(CCReplacedKeyFromPropertyName121)replacedKeyFromPropertyName121 CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
+ (void)setupObjectClassInArray:(CCObjectClassInArray)objectClassInArray CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
@end