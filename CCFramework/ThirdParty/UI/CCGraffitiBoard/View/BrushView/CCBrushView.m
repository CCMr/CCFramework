//
//  CCBrushView.m
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

#import "CCBrushView.h"
#import "UIButton+BUIButton.h"
#import "UIView+BUIView.h"
#import "UIControl+BUIControl.h"
#import "CCBarSlider.h"
#import "config.h"

#define kCCBottomToolHeight 44

typedef void (^CompleteSelectedType)(float lineSize, CCBrushType type);

@interface CCBrushView () <UITableViewDataSource, UITableViewDelegate>

/**
 *  @author CC, 2015-12-19
 *  
 *  @brief  画笔小大滑块
 */
@property(nonatomic, weak) CCBarSlider *brushSlider;

/**
 *  @author CC, 2015-12-19
 *  
 *  @brief  完成回调函数
 */
@property(nonatomic, strong) CompleteSelectedType completeSelectedType;

/**
 *  @author CC, 2015-12-19
 *  
 *  @brief  画笔类型
 */
@property(nonatomic, assign) CCBrushType type;

@end

@implementation CCBrushView

- (instancetype)init
{
    if (self = [super init]) {
        [self InitControl];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self InitControl];
    }
    return self;
}

/**
 *  @author CC, 2015-12-17
 *  
 *  @brief  初始化控件
 */
- (void)InitControl
{
    UITableView *brushTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    brushTableView.showsHorizontalScrollIndicator = NO;
    brushTableView.showsVerticalScrollIndicator = NO;
    brushTableView.delegate = self;
    brushTableView.dataSource = self;
    [self addSubview:brushTableView];
    
    [self InitBottomTool];
}

/**
 *  @author CC, 2015-12-17
 *  
 *  @brief  初始化底部菜单
 */
- (void)InitBottomTool
{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - kCCBottomToolHeight, CGRectGetWidth(self.bounds), kCCBottomToolHeight)];
    bottomView.opaque = NO;
    bottomView.backgroundColor = nil;
    bottomView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth);
    bottomView.backgroundColor = [UIColor colorWithWhite:0.667f alpha:0.667f];
    [self addSubview:bottomView];
    
    @weakify(self);
    
    UIButton *barMinusButton = [UIButton buttonWithBackgroundImageFrame:@"" Frame:CGRectMake(0, 0, 44, bottomView.height)];
    [barMinusButton handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        @strongify(self);
        self.brushSlider.currentValue = self.brushSlider.currentValue - 1;
    }];
    [bottomView addSubview:barMinusButton];
    
    CCBarSlider *brushSlider = [[CCBarSlider alloc] initWithFrame:CGRectMake(barMinusButton.width, 0, bottomView.width - (44 * 3), bottomView.height)];
    brushSlider.currentValue = 9;
    [brushSlider handleControlEvent:UIControlEventValueChanged withBlock:^(CCBarSlider *sender) {
        @strongify(self);
        self.currentValue = sender.currentValue;
    }];
    [bottomView addSubview:self.brushSlider = brushSlider];
    
    UIButton *barPlusButton = [UIButton buttonWithBackgroundImageFrame:@"" Frame:CGRectMake(brushSlider.x + brushSlider.width, 0, 44, bottomView.height)];
    [barPlusButton handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        @strongify(self);
        self.brushSlider.currentValue = self.brushSlider.currentValue + 1;
    }];
    [bottomView addSubview:barPlusButton];
    
    UIButton *dismissButton = [UIButton buttonWithBackgroundImageFrame:@"" Frame:CGRectMake(bottomView.width - 44, 0, 44, 44)];
    dismissButton.backgroundColor = [UIColor redColor];
    [dismissButton handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        @strongify(self);
        
        if (self.completeSelectedType)
            self.completeSelectedType(self.currentValue,self.type);
        
        CGFloat duration = 0.15;
        [UIView animateWithDuration:duration + 0.1 animations:^{
            self.alpha = 1;
        } completion:^(BOOL finished) {
            self.alpha = 0;
            self.backgroundColor = [UIColor clearColor];
            [self removeFromSuperview];
        }];
    }];
    [bottomView addSubview:dismissButton];
}

- (void)setCurrentValue:(float)currentValue
{
    _currentValue = currentValue;
    self.brushSlider.currentValue = currentValue;
}

- (void)show
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"123");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellIdentifier";
    
    UITableViewCell *Cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!Cell) {
        Cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        Cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    Cell.textLabel.text = @"123";
    
    return Cell;
}

- (void)didSelectBrush:(void (^)(float, CCBrushType))block
{
    _completeSelectedType = block;
}

@end
