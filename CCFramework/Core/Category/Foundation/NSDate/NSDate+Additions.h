//
//  NSDate+Additions.h
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

@interface NSDate (Additions)

/**
 *  @author CC, 2015-07-21
 *
 *  @brief  时间转字符串
 *
 *  @param format 转换格式
 */
- (NSString *)timeFormat:(NSString *)format;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  计算这个月有多少天
 */
- (NSUInteger)numberOfDaysInCurrentMonth;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取这个月有多少周
 */
- (NSUInteger)numberOfWeeksInCurrentMonth;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  计算这个月的第一天是礼拜几
 */
- (NSUInteger)weeklyOrdinality;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  计算这个月最开始的一天
 */
- (NSDate *)firstDayOfCurrentMonth;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取这个月有多少周
 */
- (NSDate *)lastDayOfCurrentMonth;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取上一个月有多少周
 */
- (NSDate *)dayInThePreviousMonth;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取下一个月有多少周
 */
- (NSDate *)dayInTheFollowingMonth;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取当前日期之后的几个月
 */
- (NSDate *)dayInTheFollowingMonth:(int)month;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取当前日期之后的几个天
 */
- (NSDate *)dayInTheFollowingDay:(int)day;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取年月日对象
 */
- (NSDateComponents *)YMDComponents;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  NSString转NSDate
 */
- (NSDate *)dateFromString:(NSString *)dateString;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  NSDate转NSString
 */
- (NSString *)stringFromDate:(NSDate *)date;

/**
 *  @author CC, 2015-06-10 15:06:13
 *
 *  @brief  时间转换字符串
 *
 *  @param Format 格式
 */
- (NSString *)toStringFormat:(NSString *)Format;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  两个日历之间相差多少月
 */
+ (NSInteger)dayNumbertoDay:(NSDate *)today beforDay:(NSDate *)beforday;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  周日是“1”，周一是“2”...
 */
- (NSInteger)weekIntValueWithDate;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  判断日期是今天,明天,后天,周几
 */
- (NSString *)compareIfTodayWithDate;

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  通过数字返回星期几
 */
+ (NSString *)getWeekStringFromInteger:(int)week;

/**
 *  @author CC, 2015-07-23 10:07:35
 *
 *  @brief  前一天
 */
- (NSDate *)theDayBefore;

/**
 *  @author CC, 2015-07-23 10:07:26
 *
 *  @brief  后一天
 */
- (NSDate *)afterADay;

/**
 *  @author C C, 2016-09-29
 *  
 *  @brief  转换时间格式（微信样式）
 */
- (NSString *)convertDateFormat;

/**
 *  @author CC, 15-09-15
 *
 *  @brief  时间转换
 *          今天 昨天 星期 年月日时分
 */
- (NSString *)convertingDataFormat;

/**
 *  @author CC, 16-04-19
 *  
 *  @brief 比较时间并转换时间格式
 *         多少(秒or分or时or今天or明天or星期or年月日时分)+前 (比如，刚刚、10分钟前)
 */
- (NSString *)comparcCurrentTimeAndConvertingDataFormat;

/**
 *  @author CC, 2015-11-04
 *  
 *  @brief  比较时间相隔
 *
 *  @param timestamp 时间
 */
- (NSDictionary *)comparativeApart:(NSDate *)timestamp;

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 开始日
 */
- (NSDate *)beginningOfDay;

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 结束日
 */
- (NSDate *)endOfDay;

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 开始星期
 */
- (NSDate *)beginningOfWeek;

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 结束星期
 */
- (NSDate *)endOfWeek;

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 开始月份
 */
- (NSDate *)beginningOfMonth;

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 结束月份
 */
- (NSDate *)endOfMonth;

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 开始年份
 */
- (NSDate *)beginningOfYear;

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 结束年份
 */
- (NSDate *)endOfYear;

/**
 * 获取日、月、年、小时、分钟、秒
 */
