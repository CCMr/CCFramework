//
//  CCChart.m
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


#import "CCChart.h"
#import "PNChart.h"

@interface CCChart () <PNChartDelegate>

@end

@implementation CCChart

/**
 *  @author CC, 2015-11-05
 *  
 *  @brief  曲线报表图
 *
 *  @param frame          绘画大小
 *  @param xLabels        x显示字段名称
 *  @param yLabels        y显示字段名称
 *  @param yFixedValueMin 最小数值
 *  @param yFixedValueMax 最大数值
 *  @param datas          曲线数据键值（规格：title : 曲线名称，dataArray : 曲线数据值）
 *
 *  @return 返回曲线报表图
 */
+ (instancetype)buildLineChart:(CGRect)frame
                       XLabels:(NSArray *)xLabels
                       YLabels:(NSArray *)yLabels
                YFixedValueMin:(CGFloat)yFixedValueMin
                YFixedValueMax:(CGFloat)yFixedValueMax
                withChartDatas:(NSDictionary *)datas, ... NS_REQUIRES_NIL_TERMINATION
{
    CCChart *lineChartView = [[CCChart alloc] initWithFrame:frame];
    lineChartView.backgroundColor = [UIColor clearColor];
    
    NSMutableArray *array = [NSMutableArray array];
    if (datas) {
        [array addObject:datas];
        va_list arguments;
        id eachObject;
        va_start(arguments, datas);
        while ((eachObject = va_arg(arguments, id))) {
            [array addObject:datas];
        }
        va_end(arguments);
    }
    
    NSMutableArray *arrayData = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        
        PNLineChartData *lineChartData = [PNLineChartData new];
        lineChartData.dataTitle = [dic objectForKey:@"title"];
        lineChartData.color = PNFreshGreen;
        lineChartData.alpha = 0.5f;
        lineChartData.itemCount = [[dic objectForKey:@"dataArray"] count];
        lineChartData.inflexionPointStyle = PNLineChartPointStyleTriangle;
        lineChartData.getData = ^(NSUInteger index) {
            CGFloat yValue = [[[dic objectForKey:@"dataArray"] objectAtIndex:index] floatValue];
            return [PNLineChartDataItem dataItemWithY:yValue];
        };
        [arrayData addObject:lineChartData];
    }
    
    
    PNLineChart *lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 5 - arrayData.count * 15)];
    lineChart.yLabelFormat = @"%1.1f";
    lineChart.backgroundColor = [UIColor clearColor];
    [lineChart setXLabels:xLabels];
    lineChart.showCoordinateAxis = YES;
    lineChart.yFixedValueMax = yFixedValueMax;
    lineChart.yFixedValueMin = yFixedValueMin;
    [lineChart setYLabels:yLabels];
    
    lineChart.chartData = arrayData;
    [lineChart strokeChart];
    [lineChartView addSubview:lineChart];
    
    
    lineChart.legendStyle = PNLegendItemStyleStacked;
    lineChart.legendFont = [UIFont boldSystemFontOfSize:12.0f];
    lineChart.legendFontColor = [UIColor redColor];
    
    UIView *legend = [lineChart getLegendWithMaxWidth:SCREEN_WIDTH];
    legend.frame = CGRectMake(30, lineChart.frame.size.height + 5, frame.size.width, arrayData.count * 15);
    [lineChartView addSubview:legend];
    
    return lineChartView;
}

/**
 *  @author CC, 2015-11-05
 *  
 *  @brief  柱状报表图
 *
 *  @param frame        绘画大小
 *  @param xLabels      x显示字段名称
 *  @param yLabels      y显示字段名称
 *  @param strokeColors 柱的颜色
 *
 *  @return 返回柱状报表图
 */
+ (instancetype)buildBarChart:(CGRect)frame
                      XLabels:(NSArray *)xLabels
                      YLabels:(NSArray *)yLabels
                 StrokeColors:(NSArray *)strokeColors
{
    CCChart *barChartView = [[CCChart alloc] initWithFrame:frame];
    barChartView.backgroundColor = [UIColor clearColor];
    
    static NSNumberFormatter *barChartFormatter;
    if (!barChartFormatter) {
        barChartFormatter = [[NSNumberFormatter alloc] init];
        barChartFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
        barChartFormatter.allowsFloats = NO;
        barChartFormatter.maximumFractionDigits = 0;
    }
    
    PNBarChart *barChart = [[PNBarChart alloc] initWithFrame:frame];
    barChart.backgroundColor = [UIColor clearColor];
    barChart.yLabelFormatter = ^(CGFloat yValue) {
        return [barChartFormatter stringFromNumber:[NSNumber numberWithFloat:yValue]];
    };
    [barChartView addSubview:barChart];
    
    barChart.yChartLabelWidth = 20.0;
    barChart.chartMarginLeft = 30.0;
    barChart.chartMarginRight = 10.0;
    barChart.chartMarginTop = 5.0;
    barChart.chartMarginBottom = 10.0;
    
    
    barChart.labelMarginTop = 5.0;
    barChart.showChartBorder = YES;
    [barChart setXLabels:xLabels];
    
    [barChart setYValues:yLabels];
    [barChart setStrokeColors:strokeColors];
    barChart.isGradientShow = NO;
    barChart.isShowNumbers = NO;
    
    [barChart strokeChart];
    
    return barChartView;
}

