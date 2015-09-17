//
//  NSDate+BNSDate.h
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

@interface NSDate (BNSDate)

/**
 *  @author CC, 2015-07-21 18:07:04
 *
 *  @brief  时间转字符串
 *
 *  @param format 转换格式
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSString *)timeFormat:(NSString *)format;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  计算这个月有多少天
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSUInteger)numberOfDaysInCurrentMonth;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取这个月有多少周
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSUInteger)numberOfWeeksInCurrentMonth;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  计算这个月的第一天是礼拜几
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSUInteger)weeklyOrdinality;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  计算这个月最开始的一天
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSDate *)firstDayOfCurrentMonth;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取这个月有多少周
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSDate *)lastDayOfCurrentMonth;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取上一个月有多少周
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSDate *)dayInThePreviousMonth;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取下一个月有多少周
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSDate *)dayInTheFollowingMonth;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取当前日期之后的几个月
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSDate *)dayInTheFollowingMonth:(int)month;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取当前日期之后的几个天
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSDate *)dayInTheFollowingDay:(int)day;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取年月日对象
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSDateComponents *)YMDComponents;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  NSString转NSDate
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSDate *)dateFromString:(NSString *)dateString;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  NSDate转NSString
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSString *)stringFromDate:(NSDate *)date;

/**
 *  @author CC, 2015-06-10 15:06:13
 *
 *  @brief  时间转换字符串
 *
 *  @param Format <#Format description#>
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSString *)toStringFormat:(NSString *)Format;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  两个日历之间相差多少月
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
+ (NSInteger)dayNumbertoDay:(NSDate *)today beforDay:(NSDate *)beforday;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  周日是“1”，周一是“2”...
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSInteger)weekIntValueWithDate;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  判断日期是今天,明天,后天,周几
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSString *)compareIfTodayWithDate;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  通过数字返回星期几
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
+ (NSString *)getWeekStringFromInteger:(int)week;

/**
 *  @author CC, 2015-07-23 10:07:35
 *
 *  @brief  前一天
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSDate *)theDayBefore;

/**
 *  @author CC, 2015-07-23 10:07:26
 *
 *  @brief  后一天
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSDate *)afterADay;

/**
 *  @author CC, 15-09-15
 *
 *  @brief  时间转换
 *          今天 昨天 星期 年月日时分
 *
 *  @return 格式化字符串
 *
 *  @since 1.0
 */
- (NSString *)convertingDataFormat;

@end
