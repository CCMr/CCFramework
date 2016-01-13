//
//  BaseTableViewCell.m
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

#import "BaseTableViewCell.h"

@implementation BaseTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initTabelViewCell];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initTabelViewCell];
}

/**
 *  @author CC, 2015-07-29
 *
 *  @brief  使用XIB初始化
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (id)init
{
    self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil].lastObject;

    if (!self) {
        self = [self initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];

    }
    return self;
}

- (void)initTabelViewCell
{
    self.layer.masksToBounds = YES;
    self.contentView.layer.masksToBounds = YES;
    self.backgroundView.layer.masksToBounds = YES;
    self.backgroundView = [UIView new];
    self.backgroundColor = [UIColor whiteColor];
}

+ (id)initViewWithNibName:(NSString *)nibName
{
    id view = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil].lastObject;
    
    return view;
}

/**
 *  @author CC, 2015-07-29
 *
 *  @brief  初始化Cell  子类必须重载
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
+ (id)initView
{
    return [self initViewWithNibName:NSStringFromClass(self.class)];
}

/**
 *  @author CC, 15-08-24
 *
 *  @brief  赋值数据
 *
 *  @param data 当前数据对象
 *
 *  @since <#1.0#>
 */
- (void)setData:(id)data
{
    _dataSources = data;
}

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
    CompletionL:(Completion)completion
{
    _dataSources = data;
    _completion = completion;
}

/**
 *  @author CC, 2015-07-29
 *
 *  @brief  适配器选择状态
 *
 *  @param selected <#selected description#>
 *  @param animated <#animated description#>
 *
 *  @since 1.0
 */
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    [self performSelector:@selector(cancelSelectedCell) withObject:nil afterDelay:0.5];
}

- (void)cancelSelectedCell
{
    [super setSelected:NO animated:YES];
}

@end
