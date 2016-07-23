//
//  NSArray+Additions.m
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

#import "NSArray+Additions.h"
#import "CCExtension.h"
#import <objc/runtime.h>

@implementation NSArray (Additions)

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  只适用于截取URL  Value
 *
 *  @param key <#key description#>
 */
- (NSString *)findOutUrlValueWithKey:(NSString *)key
{
    for (NSString *string in self) {
        NSRange range = [string rangeOfString:key];
        if (range.location != NSNotFound) {
            return [string substringFromIndex:range.location + range.length];
        }
    }
    return nil;
}

/**
 *  @author CC, 15-09-02
 *
 *  @brief  数组转字符串
 *
 *  @return 返回逗号分隔字符串
 *
 *  @since 1.0
 */
- (NSString *)toString
{
    if (self == nil || self.count == 0)
        return @"";
    NSMutableString *variableStr = [NSMutableString string];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [variableStr appendFormat:@"%@",obj];
    }];

    NSString *strForRigth = [variableStr substringWithRange:NSMakeRange(0, variableStr.length - 1)];
    return strForRigth;
}

/**
 *  @author CC, 15-09-02
 *
 *  @brief  数组对象比较
 *
 *  @param ary 比较数组对象
 */
- (BOOL)compareIgnoreObjectOrderWithArray:(NSArray *)ary
{
    NSSet *selfSet = [NSSet setWithArray:self];
    NSSet *arySet = [NSSet setWithArray:ary];
    return [selfSet isEqualToSet:arySet];
}

/**
 *  @author CC, 15-09-02
 *
 *  @brief  数组计算交集
 *
 *  @param otherAry <#otherAry description#>
 */
- (NSArray *)arrayForIntersectionWithOtherArray:(NSArray *)otherAry
{
    NSMutableArray *intersectionArray = [NSMutableArray array];
    if (self.count == 0) return nil;
    if (otherAry == nil) return nil;

    //遍历
    for (id obj in self) {
        if (![otherAry containsObject:obj]) continue;
        //添加
        [intersectionArray addObject:obj];
    }

    return intersectionArray;
}

/**
 *  @author CC, 15-09-02
 *
 *  @brief  数据计算差集
 *
 *  @param otherAry <#otherAry description#>
 */
- (NSArray *)arrayForMinusWithOtherArray:(NSArray *)otherAry
{
    if (!self) return nil;
    if (!otherAry) return self;

    NSMutableArray *minusArray = [NSMutableArray arrayWithArray:self];
    //遍历
    for (id obj in otherAry) {
        if (![self containsObject:obj]) continue;
        //添加
        [minusArray removeObject:obj];
    }

    return minusArray;
}

/**
 *  @author C C, 2015-10-10
 *
 *  @brief  分析数据对象分组
 *
 *  @param analysisName 分析对象名称
 *
 *  @return 返回分组集合对象
 */
- (NSMutableDictionary *)analysisSortGroup:(NSString *)analysisName
{
    NSMutableDictionary *sortGroupDic = [[NSMutableDictionary alloc] init];
    for (id object in self) {
        NSString *persoName = [self obtainObjectPropertyValues:object Attributes:analysisName];
        NSMutableString *personName = [[NSMutableString alloc] initWithString:persoName];
        //转拼音带音标
        CFStringTransform((__bridge CFMutableStringRef)personName, 0, kCFStringTransformMandarinLatin, NO);
        //必须先执行转带音标方法 转拼音不带音标
        CFStringTransform((__bridge CFMutableStringRef)personName, 0, kCFStringTransformStripDiacritics, NO);

        //转译错误的拼音
        NSString *sectionName;
        if ([[persoName substringToIndex:1] compare:@"长"] == NSOrderedSame)
            [personName replaceCharactersInRange:NSMakeRange(0, 5) withString:@"chang"];
        else if ([[personName substringToIndex:1] compare:@"沈"] == NSOrderedSame)
            [personName replaceCharactersInRange:NSMakeRange(0, 4) withString:@"shen"];
        else if ([[personName substringToIndex:1] compare:@"厦"] == NSOrderedSame)
            [personName replaceCharactersInRange:NSMakeRange(0, 3) withString:@"xia"];
        else if ([[personName substringToIndex:1] compare:@"地"] == NSOrderedSame)
            [personName replaceCharactersInRange:NSMakeRange(0, 3) withString:@"di"];
        else if ([[personName substringToIndex:1] compare:@"重"] == NSOrderedSame)
            [personName replaceCharactersInRange:NSMakeRange(0, 5) withString:@"chong"];

        char first = [[personName substringToIndex:1] characterAtIndex:0]; //头字母 转码
        //判断是是否 a-z|| A-Z
        if (isalpha(first) > 0)
            sectionName = [personName substringToIndex:1];
        else
            sectionName = @"#";

        NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:[sortGroupDic objectForKey:[sectionName uppercaseString]]];

        NSString *pinyin = personName;
        NSArray *arr = [pinyin componentsSeparatedByString:@" "];
        NSString *InitialName = @"";
        for (NSString *str in arr)
            InitialName = [NSString stringWithFormat:@"%@%@", InitialName, [str substringWithRange:NSMakeRange(0, 1)]];

        id pinyinObject = [self objectPropertyWithAttribute:object PinyinValue:personName InitialName:InitialName];

        [temp addObject:pinyinObject];
        temp = [[NSMutableArray alloc] initWithArray:[temp sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:analysisName ascending:YES], nil]]];
        [sortGroupDic setObject:temp forKey:[sectionName uppercaseString]];
    }
    return sortGroupDic;
}

