//
//  NSDate+BNSDate.m
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

#import "NSDate+BNSDate.h"

@implementation NSDate (BNSDate)

/**
 *  @author CC, 2015-07-21
 *
 *  @brief  时间转字符串
 *
 *  @param format 转换格式
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSString *)timeFormat:(NSString *)format
{
    NSDateFormatter *mDateFormatter = [[NSDateFormatter alloc] init];
    [mDateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [mDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [mDateFormatter setDateFormat:format];
    return [mDateFormatter stringFromDate:self];
}

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  计算这个月有多少天
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSUInteger)numberOfDaysInCurrentMonth
{
    // 频繁调用 [NSCalendar currentCalendar] 可能存在性能问题
    return [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit
                                              inUnit:NSMonthCalendarUnit
                                             forDate:self].length;
}

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取这个月有多少周
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSUInteger)numberOfWeeksInCurrentMonth
{
    NSUInteger weekday = [[self firstDayOfCurrentMonth] weeklyOrdinality];
    NSUInteger days = [self numberOfDaysInCurrentMonth];
    NSUInteger weeks = 0;
    
    if (weekday > 1) weeks += 1, days -= (7 - weekday + 1);
    
    weeks += days / 7;
    weeks += (days % 7 > 0) ? 1 : 0;
    
    return weeks;
}

/*计算这个月的第一天是礼拜几*/
/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取这个月有多少周
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSUInteger)weeklyOrdinality
{
    return [[NSCalendar currentCalendar] ordinalityOfUnit:NSDayCalendarUnit
                                                   inUnit:NSWeekCalendarUnit
                                                  forDate:self];
}

//计算这个月最开始的一天
/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取这个月有多少周
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSDate *)firstDayOfCurrentMonth
{
    NSDate *startDate = nil;
    [[NSCalendar currentCalendar] rangeOfUnit:NSMonthCalendarUnit
                                    startDate:&startDate
                                     interval:NULL
                                      forDate:self];
    return startDate;
}

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取这个月有多少周
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSDate *)lastDayOfCurrentMonth
{
    NSCalendarUnit calendarUnit =
    NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *dateComponents =
    [[NSCalendar currentCalendar] components:calendarUnit fromDate:self];
    dateComponents.day = [self numberOfDaysInCurrentMonth];
    return [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
}

//上一个月
/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取这个月有多少周
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSDate *)dayInThePreviousMonth
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = -1;
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents
                                                         toDate:self
                                                        options:0];
}

//下一个月
/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取这个月有多少周
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSDate *)dayInTheFollowingMonth
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = 1;
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents
                                                         toDate:self
                                                        options:0];
}

//获取当前日期之后的几个月
/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取这个月有多少周
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSDate *)dayInTheFollowingMonth:(int)month
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = month;
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents
                                                         toDate:self
                                                        options:0];
}

//获取当前日期之后的几个天
/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取这个月有多少周
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSDate *)dayInTheFollowingDay:(int)day
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.day = day; //当前延后多少天
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date = [calendar dateByAddingComponents:dateComponents
                                             toDate:self
                                            options:0]; // 延后天数的日期
    
    NSInteger Days = [calendar rangeOfUnit:NSDayCalendarUnit
                                    inUnit:NSMonthCalendarUnit
                                   forDate:date].length; // 延后的那个月天数
    Days -= [[date timeFormat:@"dd"] integerValue];      //当月天数 - 当日
    dateComponents.day = day + Days;			 // 延后天数 + 当月余下天数
    
    return
    [calendar dateByAddingComponents:dateComponents toDate:self options:0];
}

//获取年月日对象
/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取这个月有多少周
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSDateComponents *)YMDComponents
{
    return [[NSCalendar currentCalendar]
            components:NSYearCalendarUnit | NSMonthCalendarUnit |
            NSDayCalendarUnit | NSWeekdayCalendarUnit
            fromDate:self];
}

// NSString转NSDate
/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取这个月有多少周
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSDate *)dateFromString:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return [dateFormatter dateFromString:dateString];
}

// NSDate转NSString
/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取这个月有多少周
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return [dateFormatter stringFromDate:date];
}

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
- (NSString *)toStringFormat:(NSString *)Format
{
    NSDateFormatter *mDateFormatter = [[NSDateFormatter alloc] init];
    [mDateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [mDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [mDateFormatter setDateFormat:Format];
    return [mDateFormatter stringFromDate:self];
}

/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取这个月有多少周
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
+ (NSInteger)dayNumbertoDay:(NSDate *)today beforDay:(NSDate *)beforday
{
    NSCalendar *calendar = [[NSCalendar alloc]
                            initWithCalendarIdentifier:NSGregorianCalendar]; //日历控件对象
    NSDateComponents *components = [calendar components:NSDayCalendarUnit
                                               fromDate:today
                                                 toDate:beforday
                                                options:0];
    return [components day]; //两个日历之间相差多少月//    NSInteger days =
    //[components day];//两个之间相差几天
}


//周日是“1”，周一是“2”...
/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取这个月有多少周
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSInteger)weekIntValueWithDate
{
    NSCalendar *calendar =
    [[NSCalendar alloc] initWithCalendarIdentifier:NSChineseCalendar];
    NSDateComponents *comps =
    [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit |
                          NSDayCalendarUnit | NSWeekdayCalendarUnit)
                fromDate:self];
    return [comps weekday];
}

