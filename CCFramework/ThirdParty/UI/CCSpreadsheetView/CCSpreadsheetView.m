//
//  CCSpreadsheetView.m
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

#import "CCSpreadsheetView.h"
#import <QuartzCore/QuartzCore.h>
#import "CCGridLayout.h"
#import "NSIndexPath+CCSpreadsheetView.h"

typedef NS_ENUM(NSUInteger, CCSpreadsheetViewCollection) {
    CCSpreadsheetViewCollectionUpperLeft = 1,
    CCSpreadsheetViewCollectionUpperRight,
    CCSpreadsheetViewCollectionLowerLeft,
    CCSpreadsheetViewCollectionLowerRight,
};


const static CGFloat CCSpreadsheetViewGridSpace = .2f;
const static CGFloat CCSpreadsheetViewScrollIndicatorWidth = 5.0f;
const static CGFloat CCSpreadsheetViewScrollIndicatorSpace = 3.0f;
const static CGFloat CCSpreadsheetViewScrollIndicatorMinimum = 25.0f;
const static CGFloat MMScrollIndicatorDefaultInsetSpace = 2.0f;
const static NSUInteger MMScrollIndicatorTag = 12345;

@interface CCSpreadsheetView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property(nonatomic, assign) NSUInteger headerRowCount;
@property(nonatomic, assign) NSUInteger headerColumnCount;
@property(nonatomic, assign) CCSpreadsheetHeaderConfiguration spreadsheetHeaderConfiguration;
@property(nonatomic, strong) UIScrollView *controllingScrollView;

@property(nonatomic, strong) UIView *upperLeftContainerView;
@property(nonatomic, strong) UIView *upperRightContainerView;
@property(nonatomic, strong) UIView *lowerLeftContainerView;
@property(nonatomic, strong) UIView *lowerRightContainerView;

@property(nonatomic, strong) UICollectionView *upperLeftCollectionView;
@property(nonatomic, strong) UICollectionView *upperRightCollectionView;
@property(nonatomic, strong) UICollectionView *lowerLeftCollectionView;
@property(nonatomic, strong) UICollectionView *lowerRightCollectionView;

@property(nonatomic, assign, getter=isUpperRightBouncing) BOOL upperRightBouncing;
@property(nonatomic, assign, getter=isLowerLeftBouncing) BOOL lowerLeftBouncing;
@property(nonatomic, assign, getter=isLowerRightBouncing) BOOL lowerRightBouncing;

@property(nonatomic, strong) UIView *verticalScrollIndicator;
@property(nonatomic, strong) UIView *horizontalScrollIndicator;

@property(nonatomic, strong) UICollectionView *selectedItemCollectionView;
@property(nonatomic, strong) NSIndexPath *selectedItemIndexPath;

@end


@implementation CCSpreadsheetView

- (id)init
{
    return [self initWithNumberOfHeaderRows:CGRectZero SpreadsheetType:CCSpreadsheetHeaderConfigurationNone];
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithNumberOfHeaderRows:frame SpreadsheetType:CCSpreadsheetHeaderConfigurationNone];
}

#pragma mark - CCSpreadsheetView designated initializer

- (id)initWithNumberOfHeaderRows:(CGRect)frame SpreadsheetType:(CCSpreadsheetHeaderConfiguration)spreadsheetType
{
    self = [super initWithFrame:frame];
    if (self) {
        _scrollIndicatorInsets = UIEdgeInsetsZero;
        _showsVerticalScrollIndicator = YES;
        _showsHorizontalScrollIndicator = YES;
        _spreadsheetHeaderConfiguration = spreadsheetType;
        
        switch (spreadsheetType) {
            case CCSpreadsheetHeaderConfigurationNone:
                _headerRowCount = 0;
                _headerColumnCount = 0;
                break;
            case CCSpreadsheetHeaderConfigurationColumnOnly:
                _headerRowCount = 1;
                _headerColumnCount = 0;
                break;
            case CCSpreadsheetHeaderConfigurationRowOnly:
                _headerRowCount = 0;
                _headerColumnCount = 1;
                break;
            case CCSpreadsheetHeaderConfigurationBoth:
                _headerRowCount = 1;
                _headerColumnCount = 1;
                break;
                
            default:
                break;
        }
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor grayColor];
        [self setupSubviews];
    }
    return self;
}

#pragma mark - Public Functions

- (UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *collectionViewIndexPath = [self collectionViewIndexPathFromDataSourceIndexPath:indexPath];
    UICollectionView *collectionView = [self collectionViewForDataSourceIndexPath:indexPath];
    NSAssert(collectionView, @"No collectionView Returned!");
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:collectionViewIndexPath];
    return cell;
}

