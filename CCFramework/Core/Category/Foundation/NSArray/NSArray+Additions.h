//
//  NSArray+Additions.h
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
#import <UIKit/UIKit.h>

@interface NSArray (Additions)

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  只适用于截取URL  Value
 *
 *  @param key key
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
 */
- (BOOL)compareIgnoreObjectOrderWithArray:(NSArray *)ary;

/**
 *  @author CC, 15-09-02
 *
 *  @brief  数组计算交集
 *
 *  @param otherAry 数组
 */
- (NSArray *)arrayForIntersectionWithOtherArray:(NSArray *)otherAry;

/**
 *  @author CC, 15-09-02
 *
 *  @brief  数据计算差集
 *
 *  @param otherAry 数组
 */
- (NSArray *)arrayForMinusWithOtherArray:(NSArray *)otherAry;

/**
 *  @author C C, 2015-10-10
 *
 *  @brief  分析数据对象分组
 *
 *  @param analysisName 分析对象名称
 */
- (NSMutableDictionary *)analysisSortGroup:(NSString *)analysisName;

/**
 *  @author CC, 2015-10-30
 *  
 *  @brief  排序
 *
 *  @param ascending     是否升序
 *  @param sortedWithKey 排序字段
 */
- (NSArray *)sortedArray:(BOOL)ascending
           SortedWithKey:(NSString *)sortedWithKey, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark -
#pragma mark :. Block

- (void)each:(void (^)(id object))block;
- (void)eachWithIndex:(void (^)(id object, NSUInteger index))block;
- (NSArray *)map:(id (^)(id object))block;
- (NSArray *)filter:(BOOL (^)(id object))block;
- (NSArray *)reject:(BOOL (^)(id object))block;
- (id)detect:(BOOL (^)(id object))block;
- (id)reduce:(id (^)(id accumulator, id object))block;
- (id)reduce:(id)initial withBlock:(id (^)(id accumulator, id object))block;

#pragma mark -
#pragma mark :. SafeAccess

- (id)objectWithIndex:(NSUInteger)index;

- (NSString *)stringWithIndex:(NSUInteger)index;

- (NSNumber *)numberWithIndex:(NSUInteger)index;

- (NSDecimalNumber *)decimalNumberWithIndex:(NSUInteger)index;

- (NSArray *)arrayWithIndex:(NSUInteger)index;

- (NSDictionary *)dictionaryWithIndex:(NSUInteger)index;

- (NSInteger)integerWithIndex:(NSUInteger)index;

- (NSUInteger)unsignedIntegerWithIndex:(NSUInteger)index;

- (BOOL)boolWithIndex:(NSUInteger)index;

- (int16_t)int16WithIndex:(NSUInteger)index;

- (int32_t)int32WithIndex:(NSUInteger)index;

- (int64_t)int64WithIndex:(NSUInteger)index;

- (char)charWithIndex:(NSUInteger)index;

- (short)shortWithIndex:(NSUInteger)index;

- (float)floatWithIndex:(NSUInteger)index;

- (double)doubleWithIndex:(NSUInteger)index;

- (NSDate *)dateWithIndex:(NSUInteger)index dateFormat:(NSString *)dateFormat;
//CG
- (CGFloat)CGFloatWithIndex:(NSUInteger)index;

- (CGPoint)pointWithIndex:(NSUInteger)index;

- (CGSize)sizeWithIndex:(NSUInteger)index;

- (CGRect)rectWithIndex:(NSUInteger)index;

@end


#pragma mark - NSMutableArray setter

@interface NSMutableArray (SafeAccess)

- (void)addObj:(id)i;

- (void)addString:(NSString *)i;

- (void)addBool:(BOOL)i;

- (void)addInt:(int)i;

- (void)addInteger:(NSInteger)i;

- (void)addUnsignedInteger:(NSUInteger)i;

- (void)addCGFloat:(CGFloat)f;

- (void)addChar:(char)c;

- (void)addFloat:(float)i;

- (void)addPoint:(CGPoint)o;

- (void)addSize:(CGSize)o;

- (void)addRect:(CGRect)o;

/**
 *  @author CC, 2015-07-22
 *
 *  @brief  去除重复数据
 *
 *  @param PropertyName 去重key
 */
- (void)deduplication:(NSArray *)PropertyName;

@end