- (NSUInteger)day;
- (NSUInteger)month;
- (NSUInteger)year;
- (NSUInteger)hour;
- (NSUInteger)minute;
- (NSUInteger)second;
+ (NSUInteger)day:(NSDate *)date;
+ (NSUInteger)month:(NSDate *)date;
+ (NSUInteger)year:(NSDate *)date;
+ (NSUInteger)hour:(NSDate *)date;
+ (NSUInteger)minute:(NSDate *)date;
+ (NSUInteger)second:(NSDate *)date;

/**
 * 获取一年中的总天数
 */
- (NSUInteger)daysInYear;
+ (NSUInteger)daysInYear:(NSDate *)date;

/**
 * 判断是否是润年
 * @return YES表示润年，NO表示平年
 */
- (BOOL)isLeapYear;
+ (BOOL)isLeapYear:(NSDate *)date;

/**
 * 获取该日期是该年的第几周
 */
- (NSUInteger)weekOfYear;
+ (NSUInteger)weekOfYear:(NSDate *)date;

/**
 * 获取格式化为YYYY-MM-dd格式的日期字符串
 */
- (NSString *)formatYMD;
+ (NSString *)formatYMD:(NSDate *)date;

/**
 * 返回当前月一共有几周(可能为4,5,6)
 */
- (NSUInteger)weeksOfMonth;
+ (NSUInteger)weeksOfMonth:(NSDate *)date;

/**
 * 获取该月的第一天的日期
 */
- (NSDate *)begindayOfMonth;
+ (NSDate *)begindayOfMonth:(NSDate *)date;

/**
 * 获取该月的最后一天的日期
 */
- (NSDate *)lastdayOfMonth;
+ (NSDate *)lastdayOfMonth:(NSDate *)date;

/**
 * 返回day天后的日期(若day为负数,则为|day|天前的日期)
 */
- (NSDate *)dateAfterDay:(NSUInteger)day;
+ (NSDate *)dateAfterDate:(NSDate *)date day:(NSInteger)day;

/**
 * 返回day天后的日期(若day为负数,则为|day|天前的日期)
 */
- (NSDate *)dateAfterMonth:(NSUInteger)month;
+ (NSDate *)dateAfterDate:(NSDate *)date month:(NSInteger)month;

/**
 * 返回numYears年后的日期
 */
- (NSDate *)offsetYears:(int)numYears;
+ (NSDate *)offsetYears:(int)numYears fromDate:(NSDate *)fromDate;

/**
 * 返回numMonths月后的日期
 */
- (NSDate *)offsetMonths:(int)numMonths;
+ (NSDate *)offsetMonths:(int)numMonths fromDate:(NSDate *)fromDate;

/**
 * 返回numDays天后的日期
 */
- (NSDate *)offsetDays:(int)numDays;
+ (NSDate *)offsetDays:(int)numDays fromDate:(NSDate *)fromDate;

/**
 * 返回numHours小时后的日期
 */
- (NSDate *)offsetHours:(int)hours;
+ (NSDate *)offsetHours:(int)numHours fromDate:(NSDate *)fromDate;

/**
 * 距离该日期前几天
 */
- (NSUInteger)daysAgo;
+ (NSUInteger)daysAgo:(NSDate *)date;

/**
 *  获取星期几
 *
 *  @return Return weekday number
 *  [1 - Sunday]
 *  [2 - Monday]
 *  [3 - Tuerday]
 *  [4 - Wednesday]
 *  [5 - Thursday]
 *  [6 - Friday]
 *  [7 - Saturday]
 */
- (NSInteger)weekday;
+ (NSInteger)weekday:(NSDate *)date;

/**
 *  获取星期几(名称)
 *
 *  @return Return weekday as a localized string
 *  [1 - Sunday]
 *  [2 - Monday]
 *  [3 - Tuerday]
 *  [4 - Wednesday]
 *  [5 - Thursday]
 *  [6 - Friday]
 *  [7 - Saturday]
 */