- (void)registerCellClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier
{
    [self.upperLeftCollectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
    [self.upperRightCollectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
    [self.lowerLeftCollectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
    [self.lowerRightCollectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}

- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    NSIndexPath *collectionViewIndexPath = [self collectionViewIndexPathFromDataSourceIndexPath:indexPath];
    UICollectionView *collectionView = [self collectionViewForDataSourceIndexPath:indexPath];
    NSAssert(collectionView, @"No collectionView Returned!");
    [collectionView deselectItemAtIndexPath:collectionViewIndexPath animated:animated];
}

- (void)reloadData
{
    [self.upperLeftCollectionView reloadData];
    [self.upperRightCollectionView reloadData];
    [self.lowerLeftCollectionView reloadData];
    [self.lowerRightCollectionView reloadData];
}

- (void)flashScrollIndicators
{
    [self showScrollIndicators];
    [self performSelector:@selector(hideScrollIndicators) withObject:nil afterDelay:1];
}

#pragma mark - View Setup functions

- (void)setupSubviews
{
    switch (self.spreadsheetHeaderConfiguration) {
        case CCSpreadsheetHeaderConfigurationNone:
            [self setupLowerRightView];
            break;
            
        case CCSpreadsheetHeaderConfigurationColumnOnly:
            [self setupLowerLeftView];
            [self setupLowerRightView];
            break;
            
        case CCSpreadsheetHeaderConfigurationRowOnly:
            [self setupUpperRightView];
            [self setupLowerRightView];
            break;
            
        case CCSpreadsheetHeaderConfigurationBoth:
            [self setupUpperLeftView];
            [self setupUpperRightView];
            [self setupLowerLeftView];
            [self setupLowerRightView];
            break;
            
        default:
            NSAssert(NO, @"What have you done?");
            break;
    }
    self.verticalScrollIndicator = [self setupScrollIndicator];
    self.horizontalScrollIndicator = [self setupScrollIndicator];
}

- (void)setupContainerSubview:(UIView *)container collectionView:(UICollectionView *)collectionView tag:(NSInteger)tag
{
    container.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:container];
    
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.tag = tag;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    [container addSubview:collectionView];
}

- (UICollectionView *)setupCollectionViewWithGridLayout
{
    CCGridLayout *layout = [[CCGridLayout alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    return collectionView;
}

- (void)setupUpperLeftView
{
    self.upperLeftContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.upperLeftCollectionView = [self setupCollectionViewWithGridLayout];
    [self setupContainerSubview:self.upperLeftContainerView
                 collectionView:self.upperLeftCollectionView
                            tag:CCSpreadsheetViewCollectionUpperLeft];
    self.upperLeftCollectionView.scrollEnabled = NO;
}

- (void)setupUpperRightView
{
    self.upperRightContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.upperRightCollectionView = [self setupCollectionViewWithGridLayout];
    [self.upperRightCollectionView.panGestureRecognizer addTarget:self
                                                           action:@selector(handleUpperRightPanGesture:)];
    [self setupContainerSubview:self.upperRightContainerView
                 collectionView:self.upperRightCollectionView
                            tag:CCSpreadsheetViewCollectionUpperRight];
}

- (void)setupLowerLeftView
{
    self.lowerLeftContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.lowerLeftCollectionView = [self setupCollectionViewWithGridLayout];
    [self.lowerLeftCollectionView.panGestureRecognizer addTarget:self
                                                          action:@selector(handleLowerLeftPanGesture:)];
    [self setupContainerSubview:self.lowerLeftContainerView
                 collectionView:self.lowerLeftCollectionView
                            tag:CCSpreadsheetViewCollectionLowerLeft];
}

- (void)setupLowerRightView
{
    self.lowerRightContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.lowerRightCollectionView = [self setupCollectionViewWithGridLayout];
    [self.lowerRightCollectionView.panGestureRecognizer addTarget:self
                                                           action:@selector(handleLowerRightPanGesture:)];
    [self setupContainerSubview:self.lowerRightContainerView
                 collectionView:self.lowerRightCollectionView
                            tag:CCSpreadsheetViewCollectionLowerRight];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    NSIndexPath *indexPathZero = [NSIndexPath indexPathForItem:0 inSection:0];
    switch (self.spreadsheetHeaderConfiguration) {
        case CCSpreadsheetHeaderConfigurationNone:
            self.lowerRightContainerView.frame = self.bounds;
            break;
            
        case CCSpreadsheetHeaderConfigurationColumnOnly: {
            CGSize size = self.lowerLeftCollectionView.collectionViewLayout.collectionViewContentSize;
            CGSize cellSize = [self collectionView:self.lowerRightCollectionView
                                            layout:self.lowerRightCollectionView.collectionViewLayout
                            sizeForItemAtIndexPath:indexPathZero];
            CGFloat maxLockDistance = self.bounds.size.width - cellSize.width;
            if (size.width > maxLockDistance) {
                NSAssert(NO, @"Width of header too large! Reduce the number of header columns.");
            }
            self.lowerLeftContainerView.frame = CGRectMake(0.0f,
                                                           0.0f,
                                                           size.width,
                                                           self.bounds.size.height);
            self.lowerRightContainerView.frame = CGRectMake(size.width + CCSpreadsheetViewGridSpace,
                                                            0.0f,
                                                            self.bounds.size.width - size.width - CCSpreadsheetViewGridSpace,
                                                            self.bounds.size.height);
            break;
        }
            
        case CCSpreadsheetHeaderConfigurationRowOnly: {
            CGSize size = self.upperRightCollectionView.collectionViewLayout.collectionViewContentSize;
            CGSize cellSize = [self collectionView:self.lowerRightCollectionView
                                            layout:self.lowerRightCollectionView.collectionViewLayout
                            sizeForItemAtIndexPath:indexPathZero];
            CGFloat maxLockDistance = self.bounds.size.height - cellSize.height;
            if (size.height > maxLockDistance) {
                NSAssert(NO, @"Height of header too large! Reduce the number of header rows.");
            }
            self.upperRightContainerView.frame = CGRectMake(0.0f,
                                                            0.0f,
                                                            self.bounds.size.width,
                                                            size.height);
            self.lowerRightContainerView.frame = CGRectMake(0.0f,
                                                            size.height + CCSpreadsheetViewGridSpace,
                                                            self.bounds.size.width,
                                                            self.bounds.size.height - size.height - CCSpreadsheetViewGridSpace);
            break;
        }
            
        case CCSpreadsheetHeaderConfigurationBoth: {
            CGSize size = self.upperLeftCollectionView.collectionViewLayout.collectionViewContentSize;
            CGSize cellSize = [self collectionView:self.lowerRightCollectionView
                                            layout:self.lowerRightCollectionView.collectionViewLayout
                            sizeForItemAtIndexPath:indexPathZero];
            CGFloat maxLockDistance = self.bounds.size.height - cellSize.height;
            if (size.height > maxLockDistance) {
                NSAssert(NO, @"Height of header too large! Reduce the number of header rows.");
            }
            maxLockDistance = self.bounds.size.width - cellSize.width;
            if (size.width > maxLockDistance) {
                NSAssert(NO, @"Width of header too large! Reduce the number of header columns.");
            }
            
            self.upperLeftContainerView.frame = CGRectMake(0.0f,
                                                           0.0f,
                                                           size.width,
                                                           size.height);
            self.upperRightContainerView.frame = CGRectMake(size.width + CCSpreadsheetViewGridSpace,
                                                            0.0f,
                                                            self.bounds.size.width - size.width - CCSpreadsheetViewGridSpace,
                                                            size.height);
            self.lowerLeftContainerView.frame = CGRectMake(0.0f,
                                                           size.height + CCSpreadsheetViewGridSpace,
                                                           size.width,
                                                           self.bounds.size.height - size.height - CCSpreadsheetViewGridSpace);
            self.lowerRightContainerView.frame = CGRectMake(size.width + CCSpreadsheetViewGridSpace,
                                                            size.height + CCSpreadsheetViewGridSpace,
                                                            self.bounds.size.width - size.width - CCSpreadsheetViewGridSpace,
                                                            self.bounds.size.height - size.height - CCSpreadsheetViewGridSpace);
            break;
        }
            
        default:
            NSAssert(NO, @"What have you done?");
            break;
    }
    
    // Resize the indicators.
    self.verticalScrollIndicator.frame = CGRectMake(self.frame.size.width - CCSpreadsheetViewScrollIndicatorWidth - self.scrollIndicatorInsets.right - MMScrollIndicatorDefaultInsetSpace,
                                                    self.scrollIndicatorInsets.top + CCSpreadsheetViewScrollIndicatorSpace,
                                                    CCSpreadsheetViewScrollIndicatorWidth,
                                                    self.frame.size.height - 4 * CCSpreadsheetViewScrollIndicatorSpace);
    [self updateVerticalScrollIndicator];
    
    self.horizontalScrollIndicator.frame = CGRectMake(self.scrollIndicatorInsets.left + CCSpreadsheetViewScrollIndicatorSpace,
                                                      self.frame.size.height - CCSpreadsheetViewScrollIndicatorWidth - self.scrollIndicatorInsets.bottom - MMScrollIndicatorDefaultInsetSpace,
                                                      self.frame.size.width - 4 * CCSpreadsheetViewScrollIndicatorSpace,
                                                      CCSpreadsheetViewScrollIndicatorWidth);
    [self updateHorizontalScrollIndicator];
}

#pragma mark - UIPanGestureRecognizer callbacks

- (void)handleUpperRightPanGesture:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.lowerLeftContainerView.userInteractionEnabled = NO;
        self.lowerRightContainerView.userInteractionEnabled = NO;
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (self.isUpperRightBouncing == NO) {
            self.lowerLeftContainerView.userInteractionEnabled = YES;
            self.lowerRightContainerView.userInteractionEnabled = YES;
        }
    }
}

- (void)handleLowerLeftPanGesture:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.upperRightContainerView.userInteractionEnabled = NO;
        self.lowerRightContainerView.userInteractionEnabled = NO;
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (self.isLowerLeftBouncing == NO) {
            self.upperRightContainerView.userInteractionEnabled = YES;
            self.lowerRightContainerView.userInteractionEnabled = YES;
        }
    }
}

