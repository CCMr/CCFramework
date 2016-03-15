//
//  UITableView+Additions.m
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

#import "UITableView+Additions.h"
#import <objc/runtime.h>
#import "CCTableViewManger.h"
#import "NSObject+Additions.h"
#import "UIView+Method.h"
#import "CCTableViewHelper.h"
#import "NSObject+Additions.h"

#pragma mark -
#pragma mark :. CCIndexPathHeightCache

@interface CCIndexPathHeightCache ()

@property(nonatomic, strong) NSMutableArray *heightsBySectionForPortrait;
@property(nonatomic, strong) NSMutableArray *heightsBySectionForLandscape;

@end

@implementation CCIndexPathHeightCache

- (instancetype)init
{
    self = [super init];
    if (self) {
        _heightsBySectionForPortrait = [NSMutableArray array];
        _heightsBySectionForLandscape = [NSMutableArray array];
    }
    return self;
}

- (NSMutableArray *)heightsBySectionForCurrentOrientation
{
    return UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? self.heightsBySectionForPortrait : self.heightsBySectionForLandscape;
}

- (void)enumerateAllOrientationsUsingBlock:(void (^)(NSMutableArray *heightsBySection))block
{
    block(self.heightsBySectionForPortrait);
    block(self.heightsBySectionForLandscape);
}

- (BOOL)existsHeightAtIndexPath:(NSIndexPath *)indexPath
{
    [self buildCachesAtIndexPathsIfNeeded:@[ indexPath ]];
    NSNumber *number = self.heightsBySectionForCurrentOrientation[indexPath.section][indexPath.row];
    return ![number isEqualToNumber:@-1];
}

- (void)cacheHeight:(CGFloat)height byIndexPath:(NSIndexPath *)indexPath
{
    self.automaticallyInvalidateEnabled = YES;
    [self buildCachesAtIndexPathsIfNeeded:@[ indexPath ]];
    self.heightsBySectionForCurrentOrientation[indexPath.section][indexPath.row] = @(height);
}

- (CGFloat)heightForIndexPath:(NSIndexPath *)indexPath
{
    [self buildCachesAtIndexPathsIfNeeded:@[ indexPath ]];
    NSNumber *number = self.heightsBySectionForCurrentOrientation[indexPath.section][indexPath.row];
#if CGFLOAT_IS_DOUBLE
    return number.doubleValue;
#else
    return number.floatValue;
#endif
}

- (void)invalidateHeightAtIndexPath:(NSIndexPath *)indexPath
{
    [self buildCachesAtIndexPathsIfNeeded:@[ indexPath ]];
    [self enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
        heightsBySection[indexPath.section][indexPath.row] = @-1;
    }];
}

- (void)invalidateAllHeightCache
{
    [self enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
        [heightsBySection removeAllObjects];
    }];
}

- (void)buildCachesAtIndexPathsIfNeeded:(NSArray *)indexPaths
{
    // Build every section array or row array which is smaller than given index path.
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        [self buildSectionsIfNeeded:indexPath.section];
        [self buildRowsIfNeeded:indexPath.row inExistSection:indexPath.section];
    }];
}

- (void)buildSectionsIfNeeded:(NSInteger)targetSection
{
    [self enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
        for (NSInteger section = 0; section <= targetSection; ++section) {
            if (section >= heightsBySection.count) {
                heightsBySection[section] = [NSMutableArray array];
            }
        }
    }];
}

- (void)buildRowsIfNeeded:(NSInteger)targetRow inExistSection:(NSInteger)section
{
    [self enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
        NSMutableArray *heightsByRow = heightsBySection[section];
        for (NSInteger row = 0; row <= targetRow; ++row) {
            if (row >= heightsByRow.count) {
                heightsByRow[row] = @-1;
            }
        }
    }];
}

@end

#pragma mark -
#pragma mark :. Additions

@implementation UITableView (Additions)

