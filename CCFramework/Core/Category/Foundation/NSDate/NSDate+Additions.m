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

#import "NSDate+Additions.h"

@implementation NSDate (Additions)

/**
 *  @author CC, 16-05-25
 *
 *  @brief  时间戳转换
 *
 *  @param timeInterval 时间戳
 */
+ (NSDate *)timestampConversion:(NSTimeInterval)timeInterval
{
    double timestampval = timeInterval;
    if ([NSString stringWithFormat:@"%.0f", timeInterval].length == 13)
        timestampval /= 1000;
    return [NSDate dateWithTimeIntervalSince1970:timestampval];
}

/**
 *  @author C C, 2016-10-06
 *  
 *  @brief  时间转13位时间戳
 */
-(NSTimeInterval)dataConversionTimestamp
{
    NSTimeInterval timestamp = [self timeIntervalSince1970] * 1000;
    return ceil(timestamp);
}

/**
 *  @author CC, 2015-07-21
 *
 *  @brief  时间转字符串
 *
 *  @param format 转换格式
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
    dateComponents.day = day + Days;		      // 延后天数 + 当月余下天数

    return
    [calendar dateByAddingComponents:dateComponents toDate:self options:0];
}

//获取年月日对象
/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取这个月有多少周
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
 */
- (NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return [dateFormatter stringFromDate:date];
}

/**
 *  @author CC, 2015-06-10
 *
 *  @brief  时间转换字符串
 *
 *  @param Format 格式
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
 */
+ (NSInteger)dayNumbertoDay:(NSDate *)today beforDay:(NSDate *)beforday
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]; //日历控件对象
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
 */
- (NSInteger)weekIntValueWithDate
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSChineseCalendar];
    NSDateComponents *comps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit)
                                          fromDate:self];
    return [comps weekday];
}

//判断日期是今天,明天,后天,周几
/**
 *  @author CC, 2015-07-17
 *
 *  @brief  获取这个月有多少周
 */
- (NSString *)compareIfTodayWithDate
{
    NSDate *todate = [NSDate date]; //今天
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSChineseCalendar];
    NSDateComponents *comps_today = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit)
                                                fromDate:todate];
    NSDateComponents *comps_other = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit)
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
 */
+ (NSString *)getWeekStringFromInteger:(int)week
{
    NSArray *weekArray = @[ @"周日",
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
 */
- (NSDate *)theDayBefore
{
    return [NSDate dateWithTimeInterval:-60 * 60 * 24 + 60 * 10 sinceDate:self];
}

/**
 *  @author CC, 2015-07-23 10:07:26
 *
 *  @brief  后一天
 */
- (NSDate *)afterADay
{
    return [NSDate dateWithTimeInterval:60 * 60 * 24 + 60 * 10 sinceDate:self];
}

/**
 *  @author C C, 2016-09-29
 *  
 *  @brief  转换时间格式（微信样式）
 */
-(NSString *)convertDateFormat
{
    NSDate *currentDate = [NSDate date];
    
    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    NSDateComponents *currentComps = [currentCalendar components:unitFlags fromDate:currentDate];
    NSDateComponents *otherComps = [currentCalendar components:unitFlags fromDate:self];
    
    NSString *strDate;
    NSInteger weekIntValue = [self weekIntValueWithDate] - 1; //获取星期对应的数字
    NSInteger days = currentComps.day - otherComps.day;
    
    if (currentComps.year == otherComps.year && currentComps.month == otherComps.month && currentComps.day == otherComps.day)
        strDate = [self timeFormat:@"HH:mm"];
    else if (currentComps.year == otherComps.year && currentComps.month == otherComps.month && days == 1)
        strDate = @"昨天";
    else if (currentComps.year == otherComps.year && currentComps.month == otherComps.month && days < 7)
        strDate = [NSDate getWeekStringFromInteger:(int)weekIntValue];
    else if (currentComps.year == otherComps.year)
        strDate = [self timeFormat:@"yyyy/MM/dd"];
    else
        strDate = [self timeFormat:@"yyyy/MM/dd HH:mm"];
    
    return strDate;
}

/**
 *  @author CC, 15-09-15
 *
 *  @brief  时间转换
 *          今天 昨天 星期 年月日时分
 */
- (NSString *)convertingDataFormat
{
    NSDate *currentDate = [NSDate date];

    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;

    NSDateComponents *currentComps = [currentCalendar components:unitFlags fromDate:currentDate];
    NSDateComponents *otherComps = [currentCalendar components:unitFlags fromDate:self];

    NSString *strDate;
    NSInteger weekIntValue = [self weekIntValueWithDate] - 1; //获取星期对应的数字
    NSInteger days = currentComps.day - otherComps.day;

    if (currentComps.year == otherComps.year && currentComps.month == otherComps.month && currentComps.day == otherComps.day)
        strDate = [NSString stringWithFormat:@"今天 %@", [self timeFormat:@"HH:mm"]];
    else if (currentComps.year == otherComps.year && currentComps.month == otherComps.month && days == 1)
        strDate = [NSString stringWithFormat:@"昨天 %@", [self timeFormat:@"HH:mm"]];
    else if (currentComps.year == otherComps.year && currentComps.month == otherComps.month && days < 7)
        strDate = [NSString stringWithFormat:@"%@ %@", [NSDate getWeekStringFromInteger:(int)weekIntValue], [self timeFormat:@"HH:mm"]];
    else if (currentComps.year == otherComps.year)
        strDate = [self timeFormat:@"MM月dd日"];
    else
        strDate = [self timeFormat:@"yyyy年MM月dd HH:mm"];

    return strDate;
}

/**
 *  @author CC, 16-04-19
 *
 *  @brief 比较时间并转换时间格式
 *         多少(秒or分or时or今天or明天or星期or年月日时分)+前 (比如，刚刚、10分钟前)
 */
- (NSString *)comparcCurrentTimeAndConvertingDataFormat
{
    NSDate *currentDate = [NSDate date];

    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;

    NSDateComponents *currentComps = [currentCalendar components:unitFlags fromDate:currentDate];
    NSDateComponents *otherComps = [currentCalendar components:unitFlags fromDate:self];

    NSString *strDate;
    NSInteger weekIntValue = [self weekIntValueWithDate] - 1; //获取星期对应的数字
    NSInteger days = currentComps.day - otherComps.day;

    if (currentComps.year == otherComps.year && currentComps.month == otherComps.month && currentComps.day == otherComps.day && currentComps.hour == otherComps.hour && currentComps.minute == otherComps.minute && otherComps.second < 60) {
        strDate = @"刚刚";
    } else if (currentComps.year == otherComps.year && currentComps.month == otherComps.month && currentComps.day == otherComps.day && currentComps.hour == otherComps.hour && otherComps.minute < 60) {
        strDate = [NSString stringWithFormat:@"%zi 分钟前", currentComps.minute - otherComps.minute];
    } else if (currentComps.year == otherComps.year && currentComps.month == otherComps.month && currentComps.day == otherComps.day && otherComps.hour < 24) {
        NSInteger hour = currentComps.hour - otherComps.hour;

        double time = [currentDate timeIntervalSinceReferenceDate] - [self timeIntervalSinceReferenceDate];
        if (time < 3600) {
            NSInteger retTime = 1.0;
            retTime = time / 60;
            retTime = retTime <= 0.0 ? 1.0 : retTime;
            strDate = [NSString stringWithFormat:@"%zi 分钟前",retTime];
        } else {
            strDate = [NSString stringWithFormat:@"%zi 小时前", hour];
        }

        if (hour > 3) {
            strDate = [NSString stringWithFormat:@"今天 %@", [self timeFormat:@"HH:mm"]];
        }
    } else if (currentComps.year == otherComps.year && currentComps.month == otherComps.month && currentComps.day == otherComps.day)
        strDate = [NSString stringWithFormat:@"今天 %@", [self timeFormat:@"HH:mm"]];
    else if (currentComps.year == otherComps.year && currentComps.month == otherComps.month && days == 1)
        strDate = [NSString stringWithFormat:@"昨天 %@", [self timeFormat:@"HH:mm"]];
    else if (currentComps.year == otherComps.year && currentComps.month == otherComps.month && days < 7)
        strDate = [NSString stringWithFormat:@"%@ %@", [NSDate getWeekStringFromInteger:(int)weekIntValue], [self timeFormat:@"HH:mm"]];
    else if (currentComps.year == otherComps.year)
        strDate = [self timeFormat:@"MM月dd日"];
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
    NSInteger iYears = lTime / 60 / 60 / 24 / 384;


    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@(iYears) forKey:@"years"];
    [dic setObject:@(iMonth) forKey:@"month"];
    [dic setObject:@(iDays) forKey:@"days"];
    [dic setObject:@(iHours) forKey:@"hours"];
    [dic setObject:@(iMinutes) forKey:@"minutes"];
    [dic setObject:@(iSeconds) forKey:@"seconds"];

    return dic;
}

- (NSDate *)beginningOfDay
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:self];

    return [calendar dateFromComponents:components];
}

