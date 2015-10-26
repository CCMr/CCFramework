//
//  CalendarLogic.m
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

#import "CalendarLogic.h"
#import "NSDate+BNSDate.h"

@interface CalendarLogic()

/**
 *  @author CC, 2015-07-29
 *
 *  @brief  之后的日期
 *
 *  @since 1.0
 */
@property (nonatomic, strong) NSDate *before;

/**
 *  @author CC, 2015-07-29
 *
 *  @brief  选择的开始日期
 *
 *  @since 1.0
 */
@property (nonatomic, strong) NSDate *select;

@property (nonatomic, strong) NSString *beginDayAnnotation;
@property (nonatomic, strong) NSString *endDayAnnotation;

@end

@implementation CalendarLogic

#pragma mark - 设置属性
-(void)setCalendarBeginDayAnnotation:(NSString *)calendarBeginDayAnnotation{
    _calendarBeginDayAnnotation= calendarBeginDayAnnotation;
}

-(void)setCalendarEndDayAnnotation:(NSString *)calendarEndDayAnnotation{
    _calendarEndDayAnnotation = calendarEndDayAnnotation;
}

-(void)setBeginDate:(NSDate *)beginDate{
    _beginDate = beginDate;
}

-(void)setEndDate:(NSDate *)EndDate{
    _EndDate = EndDate;
}

-(NSMutableArray *)reloadCalendarView:(NSDate *)date BeginDate:(NSDate *)beginDate EndDate:(NSDate *)endDate NeedDays:(int)days_number{
    if (endDate)
        _EndDate = endDate;
    return [self reloadCalendarView:date selectDate:beginDate needDays:days_number];
}

//计算当前日期之前几天或者是之后的几天（负数是之前几天，正数是之后的几天）
- (NSMutableArray *)reloadCalendarView:(NSDate *)date  selectDate:(NSDate *)selectdate needDays:(int)days_number{
    //如果为空就从当天的日期开始
    if(!date)
        date = [NSDate date];
    
    //默认选择中的时间
    if (!selectdate)
        selectdate = date;
    
//    if (_EndDate)
//        _EndDate = [CommonUtils ConverDays:selectdate Before:NO];
    
    _beginDate = date;//起始日期
    _before = [date dayInTheFollowingDay:days_number];//计算它days天以后的时间
    _select = selectdate;//选择的日期
    
    return [self calendarMoths];
}

-(NSMutableArray *)calendarMoths{
    NSDateComponents *todayDC= [_beginDate YMDComponents];
    NSDateComponents *beforeDC= [_before YMDComponents];
    
    NSInteger todayYear = todayDC.year;
    NSInteger todayMonth = todayDC.month;
    NSInteger beforeYear = beforeDC.year;
    NSInteger beforeMonth = beforeDC.month;
    NSInteger months = (beforeYear-todayYear) * 12 + (beforeMonth - todayMonth);
    
    NSMutableArray *calendarMonth = [[NSMutableArray alloc]init];//每个月的dayModel数组
    for (int i = 0; i <= months; i++) {
        NSDate *month = [_beginDate dayInTheFollowingMonth:i];
        NSMutableArray *calendarDays = [[NSMutableArray alloc]init];
        [self calculateDaysInPreviousMonthWithDate:month andArray:calendarDays];
        [self calculateDaysInCurrentMonthWithDate:month andArray:calendarDays];
        [self calculateDaysInFollowingMonthWithDate:month andArray:calendarDays];//计算下月份的天数
        [calendarMonth insertObject:calendarDays atIndex:i];
    }
    
    return calendarMonth;
}

