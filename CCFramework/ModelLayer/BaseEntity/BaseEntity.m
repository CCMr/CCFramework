//
//  BaseEntity.m
//  CC
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

#import "BaseEntity.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "NSData+Additions.h"
#import "UIImage+Data.h"

@interface BaseEntity ()

/**
 *  @author CC, 2015-08-01
 *
 *  @brief  对象数组属性
 *
 *  @since 1.0
 */
@property(nonatomic, strong) NSMutableArray *propertArray;

@end

@implementation BaseEntity

// must override
+ (id)dataWithJavaJsonDictonary:(NSDictionary *)jsonDic error:(NSError **)error
{
    if ([NSStringFromClass(self.class) isEqualToString:@"BaseEntity"]) {
        assert(0);
    }
    return [self.class new];
}

/**
 *  @author CC, 15-09-09
 *
 *  @brief  json字符串转换对象
 *
 *  @param jsonStr json字符串
 *
 *  @return 返回当前对象
 *
 *  @since 1.0
 */
+ (id)BaseEntityWithJson:(NSString *)jsonStr
{
    return [[self alloc] initWithJson:jsonStr];
}

/**
 *  @author CC, 2015-06-23
 *  @brief  NSDictionary转对象
 *  @since 1.0
 */
+ (id)BaseEntityWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

/**
 *  @author CC, 2015-06-23
 *  @brief  初始化对象
 *  @since 1.0
 */
- (id)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self populateObject:self fromDictionary:dict exclude:nil];
    }
    return self;
}

/**
 *  @author CC, 15-09-09
 *
 *  @brief  初始化对象
 *
 *  @param jsonStr json字符串
 *
 *  @return 返回当前对象
 *
 *  @since 1.0
 */
- (id)initWithJson:(NSString *)jsonStr
{
    if (self = [super init]) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
        [self populateObject:self fromDictionary:dic exclude:nil];
    }
    return self;
}

- (void)setDic:(NSDictionary *)dic
{
    [self populateObject:self fromDictionary:dic exclude:nil];
}

/**
 *  @author CC, 15-09-09
 *
 *  @brief  赋值属性
 *          递归解析子对象时，对象属性命名规则：对应属性名_对应对象名
 *
 *  @param jsonStr json字符串
 *
 *  @since 1.0
 */
- (void)setJson:(NSString *)jsonStr
{
    NSDictionary *dic = [NSJSONSerialization
                         JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]
                         options:NSJSONReadingAllowFragments
                         error:nil];
    [self populateObject:self fromDictionary:dic exclude:nil];
}

/**
 *  @author CC, 15-09-09
 *
 *  @brief  对象转换Json字符串
 *
 *  @return 返回当前json字符串
 *
 *  @since 1.0
 */
- (NSString *)ChangedJson
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self ChangedDictionary]
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    return [jsonData ChangedString];
}

- (NSDictionary *)ChangedDictionary
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int propsCount;
    objc_property_t *props =
    class_copyPropertyList([self class], &propsCount); //获得属性列表
    
    for (int i = 0; i < propsCount; i++) {
        objc_property_t prop = props[i];
        NSString *propName = [NSString
                              stringWithUTF8String:property_getName(prop)]; //获得属性的名称
        
        const char *propType = getPropertyType(prop);
        NSString *propertyType = [NSString stringWithUTF8String:propType]; //获得属性类型
        
        id value = [self valueForKey:propName]; // kvc读值
        if (!value) {
            if ([propertyType isEqualToString:@"NSString"])
                value = @"";
            else if ([propertyType isEqualToString:@"int"])
                value = 0;
            else if ([propertyType isEqualToString:@"NSManagedObjectID"])
                value = [NSManagedObjectID new];
            else if ([propertyType isEqualToString:@"NSMutableArray"] ||
                     [propertyType isEqualToString:@"NSArray"])
                value = [NSMutableArray array];
            else
                value = nil;
        } else
            value = [self ObjectInternal:value];
        if (value) [dic setObject:value forKey:propName];
    }
    return dic;
}