- (NSDate *)endOfDay
{
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:1];

    return [[calendar dateByAddingComponents:components toDate:[self beginningOfDay] options:0] dateByAddingTimeInterval:-1];
}

- (NSDate *)beginningOfWeek
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit | NSDayCalendarUnit fromDate:self];

    NSUInteger offset = ([components weekday] == [calendar firstWeekday]) ? 6 : [components weekday] - 2;
    [components setDay:[components day] - offset];

    return [calendar dateFromComponents:components];
}

- (NSDate *)endOfWeek
{
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setWeekOfMonth:1];

    return [[calendar dateByAddingComponents:components toDate:[self beginningOfWeek] options:0] dateByAddingTimeInterval:-1];
}

- (NSDate *)beginningOfMonth
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:self];

    return [calendar dateFromComponents:components];
}

- (NSDate *)endOfMonth
{
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMonth:1];

    return [[calendar dateByAddingComponents:components toDate:[self beginningOfMonth] options:0] dateByAddingTimeInterval:-1];
}

- (NSDate *)beginningOfYear
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit fromDate:self];

    return [calendar dateFromComponents:components];
}

- (NSDate *)endOfYear
{
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:1];

    return [[calendar dateByAddingComponents:components toDate:[self beginningOfYear] options:0] dateByAddingTimeInterval:-1];
}

- (NSUInteger)day
{
    return [NSDate day:self];
}

- (NSUInteger)month
{
    return [NSDate month:self];
}

- (NSUInteger)year
{
    return [NSDate year:self];
}

- (NSUInteger)hour
{
    return [NSDate hour:self];
}

- (NSUInteger)minute
{
    return [NSDate minute:self];
}

- (NSUInteger)second
{
    return [NSDate second:self];
}

+ (NSUInteger)day:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    // NSDayCalendarUnit
    NSDateComponents *dayComponents = [calendar components:(NSCalendarUnitDay)fromDate:date];
#else
    NSDateComponents *dayComponents = [calendar components:(NSDayCalendarUnit)fromDate:date];
#endif

    return [dayComponents day];
}

+ (NSUInteger)month:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    // NSDayCalendarUnit
    NSDateComponents *dayComponents = [calendar components:(NSCalendarUnitMonth)fromDate:date];
#else
    NSDateComponents *dayComponents = [calendar components:(NSMonthCalendarUnit)fromDate:date];
#endif

    return [dayComponents month];
}

+ (NSUInteger)year:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    // NSDayCalendarUnit
    NSDateComponents *dayComponents = [calendar components:(NSCalendarUnitYear)fromDate:date];
#else
    NSDateComponents *dayComponents = [calendar components:(NSYearCalendarUnit)fromDate:date];
#endif

    return [dayComponents year];
}

+ (NSUInteger)hour:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    // NSDayCalendarUnit
    NSDateComponents *dayComponents = [calendar components:(NSCalendarUnitHour)fromDate:date];
#else
    NSDateComponents *dayComponents = [calendar components:(NSHourCalendarUnit)fromDate:date];
#endif

    return [dayComponents hour];
}

+ (NSUInteger)minute:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    // NSDayCalendarUnit
    NSDateComponents *dayComponents = [calendar components:(NSCalendarUnitMinute)fromDate:date];
#else
    NSDateComponents *dayComponents = [calendar components:(NSMinuteCalendarUnit)fromDate:date];
#endif

    return [dayComponents minute];
}

+ (NSUInteger)second:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    // NSDayCalendarUnit
    NSDateComponents *dayComponents = [calendar components:(NSCalendarUnitSecond)fromDate:date];
#else
    NSDateComponents *dayComponents = [calendar components:(NSSecondCalendarUnit)fromDate:date];
#endif

    return [dayComponents second];
}

- (NSUInteger)daysInYear
{
    return [NSDate daysInYear:self];
}

+ (NSUInteger)daysInYear:(NSDate *)date
{
    return [self isLeapYear:date] ? 366 : 365;
}

