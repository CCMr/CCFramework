//
//  CalendarDay.m
//  CC
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

#import "CalendarDay.h"
#import "NSString+BNSString.h"
#import "NSDate+BNSDate.h"

@implementation CalendarDay

//公共的方法
+ (CalendarDay *)calendarDayWithDateComponents:(NSDateComponents *)components Day:(int)day{
    CalendarDay *calendarDay = [[CalendarDay alloc] init];//初始化自身
    calendarDay.Year = components.year;//年
    calendarDay.Month = components.month;//月
    calendarDay.Day = day;//日
    
    return calendarDay;
}


//返回当前天的NSDate对象
- (NSDate *)date{
    return [[NSString stringWithFormat:@"%d-%d-%d",(int)_Year,(int)_Month,(int)_Day] convertingStringsToDate:@"yyyy-MM-dd"];
}

//返回当前天的NSString对象
- (NSString *)toString{
    NSDate *date = [self date];
    NSString *string = [date stringFromDate:date];
    return string;
}


//返回星期
- (NSString *)getWeek{
    NSDate *date = [self date];
    NSString *week_str = [date compareIfTodayWithDate];
    return week_str;
}

//判断是不是同一天
- (BOOL)isEqualTo:(CalendarDay *)day{
    BOOL isEqual = (self.Year == day.Year) && (self.Month == day.Month) && (self.Day == day.Day);
    return isEqual;
}

@end
