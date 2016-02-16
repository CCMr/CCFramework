//
//  CCProperty.m
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

#import "NSObject+CCProperty.h"
#import "NSObject+CCKeyValue.h"
#import "NSObject+CCCoding.h"
#import "NSObject+CCClass.h"
#import "CCProperty.h"
#import "CCFoundation.h"
#import <objc/runtime.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

static const char CCReplacedKeyFromPropertyNameKey = '\0';
static const char CCReplacedKeyFromPropertyName121Key = '\0';
static const char CCNewValueFromOldValueKey = '\0';
static const char CCObjectClassInArrayKey = '\0';

static const char CCCachedPropertiesKey = '\0';

@implementation NSObject (Property)

static NSMutableDictionary *replacedKeyFromPropertyNameDict_;
static NSMutableDictionary *replacedKeyFromPropertyName121Dict_;
static NSMutableDictionary *newValueFromOldValueDict_;
static NSMutableDictionary *objectClassInArrayDict_;
static NSMutableDictionary *cachedPropertiesDict_;

+ (void)load
{
    replacedKeyFromPropertyNameDict_ = [NSMutableDictionary dictionary];
    replacedKeyFromPropertyName121Dict_ = [NSMutableDictionary dictionary];
    newValueFromOldValueDict_ = [NSMutableDictionary dictionary];
    objectClassInArrayDict_ = [NSMutableDictionary dictionary];
    cachedPropertiesDict_ = [NSMutableDictionary dictionary];
}

+ (NSMutableDictionary *)dictForKey:(const void *)key
{
    if (key == &CCReplacedKeyFromPropertyNameKey) return replacedKeyFromPropertyNameDict_;
    if (key == &CCReplacedKeyFromPropertyName121Key) return replacedKeyFromPropertyName121Dict_;
    if (key == &CCNewValueFromOldValueKey) return newValueFromOldValueDict_;
    if (key == &CCObjectClassInArrayKey) return objectClassInArrayDict_;
    if (key == &CCCachedPropertiesKey) return cachedPropertiesDict_;
    return nil;
}

#pragma mark - --私有方法--
+ (NSString *)propertyKey:(NSString *)propertyName
{
    CCExtensionAssertParamNotNil2(propertyName, nil);
    
    __block NSString *key = nil;
    // 查看有没有需要替换的key
    if ([self respondsToSelector:@selector(CC_replacedKeyFromPropertyName121:)]) {
        key = [self cc_replacedKeyFromPropertyName121:propertyName];
    }
    // 兼容旧版本
    if ([self respondsToSelector:@selector(replacedKeyFromPropertyName121:)]) {
        key = [self performSelector:@selector(replacedKeyFromPropertyName121) withObject:propertyName];
    }
    
    // 调用block
    if (!key) {
        [self cc_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            CCReplacedKeyFromPropertyName121 block = objc_getAssociatedObject(c, &CCReplacedKeyFromPropertyName121Key);
            if (block) {
                key = block(propertyName);
            }
            if (key) *stop = YES;
        }];
    }
    
    // 查看有没有需要替换的key
    if (!key && [self respondsToSelector:@selector(CC_replacedKeyFromPropertyName)]) {
        key = [self cc_replacedKeyFromPropertyName][propertyName];
    }
    // 兼容旧版本
    if (!key && [self respondsToSelector:@selector(replacedKeyFromPropertyName)]) {
        key = [self performSelector:@selector(replacedKeyFromPropertyName)][propertyName];
    }
    
    if (!key) {
        [self cc_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            NSDictionary *dict = objc_getAssociatedObject(c, &CCReplacedKeyFromPropertyNameKey);
            if (dict) {
                key = dict[propertyName];
            }
            if (key) *stop = YES;
        }];
    }
    
    // 2.用属性名作为key
    if (!key) key = propertyName;
    
    return key;
}

+ (Class)propertyObjectClassInArray:(NSString *)propertyName
{
    __block id clazz = nil;
    if ([self respondsToSelector:@selector(CC_objectClassInArray)]) {
        clazz = [self cc_objectClassInArray][propertyName];
    }
    // 兼容旧版本
    if ([self respondsToSelector:@selector(objectClassInArray)]) {
        clazz = [self performSelector:@selector(objectClassInArray)][propertyName];
    }
    
    if (!clazz) {
        [self cc_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            NSDictionary *dict = objc_getAssociatedObject(c, &CCObjectClassInArrayKey);
            if (dict) {
                clazz = dict[propertyName];
            }
            if (clazz) *stop = YES;
        }];
    }
    
    // 如果是NSString类型
    if ([clazz isKindOfClass:[NSString class]]) {
        clazz = NSClassFromString(clazz);
    }
    return clazz;
}

#pragma mark - --公共方法--
+ (void)cc_enumerateProperties:(CCPropertiesEnumeration)enumeration
{
    // 获得成员变量
    NSArray *cachedProperties = [self properties];
    
    // 遍历成员变量
    BOOL stop = NO;
    for (CCProperty *property in cachedProperties) {
        enumeration(property, &stop);
        if (stop) break;
    }
}

