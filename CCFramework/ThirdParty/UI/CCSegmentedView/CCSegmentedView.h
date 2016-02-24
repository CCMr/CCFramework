//
//  CCSegmentedView.h
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

#pragma mark - 说明
/*
 使用说明：
 初始化：
 可以在代码中通过alloc-init的方法初始化；
 例如：
 //初始化
 self.segmentedView = [[CCSegmentedView alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
 //设置标题
 [self.segmentedView setTitles:@[@"消息",@"电话",@"视频",@"空间",@"圈子"]];
 或者：
 //初始化并设置标题
 self.segmentedView = [[CCSegmentedView alloc]initWithFrame:CGRectMake(0, 0, 200, 44) titles:@[@"消息",@"电话",@"视频",@"空间",@"游戏"]];
 
 或者在Xib（Storyboard）中拖拽View，设置继承自 CCSegmentedView 类。
 在Xib（Storyboard）中可设置TintColor，改变主体颜色。
 
 设置代理：
 代码与Xib（Storyboard）均使用
 self.segmentedView.delegate = self;
 设置代理
 
 代理方法：
 提供
 - (void)ccSegmentedView:(CCSegmentedView *)CCSegmentedView selectTitleInteger:(NSInteger)integer;
 - (BOOL)ccSegmentedView:(CCSegmentedView *)CCSegmentedView didSelectTitleInteger:(NSInteger)integer;
 代理方法，
 具体功能见代码注释
 */

#pragma mark -

#import <UIKit/UIKit.h>

@protocol CCSegmentedViewDelegate;

@interface CCSegmentedView : UIView

#pragma mark - 属性
//标题数组
@property(nonatomic, copy) NSArray *titles;
//未选中文字、边框、滑块颜色
@property(nonatomic, strong) UIColor *textColor;
//背景、选中文字颜色，当设置为透明时，选中文字为白色
@property(nonatomic, strong) UIColor *viewColor;
//选中的标题
@property(nonatomic) NSInteger selectNumber;

@property(nonatomic, copy) void (^didSelectRowAtIndex)(CCSegmentedView *segmentedView, NSInteger Index);
@property(nonatomic, copy) BOOL (^didDeselectRowAtIndex)(CCSegmentedView *segmentedView, NSInteger Index);


#pragma mark - 方法
/*
 初始化方法
 设置标题
 */
- (instancetype)initWithFrame:(CGRect)frame
                       titles:(NSArray *)titles;

/*
 设置标题
 */
- (void)setTitles:(NSArray *)titles;

/*
 设置选中的标题
 超出范围，则为最后一个标题
 
 或者使用隐藏的
 - (void)setSelectNumber:(NSInteger)selectNumber
 方法，默认无动画效果。
 */
- (void)setSelectNumber:(NSInteger)selectNumber
                animate:(BOOL)animate;

#pragma mark - 代理

@property (nonatomic, weak) id <CCSegmentedViewDelegate> delegate;

@end

@protocol CCSegmentedViewDelegate <NSObject>

@optional

/*
 当滑动CCSegmentedView滑块时，或者CCSegmentedView被点击时，会调用此方法。
 */
- (void)didSelectRowAtIndex:(CCSegmentedView *)CCSegmentedView 
         selectTitleInteger:(NSInteger)integer;

/*
 是否允许被选中
 返回YES可以被选中
 返回NO不可以被选中
 */
- (BOOL)didDeselectRowAtIndex:(CCSegmentedView *)CCSegmentedView 
    didDeseSelectTitleInteger:(NSInteger)integer;

@end
