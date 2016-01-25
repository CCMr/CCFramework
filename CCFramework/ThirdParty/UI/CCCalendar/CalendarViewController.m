//
//  CalendarViewController.m
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

#import "CalendarViewController.h"
#import "CalendarFlowLayout.h"
#import "CalendarCollectionViewCell.h"
#import "CalendarHeaderView.h"
#import "CalendarLogic.h"
#import "UIButton+BUIButton.h"
#import "UIControl+BUIControl.h"
#import "NSDate+BNSDate.h"
#import "Config.h"

static NSString *CellIdentifier = @"CalendarCell";
static NSString *CellHeaderIdentifier = @"CalendarHeader";

@interface CalendarViewController()

@property (nonatomic, strong) UICollectionView *calendarCollectionView;
@property (nonatomic, strong) NSMutableArray *calendarMonth;
@property (nonatomic, strong) NSString *toDate;
@property (nonatomic, strong) CalendarLogic *calendarLogic;

@property (nonatomic, assign) int dayNumber;
@property (nonatomic, assign) int selectdDayNumber;

@end

@implementation CalendarViewController

-(id)initWithToDay:(int)day TitleName:(NSString *)titleName{
    if (self = [super init]) {
        _optionDayNumber = 1;
        _dayNumber = day;
        self.title = titleName;
        
        [self initUI];
    }
    return self;
}


-(id)initWithToDate:(int )day ToDateForString:(NSString *)todate{
    if (self = [super init]) {
        _optionDayNumber = 1;
        _dayNumber = day;
        _toDate = todate;
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    [self initNavigation];
    [self initControl];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)initNavigation
{
    UIButton *NavLeftBtn = [UIButton buttonWith];
    [NavLeftBtn setImage:CCResourceImage(@"returns") forState:UIControlStateNormal];
    NavLeftBtn.frame = CGRectMake(0, 0, 15, 20);
    __weak typeof (self)weakSelf = self;
    [NavLeftBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    [self.navigationItem setLeftBarButtonItem:[[[UIBarButtonItem alloc]init] initWithCustomView:NavLeftBtn]];
    
}

-(void)initControl{
    _calendarLogic = [[CalendarLogic alloc] init];
    
    CalendarFlowLayout *layout = [CalendarFlowLayout new];
    _calendarCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    [_calendarCollectionView registerClass:[CalendarCollectionViewCell class] forCellWithReuseIdentifier:CellIdentifier];
    [_calendarCollectionView registerClass:[CalendarHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:CellHeaderIdentifier];
    _calendarCollectionView.delegate = self;
    _calendarCollectionView.dataSource = self;
    _calendarCollectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_calendarCollectionView];
    
    if (_IsTips)
        [self InitTipsControl];
}

-(void)initLoadData{
    NSDate *selectdate  = [NSDate date];
    if (_beginDate)
        selectdate = _beginDate;
    
    if (_toDate)
        selectdate = [selectdate dateFromString:_toDate];

    
    if (_beginDate && _endDate)
        _calendarMonth = [_calendarLogic reloadCalendarView:[NSDate date] BeginDate:_beginDate EndDate:_endDate NeedDays:_dayNumber];
    else
        _calendarMonth = [_calendarLogic reloadCalendarView:[NSDate date] selectDate:selectdate needDays:_dayNumber];
    [_calendarLogic setOptionDayNumber:_optionDayNumber];
    [_calendarCollectionView reloadData];
    
    NSUInteger Year = [[_beginDate YMDComponents] year];
    NSUInteger Month = [[_beginDate YMDComponents] month];
    
    __block NSUInteger index = 0;
    [_calendarMonth enumerateObjectsUsingBlock:^(id obja, NSUInteger idxa, BOOL *stop) {
        [obja enumerateObjectsUsingBlock:^(id objb, NSUInteger idxb, BOOL *stop) {
            CalendarDay *d = objb;
            if (d.Year == Year && d.Month == Month)
                index = idxa;
        }];
    }];
    
    [_calendarCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:index] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
}

//页面显示完成
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_IsTips) {
        [self.view viewWithTag:123456789].hidden = NO;
        [self.view viewWithTag:987654321].hidden = NO;
    }
    [self initLoadData];
}

//页面消失的时候
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view viewWithTag:123456789].hidden = YES;
    [self.view viewWithTag:987654321].hidden = YES;
}