- (void)handleLowerRightPanGesture:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.upperRightContainerView.userInteractionEnabled = NO;
        self.lowerLeftContainerView.userInteractionEnabled = NO;
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (self.isLowerRightBouncing == NO) {
            self.upperRightContainerView.userInteractionEnabled = YES;
            self.lowerLeftContainerView.userInteractionEnabled = YES;
        }
    }
}

#pragma mark - bounces property setter

- (void)setBounces:(BOOL)bounces
{
    _bounces = bounces;
    self.upperLeftCollectionView.bounces = bounces;
    self.upperRightCollectionView.bounces = bounces;
    self.lowerLeftCollectionView.bounces = bounces;
    self.lowerRightCollectionView.bounces = bounces;
}

#pragma mark - DataSource property setter

- (void)setDataSource:(id<CCSpreadsheetViewDataSource>)dataSource
{
    _dataSource = dataSource;
    if (self.upperLeftCollectionView) {
        [self initializeCollectionViewLayoutItemSize:self.upperLeftCollectionView];
    }
    if (self.upperRightCollectionView) {
        [self initializeCollectionViewLayoutItemSize:self.upperRightCollectionView];
    }
    if (self.lowerLeftCollectionView) {
        [self initializeCollectionViewLayoutItemSize:self.lowerLeftCollectionView];
    }
    if (self.lowerRightCollectionView) {
        [self initializeCollectionViewLayoutItemSize:self.lowerRightCollectionView];
    }
    
    // Validate dataSource & header configuration
    NSInteger maxRows = [_dataSource numberOfRowsInSpreadsheetView:self];
    NSInteger maxCols = [_dataSource numberOfColumnsInSpreadsheetView:self];
    
    if (self.headerColumnCount < maxCols)
        NSAssert(self.headerColumnCount < maxCols, @"Invalid configuration: number of header columns must be less than (dataSource) numberOfColumnsInSpreadsheetView");
    
    if (self.headerRowCount < maxRows)
        NSAssert(self.headerRowCount < maxRows, @"Invalid configuration: number of header rows must be less than (dataSource) numberOfRowsInSpreadsheetView");
}