- (BOOL)isLeapYear
{
    return [NSDate isLeapYear:self];
}

+ (BOOL)isLeapYear:(NSDate *)date
{
    NSUInteger year = [date year];
    if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
        return YES;
    }
    return NO;
}

- (NSString *)formatYMD
{
    return [NSDate formatYMD:self];
}

+ (NSString *)formatYMD:(NSDate *)date
{
    return [NSString stringWithFormat:@"%zi-%02zi-%02zi", [date year], [date month], [date day]];
}

- (NSUInteger)weeksOfMonth
{
    return [NSDate weeksOfMonth:self];
}

+ (NSUInteger)weeksOfMonth:(NSDate *)date
{
    return [[date lastdayOfMonth] weekOfYear] - [[date begindayOfMonth] weekOfYear] + 1;
}

- (NSUInteger)weekOfYear
{
    return [NSDate weekOfYear:self];
}

+ (NSUInteger)weekOfYear:(NSDate *)date
{
    NSUInteger i;
    NSUInteger year = [date year];

    NSDate *lastdate = [date lastdayOfMonth];

    for (i = 1;[[lastdate dateAfterDay:-7 * i] year] == year; i++) {
    }

    return i;
}

- (NSDate *)dateAfterDay:(NSUInteger)day
{
    return [NSDate dateAfterDate:self day:day];
}

+ (NSDate *)dateAfterDate:(NSDate *)date day:(NSInteger)day
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    [componentsToAdd setDay:day];

    NSDate *dateAfterDay = [calendar dateByAddingComponents:componentsToAdd toDate:date options:0];

    return dateAfterDay;
}

- (NSDate *)dateAfterMonth:(NSUInteger)month
{
    return [NSDate dateAfterDate:self month:month];
}

+ (NSDate *)dateAfterDate:(NSDate *)date month:(NSInteger)month
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    [componentsToAdd setMonth:month];
    NSDate *dateAfterMonth = [calendar dateByAddingComponents:componentsToAdd toDate:date options:0];

    return dateAfterMonth;
}

- (NSDate *)begindayOfMonth
{
    return [NSDate begindayOfMonth:self];
}

+ (NSDate *)begindayOfMonth:(NSDate *)date
{
    return [self dateAfterDate:date day:-[date day] + 1];
}

- (NSDate *)lastdayOfMonth
{
    return [NSDate lastdayOfMonth:self];
}

+ (NSDate *)lastdayOfMonth:(NSDate *)date
{
    NSDate *lastDate = [self begindayOfMonth:date];
    return [[lastDate dateAfterMonth:1] dateAfterDay:-1];
}

- (NSUInteger)daysAgo
{
    return [NSDate daysAgo:self];
}

+ (NSUInteger)daysAgo:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    NSDateComponents *components = [calendar components:(NSCalendarUnitDay)
                                               fromDate:date
                                                 toDate:[NSDate date]
                                                options:0];
#else
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit)
                                               fromDate:date
                                                 toDate:[NSDate date]
                                                options:0];
#endif

    return [components day];
}

- (NSInteger)weekday
{
    return [NSDate weekday:self];
}

+ (NSInteger)weekday:(NSDate *)date
{
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday)fromDate:date];
    NSInteger weekday = [comps weekday];

    return weekday;
}

- (NSString *)dayFromWeekday
{
    return [NSDate dayFromWeekday:self];
}

+ (NSString *)dayFromWeekday:(NSDate *)date
{
    switch ([date weekday]) {
        case 1:
            return @"星期天";
            break;
        case 2:
            return @"星期一";
            break;
        case 3:
            return @"星期二";
            break;
        case 4:
            return @"星期三";
            break;
        case 5:
            return @"星期四";
            break;
        case 6:
            return @"星期五";
            break;
        case 7:
            return @"星期六";
            break;
        default:
            break;
    }
    return @"";
}

- (BOOL)isSameDay:(NSDate *)anotherDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components1 = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                                fromDate:self];
    NSDateComponents *components2 = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                                fromDate:anotherDate];
    return ([components1 year] == [components2 year] && [components1 month] == [components2 month] && [components1 day] == [components2 day]);
}

- (BOOL)isToday
{
    return [self isSameDay:[NSDate date]];
}

- (NSDate *)dateByAddingDays:(NSUInteger)days
{
    NSDateComponents *c = [[NSDateComponents alloc] init];
    c.day = days;
    return [[NSCalendar currentCalendar] dateByAddingComponents:c toDate:self options:0];
}

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
+ (NSString *)monthWithMonthNumber:(NSInteger)month
{
    switch (month) {
        case 1:
            return @"January";
            break;
        case 2:
            return @"February";
            break;
        case 3:
            return @"March";
            break;
        case 4:
            return @"April";
            break;
        case 5:
            return @"May";
            break;
        case 6:
            return @"June";
            break;
        case 7:
            return @"July";
            break;
        case 8:
            return @"August";
            break;
        case 9:
            return @"September";
            break;
        case 10:
            return @"October";
            break;
        case 11:
            return @"November";
            break;
        case 12:
            return @"December";
            break;
        default:
            break;
    }
    return @"";
}

+ (NSString *)stringWithDate:(NSDate *)date format:(NSString *)format
{
    return [date stringWithFormat:format];
}

- (NSString *)stringWithFormat:(NSString *)format
{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:format];

    NSString *retStr = [outputFormatter stringFromDate:self];

    return retStr;
}

+ (NSDate *)dateWithString:(NSString *)string format:(NSString *)format
{
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:format];

    NSDate *date = [inputFormatter dateFromString:string];

    return date;
}

- (NSUInteger)daysInMonth:(NSUInteger)month
{
    return [NSDate daysInMonth:self month:month];
}

+ (NSUInteger)daysInMonth:(NSDate *)date month:(NSUInteger)month
{
    switch (month) {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:
            return 31;
        case 2:
            return [date isLeapYear] ? 29 : 28;
    }
    return 30;
}

- (NSUInteger)daysInMonth
{
    return [NSDate daysInMonth:self];
}

+ (NSUInteger)daysInMonth:(NSDate *)date
{
    return [self daysInMonth:date month:[date month]];
}

- (NSString *)timeInfo
{
    return [NSDate timeInfoWithDate:self];
}

+ (NSString *)timeInfoWithDate:(NSDate *)date
{
    return [self timeInfoWithDateString:[self stringWithDate:date format:[self ymdHmsFormat]]];
}

