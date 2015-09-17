//
//  CalendarViewController.h
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

#import <UIKit/UIKit.h>
@class CalendarDay;

typedef void (^CalendarBlock)(NSDictionary *calendarDay);

@interface CalendarViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate>{
    CalendarBlock block;
}

@property (nonatomic, assign) int optionDayNumber; //多选日期； 默认选择一个日期。
@property (nonatomic, assign) NSDate *beginDate; //开始时间
@property (nonatomic, assign) NSDate *endDate; //结束日期
@property (nonatomic, assign) NSString *beginAnnotation; //开始时间注释
@property (nonatomic, assign) NSString *endAnnotation; //结束时间注释
@property (nonatomic, assign) BOOL IsTips; //是否启用提示语
@property (nonatomic, assign) NSString *beinTips; //开始提示语
@property (nonatomic, assign) NSString *endTips;  //结束提示语


-(id)initWithToDay:(int)day TitleName:(NSString *)titleName;
-(id)initWithToDate:(int )day ToDateForString:(NSString *)todate;

-(void)didCalendarBlock:(CalendarBlock)calendar;

@end
