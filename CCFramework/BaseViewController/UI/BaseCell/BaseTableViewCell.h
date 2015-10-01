//
//  BaseTableViewCell.h
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

#import <UIKit/UIKit.h>
#import "Config.h"

@interface BaseTableViewCell : UITableViewCell

/**
 *  @author CC, 15-08-24
 *
 *  @brief  回调函数
 *
 *  @since 1.0
 */
@property (nonatomic, strong) Completion completion;

/**
 *  @author C C, 2015-10-01
 *
 *  @brief  Cell 获取下标
 */
@property (nonatomic, strong) NSIndexPath *indexPath;

/**
 *  @author CC, 2015-07-29
 *
 *  @brief  使用XIB初始化
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (id)init;

/**
 *  @author CC, 2015-07-29
 *
 *  @brief  初始化Cell  子类必须重载
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
+ (id)initView;

+ (id)initViewWithNibName:(NSString *)nibName;

/**
 *  @author CC, 15-08-24
 *
 *  @brief  赋值数据
 *
 *  @param data 当前数据对象
 *
 *  @since <#1.0#>
 */
- (void)setData:(id)data;

/**
 *  @author CC, 15-08-24
 *
 *  @brief  赋值数据
 *
 *  @param data       当前数据对象
 *  @param completion 回调函数
 *
 *  @since 1.0
 */
- (void)setData:(id)data
    CompletionL:(Completion)completion;

@end