//判断日期是今天,明天,后天,周几
/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取这个月有多少周
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSString *)compareIfTodayWithDate
{
    NSDate *todate = [NSDate date]; //今天
    NSCalendar *calendar =
    [[NSCalendar alloc] initWithCalendarIdentifier:NSChineseCalendar];
    NSDateComponents *comps_today =
    [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit |
                          NSDayCalendarUnit | NSWeekdayCalendarUnit)
                fromDate:todate];
    NSDateComponents *comps_other =
    [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit |
                          NSDayCalendarUnit | NSWeekdayCalendarUnit)
                fromDate:self];
    
    //获取星期对应的数字
    NSInteger weekIntValue = [self weekIntValueWithDate];
    
    if (comps_today.year == comps_other.year &&
        comps_today.month == comps_other.month &&
        comps_today.day == comps_other.day)
        return @"今天";
    else if (comps_today.year == comps_other.year &&
             comps_today.month == comps_other.month &&
             (comps_today.day - comps_other.day) == -1)
        return @"明天";
    else if (comps_today.year == comps_other.year &&
             comps_today.month == comps_other.month &&
             (comps_today.day - comps_other.day) == -2)
        return @"后天";
    else
        return [NSDate getWeekStringFromInteger:(int)weekIntValue]; //周几
}

//通过数字返回星期几
/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取这个月有多少周
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
+ (NSString *)getWeekStringFromInteger:(int)week
{
    NSArray *weekArray =
    @[ @"周日",
       @"周一",
       @"周二",
       @"周三",
       @"周四",
       @"周五",
       @"周六" ];
    return [weekArray objectAtIndex:week];
}

/**
 *  @author CC, 2015-07-23 10:07:35
 *
 *  @brief  前一天
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSDate *)theDayBefore
{
    return [NSDate dateWithTimeInterval:-60 * 60 * 24 + 60 * 10 sinceDate:self];
}

/**
 *  @author CC, 2015-07-23 10:07:26
 *
 *  @brief  后一天
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSDate *)afterADay
{
    return [NSDate dateWithTimeInterval:60 * 60 * 24 + 60 * 10 sinceDate:self];
}

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
- (NSString *)convertingDataFormat
{
    NSDate *todate = [NSDate date]; //今天
    NSCalendar *calendar =
    [[NSCalendar alloc] initWithCalendarIdentifier:NSChineseCalendar];
    NSDateComponents *comps_today =
    [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit |
                          NSDayCalendarUnit | NSWeekdayCalendarUnit)
                fromDate:todate];
    NSDateComponents *comps_other =
    [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit |
                          NSDayCalendarUnit | NSWeekdayCalendarUnit)
                fromDate:self];
    
    NSString *strDate;
    NSInteger weekIntValue =
    [self weekIntValueWithDate] - 1; //获取星期对应的数字
    NSInteger days = comps_today.day - comps_other.day;
    
    if (comps_today.year == comps_other.year && comps_today.month == comps_other.month && comps_today.day == comps_other.day)
        strDate = [NSString stringWithFormat:@"今天 %@", [self timeFormat:@"HH:mm"]];
    else if (comps_today.year == comps_other.year && comps_today.month == comps_other.month && days == 1)
        strDate = [NSString stringWithFormat:@"昨天 %@", [self timeFormat:@"HH:mm"]];
    else if (comps_today.year == comps_other.year && comps_today.month == comps_other.month && days < 7)
        strDate = [NSString stringWithFormat:@"%@ %@", [NSDate getWeekStringFromInteger:(int)weekIntValue], [self timeFormat:@"HH:mm"]];
    else
        strDate = [self timeFormat:@"yyyy年MM月dd HH:mm"];
    
    return strDate;
}

/**
 *  @author CC, 2015-11-04
 *  
 *  @brief  比较时间相隔
 *
 *  @param timestamp 时间
 *
 *  @return 返回相隔时间
 */
- (NSDictionary *)comparativeApart:(NSDate *)timestamp
{
    double intervalTime = [self timeIntervalSinceReferenceDate] - [timestamp timeIntervalSinceReferenceDate];
    
    long lTime = (long)intervalTime;
    NSInteger iSeconds = lTime % 60;
    NSInteger iMinutes = (lTime / 60) % 60;
    NSInteger iHours = (lTime / 3600);
    NSInteger iDays = lTime / 60 / 60 / 24;
    NSInteger iMonth = lTime / 60 / 60 / 24 / 12;
    NSInteger iYears = lTime /60 / 60 / 24 / 384;
    
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@(iYears) forKey:@"years"];
    [dic setObject:@(iMonth) forKey:@"month"];
    [dic setObject:@(iDays) forKey:@"days"];
    [dic setObject:@(iHours) forKey:@"hours"];
    [dic setObject:@(iMinutes) forKey:@"minutes"];
    [dic setObject:@(iSeconds) forKey:@"seconds"];
    
    return dic;
    
}

@end
