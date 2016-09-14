//
//  UITableView+Additions.h
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

@class CCTableViewManger;
@class CCTableViewHelper;

#pragma mark -
#pragma mark :. CCIndexPathHeightCache

@interface CCIndexPathHeightCache : NSObject

// Enable automatically if you're using index path driven height cache
@property(nonatomic, assign) BOOL automaticallyInvalidateEnabled;

// Height cache
- (BOOL)existsHeightAtIndexPath:(NSIndexPath *)indexPath;
- (void)cacheHeight:(CGFloat)height byIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)heightForIndexPath:(NSIndexPath *)indexPath;
- (void)invalidateHeightAtIndexPath:(NSIndexPath *)indexPath;
- (void)invalidateAllHeightCache;

@end

#pragma mark -
#pragma mark :. CCKeyedHeightCache
@interface CCKeyedHeightCache : NSObject

- (BOOL)existsHeightForKey:(id<NSCopying>)key;
- (void)cacheHeight:(CGFloat)height byKey:(id<NSCopying>)key;
- (CGFloat)heightForKey:(id<NSCopying>)key;

// Invalidation
- (void)invalidateHeightForKey:(id<NSCopying>)key;
- (void)invalidateAllHeightCache;

@end

#pragma mark -
#pragma mark :. Additions

@interface UITableView (Additions)

@property(nonatomic, weak) UIViewController *cc_vc;

@property(nonatomic, strong) CCTableViewManger *tabelHander;

@property(nonatomic, strong) CCTableViewHelper *cc_tableViewHelper;

@property(nonatomic) IBInspectable BOOL cc_autoSizingCell;



/**
 *  @author CC, 16-07-23
 *
 *  @brief SectionView
 *
 *  @param text   显示值
 *  @param height 高度
 */
- (UIView *)tableViewSectionView:(NSString *)text
                   SectionHeight:(CGFloat)height;

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  隐藏TableView多余线
 *
 *  @since 1.0
 */
- (void)extraCellLineHidden;

/**
 *  @brief  ios7设置页面的UITableViewCell样式
 *
 *  @param cell      cell
 *  @param indexPath indexPath
 */
- (void)applyiOS7SettingsStyleGrouping:(UITableViewCell *)cell
                     forRowAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark -
#pragma mark :. CCIndexPathHeightCache

/// Height cache by index path. Generally, you don't need to use it directly.
@property(nonatomic, strong, readonly) CCIndexPathHeightCache *cc_indexPathHeightCache;


#pragma mark -
#pragma mark :. CCKeyedHeightCache

/// Height cache by key. Generally, you don't need to use it directly.
@property(nonatomic, strong, readonly) CCKeyedHeightCache *cc_keyedHeightCache;

#pragma mark -
#pragma mark :. CCTemplateLayoutCell

/// Access to internal template layout cell for given reuse identifier.
/// Generally, you don't need to know these template layout cells.
///
/// @param identifier Reuse identifier for cell which must be registered.
///
- (__kindof UITableViewCell *)cc_templateCellForReuseIdentifier:(NSString *)identifier;

/// Returns height of cell of type specifed by a reuse identifier and configured
/// by the configuration block.
///
/// The cell would be layed out on a fixed-width, vertically expanding basis with
/// respect to its dynamic content, using auto layout. Thus, it is imperative that
/// the cell was set up to be self-satisfied, i.e. its content always determines
/// its height given the width is equal to the tableview's.
///
/// @param identifier A string identifier for retrieving and maintaining template
///        cells with system's "-dequeueReusableCellWithIdentifier:" call.
/// @param configuration An optional block for configuring and providing content
///        to the template cell. The configuration should be minimal for scrolling
///        performance yet sufficient for calculating cell's height.
///
- (CGFloat)cc_heightForCellWithIdentifier:(NSString *)identifier configuration:(void (^)(id cell))configuration;

/// This method does what "-fd_heightForCellWithIdentifier:configuration" does, and
/// calculated height will be cached by its index path, returns a cached height
/// when needed. Therefore lots of extra height calculations could be saved.
///
/// No need to worry about invalidating cached heights when data source changes, it
/// will be done automatically when you call "-reloadData" or any method that triggers
/// UITableView's reloading.
///
/// @param indexPath where this cell's height cache belongs.
///
- (CGFloat)cc_heightForCellWithIdentifier:(NSString *)identifier cacheByIndexPath:(NSIndexPath *)indexPath configuration:(void (^)(id cell))configuration;

/// This method caches height by your model entity's identifier.
/// If your model's changed, call "-invalidateHeightForKey:(id <NSCopying>)key" to
/// invalidate cache and re-calculate, it's much cheaper and effective than "cacheByIndexPath".
///
/// @param key model entity's identifier whose data configures a cell.
///
- (CGFloat)cc_heightForCellWithIdentifier:(NSString *)identifier cacheByKey:(id<NSCopying>)key configuration:(void (^)(id cell))configuration;

@end

@interface UITableView (CCTemplateLayoutHeaderFooterView)

/// Returns header or footer view's height that registered in table view with reuse identifier.
///
/// Use it after calling "-[UITableView registerNib/Class:forHeaderFooterViewReuseIdentifier]",
/// same with "-fd_heightForCellWithIdentifier:configuration:", it will call "-sizeThatFits:" for
/// subclass of UITableViewHeaderFooterView which is not using Auto Layout.
///
- (CGFloat)cc_heightForHeaderFooterViewWithIdentifier:(NSString *)identifier configuration:(void (^)(id headerFooterView))configuration;

@end

@interface UITableViewCell (CCTemplateLayoutCell)

/// Indicate this is a template layout cell for calculation only.
/// You may need this when there are non-UI side effects when configure a cell.
/// Like:
///   - (void)configureCell:(FooCell *)cell atIndexPath:(NSIndexPath *)indexPath {
///       cell.entity = [self entityAtIndexPath:indexPath];
///       if (!cell.fd_isTemplateLayoutCell) {
///           [self notifySomething]; // non-UI side effects
///       }
///   }
///
@property(nonatomic, assign) BOOL cc_isTemplateLayoutCell;

/// Enable to enforce this template layout cell to use "frame layout" rather than "auto layout",
/// and will ask cell's height by calling "-sizeThatFits:", so you must override this method.
/// Use this property only when you want to manually control this template layout cell's height
/// calculation mode, default to NO.
///
@property(nonatomic, assign) BOOL cc_enforceFrameLayout;

@end


#pragma mark -
#pragma mark :. CCIndexPathHeightCacheInvalidation

@interface UITableView (CCIndexPathHeightCacheInvalidation)

/**
 *  @author CC, 16-09-09
 *
 *  @brief 设置添加数时不会顶部
 */
@property(nonatomic,assign) BOOL cc_isContentSize;

/// Call this method when you want to reload data but don't want to invalidate
/// all height cache by index path, for example, load more data at the bottom of
/// table view.
- (void)cc_reloadDataWithoutInvalidateIndexPathHeightCache;

@end
