//
//  BaseTableViewHeaderFooterView.h
//  CC
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

typedef void (^didSelectedHeaderFooterView)(NSObject *requestData,BOOL IsError);

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
-(void)didClickHeadView: (UIView *)views
                  Index: (int)index;

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
-(void)didEditingChanged: (NSString *)text
                   Index: (int)index;

@end

@interface BaseTableViewHeaderFooterView : UITableViewHeaderFooterView<UIGestureRecognizerDelegate>

/**
 *  @author CC, 15-09-16
 *
 *  @brief  委托
 *
 *  @since 1.0
 */
@property (nonatomic, weak) id<BaseTableViewHeaderFooterViewDelegate> delegate;

/**
 *  @author CC, 15-09-16
 *
 *  @brief  选中回调
 *
 *  @since 1.0
 */
@property (nonatomic, copy) didSelectedHeaderFooterView didSelected;

/**
 *  @author CC, 15-09-16
 *
 *  @brief  背景线图片
 *
 *  @since 1.0
 */
@property (nonatomic, strong) UIImageView *lineBgImageView;

/**
 *  @author CC, 15-09-16
 *
 *  @brief  设置数据
 *
 *  @param obj 数据对象
 *
 *  @since 1.0
 */
-(void)setDatas:(NSObject *)obj;

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
-(void)setDatas: (NSObject *) objDatas
didSelectedBlock: (didSelectedHeaderFooterView)seletedBlock;

@end