- (CCTableViewManger *)tabelHander
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTabelHander:(CCTableViewManger *)tabelHander
{
    if (tabelHander)
        [tabelHander handleTableViewDatasourceAndDelegate:self];
    
    objc_setAssociatedObject(self, @selector(tabelHander), tabelHander, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIViewController *)cc_vc
{
    UIViewController *curVC = [self associatedValueForKey:@selector(cc_vc)];
    if (curVC) return curVC;
    
    curVC = [self viewController];
    if (curVC) {
        self.cc_vc = curVC;
    }
    return curVC;
}

- (void)setCc_vc:(UIViewController *)cc_vc
{
    [self associateValue:cc_vc withKey:@selector(cc_vc)];
}

- (CCTableViewHelper *)cc_tableViewHelper
{
    CCTableViewHelper *curTableHelper = [self associatedValueForKey:@selector(cc_tableViewHelper)];
    if (curTableHelper) return curTableHelper;
    
    curTableHelper = [CCTableViewHelper new];
    self.cc_tableViewHelper = curTableHelper;
    return curTableHelper;
}
- (void)setCc_tableViewHelper:(CCTableViewHelper *)cc_tableViewHelper
{
    [self associateValue:cc_tableViewHelper withKey:@selector(cc_tableViewHelper)];
    self.delegate = cc_tableViewHelper;
    self.dataSource = cc_tableViewHelper;
    cc_tableViewHelper.cc_tableView = self;
}


- (BOOL)cc_autoSizingCell
{
    return [[self associatedValueForKey:@selector(cc_autoSizingCell)] boolValue];
}
- (void)setCc_autoSizingCell:(BOOL)cc_autoSizingCell
{
    [self associateValue:@(cc_autoSizingCell) withKey:@selector(cc_autoSizingCell)];
}


/**
 *  @author CC, 2015-07-23
 *
 *  @brief  隐藏TableView多余线
 *
 *  @since 1.0
 */
- (void)extraCellLineHidden
{
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor clearColor];
    [self setTableFooterView:v];
}

/**
 *  @brief  ios7设置页面的UITableViewCell样式
 *
 *  @param cell      cell
 *  @param indexPath indexPath
 */
- (void)applyiOS7SettingsStyleGrouping:(UITableViewCell *)cell
                     forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(tintColor)]) {
        CGFloat cornerRadius = 5.f;
        cell.backgroundColor = UIColor.clearColor;
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        CGMutablePathRef pathRef = CGPathCreateMutable();
        CGRect bounds = cell.bounds; // CGRectInset(cell.bounds, 10, 0);
        BOOL addLine = NO;
        if (indexPath.row == 0 && indexPath.row == [self numberOfRowsInSection:indexPath.section] - 1) {
            CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
        } else if (indexPath.row == 0) {
            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
            addLine = YES;
        } else if (indexPath.row == [self numberOfRowsInSection:indexPath.section] - 1) {
            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
        } else {
            CGPathAddRect(pathRef, nil, bounds);
            addLine = YES;
        }
        layer.path = pathRef;
        CFRelease(pathRef);
        layer.fillColor = [UIColor colorWithWhite:1.f alpha:0.8f].CGColor;
        
        if (addLine == YES) {
            CALayer *lineLayer = [[CALayer alloc] init];
            CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
            lineLayer.frame = CGRectMake(CGRectGetMinX(bounds) + 10, bounds.size.height - lineHeight, bounds.size.width - 10, lineHeight);
            lineLayer.backgroundColor = self.separatorColor.CGColor;
            [layer addSublayer:lineLayer];
        }
        UIView *testView = [[UIView alloc] initWithFrame:bounds];
        [testView.layer insertSublayer:layer atIndex:0];
        testView.backgroundColor = UIColor.clearColor;
        cell.backgroundView = testView;
    }
}

#pragma mark -
#pragma mark :. CCIndexPathHeightCache