+ (NSString *)timeInfoWithDateString:(NSString *)dateString
{
    NSDate *date = [self dateWithString:dateString format:[self ymdHmsFormat]];

    NSDate *curDate = [NSDate date];
    NSTimeInterval time = -[date timeIntervalSinceDate:curDate];

    int month = (int)([curDate month] - [date month]);
    int year = (int)([curDate year] - [date year]);
    int day = (int)([curDate day] - [date day]);

    NSTimeInterval retTime = 1.0;
    if (time < 3600) { // 小于一小时
        retTime = time / 60;
        retTime = retTime <= 0.0 ? 1.0 : retTime;
        return [NSString stringWithFormat:@"%.0f分钟前", retTime];
    } else if (time < 3600 * 24) { // 小于一天，也就是今天
        retTime = time / 3600;
        retTime = retTime <= 0.0 ? 1.0 : retTime;
        return [NSString stringWithFormat:@"%.0f小时前", retTime];
    } else if (time < 3600 * 24 * 2) {
        return @"昨天";
    }
    // 第一个条件是同年，且相隔时间在一个月内
    // 第二个条件是隔年，对于隔年，只能是去年12月与今年1月这种情况
    else if ((abs(year) == 0 && abs(month) <= 1) || (abs(year) == 1 && [curDate month] == 1 && [date month] == 12)) {
        int retDay = 0;
        if (year == 0) {   // 同年
            if (month == 0) { // 同月
                retDay = day;
            }
        }

        if (retDay <= 0) {
            // 获取发布日期中，该月有多少天
            int totalDays = (int)[self daysInMonth:date month:[date month]];

            // 当前天数 + （发布日期月中的总天数-发布日期月中发布日，即等于距离今天的天数）
            retDay = (int)[curDate day] + (totalDays - (int)[date day]);
        }

        return [NSString stringWithFormat:@"%d天前", (abs)(retDay)];
    } else {
        if (abs(year) <= 1) {
            if (year == 0) { // 同年
                return [NSString stringWithFormat:@"%d个月前", abs(month)];
            }

            // 隔年
            int month = (int)[curDate month];
            int preMonth = (int)[date month];
            if (month == 12 && preMonth == 12) { // 隔年，但同月，就作为满一年来计算
                return @"1年前";
            }
            return [NSString stringWithFormat:@"%d个月前", (abs)(12 - preMonth + month)];
        }

        return [NSString stringWithFormat:@"%d年前", abs(year)];
    }

    return @"1小时前";
}

- (NSString *)ymdFormat
{
    return [NSDate ymdFormat];
}

- (NSString *)hmsFormat
{
    return [NSDate hmsFormat];
}

- (NSString *)ymdHmsFormat
{
    return [NSDate ymdHmsFormat];
}

+ (NSString *)ymdFormat
{
    return @"yyyy-MM-dd";
}

+ (NSString *)hmsFormat
{
    return @"HH:mm:ss";
}

+ (NSString *)ymdHmsFormat
{
    return [NSString stringWithFormat:@"%@ %@", [self ymdFormat], [self hmsFormat]];
}

- (NSDate *)offsetYears:(int)numYears
{
    return [NSDate offsetYears:numYears fromDate:self];
}

+ (NSDate *)offsetYears:(int)numYears fromDate:(NSDate *)fromDate
{
    if (fromDate == nil) {
        return nil;
    }

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    // NSDayCalendarUnit
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
#else
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
#endif


    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setYear:numYears];

    return [gregorian dateByAddingComponents:offsetComponents
                                      toDate:fromDate
                                     options:0];
}

- (NSDate *)offsetMonths:(int)numMonths
{
    return [NSDate offsetMonths:numMonths fromDate:self];
}

+ (NSDate *)offsetMonths:(int)numMonths fromDate:(NSDate *)fromDate
{
    if (fromDate == nil) {
        return nil;
    }

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    // NSDayCalendarUnit
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
#else
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
#endif


    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setMonth:numMonths];

    return [gregorian dateByAddingComponents:offsetComponents
                                      toDate:fromDate
                                     options:0];
}

- (NSDate *)offsetDays:(int)numDays
{
    return [NSDate offsetDays:numDays fromDate:self];
}

+ (NSDate *)offsetDays:(int)numDays fromDate:(NSDate *)fromDate
{
    if (fromDate == nil) {
        return nil;
    }

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    // NSDayCalendarUnit
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
#else
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
#endif


    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:numDays];

    return [gregorian dateByAddingComponents:offsetComponents
                                      toDate:fromDate
                                     options:0];
}

- (NSDate *)offsetHours:(int)hours
{
    return [NSDate offsetHours:hours fromDate:self];
}

+ (NSDate *)offsetHours:(int)numHours fromDate:(NSDate *)fromDate
{
    if (fromDate == nil) {
        return nil;
    }

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    // NSDayCalendarUnit
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
#else
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
#endif


    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setHour:numHours];

    return [gregorian dateByAddingComponents:offsetComponents
                                      toDate:fromDate
                                     options:0];
}

#pragma mark -
#pragma mark :. Formatter

+ (NSDateFormatter *)formatter
{

    static NSDateFormatter *formatter = nil;
    static dispatch_once_t oncePredicate;

    dispatch_once(&oncePredicate, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDoesRelativeDateFormatting:YES];
    });

    return formatter;
}

+ (NSDateFormatter *)formatterWithoutTime
{

    static NSDateFormatter *formatterWithoutTime = nil;
    static dispatch_once_t oncePredicate;

    dispatch_once(&oncePredicate, ^{
        formatterWithoutTime = [[NSDate formatter] copy];
        [formatterWithoutTime setTimeStyle:NSDateFormatterNoStyle];
    });

    return formatterWithoutTime;
}

+ (NSDateFormatter *)formatterWithoutDate
{

    static NSDateFormatter *formatterWithoutDate = nil;
    static dispatch_once_t oncePredicate;

    dispatch_once(&oncePredicate, ^{
        formatterWithoutDate = [[NSDate formatter] copy];
        [formatterWithoutDate setDateStyle:NSDateFormatterNoStyle];
    });

    return formatterWithoutDate;
}

#pragma mark--- Formatter with date & time
- (NSString *)formatWithUTCTimeZone
{
    return [self formatWithTimeZoneOffset:0];
}

- (NSString *)formatWithLocalTimeZone
{
    return [self formatWithTimeZone:[NSTimeZone localTimeZone]];
}

- (NSString *)formatWithTimeZoneOffset:(NSTimeInterval)offset
{
    return [self formatWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:offset]];
}