/**
 *  @author CC, 16-07-23
 *
 *  @brief 获取对象属性值
 *
 *  @param obj       对象
 *  @param attribute 属性名
 */
- (NSString *)obtainObjectPropertyValues:(id)obj
                              Attributes:(NSString *)attribute
{
    NSString *attributeValue = nil;
    if ([obj isKindOfClass:[NSDictionary class]]) {
        attributeValue = [obj objectForKey:attribute];
    } else {
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList([obj class], &outCount);
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            const char *char_f = property_getName(property);
            NSString *propertyName = [NSString stringWithUTF8String:char_f];
            if ([propertyName isEqualToString:attribute]) {
                id propertyValue = [obj valueForKey:(NSString *)propertyName];
                if (propertyValue) {
                    attributeValue = propertyValue;
                    break;
                }
            }
        }
        free(properties);
    }
    return attributeValue;
}

- (id)objectPropertyWithAttribute:(id)object
                      PinyinValue:(NSString *)value
                      InitialName:(NSString *)initialName
{
    id obj;
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *PinyinDic = [[NSMutableDictionary alloc] initWithDictionary:object];
        [PinyinDic setObject:[value stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"pinyin"];
        [PinyinDic setObject:initialName forKey:@"initialName"];
        obj = PinyinDic;
    } else {
        //        objc_setAssociatedObject(object, @"pinyin", value, OBJC_ASSOCIATION_COPY_NONATOMIC);
        //        objc_setAssociatedObject(object, @"initialName", initialName, OBJC_ASSOCIATION_COPY_NONATOMIC);
        obj = object;
    }
    return obj;
}

/**
 *  @author CC, 2015-10-30
 *
 *  @brief  排序
 *
 *  @param ascending     是否升序
 *  @param sortedWithKey 排序字段
 *
 *  @return 返回排序结果
 */
- (NSArray *)sortedArray:(BOOL)ascending
           SortedWithKey:(NSString *)sortedWithKey, ... NS_REQUIRES_NIL_TERMINATION
{
    NSMutableArray *array = [NSMutableArray array];
    if (sortedWithKey) {
        [array addObject:[NSSortDescriptor sortDescriptorWithKey:sortedWithKey ascending:ascending]];
        va_list arguments;
        id eachObject;
        va_start(arguments, sortedWithKey);
        while ((eachObject = va_arg(arguments, id))) {
            [array addObject:[NSSortDescriptor sortDescriptorWithKey:eachObject ascending:ascending]];
        }
        va_end(arguments);
    }
    return [self sortedArrayUsingDescriptors:array];
}

#pragma mark -
#pragma mark :. Block

- (void)each:(void (^)(id object))block
{
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj);
    }];
}

- (void)eachWithIndex:(void (^)(id object, NSUInteger index))block
{
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj, idx);
    }];
}

- (NSArray *)map:(id (^)(id object))block
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];

    for (id object in self) {
        [array addObject:block(object) ?: [NSNull null]];
    }

    return array;
}