- (void)initializeCollectionViewLayoutItemSize:(UICollectionView *)collectionView
{
    NSIndexPath *indexPathZero = [NSIndexPath indexPathForItem:0 inSection:0];
    CCGridLayout *layout = (CCGridLayout *)collectionView.collectionViewLayout;
    CGSize size = [self collectionView:collectionView
                                layout:layout
                sizeForItemAtIndexPath:indexPathZero];
    layout.itemSize = size;
}

#pragma mark - Scroll Indicator

- (UIView *)setupScrollIndicator
{
    UIView *scrollIndicator = [[UIView alloc] initWithFrame:CGRectZero];
    scrollIndicator.alpha = 0.0f;
    scrollIndicator.layer.cornerRadius = CCSpreadsheetViewScrollIndicatorWidth / 2;
    scrollIndicator.clipsToBounds = YES;
    [self addSubview:scrollIndicator];
    
    UIView *scrollIndicatorSegment = [[UIView alloc] initWithFrame:CGRectZero];
    scrollIndicatorSegment.backgroundColor = [UIColor colorWithWhite:0.44f alpha:1.0f];
    scrollIndicatorSegment.layer.cornerRadius = CCSpreadsheetViewScrollIndicatorWidth / 2;
    scrollIndicatorSegment.tag = MMScrollIndicatorTag;
    [scrollIndicator addSubview:scrollIndicatorSegment];
    
    return scrollIndicator;
}

- (void)showScrollIndicators
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideScrollIndicators) object:nil];
    [UIView animateWithDuration:0.4f animations:^{
        self.verticalScrollIndicator.alpha = self.showsVerticalScrollIndicator ? 1.0f : 0.0f;
        self.horizontalScrollIndicator.alpha = self.showsHorizontalScrollIndicator ? 1.0f : 0.0f;
    }];
}

- (void)hideScrollIndicators
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showScrollIndicators) object:nil];
    [UIView animateWithDuration:0.5f animations:^{
        self.verticalScrollIndicator.alpha = 0.0f;
        self.horizontalScrollIndicator.alpha = 0.0f;
    }];
}

