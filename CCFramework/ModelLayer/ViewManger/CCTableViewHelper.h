//
//  CCTableViewHelper.h
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
#import "CCViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSString *__nonnull (^CCTableHelperCellIdentifierBlock)(NSIndexPath *cIndexPath, id cModel);
typedef void (^CCTableHelperDidSelectBlock)(UITableView *tableView, NSIndexPath *cIndexPath, id cModel);
typedef void (^CCTableHelperDidWillDisplayBlock)(UITableViewCell *Cell, NSIndexPath *cIndexPath, id cModel);

typedef void (^CCTableHelperDidEditingBlock)(UITableView *tableView, UITableViewCellEditingStyle editingStyle, NSIndexPath *cIndexPath, id cModel);
typedef NSString *__nonnull (^CCTableHelperDidEditTitleBlock)(UITableView *tableView, NSIndexPath *cIndexPath, id cModel);

typedef NSArray<UITableViewRowAction *> *__nonnull (^CCTableHelperDidEditActionsBlock)(UITableView *tableView, NSIndexPath *cIndexPath, id cModel);

typedef void (^CCScrollViewWillBeginDragging)(UIScrollView *scrollView);
typedef void (^CCScrollViewDidScroll)(UIScrollView *scrollView);
typedef void (^CCTableHelperCellBlock)(NSString *info, id event);


typedef UIView *__nonnull (^CCTableHelperHeaderBlock)(UITableView *tableView, NSInteger section);
typedef UIView *__nonnull (^CCTableHelperFooterBlock)(UITableView *tableView, NSInteger section);

typedef NSInteger (^CCTableHelperNumberRows)(UITableView *tableView, id cModel);
typedef id __nonnull (^CCTableHelperCurrentModelAtIndexPath)(id dataAry, NSIndexPath *cIndexPath);

@interface CCTableViewHelper : NSObject <UITableViewDataSource, UITableViewDelegate>

/**
 *  @author CC, 16-03-19
 *  
 *  @brief 是否补齐线(默认不补齐)
 */
@property(nonatomic, assign) BOOL paddedSeparator;

/**
 *  When using the storyboard and a single cell, set the property inspector same identifier 
 */
@property(nullable, nonatomic, copy) NSString *cellIdentifier;

@property(nonatomic, strong) NSArray *cc_CellXIB;

/**
 *  @author CC, 16-04-07
 *  
 *  @brief Cell委托
 */
@property(nonatomic, weak) id<CCViewProtocol> cellDelegate;

/**
 *  When using xib, all incoming nib names
 */
- (void)registerNibs:(NSArray<NSString *> *)cellNibNames;

#pragma mark -
#pragma mark :. Block事件
/**
 *  When there are multiple cell, returned identifier in block
 */
- (void)cellMultipleIdentifier:(CCTableHelperCellIdentifierBlock)cb;

/**
 *  If you override tableView:didSelectRowAtIndexPath: method, it will be invalid
 */
- (void)didSelect:(CCTableHelperDidSelectBlock)cb;


/**
 *  @author CC, 16-06-20
 *  
 *  @brief  cell侧滑编辑事件
 */
- (void)didEnditing:(CCTableHelperDidEditingBlock)cb;
/**
 *  @author CC, 16-06-20
 *  
 *  @brief  cell侧滑标题
 */
- (void)didEnditTitle:(CCTableHelperDidEditTitleBlock)cb;

/**
 *  @author CC, 16-06-20
 *  
 *  @brief  cell侧滑菜单
 */
- (void)didEditActions:(CCTableHelperDidEditActionsBlock)cb;

/**
 *  @author CC, 16-03-19
 *  
 *  @brief 设置Cell显示
 */
- (void)cellWillDisplay:(CCTableHelperDidWillDisplayBlock)cb;

- (void)ccScrollViewWillBeginDragging:(CCScrollViewWillBeginDragging)block;
- (void)ccScrollViewDidScroll:(CCScrollViewDidScroll)block;

/**
 *  @author CC, 16-05-18
 *  
 *  @brief  Header视图
 */
- (void)headerView:(CCTableHelperHeaderBlock)cb;

/**
 *  @author CC, 16-05-18
 *  
 *  @brief  Footer视图
 */
- (void)footerView:(CCTableHelperFooterBlock)cb;

/**
 *  @author CC, 16-05-23
 *  
 *  @brief  NumberOfRowsInSection
 */
- (void)numberOfRowsInSection:(CCTableHelperNumberRows)cb;

/**
 *  @author CC, 16-04-22
 *  
 *  @brief 设置Cell回调Block
 */
- (void)cellViewEventBlock:(CCTableHelperCellBlock)cb;

/**
 *  @author CC, 16-05-23
 *  
 *  @brief  处理获取当前模型
 */
- (void)currentModelIndexPath:(CCTableHelperCurrentModelAtIndexPath)cb;

@property(nonatomic, weak) UITableView *cc_tableView;
@property(nonatomic, strong) NSIndexPath *cc_indexPath;

#pragma mark -
#pragma mark :. Handler
/**
 *  @author CC, 16-05-18
 *  
 *  @brief  显示数据
 *
 *  @param newDataAry 数据源
 */
- (void)cc_resetDataAry:(NSArray *)newDataAry;

/**
 *  @author CC, 16-05-18
 *  
 *  @brief  显示数据
 *
 *  @param newDataAry 数据源
 *  @param cSection   分组数
 */
- (void)cc_resetDataAry:(NSArray *)newDataAry forSection:(NSUInteger)cSection;

/**
 *  @author CC, 16-05-18
 *  
 *  @brief  刷新并加入新数据
 *
 *  @param newDataAry 数据源
 */
- (void)cc_reloadDataAry:(NSArray *)newDataAry;

/**
 *  @author CC, 16-05-18
 *  
 *  @brief  刷新并加入新数据
 *
 *  @param newDataAry 数据源
 *  @param cSection   分组数
 */
- (void)cc_reloadDataAry:(NSArray *)newDataAry forSection:(NSUInteger)cSection;

/**
 *  @author CC, 16-05-18
 *  
 *  @brief  批量添加数据
 *
 *  @param newDataAry 数据源
 */
- (void)cc_addDataAry:(NSArray *)newDataAry;
/**
 *  @author CC, 16-05-18
 *  
 *  @brief  批量添加
 *
 *  @param newDataAry 数据源
 *  @param cSection   分组数
 */
- (void)cc_addDataAry:(NSArray *)newDataAry forSection:(NSUInteger)cSection;

/**
 *  @author CC, 16-05-18
 *  
 *  @brief  单个添加
 *
 *  @param cModel     数据模型
 *  @param cIndexPath 下标位置
 */
- (void)cc_insertData:(id)cModel AtIndex:(NSIndexPath *)cIndexPath;

/**
 *  @author CC, 16-05-18
 *  
 *  @brief  根据下标删除数据
 *
 *  @param cIndexPath 下标位置
 */
- (void)cc_deleteDataAtIndex:(NSIndexPath *)cIndexPath;


- (id)currentModel;
- (id)currentModelAtIndexPath:(NSIndexPath *)cIndexPath;

@end

NS_ASSUME_NONNULL_END