#pragma mark - 日历上+当前+下月份的天数
//计算上月份的天数
- (NSMutableArray *)calculateDaysInPreviousMonthWithDate:(NSDate *)date andArray:(NSMutableArray *)array{
    
    NSUInteger weeklyOrdinality = [[date firstDayOfCurrentMonth] weeklyOrdinality];//计算这个的第一天是礼拜几,并转为int型
    NSDate *dayInThePreviousMonth = [date dayInThePreviousMonth];//上一个月的NSDate对象
    NSUInteger daysCount = [dayInThePreviousMonth numberOfDaysInCurrentMonth];//计算上个月有多少天
    NSUInteger partialDaysCount = weeklyOrdinality - 1;//获取上月在这个月的日历上显示的天数
    NSDateComponents *components = [dayInThePreviousMonth YMDComponents];//获取年月日对象
    
    for (NSInteger i = daysCount - partialDaysCount + 1; i < daysCount + 1; ++i) {
        CalendarDay *calendarDay = [CalendarDay calendarDayWithDateComponents:components Day:i];
        calendarDay.style = CellDayTypeEmpty;//不显示
        [array addObject:calendarDay];
    }
    
    return NULL;
}

//计算下月份的天数
- (void)calculateDaysInFollowingMonthWithDate:(NSDate *)date andArray:(NSMutableArray *)array{
    NSUInteger weeklyOrdinality = [[date lastDayOfCurrentMonth] weeklyOrdinality];
    if (weeklyOrdinality == 7) return ;
    
    NSUInteger partialDaysCount = 7 - weeklyOrdinality;
    NSDateComponents *components = [[date dayInTheFollowingMonth] YMDComponents];
    
    for (int i = 1; i < partialDaysCount + 1; ++i) {
        CalendarDay *calendarDay = [CalendarDay calendarDayWithDateComponents:components Day:i];
        calendarDay.style = CellDayTypeEmpty;
        [array addObject:calendarDay];
    }
}

//计算当月的天数
- (void)calculateDaysInCurrentMonthWithDate:(NSDate *)date andArray:(NSMutableArray *)array{
    
    NSUInteger daysCount = [date numberOfDaysInCurrentMonth];//计算这个月有多少天
    NSDateComponents *components = [date YMDComponents];//今天日期的年月日
    
    for (int i = 1; i < daysCount + 1; ++i) {
        CalendarDay *calendarDay = [CalendarDay calendarDayWithDateComponents:components Day:i];
        calendarDay.Week = [[calendarDay date] weekIntValueWithDate];
        [self LunarForSolarYear:calendarDay];
        [self changStyle:calendarDay];
        [array addObject:calendarDay];
    }
}

