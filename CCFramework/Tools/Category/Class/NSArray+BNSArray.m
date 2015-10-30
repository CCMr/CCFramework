//
//  NSArray+BNSArray.m
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

#import "NSArray+BNSArray.h"

@implementation NSArray (BNSArray)

/**
 *  @author CC, 2015-07-23 10:07:46
 *
 *  @brief  可变数组
 *
 *  @return <#return value description#>
 *
 *  @since <#version number#>
 */
- (NSMutableArray *)mutableArray
{
    return [NSMutableArray arrayWithArray:self];
}

/**
 *  @author CC, 2015-07-23 10:07:39
 *
 *  @brief  创建可变数组
 *
 *  @param array <#array description#>
 *
 *  @return <#return value description#>
 *
 *  @since <#version number#>
 */
+ (NSMutableArray *)mutableUnEmptyArrayWithArray:(NSArray *)array
{
    if (array == nil) {
        return [NSMutableArray array];
    }
    return [array mutableArray];
}

/**
 *  @author CC, 2015-07-23 10:07:27
 *
 *  @brief  只适用于截取URL  Value
 *
 *  @param key <#key description#>
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
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
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
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
 *
 *  @return <#return value description#>
 *
 *  @since <#1.0#>
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
 *
 *  @return <#return value description#>
 *
 *  @since <#1.0#>
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
    for (NSDictionary *dic in self) {
        NSString *persoName = [dic objectForKey:analysisName];
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
        
        NSMutableDictionary *PinyinDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
        
        NSString *pinyin = personName;
        NSArray *arr = [pinyin componentsSeparatedByString:@" "];
        NSString *InitialName = @"";
        for (NSString *str in arr)
            InitialName = [NSString stringWithFormat:@"%@%@", InitialName, [str substringWithRange:NSMakeRange(0, 1)]];
        
        [PinyinDic setObject:[personName stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"Pinyin"];
        [PinyinDic setObject:InitialName forKey:@"InitialName"];
        
        [temp addObject:PinyinDic];
        temp = [[NSMutableArray alloc] initWithArray:[temp sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:analysisName ascending:YES], nil]]];
        [sortGroupDic setObject:temp forKey:[sectionName uppercaseString]];
    }
    return sortGroupDic;
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
        va_list arguments;
        id eachObject;
        va_start(arguments, sortedWithKey);
        while ((eachObject = va_arg(arguments, id))) {
            NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:sortedWithKey ascending:ascending];
            [array addObject:descriptor];
        }
        va_end(arguments);
    }
    return [self sortedArrayUsingDescriptors:array];
}

@end
