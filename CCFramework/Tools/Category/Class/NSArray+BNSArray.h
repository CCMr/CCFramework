//
//  NSArray+BNSArray.h
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

@interface NSArray (BNSArray)

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  可变数组
 *
 *  @return <#return value description#>
 *
 *  @since <#version number#>
 */
- (NSMutableArray *)mutableArray;

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  创建可变数组
 *
 *  @param array <#array description#>
 *
 *  @return <#return value description#>
 *
 *  @since <#version number#>
 */
+ (NSMutableArray *)mutableUnEmptyArrayWithArray:(NSArray *)array;

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  只适用于截取URL  Value
 *
 *  @param key <#key description#>
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSString *)findOutUrlValueWithKey:(NSString *)key;

/**
 *  @author CC, 15-09-02
 *
 *  @brief  数组转字符串
 *
 *  @return 返回逗号分隔字符串
 *
 *  @since 1.0
 */
- (NSString *)toString;

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
- (BOOL)compareIgnoreObjectOrderWithArray: (NSArray *)ary;

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
- (NSArray *)arrayForIntersectionWithOtherArray: (NSArray *)otherAry;

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
- (NSArray *)arrayForMinusWithOtherArray: (NSArray *)otherAry;

/**
 *  @author C C, 2015-10-10
 *
 *  @brief  分析数据对象分组
 *
 *  @param analysisName 分析对象名称
 *
 *  @return 返回分组集合对象
 */
- (NSMutableDictionary *)analysisSortGroup: (NSString *)analysisName;

@end
