//
//  CCChart.h
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


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CCChart : UIView

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
                withChartDatas:(NSDictionary *)datas, ... NS_REQUIRES_NIL_TERMINATION;

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
                 StrokeColors:(NSArray *)strokeColors;

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
        StrokeColorGradientStart:(UIColor *)strokeColorGradientStart;

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
                     DataItem:(NSDictionary *)dataItem, ... NS_REQUIRES_NIL_TERMINATION;

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
                       DataItem:(NSDictionary *)dataItem, ... NS_REQUIRES_NIL_TERMINATION;

@end