- (NSArray *)filter:(BOOL (^)(id object))block
{
    return [self filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return block(evaluatedObject);
    }]];
}

- (NSArray *)reject:(BOOL (^)(id object))block
{
    return [self filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return !block(evaluatedObject);
    }]];
}

- (id)detect:(BOOL (^)(id object))block
{
    for (id object in self) {
        if (block(object))
            return object;
    }
    return nil;
}

- (id)reduce:(id (^)(id accumulator, id object))block
{
    return [self reduce:nil withBlock:block];
}

- (id)reduce:(id)initial withBlock:(id (^)(id accumulator, id object))block
{
    id accumulator = initial;

    for (id object in self)
        accumulator = accumulator ? block(accumulator, object) : object;

    return accumulator;
}

#pragma mark -
#pragma mark :. SafeAccess

- (id)objectWithIndex:(NSUInteger)index
{
    if (index < self.count) {
        return self[index];
    } else {
        return nil;
    }
}

- (NSString *)stringWithIndex:(NSUInteger)index
{
    id value = [self objectWithIndex:index];
    if (value == nil || value == [NSNull null]) {
        return @"";
    }
    if ([value isKindOfClass:[NSString class]]) {
        return (NSString *)value;
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value stringValue];
    }

    return nil;
}


- (NSNumber *)numberWithIndex:(NSUInteger)index
{
    id value = [self objectWithIndex:index];
    if ([value isKindOfClass:[NSNumber class]]) {
        return (NSNumber *)value;
    }
    if ([value isKindOfClass:[NSString class]]) {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        return [f numberFromString:(NSString *)value];
    }
    return nil;
}

- (NSDecimalNumber *)decimalNumberWithIndex:(NSUInteger)index
{
    id value = [self objectWithIndex:index];

    if ([value isKindOfClass:[NSDecimalNumber class]]) {
        return value;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber *number = (NSNumber *)value;
        return [NSDecimalNumber decimalNumberWithDecimal:[number decimalValue]];
    } else if ([value isKindOfClass:[NSString class]]) {
        NSString *str = (NSString *)value;
        return [str isEqualToString:@""] ? nil : [NSDecimalNumber decimalNumberWithString:str];
    }
    return nil;
}

- (NSArray *)arrayWithIndex:(NSUInteger)index
{
    id value = [self objectWithIndex:index];
    if (value == nil || value == [NSNull null]) {
        return nil;
    }
    if ([value isKindOfClass:[NSArray class]]) {
        return value;
    }
    return nil;
}


- (NSDictionary *)dictionaryWithIndex:(NSUInteger)index
{
    id value = [self objectWithIndex:index];
    if (value == nil || value == [NSNull null]) {
        return nil;
    }
    if ([value isKindOfClass:[NSDictionary class]]) {
        return value;
    }
    return nil;
}

- (NSInteger)integerWithIndex:(NSUInteger)index
{
    id value = [self objectWithIndex:index];
    if (value == nil || value == [NSNull null]) {
        return 0;
    }
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
        return [value integerValue];
    }
    return 0;
}
- (NSUInteger)unsignedIntegerWithIndex:(NSUInteger)index
{
    id value = [self objectWithIndex:index];
    if (value == nil || value == [NSNull null]) {
        return 0;
    }
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
        return [value unsignedIntegerValue];
    }
    return 0;
}
- (BOOL)boolWithIndex:(NSUInteger)index
{
    id value = [self objectWithIndex:index];

    if (value == nil || value == [NSNull null]) {
        return NO;
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value boolValue];
    }
    if ([value isKindOfClass:[NSString class]]) {
        return [value boolValue];
    }
    return NO;
}
- (int16_t)int16WithIndex:(NSUInteger)index
{
    id value = [self objectWithIndex:index];

    if (value == nil || value == [NSNull null]) {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value shortValue];
    }
    if ([value isKindOfClass:[NSString class]]) {
        return [value intValue];
    }
    return 0;
}
- (int32_t)int32WithIndex:(NSUInteger)index
{
    id value = [self objectWithIndex:index];

    if (value == nil || value == [NSNull null]) {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value intValue];
    }
    return 0;
}
- (int64_t)int64WithIndex:(NSUInteger)index
{
    id value = [self objectWithIndex:index];

    if (value == nil || value == [NSNull null]) {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value longLongValue];
    }
    return 0;
}