- (void)updateVerticalScrollIndicator
{
    if (self.showsVerticalScrollIndicator) {
        UIView *scrollIndicator = self.verticalScrollIndicator;
        UIView *indicatorView = [scrollIndicator viewWithTag:MMScrollIndicatorTag];
        UICollectionView *collectionView = self.lowerRightCollectionView;
        CGSize contentSize = collectionView.collectionViewLayout.collectionViewContentSize;
        CGRect collectionViewFrame = collectionView.frame;
        
        if (collectionViewFrame.size.height > contentSize.height) {
            indicatorView.frame = CGRectZero;
        } else {
            CGFloat indicatorHeight = collectionViewFrame.size.height / contentSize.height * scrollIndicator.frame.size.height;
            if (indicatorHeight < CCSpreadsheetViewScrollIndicatorMinimum) {
                indicatorHeight = CCSpreadsheetViewScrollIndicatorMinimum;
            }
            CGFloat indicatorOffsetY = collectionView.contentOffset.y / (contentSize.height - collectionViewFrame.size.height) * (scrollIndicator.frame.size.height - indicatorHeight);
            indicatorView.frame = CGRectMake(0.0f,
                                             indicatorOffsetY,
                                             CCSpreadsheetViewScrollIndicatorWidth,
                                             indicatorHeight);
        }
    }
}

- (void)updateHorizontalScrollIndicator
{
    if (self.showsHorizontalScrollIndicator) {
        UIView *scrollIndicator = self.horizontalScrollIndicator;
        UIView *indicatorView = [scrollIndicator viewWithTag:MMScrollIndicatorTag];
        UICollectionView *collectionView = self.lowerRightCollectionView;
        CGSize contentSize = collectionView.collectionViewLayout.collectionViewContentSize;
        CGRect collectionViewFrame = collectionView.frame;
        
        if (collectionView.frame.size.width > contentSize.width) {
            indicatorView.frame = CGRectZero;
        } else {
            CGFloat indicatorWidth = collectionViewFrame.size.width / contentSize.width * scrollIndicator.frame.size.width;
            if (indicatorWidth < CCSpreadsheetViewScrollIndicatorMinimum) {
                indicatorWidth = CCSpreadsheetViewScrollIndicatorMinimum;
            }
            CGFloat indicatorOffsetX = collectionView.contentOffset.x / (contentSize.width - collectionViewFrame.size.width) * (scrollIndicator.frame.size.width - indicatorWidth);
            indicatorView.frame = CGRectMake(indicatorOffsetX,
                                             0.0f,
                                             indicatorWidth,
                                             CCSpreadsheetViewScrollIndicatorWidth);
        }
    }
}

#pragma mark - Custom functions that don't go anywhere else

- (UICollectionView *)collectionViewForDataSourceIndexPath:(NSIndexPath *)indexPath
{
    UICollectionView *collectionView = nil;
    switch (self.spreadsheetHeaderConfiguration) {
        case CCSpreadsheetHeaderConfigurationNone:
            collectionView = self.lowerRightCollectionView;
            break;
            
        case CCSpreadsheetHeaderConfigurationColumnOnly:
            if (indexPath.ccSpreadsheetColumn >= self.headerColumnCount) {
                collectionView = self.lowerRightCollectionView;
            } else {
                collectionView = self.lowerLeftCollectionView;
            }
            break;
            
        case CCSpreadsheetHeaderConfigurationRowOnly:
            if (indexPath.ccSpreadsheetRow >= self.headerRowCount) {
                collectionView = self.lowerRightCollectionView;
            } else {
                collectionView = self.upperRightCollectionView;
            }
            break;
            
        case CCSpreadsheetHeaderConfigurationBoth:
            if (indexPath.ccSpreadsheetRow >= self.headerRowCount) {
                if (indexPath.ccSpreadsheetColumn >= self.headerColumnCount) {
                    collectionView = self.lowerRightCollectionView;
                } else {
                    collectionView = self.lowerLeftCollectionView;
                }
            } else {
                if (indexPath.ccSpreadsheetColumn >= self.headerColumnCount) {
                    collectionView = self.upperRightCollectionView;
                } else {
                    collectionView = self.upperLeftCollectionView;
                }
            }
            break;
            
        default:
            NSAssert(NO, @"What have you done?");
            break;
    }
    return collectionView;
}

- (NSIndexPath *)dataSourceIndexPathFromCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath
{
    NSInteger ccSpreadsheetRow = indexPath.ccSpreadsheetRow;
    NSInteger ccSpreadsheetColumn = indexPath.ccSpreadsheetColumn;
    
    if (collectionView != nil) {
        switch (collectionView.tag) {
            case CCSpreadsheetViewCollectionUpperLeft:
                break;
                
            case CCSpreadsheetViewCollectionUpperRight:
                ccSpreadsheetColumn += self.headerColumnCount;
                break;
                
            case CCSpreadsheetViewCollectionLowerLeft:
                ccSpreadsheetRow += self.headerRowCount;
                break;
                
            case CCSpreadsheetViewCollectionLowerRight:
                ccSpreadsheetRow += self.headerRowCount;
                ccSpreadsheetColumn += self.headerColumnCount;
                break;
                
            default:
                NSAssert(NO, @"What have you done?");
                break;
        }
    }
    return [NSIndexPath indexPathForItem:ccSpreadsheetColumn inSection:ccSpreadsheetRow];
}

