//
//  BaseTableViewHeaderFooterView.h
//  CCFramework
//
//  Created by kairunyun on 15/3/6.
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

typedef void (^didSelectedHeaderFooterView)(id requestData, BOOL IsError);

@protocol BaseTableViewHeaderFooterViewDelegate <NSObject>

@optional
/**
 *  @author CC, 15-09-16
 *
 *  @brief  选中回调
 *
 *  @param views 当前视图对象
 *  @param index 当前位置
 *
 *  @since 1.0
 */
- (void)didClickHeadView:(UITableViewHeaderFooterView *)views
                   Index:(int)index;

/**
 *  @author CC, 15-09-17
 *
 *  @brief  双击回调
 *
 *  @param views 当前视图对象
 *  @param index 当前位置
 *
 *  @since 1.0
 */
- (void)didClickDoubleClick:(UITableViewHeaderFooterView *)views
                      Index:(int)index;

/**
 *  @author CC, 15-09-17
 *
 *  @brief  长按回调
 *
 *  @param view  当前视图对象
 *  @param index 当前位置
 *
 *  @since 1.0
 */
- (void)didLongPress:(UITableViewHeaderFooterView *)view
               Index:(int)index;

/**
 *  @author CC, 15-09-16
 *
 *  @brief  编辑修改回调
 *
 *  @param text  输入的文本
 *  @param index 当前位置
 *
 *  @since 1.0
 */
- (void)didEditingChanged:(NSString *)text
                    Index:(int)index;

@end

@interface BaseTableViewHeaderFooterView : UITableViewHeaderFooterView <UIGestureRecognizerDelegate>

+ (id)initViewWithNibName:(NSString *)nibName;

/**
 *  @author CC, 2015-07-29
 *
 *  @brief  初始化子视图  子类必须重载
 */
+ (id)initHeaderFooterView;

/**
 *  @author CC, 15-09-16
 *
 *  @brief  委托
 *
 *  @since 1.0
 */
@property(nonatomic, weak) id<BaseTableViewHeaderFooterViewDelegate> delegate;

/**
 *  @author CC, 15-09-16
 *
 *  @brief  选中回调
 *
 *  @since 1.0
 */
@property(nonatomic, copy) didSelectedHeaderFooterView didSelected;

/**
 *  @author CC, 15-09-16
 *
 *  @brief  背景线图片
 *
 *  @since 1.0
 */
@property(nonatomic, strong) UIImage *backgroundImage;

/**
 *  @author CC, 2016-01-13
 *  
 *  @brief 设置背景颜色
 */
@property(nonatomic, strong) UIColor *backgroundViewColor;

/**
 *  @author CC, 15-09-16
 *
 *  @brief  设置数据
 *
 *  @param obj 数据对象
 *
 *  @since 1.0
 */
- (void)setDatas:(id)obj;

/**
 *  @author CC, 15-09-16
 *
 *  @brief  设置数据对象
 *
 *  @param objDatas     数据对象
 *  @param seletedBlock 回调函数
 *
 *  @since 1.0
 */
-(void)setDatas:(id)objDatas didSelectedBlock:(didSelectedHeaderFooterView)seletedBlock;

@end
