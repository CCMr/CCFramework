//
//  CalendarHeaderView.m
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

#import "CalendarHeaderView.h"
#import "Config.h"

@implementation CalendarHeaderView{
    UILabel *masterLabel;
}

-(instancetype)init{
    if (self = [super init]) {
        [self InitControl];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self InitControl];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        [self InitControl];
    }
    return self;
}

-(void)InitControl{
    self.clipsToBounds = YES;
    //月份
    masterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, winsize.width, 40)];
    [masterLabel setBackgroundColor:[UIColor clearColor]];
    [masterLabel setTextAlignment:NSTextAlignmentCenter];
    [masterLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:17.0f]];
    masterLabel.textColor = RGBA(26, 168, 186, 1);
    masterLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.8];
    [self addSubview:masterLabel];
    
    NSArray *array = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
    CGFloat width = winsize.width / 7;
    for (int i = 0; i < array.count; i++) {
        UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(i * width, 40, width, 25)];
        dayLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.6];
        dayLabel.textAlignment = NSTextAlignmentCenter;
        dayLabel.textColor = RGBA(26, 168, 186, 1);
        if (i == 0 || i == 6)
            dayLabel.textColor = [UIColor redColor];
        dayLabel.text = array[i];
        [self addSubview:dayLabel];
    }
}

-(void)setCurrentDate:(NSString *)currentDate{
    masterLabel.text = currentDate;
}

@end