- (id)ObjectInternal:(id)obj
{
    if ([obj isKindOfClass:[NSString class]] ||
        [obj isKindOfClass:[NSNumber class]] ||
        [obj isKindOfClass:[NSNull class]] ||
        [obj isKindOfClass:[NSManagedObjectID class]] ||
        [obj isKindOfClass:[NSData class]] ||
        [obj isKindOfClass:[NSDate class]])
        return obj;
    
    if ([obj isKindOfClass:[UIImage class]]) {
        obj = [obj data];
        return obj;
    }
    
    if ([obj isKindOfClass:[NSArray class]]) {
        NSArray *objarr = obj;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];
        [objarr
         enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
             [arr setObject:[self ObjectInternal:obj] atIndexedSubscript:idx];
         }];
        return arr;
    } else if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *objdic = obj;
        NSMutableDictionary *dic =
        [NSMutableDictionary dictionaryWithCapacity:[objdic count]];
        for (NSString *key in objdic.allKeys)
            [dic setObject:[self ObjectInternal:[objdic objectForKey:key]]
                    forKey:key];
        return dic;
    } else if ([obj isKindOfClass:[BaseEntity class]]) { //对象解析
        return [obj ChangedDictionary];
    }
    return [self ObjectInternal:obj];
}

#pragma mark - Get properties for a class
- (id)populateObject:(id)obj
      fromDictionary:(NSDictionary *)dict
             exclude:(NSArray *)excludeArray
{
    if (obj == nil) return nil;
    
    Class cls = [obj class];
    NSDictionary *properties = [self propertiesForClass:cls];
    for (id keys in dict) {
        
        if ([keys isKindOfClass:[NSString class]] == NO) continue;
        
        __block NSString *key = keys;
        if (![properties objectForKey:keys]) {
            //不区分大小写解析对象属性
            [properties.allKeys
             enumerateObjectsUsingBlock:^(id obj, NSUInteger idx,
                                          BOOL *stop) {
                 if ([obj compare:key options:NSCaseInsensitiveSearch] == NSOrderedSame)
                     key = obj;
             }];
            
            if ([key isEqualToString:keys]) continue;
        }
        
        if (excludeArray && [excludeArray indexOfObject:key] != NSNotFound)
            continue;
        
        id value = [self analysisValue:properties
                             ValueDdic:dict
                                   Key:keys];
        
        NSString *propertyType = [properties objectForKey:key];
        
        //对应属性对象与对应对象实体名称
        __block NSString *propertKey, *classKey;
        if ([propertyType isEqualToString:@"NSArray"] ||
            [propertyType isEqualToString:@"NSMutableArray"]) {
            
            if (!_propertArray) {
                //获取对象属性中是数组的属性
                _propertArray = [NSMutableArray array];
                [properties.allKeys
                 enumerateObjectsUsingBlock:^(id obj, NSUInteger idx,
                                              BOOL *stop) {
                     id type = [properties objectForKey:obj];
                     
                     if ([type isEqualToString:@"NSArray"] ||
                         [type isEqualToString:@"NSMutableArray"]) {
                         [_propertArray addObject:obj];
                     }
                 }];
            }
            
            //匹配当前属性
            [_propertArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx,
                                                        BOOL *stop) {
                NSArray *keyAry = [obj componentsSeparatedByString:@"_"];
                if (keyAry.count > 1) {
                    //子对象名
                    NSString *className = keyAry.lastObject;
                    //解析判断字段名
                    NSString *isKey =
                    [obj stringByReplacingOccurrencesOfString:
                     [NSString stringWithFormat:@"_%@", className]
                                                   withString:@""];
                    
                    if ([key isEqualToString:isKey]) {
                        propertKey = obj;
                        classKey = className;
                    }
                }
            }];
        }
        
        if ([propertyType isEqualToString:@"NSString"] &&
            [value isKindOfClass:[NSArray class]]) {
            NSArray *arr = (NSArray *)value;
            NSString *arrString = [arr componentsJoinedByString:@","];
            [obj setValue:arrString forKey:key];
        } else if (![propertyType isEqualToString:@"NSString"] &&
                   ![propertyType isEqualToString:@"NSDictionary"] &&
                   [value isKindOfClass:[NSDictionary class]]) {
            Class objCls = NSClassFromString(propertyType);
            id childObj = [[objCls alloc] init];
            
            [self populateObject:childObj fromDictionary:value exclude:nil];
            
            [obj setValue:childObj forKey:key];
        } else if (propertKey && classKey) { // 子对象的解析子对象类名
            Class objCls = NSClassFromString(classKey);
            
            NSMutableArray *chilArray = [NSMutableArray array];
            [value enumerateObjectsUsingBlock:^(id valueObj, NSUInteger idx,
                                                BOOL *stop) {
                //创建子对象
                //递归解析对象
                id childObj = [[objCls alloc] init];
                [self populateObject:childObj
                      fromDictionary:valueObj
                             exclude:nil];
                [chilArray addObject:childObj];
            }];
            
            [obj setValue:chilArray forKey:propertKey];
        } else { // Else, set value for key
            [obj setValue:value forKey:key];
        }
    }
    
    return obj;
}

