//
//  CalendarCollectionViewCell.m
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

#import "CalendarCollectionViewCell.h"
#import "Config.h"

@interface CalendarCollectionViewCell()

@property (nonatomic, strong) UIImageView *selectedImageView;;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *lunarCalendar;

@end

@implementation CalendarCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _selectedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 15, self.bounds.size.width - 10, self.bounds.size.width - 10)];
        _selectedImageView.layer.cornerRadius = _selectedImageView.frame.size.width / 2;
        _selectedImageView.backgroundColor = RGBA(26, 168, 186, 1);
        [self addSubview:_selectedImageView];
        
        //日期
        _dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 15, self.bounds.size.width, self.bounds.size.width - 10)];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:_dateLabel];
        
        //农历
        _lunarCalendar = [[UILabel alloc]initWithFrame:CGRectMake(0, self.bounds.size.height - 15, self.bounds.size.width, 13)];
        _lunarCalendar.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_lunarCalendar];
        
    }
    return self;
}

-(void)setData:(CalendarDay *)calendarDay{
    _lunarCalendar.font = [UIFont boldSystemFontOfSize:10];
    _lunarCalendar.textColor = [UIColor lightGrayColor];
    switch (calendarDay.style) {
        case CellDayTypeEmpty://不显示
            [self hidden_YES];
            break;
            
        case CellDayTypePast://过去的日期
            [self hidden_NO];
            
            if (calendarDay.Holidays)
                _dateLabel.text = calendarDay.Holidays;
            else
                _dateLabel.text = [NSString stringWithFormat:@"%d",(int)calendarDay.Day];
            
            _dateLabel.textColor = [UIColor lightGrayColor];
            _selectedImageView.hidden = YES;
            break;
            
        case CellDayTypeFutur://将来的日期
            [self hidden_NO];
            
            if (calendarDay.Holidays) {
                _dateLabel.text = calendarDay.Holidays;
                _dateLabel.textColor = [UIColor orangeColor];
            }else{
                _dateLabel.text = [NSString stringWithFormat:@"%d",(int)calendarDay.Day];
                _dateLabel.textColor = RGBA(26, 168, 186, 1);
            }
            
            _selectedImageView.hidden = YES;
            break;
            
        case CellDayTypeWeek://周末
            [self hidden_NO];
            
            if (calendarDay.Holidays) {
                _dateLabel.text = calendarDay.Holidays;
                _dateLabel.textColor = [UIColor orangeColor];
            }else{
                _dateLabel.text = [NSString stringWithFormat:@"%d",(int)calendarDay.Day];
                _dateLabel.textColor = [UIColor redColor];
            }
           
            _selectedImageView.hidden = YES;
            break;
            
        case CellDayTypeClick://被点击的日期
            [self hidden_NO];
            _dateLabel.text = [NSString stringWithFormat:@"%d",(int)calendarDay.Day];
            _dateLabel.textColor = [UIColor whiteColor];
            
            _lunarCalendar.font = [UIFont boldSystemFontOfSize:15];
            _lunarCalendar.textColor = RGBA(26, 168, 186, 1);
            
            _selectedImageView.hidden = NO;
            break;
            
        default:
            break;
    }
    _lunarCalendar.text = calendarDay.LunarCalendar;
    if (calendarDay.Annotation)
        _lunarCalendar.text = calendarDay.Annotation;
}

- (void)hidden_YES{
    _dateLabel.hidden = YES;
    _lunarCalendar.hidden = YES;
    _selectedImageView.hidden = YES;
}

- (void)hidden_NO{
    _dateLabel.hidden = NO;
    _lunarCalendar.hidden = NO;
}


@end