- (NSString *)dayFromWeekday;
+ (NSString *)dayFromWeekday:(NSDate *)date;

/**
 *  日期是否相等
 *
 *  @param anotherDate The another date to compare as NSDate
 *  @return Return YES if is same day, NO if not
 */
- (BOOL)isSameDay:(NSDate *)anotherDate;

/**
 *  是否是今天
 *
 *  @return Return if self is today
 */
- (BOOL)isToday;

/**
 *  Add days to self
 *
 *  @param days The number of days to add
 *  @return Return self by adding the gived days number
 */
- (NSDate *)dateByAddingDays:(NSUInteger)days;

/**
 *  Get the month as a localized string from the given month number
 *
 *  @param month The month to be converted in string
 *  [1 - January]
 *  [2 - February]
 *  [3 - March]
 *  [4 - April]
 *  [5 - May]
 *  [6 - June]
 *  [7 - July]
 *  [8 - August]
 *  [9 - September]
 *  [10 - October]
 *  [11 - November]
 *  [12 - December]
 *
 *  @return Return the given month as a localized string
 */
+ (NSString *)monthWithMonthNumber:(NSInteger)month;

/**
 * 根据日期返回字符串
 */
+ (NSString *)stringWithDate:(NSDate *)date format:(NSString *)format;
- (NSString *)stringWithFormat:(NSString *)format;
+ (NSDate *)dateWithString:(NSString *)string format:(NSString *)format;

/**
 * 获取指定月份的天数
 */
- (NSUInteger)daysInMonth:(NSUInteger)month;
+ (NSUInteger)daysInMonth:(NSDate *)date month:(NSUInteger)month;

/**
 * 获取当前月份的天数
 */
- (NSUInteger)daysInMonth;
+ (NSUInteger)daysInMonth:(NSDate *)date;

/**
 * 返回x分钟前/x小时前/昨天/x天前/x个月前/x年前
 */
- (NSString *)timeInfo;
+ (NSString *)timeInfoWithDate:(NSDate *)date;
+ (NSString *)timeInfoWithDateString:(NSString *)dateString;

/**
 * 分别获取yyyy-MM-dd/HH:mm:ss/yyyy-MM-dd HH:mm:ss格式的字符串
 */
- (NSString *)ymdFormat;
- (NSString *)hmsFormat;
- (NSString *)ymdHmsFormat;
+ (NSString *)ymdFormat;
+ (NSString *)hmsFormat;

/**
 *  @author CC, 16-05-25
 *  
 *  @brief  时间戳转换
 *
 *  @param timeInterval 时间戳
 */
+ (NSDate *)timestampConversion:(NSTimeInterval)timeInterval;

/**
 *  @author C C, 2016-10-06
 *  
 *  @brief  时间转13位时间戳
 */
- (NSTimeInterval)dataConversionTimestamp;

#pragma mark -
#pragma mark :. Formatter

+ (NSDateFormatter *)formatter;
+ (NSDateFormatter *)formatterWithoutTime;
+ (NSDateFormatter *)formatterWithoutDate;

- (NSString *)formatWithUTCTimeZone;
- (NSString *)formatWithLocalTimeZone;
- (NSString *)formatWithTimeZoneOffset:(NSTimeInterval)offset;
- (NSString *)formatWithTimeZone:(NSTimeZone *)timezone;

- (NSString *)formatWithUTCTimeZoneWithoutTime;
- (NSString *)formatWithLocalTimeZoneWithoutTime;
- (NSString *)formatWithTimeZoneOffsetWithoutTime:(NSTimeInterval)offset;
- (NSString *)formatWithTimeZoneWithoutTime:(NSTimeZone *)timezone;

