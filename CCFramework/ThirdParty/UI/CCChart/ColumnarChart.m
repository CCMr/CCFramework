//
//  ColumnarChart.m
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

#import "ColumnarChart.h"
#import "UIControl+Additions.h"
#import "UIButton+Additions.h"

@implementation ColumnarChart
@synthesize horizontalArray,DataArray;

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    int maxIndex = [self getMaxIndex];
    int DatamaxMoney = [DataArray[maxIndex] intValue];
    int maxMoney = 100000;
    int remainder = 10000;
    NSString *digit = @"万";
    if (DatamaxMoney < maxMoney){
        maxMoney = 1000000;
    }else if (DatamaxMoney < 1000000){
        maxMoney = 10000000;
        digit = @"百万";
        remainder = 100000;
    }else{
        maxMoney = 100000000;
        digit = @"亿";
        remainder = 1000000;
    }
    
    float y = self.frame.size.height - 20,x = 35,w = 20 + (self.frame.size.width - 50 - horizontalArray.count * 20) / horizontalArray.count;
    for (int i = 0; i < 5; i++) {
        UILabel *VerticalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, 30, 10)];
        VerticalLabel.font = [UIFont systemFontOfSize:10];
        VerticalLabel.textColor = [UIColor darkGrayColor];
        VerticalLabel.backgroundColor = [UIColor clearColor];
        VerticalLabel.text = [NSString stringWithFormat:@"%d%@",((maxMoney / 4) * i) / remainder,digit];
        VerticalLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:VerticalLabel];
        y -= 10 + (self.frame.size.height - 50) / 4;
    }
    
    [self addLine:x tox:x y:0 toY:self.frame.size.height-15];
    
    [self addLine:x tox:self.frame.size.width - 20 y:self.frame.size.height-15 toY:self.frame.size.height-15];
    
    for (int i = 0; i < horizontalArray.count; i++) {
        UILabel *horizontalLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, self.frame.size.height - 10, 20, 10)];
        horizontalLabel.font = [UIFont systemFontOfSize:10];
        horizontalLabel.textColor = [UIColor darkGrayColor];
        horizontalLabel.backgroundColor = [UIColor clearColor];
        horizontalLabel.text = horizontalArray[i];
        horizontalLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:horizontalLabel];
        x+= w;
    }
    
    x = 40;
    
    float h = self.frame.size.height - 15;
    for (int i = 0; i < DataArray.count; i++) {
        
        CGFloat y = [DataArray[i] integerValue] * h / [DataArray[maxIndex] integerValue];
        y = isnan(y) ? 0 : y;
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(x, h - y, 10, y)];
        view.backgroundColor = [UIColor colorWithRed:50/255.0 green:143/255.0 blue:222/255.0 alpha:1];
        view.layer.shadowColor= [UIColor blackColor].CGColor;
        view.layer.shadowOpacity = 0.2;
        view.layer.shadowOffset =CGSizeMake(0.0, 1.0);
        view.tag = i+1;
        [self addSubview:view];
        
        UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(x- 20, h - y - 15, 50, 10)];
        contentLabel.font = [UIFont systemFontOfSize:8];
        contentLabel.textAlignment = NSTextAlignmentCenter;
        contentLabel.text = [DataArray objectAtIndex:i]; //[CommonUtils NumberFormatter:[DataArray objectAtIndex:i]];
        contentLabel.textColor = [UIColor darkGrayColor];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.hidden = YES;
        [self addSubview:contentLabel];

        
        UIButton *btn = [UIButton buttonWith];
        btn.frame = CGRectMake(x-7, 0, w, self.frame.size.height - 15);
        btn.tag = i+1;
        [btn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
            if (lastTapView) {
                lastTapView.backgroundColor = [UIColor colorWithRed:50/255.0 green:143/255.0 blue:222/255.0 alpha:1];
                valueLabel.hidden = YES;
                if (lastTapView != view) {
                    view.backgroundColor = [UIColor colorWithRed:118/255.0 green:207/255.0 blue:244/255.0 alpha:1];;
                    lastTapView = view;
                    valueLabel = contentLabel;
                    selected = YES;
                    valueLabel.hidden = !selected;
                }else{
                    if (selected) {
                        selected = NO;
                        view.backgroundColor = [UIColor colorWithRed:50/255.0 green:143/255.0 blue:222/255.0 alpha:1];
                        valueLabel.hidden = !selected;
                    }else{
                        selected = YES;
                        view.backgroundColor = [UIColor colorWithRed:118/255.0 green:207/255.0 blue:244/255.0 alpha:1];
                        valueLabel.hidden = !selected;
                    }
                }
            }else{
                view.backgroundColor = [UIColor colorWithRed:118/255.0 green:207/255.0 blue:244/255.0 alpha:1];;
                lastTapView = view;
                valueLabel = contentLabel;
                selected = YES;
                valueLabel.hidden = !selected;
            }
        }];
        [self addSubview:btn];
        x+= w;
    }
}

-(void)addLine:(int)x tox:(int)toX y:(int)y toY:(int)toY{
    CAShapeLayer *lineShape = nil;
    CGMutablePathRef linePath = nil;
    linePath = CGPathCreateMutable();
    lineShape = [CAShapeLayer layer];
    lineShape.lineWidth = 0.5f;
    lineShape.lineCap = kCALineCapRound;;
    lineShape.strokeColor = [UIColor darkGrayColor].CGColor;
    
    CGPathMoveToPoint(linePath, NULL, x, y);
    CGPathAddLineToPoint(linePath, NULL, toX, toY);
    lineShape.path = linePath;
    CGPathRelease(linePath);
    [self.layer addSublayer:lineShape];
}

-(int)getMaxIndex{
    int MaxValue=[[DataArray objectAtIndex:0] intValue];
    int length = (int)DataArray.count;
    int maxIndex = 0;
    for (int i=1; i< length; i++) {
        if ([[DataArray objectAtIndex:i] intValue] > MaxValue) {
            MaxValue =[[DataArray objectAtIndex:i] intValue];
            maxIndex = i;
        }
    }
    return maxIndex;
}

@end
