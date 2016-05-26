//
//  CCKeyValue.h
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

#import "NSObject+CCKeyValue.h"
#import "NSObject+CCProperty.h"
#import "NSString+CCExtension.h"
#import "CCProperty.h"
#import "CCPropertyType.h"
#import "CCExtensionConst.h"
#import "CCFoundation.h"
#import "NSString+CCExtension.h"
#import "NSObject+CCClass.h"
#import "CCNSLog.h"

#import <UIKit/UIKit.h>

@implementation NSObject (CCKeyValue)

#pragma mark - 错误
static const char CCErrorKey = '\0';
+ (NSError *)cc_error
{
    return objc_getAssociatedObject(self, &CCErrorKey);
}

+ (void)setcc_error:(NSError *)error
{
    objc_setAssociatedObject(self, &CCErrorKey, error, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - 模型 -> 字典时的参考
/** 模型转字典时，字典的key是否参考replacedKeyFromPropertyName等方法（父类设置了，子类也会继承下来） */
static const char CCReferenceReplacedKeyWhenCreatingKeyValuesKey = '\0';

+ (void)cc_referenceReplacedKeyWhenCreatingKeyValues:(BOOL)reference
{
    objc_setAssociatedObject(self, &CCReferenceReplacedKeyWhenCreatingKeyValuesKey, @(reference), OBJC_ASSOCIATION_ASSIGN);
}

+ (BOOL)cc_isReferenceReplacedKeyWhenCreatingKeyValues
{
    __block id value = objc_getAssociatedObject(self, &CCReferenceReplacedKeyWhenCreatingKeyValuesKey);
    if (!value) {
        [self cc_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            value = objc_getAssociatedObject(c, &CCReferenceReplacedKeyWhenCreatingKeyValuesKey);
            
            if (value) *stop = YES;
        }];
    }
    return [value boolValue];
}

#pragma mark - --常用的对象--
static NSNumberFormatter *numberFormatter_;
+ (void)load
{
    numberFormatter_ = [[NSNumberFormatter alloc] init];
    
    // 默认设置
    [self cc_referenceReplacedKeyWhenCreatingKeyValues:YES];
}

#pragma mark - --公共方法--
#pragma mark - 字典 -> 模型
- (instancetype)cc_setKeyValues:(id)keyValues
{
    return [self cc_setKeyValues:keyValues context:nil];
}

/**
 核心代码：
 */
- (instancetype)cc_setKeyValues:(id)keyValues context:(NSManagedObjectContext *)context
{
    // 获得JSON对象
    keyValues = [keyValues cc_JSONObject];
    
    CCExtensionAssertError([keyValues isKindOfClass:[NSDictionary class]], self, [self class], @"keyValues参数不是一个字典");
    
    Class clazz = [self class];
    NSArray *allowedPropertyNames = [clazz cc_totalAllowedPropertyNames];
    NSArray *ignoredPropertyNames = [clazz cc_totalIgnoredPropertyNames];
    
    //通过封装的方法回调一个通过运行时编写的，用于返回属性列表的方法。
    [clazz cc_enumerateProperties:^(CCProperty *property, BOOL *stop) {
        @try {
            // 0.检测是否被忽略
            if (allowedPropertyNames.count && ![allowedPropertyNames containsObject:property.name]) return;
            if ([ignoredPropertyNames containsObject:property.name]) return;
            
            // 1.取出属性值
            id value;
            NSArray *propertyKeyses = [property propertyKeysForClass:clazz];
            for (NSArray *propertyKeys in propertyKeyses) {
                value = keyValues;
                for (CCPropertyKey *propertyKey in propertyKeys) {
                    value = [propertyKey valueInObject:value];
                }
                if (value) break;
            }
            
            // 值的过滤
            id newValue = [clazz cc_getNewValueFromObject:self oldValue:value property:property];
            if (newValue != value) { // 有过滤后的新值
                [property setValue:newValue forObject:self];
                return;
            }
            
            // 如果没有值，就直接返回
            if (!value || value == [NSNull null]) return;
            
            // 2.复杂处理
            CCPropertyType *type = property.type;
            Class propertyClass = type.typeClass;
            Class objectClass = [property objectClassInArrayForClass:[self class]];
            
            // 不可变 -> 可变处理
            if (propertyClass == [NSMutableArray class] && [value isKindOfClass:[NSArray class]]) {
                value = [NSMutableArray arrayWithArray:value];
            } else if (propertyClass == [NSMutableDictionary class] && [value isKindOfClass:[NSDictionary class]]) {
                value = [NSMutableDictionary dictionaryWithDictionary:value];
            } else if (propertyClass == [NSMutableString class] && [value isKindOfClass:[NSString class]]) {
                value = [NSMutableString stringWithString:value];
            } else if (propertyClass == [NSMutableData class] && [value isKindOfClass:[NSData class]]) {
                value = [NSMutableData dataWithData:value];
            }
            
            if (!type.isFromFoundation && propertyClass) { // 模型属性
                id values = value;
                
                if (propertyClass != [NSManagedObjectID class])
                    values = [propertyClass cc_objectWithKeyValues:value context:context];
                
                if (values)
                    value = values;
            } else if (objectClass) {
                if (objectClass == [NSURL class] && [value isKindOfClass:[NSArray class]]) {
                    // string array -> url array
                    NSMutableArray *urlArray = [NSMutableArray array];
                    for (NSString *string in value) {
                        if (![string isKindOfClass:[NSString class]]) continue;
                        [urlArray addObject:string.cc_url];
                    }
                    value = urlArray;
                } else { // 字典数组-->模型数组
                    value = [objectClass cc_objectArrayWithKeyValuesArray:value context:context];
                }
            } else {
                if (propertyClass == [NSString class]) {
                    if ([value isKindOfClass:[NSNumber class]]) {
                        // NSNumber -> NSString
                        value = [value description];
                    } else if ([value isKindOfClass:[NSURL class]]) {
                        // NSURL -> NSString
                        value = [value absoluteString];
                    }
                }else if (propertyClass == [NSDate class]){ 
                    
                    if(![value isKindOfClass:[NSDate class]]){
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        NSRange range = [[NSString stringWithFormat:@"%@",value] rangeOfString:@"T"];
                        if (range.location != NSNotFound) {
                            [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
                        }else if([value isKindOfClass:[NSDate class]]){
                            [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                            [formatter setLocale:[NSLocale currentLocale]];
                        }
                        value = [formatter dateFromString:value];
                    }
                }else if ([value isKindOfClass:[NSString class]]) {
                    if (propertyClass == [NSURL class]) {
                        // NSString -> NSURL
                        // 字符串转码
                        value = [value cc_url];
                    } else if (type.isNumberType) {
                        NSString *oldValue = value;
                        
                        // NSString -> NSNumber
                        if (type.typeClass == [NSDecimalNumber class]) {
                            value = [NSDecimalNumber decimalNumberWithString:oldValue];
                        } else {
                            value = [numberFormatter_ numberFromString:oldValue];
                        }
                        
                        // 如果是BOOL
                        if (type.isBoolType) {
                            // 字符串转BOOL（字符串没有charValue方法）
                            // 系统会调用字符串的charValue转为BOOL类型
                            NSString *lower = [oldValue lowercaseString];
                            if ([lower isEqualToString:@"yes"] || [lower isEqualToString:@"true"]) {
                                value = @YES;
                            } else if ([lower isEqualToString:@"no"] || [lower isEqualToString:@"false"]) {
                                value = @NO;
                            }
                        }
                    }
                }
                
                // value和property类型不匹配
                if (propertyClass && ![value isKindOfClass:propertyClass]) {
                    value = nil;
                }
            }
            
            // 3.赋值
            [property setValue:value forObject:self];
        } @catch (NSException *exception) {
            CCExtensionBuildError([self class], exception.reason);
        }
    }];
    
    // 转换完毕
    if ([self respondsToSelector:@selector(cc_keyValuesDidFinishConvertingToObject)]) {
        [self cc_keyValuesDidFinishConvertingToObject];
    }
    return self;
}

+ (instancetype)cc_objectWithKeyValues:(id)keyValues
{
    return [self cc_objectWithKeyValues:keyValues context:nil];
}

+ (instancetype)cc_objectWithKeyValues:(id)keyValues context:(NSManagedObjectContext *)context
{
    // 获得JSON对象
    keyValues = [keyValues cc_JSONObject];
    CCExtensionAssertError([keyValues isKindOfClass:[NSDictionary class]], nil, [self class], @"keyValues参数不是一个字典");
    
    if ([self isSubclassOfClass:[NSManagedObject class]] && context) {
        return [[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext:context] cc_setKeyValues:keyValues context:context];
    }
    return [[[self alloc] init] cc_setKeyValues:keyValues];
}

+ (instancetype)cc_objectWithFilename:(NSString *)filename
{
    CCExtensionAssertError(filename != nil, nil, [self class], @"filename参数为nil");
    
    return [self cc_objectWithFile:[[NSBundle mainBundle] pathForResource:filename ofType:nil]];
}

+ (instancetype)cc_objectWithFile:(NSString *)file
{
    CCExtensionAssertError(file != nil, nil, [self class], @"file参数为nil");
    
    return [self cc_objectWithKeyValues:[NSDictionary dictionaryWithContentsOfFile:file]];
}

#pragma mark - 字典数组 -> 模型数组
+ (NSMutableArray *)cc_objectArrayWithKeyValuesArray:(NSArray *)keyValuesArray
{
    return [self cc_objectArrayWithKeyValuesArray:keyValuesArray context:nil];
}

+ (NSMutableArray *)cc_objectArrayWithKeyValuesArray:(id)keyValuesArray context:(NSManagedObjectContext *)context
{
    // 如果是JSON字符串
    keyValuesArray = [keyValuesArray cc_JSONObject];
    
    // 1.判断真实性
    CCExtensionAssertError([keyValuesArray isKindOfClass:[NSArray class]], nil, [self class], @"keyValuesArray参数不是一个数组");
    
    // 如果数组里面放的是NSString、NSNumber等数据
    if ([CCFoundation isClassFromFoundation:self]) return [NSMutableArray arrayWithArray:keyValuesArray];
    
    
    // 2.创建数组
    NSMutableArray *modelArray = [NSMutableArray array];
    
    // 3.遍历
    for (NSDictionary *keyValues in keyValuesArray) {
        if ([keyValues isKindOfClass:[NSArray class]]) {
            [modelArray addObject:[self cc_objectArrayWithKeyValuesArray:keyValues context:context]];
        } else {
            id model = [self cc_objectWithKeyValues:keyValues context:context];
            if (model) [modelArray addObject:model];
        }
    }
    
    return modelArray;
}

+ (NSMutableArray *)cc_objectArrayWithFilename:(NSString *)filename
{
    CCExtensionAssertError(filename != nil, nil, [self class], @"filename参数为nil");
    
    return [self cc_objectArrayWithFile:[[NSBundle mainBundle] pathForResource:filename ofType:nil]];
}

+ (NSMutableArray *)cc_objectArrayWithFile:(NSString *)file
{
    CCExtensionAssertError(file != nil, nil, [self class], @"file参数为nil");
    
    return [self cc_objectArrayWithKeyValuesArray:[NSArray arrayWithContentsOfFile:file]];
}

#pragma mark - 模型 -> 字典
- (NSMutableDictionary *)cc_keyValues
{
    return [self cc_keyValuesWithKeys:nil ignoredKeys:nil];
}

- (NSMutableDictionary *)cc_keyValuesWithKeys:(NSArray *)keys
{
    return [self cc_keyValuesWithKeys:keys ignoredKeys:nil];
}

- (NSMutableDictionary *)cc_keyValuesWithIgnoredKeys:(NSArray *)ignoredKeys
{
    return [self cc_keyValuesWithKeys:nil ignoredKeys:ignoredKeys];
}

- (NSMutableDictionary *)cc_keyValuesWithKeys:(NSArray *)keys ignoredKeys:(NSArray *)ignoredKeys
{
    // 如果自己不是模型类, 那就返回自己
    CCExtensionAssertError(![CCFoundation isClassFromFoundation:[self class]], (NSMutableDictionary *)self, [self class], @"不是自定义的模型类")
    
    id keyValues = [NSMutableDictionary dictionary];
    
    Class clazz = [self class];
    NSArray *allowedPropertyNames = [clazz cc_totalAllowedPropertyNames];
    NSArray *ignoredPropertyNames = [clazz cc_totalIgnoredPropertyNames];
    
    [clazz cc_enumerateProperties:^(CCProperty *property, BOOL *stop) {
        @try {
            // 0.检测是否被忽略
            if (allowedPropertyNames.count && ![allowedPropertyNames containsObject:property.name]) return;
            if ([ignoredPropertyNames containsObject:property.name]) return;
            if (keys.count && ![keys containsObject:property.name]) return;
            if ([ignoredKeys containsObject:property.name]) return;
            
            // 1.取出属性值
            id value = [property valueForObject:self];
            if (!value) return;
            
            // 2.如果是模型属性
            CCPropertyType *type = property.type;
            Class propertyClass = type.typeClass;
            if (!type.isFromFoundation && propertyClass) {
                if (![propertyClass isSubclassOfClass:[UIImage class]] && 
                    ![propertyClass isKindOfClass:[NSData class]] &&
                    ![propertyClass isKindOfClass:[NSDate class]] && 
                    propertyClass != [NSManagedObjectID class]) {
                    value = [value cc_keyValues];
                }
                
            } else if ([value isKindOfClass:[NSArray class]]) {
                // 3.处理数组里面有模型的情况
                value = [NSObject cc_keyValuesArrayWithObjectArray:value];
            } else if (propertyClass == [NSURL class]) {
                value = [value absoluteString];
            }
            
            // 4.赋值
            if ([clazz cc_isReferenceReplacedKeyWhenCreatingKeyValues]) {
                NSArray *propertyKeys = [[property propertyKeysForClass:clazz] firstObject];
                NSUInteger keyCount = propertyKeys.count;
                // 创建字典
                __block id innerContainer = keyValues;
                [propertyKeys enumerateObjectsUsingBlock:^(CCPropertyKey *propertyKey, NSUInteger idx, BOOL *stop) {
                    // 下一个属性
                    CCPropertyKey *nextPropertyKey = nil;
                    if (idx != keyCount - 1) {
                        nextPropertyKey = propertyKeys[idx + 1];
                    }
                    
                    if (nextPropertyKey) { // 不是最后一个key
                        // 当前propertyKey对应的字典或者数组
                        id tempInnerContainer = [propertyKey valueInObject:innerContainer];
                        if (tempInnerContainer == nil || [tempInnerContainer isKindOfClass:[NSNull class]]) {
                            if (nextPropertyKey.type == CCPropertyKeyTypeDictionary) {
                                tempInnerContainer = [NSMutableDictionary dictionary];
                            } else {
                                tempInnerContainer = [NSMutableArray array];
                            }
                            if (propertyKey.type == CCPropertyKeyTypeDictionary) {
                                innerContainer[propertyKey.name] = tempInnerContainer;
                            } else {
                                innerContainer[propertyKey.name.intValue] = tempInnerContainer;
                            }
                        }
                        
                        if ([tempInnerContainer isKindOfClass:[NSMutableArray class]]) {
                            NSMutableArray *tempInnerContainerArray = tempInnerContainer;
                            int index = nextPropertyKey.name.intValue;
                            while (tempInnerContainerArray.count < index + 1) {
                                [tempInnerContainerArray addObject:[NSNull null]];
                            }
                        }
                        
                        innerContainer = tempInnerContainer;
                    } else { // 最后一个key
                        if (propertyKey.type == CCPropertyKeyTypeDictionary) {
                            innerContainer[propertyKey.name] = value;
                        } else {
                            innerContainer[propertyKey.name.intValue] = value;
                        }
                    }
                }];
            } else {
                keyValues[property.name] = value;
            }
        } @catch (NSException *exception) {
            CCExtensionBuildError([self class], exception.reason);
            CCNSLogger(@"%@", exception);
        }
    }];
    
    // 转换完毕
    if ([self respondsToSelector:@selector(cc_objectDidFinishConvertingToKeyValues)]) {
        [self cc_objectDidFinishConvertingToKeyValues];
    }
    
    return keyValues;
}
#pragma mark - 模型数组 -> 字典数组
+ (NSMutableArray *)cc_keyValuesArrayWithObjectArray:(NSArray *)objectArray
{
    return [self cc_keyValuesArrayWithObjectArray:objectArray keys:nil ignoredKeys:nil];
}

+ (NSMutableArray *)cc_keyValuesArrayWithObjectArray:(NSArray *)objectArray
                                                keys:(NSArray *)keys
{
    return [self cc_keyValuesArrayWithObjectArray:objectArray keys:keys ignoredKeys:nil];
}

+ (NSMutableArray *)cc_keyValuesArrayWithObjectArray:(NSArray *)objectArray
                                         ignoredKeys:(NSArray *)ignoredKeys
{
    return [self cc_keyValuesArrayWithObjectArray:objectArray keys:nil ignoredKeys:ignoredKeys];
}

+ (NSMutableArray *)cc_keyValuesArrayWithObjectArray:(NSArray *)objectArray
                                                keys:(NSArray *)keys
                                         ignoredKeys:(NSArray *)ignoredKeys
{
    // 0.判断真实性
    CCExtensionAssertError([objectArray isKindOfClass:[NSArray class]], nil, [self class], @"objectArray参数不是一个数组");
    
    // 1.创建数组
    NSMutableArray *keyValuesArray = [NSMutableArray array];
    for (id object in objectArray) {
        if (keys) {
            [keyValuesArray addObject:[object cc_keyValuesWithKeys:keys]];
        } else {
            [keyValuesArray addObject:[object cc_keyValuesWithIgnoredKeys:ignoredKeys]];
        }
    }
    return keyValuesArray;
}

#pragma mark - 转换为JSON
- (NSData *)cc_JSONData
{
    if ([self isKindOfClass:[NSString class]]) {
        return [((NSString *)self)dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([self isKindOfClass:[NSData class]]) {
        return (NSData *)self;
    }
    
    return [NSJSONSerialization dataWithJSONObject:[self cc_JSONObject] options:kNilOptions error:nil];
}

- (id)cc_JSONObject
{
    if ([self isKindOfClass:[NSString class]]) {
        return [NSJSONSerialization JSONObjectWithData:[((NSString *)self)dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    } else if ([self isKindOfClass:[NSData class]]) {
        return [NSJSONSerialization JSONObjectWithData:(NSData *)self options:kNilOptions error:nil];
    }
    
    return self.cc_keyValues;
}

- (NSString *)cc_JSONString
{
    if ([self isKindOfClass:[NSString class]]) {
        return (NSString *)self;
    } else if ([self isKindOfClass:[NSData class]]) {
        return [[NSString alloc] initWithData:(NSData *)self encoding:NSUTF8StringEncoding];
    }
    
    return [[NSString alloc] initWithData:[self cc_JSONData] encoding:NSUTF8StringEncoding];
}
@end

@implementation NSObject (CCKeyValueDeprecated_v_2_5_16)
- (instancetype)setKeyValues:(id)keyValues
{
    return [self cc_setKeyValues:keyValues];
}

- (instancetype)setKeyValues:(id)keyValues
                       error:(NSError **)error
{
    id value = [self cc_setKeyValues:keyValues];
    if (error != NULL) {
        *error = [self.class cc_error];
    }
    return value;
}

- (instancetype)setKeyValues:(id)keyValues
                     context:(NSManagedObjectContext *)context
{
    return [self cc_setKeyValues:keyValues context:context];
}

- (instancetype)setKeyValues:(id)keyValues
                     context:(NSManagedObjectContext *)context
                       error:(NSError **)error
{
    id value = [self cc_setKeyValues:keyValues context:context];
    if (error != NULL) {
        *error = [self.class cc_error];
    }
    return value;
}

+ (void)referenceReplacedKeyWhenCreatingKeyValues:(BOOL)reference
{
    [self cc_referenceReplacedKeyWhenCreatingKeyValues:reference];
}

- (NSMutableDictionary *)keyValues
{
    return [self cc_keyValues];
}

- (NSMutableDictionary *)keyValuesWithError:(NSError **)error
{
    id value = [self cc_keyValues];
    if (error != NULL) {
        *error = [self.class cc_error];
    }
    return value;
}

- (NSMutableDictionary *)keyValuesWithKeys:(NSArray *)keys
{
    return [self cc_keyValuesWithKeys:keys];
}

- (NSMutableDictionary *)keyValuesWithKeys:(NSArray *)keys
                                     error:(NSError **)error
{
    id value = [self cc_keyValuesWithKeys:keys];
    if (error != NULL) {
        *error = [self.class cc_error];
    }
    return value;
}

- (NSMutableDictionary *)keyValuesWithIgnoredKeys:(NSArray *)ignoredKeys
{
    return [self cc_keyValuesWithIgnoredKeys:ignoredKeys];
}

- (NSMutableDictionary *)keyValuesWithIgnoredKeys:(NSArray *)ignoredKeys
                                            error:(NSError **)error
{
    id value = [self cc_keyValuesWithIgnoredKeys:ignoredKeys];
    if (error != NULL) {
        *error = [self.class cc_error];
    }
    return value;
}

+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray
{
    return [self cc_keyValuesArrayWithObjectArray:objectArray];
}

+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray
                                            error:(NSError **)error
{
    id value = [self cc_keyValuesArrayWithObjectArray:objectArray];
    if (error != NULL) {
        *error = [self cc_error];
    }
    return value;
}

+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray
                                             keys:(NSArray *)keys
{
    return [self cc_keyValuesArrayWithObjectArray:objectArray keys:keys];
}

+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray
                                             keys:(NSArray *)keys
                                            error:(NSError **)error
{
    id value = [self cc_keyValuesArrayWithObjectArray:objectArray keys:keys];
    if (error != NULL) {
        *error = [self cc_error];
    }
    return value;
}

+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray
                                      ignoredKeys:(NSArray *)ignoredKeys
{
    return [self cc_keyValuesArrayWithObjectArray:objectArray ignoredKeys:ignoredKeys];
}

+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray
                                      ignoredKeys:(NSArray *)ignoredKeys
                                            error:(NSError **)error
{
    id value = [self cc_keyValuesArrayWithObjectArray:objectArray ignoredKeys:ignoredKeys];
    if (error != NULL) {
        *error = [self cc_error];
    }
    return value;
}

+ (instancetype)objectWithKeyValues:(id)keyValues
{
    return [self cc_objectWithKeyValues:keyValues];
}

+ (instancetype)objectWithKeyValues:(id)keyValues
                              error:(NSError **)error
{
    id value = [self cc_objectWithKeyValues:keyValues];
    if (error != NULL) {
        *error = [self cc_error];
    }
    return value;
}

+ (instancetype)objectWithKeyValues:(id)keyValues
                            context:(NSManagedObjectContext *)context
{
    return [self cc_objectWithKeyValues:keyValues context:context];
}

+ (instancetype)objectWithKeyValues:(id)keyValues
                            context:(NSManagedObjectContext *)context
                              error:(NSError **)error
{
    id value = [self cc_objectWithKeyValues:keyValues context:context];
    if (error != NULL) {
        *error = [self cc_error];
    }
    return value;
}

+ (instancetype)objectWithFilename:(NSString *)filename
{
    return [self cc_objectWithFilename:filename];
}

+ (instancetype)objectWithFilename:(NSString *)filename
                             error:(NSError **)error
{
    id value = [self cc_objectWithFilename:filename];
    if (error != NULL) {
        *error = [self cc_error];
    }
    return value;
}

+ (instancetype)objectWithFile:(NSString *)file
{
    return [self cc_objectWithFile:file];
}

+ (instancetype)objectWithFile:(NSString *)file
                         error:(NSError **)error
{
    id value = [self cc_objectWithFile:file];
    if (error != NULL) {
        *error = [self cc_error];
    }
    return value;
}

+ (NSMutableArray *)objectArrayWithKeyValuesArray:(id)keyValuesArray
{
    return [self cc_objectArrayWithKeyValuesArray:keyValuesArray];
}

+ (NSMutableArray *)objectArrayWithKeyValuesArray:(id)keyValuesArray
                                            error:(NSError **)error
{
    id value = [self cc_objectArrayWithKeyValuesArray:keyValuesArray];
    if (error != NULL) {
        *error = [self cc_error];
    }
    return value;
}

+ (NSMutableArray *)objectArrayWithKeyValuesArray:(id)keyValuesArray
                                          context:(NSManagedObjectContext *)context
{
    return [self cc_objectArrayWithKeyValuesArray:keyValuesArray context:context];
}

+ (NSMutableArray *)objectArrayWithKeyValuesArray:(id)keyValuesArray
                                          context:(NSManagedObjectContext *)context
                                            error:(NSError **)error
{
    id value = [self cc_objectArrayWithKeyValuesArray:keyValuesArray context:context];
    if (error != NULL) {
        *error = [self cc_error];
    }
    return value;
}

+ (NSMutableArray *)objectArrayWithFilename:(NSString *)filename
{
    return [self cc_objectArrayWithFilename:filename];
}

+ (NSMutableArray *)objectArrayWithFilename:(NSString *)filename
                                      error:(NSError **)error
{
    id value = [self cc_objectArrayWithFilename:filename];
    if (error != NULL) {
        *error = [self cc_error];
    }
    return value;
}

+ (NSMutableArray *)objectArrayWithFile:(NSString *)file
{
    return [self cc_objectArrayWithFile:file];
}

+ (NSMutableArray *)objectArrayWithFile:(NSString *)file 
                                  error:(NSError **)error
{
    id value = [self cc_objectArrayWithFile:file];
    if (error != NULL) {
        *error = [self cc_error];
    }
    return value;
}

- (NSData *)JSONData
{
    return [self cc_JSONData];
}

- (id)JSONObject
{
    return [self cc_JSONObject];
}

- (NSString *)JSONString
{
    return [self cc_JSONString];
}
@end