- (NSIndexPath *)collectionViewIndexPathFromDataSourceIndexPath:(NSIndexPath *)indexPath
{
    UICollectionView *collectionView = [self collectionViewForDataSourceIndexPath:indexPath];
    NSAssert(collectionView, @"No collectionView Returned!");
    
    NSInteger ccSpreadsheetRow = indexPath.ccSpreadsheetRow;
    NSInteger ccSpreadsheetColumn = indexPath.ccSpreadsheetColumn;
    
    switch (collectionView.tag) {
        case CCSpreadsheetViewCollectionUpperLeft:
            break;
            
        case CCSpreadsheetViewCollectionUpperRight:
            ccSpreadsheetColumn -= self.headerColumnCount;
            break;
            
        case CCSpreadsheetViewCollectionLowerLeft:
            ccSpreadsheetRow -= self.headerRowCount;
            break;
            
        case CCSpreadsheetViewCollectionLowerRight:
            ccSpreadsheetRow -= self.headerRowCount;
            ccSpreadsheetColumn -= self.headerColumnCount;
            break;
            
        default:
            NSAssert(NO, @"What have you done?");
            break;
    }
    return [NSIndexPath indexPathForItem:ccSpreadsheetColumn inSection:ccSpreadsheetRow];
}

- (void)setScrollEnabledValue:(BOOL)scrollEnabled scrollView:(UIScrollView *)scrollView
{
    switch (scrollView.tag) {
        case CCSpreadsheetViewCollectionUpperLeft:
            // Don't think we need to do anything here
            break;
            
        case CCSpreadsheetViewCollectionUpperRight:
            self.lowerLeftCollectionView.scrollEnabled = scrollEnabled;
            self.lowerRightCollectionView.scrollEnabled = scrollEnabled;
            break;
            
        case CCSpreadsheetViewCollectionLowerLeft:
            self.upperRightCollectionView.scrollEnabled = scrollEnabled;
            self.lowerRightCollectionView.scrollEnabled = scrollEnabled;
            break;
            
        case CCSpreadsheetViewCollectionLowerRight:
            self.upperRightCollectionView.scrollEnabled = scrollEnabled;
            self.lowerLeftCollectionView.scrollEnabled = scrollEnabled;
            break;
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *dataSourceIndexPath = [self dataSourceIndexPathFromCollectionView:collectionView indexPath:indexPath];
    CGSize size = [self.dataSource spreadsheetView:self sizeForItemAtIndexPath:dataSourceIndexPath];
    return size;
}

#pragma mark - UICollectionViewDataSource pass-through

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger rowCount = [self.dataSource numberOfRowsInSpreadsheetView:self];
    NSInteger adjustedRows = 1;
    
    switch (collectionView.tag) {
            
        case CCSpreadsheetViewCollectionUpperLeft:
            adjustedRows = self.headerRowCount;
            break;
            
        case CCSpreadsheetViewCollectionUpperRight:
            adjustedRows = self.headerRowCount;
            break;
            
        case CCSpreadsheetViewCollectionLowerLeft:
            adjustedRows = rowCount - self.headerRowCount;
            break;
            
        case CCSpreadsheetViewCollectionLowerRight:
            adjustedRows = rowCount - self.headerRowCount;
            break;
            
        default:
            NSAssert(NO, @"What have you done?");
            break;
    }
    return adjustedRows;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger items = 0;
    NSInteger columnCount = [self.dataSource numberOfColumnsInSpreadsheetView:self];
    
    switch (collectionView.tag) {
        case CCSpreadsheetViewCollectionUpperLeft:
            items = self.headerColumnCount;
            break;
            
        case CCSpreadsheetViewCollectionUpperRight:
            items = columnCount - self.headerColumnCount;
            break;
            
        case CCSpreadsheetViewCollectionLowerLeft:
            items = self.headerColumnCount;
            break;
            
        case CCSpreadsheetViewCollectionLowerRight:
            items = columnCount - self.headerColumnCount;
            break;
            
        default:
            NSAssert(NO, @"What have you done?");
            break;
    }
    
    return items;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *dataSourceIndexPath = [self dataSourceIndexPathFromCollectionView:collectionView indexPath:indexPath];
    UICollectionViewCell *cell = [self.dataSource spreadsheetView:self cellForItemAtIndexPath:dataSourceIndexPath];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectedItemCollectionView != nil) {
        if (collectionView == self.selectedItemCollectionView) {
            self.selectedItemIndexPath = indexPath;
        } else {
            [self.selectedItemCollectionView deselectItemAtIndexPath:self.selectedItemIndexPath animated:NO];
            self.selectedItemCollectionView = collectionView;
            self.selectedItemIndexPath = indexPath;
        }
    } else {
        self.selectedItemCollectionView = collectionView;
        self.selectedItemIndexPath = indexPath;
    }
    
    NSIndexPath *dataSourceIndexPath = [self dataSourceIndexPathFromCollectionView:collectionView indexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(spreadsheetView:didSelectItemAtIndexPath:)]) {
        [self.delegate spreadsheetView:self didSelectItemAtIndexPath:dataSourceIndexPath];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *dataSourceIndexPath = [self dataSourceIndexPathFromCollectionView:collectionView indexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(spreadsheetView:shouldShowMenuForItemAtIndexPath:)]) {
        return [self.delegate spreadsheetView:self shouldShowMenuForItemAtIndexPath:dataSourceIndexPath];
    }
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    NSIndexPath *dataSourceIndexPath = [self dataSourceIndexPathFromCollectionView:collectionView indexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(spreadsheetView:canPerformAction:forItemAtIndexPath:withSender:)]) {
        return [self.delegate spreadsheetView:self canPerformAction:action forItemAtIndexPath:dataSourceIndexPath withSender:sender];
    }
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    NSIndexPath *dataSourceIndexPath = [self dataSourceIndexPathFromCollectionView:collectionView indexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(spreadsheetView:performAction:forItemAtIndexPath:withSender:)]) {
        return [self.delegate spreadsheetView:self performAction:action forItemAtIndexPath:dataSourceIndexPath withSender:sender];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.controllingScrollView) {
        
        switch (scrollView.tag) {
            case CCSpreadsheetViewCollectionLowerLeft:
                [self lowerLeftCollectionViewDidScrollForScrollView:scrollView];
                break;
                
            case CCSpreadsheetViewCollectionUpperRight:
                [self upperRightCollectionViewDidScrollForScrollView:scrollView];
                break;
                
            case CCSpreadsheetViewCollectionLowerRight:
                [self lowerRightCollectionViewDidScrollForScrollView:scrollView];
                break;
        }
    } else {
        [scrollView setContentOffset:scrollView.contentOffset animated:NO];
    }
}