#pragma mark - 底部提示语
-(void)InitTipsControl{
    CGFloat x = 75;
    for (int i = 0; i < _optionDayNumber; i++) {
        UIView *tipsView = [[UIView alloc] initWithFrame:CGRectMake(x, winsize.height - 100, winsize.width - 150, 70)];
        tipsView.layer.cornerRadius = 5;
        tipsView.backgroundColor = cc_ColorRGBA(0, 0, 0, .7);
        tipsView.tag = i == 0 ? 123456789 : 987654321;
        tipsView.hidden = YES;
        [self.view addSubview:tipsView];
        
        UILabel *tipsTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, tipsView.frame.size.width, 30)];
        tipsTitle.textAlignment = NSTextAlignmentCenter;
        tipsTitle.textColor = [UIColor whiteColor];
        tipsTitle.tag = i == 0 ? 66666 : 77777;
        [tipsView addSubview:tipsTitle];
        
        UILabel *tipsContent = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, tipsView.frame.size.width, 20)];
        tipsContent.textAlignment = NSTextAlignmentCenter;
        tipsContent.textColor = [UIColor whiteColor];
        tipsContent.text = @"*注:所选日期为目的地日期";
        tipsContent.tag = i == 0 ? 99999 : 88888;
        [tipsView addSubview:tipsContent];
        x = -winsize.width;
    }
}

#pragma mark - 设置提示语
-(void)setBeinTips:(NSString *)beinTips{
    ((UILabel *)[self.view viewWithTag:66666]).text = beinTips;
}

-(void)setEndTips:(NSString *)endTips{
    ((UILabel *)[self.view viewWithTag:77777]).text = endTips;
}

-(void)setBeginAnnotation:(NSString *)beginAnnotation{
    [_calendarLogic setCalendarBeginDayAnnotation:beginAnnotation];
}

-(void)setEndAnnotation:(NSString *)endAnnotation{
   [_calendarLogic setCalendarEndDayAnnotation:endAnnotation];
}

#pragma mark - 设置开始时间与结束时间
-(void)setBeginDate:(NSDate *)beginDate{
    _beginDate = beginDate;
}

-(void)setEndDate:(NSDate *)endDate{
    _endDate = endDate;
}

-(void)setSelectCalendarDay:(NSString *)dates{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (NSArray *dayAray in _calendarMonth) {
            for (CalendarDay *day in dayAray) {
                NSString *dayDate = [day.date timeFormat:@"yyyy-MM-dd"];
                if ([dayDate isEqualToString:dates]) {
                    [_calendarLogic selectLogic:day Completion:^(BOOL isBol) {
                    }];
                    continue;
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [_calendarCollectionView reloadData];
        });
    });
}

#pragma mark - CollectionView代理方法
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return _calendarMonth.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_calendarMonth[section] count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader){
        CalendarDay *model = [_calendarMonth[indexPath.section] objectAtIndex:15];
        CalendarHeaderView *monthHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:CellHeaderIdentifier forIndexPath:indexPath];
        [monthHeader setCurrentDate:[NSString stringWithFormat:@"%d年 %d月",(int)model.Year,(int)model.Month]];
        reusableview = monthHeader;
    }
    return reusableview;
}

//选中处理事件
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    CalendarDay *model = _calendarMonth[indexPath.section][indexPath.row];
    if (model.style == CellDayTypeFutur || model.style == CellDayTypeWeek || model.style == CellDayTypeClick) {
        [_calendarLogic selectLogic:model Completion:^(BOOL isBol) {
            if (!isBol){
                _selectdDayNumber++;
                if (_selectdDayNumber == _optionDayNumber)
                    _selectdDayNumber--;
            }else
                _selectdDayNumber++;
            
            if (_optionDayNumber > 1) {
                if (_selectdDayNumber > 0)
                    [self ToggleView];
            }
            
            if (_selectdDayNumber == _optionDayNumber)
                [self performSelector:@selector(PushView) withObject:nil afterDelay:.5];
            
            [collectionView reloadData];
        }];
        
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CalendarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setData:_calendarMonth[indexPath.section][indexPath.row]];
    return cell;
}

#pragma mark - 页面处理事件
//延迟跳转
-(void)PushView{
    if (block){
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:@{@"BeginDate":_calendarLogic.calendarBeginDay.date}];
        if (_optionDayNumber == 2)
            [dic setObject:_calendarLogic.calendarEndDay.date forKey:@"EndDate"];
        block(dic);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//切换提示语
-(void)ToggleView{
    [UIView animateWithDuration:.3 animations:^{
        [self.view viewWithTag:123456789].frame  = CGRectMake(winsize.width, winsize.height - 100, winsize.width - 150, 70);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.3 animations:^{
            [self.view viewWithTag:987654321].frame = CGRectMake(75, winsize.height - 100, winsize.width - 150, 70);
            [self.view viewWithTag:123456789].hidden = YES;
        }];
    }];
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)didCalendarBlock:(CalendarBlock)calendar{
    block = calendar;
}

-(void)setOptionDayNumber:(int)optionDayNumber{
    _optionDayNumber = optionDayNumber;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
