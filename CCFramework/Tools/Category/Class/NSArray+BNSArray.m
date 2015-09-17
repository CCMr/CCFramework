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
    for(NSString *string in self){
        NSRange range = [string rangeOfString:key];
        if(range.location != NSNotFound){
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
- (BOOL)compareIgnoreObjectOrderWithArray: (NSArray *)ary
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
- (NSArray *)arrayForIntersectionWithOtherArray: (NSArray *)otherAry
{
    NSMutableArray *intersectionArray=[NSMutableArray array];
    if(self.count==0) return nil;
    if(otherAry==nil) return nil;

    //遍历
    for (id obj in self) {
        if(![otherAry containsObject:obj]) continue;
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
- (NSArray *)arrayForMinusWithOtherArray: (NSArray *)otherAry
{
    if(!self) return nil;
    if(!otherAry) return self;

    NSMutableArray *minusArray=[NSMutableArray arrayWithArray:self];
    //遍历
    for (id obj in otherAry) {
        if(![self containsObject:obj]) continue;
        //添加
        [minusArray removeObject:obj];
    }

    return minusArray;
}

@end
