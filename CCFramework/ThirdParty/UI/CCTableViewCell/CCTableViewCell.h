//
//  CCTableViewCell.h
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
#import <UIKit/UIGestureRecognizerSubclass.h>

@class CCTableViewCell;

typedef NS_ENUM(NSInteger, CCCellState) {
    kCellStateCenter,
    kCellStateLeft,
    kCellStateRight,
};

@protocol CCTableViewCellDelegate <NSObject>

@optional
/**
 *  @author CC, 2015-10-16
 *
 *  @brief  左侧菜单按钮回调
 *
 *  @param cell  当前Cell
 *  @param index 按钮下标
 */
- (void)CCipeableTableViewCell:(CCTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index;
/**
 *  @author CC, 2015-10-16
 *
 *  @brief  右侧菜单按钮回调
 *
 *  @param cell  当前Cell
 *  @param index 按钮下标
 */
- (void)CCipeableTableViewCell:(CCTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index;

- (void)CCipeableTableViewCell:(CCTableViewCell *)cell scrollingToState:(CCCellState)state;
- (BOOL)CCipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(CCTableViewCell *)cell;

/**
 *  @author CC, 2015-10-16
 *
 *  @brief  刷新所有单元格状态
 *
 *  @param cell  当前Cell
 *  @param state 状态
 *
 *  @return 返回是否关闭菜单栏
 */
- (BOOL)CCipeableTableViewCell:(CCTableViewCell *)cell canSwipeToState:(CCCellState)state;
- (void)CCipeableTableViewCellDidEndScrolling:(CCTableViewCell *)cell;
- (void)CCipeableTableViewCell:(CCTableViewCell *)cell didScroll:(UIScrollView *)scrollView;

@end

@interface CCTableViewCell : UITableViewCell

/**
 *  @author CC, 2015-10-21
 *
 *  @brief  当前Cell数据源
 */
@property(nonatomic, strong) id dataSources;

@property(nonatomic, copy) NSArray *leftUtilityButtons;
@property(nonatomic, copy) NSArray *rightUtilityButtons;

@property(nonatomic, weak) id<CCTableViewCellDelegate> delegate;

- (void)setRightUtilityButtons:(NSArray *)rightUtilityButtons WithButtonWidth:(CGFloat)width;
- (void)setLeftUtilityButtons:(NSArray *)leftUtilityButtons WithButtonWidth:(CGFloat)width;
- (void)hideUtilityButtonsAnimated:(BOOL)animated;
- (void)showLeftUtilityButtonsAnimated:(BOOL)animated;
- (void)showRightUtilityButtonsAnimated:(BOOL)animated;

- (BOOL)isUtilityButtonsHidden;

@end

#pragma mark - Array
@interface NSMutableArray (CCUtilityButtons)

- (void)cc_addUtilityButtonWithColor:(UIColor *)color
                               title:(NSString *)title;

- (void)cc_addUtilityButtonWithColor:(UIColor *)color
                     attributedTitle:(NSAttributedString *)title;

- (void)cc_addUtilityButtonWithColor:(UIColor *)color
                                icon:(UIImage *)icon;

- (void)cc_addUtilityButtonWithColor:(UIColor *)color
                          normalIcon:(UIImage *)normalIcon
                        selectedIcon:(UIImage *)selectedIcon;

@end


@interface NSArray (CCUtilityButtons)

- (BOOL)cc_isEqualToButtons:(NSArray *)buttons;

@end
