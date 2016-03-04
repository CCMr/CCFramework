//
//  NSDictionary+Additions.h
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

@interface NSDictionary (Additions)

#pragma mark - Manipulation
- (NSDictionary *)dictionaryByAddingEntriesFromDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryByRemovingEntriesWithKeys:(NSSet *)keys;

/**
 *  @brief NSDictionary转换成JSON字符串
 *
 *  @return  JSON字符串
 */
-(NSString *)JSONString;

#pragma mark -
#pragma mark :. Block

- (void)each:(void (^)(id k, id v))block;
- (void)eachKey:(void (^)(id k))block;
- (void)eachValue:(void (^)(id v))block;
- (NSArray *)map:(id (^)(id key, id value))block;
- (NSDictionary *)pick:(NSArray *)keys;
- (NSDictionary *)omit:(NSArray *)key;

#pragma mark -
#pragma mark :. SafeAccess

- (BOOL)hasKey:(NSString *)key;

- (NSString *)stringForKey:(id)key;

- (NSNumber *)numberForKey:(id)key;

- (NSDecimalNumber *)decimalNumberForKey:(id)key;

- (NSArray *)arrayForKey:(id)key;

- (NSDictionary *)dictionaryForKey:(id)key;

- (NSInteger)integerForKey:(id)key;

- (NSUInteger)unsignedIntegerForKey:(id)key;

- (BOOL)boolForKey:(id)key;

- (int16_t)int16ForKey:(id)key;

- (int32_t)int32ForKey:(id)key;

- (int64_t)int64ForKey:(id)key;

- (char)charForKey:(id)key;

- (short)shortForKey:(id)key;

- (float)floatForKey:(id)key;

- (double)doubleForKey:(id)key;

- (long long)longLongForKey:(id)key;

- (unsigned long long)unsignedLongLongForKey:(id)key;

- (NSDate *)dateForKey:(id)key dateFormat:(NSString *)dateFormat;

//CG
- (CGFloat)CGFloatForKey:(id)key;

- (CGPoint)pointForKey:(id)key;

- (CGSize)sizeForKey:(id)key;

- (CGRect)rectForKey:(id)key;

#pragma mark -
#pragma mark :. URL

/**
 *  @brief  将url参数转换成NSDictionary
 *
 *  @param query url参数
 *
 *  @return NSDictionary
 */
+ (NSDictionary *)dictionaryWithURLQuery:(NSString *)query;

/**
 *  @brief  将NSDictionary转换成url 参数字符串
 *
 *  @return url 参数字符串
 */
- (NSString *)URLQueryString;

#pragma mark -
#pragma mark :. XML

/**
 *  @brief  将NSDictionary转换成XML 字符串
 *
 *  @return XML 字符串
 */
- (NSString *)XMLString;

#pragma mark-
#pragma mark :. QueryDictionary

/**
 *  @return URL query string component created from the keys and values in
 *  the dictionary. Returns nil for an empty dictionary.
 *  @param sortedKeys Sorted the keys alphabetically?
 *  @see cavetas from the main `NSURL` category as well.
 */
- (NSString *)cc_URLQueryStringWithSortedKeys:(BOOL)sortedKeys;

/** As above, but `sortedKeys=NO` */
- (NSString *)cc_URLQueryString;

@end

#pragma-- mark NSMutableDictionary setter

@interface NSMutableDictionary (SafeAccess)

- (void)setObj:(id)i forKey:(NSString *)key;

- (void)setString:(NSString *)i forKey:(NSString *)key;

- (void)setBool:(BOOL)i forKey:(NSString *)key;

- (void)setInt:(int)i forKey:(NSString *)key;

- (void)setInteger:(NSInteger)i forKey:(NSString *)key;

- (void)setUnsignedInteger:(NSUInteger)i forKey:(NSString *)key;

- (void)setCGFloat:(CGFloat)f forKey:(NSString *)key;

- (void)setChar:(char)c forKey:(NSString *)key;

- (void)setFloat:(float)i forKey:(NSString *)key;

- (void)setDouble:(double)i forKey:(NSString *)key;

- (void)setLongLong:(long long)i forKey:(NSString *)key;

- (void)setPoint:(CGPoint)o forKey:(NSString *)key;

- (void)setSize:(CGSize)o forKey:(NSString *)key;

- (void)setRect:(CGRect)o forKey:(NSString *)key;

@end