- (char)charWithIndex:(NSUInteger)index
{

    id value = [self objectWithIndex:index];

    if (value == nil || value == [NSNull null]) {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value charValue];
    }
    return 0;
}

- (short)shortWithIndex:(NSUInteger)index
{
    id value = [self objectWithIndex:index];

    if (value == nil || value == [NSNull null]) {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value shortValue];
    }
    if ([value isKindOfClass:[NSString class]]) {
        return [value intValue];
    }
    return 0;
}
- (float)floatWithIndex:(NSUInteger)index
{
    id value = [self objectWithIndex:index];

    if (value == nil || value == [NSNull null]) {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value floatValue];
    }
    return 0;
}
- (double)doubleWithIndex:(NSUInteger)index
{
    id value = [self objectWithIndex:index];

    if (value == nil || value == [NSNull null]) {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value doubleValue];
    }
    return 0;
}

- (NSDate *)dateWithIndex:(NSUInteger)index dateFormat:(NSString *)dateFormat
{
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    formater.dateFormat = dateFormat;
    id value = [self objectWithIndex:index];

    if (value == nil || value == [NSNull null]) {
        return nil;
    }

    if ([value isKindOfClass:[NSString class]] && ![value isEqualToString:@""] && !dateFormat) {
        return [formater dateFromString:value];
    }
    return nil;
}

//CG
- (CGFloat)CGFloatWithIndex:(NSUInteger)index
{
    id value = [self objectWithIndex:index];

    CGFloat f = [value doubleValue];

    return f;
}

- (CGPoint)pointWithIndex:(NSUInteger)index
{
    id value = [self objectWithIndex:index];

    CGPoint point = CGPointFromString(value);

    return point;
}
- (CGSize)sizeWithIndex:(NSUInteger)index
{
    id value = [self objectWithIndex:index];

    CGSize size = CGSizeFromString(value);

    return size;
}
- (CGRect)rectWithIndex:(NSUInteger)index
{
    id value = [self objectWithIndex:index];

    CGRect rect = CGRectFromString(value);

    return rect;
}

@end


#pragma-- mark NSMutableArray setter

@implementation NSMutableArray (SafeAccess)

- (void)addObj:(id)i
{
    if (i != nil) {
        [self addObject:i];
    }
}
- (void)addString:(NSString *)i
{
    if (i != nil) {
        [self addObject:i];
    }
}
- (void)addBool:(BOOL)i
{
    [self addObject:@(i)];
}
- (void)addInt:(int)i
{
    [self addObject:@(i)];
}
- (void)addInteger:(NSInteger)i
{
    [self addObject:@(i)];
}
- (void)addUnsignedInteger:(NSUInteger)i
{
    [self addObject:@(i)];
}
- (void)addCGFloat:(CGFloat)f
{
    [self addObject:@(f)];
}
- (void)addChar:(char)c
{
    [self addObject:@(c)];
}
- (void)addFloat:(float)i
{
    [self addObject:@(i)];
}
- (void)addPoint:(CGPoint)o
{
    [self addObject:NSStringFromCGPoint(o)];
}
- (void)addSize:(CGSize)o
{
    [self addObject:NSStringFromCGSize(o)];
}
- (void)addRect:(CGRect)o
{
    [self addObject:NSStringFromCGRect(o)];
}

/**
 *  @author CC, 2015-07-22
 *
 *  @brief  去除重复数据
 *
 *  @param PropertyName 去重key
 */
- (void)deduplication:(NSArray *)PropertyName
{
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:[[NSSet setWithArray:[self mutableCopy]] allObjects]];

    NSMutableSet *seenObject = [NSMutableSet set];
    array = [[NSMutableArray alloc] initWithArray:[array filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [PropertyName enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *oDic = evaluatedObject;
            if ([evaluatedObject isKindOfClass:[NSObject class]]) {
                oDic = [evaluatedObject cc_keyValues];
            }
            [dic setObject:[oDic objectForKey:obj] forKey:obj];
        }];
        BOOL seen = [seenObject containsObject:dic];
        if (!seen)
            [seenObject addObject:dic];
        return !seen;
    }]]];
    [self removeAllObjects];
    [self addObjectsFromArray:array];
}

@end
