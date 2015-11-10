//
//  CCPopMenu.m
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


#import "CCPopMenu.h"
#import "CCPopMenuItemView.h"
#import "CCPageIndicatorView.h"

@interface CCPopMenu () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) UIView *menuContainerView;
@property(nonatomic, strong) CCPageIndicatorView *indicatorView;

@property(nonatomic, strong) UITableView *menuTableView;
@property(nonatomic, strong) NSMutableArray *menus;

@property(nonatomic, weak) UIView *currentSuperView;
@property(nonatomic, assign) CGPoint targetPoint;

@property(nonatomic, strong) NSIndexPath *indexPath;

@property(nonatomic, assign) CGFloat fromTheTop;

@end

@implementation CCPopMenu

- (void)showMenuAtPoint:(CGPoint)point
{
    [self showMenuOnView:[[UIApplication sharedApplication] keyWindow] atPoint:point];
}

- (void)showMenuOnView:(UIView *)view atPoint:(CGPoint)point
{
    self.currentSuperView = view;
    self.targetPoint = point;
    [self showMenu];
}

#pragma mark - animation

- (void)showMenu
{
    if (![self.currentSuperView.subviews containsObject:self]) {
        self.alpha = 0.0;
        
        if ([self.currentSuperView isKindOfClass:[UIWindow class]]) {
            self.fromTheTop = 64;
            [self layoutSubviews];
        }
        [self.currentSuperView addSubview:self];
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.alpha = 1.0;
            
            self.menuContainerView.frame = CGRectMake(CGRectGetWidth(self.bounds) - kCCMenuTableViewWidth - 6, _fromTheTop + 8, kCCMenuTableViewWidth, self.menus.count * (kCCMenuItemViewHeight + kCCSeparatorLineImageViewHeight) + kCCMenuTableViewSapcing);
            self.menuTableView.frame = CGRectMake(0, kCCMenuTableViewSapcing, CGRectGetWidth(_menuContainerView.bounds), CGRectGetHeight(_menuContainerView.bounds) - kCCMenuTableViewSapcing);
            
        } completion:^(BOOL finished){
            
        }];
    } else {
        [self dissMissPopMenuAnimatedOnMenuSelected:NO];
    }
}

- (void)dissMissPopMenuAnimatedOnMenuSelected:(BOOL)selected
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0.0;
        self.menuContainerView.frame = CGRectMake(CGRectGetWidth(self.bounds) - kCCMenuTableViewWidth - 6, _fromTheTop + 8, kCCMenuTableViewWidth, 0);
        self.menuTableView.frame = CGRectMake(0, kCCMenuTableViewSapcing, CGRectGetWidth(_menuContainerView.bounds), 0);
    } completion:^(BOOL finished) {
        if (selected) {
            if (self.popMenuDidDismissCompled) {
                self.popMenuDidDismissCompled(self.indexPath.row, self.menus[self.indexPath.row]);
            }
        }
        [super removeFromSuperview];
    }];
}

#pragma mark - Propertys
- (void)layoutSubviews
{
    CGRect frame = self.indicatorView.frame;
    frame.origin.y = _fromTheTop;
    self.indicatorView.frame = frame;
    
    frame = self.menuContainerView.frame;
    frame.origin.y = _fromTheTop + 8;
    self.menuContainerView.frame = frame;
}

- (UIView *)menuContainerView
{
    if (!_menuContainerView) {
        _menuContainerView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds) - kCCMenuTableViewWidth - 6, _fromTheTop + 8, kCCMenuTableViewWidth, 0)];
        _menuContainerView.backgroundColor = [UIColor whiteColor];
        _menuContainerView.layer.cornerRadius = 5;
        _menuContainerView.layer.masksToBounds = YES;
        _menuContainerView.userInteractionEnabled = YES;
        
        [_menuContainerView addSubview:self.menuTableView];
    }
    return _menuContainerView;
}

- (CCPageIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[CCPageIndicatorView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds) - 35, _fromTheTop, 20, 8)];
        _indicatorView.color = [UIColor whiteColor];
        _indicatorView.indicatorType = CCPageIndicatorViewTypeTriangle;
    }
    return _indicatorView;
}

- (UITableView *)menuTableView
{
    if (!_menuTableView) {
        _menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kCCMenuTableViewSapcing, CGRectGetWidth(_menuContainerView.bounds), 0) style:UITableViewStylePlain];
        _menuTableView.backgroundColor = [UIColor clearColor];
        _menuTableView.separatorColor = [UIColor clearColor];
        _menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _menuTableView.delegate = self;
        _menuTableView.dataSource = self;
        _menuTableView.rowHeight = kCCMenuItemViewHeight;
        _menuTableView.scrollEnabled = NO;
    }
    return _menuTableView;
}

/**
 *  @author CC, 2015-10-16
 *
 *  @brief  设置菜单栏背景颜色
 *
 *  @param menuBackgroundColor 颜色值
 */
- (void)setMenuBackgroundColor:(UIColor *)menuBackgroundColor
{
    _menuContainerView.backgroundColor = menuBackgroundColor;
    _indicatorView.color = menuBackgroundColor;
}

/**
 *  @author CC, 2015-10-16
 *
 *  @brief  设置菜单文字颜色
 *
 *  @param menuItemTextColor 颜色值
 */
- (void)setMenuItemTextColor:(UIColor *)menuItemTextColor
{
    _menuItemTextColor = menuItemTextColor;
    [self.menuTableView reloadData];
}

#pragma mark - Life Cycle

- (void)setup
{
    _fromTheTop = 0;
    self.frame = [[UIScreen mainScreen] bounds];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1];
    [self addSubview:self.indicatorView];
    [self addSubview:self.menuContainerView];
}

- (id)initWithMenus:(NSArray *)menus
{
    self = [super init];
    if (self) {
        self.menus = [[NSMutableArray alloc] initWithArray:menus];
        [self setup];
    }
    return self;
}

- (instancetype)initWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION
{
    self = [super init];
    if (self) {
        NSMutableArray *menuItems = [[NSMutableArray alloc] init];
        CCPopMenuItem *eachItem;
        va_list argumentList;
        if (firstObj) {
            [menuItems addObject:firstObj];
            va_start(argumentList, firstObj);
            while ((eachItem = va_arg(argumentList, CCPopMenuItem *))) {
                [menuItems addObject:eachItem];
            }
            va_end(argumentList);
        }
        self.menus = menuItems;
        [self setup];
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint localPoint = [touch locationInView:self];
    if (CGRectContainsPoint(_menuContainerView.frame, localPoint)) {
        [self hitTest:localPoint withEvent:event];
    } else {
        [self dissMissPopMenuAnimatedOnMenuSelected:NO];
    }
}

#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menus.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"cellIdentifer";
    CCPopMenuItemView *popMenuItemView = (CCPopMenuItemView *)[tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (!popMenuItemView) {
        popMenuItemView = [[CCPopMenuItemView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
    }
    
    if (indexPath.row < self.menus.count) {
        [popMenuItemView setupPopMenuItem:self.menus[indexPath.row] atIndexPath:indexPath isBottom:(indexPath.row == self.menus.count - 1)];
    }
    
    popMenuItemView.textLabel.textColor = self.menuItemTextColor;
    
    return popMenuItemView;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.indexPath = indexPath;
    [self dissMissPopMenuAnimatedOnMenuSelected:YES];
    if (self.popMenuDidSlectedCompled) {
        self.popMenuDidSlectedCompled(indexPath.row, self.menus[indexPath.row]);
    }
}

@end
