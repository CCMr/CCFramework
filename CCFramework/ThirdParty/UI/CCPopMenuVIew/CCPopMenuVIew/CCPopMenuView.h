//
//  CCPopMenuView.h
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
#import "CCPopMenuItem.h"

typedef NS_ENUM(NSInteger, PopMenuAnimationType) {
    /** 从下部入 下部出*/
    kPopMenuAnimationTypeSina = 0,
    /** 顶部中入 下底部中*/
    kPopMenuAnimationTypeNetEase = 1,
};

typedef NS_ENUM(NSInteger, CCStyle) {
    // 垂直梯度背景从黑色到半透明的。
    CCBlackGradient = 0,
    // 类似UIToolbar的半透明背景
    CCTranslucent,
    // 黑色半透明背景
    CCBlackTranslucent,
    // 纯白色
    CCWhite,
    // 白色毛玻璃
    CCFrstedGlass,
};

/**
 *  选中菜单按钮 操作
 *
 *  @param selectedItem 菜单按钮
 */
typedef void (^DidSelectedItemBlock)(CCPopMenuItem *selectedItem);


@interface CCPopMenuView : UIView

/**
 *  菜单动画格式
 */
@property(nonatomic, assign) PopMenuAnimationType menuAnimationType;

/**
 *  是否显示
 */
@property(nonatomic, assign, readonly) BOOL isShowed;

/**
 *  菜单中菜单元素
 */
@property(nonatomic, strong, readonly) NSArray *items;

// 每行有多少列 Default is 3
@property(nonatomic, assign) NSInteger perRowItemCount;

/**
 *  点击菜单元素,Block会把点击的菜单元素当成参数返回给用户，用户可以拿到菜单元素对点击，做相应的操作
 */
@property(nonatomic, copy) DidSelectedItemBlock didSelectedItemCompletion;

@property(nonatomic, copy) void (^didDismissMenuCompletion)(CCPopMenuView *popMenuView);

/**
 *  @author CC, 16-03-18
 *  
 *  @brief 背景颜色类型
 */
@property(nonatomic, assign) CCStyle backgroundType;

#pragma mark - init 初始化

- (instancetype)initWithItems:(NSArray *)items;

- (instancetype)initWithFrame:(CGRect)frame
                        items:(NSArray *)items;

#pragma mark - show
#pragma mark 将菜单显示到某个视图上

- (void)showMenuAtView:(UIView *)containerView;

#pragma mark 控制菜单从哪个点的进 和 出

/**
 *  将菜单  开始 现实到哪个point 上  在哪个 point 结束
 *
 *  此效果用于 在 PopMenu AnimationType 为 kPopMenuAnimationTypeNetEase 有效，
 *  @param containerView 显示在哪个视图容器上
 *  @param startPoint    菜单从哪个 点 进入 容器 展示效果
 *  @param endPoint      菜单从哪个 点 出 容器
 */
- (void)showMenuAtView:(UIView *)containerView 
            startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

#pragma mark - dismiss
/**
 *  容器dismiss
 */
- (void)dismissMenu;

@end