/**
 *  @author CC, 2015-11-05
 *  
 *  @brief  圆报表图
 *
 *  @param frame                    绘图大小
 *  @param total                    总数
 *  @param current                  当前数
 *  @param clockwise                左右
 *  @param strokeColorGradientStart 圆颜色
 *
 *  @return 返回圆报表图
 */
+ (instancetype)buildCircleChart:(CGRect)frame
                           Total:(NSNumber *)total
                         Current:(NSNumber *)current
                       Clockwise:(BOOL)clockwise
        StrokeColorGradientStart:(UIColor *)strokeColorGradientStart
{
    CCChart *CircleChartView = [[CCChart alloc] initWithFrame:frame];
    CircleChartView.backgroundColor = [UIColor clearColor];
    
    PNCircleChart *circleChart = [[PNCircleChart alloc] initWithFrame:frame
                                                                total:total
                                                              current:current
                                                            clockwise:clockwise];
    [CircleChartView addSubview:circleChart];
    
    circleChart.backgroundColor = [UIColor clearColor];
    [circleChart setStrokeColor:[UIColor clearColor]];
    [circleChart setStrokeColorGradientStart:strokeColorGradientStart];
    [circleChart strokeChart];
    
    return CircleChartView;
}

/**
 *  @author CC, 2015-11-05
 *  
 *  @brief  饼形图报表图
 *
 *  @param frame    绘图大小
 *  @param dataItem 饼型子项集合（规格：description:名称 value:数值 color:颜色）
 *
 *  @return 返回饼形图报表图
 */
+ (instancetype)buildPieChart:(CGRect)frame
                     DataItem:(NSDictionary *)dataItem, ... NS_REQUIRES_NIL_TERMINATION
{
    CCChart *PieChartView = [[CCChart alloc] initWithFrame:frame];
    PieChartView.backgroundColor = [UIColor clearColor];
    
    NSMutableArray *array = [NSMutableArray array];
    if (dataItem) {
        [array addObject:dataItem];
        va_list arguments;
        id eachObject;
        va_start(arguments, dataItem);
        while ((eachObject = va_arg(arguments, id))) {
            [array addObject:dataItem];
        }
        va_end(arguments);
    }
    NSMutableArray *arrayDataItem = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        PNPieChartDataItem *item = [PNPieChartDataItem dataItemWithValue:[[dic objectForKey:@"value"] floatValue] color:[dic objectForKey:@"color"] description:[dic objectForKey:@"description"]];
        [arrayDataItem addObject:item];
    }
    
    PNPieChart *pieChart = [[PNPieChart alloc] initWithFrame:CGRectMake(frame.size.width / 2.0 - 100, 0, frame.size.width - 200, frame.size.height - 5 - arrayDataItem.count * 15) items:arrayDataItem];
    pieChart.descriptionTextColor = [UIColor whiteColor];
    pieChart.descriptionTextFont = [UIFont fontWithName:@"Avenir-Medium" size:11.0];
    pieChart.descriptionTextShadowColor = [UIColor clearColor];
    pieChart.showAbsoluteValues = NO;
    pieChart.showOnlyValues = NO;
    [pieChart strokeChart];
    [PieChartView addSubview:pieChart];
    
    pieChart.legendStyle = PNLegendItemStyleStacked;
    pieChart.legendFont = [UIFont boldSystemFontOfSize:12.0f];
    
    UIView *legend = [pieChart getLegendWithMaxWidth:SCREEN_WIDTH];
    legend.frame = CGRectMake((SCREEN_WIDTH - 80) / 2, pieChart.frame.size.height + 5, frame.size.width, arrayDataItem.count * 15);
    [PieChartView addSubview:legend];
    
    return PieChartView;
}

/**
 *  @author CC, 2015-11-05
 *  
 *  @brief  雷达分布图
 *
 *  @param frame        绘图大小
 *  @param valueDivider 绘线大小
 *  @param dataItem     雷达分布子项（规格：description:名称 value:数值）
 *
 *  @return 返回雷达分布图
 */
+ (instancetype)buildRadarChart:(CGRect)frame
                   ValueDivider:(CGFloat)valueDivider
                       DataItem:(NSDictionary *)dataItem, ... NS_REQUIRES_NIL_TERMINATION
{
    CCChart *RadarChartView = [[CCChart alloc] initWithFrame:frame];
    RadarChartView.backgroundColor = [UIColor clearColor];
    
    NSMutableArray *array = [NSMutableArray array];
    if (dataItem) {
        [array addObject:dataItem];
        va_list arguments;
        id eachObject;
        va_start(arguments, dataItem);
        while ((eachObject = va_arg(arguments, id))) {
            [array addObject:dataItem];
        }
        va_end(arguments);
    }
    
    NSMutableArray *arrayDataItem = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        PNRadarChartDataItem *item = [PNRadarChartDataItem dataItemWithValue:[[dic objectForKey:@"value"] floatValue] description:[dic objectForKey:@"description"]];
        [arrayDataItem addObject:item];
    }
    
    PNRadarChart *radarChart = [[PNRadarChart alloc] initWithFrame:frame items:arrayDataItem valueDivider:valueDivider];
    [radarChart strokeChart];
    
    return RadarChartView;
}


@end