- (NSString *)formatWithTimeZone:(NSTimeZone *)timezone
{
    NSDateFormatter *formatter = [NSDate formatter];
    [formatter setTimeZone:timezone];
    return [formatter stringFromDate:self];
}

#pragma mark--- Formatter without time
- (NSString *)formatWithUTCTimeZoneWithoutTime
{
    return [self formatWithTimeZoneOffsetWithoutTime:0];
}

- (NSString *)formatWithLocalTimeZoneWithoutTime
{
    return [self formatWithTimeZoneWithoutTime:[NSTimeZone localTimeZone]];
}

- (NSString *)formatWithTimeZoneOffsetWithoutTime:(NSTimeInterval)offset
{
    return [self formatWithTimeZoneWithoutTime:[NSTimeZone timeZoneForSecondsFromGMT:offset]];
}

- (NSString *)formatWithTimeZoneWithoutTime:(NSTimeZone *)timezone
{
    NSDateFormatter *formatter = [NSDate formatterWithoutTime];
    [formatter setTimeZone:timezone];
    return [formatter stringFromDate:self];
}

#pragma mark--- Formatter without date
- (NSString *)formatWithUTCWithoutDate
{
    return [self formatTimeWithTimeZone:0];
}
- (NSString *)formatWithLocalTimeWithoutDate
{
    return [self formatTimeWithTimeZone:[NSTimeZone localTimeZone]];
}

- (NSString *)formatWithTimeZoneOffsetWithoutDate:(NSTimeInterval)offset
{
    return [self formatTimeWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:offset]];
}

- (NSString *)formatTimeWithTimeZone:(NSTimeZone *)timezone
{
    NSDateFormatter *formatter = [NSDate formatterWithoutDate];
    [formatter setTimeZone:timezone];
    return [formatter stringFromDate:self];
}

#pragma mark--- Formatter  date
+ (NSString *)currentDateStringWithFormat:(NSString *)format
{
    NSDate *chosenDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSString *date = [formatter stringFromDate:chosenDate];
    return date;
}
+ (NSDate *)dateWithSecondsFromNow:(NSInteger)seconds
{
    NSDate *date = [NSDate date];
    NSDateComponents *components = [NSDateComponents new];
    [components setSecond:seconds];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *dateSecondsAgo = [calendar dateByAddingComponents:components toDate:date options:0];
    return dateSecondsAgo;
}

+ (NSDate *)dateWithYear:(NSInteger)year Month:(NSInteger)month Day:(NSInteger)day
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:year];
    [components setMonth:month];
    [components setDay:day];
    return [calendar dateFromComponents:components];
}
- (NSString *)dateWithFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSString *date = [formatter stringFromDate:self];
    return date;
}

#pragma mark -
#pragma mark :. InternetDateTime

// Always keep the formatter around as they're expensive to instantiate
static NSDateFormatter *_internetDateTimeFormatter = nil;