- (void)lowerLeftCollectionViewDidScrollForScrollView:(UIScrollView *)scrollView
{
    [self.lowerRightCollectionView setContentOffset:CGPointMake(self.lowerRightCollectionView.contentOffset.x, scrollView.contentOffset.y) animated:NO];
    [self updateVerticalScrollIndicator];
    
    if (scrollView.contentOffset.y <= 0.0f) {
        CGRect rect = self.upperLeftContainerView.frame;
        rect.origin.y = 0 - scrollView.contentOffset.y;
        self.upperLeftContainerView.frame = rect;
        
        rect = self.upperRightContainerView.frame;
        rect.origin.y = 0 - scrollView.contentOffset.y;
        self.upperRightContainerView.frame = rect;
    } else {
        CGRect rect = self.upperLeftContainerView.frame;
        rect.origin.y = 0.0f;
        self.upperLeftContainerView.frame = rect;
        
        rect = self.upperRightContainerView.frame;
        rect.origin.y = 0.0f;
        self.upperRightContainerView.frame = rect;
    }
}

- (void)upperRightCollectionViewDidScrollForScrollView:(UIScrollView *)scrollView
{
    [self.lowerRightCollectionView setContentOffset:CGPointMake(scrollView.contentOffset.x, self.lowerRightCollectionView.contentOffset.y) animated:NO];
    [self updateHorizontalScrollIndicator];
    
    if (scrollView.contentOffset.x <= 0.0f) {
        CGRect rect = self.upperLeftContainerView.frame;
        rect.origin.x = 0 - scrollView.contentOffset.x;
        self.upperLeftContainerView.frame = rect;
        
        rect = self.lowerLeftContainerView.frame;
        rect.origin.x = 0 - scrollView.contentOffset.x;
        self.lowerLeftContainerView.frame = rect;
    } else {
        CGRect rect = self.upperLeftContainerView.frame;
        rect.origin.x = 0.0f;
        self.upperLeftContainerView.frame = rect;
        
        rect = self.lowerLeftContainerView.frame;
        rect.origin.x = 0.0f;
        self.lowerLeftContainerView.frame = rect;
    }
}