- (CCIndexPathHeightCache *)cc_indexPathHeightCache
{
    CCIndexPathHeightCache *cache = objc_getAssociatedObject(self, _cmd);
    if (!cache) {
        [self methodSignatureForSelector:nil];
        cache = [CCIndexPathHeightCache new];
        objc_setAssociatedObject(self, _cmd, cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cache;
}

#pragma mark -
#pragma mark :. CCKeyedHeightCache

- (CCKeyedHeightCache *)cc_keyedHeightCache
{
    CCKeyedHeightCache *cache = objc_getAssociatedObject(self, _cmd);
    if (!cache) {
        cache = [CCKeyedHeightCache new];
        objc_setAssociatedObject(self, _cmd, cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cache;
}

#pragma mark -
#pragma mark :. CCTemplateLayoutCell

- (id)cc_templateCellForReuseIdentifier:(NSString *)identifier
{
    NSAssert(identifier.length > 0, @"Expect a valid identifier - %@", identifier);
    
    NSMutableDictionary *templateCellsByIdentifiers = objc_getAssociatedObject(self, _cmd);
    if (!templateCellsByIdentifiers) {
        templateCellsByIdentifiers = @{}.mutableCopy;
        objc_setAssociatedObject(self, _cmd, templateCellsByIdentifiers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    UITableViewCell *templateCell = templateCellsByIdentifiers[identifier];
    
    if (!templateCell) {
        templateCell = [self dequeueReusableCellWithIdentifier:identifier];
        NSAssert(templateCell != nil, @"Cell must be registered to table view for identifier - %@", identifier);
        templateCell.cc_isTemplateLayoutCell = YES;
        templateCell.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        templateCellsByIdentifiers[identifier] = templateCell;
    }
    
    return templateCell;
}

- (CGFloat)cc_heightForCellWithIdentifier:(NSString *)identifier configuration:(void (^)(id cell))configuration
{
    if (!identifier) {
        return 0;
    }
    
    UITableViewCell *cell = [self cc_templateCellForReuseIdentifier:identifier];
    
    // Manually calls to ensure consistent behavior with actual cells (that are displayed on screen).
    [cell prepareForReuse];
    
    // Customize and provide content for our template cell.
    if (configuration) {
        configuration(cell);
    }
    
    CGFloat contentViewWidth = CGRectGetWidth(self.frame);
    
    // If a cell has accessory view or system accessory type, its content view's width is smaller
    // than cell's by some fixed values.
    if (cell.accessoryView) {
        contentViewWidth -= 16 + CGRectGetWidth(cell.accessoryView.frame);
    } else {
        static const CGFloat systemAccessoryWidths[] = {
            [UITableViewCellAccessoryNone] = 0,
            [UITableViewCellAccessoryDisclosureIndicator] = 34,
            [UITableViewCellAccessoryDetailDisclosureButton] = 68,
            [UITableViewCellAccessoryCheckmark] = 40,
            [UITableViewCellAccessoryDetailButton] = 48};
        contentViewWidth -= systemAccessoryWidths[cell.accessoryType];
    }
    
    CGSize fittingSize = CGSizeZero;
    
    if (cell.cc_enforceFrameLayout) {
        // If not using auto layout, you have to override "-sizeThatFits:" to provide a fitting size by yourself.
        // This is the same method used in iOS8 self-sizing cell's implementation.
        // Note: fitting height should not include separator view.
        SEL selector = @selector(sizeThatFits:);
        BOOL inherited = ![cell isMemberOfClass:UITableViewCell.class];
        BOOL overrided = [cell.class instanceMethodForSelector:selector] != [UITableViewCell instanceMethodForSelector:selector];
        if (inherited && !overrided) {
            NSAssert(NO, @"Customized cell must override '-sizeThatFits:' method if not using auto layout.");
        }
        fittingSize = [cell sizeThatFits:CGSizeMake(contentViewWidth, 0)];
    } else {
        // Add a hard width constraint to make dynamic content views (like labels) expand vertically instead
        // of growing horizontally, in a flow-layout manner.
        NSLayoutConstraint *tempWidthConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:contentViewWidth];
        [cell.contentView addConstraint:tempWidthConstraint];
        // Auto layout engine does its math
        fittingSize = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        [cell.contentView removeConstraint:tempWidthConstraint];
    }
    
    // Add 1px extra space for separator line if needed, simulating default UITableViewCell.
    if (self.separatorStyle != UITableViewCellSeparatorStyleNone) {
        fittingSize.height += 1.0 / [UIScreen mainScreen].scale;
    }
    
    return fittingSize.height;
}

- (CGFloat)cc_heightForCellWithIdentifier:(NSString *)identifier cacheByIndexPath:(NSIndexPath *)indexPath configuration:(void (^)(id cell))configuration
{
    if (!identifier || !indexPath) {
        return 0;
    }
    
    // Hit cache
    if ([self.cc_indexPathHeightCache existsHeightAtIndexPath:indexPath]) {
        return [self.cc_indexPathHeightCache heightForIndexPath:indexPath];
    }
    
    CGFloat height = [self cc_heightForCellWithIdentifier:identifier configuration:configuration];
    [self.cc_indexPathHeightCache cacheHeight:height byIndexPath:indexPath];
    
    return height;
}

- (CGFloat)cc_heightForCellWithIdentifier:(NSString *)identifier cacheByKey:(id<NSCopying>)key configuration:(void (^)(id cell))configuration
{
    if (!identifier || !key) {
        return 0;
    }
    
    // Hit cache
    if ([self.cc_keyedHeightCache existsHeightForKey:key]) {
        CGFloat cachedHeight = [self.cc_keyedHeightCache heightForKey:key];
        return cachedHeight;
    }
    
    CGFloat height = [self cc_heightForCellWithIdentifier:identifier configuration:configuration];
    [self.cc_keyedHeightCache cacheHeight:height byKey:key];
    
    return height;
}


@end

@implementation UITableViewCell (CCTemplateLayoutCell)

- (BOOL)cc_isTemplateLayoutCell
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setCc_isTemplateLayoutCell:(BOOL)isTemplateLayoutCell
{
    objc_setAssociatedObject(self, @selector(cc_isTemplateLayoutCell), @(isTemplateLayoutCell), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)cc_enforceFrameLayout
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setCc_enforceFrameLayout:(BOOL)enforceFrameLayout
{
    objc_setAssociatedObject(self, @selector(cc_enforceFrameLayout), @(enforceFrameLayout), OBJC_ASSOCIATION_RETAIN);
}

@end


#pragma mark -
#pragma mark :. CCKeyedHeightCache
@interface CCKeyedHeightCache ()

@property(nonatomic, strong) NSMutableDictionary *mutableHeightsByKeyForPortrait;
@property(nonatomic, strong) NSMutableDictionary *mutableHeightsByKeyForLandscape;

@end

@implementation CCKeyedHeightCache

- (instancetype)init
{
    self = [super init];
    if (self) {
        _mutableHeightsByKeyForPortrait = [NSMutableDictionary dictionary];
        _mutableHeightsByKeyForLandscape = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSMutableDictionary *)mutableHeightsByKeyForCurrentOrientation
{
    return UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? self.mutableHeightsByKeyForPortrait : self.mutableHeightsByKeyForLandscape;
}

- (BOOL)existsHeightForKey:(id<NSCopying>)key
{
    NSNumber *number = self.mutableHeightsByKeyForCurrentOrientation[key];
    return number && ![number isEqualToNumber:@-1];
}

- (void)cacheHeight:(CGFloat)height byKey:(id<NSCopying>)key
{
    self.mutableHeightsByKeyForCurrentOrientation[key] = @(height);
}

- (CGFloat)heightForKey:(id<NSCopying>)key
{
#if CGFLOAT_IS_DOUBLE
    return [self.mutableHeightsByKeyForCurrentOrientation[key] doubleValue];
#else
    return [self.mutableHeightsByKeyForCurrentOrientation[key] floatValue];
#endif
}

- (void)invalidateHeightForKey:(id<NSCopying>)key
{
    [self.mutableHeightsByKeyForPortrait removeObjectForKey:key];
    [self.mutableHeightsByKeyForLandscape removeObjectForKey:key];
}

- (void)invalidateAllHeightCache
{
    [self.mutableHeightsByKeyForPortrait removeAllObjects];
    [self.mutableHeightsByKeyForLandscape removeAllObjects];
}

@end

#pragma mark -
#pragma mark :. CCIndexPathHeightCacheInvalidation
@implementation UITableView (CCIndexPathHeightCacheInvalidation)

- (void)cc_reloadDataWithoutInvalidateIndexPathHeightCache
{
    [self cc_reloadData]; // Primary call only
}

+ (void)load
{
    // All methods that trigger height cache's invalidation
    SEL selectors[] = {
        @selector(reloadData),
        @selector(insertSections:withRowAnimation:),
        @selector(deleteSections:withRowAnimation:),
        @selector(reloadSections:withRowAnimation:),
        @selector(moveSection:toSection:),
        @selector(insertRowsAtIndexPaths:withRowAnimation:),
        @selector(deleteRowsAtIndexPaths:withRowAnimation:),
        @selector(reloadRowsAtIndexPaths:withRowAnimation:),
        @selector(moveRowAtIndexPath:toIndexPath:)
    };
    
    for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); ++index) {
        SEL originalSelector = selectors[index];
        SEL swizzledSelector = NSSelectorFromString([@"cc_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
        Method originalMethod = class_getInstanceMethod(self, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)cc_reloadData
{
    if (self.cc_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.cc_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
            [heightsBySection removeAllObjects];
        }];
    }
    [self cc_reloadData]; // Primary call
}

- (void)cc_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    if (self.cc_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            [self.cc_indexPathHeightCache buildSectionsIfNeeded:section];
            [self.cc_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
                [heightsBySection insertObject:[NSMutableArray array] atIndex:section];
            }];
        }];
    }
    [self cc_insertSections:sections withRowAnimation:animation]; // Primary call
}

- (void)cc_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    if (self.cc_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            [self.cc_indexPathHeightCache buildSectionsIfNeeded:section];
            [self.cc_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
                [heightsBySection removeObjectAtIndex:section];
            }];
        }];
    }
    [self cc_deleteSections:sections withRowAnimation:animation]; // Primary call
}