// Instantiate single date formatter
+ (NSDateFormatter *)internetDateTimeFormatter
{
    @synchronized(self)
    {
        if (!_internetDateTimeFormatter) {
            NSLocale *en_US_POSIX = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            _internetDateTimeFormatter = [[NSDateFormatter alloc] init];
            [_internetDateTimeFormatter setLocale:en_US_POSIX];
            [_internetDateTimeFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        }
    }
    return _internetDateTimeFormatter;
}

// Get a date from a string - hint can be used to speed up
+ (NSDate *)dateFromInternetDateTimeString:(NSString *)dateString formatHint:(DateFormatHint)hint
{
    // Keep dateString around a while (for thread-safety)
    NSDate *date = nil;
    if (dateString) {
        if (hint != DateFormatHintRFC3339) {
            // Try RFC822 first
            date = [NSDate dateFromRFC822String:dateString];
            if (!date) date = [NSDate dateFromRFC3339String:dateString];
        } else {
            // Try RFC3339 first
            date = [NSDate dateFromRFC3339String:dateString];
            if (!date) date = [NSDate dateFromRFC822String:dateString];
        }
    }
    // Finished with date string
    return date;
}

+ (NSDate *)dateFromRFC822String:(NSString *)dateString
{
    // Keep dateString around a while (for thread-safety)
    NSDate *date = nil;
    if (dateString) {
        NSDateFormatter *dateFormatter = [NSDate internetDateTimeFormatter];
        @synchronized(dateFormatter)
        {

            // Process
            NSString *RFC822String = [[NSString stringWithString:dateString] uppercaseString];
            if ([RFC822String rangeOfString:@","].location != NSNotFound) {
                if (!date) { // Sun, 19 May 2002 15:21:36 GMT
                    [dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss zzz"];
                    date = [dateFormatter dateFromString:RFC822String];
                }
                if (!date) { // Sun, 19 May 2002 15:21 GMT
                    [dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm zzz"];
                    date = [dateFormatter dateFromString:RFC822String];
                }
                if (!date) { // Sun, 19 May 2002 15:21:36
                    [dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss"];
                    date = [dateFormatter dateFromString:RFC822String];
                }
                if (!date) { // Sun, 19 May 2002 15:21
                    [dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm"];
                    date = [dateFormatter dateFromString:RFC822String];
                }
            } else {
                if (!date) { // 19 May 2002 15:21:36 GMT
                    [dateFormatter setDateFormat:@"d MMM yyyy HH:mm:ss zzz"];
                    date = [dateFormatter dateFromString:RFC822String];
                }
                if (!date) { // 19 May 2002 15:21 GMT
                    [dateFormatter setDateFormat:@"d MMM yyyy HH:mm zzz"];
                    date = [dateFormatter dateFromString:RFC822String];
                }
                if (!date) { // 19 May 2002 15:21:36
                    [dateFormatter setDateFormat:@"d MMM yyyy HH:mm:ss"];
                    date = [dateFormatter dateFromString:RFC822String];
                }
                if (!date) { // 19 May 2002 15:21
                    [dateFormatter setDateFormat:@"d MMM yyyy HH:mm"];
                    date = [dateFormatter dateFromString:RFC822String];
                }
            }
            if (!date) NSLog(@"Could not parse RFC822 date: \"%@\" Possible invalid format.", dateString);
        }
    }
    // Finished with date string
    return date;
}

+ (NSDate *)dateFromRFC3339String:(NSString *)dateString
{
    // Keep dateString around a while (for thread-safety)
    NSDate *date = nil;
    if (dateString) {
        NSDateFormatter *dateFormatter = [NSDate internetDateTimeFormatter];
        @synchronized(dateFormatter)
        {

            // Process date
            NSString *RFC3339String = [[NSString stringWithString:dateString] uppercaseString];
            RFC3339String = [RFC3339String stringByReplacingOccurrencesOfString:@"Z" withString:@"-0000"];
            // Remove colon in timezone as it breaks NSDateFormatter in iOS 4+.
            if (RFC3339String.length > 20) {
                RFC3339String = [RFC3339String stringByReplacingOccurrencesOfString:@":"
                                                                         withString:@""
                                                                            options:0
                                                                              range:NSMakeRange(20, RFC3339String.length - 20)];
            }
            if (!date) { // 1996-12-19T16:39:57-0800
                [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"];
                date = [dateFormatter dateFromString:RFC3339String];
            }
            if (!date) { // 1937-01-01T12:00:27.87+0020
                [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZZZ"];
                date = [dateFormatter dateFromString:RFC3339String];
            }
            if (!date) { // 1937-01-01T12:00:27
                [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss"];
                date = [dateFormatter dateFromString:RFC3339String];
            }
            if (!date) //  2013-04-05 14:06:00
            {
                [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd HH':'mm':'ss"];
                date = [dateFormatter dateFromString:RFC3339String];
            }
            if (!date) NSLog(@"Could not parse RFC3339 date: \"%@\" Possible invalid format.", dateString);
        }
    }
    // Finished with date string
    return date;
}

#pragma mark -
#pragma mark :. Reporting

+ (NSDate *)midnightOfDate:(NSDate *)date
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    // Start out by getting just the year, month and day components of the specified date.
    NSDateComponents *components = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                                        fromDate:date];
    // Zero out the hour, minute and second components.
    [self zeroOutTimeComponents:&components];

    // Convert the components back into a date and return it.
    return [gregorianCalendar dateFromComponents:components];
}

+ (NSDate *)midnightToday
{
    return [self midnightOfDate:[NSDate date]];
}

+ (NSDate *)midnightTomorrow
{
    NSDate *midnightToday = [self midnightToday];
    return [self oneDayAfter:midnightToday];
}

+ (NSDate *)oneDayAfter:(NSDate *)date
{
    NSDateComponents *oneDayComponent = [[NSDateComponents alloc] init];
    [oneDayComponent setDay:1];

    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [gregorianCalendar dateByAddingComponents:oneDayComponent
                                              toDate:date
                                             options:0];
}

+ (NSDate *)firstDayOfCurrentMonth
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    // Start out by getting just the year, month and day components of the current date.
    NSDate *currentDate = [NSDate date];
    NSDateComponents *components = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                                        fromDate:currentDate];

    // Change the Day component to 1 (for the first day of the month), and zero out the time components.
    [components setDay:1];
    [self zeroOutTimeComponents:&components];

    return [gregorianCalendar dateFromComponents:components];
}

+ (NSDate *)firstDayOfPreviousMonth
{
    // Set up a "minus one month" component.
    NSDateComponents *minusOneMonthComponent = [[NSDateComponents alloc] init];
    [minusOneMonthComponent setMonth:-1];

    // Subtract 1 month from today's date. This gives us "one month ago today".
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *currentDate = [NSDate date];
    NSDate *oneMonthAgoToday = [gregorianCalendar dateByAddingComponents:minusOneMonthComponent
                                                                  toDate:currentDate
                                                                 options:0];

    // Now extract the year, month and day components of oneMonthAgoToday.
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit
                                                        fromDate:oneMonthAgoToday];

    // Change the day to 1 (since we want the first day of the previous month).
    [components setDay:1];

    // Zero out the time components so we get midnight.
    [self zeroOutTimeComponents:&components];

    // Finally, create a new NSDate from components and return it.
    return [gregorianCalendar dateFromComponents:components];
}

+ (NSDate *)firstDayOfNextMonth
{
    NSDate *firstDayOfCurrentMonth = [self firstDayOfCurrentMonth];

    // Set up a "plus 1 month" component.
    NSDateComponents *plusOneMonthComponent = [[NSDateComponents alloc] init];
    [plusOneMonthComponent setMonth:1];

    // Add 1 month to firstDayOfCurrentMonth.
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [gregorianCalendar dateByAddingComponents:plusOneMonthComponent
                                              toDate:firstDayOfCurrentMonth
                                             options:0];
}

+ (NSDate *)firstDayOfCurrentQuarter
{
    return [self firstDayOfQuarterFromDate:[NSDate date]];
}

+ (NSDate *)firstDayOfPreviousQuarter
{
    NSDate *firstDayOfCurrentQuarter = [self firstDayOfCurrentQuarter];

    // Set up a "minus one day" component.
    NSDateComponents *minusOneDayComponent = [[NSDateComponents alloc] init];
    [minusOneDayComponent setDay:-1];

    // Subtract 1 day from firstDayOfCurrentQuarter.
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *lastDayOfPreviousQuarter = [gregorianCalendar dateByAddingComponents:minusOneDayComponent
                                                                          toDate:firstDayOfCurrentQuarter
                                                                         options:0];
    return [self firstDayOfQuarterFromDate:lastDayOfPreviousQuarter];
}

+ (NSDate *)firstDayOfNextQuarter
{
    NSDate *firstDayOfCurrentQuarter = [self firstDayOfCurrentQuarter];

    // Set up a "plus 3 months" component.
    NSDateComponents *plusThreeMonthsComponent = [[NSDateComponents alloc] init];
    [plusThreeMonthsComponent setMonth:3];

    // Add 3 months to firstDayOfCurrentQuarter.
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [gregorianCalendar dateByAddingComponents:plusThreeMonthsComponent
                                              toDate:firstDayOfCurrentQuarter
                                             options:0];
}

+ (NSDate *)firstDayOfCurrentYear
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    // Start out by getting just the year, month and day components of the current date.
    NSDate *currentDate = [NSDate date];
    NSDateComponents *components = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                                        fromDate:currentDate];

    // Change the Day and Month components to 1 (for the first day of the year), and zero out the time components.
    [components setDay:1];
    [components setMonth:1];
    [self zeroOutTimeComponents:&components];

    return [gregorianCalendar dateFromComponents:components];
}

+ (NSDate *)firstDayOfPreviousYear
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *currentDate = [NSDate date];
    NSDateComponents *components = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                                        fromDate:currentDate];
    [components setDay:1];
    [components setMonth:1];
    [components setYear:components.year - 1];

    // Zero out the time components so we get midnight.
    [self zeroOutTimeComponents:&components];
    return [gregorianCalendar dateFromComponents:components];
}

