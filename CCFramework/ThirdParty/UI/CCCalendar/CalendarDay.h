//
//  CalendarDay.h
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

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CollectionViewCellDayType) {
    CellDayTypeEmpty,   //不显示
    CellDayTypePast,    //过去的日期
    CellDayTypeFutur,   //将来的日期
    CellDayTypeWeek,    //周末
    CellDayTypeClick    //被点击的日期
};

@interface CalendarDay : NSObject
@property (nonatomic, assign) NSUInteger Year;//年
@property (nonatomic, assign) NSUInteger Month;//月
@property (nonatomic, assign) NSUInteger Day;//天

@property (nonatomic, assign) NSUInteger Week;//周

@property (nonatomic, strong) NSString *LunarCalendar;//农历
@property (nonatomic, strong) NSString *Annotation; //注解
@property (nonatomic, strong) NSString *Holidays;//节日

@property (assign, nonatomic) CollectionViewCellDayType style;//显示的样式

+(CalendarDay *)calendarDayWithDateComponents:(NSDateComponents *)components Day:(NSInteger)day;
-(NSDate *)date;//返回当前天的NSDate对象
-(NSString *)toString;//返回当前天的NSString对象
-(NSString *)getWeek; //返回星期

@end