- (NSString *)formatWithUTCWithoutDate;
- (NSString *)formatWithLocalTimeWithoutDate;
- (NSString *)formatWithTimeZoneOffsetWithoutDate:(NSTimeInterval)offset;
- (NSString *)formatTimeWithTimeZone:(NSTimeZone *)timezone;


+ (NSString *)currentDateStringWithFormat:(NSString *)format;
+ (NSDate *)dateWithSecondsFromNow:(NSInteger)seconds;
- (NSString *)dateWithFormat:(NSString *)format;

#pragma mark -
#pragma mark :. InternetDateTime

typedef enum {
    DateFormatHintNone,
    DateFormatHintRFC822,
    DateFormatHintRFC3339
} DateFormatHint;

// Get date from RFC3339 or RFC822 string
// - A format/specification hint can be used to speed up,
//   otherwise both will be attempted in order to get a date
+ (NSDate *)dateFromInternetDateTimeString:(NSString *)dateString
                                formatHint:(DateFormatHint)hint;

// Get date from a string using a specific date specification
+ (NSDate *)dateFromRFC3339String:(NSString *)dateString;
+ (NSDate *)dateFromRFC822String:(NSString *)dateString;

#pragma mark -
#pragma mark :. Reporting

// Return a date with a specified year, month and day.
+ (NSDate *)dateWithYear:(NSInteger)year Month:(NSInteger)month Day:(NSInteger)day;

// Return midnight on the specified date.
+ (NSDate *)midnightOfDate:(NSDate *)date;

// Return midnight today.
+ (NSDate *)midnightToday;

// Return midnight tomorrow.
+ (NSDate *)midnightTomorrow;

// Returns a date that is exactly 1 day after the specified date. Does *not*
// zero out the time components. For example, if the specified date is
// April 15 2012 10:00 AM, the return value will be April 16 2012 10:00 AM.
+ (NSDate *)oneDayAfter:(NSDate *)date;

// Returns midnight of the first day of the current, previous or next Month.
// Note: firstDayOfNextMonth returns midnight of the first day of next month,
// which is effectively the same as the "last moment" of the current month.
+ (NSDate *)firstDayOfCurrentMonth;
+ (NSDate *)firstDayOfPreviousMonth;
+ (NSDate *)firstDayOfNextMonth;

// Returns midnight of the first day of the current, previous or next Quarter.
// Note: firstDayOfNextQuarter returns midnight of the first day of next quarter,
// which is effectively the same as the "last moment" of the current quarter.
+ (NSDate *)firstDayOfCurrentQuarter;
+ (NSDate *)firstDayOfPreviousQuarter;
+ (NSDate *)firstDayOfNextQuarter;

// Returns midnight of the first day of the current, previous or next Year.
// Note: firstDayOfNextYear returns midnight of the first day of next year,
// which is effectively the same as the "last moment" of the current year.
+ (NSDate *)firstDayOfCurrentYear;
+ (NSDate *)firstDayOfPreviousYear;
+ (NSDate *)firstDayOfNextYear;


- (NSDate *)dateFloor;
- (NSDate *)dateCeil;

- (NSDate *)previousDay;
- (NSDate *)nextDay;

- (NSDate *)previousWeek;
- (NSDate *)nextWeek;

- (NSDate *)previousMonth;
- (NSDate *)previousMonth:(NSUInteger)monthsToMove;
- (NSDate *)nextMonth;
- (NSDate *)nextMonth:(NSUInteger)monthsToMove;

#ifdef DEBUG
// For testing only. A helper function to format and display a date
// with an optional comment. For example:
//     NSDate *test = [NSDate firstDayOfCurrentMonth];
//     [test logWithComment:@"First day of current month: "];
- (void)logWithComment:(NSString *)comment;
#endif


#pragma mark -
#pragma mark :. Utilities

+ (NSCalendar *)currentCalendar; // avoid bottlenecks

