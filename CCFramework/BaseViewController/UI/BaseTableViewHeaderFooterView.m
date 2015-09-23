//
//  BaseTableViewHeaderFooterView.m
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

#import "BaseTableViewHeaderFooterView.h"
#import "FriendGroup.h"
#include "Config.h"

@interface BaseTableViewHeaderFooterView()

@property (nonatomic, weak) FriendGroup *friendGroup;

@property (nonatomic, strong) UIButton *clickBtn;

@property (nonatomic, strong) UIImageView *backgroundImageView;

@end

@implementation BaseTableViewHeaderFooterView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self Initialization];
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self Initialization];
    }
    return self;
}

+ (id)initViewWithNibName:(NSString *)nibName
{
    id view = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil].lastObject;
    if (view)
        [view Initialization];

    return view;
}

/**
 *  @author CC, 2015-07-29
 *
 *  @brief  初始化子视图  子类必须重载
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
+ (id)initHeaderFooterView
{
    return [self initViewWithNibName:NSStringFromClass(self.class)];
}

/**
 *  @author CC, 15-09-17
 *
 *  @brief  初始化
 *
 *  @since 1.0
 */
- (void)Initialization
{
    if (!_clickBtn) {
        _clickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clickBtn addTarget:self action:@selector(didSelectedClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_clickBtn];

        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressClick:)];
        longPress.minimumPressDuration = 0.8; //定义按的时间
        [_clickBtn addGestureRecognizer:longPress];

        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _backgroundImageView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_backgroundImageView];
        [self sendSubviewToBack:_backgroundImageView];
    }
}

/**
 *  @author CC, 15-09-17
 *
 *  @brief  单击事件
 *
 *  @param recognizer 手势
 *
 *  @since 1.0
 */
- (void)didSelectedClick: (UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(didClickHeadView:Index:)]){
        _friendGroup.opened = !_friendGroup.opened;
        [self.delegate didClickHeadView:self Index:(int)self.tag];
    }
}

/**
 *  @author CC, 15-09-17
 *
 *  @brief  双击手势
 *
 *  @param recognizer 手势
 *
 *  @since 1.0
 */
- (void)didSelectedDoubleClick: (UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(didClickDoubleClick:Index:)]) {
        [self.delegate didClickDoubleClick:self Index:(int)self.tag];
    }
}

/**
 *  @author CC, 15-09-17
 *
 *  @brief  长按手势
 *
 *  @param recognizer 手势
 *
 *  @since 1.0
 */
-(void)didLongPressClick: (UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(didLongPress:Index:)])
            [self.delegate didLongPress:self Index:(int)self.tag];
    }
}

/**
 *  @author CC, 15-09-16
 *
 *  @brief  设置背景图片
 *
 *  @param lineBgImageView 图片
 *
 *  @since 1.0
 */
- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImageView.image = backgroundImage;
}

/**
 *  @author CC, 15-09-16
 *
 *  @brief  设置数据
 *
 *  @param obj 数据对象
 *
 *  @since 1.0
 */
-(void)setDatas:(NSObject *)obj{
    _friendGroup = (FriendGroup *)obj;
}

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
-(void)setDatas: (NSObject *)objDatas
didSelectedBlock: (didSelectedHeaderFooterView)seletedBlock{
    self.didSelected = seletedBlock;
    _friendGroup = (FriendGroup *)objDatas;
}

-(void)layoutSubviews
{
    _clickBtn.frame = self.bounds;
    _backgroundImageView.frame = self.bounds;
}

@end