- (void)changStyle:(CalendarDay *)calendarDay{
    NSDateComponents *calendarToDay  = [_beginDate YMDComponents];//今天
    NSDateComponents *calendarbefore = [_before YMDComponents];//最后一天
    NSDateComponents *calendarSelectBegin = [_select YMDComponents];//默认选择开始的那一天
    NSDateComponents *calendarSelectEnd;
    if (_EndDate)
        calendarSelectEnd = [_EndDate YMDComponents];//默认选择的结束的那一天
    
    
    //被点击选中
    if(calendarSelectBegin.year == calendarDay.Year & calendarSelectBegin.month == calendarDay.Month & calendarSelectBegin.day == calendarDay.Day){
        calendarDay.style = CellDayTypeClick;
        _calendarBeginDay = calendarDay;
        _beginDayAnnotation = _calendarBeginDay.LunarCalendar;
        _calendarBeginDay.Annotation = _calendarBeginDayAnnotation;
    }else if (calendarSelectEnd.year == calendarDay.Year & calendarSelectEnd.month == calendarDay.Month & calendarSelectEnd.day == calendarDay.Day){
        calendarDay.style = CellDayTypeClick;
        _calendarEndDay = calendarDay;
        _endDayAnnotation = _calendarEndDay.LunarCalendar;
        _calendarEndDay.Annotation = _calendarEndDayAnnotation;
    }else{  //没被点击选中
        if (calendarToDay.year >= calendarDay.Year & calendarToDay.month >= calendarDay.Month & calendarToDay.day > calendarDay.Day) //昨天乃至过去的时间设置一个灰度
            calendarDay.style = CellDayTypePast;
        else if (calendarbefore.year <= calendarDay.Year & calendarbefore.month <= calendarDay.Month & calendarbefore.day <= calendarDay.Day) //之后的时间时间段
            calendarDay.style = CellDayTypeFutur;
        else{ //需要正常显示的时间段
            if (calendarDay.Week == 1 || calendarDay.Week == 7) //周末
                calendarDay.style = CellDayTypeWeek;
            else //工作日
                calendarDay.style = CellDayTypeFutur;
        }
    }
    
    //===================================
    //这里来判断节日
    if (calendarToDay.year == calendarDay.Year && calendarToDay.month == calendarDay.Month && calendarToDay.day == calendarDay.Day) { //今天
        calendarDay.Holidays = @"今天";
    }else if(calendarToDay.year == calendarDay.Year && calendarToDay.month == calendarDay.Month && calendarToDay.day - calendarDay.Day == -1){  //明天
        calendarDay.Holidays = @"明天";
    }else if(calendarToDay.year == calendarDay.Year && calendarToDay.month == calendarDay.Month && calendarToDay.day - calendarDay.Day == -2){ //后天
        calendarDay.Holidays = @"后天";
    }else if (calendarDay.Month == 1 && calendarDay.Day == 1){ //1.1元旦
        calendarDay.Holidays = @"元旦";
    }else if (calendarDay.Month == 2 && calendarDay.Day == 14){ //2.14情人节
        calendarDay.Holidays = @"情人节";
    }else if (calendarDay.Month == 3 && calendarDay.Day == 8){ //3.8妇女节
        calendarDay.Holidays = @"妇女节";
    }else if (calendarDay.Month == 5 && calendarDay.Day == 1){ //5.1劳动节
        calendarDay.Holidays = @"劳动节";
    }else if (calendarDay.Month == 6 && calendarDay.Day == 1){ //6.1儿童节
        calendarDay.Holidays = @"儿童节";
    }else if (calendarDay.Month == 8 && calendarDay.Day == 1){ //8.1建军节
        calendarDay.Holidays = @"建军节";
    }else if (calendarDay.Month == 9 && calendarDay.Day == 10){ //9.10教师节
        calendarDay.Holidays = @"教师节";
    }else if (calendarDay.Month == 10 && calendarDay.Day == 1){ //10.1国庆节
        calendarDay.Holidays = @"国庆节";
    }else if (calendarDay.Month == 11 && calendarDay.Day == 1){ //11.1植树节
        calendarDay.Holidays = @"植树节";
    }else if (calendarDay.Month == 11 && calendarDay.Day == 11){//11.11光棍节
        calendarDay.Holidays = @"光棍节";
    }else{
        //            这里写其它的节日
    }
    
}

#pragma mark - 农历转换函数

-(void)LunarForSolarYear:(CalendarDay *)calendarDay{
    NSString *solarYear = [self LunarForSolarYear:(int)calendarDay.Year Month:(int)calendarDay.Month Day:(int)calendarDay.Day];
    
    NSArray *solarYear_arr= [solarYear componentsSeparatedByString:@"-"];
    
    if([solarYear_arr[0]isEqualToString:@"正"] && [solarYear_arr[1]isEqualToString:@"初一"]){
        //正月初一：春节
        calendarDay.Holidays = @"春节";
    }else if([solarYear_arr[0]isEqualToString:@"正"] && [solarYear_arr[1]isEqualToString:@"十五"]){
        //正月十五：元宵节
        calendarDay.Holidays = @"元宵";
    }else if([solarYear_arr[0]isEqualToString:@"二"] && [solarYear_arr[1]isEqualToString:@"初二"]){
        //二月初二：春龙节(龙抬头)
        calendarDay.Holidays = @"龙抬头";
    }else if([solarYear_arr[0]isEqualToString:@"五"] && [solarYear_arr[1]isEqualToString:@"初五"]){
        //五月初五：端午节
        calendarDay.Holidays = @"端午";
    }else if([solarYear_arr[0]isEqualToString:@"七"] && [solarYear_arr[1]isEqualToString:@"初七"]){
        //七月初七：七夕情人节
        calendarDay.Holidays = @"七夕";
    }else if([solarYear_arr[0]isEqualToString:@"八"] && [solarYear_arr[1]isEqualToString:@"十五"]){
        //八月十五：中秋节
        calendarDay.Holidays = @"中秋";
    }else if([solarYear_arr[0]isEqualToString:@"九"] && [solarYear_arr[1]isEqualToString:@"初九"]){
        //九月初九：重阳节、中国老年节（义务助老活动日）
        calendarDay.Holidays = @"重阳";
    }else if([solarYear_arr[0]isEqualToString:@"腊"] && [solarYear_arr[1]isEqualToString:@"初八"]){
        //腊月初八：腊八节
        calendarDay.Holidays = @"腊八";
    }else if([solarYear_arr[0]isEqualToString:@"腊"] && [solarYear_arr[1]isEqualToString:@"二十四"]){
        //腊月二十四 小年
        calendarDay.Holidays = @"小年";
    }else if([solarYear_arr[0]isEqualToString:@"腊"] && [solarYear_arr[1]isEqualToString:@"三十"]){
        //腊月三十（小月二十九）：除夕
        calendarDay.Holidays = @"除夕";
    }
    
    calendarDay.LunarCalendar = solarYear_arr[1];
    
    
}