+ (NSDate *)firstDayOfNextYear
{
    NSDate *firstDayOfCurrentYear = [self firstDayOfCurrentYear];

    // Set up a "plus 1 year" component.
    NSDateComponents *plusOneYearComponent = [[NSDateComponents alloc] init];
    [plusOneYearComponent setYear:1];

    // Add 1 year to firstDayOfCurrentYear.
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [gregorianCalendar dateByAddingComponents:plusOneYearComponent
                                              toDate:firstDayOfCurrentYear
                                             options:0];
}

#ifdef DEBUG
- (void)logWithComment:(NSString *)comment
{
    NSString *output = [NSDateFormatter localizedStringFromDate:self
                                                      dateStyle:NSDateFormatterMediumStyle
                                                      timeStyle:NSDateFormatterMediumStyle];
    NSLog(@"%@: %@", comment, output);
}
#endif

#pragma mark - Private Helper functions

+ (void)zeroOutTimeComponents:(NSDateComponents **)components
{
    [*components setHour:0];
    [*components setMinute:0];
    [*components setSecond:0];
}

+ (NSDate *)firstDayOfQuarterFromDate:(NSDate *)date
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSMonthCalendarUnit | NSYearCalendarUnit
                                                        fromDate:date];

    NSInteger quarterNumber = floor((components.month - 1) / 3) + 1;
    // NSLog(@"Quarter number: %d", quarterNumber);

    NSInteger firstMonthOfQuarter = (quarterNumber - 1) * 3 + 1;
    [components setMonth:firstMonthOfQuarter];
    [components setDay:1];

    // Zero out the time components so we get midnight.
    [self zeroOutTimeComponents:&components];
    return [gregorianCalendar dateFromComponents:components];
}


- (NSDate *)dateFloor
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    NSDateComponents *dateComponents = [gregorianCalendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit)fromDate:self];

    return [gregorianCalendar dateFromComponents:dateComponents];
}

- (NSDate *)dateCeil
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    NSDateComponents *dateComponents = [gregorianCalendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit)fromDate:self];

    [dateComponents setHour:23];
    [dateComponents setMinute:59];
    [dateComponents setSecond:59];

    return [gregorianCalendar dateFromComponents:dateComponents];
}

- (NSDate *)previousDay
{
    return [self dateByAddingTimeInterval:-86400];
}

- (NSDate *)nextDay
{
    return [self dateByAddingTimeInterval:86400];
}

- (NSDate *)previousWeek
{
    return [self dateByAddingTimeInterval:-(86400 * 7)];
}

- (NSDate *)nextWeek
{
    return [self dateByAddingTimeInterval:+(86400 * 7)];
}

- (NSDate *)previousMonth
{
    return [self previousMonth:1];
}

- (NSDate *)previousMonth:(NSUInteger)monthsToMove
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    NSDateComponents *components = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:self];

    NSInteger dayInMonth = [components day];

    // Update the components, initially setting the day in month to 0
    NSInteger newMonth = ([components month] - monthsToMove);
    [components setDay:1];
    [components setMonth:newMonth];

    // Determine the valid day range for that month
    NSDate *workingDate = [gregorianCalendar dateFromComponents:components];
    NSRange dayRange = [gregorianCalendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:workingDate];

    // Set the day clamping to the maximum number of days in that month
    [components setDay:MIN(dayInMonth, dayRange.length)];

    return [gregorianCalendar dateFromComponents:components];
}

- (NSDate *)nextMonth
{
    return [self nextMonth:1];
}

- (NSDate *)nextMonth:(NSUInteger)monthsToMove
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    NSDateComponents *components = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:self];

    NSInteger dayInMonth = [components day];

    // Update the components, initially setting the day in month to 0
    NSInteger newMonth = ([components month] + monthsToMove);
    [components setDay:1];
    [components setMonth:newMonth];

    // Determine the valid day range for that month
    NSDate *workingDate = [gregorianCalendar dateFromComponents:components];
    NSRange dayRange = [gregorianCalendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:workingDate];

    // Set the day clamping to the maximum number of days in that month
    [components setDay:MIN(dayInMonth, dayRange.length)];

    return [gregorianCalendar dateFromComponents:components];
}

#pragma mark -
#pragma mark :. Utilities

#define D_MINUTE 60
#define D_HOUR 3600
#define D_DAY 86400
#define D_WEEK 604800
#define D_YEAR 31556926

#define DATE_COMPONENTS (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

+ (NSCalendar *)currentCalendar
{
    static NSCalendar *sharedCalendar = nil;
    if (!sharedCalendar)
        sharedCalendar = [NSCalendar autoupdatingCurrentCalendar];
    return sharedCalendar;
}

#pragma mark--- Relative Dates
+ (NSDate *)dateWithDaysFromNow:(NSInteger)days
{
    // Thanks, Jim Morrison
    return [[NSDate date] dateByAddingDays:days];
}
+ (NSDate *)dateWithDaysBeforeNow:(NSInteger)days
{
    // Thanks, Jim Morrison
    return [[NSDate date] dateBySubtractingDays:days];
}
+ (NSDate *)dateTomorrow
{
    return [NSDate dateWithDaysFromNow:1];
}
+ (NSDate *)dateYesterday
{
    return [NSDate dateWithDaysBeforeNow:1];
}
+ (NSDate *)dateWithHoursFromNow:(NSInteger)dHours
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}
+ (NSDate *)dateWithHoursBeforeNow:(NSInteger)dHours
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}
+ (NSDate *)dateWithMinutesFromNow:(NSInteger)dMinutes
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}
+ (NSDate *)dateWithMinutesBeforeNow:(NSInteger)dMinutes
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

#pragma mark--- String Properties

- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateStyle = dateStyle;
    formatter.timeStyle = timeStyle;
    //    formatter.locale = [NSLocale currentLocale]; // Necessary?
    return [formatter stringFromDate:self];
}

