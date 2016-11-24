//
//  UICollectionView+Additions.m
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

#import "UICollectionView+Additions.h"
#import "CCCollectionViewHelper.h"
#import "NSObject+Additions.h"
#import <objc/runtime.h>

#pragma mark -
#pragma mark :. CCIndexPathSizeCache

typedef NSMutableArray<NSMutableArray<NSNumber *> *> CCIndexPathSizesBySection;

@interface CCIndexPathSizeCache ()

@property(nonatomic, strong) CCIndexPathSizesBySection *SizesBySectionForPortrait;
@property(nonatomic, strong) CCIndexPathSizesBySection *SizesBySectionForLandscape;

@end

@implementation CCIndexPathSizeCache

- (instancetype)init
{
    self = [super init];
    if (self) {
        _SizesBySectionForPortrait = [NSMutableArray array];
        _SizesBySectionForLandscape = [NSMutableArray array];
    }
    return self;
}

- (CCIndexPathSizesBySection *)SizesBySectionForCurrentOrientation
{
    return UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? self.SizesBySectionForPortrait : self.SizesBySectionForLandscape;
}

- (void)enumerateAllOrientationsUsingBlock:(void (^)(CCIndexPathSizesBySection *SizesBySection))block
{
    block(self.SizesBySectionForPortrait);
    block(self.SizesBySectionForLandscape);
}

- (BOOL)existsSizeAtIndexPath:(NSIndexPath *)indexPath
{
    [self buildCachesAtIndexPathsIfNeeded:@[ indexPath ]];
    NSNumber *number = self.SizesBySectionForCurrentOrientation[indexPath.section][indexPath.row];
    return ![number isEqualToNumber:@-1];
}

- (void)cacheSize:(CGSize)size byIndexPath:(NSIndexPath *)indexPath
{
    self.automaticallyInvalidateEnabled = YES;
    [self buildCachesAtIndexPathsIfNeeded:@[ indexPath ]];
    self.SizesBySectionForCurrentOrientation[indexPath.section][indexPath.row] = [NSValue valueWithCGSize:size];
}

- (CGSize)sizeForIndexPath:(NSIndexPath *)indexPath
{
    [self buildCachesAtIndexPathsIfNeeded:@[ indexPath ]];
    NSValue *value = self.SizesBySectionForCurrentOrientation[indexPath.section][indexPath.row];
    return value.CGSizeValue;
}

- (void)invalidateSizeAtIndexPath:(NSIndexPath *)indexPath
{
    [self buildCachesAtIndexPathsIfNeeded:@[ indexPath ]];
    [self enumerateAllOrientationsUsingBlock:^(CCIndexPathSizesBySection *sizesBySection) {
        sizesBySection[indexPath.section][indexPath.row] = @-1;
    }];
}