/**
 *  @author CC, 15-09-22
 *
 *  @brief  获取对象属性名与属性类型
 *
 *  @param cls 对象
 *
 *  @return 返回属性与属性类型集合
 */
- (NSDictionary *)propertiesForClass:(Class)cls
{
    if (cls == NULL) return nil;
    
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(cls, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if (propName) {
            
            NSString *keyName = [[NSString alloc] initWithUTF8String:propName];
            NSArray *keyAry = [keyName componentsSeparatedByString:@"_"];
            if (keyAry.count > 1) {
                //子对象名
                NSString *className = keyAry.lastObject;
                //解析判断字段名
                NSString *isKey =
                [keyName stringByReplacingOccurrencesOfString:
                 [NSString stringWithFormat:@"_%@", className]
                                                   withString:@""];
                
                const char *propType = getPropertyType(property);
                NSString *propertyName =
                [NSString stringWithUTF8String:
                 [isKey UTF8String]]; //属性名称转换成小写
                NSString *propertyType =
                [NSString stringWithUTF8String:propType];
                [results setObject:propertyType forKey:propertyName];
            }
            
            const char *propType = getPropertyType(property);
            NSString *propertyName =
            [NSString stringWithUTF8String:propName]; //属性名称转换成小写
            NSString *propertyType = [NSString stringWithUTF8String:propType];
            [results setObject:propertyType forKey:propertyName];
        }
    }
    
    free(properties);
    // returning a copy here to make sure the dictionary is immutable
    return [NSDictionary dictionaryWithDictionary:results];
}

static const char *getPropertyType(objc_property_t property)
{
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            // it's a C primitive type:
            /*
             if you want a list of what will be returned for these
             primitives,
             search online for
             "objective-c" "Property Attribute Description Examples"
             apple docs list plenty of examples of what you get for
             int "i",
             long "l", unsigned "I", struct, etc.
             */
            NSString *name = [[NSString alloc] initWithBytes:attribute + 1
                                                      length:strlen(attribute) - 1
                                                    encoding:NSASCIIStringEncoding];
            
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        } else if (attribute[0] == 'T' && attribute[1] == '@' &&
                   strlen(attribute) == 2) {
            // it's an ObjC id type:
            return "id";
        } else if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            NSString *name = [[NSString alloc] initWithBytes:attribute + 3
                                                      length:strlen(attribute) - 4
                                                    encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
    }
    return "";
}

/**
 *  @author CC, 2015-10-15
 *
 *  @brief  分析数据值去除NULL
 *
 *  @param properties 对象属性列表
 *  @param dict       对象数据值
 *  @param key        属性名
 *
 *  @return 返回值
 */
- (id)analysisValue:(NSDictionary *)properties
          ValueDdic:(NSDictionary *)dict
                Key:(NSString *)key
{
    NSString *propertyType = [properties objectForKey:key];
    id value = [dict objectForKey:key];
    if ([value isKindOfClass:[NSNull class]]) {
        if ([propertyType isEqualToString:@"NSString"]) {
            value = @"";
        } else if ([propertyType isEqualToString:@"i"] ||
                   [propertyType isEqualToString:@"l"] ||
                   [propertyType isEqualToString:@"q"] ||
                   [propertyType isEqualToString:@"I"]) {
            value = @(-1);
        }else if ([propertyType isEqualToString:@"NSArray"] || 
                  [propertyType isEqualToString:@"NSMutableArray"]){
            value = @[];
        }else if ([propertyType isEqualToString:@"B"]){
            value =@(NO);
        }
    }else{
        NSString *propertyType = [properties objectForKey:key];
        if ([propertyType isEqualToString:@"c"]) {
            value = @([[dict objectForKey:key] boolValue]); 
        }
    }
    
    return value;
}

@end