- (NSString *)shortString
{
    return [self stringWithDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
}

- (NSString *)shortTimeString
{
    return [self stringWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
}

- (NSString *)shortDateString
{
    return [self stringWithDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
}

- (NSString *)mediumString
{
    return [self stringWithDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
}

- (NSString *)mediumTimeString
{
    return [self stringWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle];
}

- (NSString *)mediumDateString
{
    return [self stringWithDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
}

- (NSString *)longString
{
    return [self stringWithDateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterLongStyle];
}

- (NSString *)longTimeString
{
    return [self stringWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterLongStyle];
}

- (NSString *)longDateString
{
    return [self stringWithDateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
}


#pragma mark--- Comparing Dates
- (BOOL)isEqualToDateIgnoringTime:(NSDate *)aDate
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
    return ((components1.year == components2.year) &&
            (components1.month == components2.month) &&
            (components1.day == components2.day));
}

- (BOOL)isTomorrow
{
    return [self isEqualToDateIgnoringTime:[NSDate dateTomorrow]];
}
- (BOOL)isYesterday
{
    return [self isEqualToDateIgnoringTime:[NSDate dateYesterday]];
}
// This hard codes the assumption that a week is 7 days
- (BOOL)isSameWeekAsDate:(NSDate *)aDate
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
    // Must be same week. 12/31 and 1/1 will both be week "1" if they are in the same week
    if (components1.weekOfYear != components2.weekOfYear) return NO;
    // Must have a time interval under 1 week. Thanks @aclark
    return (fabs([self timeIntervalSinceDate:aDate]) < D_WEEK);
}
- (BOOL)isThisWeek
{
    return [self isSameWeekAsDate:[NSDate date]];
}
- (BOOL)isNextWeek
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_WEEK;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return [self isSameWeekAsDate:newDate];
}
- (BOOL)isLastWeek
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_WEEK;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return [self isSameWeekAsDate:newDate];
}
// Thanks, mspasov
- (BOOL)isSameMonthAsDate:(NSDate *)aDate
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:aDate];
    return ((components1.month == components2.month) &&
            (components1.year == components2.year));
}

- (BOOL)isThisMonth
{
    return [self isSameMonthAsDate:[NSDate date]];
}
- (BOOL)isLastMonth
{
    return [self isSameMonthAsDate:[[NSDate date] dateBySubtractingMonths:1]];
}

- (BOOL)isNextMonth
{
    return [self isSameMonthAsDate:[[NSDate date] dateByAddingMonths:1]];
}

- (BOOL)isSameYearAsDate:(NSDate *)aDate
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:aDate];
    return (components1.year == components2.year);
}
- (BOOL)isThisYear
{
    // Thanks, baspellis
    return [self isSameYearAsDate:[NSDate date]];
}
- (BOOL)isNextYear
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:[NSDate date]];
    return (components1.year == (components2.year + 1));
}
- (BOOL)isLastYear
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:[NSDate date]];
    return (components1.year == (components2.year - 1));
}
- (BOOL)isEarlierThanDate:(NSDate *)aDate
{
    return ([self compare:aDate] == NSOrderedAscending);
}
- (BOOL)isLaterThanDate:(NSDate *)aDate
{
    return ([self compare:aDate] == NSOrderedDescending);
}
// Thanks, markrickert
- (BOOL)isInFuture
{
    return ([self isLaterThanDate:[NSDate date]]);
}
// Thanks, markrickert
- (BOOL)isInPast
{
    return ([self isEarlierThanDate:[NSDate date]]);
}
#pragma mark--- Roles
- (BOOL)isTypicallyWeekend
{
    NSDateComponents *components = [CURRENT_CALENDAR components:NSWeekdayCalendarUnit fromDate:self];
    if ((components.weekday == 1) ||
        (components.weekday == 7))
        return YES;
    return NO;
}
- (BOOL)isTypicallyWorkday
{
    return ![self isTypicallyWeekend];
}

#pragma mark--- Adjusting Dates

// Thaks, rsjohnson
- (NSDate *)dateByAddingYears:(NSInteger)dYears
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:dYears];
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
    return newDate;
}

- (NSDate *)dateBySubtractingYears:(NSInteger)dYears
{
    return [self dateByAddingYears:-dYears];
}

- (NSDate *)dateByAddingMonths:(NSInteger)dMonths
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setMonth:dMonths];
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
    return newDate;
}

- (NSDate *)dateBySubtractingMonths:(NSInteger)dMonths
{
    return [self dateByAddingMonths:-dMonths];
}

- (NSDate *)dateBySubtractingDays:(NSInteger)dDays
{
    return [self dateByAddingDays:(dDays * -1)];
}
- (NSDate *)dateByAddingHours:(NSInteger)dHours
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}
- (NSDate *)dateBySubtractingHours:(NSInteger)dHours
{
    return [self dateByAddingHours:(dHours * -1)];
}
- (NSDate *)dateByAddingMinutes:(NSInteger)dMinutes
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}
- (NSDate *)dateBySubtractingMinutes:(NSInteger)dMinutes
{
    return [self dateByAddingMinutes:(dMinutes * -1)];
}
- (NSDate *)dateAtStartOfDay
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    return [CURRENT_CALENDAR dateFromComponents:components];
}
// Thanks gsempe & mteece
- (NSDate *)dateAtEndOfDay
{
    NSDateComponents *components = [[NSDate currentCalendar] components:DATE_COMPONENTS fromDate:self];
    components.hour = 23; // Thanks Aleksey Kononov
    components.minute = 59;
    components.second = 59;
    return [[NSDate currentCalendar] dateFromComponents:components];
}
- (NSDateComponents *)componentsWithOffsetFromDate:(NSDate *)aDate
{
    NSDateComponents *dTime = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate toDate:self options:0];
    return dTime;
}

#pragma mark--- Retrieving Intervals
- (NSInteger)minutesAfterDate:(NSDate *)aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger)(ti / D_MINUTE);
}
- (NSInteger)minutesBeforeDate:(NSDate *)aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger)(ti / D_MINUTE);
}
- (NSInteger)hoursAfterDate:(NSDate *)aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger)(ti / D_HOUR);
}
- (NSInteger)hoursBeforeDate:(NSDate *)aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger)(ti / D_HOUR);
}
- (NSInteger)daysAfterDate:(NSDate *)aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger)(ti / D_DAY);
}
- (NSInteger)daysBeforeDate:(NSDate *)aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger)(ti / D_DAY);
}
// Thanks, dmitrydims
// I have not yet thoroughly tested this
- (NSInteger)distanceInDaysToDate:(NSDate *)anotherDate
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit fromDate:self toDate:anotherDate options:0];
    return components.day;
}
#pragma mark--- Decomposing Dates
- (NSInteger)nearestHour
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * 30;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    NSDateComponents *components = [CURRENT_CALENDAR components:NSHourCalendarUnit fromDate:newDate];
    return components.hour;
}

- (NSInteger)seconds
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.second;
}

- (NSInteger)week
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.weekOfYear;
}

- (NSInteger)nthWeekday // e.g. 2nd Tuesday of the month is 2
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.weekdayOrdinal;
}


@end