- (void)invalidateAllSizeCache
{
    [self enumerateAllOrientationsUsingBlock:^(CCIndexPathSizesBySection *sizesBySection) {
        [sizesBySection removeAllObjects];
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
    [self enumerateAllOrientationsUsingBlock:^(CCIndexPathSizesBySection *sizesBySection) {
        for (NSInteger section = 0; section <= targetSection; ++section) {
            if (section >= sizesBySection.count) {
                sizesBySection[section] = [NSMutableArray array];
            }
        }
    }];
}

- (void)buildRowsIfNeeded:(NSInteger)targetRow inExistSection:(NSInteger)section
{
    [self enumerateAllOrientationsUsingBlock:^(CCIndexPathSizesBySection *sizesBySection) {
        NSMutableArray<NSNumber *> *sizesByRow = sizesBySection[section];
        for (NSInteger row = 0; row <= targetRow; ++row) {
            if (row >= sizesByRow.count) {
                sizesByRow[row] = @-1;
            }
        }
    }];
}

@end

#pragma mark -
#pragma mark :. CCKeyedHeightCache
@interface CCKeyedSizeCache ()

@property(nonatomic, strong) NSMutableDictionary *mutableSizesByKeyForPortrait;
@property(nonatomic, strong) NSMutableDictionary *mutableSizesByKeyForLandscape;

@end

@implementation CCKeyedSizeCache

- (instancetype)init
{
    self = [super init];
    if (self) {
        _mutableSizesByKeyForPortrait = [NSMutableDictionary dictionary];
        _mutableSizesByKeyForLandscape = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSMutableDictionary *)mutableSizesByKeyForCurrentOrientation
{
    return UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? self.mutableSizesByKeyForPortrait : self.mutableSizesByKeyForLandscape;
}

- (BOOL)existsHeightForKey:(id<NSCopying>)key
{
    NSNumber *number = self.mutableSizesByKeyForCurrentOrientation[key];
    return number && ![number isEqualToNumber:@-1];
}

- (void)cacheSize:(CGSize)size byKey:(id<NSCopying>)key
{
    self.mutableSizesByKeyForCurrentOrientation[key] = [NSValue valueWithCGSize:size];
}

- (CGSize)sizeForKey:(id<NSCopying>)key
{
    return [self.mutableSizesByKeyForCurrentOrientation[key] CGSizeValue];
}

- (void)invalidateHeightForKey:(id<NSCopying>)key
{
    [self.mutableSizesByKeyForPortrait removeObjectForKey:key];
    [self.mutableSizesByKeyForLandscape removeObjectForKey:key];
}

- (void)invalidateAllHeightCache
{
    [self.mutableSizesByKeyForPortrait removeAllObjects];
    [self.mutableSizesByKeyForLandscape removeAllObjects];
}

@end

@implementation UICollectionView (Additions)

- (CCCollectionViewHelper *)cc_collectionViewHelper
{
    CCCollectionViewHelper *curTableHelper = [self associatedValueForKey:@selector(cc_collectionViewHelper)];
    if (curTableHelper) return curTableHelper;
    
    curTableHelper = [CCCollectionViewHelper new];
    self.cc_collectionViewHelper = curTableHelper;
    return curTableHelper;
}
- (void)setCc_collectionViewHelper:(CCCollectionViewHelper *)cc_collectionViewHelper
{
    [self associateValue:cc_collectionViewHelper withKey:@selector(cc_collectionViewHelper)];
    self.delegate = cc_collectionViewHelper;
    self.dataSource = cc_collectionViewHelper;
    cc_collectionViewHelper.cc_CollectionView = self;
}

#pragma mark -
#pragma mark :. CCIndexPathSizeCache

- (CCIndexPathSizeCache *)cc_indexPathSizeCache
{
    CCIndexPathSizeCache *cache = objc_getAssociatedObject(self, _cmd);
    if (!cache) {
        [self methodSignatureForSelector:nil];
        cache = [CCIndexPathSizeCache new];
        objc_setAssociatedObject(self, _cmd, cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cache;
}

#pragma mark -
#pragma mark :. CCKeyedSizeCache

- (CCKeyedSizeCache *)cc_keyedSizeCache
{
    CCKeyedSizeCache *cache = objc_getAssociatedObject(self, _cmd);
    if (!cache) {
        cache = [CCKeyedSizeCache new];
        objc_setAssociatedObject(self, _cmd, cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cache;
}


#pragma mark -
#pragma mark :. CCTemplateLayoutCell

- (CGSize)cc_systemFittingHeightForConfiguratedCell:(UICollectionViewCell *)cell
{
    CGSize contentSize = self.frame.size;
    if (!cell.cc_enforceFrameLayout && contentSize.width > 0) {
        // Add a hard width constraint to make dynamic content views (like labels) expand vertically instead
        // of growing horizontally, in a flow-layout manner.
        NSLayoutConstraint *widthFenceConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:contentSize.width];
        [cell.contentView addConstraint:widthFenceConstraint];
        
        // Auto layout engine does its math
        contentSize = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        [cell.contentView removeConstraint:widthFenceConstraint];
    }
    
    if (contentSize.height == 0) {
#if DEBUG
        // Warn if using AutoLayout but get zero height.
        if (cell.contentView.constraints.count > 0) {
            if (!objc_getAssociatedObject(self, _cmd)) {
                NSLog(@"[CCTemplateLayoutCell] Warning once only: Cannot get a proper cell height (now 0) from '- systemFittingSize:'(AutoLayout). You should check how constraints are built in cell, making it into 'self-sizing' cell.");
                objc_setAssociatedObject(self, _cmd, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
#endif
        // Try '- sizeThatFits:' for frame layout.
        // Note: fitting height should not include separator view.
        contentSize = [cell sizeThatFits:CGSizeMake(contentSize.width, 0)];
    }
    
    // Still zero height after all above.
    if (contentSize.height == 0) {
        // Use default row height.
        contentSize.height = 44;
    }
    
    return contentSize;
}

- (__kindof UICollectionViewCell *)cc_templateCellForReuseIdentifier:(NSString *)identifier
{
    NSAssert(identifier.length > 0, @"Expect a valid identifier - %@", identifier);
    
    NSMutableDictionary<NSString *, UITableViewCell *> *templateCellsByIdentifiers = objc_getAssociatedObject(self, _cmd);
    if (!templateCellsByIdentifiers) {
        templateCellsByIdentifiers = @{}.mutableCopy;
        objc_setAssociatedObject(self, _cmd, templateCellsByIdentifiers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    UICollectionViewCell *templateCell = templateCellsByIdentifiers[identifier];
    
    if (!templateCell) {
        Class class = NSClassFromString(identifier);
        templateCell = [[class alloc] init];
        NSAssert(templateCell != nil, @"Cell must be registered to table view for identifier - %@", identifier);
        templateCell.cc_isTemplateLayoutCell = YES;
        templateCell.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        templateCellsByIdentifiers[identifier] = templateCell;
    }
    
    return templateCell;
}

- (CGSize)cc_SizeForCellWithIdentifier:(NSString *)identifier configuration:(void (^)(id cell))configuration
{
    if (!identifier) {
        return CGSizeMake(0, 0);
    }
    
    UITableViewCell *templateLayoutCell = [self cc_templateCellForReuseIdentifier:identifier];
    
    // Manually calls to ensure consistent behavior with actual cells. (that are displayed on screen)
    [templateLayoutCell prepareForReuse];
    
    // Customize and provide content for our template cell.
    if (configuration) {
        configuration(templateLayoutCell);
    }
    
    return [self cc_systemFittingHeightForConfiguratedCell:templateLayoutCell];
}

- (CGSize)cc_heightForCellWithIdentifier:(NSString *)identifier cacheByIndexPath:(NSIndexPath *)indexPath configuration:(void (^)(id cell))configuration
{
    CGSize viewSize = CGSizeMake(0, 0);
    if (!identifier || !indexPath) {
        return viewSize;
    }
    
    // Hit cache
    if ([self.cc_indexPathSizeCache existsSizeAtIndexPath:indexPath]) {
        return [self.cc_indexPathSizeCache sizeForIndexPath:indexPath];
    }
    
    viewSize = [self cc_SizeForCellWithIdentifier:identifier configuration:configuration];
    [self.cc_indexPathSizeCache cacheSize:viewSize byIndexPath:indexPath];
    
    return viewSize;
}

- (CGSize)cc_heightForCellWithIdentifier:(NSString *)identifier cacheByKey:(id<NSCopying>)key configuration:(void (^)(id cell))configuration
{
     CGSize contentSize = CGSizeMake(0, 0);
    if (!identifier || !key) {
        return contentSize;
    }
    
    // Hit cache
    if ([self.cc_keyedSizeCache existsSizeForKey:key]) {
        contentSize = [self.cc_keyedSizeCache sizeForKey:key];
        return contentSize;
    }
    
    contentSize = [self cc_SizeForCellWithIdentifier:identifier configuration:configuration];
    [self.cc_keyedSizeCache cacheSize:contentSize byKey:key];
    
    return contentSize;
}

@end

@implementation UICollectionViewCell (CCTemplateLayoutCell)

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
