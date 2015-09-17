//
//  CCTimePicker.m
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

#import "CCTimePicker.h"
#import "CCActionSheet.h"
#import "Config.h"
#import "UIControl+BUIControl.h"
#import "UIButton+BUIButton.h"
#import "UIActionSheet+BUIActionSheet.h"

@interface CCTimePicker()

@property (nonatomic, strong) NSDate *selectedDate;

@property (nonatomic, copy) Completion completion;

@end

@implementation CCTimePicker

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  IOS8以下自定义显示
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
-(UIView *)SheetDate{
    UIView *views = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winsize.width, 270)];
    views.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1];
    
    UIDatePicker *dataPickView = [[UIDatePicker alloc] init];
    dataPickView.frame = CGRectMake(0, 0, views.frame.size.width, 200);
    dataPickView.layer.cornerRadius = 5;
    dataPickView.layer.masksToBounds = YES;
    [dataPickView setLocale:[NSLocale localeWithLocaleIdentifier:@"zh-CN"]];
    //只显示日期
    dataPickView.datePickerMode=UIDatePickerModeDate;
    dataPickView.backgroundColor = [UIColor whiteColor];
    [dataPickView handleControlEvent:UIControlEventValueChanged withBlock:^(id sender) {
        _selectedDate = [sender date];
        if (!_selectedDate)
            _selectedDate = [NSDate date];
    }];
    [views addSubview:dataPickView];
    
    UIButton *Canceled = [UIButton buttonWithBackgroundImage:@"endbutton"];
    Canceled.frame = CGRectMake(15, 220, 135, 40);
    [Canceled setTitle:@"取消" forState:UIControlStateNormal];
    [Canceled handleControlEvent:UIControlEventTouchDown withBlock:^(id sender) {
        [((UIActionSheet *)views.superview) hide:0];
    }];
    [views addSubview:Canceled];
    
    UIButton *definite = [UIButton buttonWithBackgroundImage:@"button"];
    definite.frame = CGRectMake(165, 220, 135, 40);
    [definite setTitle:@"确定" forState:UIControlStateNormal];
    [definite handleControlEvent:UIControlEventTouchDown withBlock:^(id sender) {
        [((UIActionSheet *)views.superview) hide:1];
    }];
    [views addSubview:definite];
    
    return views;
}

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  启动时间选择器
 *
 *  @since 1.0
 */
- (void)startTimePick
{
    _selectedDate = [NSDate date];
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        UIAlertController *alers= [UIAlertController alertControllerWithTitle:@"\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIDatePicker *dataPickView = [[UIDatePicker alloc] init];
        dataPickView.frame = CGRectMake(0, 0, alers.view.frame.size.width - 17, 210);
        dataPickView.layer.cornerRadius = 5;
        dataPickView.layer.masksToBounds = YES;
        //只显示日期
        dataPickView.datePickerMode = UIDatePickerModeDate;
        dataPickView.backgroundColor = [UIColor whiteColor];
        dataPickView.alpha = .7;
        [dataPickView handleControlEvent:UIControlEventValueChanged withBlock:^(id sender) {
            _selectedDate = [sender date];
            if (!_selectedDate)
                _selectedDate = [NSDate date];
        }];
        [alers.view addSubview:dataPickView];
        [alers addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if(_selectedDate){
                if (![[_selectedDate earlierDate:[NSDate date]] isEqualToDate:_selectedDate]) {
                    _completion(_selectedDate);
                }else{//小于当前时间
                    _completion(_selectedDate);
                }
            }
        }]];
        
        [alers addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        
        [UIView animateWithDuration:0.2 animations:^{
            [self presentViewController:alers animated:YES completion:nil];
        }];
    }else{
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithContentView:[self SheetDate]];
        [sheet showInView:self.view withCompletionHandler:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                if (_selectedDate) {
                    if (![[_selectedDate earlierDate:[NSDate date]] isEqualToDate:_selectedDate]) {
                        _completion(_selectedDate);
                    }else{//小于当前时间
                        _completion(_selectedDate);
                    }
                }
            }
        }];
        [sheet showInView:self.view];
    }
}

@end