- (void)cc_reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    if (self.cc_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            [self.cc_indexPathHeightCache buildSectionsIfNeeded:section];
            [self.cc_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
                [heightsBySection[section] removeAllObjects];
            }];
            
        }];
    }
    [self cc_reloadSections:sections withRowAnimation:animation]; // Primary call
}

- (void)cc_moveSection:(NSInteger)section toSection:(NSInteger)newSection
{
    if (self.cc_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.cc_indexPathHeightCache buildSectionsIfNeeded:section];
        [self.cc_indexPathHeightCache buildSectionsIfNeeded:newSection];
        [self.cc_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
            [heightsBySection exchangeObjectAtIndex:section withObjectAtIndex:newSection];
        }];
    }
    [self cc_moveSection:section toSection:newSection]; // Primary call
}

- (void)cc_insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    if (self.cc_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.cc_indexPathHeightCache buildCachesAtIndexPathsIfNeeded:indexPaths];
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            [self.cc_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
                NSMutableArray *rows = heightsBySection[indexPath.section];
                [rows insertObject:@-1 atIndex:indexPath.row];
            }];
        }];
    }
    [self cc_insertRowsAtIndexPaths:indexPaths withRowAnimation:animation]; // Primary call
}

- (void)cc_deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    if (self.cc_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.cc_indexPathHeightCache buildCachesAtIndexPathsIfNeeded:indexPaths];
        
        NSMutableDictionary *mutableIndexSetsToRemove = [NSMutableDictionary dictionary];
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            NSMutableIndexSet *mutableIndexSet = mutableIndexSetsToRemove[@(indexPath.section)];
            if (!mutableIndexSet) {
                mutableIndexSet = [NSMutableIndexSet indexSet];
                mutableIndexSetsToRemove[@(indexPath.section)] = mutableIndexSet;
            }
            [mutableIndexSet addIndex:indexPath.row];
        }];
        
        [mutableIndexSetsToRemove enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSIndexSet *indexSet, BOOL *stop) {
            [self.cc_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
                NSMutableArray *rows = heightsBySection[key.integerValue];
                [rows removeObjectsAtIndexes:indexSet];
            }];
        }];
    }
    [self cc_deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation]; // Primary call
}

- (void)cc_reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    if (self.cc_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.cc_indexPathHeightCache buildCachesAtIndexPathsIfNeeded:indexPaths];
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            [self.cc_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
                NSMutableArray *rows = heightsBySection[indexPath.section];
                rows[indexPath.row] = @-1;
            }];
        }];
    }
    [self cc_reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation]; // Primary call
}

- (void)cc_moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (self.cc_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.cc_indexPathHeightCache buildCachesAtIndexPathsIfNeeded:@[ sourceIndexPath, destinationIndexPath ]];
        [self.cc_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
            NSMutableArray *sourceRows = heightsBySection[sourceIndexPath.section];
            NSMutableArray *destinationRows = heightsBySection[destinationIndexPath.section];
            NSNumber *sourceValue = sourceRows[sourceIndexPath.row];
            NSNumber *destinationValue = destinationRows[destinationIndexPath.row];
            sourceRows[sourceIndexPath.row] = destinationValue;
            destinationRows[destinationIndexPath.row] = sourceValue;
        }];
    }
    [self cc_moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath]; // Primary call
}

@end