- (void)lowerRightCollectionViewDidScrollForScrollView:(UIScrollView *)scrollView
{
    [self updateVerticalScrollIndicator];
    [self updateHorizontalScrollIndicator];
    
    CGPoint offset = CGPointMake(0.0f, scrollView.contentOffset.y);
    [self.lowerLeftCollectionView setContentOffset:offset animated:NO];
    offset = CGPointMake(scrollView.contentOffset.x, 0.0f);
    [self.upperRightCollectionView setContentOffset:offset animated:NO];
    
    if (scrollView.contentOffset.y <= 0.0f) {
        CGRect rect = self.upperLeftContainerView.frame;
        rect.origin.y = 0 - scrollView.contentOffset.y;
        self.upperLeftContainerView.frame = rect;
        
        rect = self.upperRightContainerView.frame;
        rect.origin.y = 0 - scrollView.contentOffset.y;
        self.upperRightContainerView.frame = rect;
    } else {
        CGRect rect = self.upperLeftContainerView.frame;
        rect.origin.y = 0.0f;
        self.upperLeftContainerView.frame = rect;
        
        rect = self.upperRightContainerView.frame;
        rect.origin.y = 0.0f;
        self.upperRightContainerView.frame = rect;
    }
    
    if (scrollView.contentOffset.x <= 0.0f) {
        CGRect rect = self.upperLeftContainerView.frame;
        rect.origin.x = 0 - scrollView.contentOffset.x;
        
        self.upperLeftContainerView.frame = rect;
        rect = self.lowerLeftContainerView.frame;
        rect.origin.x = 0 - scrollView.contentOffset.x;
        self.lowerLeftContainerView.frame = rect;
    } else {
        CGRect rect = self.upperLeftContainerView.frame;
        rect.origin.x = 0.0f;
        
        self.upperLeftContainerView.frame = rect;
        rect = self.lowerLeftContainerView.frame;
        rect.origin.x = 0.0f;
        self.lowerLeftContainerView.frame = rect;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self setScrollEnabledValue:NO scrollView:scrollView];
    
    if (self.controllingScrollView != scrollView) {
        
        [self.lowerLeftCollectionView setContentOffset:self.lowerLeftCollectionView.contentOffset animated:NO];
        [self.upperRightCollectionView setContentOffset:self.upperRightCollectionView.contentOffset animated:NO];
        [self.lowerRightCollectionView setContentOffset:self.lowerRightCollectionView.contentOffset animated:NO];
        self.controllingScrollView = scrollView;
    }
    [self showScrollIndicators];
    
    [self setScrollEnabledValue:YES scrollView:scrollView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    // Block UI if we're in a bounce.
    // Without this, you can lock the scroll views in a scroll which looks weird.
    CGPoint toffset = *targetContentOffset;
    switch (scrollView.tag) {
        case CCSpreadsheetViewCollectionLowerLeft: {
            BOOL willBouncePastZeroY = velocity.y < 0.0f && !(toffset.y > 0.0f);
            BOOL willBouncePastMaxY = toffset.y > self.lowerLeftCollectionView.contentSize.height - self.lowerLeftCollectionView.frame.size.height - 0.1f && velocity.y > 0.0f;
            if (willBouncePastZeroY || willBouncePastMaxY) {
                self.upperRightContainerView.userInteractionEnabled = NO;
                self.lowerRightContainerView.userInteractionEnabled = NO;
                self.lowerLeftBouncing = YES;
            }
            break;
        }
            
        case CCSpreadsheetViewCollectionUpperRight: {
            BOOL willBouncePastZeroX = velocity.x < 0.0f && !(toffset.x > 0.0f);
            BOOL willBouncePastMaxX = toffset.x > self.upperRightCollectionView.contentSize.width - self.upperRightCollectionView.frame.size.width - 0.1f && velocity.x > 0.0f;
            if (willBouncePastZeroX || willBouncePastMaxX) {
                self.lowerRightContainerView.userInteractionEnabled = NO;
                self.lowerLeftContainerView.userInteractionEnabled = NO;
                self.upperRightBouncing = YES;
            }
            break;
        }
            
        case CCSpreadsheetViewCollectionLowerRight: {
            BOOL willBouncePastZeroX = velocity.x < 0.0f && !(toffset.x > 0.0f);
            BOOL willBouncePastMaxX = toffset.x > self.upperRightCollectionView.contentSize.width - self.upperRightCollectionView.frame.size.width - 0.1f && velocity.x > 0.0f;
            BOOL willBouncePastZeroY = velocity.y < 0.0f && !(toffset.y > 0.0f);
            BOOL willBouncePastMaxY = toffset.y > self.lowerLeftCollectionView.contentSize.height - self.lowerLeftCollectionView.frame.size.height - 0.1f && velocity.y > 0.0f;
            if (willBouncePastZeroX || willBouncePastMaxX ||
                willBouncePastZeroY || willBouncePastMaxY) {
                self.upperRightContainerView.userInteractionEnabled = NO;
                self.lowerLeftContainerView.userInteractionEnabled = NO;
                self.lowerRightBouncing = YES;
            }
            break;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidStop:scrollView];
}

- (void)scrollViewDidStop:(UIScrollView *)scrollView
{
    self.upperRightContainerView.userInteractionEnabled = YES;
    self.lowerRightContainerView.userInteractionEnabled = YES;
    self.lowerLeftContainerView.userInteractionEnabled = YES;
    self.upperRightBouncing = NO;
    self.lowerLeftBouncing = NO;
    self.lowerRightBouncing = NO;
    
    if (!scrollView.isDecelerating && !scrollView.isDragging && !scrollView.isTracking) {
        [self setNeedsLayout];
        [self hideScrollIndicators];
    }
}

@end