-(NSString *)LunarForSolarYear:(int)wCurYear Month:(int)wCurMonth Day:(int)wCurDay{
    //农历日期名
    NSArray *cDayName =  [NSArray arrayWithObjects:@"*",@"初一",@"初二",@"初三",@"初四",@"初五",@"初六",@"初七",@"初八",@"初九",@"初十",@"十一",@"十二",@"十三",@"十四",@"十五",@"十六",@"十七",@"十八",@"十九",@"二十",@"廿一",@"廿二",@"廿三",@"廿四",@"廿五",@"廿六",@"廿七",@"廿八",@"廿九",@"三十",nil];
    //农历月份名
    NSArray *cMonName =  [NSArray arrayWithObjects:@"*",@"正",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"十",@"十一",@"腊",nil];
    //公历每月前面的天数
    const int wMonthAdd[12] = {0,31,59,90,120,151,181,212,243,273,304,334};
    //农历数据
    const int wNongliData[100] = {2635,333387,1701,1748,267701,694,2391,133423,1175,396438
        ,3402,3749,331177,1453,694,201326,2350,465197,3221,3402
        ,400202,2901,1386,267611,605,2349,137515,2709,464533,1738
        ,2901,330421,1242,2651,199255,1323,529706,3733,1706,398762
        ,2741,1206,267438,2647,1318,204070,3477,461653,1386,2413
        ,330077,1197,2637,268877,3365,531109,2900,2922,398042,2395
        ,1179,267415,2635,661067,1701,1748,398772,2742,2391,330031
        ,1175,1611,200010,3749,527717,1452,2742,332397,2350,3222
        ,268949,3402,3493,133973,1386,464219,605,2349,334123,2709
        ,2890,267946,2773,592565,1210,2651,395863,1323,2707,265877};
    
    static int nTheDate,nIsEnd,m,k,n,i,nBit;
    
    //计算到初始时间1921年2月8日的天数：1921-2-8(正月初一)
    nTheDate = (wCurYear - 1921) * 365 + (wCurYear - 1921) / 4 + wCurDay + wMonthAdd[wCurMonth - 1] - 38;
    
    if((!(wCurYear % 4)) && (wCurMonth > 2))
        nTheDate = nTheDate + 1;
    
    //计算农历天干、地支、月、日
    nIsEnd = 0;
    m = 0;
    while(nIsEnd != 1){
        if(wNongliData[m] < 4095)
            k = 11;
        else
            k = 12;
        n = k;
        while(n>=0){
            //获取wNongliData(m)的第n个二进制位的值
            nBit = wNongliData[m];
            for(i=1;i<n+1;i++)
                nBit = nBit/2;
            
            nBit = nBit % 2;
            
            if (nTheDate <= (29 + nBit)){
                nIsEnd = 1;
                break;
            }
            
            nTheDate = nTheDate - 29 - nBit;
            n = n - 1;
        }
        if(nIsEnd)
            break;
        m = m + 1;
    }
    wCurYear = 1921 + m;
    wCurMonth = k - n + 1;
    wCurDay = nTheDate;
    if (k == 12){
        if (wCurMonth == wNongliData[m] / 65536 + 1)
            wCurMonth = 1 - wCurMonth;
        else if (wCurMonth > wNongliData[m] / 65536 + 1)
            wCurMonth = wCurMonth - 1;
    }
    
    //生成农历月
    NSString *szNongliMonth;
    if (wCurMonth < 1)
        szNongliMonth = [NSString stringWithFormat:@"闰%@",(NSString *)[cMonName objectAtIndex:-1 * wCurMonth]];
    else
        szNongliMonth = (NSString *)[cMonName objectAtIndex:wCurMonth];
    
    //生成农历日
    NSString *szNongliDay = [cDayName objectAtIndex:wCurDay];
    //合并
    NSString *lunarDate = [NSString stringWithFormat:@"%@-%@",szNongliMonth,szNongliDay];
    
    return lunarDate;
}