#pragma mark - 公共方法
+ (NSMutableArray *)properties
{
    NSMutableArray *cachedProperties = [self dictForKey:&CCCachedPropertiesKey][NSStringFromClass(self)];
    
    if (cachedProperties == nil) {
        cachedProperties = [NSMutableArray array];
        
        [self cc_enumerateClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            // 1.获得所有的成员变量
            unsigned int outCount = 0;
            objc_property_t *properties = class_copyPropertyList(c, &outCount);
            
            // 2.遍历每一个成员变量
            for (unsigned int i = 0; i<outCount; i++) {
                CCProperty *property = [CCProperty cachedPropertyWithProperty:properties[i]];
                // 过滤掉系统自动添加的元素
                if ([property.name isEqualToString:@"hash"]
                    || [property.name isEqualToString:@"superclass"]
                    || [property.name isEqualToString:@"description"]
                    || [property.name isEqualToString:@"debugDescription"]) {
                    continue;
                }
                property.srcClass = c;
                [property setOriginKey:[self propertyKey:property.name] forClass:self];
                [property setObjectClassInArray:[self propertyObjectClassInArray:property.name] forClass:self];
                [cachedProperties addObject:property];
            }
            
            // 3.释放内存
            free(properties);
        }];
        
        [self dictForKey:&CCCachedPropertiesKey][NSStringFromClass(self)] = cachedProperties;
    }
    
    return cachedProperties;
}

#pragma mark - 新值配置
+ (void)cc_setupNewValueFromOldValue:(CCNewValueFromOldValue)newValueFormOldValue
{
    objc_setAssociatedObject(self, &CCNewValueFromOldValueKey, newValueFormOldValue, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (id)CC_getNewValueFromObject:(__unsafe_unretained id)object oldValue:(__unsafe_unretained id)oldValue property:(CCProperty *__unsafe_unretained)property{
    // 如果有实现方法
    if ([object respondsToSelector:@selector(CC_newValueFromOldValue:property:)]) {
        return [object cc_newValueFromOldValue:oldValue property:property];
    }
    // 兼容旧版本
    if ([self respondsToSelector:@selector(newValueFromOldValue:property:)]) {
        return [self performSelector:@selector(newValueFromOldValue:property:)  withObject:oldValue  withObject:property];
    }
    
    // 查看静态设置
    __block id newValue = oldValue;
    [self cc_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
        CCNewValueFromOldValue block = objc_getAssociatedObject(c, &CCNewValueFromOldValueKey);
        if (block) {
            newValue = block(object, oldValue, property);
            *stop = YES;
        }
    }];
    return newValue;
}

#pragma mark - array model class配置
+ (void)cc_setupObjectClassInArray:(CCObjectClassInArray)objectClassInArray
{
    [self cc_setupBlockReturnValue:objectClassInArray key:&CCObjectClassInArrayKey];
    
    [[self dictForKey:&CCCachedPropertiesKey] removeAllObjects];
}

#pragma mark - key配置
+ (void)cc_setupReplacedKeyFromPropertyName:(CCReplacedKeyFromPropertyName)replacedKeyFromPropertyName
{
    [self cc_setupBlockReturnValue:replacedKeyFromPropertyName key:&CCReplacedKeyFromPropertyNameKey];
    
    [[self dictForKey:&CCCachedPropertiesKey] removeAllObjects];
}

+ (void)cc_setupReplacedKeyFromPropertyName121:(CCReplacedKeyFromPropertyName121)replacedKeyFromPropertyName121
{
    objc_setAssociatedObject(self, &CCReplacedKeyFromPropertyName121Key, replacedKeyFromPropertyName121, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    [[self dictForKey:&CCCachedPropertiesKey] removeAllObjects];
}
@end

@implementation NSObject (CCPropertyDeprecated_v_2_5_16)
+ (void)enumerateProperties:(CCPropertiesEnumeration)enumeration
{
    [self cc_enumerateProperties:enumeration];
}

+ (void)setupNewValueFromOldValue:(CCNewValueFromOldValue)newValueFormOldValue
{
    [self cc_setupNewValueFromOldValue:newValueFormOldValue];
}

+ (id)getNewValueFromObject:(__unsafe_unretained id)object oldValue:(__unsafe_unretained id)oldValue property:(__unsafe_unretained CCProperty *)property
{
    return [self CC_getNewValueFromObject:object oldValue:oldValue property:property];
}

+ (void)setupReplacedKeyFromPropertyName:(CCReplacedKeyFromPropertyName)replacedKeyFromPropertyName
{
    [self cc_setupReplacedKeyFromPropertyName:replacedKeyFromPropertyName];
}

+ (void)setupReplacedKeyFromPropertyName121:(CCReplacedKeyFromPropertyName121)replacedKeyFromPropertyName121
{
    [self cc_setupReplacedKeyFromPropertyName121:replacedKeyFromPropertyName121];
}

+ (void)setupObjectClassInArray:(CCObjectClassInArray)objectClassInArray
{
    [self cc_setupObjectClassInArray:objectClassInArray];
}
@end

#pragma clang diagnostic pop