// Relative dates from the current date
+ (NSDate *)dateTomorrow;
+ (NSDate *)dateYesterday;
+ (NSDate *)dateWithDaysFromNow:(NSInteger)days;
+ (NSDate *)dateWithDaysBeforeNow:(NSInteger)days;
+ (NSDate *)dateWithHoursFromNow:(NSInteger)dHours;
+ (NSDate *)dateWithHoursBeforeNow:(NSInteger)dHours;
+ (NSDate *)dateWithMinutesFromNow:(NSInteger)dMinutes;
+ (NSDate *)dateWithMinutesBeforeNow:(NSInteger)dMinutes;

// Short string utilities
- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;

@property(nonatomic, readonly) NSString *shortString;
@property(nonatomic, readonly) NSString *shortDateString;
@property(nonatomic, readonly) NSString *shortTimeString;
@property(nonatomic, readonly) NSString *mediumString;
@property(nonatomic, readonly) NSString *mediumDateString;
@property(nonatomic, readonly) NSString *mediumTimeString;
@property(nonatomic, readonly) NSString *longString;
@property(nonatomic, readonly) NSString *longDateString;
@property(nonatomic, readonly) NSString *longTimeString;


// Comparing dates
- (BOOL)isEqualToDateIgnoringTime:(NSDate *)aDate;

- (BOOL)isTomorrow;
- (BOOL)isYesterday;

- (BOOL)isSameWeekAsDate:(NSDate *)aDate;
- (BOOL)isThisWeek;
- (BOOL)isNextWeek;
- (BOOL)isLastWeek;

- (BOOL)isSameMonthAsDate:(NSDate *)aDate;
- (BOOL)isThisMonth;
- (BOOL)isNextMonth;
- (BOOL)isLastMonth;

- (BOOL)isSameYearAsDate:(NSDate *)aDate;
- (BOOL)isThisYear;
- (BOOL)isNextYear;
- (BOOL)isLastYear;

- (BOOL)isEarlierThanDate:(NSDate *)aDate;
- (BOOL)isLaterThanDate:(NSDate *)aDate;

- (BOOL)isInFuture;
- (BOOL)isInPast;

// Date roles
- (BOOL)isTypicallyWorkday;
- (BOOL)isTypicallyWeekend;

// Adjusting dates
- (NSDate *)dateByAddingYears:(NSInteger)dYears;
- (NSDate *)dateBySubtractingYears:(NSInteger)dYears;
- (NSDate *)dateByAddingMonths:(NSInteger)dMonths;
- (NSDate *)dateBySubtractingMonths:(NSInteger)dMonths;
- (NSDate *)dateBySubtractingDays:(NSInteger)dDays;
- (NSDate *)dateByAddingHours:(NSInteger)dHours;
- (NSDate *)dateBySubtractingHours:(NSInteger)dHours;
- (NSDate *)dateByAddingMinutes:(NSInteger)dMinutes;
- (NSDate *)dateBySubtractingMinutes:(NSInteger)dMinutes;

// Date extremes
- (NSDate *)dateAtStartOfDay;
- (NSDate *)dateAtEndOfDay;

// Retrieving intervals
- (NSInteger)minutesAfterDate:(NSDate *)aDate;
- (NSInteger)minutesBeforeDate:(NSDate *)aDate;
- (NSInteger)hoursAfterDate:(NSDate *)aDate;
- (NSInteger)hoursBeforeDate:(NSDate *)aDate;
- (NSInteger)daysAfterDate:(NSDate *)aDate;
- (NSInteger)daysBeforeDate:(NSDate *)aDate;
- (NSInteger)distanceInDaysToDate:(NSDate *)anotherDate;

// Decomposing dates
@property(readonly) NSInteger nearestHour;
@property(readonly) NSInteger seconds;
@property(readonly) NSInteger week;
@property(readonly) NSInteger weekday;
@property(readonly) NSInteger nthWeekday; // e.g. 2nd Tuesday of the month == 2



@end