- (void)selectLogic:(CalendarDay *)day Completion:(Completions)completion{
    
    if (day.style == CellDayTypeClick)
        return;
    //周末
    if (_calendarBeginDay.Week == 1 || _calendarBeginDay.Week == 7)
        _calendarBeginDay.style = CellDayTypeWeek;
    else
        _calendarBeginDay.style = CellDayTypeFutur;
    //周末
    if (_calendarEndDay.Week == 1 || _calendarEndDay.Week == 7)
        _calendarEndDay.style = CellDayTypeWeek;
    else
        _calendarEndDay.style = CellDayTypeFutur;
    
    day.style = CellDayTypeClick;
    if (_EndDate) {
        if (_calendarBeginDay && _calendarEndDay) {
            [self Annotation:day TempDay:_calendarBeginDay Annotation:_beginDayAnnotation];
            [self NullAnnotation];
            _calendarBeginDay = day;
        }else{
            if (day.Month == _calendarBeginDay.Month ) {
                if (day.Day < _calendarBeginDay.Day) {
                    [self Annotation:day TempDay:_calendarBeginDay Annotation:_calendarBeginDay.LunarCalendar];
                    [self NullAnnotation];
                    _calendarBeginDay = day;
                }else{
                    [self Annotation:day TempDay:_calendarEndDay Annotation:_endDayAnnotation];
                    _calendarBeginDay.style = CellDayTypeClick;
                    _calendarEndDay = day;
                }
            }else if (day.Month < _calendarBeginDay.Month){
                [self Annotation:day TempDay:_calendarBeginDay Annotation:_beginDayAnnotation];
                [self NullAnnotation];[self NullAnnotation];
                _calendarBeginDay = day;
            }else if (day.Month > _calendarEndDay.Month){
                [self Annotation:day TempDay:_calendarEndDay Annotation:_endDayAnnotation];
                _calendarBeginDay.style = CellDayTypeClick;
                _calendarEndDay =day;
            }
        }
    }else{
        [self Annotation:day TempDay:_calendarBeginDay Annotation:_beginDayAnnotation];
        _calendarBeginDay = day;
    }
    
    BOOL bol = YES;
    if (_OptionDayNumber > 1) {
        if (!_calendarBeginDay || !_calendarEndDay)
            bol = NO;
    }
    completion(bol);
}

-(void)Annotation:(CalendarDay *)CheckDay TempDay:(CalendarDay *)tempDay Annotation:(NSString *)annotation{
    CheckDay.Annotation =  tempDay ? tempDay.Annotation : annotation;
    tempDay.Annotation = nil;
    tempDay.LunarCalendar = annotation;
    annotation = CheckDay.LunarCalendar;
    tempDay = CheckDay;
}

-(void)NullAnnotation{
    NSString *temp = _calendarEndDay ? _calendarEndDay.Annotation : _calendarEndDayAnnotation;
    _calendarEndDay.Annotation = nil;
    _calendarEndDay.LunarCalendar = _endDayAnnotation;
    _endDayAnnotation = temp;
    _calendarEndDay = nil;
}


@end
