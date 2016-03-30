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

NS_ASSUME_NONNULL_BEGIN

typedef NSString *__nonnull (^CCTableHelperCellIdentifierBlock)(NSIndexPath *cIndexPath, id cModel);
typedef void (^CCTableHelperDidSelectBlock)(UITableView *tableView, NSIndexPath *cIndexPath, id cModel);
typedef void (^CCTableHelperDidWillDisplayBlock)(UITableViewCell *Cell, id cModel);

typedef void (^CCScrollViewWillBeginDragging)(UIScrollView *scrollView);

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

@property(nonatomic, assign) BOOL cc_CellXIB;

/**
 *  When using xib, all incoming nib names
 */
- (void)registerNibs:(NSArray<NSString *> *)cellNibNames;

/**
 *  When there are multiple cell, returned identifier in block
 */
- (void)cellMultipleIdentifier:(CCTableHelperCellIdentifierBlock)cb;

/**
 *  If you override tableView:didSelectRowAtIndexPath: method, it will be invalid
 */
- (void)didSelect:(CCTableHelperDidSelectBlock)cb;

/**
 *  @author CC, 16-03-19
 *  
 *  @brief 设置Cell显示
 */
- (void)cellWillDisplay:(CCTableHelperDidWillDisplayBlock)cb;

- (void)ccScrollViewWillBeginDragging:(CCScrollViewWillBeginDragging)block;

@property(nonatomic, weak) UITableView *cc_tableView;
@property(nonatomic, strong) NSIndexPath *cc_indexPath;

- (void)cc_resetDataAry:(NSArray *)newDataAry;
- (void)cc_resetDataAry:(NSArray *)newDataAry forSection:(NSUInteger)cSection;
- (void)cc_reloadDataAry:(NSArray *)newDataAry;
- (void)cc_reloadDataAry:(NSArray *)newDataAry forSection:(NSUInteger)cSection;
- (void)cc_addDataAry:(NSArray *)newDataAry;
- (void)cc_addDataAry:(NSArray *)newDataAry forSection:(NSUInteger)cSection;
- (void)cc_insertData:(id)cModel AtIndex:(NSIndexPath *)cIndexPath;
- (void)cc_deleteDataAtIndex:(NSIndexPath *)cIndexPath;


- (id)currentModel;
- (id)currentModelAtIndexPath:(NSIndexPath *)cIndexPath;

@end

NS_ASSUME_NONNULL_END
